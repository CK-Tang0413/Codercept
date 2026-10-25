using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;

namespace Codercept
{
    /// <summary>
    /// Database queries for the teacher's learner pages. A learner belongs to a teacher through an enrolment (LearnerProgress) in one of that
    /// teacher's courses, so every query is joined to Course and filtered on Course.TeacherId = @TeacherId: a forged CourseId of another
    /// teacher finds nothing. A value that is not known (yet) is "-", which the pages show as "Not available yet".
    /// </summary>
    public static class TeacherLearnerData
    {
        // Avatar colours (css .avatar--<tone>), picked by learner so a learner always keeps the same one
        private static readonly string[] Tones = { "indigo", "teal", "blue", "amber", "rose" };

        /// <summary>One attempt of a learner on a quiz, assessment or the exam of the course, with its result if it has been graded.</summary>
        private class AttemptRow
        {
            public string Kind;
            public int TestId;
            public DateTime Date;
            public string Status;
            public double? Average;
            public string Grade;
        }

        /// <summary>
        /// The learners enrolled in the course, by name. Empty when the course is not one of the signed-in teacher's. Progress is the current
        /// chapter out of the course's chapters (100% once the learner holds the course certificate); "Quizzes" counts the course's quizzes and
        /// assessments the learner has completed; the exam score and grade are those of the latest graded exam attempt; the average is the mean
        /// percentage of every graded result in the course. "Last accessed" is the learner's latest attempt in the course and "Completed" is the
        /// date of the course certificate, until the learner side records visits.
        /// </summary>
        public static List<TeacherLearner> GetLearners(int courseId)
        {
            int teacherId = TeacherDb.GetTeacherId();
            List<TeacherLearner> learners = new List<TeacherLearner>();
            List<int?> chapNums = new List<int?>();
            List<DateTime> enrolled = new List<DateTime>();
            int chapters = 0, tests = 0;
            Dictionary<int, List<AttemptRow>> attempts = new Dictionary<int, List<AttemptRow>>();
            Dictionary<int, DateTime> certificates = new Dictionary<int, DateTime>();

            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand(
                    "SELECT l.LearnerId, l.Name, l.Email, l.Age, l.AccStatus, lp.ChapNum, lp.EnrolledDate " +
                    "FROM LearnerProgress lp INNER JOIN Learner l ON l.LearnerId = lp.LearnerId INNER JOIN Course c ON c.CourseId = lp.CourseId " +
                    "WHERE lp.CourseId = @CourseId AND c.TeacherId = @TeacherId ORDER BY l.Name, l.LearnerId", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string name = reader.GetString(1);
                            learners.Add(new TeacherLearner
                            {
                                Id = reader.GetInt32(0),
                                Name = name,
                                Initials = InitialsOf(name),
                                Email = reader.GetString(2),
                                Tone = Tones[reader.GetInt32(0) % Tones.Length],
                                Age = reader.IsDBNull(3) ? "-" : reader.GetInt32(3).ToString(CultureInfo.InvariantCulture),
                                Status = reader.GetString(4),
                                // the learner table has no gender or level
                                Gender = "-",
                                Level = "-"
                            });
                            chapNums.Add(reader.IsDBNull(5) ? (int?)null : reader.GetInt32(5));
                            enrolled.Add(reader.GetDateTime(6));
                        }
                    }
                }
                if (learners.Count == 0) return learners;

                // what the course holds: its chapters, and its quizzes and assessments
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT (SELECT COUNT(*) FROM Chapter ch WHERE ch.CourseId = c.CourseId), " +
                    "(SELECT COUNT(*) FROM Quiz z INNER JOIN Chapter ch ON ch.ChapterId = z.ChapterId WHERE ch.CourseId = c.CourseId) + " +
                    "(SELECT COUNT(*) FROM Assessment s INNER JOIN Chapter ch ON ch.ChapterId = s.ChapterId WHERE ch.CourseId = c.CourseId) " +
                    "FROM Course c WHERE c.CourseId = @CourseId AND c.TeacherId = @TeacherId", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read()) { chapters = reader.GetInt32(0); tests = reader.GetInt32(1); }
                    }
                }

                // every attempt on the course's quizzes, assessments and exam, with its result when graded
                using (SqlCommand cmd = new SqlCommand(
                    "WITH CA AS (" +
                    "SELECT ch.CourseId, a.AttemptId, a.LearnerId, a.AttemptDate, a.AttemptStatus, 'quiz' AS Kind, a.QuizId AS TestId " +
                    "FROM Attempt a INNER JOIN Quiz z ON z.QuizId = a.QuizId INNER JOIN Chapter ch ON ch.ChapterId = z.ChapterId " +
                    "UNION ALL " +
                    "SELECT ch.CourseId, a.AttemptId, a.LearnerId, a.AttemptDate, a.AttemptStatus, 'assessment', a.AssessmentId " +
                    "FROM Attempt a INNER JOIN Assessment s ON s.AssessmentId = a.AssessmentId INNER JOIN Chapter ch ON ch.ChapterId = s.ChapterId " +
                    "UNION ALL " +
                    "SELECT ex.CourseId, a.AttemptId, a.LearnerId, a.AttemptDate, a.AttemptStatus, 'exam', a.ExamId " +
                    "FROM Attempt a INNER JOIN Exam ex ON ex.ExamId = a.ExamId) " +
                    "SELECT ca.LearnerId, ca.Kind, ca.TestId, ca.AttemptDate, ca.AttemptStatus, r.Average, r.Grade " +
                    "FROM CA ca INNER JOIN Course c ON c.CourseId = ca.CourseId LEFT JOIN Result r ON r.AttemptId = ca.AttemptId " +
                    "WHERE ca.CourseId = @CourseId AND c.TeacherId = @TeacherId ORDER BY ca.AttemptDate", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int learnerId = reader.GetInt32(0);
                            List<AttemptRow> list;
                            if (!attempts.TryGetValue(learnerId, out list)) { list = new List<AttemptRow>(); attempts[learnerId] = list; }
                            list.Add(new AttemptRow
                            {
                                Kind = reader.GetString(1),
                                TestId = reader.GetInt32(2),
                                Date = reader.GetDateTime(3),
                                Status = reader.GetString(4),
                                Average = reader.IsDBNull(5) ? (double?)null : reader.GetDouble(5),
                                Grade = reader.IsDBNull(6) ? null : reader.GetString(6)
                            });
                        }
                    }
                }

                using (SqlCommand cmd = new SqlCommand(
                    "SELECT cf.LearnerId, MAX(cf.IssueDate) FROM Certificate cf INNER JOIN Course c ON c.CourseId = cf.CourseId " +
                    "WHERE cf.CourseId = @CourseId AND c.TeacherId = @TeacherId GROUP BY cf.LearnerId", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read()) certificates[reader.GetInt32(0)] = reader.GetDateTime(1);
                    }
                }
            }

            for (int i = 0; i < learners.Count; i++)
            {
                TeacherLearner learner = learners[i];
                List<AttemptRow> mine;
                if (!attempts.TryGetValue(learner.Id, out mine)) mine = new List<AttemptRow>();
                DateTime certificate;
                bool hasCertificate = certificates.TryGetValue(learner.Id, out certificate);

                int? chapNum = chapNums[i];
                learner.Chapter = chapNum.HasValue && chapters > 0 ? "Chapter " + chapNum.Value + " of " + chapters : "-";
                learner.Progress = hasCertificate ? 100
                    : chapNum.HasValue && chapters > 0 ? Math.Max(0, Math.Min(100, (int)Math.Round(chapNum.Value * 100.0 / chapters))) : 0;

                int testsDone = mine.Where(a => a.Kind != "exam" && a.Status == "completed").Select(a => a.Kind + a.TestId).Distinct().Count();
                learner.Quizzes = tests > 0 ? testsDone + " of " + tests : "-";

                AttemptRow exam = mine.Where(a => a.Kind == "exam" && a.Status == "completed").OrderByDescending(a => a.Date).FirstOrDefault();
                learner.ExamDate = exam == null ? "-" : DateText(exam.Date);

                AttemptRow graded = mine.Where(a => a.Kind == "exam" && a.Average.HasValue).OrderByDescending(a => a.Date).FirstOrDefault();
                learner.Score = graded == null ? "-" : PercentText(graded.Average.Value);
                learner.Grade = graded == null || graded.Grade == null ? "-" : graded.Grade;

                List<double> results = mine.Where(a => a.Average.HasValue).Select(a => a.Average.Value).ToList();
                learner.Average = results.Count == 0 ? "-" : PercentText(results.Average());

                learner.Enrolled = DateText(enrolled[i]);
                learner.Accessed = mine.Count == 0 ? "-" : DateText(mine.Max(a => a.Date));
                learner.Completed = hasCertificate ? DateText(certificate) : "-";
            }
            return learners;
        }

        /// <summary>
        /// Removes a learner from one of the signed-in teacher's courses: deletes the learner's LearnerProgress row for that course, joined to
        /// Course so that only a course with Course.TeacherId = the teacher can lose a learner. Only the enrolment goes; the learner's attempts,
        /// results, certificates and forum posts are kept. True when exactly one enrolment was removed; false (nothing deleted) for a course
        /// that is not the teacher's or a learner who is not enrolled in it.
        /// </summary>
        public static bool RemoveLearner(int courseId, int learnerId)
        {
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                "DELETE lp FROM LearnerProgress lp INNER JOIN Course c ON c.CourseId = lp.CourseId " +
                "WHERE lp.LearnerId = @LearnerId AND lp.CourseId = @CourseId AND c.TeacherId = @TeacherId", con))
            {
                cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                cmd.Parameters.AddWithValue("@CourseId", courseId);
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                con.Open();
                return cmd.ExecuteNonQuery() == 1;
            }
        }

        private static string DateText(DateTime date)
        {
            return date.ToString("d MMMM yyyy", CultureInfo.InvariantCulture);
        }

        private static string PercentText(double percent)
        {
            return percent.ToString("0.#", CultureInfo.InvariantCulture) + "%";
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
