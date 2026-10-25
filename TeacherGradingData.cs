using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;

namespace Codercept
{
    /// <summary>
    /// Database queries for the "Grade assessments" page: what can be graded in one of the signed-in teacher's courses, and who has
    /// submitted it. Every query joins to Course and filters on Course.TeacherId = @TeacherId, so a forged CourseId of another teacher
    /// finds nothing. A submission is an Attempt the learner has completed; it waits for the teacher while it has no Result row.
    /// </summary>
    public static class TeacherGradingData
    {
        // Avatar colours (css .avatar--<tone>), picked by learner so a learner always keeps the same one
        private static readonly string[] Tones = { "indigo", "teal", "blue", "amber", "rose" };

        /// <summary>
        /// The course's exam, then the quizzes and assessments of its chapters (in chapter order), each with its number of questions,
        /// total marks and how many submissions wait for grading. Empty when the course has none of them.
        /// </summary>
        public static List<TeacherAssessment> GetGradables(int courseId)
        {
            List<TeacherAssessment> list = new List<TeacherAssessment>();
            int teacherId = TeacherDb.GetTeacherId();

            const string pendingOf = "(SELECT COUNT(*) FROM Attempt a WHERE a.{0} = t.{0} AND a.AttemptStatus = 'completed' " +
                                     "AND NOT EXISTS (SELECT 1 FROM Result r WHERE r.AttemptId = a.AttemptId))";
            const string questionsOf = "(SELECT COUNT(*) FROM Question q WHERE q.{0} = t.{0})";
            const string marksOf = "ISNULL((SELECT SUM(q.QuestionScore) FROM Question q WHERE q.{0} = t.{0}), 0)";

            string sql =
                "WITH Pos AS (SELECT ChapterId, ROW_NUMBER() OVER (ORDER BY ChapterNum, ChapterId) AS N FROM Chapter WHERE CourseId = @CourseId) " +
                "SELECT 'Exam' AS Type, t.ExamId AS Id, t.ExamTitle AS Title, 0 AS ChapterPos, " +
                    string.Format(questionsOf, "ExamId") + " AS Questions, " + string.Format(marksOf, "ExamId") + " AS Marks, " + string.Format(pendingOf, "ExamId") + " AS Pending " +
                "FROM Exam t INNER JOIN Course c ON c.CourseId = t.CourseId WHERE t.CourseId = @CourseId AND c.TeacherId = @TeacherId " +
                "UNION ALL " +
                "SELECT 'Quiz', t.QuizId, t.QuizTitle, CAST(p.N AS INT), " +
                    string.Format(questionsOf, "QuizId") + ", " + string.Format(marksOf, "QuizId") + ", " + string.Format(pendingOf, "QuizId") + " " +
                "FROM Quiz t INNER JOIN Pos p ON p.ChapterId = t.ChapterId INNER JOIN Chapter ch ON ch.ChapterId = t.ChapterId " +
                "INNER JOIN Course c ON c.CourseId = ch.CourseId WHERE c.TeacherId = @TeacherId " +
                "UNION ALL " +
                "SELECT 'Assessment', t.AssessmentId, t.AssessmentTitle, CAST(p.N AS INT), " +
                    string.Format(questionsOf, "AssessmentId") + ", " + string.Format(marksOf, "AssessmentId") + ", " + string.Format(pendingOf, "AssessmentId") + " " +
                "FROM Assessment t INNER JOIN Pos p ON p.ChapterId = t.ChapterId INNER JOIN Chapter ch ON ch.ChapterId = t.ChapterId " +
                "INNER JOIN Course c ON c.CourseId = ch.CourseId WHERE c.TeacherId = @TeacherId " +
                "ORDER BY ChapterPos, Id";

            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@CourseId", courseId);
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string type = reader.GetString(0);
                        int chapterPos = reader.GetInt32(3);
                        list.Add(new TeacherAssessment
                        {
                            Type = type,
                            Id = reader.GetInt32(1),
                            Title = type == "Exam" ? reader.GetString(2) : "Chapter " + chapterPos + " · " + reader.GetString(2),
                            Questions = reader.GetInt32(4),
                            TotalMarks = (int)Math.Round(reader.GetDouble(5)),
                            Pending = reader.GetInt32(6)
                        });
                    }
                }
            }
            return list;
        }

        /// <summary>
        /// Every learner who has submitted (completed) an attempt on one of the course's exam, quizzes or assessments. TestKey says which
        /// one ("exam:1", "quiz:3", "assessment:2", the same keys as TeacherAssessment.Key). Status is "Graded" once the attempt has a Result,
        /// "In progress" while the teacher has started grading it (a GradingProgress row), otherwise "Not graded".
        /// Waiting submissions come first, newest first.
        /// </summary>
        public static List<TeacherSubmission> GetSubmissions(int courseId)
        {
            List<TeacherSubmission> list = new List<TeacherSubmission>();
            int teacherId = TeacherDb.GetTeacherId();

            const string status =
                "CASE WHEN EXISTS (SELECT 1 FROM Result r WHERE r.AttemptId = a.AttemptId) THEN 'Graded' " +
                "WHEN EXISTS (SELECT 1 FROM GradingProgress g WHERE g.AttemptId = a.AttemptId) THEN 'In progress' ELSE 'Not graded' END";

            string sql =
                "SELECT a.AttemptId, a.LearnerId, l.Name, l.Email, a.AttemptDate, " + status + ", 'exam', a.ExamId " +
                "FROM Attempt a INNER JOIN Learner l ON l.LearnerId = a.LearnerId INNER JOIN Exam t ON t.ExamId = a.ExamId " +
                "INNER JOIN Course c ON c.CourseId = t.CourseId " +
                "WHERE t.CourseId = @CourseId AND c.TeacherId = @TeacherId AND a.AttemptStatus = 'completed' " +
                "UNION ALL " +
                "SELECT a.AttemptId, a.LearnerId, l.Name, l.Email, a.AttemptDate, " + status + ", 'quiz', a.QuizId " +
                "FROM Attempt a INNER JOIN Learner l ON l.LearnerId = a.LearnerId INNER JOIN Quiz t ON t.QuizId = a.QuizId " +
                "INNER JOIN Chapter ch ON ch.ChapterId = t.ChapterId INNER JOIN Course c ON c.CourseId = ch.CourseId " +
                "WHERE ch.CourseId = @CourseId AND c.TeacherId = @TeacherId AND a.AttemptStatus = 'completed' " +
                "UNION ALL " +
                "SELECT a.AttemptId, a.LearnerId, l.Name, l.Email, a.AttemptDate, " + status + ", 'assessment', a.AssessmentId " +
                "FROM Attempt a INNER JOIN Learner l ON l.LearnerId = a.LearnerId INNER JOIN Assessment t ON t.AssessmentId = a.AssessmentId " +
                "INNER JOIN Chapter ch ON ch.ChapterId = t.ChapterId INNER JOIN Course c ON c.CourseId = ch.CourseId " +
                "WHERE ch.CourseId = @CourseId AND c.TeacherId = @TeacherId AND a.AttemptStatus = 'completed'";

            List<DateTime> dates = new List<DateTime>();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@CourseId", courseId);
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string name = reader.GetString(2);
                        DateTime when = reader.GetDateTime(4);
                        dates.Add(when);
                        list.Add(new TeacherSubmission
                        {
                            Id = reader.GetInt32(0),
                            Initials = InitialsOf(name),
                            Name = name,
                            Email = reader.GetString(3),
                            Tone = Tones[reader.GetInt32(1) % Tones.Length],
                            Status = reader.GetString(5),
                            Submitted = when.ToString("d MMM yyyy, h:mm tt", CultureInfo.InvariantCulture),
                            TestKey = reader.GetString(6) + ":" + reader.GetInt32(7)
                        });
                    }
                }
            }

            // waiting submissions first (not graded, then in progress, then graded), newest first within each
            return list.Select((s, i) => new { s, when = dates[i] })
                .OrderBy(x => x.s.Status == "Not graded" ? 0 : x.s.Status == "In progress" ? 1 : 2)
                .ThenByDescending(x => x.when)
                .Select(x => x.s)
                .ToList();
        }

        /// <summary>"Tang Chee Kin" -> "TK" (first letters of the first and last word).</summary>
        private static string InitialsOf(string name)
        {
            string[] words = (name ?? "").Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (words.Length == 0) return "?";
            string initials = words[0].Substring(0, 1) + (words.Length > 1 ? words[words.Length - 1].Substring(0, 1) : "");
            return initials.ToUpperInvariant();
        }
    }
}
