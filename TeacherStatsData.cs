using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;

namespace Codercept
{
    /// <summary>The engagement figures of one course (what the "Course Statistics" cards show).</summary>
    public class TeacherCourseFigures
    {
        public int CourseId { get; set; }
        public string CourseTitle { get; set; }
        public int Chapters { get; set; }
        public int Subchapters { get; set; }
        /// <summary>Quizzes and assessments of the course's chapters.</summary>
        public int Tests { get; set; }
        /// <summary>Learners enrolled in the course.</summary>
        public int Attended { get; set; }
        /// <summary>Enrolled learners who hold a certificate for the course.</summary>
        public int Completed { get; set; }
        /// <summary>Completed out of attended, as a whole percentage (0 when nobody is enrolled).</summary>
        public int CompletionRate { get; set; }
        /// <summary>Average time from enrolment to certificate, in days; null when nobody has completed the course.</summary>
        public double? AverageCompletionDays { get; set; }

        /// <summary>"12.5 days", or "5.3 hours" when under a day, or "-" when nobody has completed the course.</summary>
        public string AverageCompletionText
        {
            get
            {
                if (!AverageCompletionDays.HasValue) return "-";
                double days = AverageCompletionDays.Value;
                return days >= 1
                    ? days.ToString("0.0", CultureInfo.InvariantCulture) + " days"
                    : (days * 24).ToString("0.0", CultureInfo.InvariantCulture) + " hours";
            }
        }
    }

    /// <summary>The graded results of one course (what the "Performance Statistics" card shows).</summary>
    public class TeacherPerformance
    {
        /// <summary>How many graded results the figures are based on.</summary>
        public int Graded { get; set; }
        /// <summary>Average, Median, Minimum, Maximum and Std. deviation of the result percentages ("-" when there is nothing to show).</summary>
        public List<TeacherDetailItem> Metrics { get; set; }
        /// <summary>One entry per grade letter: how many learners hold it, and a bar height (0-100, the largest count is 100).</summary>
        public List<TeacherGrade> GradeCounts { get; set; }
    }

    /// <summary>
    /// Database queries for the teacher's statistics. Every query is joined to Course and filtered on Course.TeacherId = @TeacherId, so a
    /// forged CourseId of another teacher finds nothing. A learner "completed" a course when they are still enrolled and hold a certificate for it.
    /// </summary>
    public static class TeacherStatsData
    {
        /// <summary>
        /// The figures of one of the signed-in teacher's courses, or null when the course is not theirs. Completion time is counted from the
        /// learner's EnrolledDate to their certificate date (a negative gap, from odd data, counts as 0).
        /// </summary>
        public static TeacherCourseFigures GetCourseFigures(int courseId)
        {
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                "SELECT c.CourseTitle, " +
                "(SELECT COUNT(*) FROM Chapter ch WHERE ch.CourseId = c.CourseId), " +
                "(SELECT COUNT(*) FROM SubChapter sc INNER JOIN Chapter ch ON ch.ChapterId = sc.ChapterId WHERE ch.CourseId = c.CourseId), " +
                "(SELECT COUNT(*) FROM Quiz z INNER JOIN Chapter ch ON ch.ChapterId = z.ChapterId WHERE ch.CourseId = c.CourseId) + " +
                "(SELECT COUNT(*) FROM Assessment s INNER JOIN Chapter ch ON ch.ChapterId = s.ChapterId WHERE ch.CourseId = c.CourseId), " +
                "(SELECT COUNT(*) FROM LearnerProgress lp WHERE lp.CourseId = c.CourseId), " +
                "(SELECT COUNT(*) FROM LearnerProgress lp WHERE lp.CourseId = c.CourseId AND EXISTS " +
                "   (SELECT 1 FROM Certificate cf WHERE cf.LearnerId = lp.LearnerId AND cf.CourseId = lp.CourseId)), " +
                "(SELECT AVG(CAST(CASE WHEN DATEDIFF(MINUTE, x.EnrolledDate, x.Issued) < 0 THEN 0 ELSE DATEDIFF(MINUTE, x.EnrolledDate, x.Issued) END AS FLOAT)) / 1440.0 " +
                "   FROM (SELECT lp.EnrolledDate, (SELECT MAX(cf.IssueDate) FROM Certificate cf WHERE cf.LearnerId = lp.LearnerId AND cf.CourseId = lp.CourseId) AS Issued " +
                "         FROM LearnerProgress lp WHERE lp.CourseId = c.CourseId) x WHERE x.Issued IS NOT NULL) " +
                "FROM Course c WHERE c.CourseId = @CourseId AND c.TeacherId = @TeacherId", con))
            {
                cmd.Parameters.AddWithValue("@CourseId", courseId);
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (!reader.Read()) return null;
                    int attended = reader.GetInt32(4);
                    int completed = reader.GetInt32(5);
                    return new TeacherCourseFigures
                    {
                        CourseId = courseId,
                        CourseTitle = reader.GetString(0),
                        Chapters = reader.GetInt32(1),
                        Subchapters = reader.GetInt32(2),
                        Tests = reader.GetInt32(3),
                        Attended = attended,
                        Completed = completed,
                        CompletionRate = attended == 0 ? 0 : (int)Math.Round(completed * 100.0 / attended),
                        AverageCompletionDays = reader.IsDBNull(6) ? (double?)null : reader.GetDouble(6)
                    };
                }
            }
        }

        /// <summary>
        /// The performance figures of one of the signed-in teacher's courses. The metrics cover every graded result (exam, quizzes and
        /// assessments) of learners still enrolled, as percentages; the standard deviation is the sample one and needs two results.
        /// The grade distribution counts each enrolled learner once, by the grade of their latest graded exam. Nothing graded gives "-" and zeros.
        /// </summary>
        public static TeacherPerformance GetPerformance(int courseId)
        {
            int teacherId = TeacherDb.GetTeacherId();
            List<double> percents = new List<double>();
            Dictionary<int, string> examGrade = new Dictionary<int, string>(); // learner -> grade of their latest graded exam

            const string attempts =
                "SELECT a.AttemptId, a.LearnerId, 1 AS IsExam FROM Attempt a INNER JOIN Exam t ON t.ExamId = a.ExamId " +
                "INNER JOIN Course c ON c.CourseId = t.CourseId WHERE c.CourseId = @CourseId AND c.TeacherId = @TeacherId " +
                "UNION ALL " +
                "SELECT a.AttemptId, a.LearnerId, 0 FROM Attempt a INNER JOIN Quiz t ON t.QuizId = a.QuizId " +
                "INNER JOIN Chapter ch ON ch.ChapterId = t.ChapterId INNER JOIN Course c ON c.CourseId = ch.CourseId " +
                "WHERE c.CourseId = @CourseId AND c.TeacherId = @TeacherId " +
                "UNION ALL " +
                "SELECT a.AttemptId, a.LearnerId, 0 FROM Attempt a INNER JOIN Assessment t ON t.AssessmentId = a.AssessmentId " +
                "INNER JOIN Chapter ch ON ch.ChapterId = t.ChapterId INNER JOIN Course c ON c.CourseId = ch.CourseId " +
                "WHERE c.CourseId = @CourseId AND c.TeacherId = @TeacherId";

            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                "WITH A AS (" + attempts + ") " +
                "SELECT r.Average, r.Grade, A.LearnerId, A.IsExam FROM A INNER JOIN Result r ON r.AttemptId = A.AttemptId " +
                "WHERE EXISTS (SELECT 1 FROM LearnerProgress lp WHERE lp.LearnerId = A.LearnerId AND lp.CourseId = @CourseId) " +
                "ORDER BY r.ResultId", con))
            {
                cmd.Parameters.AddWithValue("@CourseId", courseId);
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        percents.Add(reader.GetDouble(0));
                        if (reader.GetInt32(3) == 1) examGrade[reader.GetInt32(2)] = reader.GetString(1).Trim().ToUpperInvariant(); // later rows win
                    }
                }
            }

            string[] letters = TeacherGradingData.Grades;
            int[] counts = new int[letters.Length];
            foreach (string grade in examGrade.Values)
            {
                int at = Array.IndexOf(letters, grade);
                if (at >= 0) counts[at]++;
            }
            int largest = counts.Max();

            List<TeacherGrade> bars = new List<TeacherGrade>();
            for (int i = 0; i < letters.Length; i++)
            {
                bars.Add(new TeacherGrade { Grade = letters[i], Count = counts[i], Value = largest == 0 ? 0 : (int)Math.Round(counts[i] * 100.0 / largest) });
            }

            string average = "-", median = "-", min = "-", max = "-", deviation = "-";
            if (percents.Count > 0)
            {
                percents.Sort();
                double mean = percents.Average();
                int mid = percents.Count / 2;
                average = Number(mean);
                median = Number(percents.Count % 2 == 1 ? percents[mid] : (percents[mid - 1] + percents[mid]) / 2);
                min = Number(percents[0]);
                max = Number(percents[percents.Count - 1]);
                if (percents.Count > 1) deviation = Number(Math.Sqrt(percents.Sum(p => (p - mean) * (p - mean)) / (percents.Count - 1)));
            }

            return new TeacherPerformance
            {
                Graded = percents.Count,
                GradeCounts = bars,
                Metrics = new List<TeacherDetailItem>
                {
                    new TeacherDetailItem { Label = "Average", Value = average },
                    new TeacherDetailItem { Label = "Median", Value = median },
                    new TeacherDetailItem { Label = "Minimum", Value = min },
                    new TeacherDetailItem { Label = "Maximum", Value = max },
                    new TeacherDetailItem { Label = "Std. deviation", Value = deviation }
                }
            };
        }

        private static string Number(double value)
        {
            return value.ToString("0.0", CultureInfo.InvariantCulture);
        }

        /// <summary>The six rows of the "Course Statistics" card, in display order.</summary>
        public static List<TeacherDetailItem> CourseRows(TeacherCourseFigures figures)
        {
            return new List<TeacherDetailItem>
            {
                new TeacherDetailItem { Icon = "layers", Label = "Total chapters", Value = figures.Chapters.ToString(CultureInfo.InvariantCulture) },
                new TeacherDetailItem { Icon = "chapters", Label = "Subchapters", Value = figures.Subchapters.ToString(CultureInfo.InvariantCulture) },
                new TeacherDetailItem { Icon = "question", Label = "Quizzes & assessments", Value = figures.Tests.ToString(CultureInfo.InvariantCulture) },
                new TeacherDetailItem { Icon = "users", Label = "Learners attended", Value = figures.Attended.ToString(CultureInfo.InvariantCulture) },
                new TeacherDetailItem { Icon = "award", Label = "Learners completed", Value = figures.Completed.ToString(CultureInfo.InvariantCulture) },
                new TeacherDetailItem { Icon = "clock", Label = "Average completion time", Value = figures.AverageCompletionText }
            };
        }
    }
}
