using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;

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
