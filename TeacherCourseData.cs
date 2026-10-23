using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;

namespace Codercept
{
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
