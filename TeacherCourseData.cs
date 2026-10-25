using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;

namespace Codercept
{
    /// <summary>What happened when a teacher asked to delete a course.</summary>
    public enum CourseDeleteResult
    {
        Deleted,
        /// <summary>No such course for this teacher (it is not revealed whether it belongs to someone else).</summary>
        NotFound,
        /// <summary>Learners are enrolled, or have attempts, certificates or reviews: their records are kept, so the course stays.</summary>
        HasLearnerData
    }

    /// <summary>
    /// Database queries for the signed-in teacher's courses. Every query on teacher data filters on
    /// TeacherId = @TeacherId, so a teacher can never read another teacher's course even with a forged id.
    /// A course's language is the CourseSubject -> Subject row whose SubjectType is 'Language'
    /// (the other subjects, such as Machine Learning, are domains).
    /// </summary>
    public static class TeacherCourseData
    {
        /// <summary>Shown when a course has no language subject.</summary>
        public const string OtherLanguage = "Other";

        private const string CourseSelect =
            "SELECT c.CourseId, c.CourseTitle, c.CourseDescription, c.DifficultyLevel, c.CourseDuration, " +
            "       c.DateCreation, c.DateUpdate, " +
            "       ISNULL((SELECT TOP 1 s.SubjectName FROM CourseSubject cs " +
            "               INNER JOIN Subject s ON s.SubjectId = cs.SubjectId " +
            "               WHERE cs.CourseId = c.CourseId AND s.SubjectType = 'Language' " +
            "               ORDER BY s.SubjectId), @Other) AS Language, " +
            "       (SELECT COUNT(*) FROM LearnerProgress lp WHERE lp.CourseId = c.CourseId) AS LearnerCount " +
            "FROM Course c " +
            "WHERE c.TeacherId = @TeacherId";

        /// <summary>The signed-in teacher's courses, newest first.</summary>
        public static List<TeacherCourse> GetCourses()
        {
            List<TeacherCourse> list = new List<TeacherCourse>();
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand(CourseSelect + " ORDER BY c.DateCreation DESC, c.CourseId DESC", con))
                {
                    cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                    cmd.Parameters.AddWithValue("@Other", OtherLanguage);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read()) list.Add(ReadCourse(reader));
                    }
                }

                // the domains (Subject rows of type 'Domain') of those courses, in one query
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT cs.CourseId, s.SubjectName FROM CourseSubject cs " +
                    "INNER JOIN Subject s ON s.SubjectId = cs.SubjectId " +
                    "INNER JOIN Course c ON c.CourseId = cs.CourseId " +
                    "WHERE c.TeacherId = @TeacherId AND s.SubjectType = 'Domain' ORDER BY s.SubjectName", con))
                {
                    cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int courseId = reader.GetInt32(0);
                            TeacherCourse course = list.FirstOrDefault(c => c.Id == courseId);
                            if (course != null) course.Domains.Add(reader.GetString(1));
                        }
                    }
                }
            }
            return list;
        }

        /// <summary>The course with this CourseId if it belongs to the signed-in teacher, otherwise null.</summary>
        public static TeacherCourse GetCourse(int courseId)
        {
            return GetCourses().FirstOrDefault(c => c.Id == courseId);
        }

        /// <summary>
        /// How many chapters, subchapters and quizzes + assessments the course has. Joined to Course so that only the
        /// signed-in teacher's own course is counted; any other CourseId gives zeros.
        /// </summary>
        public static void GetStructureCounts(int courseId, out int chapters, out int subchapters, out int tests)
        {
            chapters = 0; subchapters = 0; tests = 0;
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT (SELECT COUNT(*) FROM Chapter ch WHERE ch.CourseId = c.CourseId), " +
                    "       (SELECT COUNT(*) FROM SubChapter sc INNER JOIN Chapter ch ON ch.ChapterId = sc.ChapterId WHERE ch.CourseId = c.CourseId), " +
                    "       (SELECT COUNT(*) FROM Quiz q INNER JOIN Chapter ch ON ch.ChapterId = q.ChapterId WHERE ch.CourseId = c.CourseId) + " +
                    "       (SELECT COUNT(*) FROM Assessment a INNER JOIN Chapter ch ON ch.ChapterId = a.ChapterId WHERE ch.CourseId = c.CourseId) " +
                    "FROM Course c WHERE c.CourseId = @CourseId AND c.TeacherId = @TeacherId", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    cmd.Parameters.AddWithValue("@TeacherId", TeacherDb.GetTeacherId());
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            chapters = reader.GetInt32(0);
                            subchapters = reader.GetInt32(1);
                            tests = reader.GetInt32(2);
                        }
                    }
                }
            }
        }

        /// <summary>
        /// The course for a ?course= value out of this teacher's courses: the first one when the value is absent,
        /// null when it is present but not one of this teacher's courses (or when the teacher has no courses).
        /// </summary>
        public static TeacherCourse Pick(List<TeacherCourse> courses, string queryValue)
        {
            if (string.IsNullOrEmpty(queryValue)) return courses.FirstOrDefault();
            int id;
            return int.TryParse(queryValue, out id) ? courses.FirstOrDefault(c => c.Id == id) : null;
        }

        /// <summary>
        /// One entry per programming language (name, thumbnail glyph and theme), whether or not a course uses it yet.
        /// This is shared reference data (the Subject table), so it is not filtered by teacher.
        /// </summary>
        public static List<TeacherCourse> GetLanguages()
        {
            List<TeacherCourse> list = new List<TeacherCourse>();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand("SELECT SubjectName FROM Subject WHERE SubjectType = 'Language' ORDER BY SubjectId", con))
            {
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string name = reader.GetString(0);
                        list.Add(new TeacherCourse { Language = name, Glyph = GlyphOf(name), Theme = ThemeOf(name) });
                    }
                }
            }
            return list;
        }

        /// <summary>Every domain name in the Subject table (shared by all teachers), for the suggestions list.</summary>
        public static List<string> GetDomainNames()
        {
            List<string> list = new List<string>();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand("SELECT SubjectName FROM Subject WHERE SubjectType = 'Domain' ORDER BY SubjectName", con))
            {
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read()) list.Add(reader.GetString(0));
                }
            }
            return list;
        }

        public const int MaxDomains = 5;

        private static readonly Regex DomainPattern = new Regex(@"^[A-Za-z0-9][A-Za-z0-9 &+#./-]{0,49}$", RegexOptions.Compiled);

        /// <summary>
        /// Tidies the domain names typed by the teacher (trim, single spaces, no repeats) and checks them.
        /// Returns null and sets error when one is not allowed; the server is the real gate, the page script only helps.
        /// </summary>
        public static List<string> CleanDomains(IEnumerable<string> typed, out string error)
        {
            error = null;
            List<string> clean = new List<string>();
            List<string> languages = GetLanguages().Select(l => l.Language).ToList();
            List<string> known = GetDomainNames();
            foreach (string raw in typed ?? new string[0])
            {
                string name = Regex.Replace((raw ?? "").Trim(), @"\s+", " ");
                if (name.Length == 0) continue;
                if (!DomainPattern.IsMatch(name))
                {
                    error = "\"" + name + "\" is not a valid domain. Use letters, numbers and & + # . / - only (up to 50 characters).";
                    return null;
                }
                if (languages.Any(l => string.Equals(l, name, StringComparison.OrdinalIgnoreCase)))
                {
                    error = name + " is a programming language. Choose it as the language instead.";
                    return null;
                }
                // a domain that already exists keeps its stored spelling ("machine learning" -> "Machine Learning")
                string existing = known.FirstOrDefault(k => string.Equals(k, name, StringComparison.OrdinalIgnoreCase));
                if (existing != null) name = existing;
                if (!clean.Any(d => string.Equals(d, name, StringComparison.OrdinalIgnoreCase))) clean.Add(name);
            }
            if (clean.Count > MaxDomains)
            {
                error = "You can add up to " + MaxDomains + " domains.";
                return null;
            }
            return clean;
        }

        /// <summary>
        /// Adds a course for the signed-in teacher, with its language and domains, in one transaction.
        /// Returns the new CourseId.
        /// </summary>
        public static int CreateCourse(string title, string description, string language, string difficulty, int hours, List<string> domains)
        {
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    int courseId;
                    using (SqlCommand cmd = new SqlCommand(
                        "INSERT INTO Course (DateCreation, DateUpdate, CourseTitle, CourseDescription, DifficultyLevel, CourseDuration, TeacherId) " +
                        "VALUES (GETDATE(), NULL, @Title, @Description, @Difficulty, @Duration, @TeacherId); " +
                        "SELECT CAST(SCOPE_IDENTITY() AS INT)", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@Title", title);
                        cmd.Parameters.AddWithValue("@Description", description);
                        cmd.Parameters.AddWithValue("@Difficulty", difficulty);
                        cmd.Parameters.AddWithValue("@Duration", DurationText(hours));
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        courseId = (int)cmd.ExecuteScalar();
                    }

                    SaveSubjects(con, tx, courseId, language, domains);
                    tx.Commit();
                    return courseId;
                }
            }
        }

        /// <summary>
        /// Saves the edited details of one of the signed-in teacher's courses, with its language and domains, in one
        /// transaction. Returns false (and changes nothing) when the course does not belong to the teacher.
        /// </summary>
        public static bool UpdateCourse(int courseId, string title, string description, string language, string difficulty, int hours, List<string> domains)
        {
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    int changed = Run(con, tx,
                        "UPDATE Course SET CourseTitle = @Title, CourseDescription = @Description, DifficultyLevel = @Difficulty, " +
                        "CourseDuration = @Duration, DateUpdate = GETDATE() WHERE CourseId = @CourseId AND TeacherId = @TeacherId",
                        new SqlParameter("@Title", title), new SqlParameter("@Description", description),
                        new SqlParameter("@Difficulty", difficulty), new SqlParameter("@Duration", DurationText(hours)),
                        new SqlParameter("@CourseId", courseId), new SqlParameter("@TeacherId", teacherId));
                    if (changed == 0) return false; // not this teacher's course: leaving without Commit rolls everything back

                    SaveSubjects(con, tx, courseId, language, domains);
                    tx.Commit();
                    return true;
                }
            }
        }

        // Parts of a course, found from the course down (all use @CourseId)
        private const string CourseChapters = "(SELECT ChapterId FROM Chapter WHERE CourseId = @CourseId)";
        private const string CourseQuizzes = "(SELECT QuizId FROM Quiz WHERE ChapterId IN " + CourseChapters + ")";
        private const string CourseAssessments = "(SELECT AssessmentId FROM Assessment WHERE ChapterId IN " + CourseChapters + ")";
        private const string CourseExams = "(SELECT ExamId FROM Exam WHERE CourseId = @CourseId)";
        private const string CourseQuestionTest =
            "QuizId IN " + CourseQuizzes + " OR AssessmentId IN " + CourseAssessments + " OR ExamId IN " + CourseExams;

        /// <summary>
        /// Deletes one of the signed-in teacher's courses with everything the teacher built under it (chapters, subchapters,
        /// quizzes, assessments, exams, questions and options), in foreign-key order inside one transaction.
        /// A course that learners are enrolled in, or have attempts, certificates or reviews for, is NOT deleted:
        /// their progress and certificates must be kept.
        /// </summary>
        public static CourseDeleteResult DeleteCourse(int courseId)
        {
            int teacherId = TeacherDb.GetTeacherId();
            SqlParameter id() { return new SqlParameter("@CourseId", courseId); }

            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    int owned;
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Course WHERE CourseId = @CourseId AND TeacherId = @TeacherId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@CourseId", courseId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        owned = (int)cmd.ExecuteScalar();
                    }
                    if (owned == 0) return CourseDeleteResult.NotFound;

                    int learnerData;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT CASE WHEN EXISTS (SELECT 1 FROM LearnerProgress WHERE CourseId = @CourseId) " +
                        "OR EXISTS (SELECT 1 FROM [Certificate] WHERE CourseId = @CourseId) " +
                        "OR EXISTS (SELECT 1 FROM Course_Review WHERE CourseId = @CourseId) " +
                        "OR EXISTS (SELECT 1 FROM Attempt WHERE QuizId IN " + CourseQuizzes + " OR AssessmentId IN " + CourseAssessments + " OR ExamId IN " + CourseExams + ") " +
                        "THEN 1 ELSE 0 END", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@CourseId", courseId);
                        learnerData = (int)cmd.ExecuteScalar();
                    }
                    if (learnerData == 1) return CourseDeleteResult.HasLearnerData;

                    Run(con, tx, "DELETE FROM MCQ_Option WHERE QuestionId IN (SELECT QuestionId FROM Question WHERE " + CourseQuestionTest + ")", id());
                    Run(con, tx, "DELETE FROM Question WHERE " + CourseQuestionTest, id());
                    Run(con, tx, "DELETE FROM Quiz WHERE ChapterId IN " + CourseChapters, id());
                    Run(con, tx, "DELETE FROM Assessment WHERE ChapterId IN " + CourseChapters, id());
                    Run(con, tx, "DELETE FROM Exam WHERE CourseId = @CourseId", id());
                    Run(con, tx, "DELETE FROM SubChapter WHERE ChapterId IN " + CourseChapters, id());
                    Run(con, tx, "DELETE FROM Chapter WHERE CourseId = @CourseId", id());
                    Run(con, tx, "DELETE FROM CourseSubject WHERE CourseId = @CourseId", id());
                    Run(con, tx, "DELETE FROM Course WHERE CourseId = @CourseId AND TeacherId = @TeacherId", id(), new SqlParameter("@TeacherId", teacherId));
                    tx.Commit();
                    return CourseDeleteResult.Deleted;
                }
            }
        }

        /// <summary>
        /// Every attempt on a quiz, assessment or exam of a course, as one list (a WITH clause to put in front of a SELECT):
        /// quiz -> chapter -> course, assessment -> chapter -> course, exam -> course.
        /// </summary>
        internal const string CourseAttemptsCte =
            "WITH CourseAttempt AS ( " +
            "SELECT ch.CourseId, a.AttemptId, a.LearnerId, a.AttemptDate, a.AttemptStatus, qz.QuizTitle AS Title " +
            "FROM Attempt a INNER JOIN Quiz qz ON qz.QuizId = a.QuizId " +
            "INNER JOIN Chapter ch ON ch.ChapterId = qz.ChapterId " +
            "UNION ALL " +
            "SELECT ch.CourseId, a.AttemptId, a.LearnerId, a.AttemptDate, a.AttemptStatus, asm.AssessmentTitle " +
            "FROM Attempt a INNER JOIN Assessment asm ON asm.AssessmentId = a.AssessmentId " +
            "INNER JOIN Chapter ch ON ch.ChapterId = asm.ChapterId " +
            "UNION ALL " +
            "SELECT ex.CourseId, a.AttemptId, a.LearnerId, a.AttemptDate, a.AttemptStatus, ex.ExamTitle " +
            "FROM Attempt a INNER JOIN Exam ex ON ex.ExamId = a.ExamId) ";

        /// <summary>The CourseIds (of the signed-in teacher's courses) that have their final exam.</summary>
        public static HashSet<int> GetCourseIdsWithExam()
        {
            HashSet<int> ids = new HashSet<int>();
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                "SELECT e.CourseId FROM Exam e INNER JOIN Course c ON c.CourseId = e.CourseId WHERE c.TeacherId = @TeacherId", con))
            {
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read()) ids.Add(reader.GetInt32(0));
                }
            }
            return ids;
        }

        /// <summary>
        /// Submissions waiting for the teacher, per CourseId: attempts the learner has completed that have no Result yet.
        /// Courses with none are not in the dictionary.
        /// </summary>
        public static Dictionary<int, int> GetPendingCounts()
        {
            Dictionary<int, int> counts = new Dictionary<int, int>();
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                CourseAttemptsCte +
                "SELECT ca.CourseId, COUNT(*) FROM CourseAttempt ca INNER JOIN Course c ON c.CourseId = ca.CourseId " +
                "WHERE c.TeacherId = @TeacherId AND ca.AttemptStatus = 'completed' " +
                "AND NOT EXISTS (SELECT 1 FROM Result r WHERE r.AttemptId = ca.AttemptId) GROUP BY ca.CourseId", con))
            {
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read()) counts[reader.GetInt32(0)] = reader.GetInt32(1);
                }
            }
            return counts;
        }

        /// <summary>Replaces the language and domain rows of a course. The caller has already checked ownership.</summary>
        private static void SaveSubjects(SqlConnection con, SqlTransaction tx, int courseId, string language, List<string> domains)
        {
            Run(con, tx, "DELETE FROM CourseSubject WHERE CourseId = @CourseId", new SqlParameter("@CourseId", courseId));

            int linked = Run(con, tx,
                "INSERT INTO CourseSubject (CourseId, SubjectId) SELECT @CourseId, SubjectId FROM Subject WHERE SubjectName = @Name AND SubjectType = 'Language'",
                new SqlParameter("@CourseId", courseId), new SqlParameter("@Name", language));
            if (linked == 0) throw new InvalidOperationException("Unknown programming language: " + language);

            foreach (string domain in domains)
            {
                // a domain nobody used before becomes a new Subject row; an existing one is just linked
                Run(con, tx,
                    "IF NOT EXISTS (SELECT 1 FROM Subject WHERE SubjectName = @Name) INSERT INTO Subject (SubjectName, SubjectType) VALUES (@Name, 'Domain'); " +
                    "INSERT INTO CourseSubject (CourseId, SubjectId) SELECT @CourseId, SubjectId FROM Subject WHERE SubjectName = @Name AND SubjectType = 'Domain'",
                    new SqlParameter("@CourseId", courseId), new SqlParameter("@Name", domain));
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

        /// <summary>Course.CourseDuration is text, stored the way the seed data writes it ("18 hours").</summary>
        private static string DurationText(int hours)
        {
            return hours + (hours == 1 ? " hour" : " hours");
        }

        private static TeacherCourse ReadCourse(SqlDataReader reader)
        {
            DateTime created = reader.GetDateTime(reader.GetOrdinal("DateCreation"));
            int updatedAt = reader.GetOrdinal("DateUpdate");
            DateTime updated = reader.IsDBNull(updatedAt) ? created : reader.GetDateTime(updatedAt);
            string language = reader.GetString(reader.GetOrdinal("Language"));
            int learners = reader.GetInt32(reader.GetOrdinal("LearnerCount"));

            return new TeacherCourse
            {
                Id = reader.GetInt32(reader.GetOrdinal("CourseId")),
                Title = reader.GetString(reader.GetOrdinal("CourseTitle")),
                Description = reader.GetString(reader.GetOrdinal("CourseDescription")),
                Difficulty = reader.GetString(reader.GetOrdinal("DifficultyLevel")),
                Duration = HoursOf(reader.GetString(reader.GetOrdinal("CourseDuration"))),
                Language = language,
                Glyph = GlyphOf(language),
                Theme = ThemeOf(language),
                Date = FormatDate(created),
                Updated = FormatDate(updated),
                Learners = learners + (learners == 1 ? " learner" : " learners")
            };
        }

        /// <summary>Course.CourseDuration is text such as "18 hours"; the pages work with whole hours.</summary>
        private static int HoursOf(string duration)
        {
            string digits = new string((duration ?? "").TrimStart().TakeWhile(ch => char.IsDigit(ch) || ch == '.').ToArray());
            decimal hours;
            return decimal.TryParse(digits, NumberStyles.Number, CultureInfo.InvariantCulture, out hours) ? (int)Math.Round(hours) : 0;
        }

        private static string FormatDate(DateTime value)
        {
            return value.ToString("d MMMM yyyy", CultureInfo.InvariantCulture);
        }

        // Thumbnail text and colour theme (css/teacher-portal.css: .course-thumbnail--<theme>) for each language
        private static string GlyphOf(string language)
        {
            switch (language)
            {
                case "Python": return "py";
                case "Java": return "Java";
                case "C++": return "C++";
                case "C": return "C";
                default: return "?";
            }
        }

        private static string ThemeOf(string language)
        {
            switch (language)
            {
                case "Python": return "python";
                case "Java": return "java";
                case "C++": return "cpp";
                case "C": return "c";
                default: return "other";
            }
        }
    }
}
