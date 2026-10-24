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
                    "SELECT ch.ChapterId, ch.ChapterTitle, ch.ChapterDescription, ch.ChapterDuration, ch.DateCreation, ch.DateUpdate " +
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
                                Updated = FormatDate(reader.IsDBNull(5) ? created : reader.GetDateTime(5))
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

        private static string FormatDate(DateTime value)
        {
            return value.ToString("d MMMM yyyy", CultureInfo.InvariantCulture);
        }
    }
}
