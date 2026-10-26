using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;

namespace Codercept
{
    /// <summary>
    /// Database queries for the chapters of the signed-in teacher's courses. A chapter has no owner check of its own:
    /// every query joins Chapter to its Course and filters on Course.TeacherId = @TeacherId, so a forged ChapterId or
    /// CourseId of another teacher finds nothing.
    /// </summary>
    public static class TeacherChapterData
    {
        /// <summary>
        /// The chapters of one of the signed-in teacher's courses, in course order, each with its subchapters and its
        /// quiz or assessment. Empty when the course has no chapters or is not this teacher's.
        /// </summary>
        public static List<TeacherChapter> GetChapters(int courseId)
        {
            List<TeacherChapter> list = new List<TeacherChapter>();
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand(
                    "SELECT ch.ChapterId, ch.ChapterTitle, ch.ChapterDescription, ch.ChapterDuration, ch.DateCreation, ch.DateUpdate, ch.ChapterMediaLink " +
                    "FROM Chapter ch INNER JOIN Course c ON c.CourseId = ch.CourseId " +
                    "WHERE ch.CourseId = @CourseId AND c.TeacherId = @TeacherId " +
                    "ORDER BY ch.ChapterNum, ch.ChapterId", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            DateTime created = reader.GetDateTime(4);
                            list.Add(new TeacherChapter
                            {
                                Id = reader.GetInt32(0),
                                Number = list.Count + 1, // the position in the list; ChapterNum is only used for the order
                                Title = reader.GetString(1),
                                Description = reader.GetString(2),
                                Duration = reader.GetString(3),
                                Created = FormatDate(created),
                                Updated = FormatDate(reader.IsDBNull(5) ? created : reader.GetDateTime(5)),
                                MediaLink = reader.IsDBNull(6) ? null : reader.GetString(6)
                            });
                        }
                    }
                }

                // all subchapters of the course in one query, in their order
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT sc.ChapterId, sc.SubChapterId, sc.SubChapterTitle " +
                    "FROM SubChapter sc INNER JOIN Chapter ch ON ch.ChapterId = sc.ChapterId " +
                    "INNER JOIN Course c ON c.CourseId = ch.CourseId " +
                    "WHERE ch.CourseId = @CourseId AND c.TeacherId = @TeacherId " +
                    "ORDER BY sc.ChapterId, sc.SubChapterOrder, sc.SubChapterId", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int chapterId = reader.GetInt32(0);
                            TeacherChapter chapter = list.FirstOrDefault(c => c.Id == chapterId);
                            if (chapter != null)
                            {
                                chapter.Contents.Add(new TeacherContentItem { Id = reader.GetInt32(1), Type = "subchapter", Title = reader.GetString(2) });
                            }
                        }
                    }
                }

                // the quiz or assessment of each chapter, with its number of questions and total marks
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT t.ChapterId, 'quiz', t.QuizId, t.QuizTitle, " +
                    "       (SELECT COUNT(*) FROM Question q WHERE q.QuizId = t.QuizId), " +
                    "       ISNULL((SELECT SUM(q.QuestionScore) FROM Question q WHERE q.QuizId = t.QuizId), 0) " +
                    "FROM Quiz t INNER JOIN Chapter ch ON ch.ChapterId = t.ChapterId INNER JOIN Course c ON c.CourseId = ch.CourseId " +
                    "WHERE ch.CourseId = @CourseId AND c.TeacherId = @TeacherId " +
                    "UNION ALL " +
                    "SELECT t.ChapterId, 'assessment', t.AssessmentId, t.AssessmentTitle, " +
                    "       (SELECT COUNT(*) FROM Question q WHERE q.AssessmentId = t.AssessmentId), " +
                    "       ISNULL((SELECT SUM(q.QuestionScore) FROM Question q WHERE q.AssessmentId = t.AssessmentId), 0) " +
                    "FROM Assessment t INNER JOIN Chapter ch ON ch.ChapterId = t.ChapterId INNER JOIN Course c ON c.CourseId = ch.CourseId " +
                    "WHERE ch.CourseId = @CourseId AND c.TeacherId = @TeacherId", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int chapterId = reader.GetInt32(0);
                            TeacherChapter chapter = list.FirstOrDefault(c => c.Id == chapterId);
                            if (chapter != null)
                            {
                                chapter.Test = new TeacherChapterTestInfo
                                {
                                    Type = reader.GetString(1),
                                    Id = reader.GetInt32(2),
                                    Title = reader.GetString(3),
                                    Questions = reader.GetInt32(4),
                                    TotalMarks = (int)Math.Round(reader.GetDouble(5))
                                };
                            }
                        }
                    }
                }
            }
            return list;
        }

        /// <summary>
        /// One chapter of the signed-in teacher's, with its position in the course (Number), its course and subchapters;
        /// null when the id is not one of this teacher's chapters.
        /// </summary>
        public static TeacherChapter GetChapter(int chapterId)
        {
            int courseId = GetCourseIdOfChapter(chapterId);
            if (courseId == 0) return null;
            TeacherChapter chapter = GetChapters(courseId).FirstOrDefault(c => c.Id == chapterId);
            if (chapter == null) return null;
            chapter.CourseId = courseId;
            TeacherCourse course = TeacherCourseData.GetCourse(courseId);
            chapter.CourseTitle = course == null ? "" : course.Title;
            return chapter;
        }

        /// <summary>
        /// The CourseId of a chapter if its course belongs to the signed-in teacher, otherwise 0
        /// (used to open Manage Chapters on the right course from a ?chapter= link).
        /// </summary>
        public static int GetCourseIdOfChapter(int chapterId)
        {
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                "SELECT ch.CourseId FROM Chapter ch INNER JOIN Course c ON c.CourseId = ch.CourseId " +
                "WHERE ch.ChapterId = @ChapterId AND c.TeacherId = @TeacherId", con))
            {
                cmd.Parameters.AddWithValue("@ChapterId", chapterId);
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                con.Open();
                object found = cmd.ExecuteScalar();
                return found == null ? 0 : (int)found;
            }
        }

        /// <summary>True when another chapter of this course (not excludeChapterId) already has this title, ignoring case.</summary>
        public static bool TitleExists(int courseId, string title, int excludeChapterId)
        {
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(*) FROM Chapter ch INNER JOIN Course c ON c.CourseId = ch.CourseId " +
                "WHERE ch.CourseId = @CourseId AND c.TeacherId = @TeacherId AND ch.ChapterId <> @Exclude AND ch.ChapterTitle = @Title", con))
            {
                cmd.Parameters.AddWithValue("@CourseId", courseId);
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                cmd.Parameters.AddWithValue("@Exclude", excludeChapterId);
                cmd.Parameters.AddWithValue("@Title", title); // the database comparison ignores case
                con.Open();
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        /// <summary>True when learners are enrolled in the course (their progress points at chapter positions).</summary>
        public static bool CourseHasLearners(int courseId)
        {
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(*) FROM LearnerProgress lp INNER JOIN Course c ON c.CourseId = lp.CourseId " +
                "WHERE lp.CourseId = @CourseId AND c.TeacherId = @TeacherId", con))
            {
                cmd.Parameters.AddWithValue("@CourseId", courseId);
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                con.Open();
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        /// <summary>
        /// Adds a chapter at the end of one of the signed-in teacher's courses and returns its ChapterId,
        /// or 0 (and adds nothing) when the course does not belong to the teacher.
        /// </summary>
        public static int CreateChapter(int courseId, string title, string description, decimal hours, string mediaLink)
        {
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    // the new chapter's position: one after the last (locks the course's chapters so two adds cannot take the same one)
                    int next;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT ISNULL(MAX(ch.ChapterNum), 0) + 1 FROM Course c LEFT JOIN Chapter ch WITH (UPDLOCK, HOLDLOCK) ON ch.CourseId = c.CourseId " +
                        "WHERE c.CourseId = @CourseId AND c.TeacherId = @TeacherId HAVING COUNT(c.CourseId) > 0", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@CourseId", courseId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        object found = cmd.ExecuteScalar();
                        if (found == null) return 0; // not this teacher's course
                        next = Convert.ToInt32(found);
                    }

                    int chapterId;
                    using (SqlCommand cmd = new SqlCommand(
                        "INSERT INTO Chapter (DateCreation, DateUpdate, ChapterNum, ChapterTitle, ChapterDescription, ChapterDuration, ChapterMediaLink, CourseId, TeacherId) " +
                        "VALUES (GETDATE(), NULL, @Num, @Title, @Description, @Duration, @Media, @CourseId, @TeacherId); " +
                        "SELECT CAST(SCOPE_IDENTITY() AS INT)", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@Num", next);
                        cmd.Parameters.AddWithValue("@Title", title);
                        cmd.Parameters.AddWithValue("@Description", description);
                        cmd.Parameters.AddWithValue("@Duration", HoursText(hours));
                        cmd.Parameters.AddWithValue("@Media", (object)mediaLink ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@CourseId", courseId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        chapterId = (int)cmd.ExecuteScalar();
                    }
                    tx.Commit();
                    return chapterId;
                }
            }
        }

        /// <summary>What happened when a teacher saved a chapter.</summary>
        public enum SaveResult
        {
            Saved,
            /// <summary>The chapter is not in one of this teacher's courses.</summary>
            NotFound,
            /// <summary>The posted order does not list exactly the course's chapters (the page is out of date).</summary>
            OrderMismatch
        }

        /// <summary>
        /// Saves a chapter's title, description and duration and, when order is given (ChapterIds in the arranged order), the order of
        /// all the course's chapters, in one transaction. orderChanged tells whether the order differs from the stored one.
        /// When changeMedia is true the chapter's file link becomes newMedia (null removes it) and oldMedia returns the link it had,
        /// so the caller can delete that file from disk after a successful save.
        /// </summary>
        public static SaveResult UpdateChapter(int courseId, int chapterId, string title, string description, decimal hours, List<int> order,
            bool changeMedia, string newMedia, out string oldMedia, out bool orderChanged)
        {
            orderChanged = false;
            oldMedia = null;
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    // the course's chapters in their stored order, only if the course is this teacher's
                    List<int> stored = new List<int>();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT ch.ChapterId FROM Chapter ch INNER JOIN Course c ON c.CourseId = ch.CourseId " +
                        "WHERE ch.CourseId = @CourseId AND c.TeacherId = @TeacherId ORDER BY ch.ChapterNum, ch.ChapterId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@CourseId", courseId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read()) stored.Add(reader.GetInt32(0));
                        }
                    }
                    if (!stored.Contains(chapterId)) return SaveResult.NotFound;

                    if (order != null && order.Count > 0)
                    {
                        if (order.Count != stored.Count || order.Distinct().Count() != order.Count || order.Any(id => !stored.Contains(id)))
                        {
                            return SaveResult.OrderMismatch;
                        }
                        orderChanged = !order.SequenceEqual(stored);
                    }

                    using (SqlCommand cmd = new SqlCommand("SELECT ChapterMediaLink FROM Chapter WHERE ChapterId = @ChapterId AND CourseId = @CourseId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
                        cmd.Parameters.AddWithValue("@CourseId", courseId);
                        object link = cmd.ExecuteScalar();
                        oldMedia = link == null || link == DBNull.Value ? null : (string)link;
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE Chapter SET ChapterTitle = @Title, ChapterDescription = @Description, ChapterDuration = @Duration, DateUpdate = GETDATE(), " +
                        "ChapterMediaLink = CASE WHEN @ChangeMedia = 1 THEN @Media ELSE ChapterMediaLink END " +
                        "WHERE ChapterId = @ChapterId AND CourseId = @CourseId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@ChangeMedia", changeMedia ? 1 : 0);
                        cmd.Parameters.AddWithValue("@Media", (object)newMedia ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@Title", title);
                        cmd.Parameters.AddWithValue("@Description", description);
                        cmd.Parameters.AddWithValue("@Duration", HoursText(hours));
                        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
                        cmd.Parameters.AddWithValue("@CourseId", courseId);
                        cmd.ExecuteNonQuery();
                    }

                    if (orderChanged) Renumber(con, tx, courseId, order);
                    tx.Commit();
                    return SaveResult.Saved;
                }
            }
        }

        /// <summary>What happened when a teacher asked to delete a chapter.</summary>
        public enum DeleteResult
        {
            Deleted,
            NotFound,
            /// <summary>Learners have attempts on this chapter's quiz or assessment: their results are kept, so the chapter stays.</summary>
            HasAttempts
        }

        /// <summary>
        /// Deletes a chapter of the signed-in teacher with its subchapters and its quiz or assessment (and their questions and options),
        /// in foreign-key order inside one transaction, then renumbers the course's remaining chapters 1..n.
        /// Learners may be enrolled: their saved chapter position (LearnerProgress.ChapNum) moves with the chapters that remain.
        /// Refused only when learners have attempts on the chapter's quiz or assessment, because those results must be kept.
        /// mediaFiles lists the stored files that belonged to the deleted rows; the caller removes them from disk once the delete succeeded.
        /// </summary>
        public static DeleteResult DeleteChapter(int chapterId, out List<string> mediaFiles)
        {
            mediaFiles = new List<string>();
            int teacherId = TeacherDb.GetTeacherId();
            SqlParameter id() { return new SqlParameter("@ChapterId", chapterId); }

            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    int courseId;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT ch.CourseId FROM Chapter ch INNER JOIN Course c ON c.CourseId = ch.CourseId " +
                        "WHERE ch.ChapterId = @ChapterId AND c.TeacherId = @TeacherId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        object found = cmd.ExecuteScalar();
                        if (found == null) return DeleteResult.NotFound;
                        courseId = (int)found;
                    }

                    // the chapter's position (1, 2, 3 ...) before it goes
                    List<int> before = new List<int>();
                    using (SqlCommand cmd = new SqlCommand("SELECT ChapterId FROM Chapter WHERE CourseId = @CourseId ORDER BY ChapterNum, ChapterId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@CourseId", courseId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read()) before.Add(reader.GetInt32(0));
                        }
                    }
                    int position = before.IndexOf(chapterId) + 1;

                    const string quizzes = "(SELECT QuizId FROM Quiz WHERE ChapterId = @ChapterId)";
                    const string assessments = "(SELECT AssessmentId FROM Assessment WHERE ChapterId = @ChapterId)";

                    int attempts;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM Attempt WHERE QuizId IN " + quizzes + " OR AssessmentId IN " + assessments, con, tx))
                    {
                        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
                        attempts = (int)cmd.ExecuteScalar();
                    }
                    if (attempts > 0) return DeleteResult.HasAttempts;

                    // the files that go away with the rows
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT ChapterMediaLink FROM Chapter WHERE ChapterId = @ChapterId " +
                        "UNION ALL SELECT SubChapterMediaLink FROM SubChapter WHERE ChapterId = @ChapterId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                if (!reader.IsDBNull(0)) mediaFiles.Add(reader.GetString(0));
                            }
                        }
                    }

                    string questions = "QuizId IN " + quizzes + " OR AssessmentId IN " + assessments;
                    Run(con, tx, "DELETE FROM MCQ_Option WHERE QuestionId IN (SELECT QuestionId FROM Question WHERE " + questions + ")", id());
                    Run(con, tx, "DELETE FROM Question WHERE " + questions, id());
                    Run(con, tx, "DELETE FROM Quiz WHERE ChapterId = @ChapterId", id());
                    Run(con, tx, "DELETE FROM Assessment WHERE ChapterId = @ChapterId", id());
                    Run(con, tx, "DELETE FROM SubChapter WHERE ChapterId = @ChapterId", id());
                    Run(con, tx, "DELETE FROM Chapter WHERE ChapterId = @ChapterId", id());

                    // close the gap: the remaining chapters are numbered 1..n again
                    List<int> remaining = new List<int>();
                    using (SqlCommand cmd = new SqlCommand("SELECT ChapterId FROM Chapter WHERE CourseId = @CourseId ORDER BY ChapterNum, ChapterId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@CourseId", courseId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read()) remaining.Add(reader.GetInt32(0));
                        }
                    }
                    Renumber(con, tx, courseId, remaining);

                    // learners keep pointing at the same chapter: those past the deleted one move up by one, and nobody points past the end
                    Run(con, tx, "UPDATE LearnerProgress SET ChapNum = ChapNum - 1 WHERE CourseId = @CourseId AND ChapNum > @Position",
                        new SqlParameter("@CourseId", courseId), new SqlParameter("@Position", position));
                    if (remaining.Count == 0)
                    {
                        Run(con, tx, "UPDATE LearnerProgress SET ChapNum = NULL WHERE CourseId = @CourseId", new SqlParameter("@CourseId", courseId));
                    }
                    else
                    {
                        Run(con, tx, "UPDATE LearnerProgress SET ChapNum = @Last WHERE CourseId = @CourseId AND ChapNum > @Last",
                            new SqlParameter("@CourseId", courseId), new SqlParameter("@Last", remaining.Count));
                    }

                    tx.Commit();
                    return DeleteResult.Deleted;
                }
            }
        }

        /// <summary>ChapterNum = position (1, 2, 3 ...) in the given order. The caller has already checked ownership.</summary>
        private static void Renumber(SqlConnection con, SqlTransaction tx, int courseId, List<int> order)
        {
            for (int i = 0; i < order.Count; i++)
            {
                Run(con, tx, "UPDATE Chapter SET ChapterNum = @Num WHERE ChapterId = @ChapterId AND CourseId = @CourseId",
                    new SqlParameter("@Num", i + 1), new SqlParameter("@ChapterId", order[i]), new SqlParameter("@CourseId", courseId));
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

        /// <summary>Chapter.ChapterDuration is text such as "2.5 hours" or "1 hour".</summary>
        private static string HoursText(decimal hours)
        {
            string text = hours.ToString("0.##", CultureInfo.InvariantCulture);
            return text + (text == "1" ? " hour" : " hours");
        }

        /// <summary>"2.5 hours" -> "2.5" (for the duration text box).</summary>
        public static string HoursOf(string duration)
        {
            return (duration ?? "").Replace("hours", "").Replace("hour", "").Trim();
        }

        private static string FormatDate(DateTime value)
        {
            return value.ToString("d MMMM yyyy", CultureInfo.InvariantCulture);
        }
    }
}
