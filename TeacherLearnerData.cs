using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;

namespace Codercept
{
    /// <summary>Everything one learner's course report shows.</summary>
    public class TeacherLearnerReportData
    {
        public int CourseId { get; set; }
        public string CourseTitle { get; set; }
        public TeacherLearner Learner { get; set; }
        /// <summary>The graded results of the course, in the order they happened ("Quiz · Variables Quiz", "2 / 2", "A").</summary>
        public List<TeacherReportScore> Scores { get; set; }
        /// <summary>Each graded result as a percentage, in the same order (for the bar chart).</summary>
        public List<int> Percents { get; set; }
    }

    /// <summary>What happened when a teacher added a learner to a course.</summary>
    public enum AddLearnerResult
    {
        Added,
        /// <summary>The text is not an email address (or is longer than Learner.Email allows).</summary>
        InvalidEmail,
        /// <summary>No learner account with that email is active. Not revealed: whether it exists but is not active.</summary>
        NotFound,
        AlreadyEnrolled,
        /// <summary>The course is not one of the signed-in teacher's.</summary>
        CourseNotFound
    }

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

        /// <summary>
        /// The report of one learner in one course: null unless the learner is enrolled in a course of the signed-in teacher (the learner, the
        /// course title and the graded results are all read through Course.TeacherId, so a forged id finds nothing).
        /// </summary>
        public static TeacherLearnerReportData GetReport(int courseId, int learnerId)
        {
            TeacherLearner learner = GetLearners(courseId).FirstOrDefault(l => l.Id == learnerId);
            if (learner == null) return null;

            int teacherId = TeacherDb.GetTeacherId();
            TeacherLearnerReportData report = new TeacherLearnerReportData
            {
                CourseId = courseId,
                Learner = learner,
                Scores = new List<TeacherReportScore>(),
                Percents = new List<int>()
            };

            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand("SELECT CourseTitle FROM Course WHERE CourseId = @CourseId AND TeacherId = @TeacherId", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                    object title = cmd.ExecuteScalar();
                    if (title == null) return null;
                    report.CourseTitle = (string)title;
                }

                using (SqlCommand cmd = new SqlCommand(
                    "WITH CA AS (" +
                    "SELECT ch.CourseId, a.AttemptId, a.LearnerId, a.AttemptDate, 'Quiz' AS Kind, z.QuizTitle AS Title, " +
                    "(SELECT ISNULL(SUM(q.QuestionScore), 0) FROM Question q WHERE q.QuizId = z.QuizId) AS MaxMarks " +
                    "FROM Attempt a INNER JOIN Quiz z ON z.QuizId = a.QuizId INNER JOIN Chapter ch ON ch.ChapterId = z.ChapterId " +
                    "UNION ALL " +
                    "SELECT ch.CourseId, a.AttemptId, a.LearnerId, a.AttemptDate, 'Assessment', s.AssessmentTitle, " +
                    "(SELECT ISNULL(SUM(q.QuestionScore), 0) FROM Question q WHERE q.AssessmentId = s.AssessmentId) " +
                    "FROM Attempt a INNER JOIN Assessment s ON s.AssessmentId = a.AssessmentId INNER JOIN Chapter ch ON ch.ChapterId = s.ChapterId " +
                    "UNION ALL " +
                    "SELECT ex.CourseId, a.AttemptId, a.LearnerId, a.AttemptDate, 'Exam', ex.ExamTitle, " +
                    "(SELECT ISNULL(SUM(q.QuestionScore), 0) FROM Question q WHERE q.ExamId = ex.ExamId) " +
                    "FROM Attempt a INNER JOIN Exam ex ON ex.ExamId = a.ExamId) " +
                    "SELECT ca.Kind, ca.Title, r.TotalScore, ca.MaxMarks, r.Average, r.Grade " +
                    "FROM CA ca INNER JOIN Course c ON c.CourseId = ca.CourseId INNER JOIN Result r ON r.AttemptId = ca.AttemptId " +
                    "WHERE ca.CourseId = @CourseId AND ca.LearnerId = @LearnerId AND c.TeacherId = @TeacherId " +
                    "ORDER BY ca.AttemptDate, ca.AttemptId", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            report.Scores.Add(new TeacherReportScore
                            {
                                Item = reader.GetString(0) + " \u00b7 " + reader.GetString(1),
                                Score = reader.GetDouble(2).ToString("0.##", CultureInfo.InvariantCulture) + " / " + reader.GetDouble(3).ToString("0.##", CultureInfo.InvariantCulture),
                                Grade = reader.GetString(5)
                            });
                            report.Percents.Add((int)Math.Max(0, Math.Min(100, Math.Round(reader.GetDouble(4)))));
                        }
                    }
                }
            }
            return report;
        }

        /// <summary>The longest email Learner.Email can hold.</summary>
        public const int MaxEmailLength = 50;

        /// <summary>True for "name@host.tld" style text no longer than MaxEmailLength.</summary>
        public static bool LooksLikeEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email) || email.Length > MaxEmailLength) return false;
            try
            {
                System.Net.Mail.MailAddress address = new System.Net.Mail.MailAddress(email);
                return address.Address == email && email.Contains(".") && email.IndexOf('@') > 0;
            }
            catch (FormatException)
            {
                return false;
            }
        }

        /// <summary>
        /// Enrols the learner whose account has this email in one of the signed-in teacher's courses (a LearnerProgress row, EnrolledDate now,
        /// starting at the first chapter when the course has chapters). In one transaction it checks that the course is the teacher's, that an
        /// active learner account has the email and that the learner is not enrolled yet (locked, so two requests at once cannot both enrol
        /// them); anything else adds nothing. learnerId and name say who was added.
        /// </summary>
        public static AddLearnerResult AddLearner(int courseId, string email, out int learnerId, out string name)
        {
            learnerId = 0; name = "";
            email = (email ?? "").Trim();
            if (!LooksLikeEmail(email)) return AddLearnerResult.InvalidEmail;

            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Course WHERE CourseId = @CourseId AND TeacherId = @TeacherId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@CourseId", courseId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        if ((int)cmd.ExecuteScalar() == 0) return AddLearnerResult.CourseNotFound;
                    }

                    using (SqlCommand cmd = new SqlCommand("SELECT LearnerId, Name FROM Learner WHERE Email = @Email AND AccStatus = 'Active'", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@Email", email);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (!reader.Read()) return AddLearnerResult.NotFound;
                            learnerId = reader.GetInt32(0);
                            name = reader.GetString(1);
                        }
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM LearnerProgress WITH (UPDLOCK, HOLDLOCK) WHERE LearnerId = @LearnerId AND CourseId = @CourseId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                        cmd.Parameters.AddWithValue("@CourseId", courseId);
                        if ((int)cmd.ExecuteScalar() > 0) return AddLearnerResult.AlreadyEnrolled;
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        "INSERT INTO LearnerProgress (LearnerId, CourseId, ChapNum, EnrolledDate) " +
                        "VALUES (@LearnerId, @CourseId, CASE WHEN EXISTS (SELECT 1 FROM Chapter WHERE CourseId = @CourseId) THEN 1 ELSE NULL END, GETDATE())", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                        cmd.Parameters.AddWithValue("@CourseId", courseId);
                        cmd.ExecuteNonQuery();
                    }

                    tx.Commit();
                    return AddLearnerResult.Added;
                }
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
