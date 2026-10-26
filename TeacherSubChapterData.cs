using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;

namespace Codercept
{
    /// <summary>
    /// Database queries for the subchapters of the signed-in teacher's chapters. A subchapter has no owner check of its own:
    /// every query joins SubChapter -> Chapter -> Course and filters on Course.TeacherId = @TeacherId, so a forged id of
    /// another teacher's chapter or subchapter finds nothing.
    /// </summary>
    public static class TeacherSubChapterData
    {
        public const int MaxMinutes = 600;

        /// <summary>The subchapters of one of the signed-in teacher's chapters, in their order. Empty when there are none or the chapter is not the teacher's.</summary>
        public static List<TeacherContentItem> GetSubChapters(int chapterId)
        {
            List<TeacherContentItem> list = new List<TeacherContentItem>();
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                "SELECT sc.SubChapterId, sc.SubChapterTitle, sc.SubChapterContent, sc.SubChapterDuration, sc.SubChapterMediaLink " +
                "FROM SubChapter sc INNER JOIN Chapter ch ON ch.ChapterId = sc.ChapterId INNER JOIN Course c ON c.CourseId = ch.CourseId " +
                "WHERE sc.ChapterId = @ChapterId AND c.TeacherId = @TeacherId " +
                "ORDER BY sc.SubChapterOrder, sc.SubChapterId", con))
            {
                cmd.Parameters.AddWithValue("@ChapterId", chapterId);
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(new TeacherContentItem
                        {
                            Id = reader.GetInt32(0),
                            Type = "subchapter",
                            Title = reader.GetString(1),
                            Description = reader.GetString(2),
                            Minutes = reader.GetInt32(3),
                            MediaLink = reader.IsDBNull(4) ? null : reader.GetString(4)
                        });
                    }
                }
            }
            return list;
        }

        /// <summary>Adds a subchapter at the end of one of the signed-in teacher's chapters and returns its SubChapterId, or 0 when the chapter is not the teacher's.</summary>
        public static int CreateSubChapter(int chapterId, string title, string description, int minutes, string mediaLink)
        {
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    // the new subchapter's position: one after the last (the lock stops two adds from taking the same one)
                    int next;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT ISNULL(MAX(sc.SubChapterOrder), 0) + 1 FROM Chapter ch INNER JOIN Course c ON c.CourseId = ch.CourseId " +
                        "LEFT JOIN SubChapter sc WITH (UPDLOCK, HOLDLOCK) ON sc.ChapterId = ch.ChapterId " +
                        "WHERE ch.ChapterId = @ChapterId AND c.TeacherId = @TeacherId HAVING COUNT(ch.ChapterId) > 0", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        object found = cmd.ExecuteScalar();
                        if (found == null) return 0; // not this teacher's chapter
                        next = Convert.ToInt32(found);
                    }

                    int subChapterId;
                    using (SqlCommand cmd = new SqlCommand(
                        "INSERT INTO SubChapter (DateCreation, DateUpdate, SubChapterOrder, SubChapterTitle, SubChapterContent, SubChapterMediaLink, SubChapterDuration, ChapterId, TeacherId) " +
                        "VALUES (GETDATE(), GETDATE(), @Order, @Title, @Content, @Media, @Minutes, @ChapterId, @TeacherId); " +
                        "SELECT CAST(SCOPE_IDENTITY() AS INT)", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@Order", next);
                        cmd.Parameters.AddWithValue("@Title", title);
                        cmd.Parameters.AddWithValue("@Content", description);
                        cmd.Parameters.AddWithValue("@Media", (object)mediaLink ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Minutes", minutes);
                        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        subChapterId = (int)cmd.ExecuteScalar();
                    }
                    tx.Commit();
                    return subChapterId;
                }
            }
        }

        /// <summary>
        /// Saves a subchapter's title, description and duration and, when order is given (SubChapterIds in the arranged order), the order of
        /// all the chapter's subchapters, in one transaction. When changeMedia is true the file link becomes newMedia (null removes it) and
        /// oldMedia returns the link it had, so the caller can delete that file from disk after a successful save.
        /// </summary>
        public static TeacherChapterData.SaveResult UpdateSubChapter(int chapterId, int subChapterId, string title, string description, int minutes,
            List<int> order, bool changeMedia, string newMedia, out string oldMedia, out bool orderChanged)
        {
            orderChanged = false;
            oldMedia = null;
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    // the chapter's subchapters in their stored order, only if the chapter's course is this teacher's
                    List<int> stored = new List<int>();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT sc.SubChapterId FROM SubChapter sc INNER JOIN Chapter ch ON ch.ChapterId = sc.ChapterId INNER JOIN Course c ON c.CourseId = ch.CourseId " +
                        "WHERE sc.ChapterId = @ChapterId AND c.TeacherId = @TeacherId ORDER BY sc.SubChapterOrder, sc.SubChapterId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read()) stored.Add(reader.GetInt32(0));
                        }
                    }
                    if (!stored.Contains(subChapterId)) return TeacherChapterData.SaveResult.NotFound;

                    if (order != null && order.Count > 0)
                    {
                        if (order.Count != stored.Count || order.Distinct().Count() != order.Count || order.Any(id => !stored.Contains(id)))
                        {
                            return TeacherChapterData.SaveResult.OrderMismatch;
                        }
                        orderChanged = !order.SequenceEqual(stored);
                    }

                    using (SqlCommand cmd = new SqlCommand("SELECT SubChapterMediaLink FROM SubChapter WHERE SubChapterId = @SubChapterId AND ChapterId = @ChapterId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@SubChapterId", subChapterId);
                        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
                        object link = cmd.ExecuteScalar();
                        oldMedia = link == null || link == DBNull.Value ? null : (string)link;
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE SubChapter SET SubChapterTitle = @Title, SubChapterContent = @Content, SubChapterDuration = @Minutes, DateUpdate = GETDATE(), " +
                        "SubChapterMediaLink = CASE WHEN @ChangeMedia = 1 THEN @Media ELSE SubChapterMediaLink END " +
                        "WHERE SubChapterId = @SubChapterId AND ChapterId = @ChapterId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@Title", title);
                        cmd.Parameters.AddWithValue("@Content", description);
                        cmd.Parameters.AddWithValue("@Minutes", minutes);
                        cmd.Parameters.AddWithValue("@ChangeMedia", changeMedia ? 1 : 0);
                        cmd.Parameters.AddWithValue("@Media", (object)newMedia ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@SubChapterId", subChapterId);
                        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
                        cmd.ExecuteNonQuery();
                    }

                    if (orderChanged) Renumber(con, tx, chapterId, order);
                    tx.Commit();
                    return TeacherChapterData.SaveResult.Saved;
                }
            }
        }

        /// <summary>
        /// Deletes one of the signed-in teacher's subchapters and renumbers the chapter's remaining subchapters 1..n.
        /// Learners may be enrolled: their progress is kept per chapter, so a subchapter can go. mediaFile is the stored file that
        /// belonged to it (or null); the caller removes it from disk once the delete succeeded.
        /// </summary>
        public static TeacherChapterData.DeleteResult DeleteSubChapter(int subChapterId, out string mediaFile)
        {
            mediaFile = null;
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    int chapterId;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT sc.ChapterId, sc.SubChapterMediaLink FROM SubChapter sc INNER JOIN Chapter ch ON ch.ChapterId = sc.ChapterId " +
                        "INNER JOIN Course c ON c.CourseId = ch.CourseId WHERE sc.SubChapterId = @SubChapterId AND c.TeacherId = @TeacherId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@SubChapterId", subChapterId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (!reader.Read()) return TeacherChapterData.DeleteResult.NotFound;
                            chapterId = reader.GetInt32(0);
                            mediaFile = reader.IsDBNull(1) ? null : reader.GetString(1);
                        }
                    }

                    Run(con, tx, "DELETE FROM SubChapter WHERE SubChapterId = @SubChapterId AND ChapterId = @ChapterId",
                        new SqlParameter("@SubChapterId", subChapterId), new SqlParameter("@ChapterId", chapterId));

                    List<int> remaining = new List<int>();
                    using (SqlCommand cmd = new SqlCommand("SELECT SubChapterId FROM SubChapter WHERE ChapterId = @ChapterId ORDER BY SubChapterOrder, SubChapterId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read()) remaining.Add(reader.GetInt32(0));
                        }
                    }
                    Renumber(con, tx, chapterId, remaining);

                    tx.Commit();
                    return TeacherChapterData.DeleteResult.Deleted;
                }
            }
        }

        /// <summary>SubChapterOrder = position (1, 2, 3 ...) in the given order. The caller has already checked ownership.</summary>
        private static void Renumber(SqlConnection con, SqlTransaction tx, int chapterId, List<int> order)
        {
            for (int i = 0; i < order.Count; i++)
            {
                Run(con, tx, "UPDATE SubChapter SET SubChapterOrder = @Order WHERE SubChapterId = @SubChapterId AND ChapterId = @ChapterId",
                    new SqlParameter("@Order", i + 1), new SqlParameter("@SubChapterId", order[i]), new SqlParameter("@ChapterId", chapterId));
            }
        }

        private static int Run(SqlConnection con, SqlTransaction tx, string sql, params SqlParameter[] parameters)
        {
            using (SqlCommand cmd = new SqlCommand(sql, con, tx))
            {
                cmd.Parameters.AddRange(parameters);
                return cmd.ExecuteNonQuery();
            }
        }
    }
}
