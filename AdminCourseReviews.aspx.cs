using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class AdminCourseReviews : System.Web.UI.Page
    {
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["CoderceptDB"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int courseId = 0;
                if (Request.QueryString["courseId"] != null && int.TryParse(Request.QueryString["courseId"], out int id))
                {
                    courseId = id;
                }

                LoadCourseDetails(courseId);
                LoadCourseReviews(courseId);
            }
        }

        private void LoadCourseDetails(int courseId)
        {
            if (string.IsNullOrEmpty(connectionString))
            {
                // Fallback Mock data
                litCourseTitle.Text = "Python Programming Fundamentals";
                badgeLanguage.InnerText = "Python";
                badgeLanguage.Attributes["class"] = "badge badge-python";
                litCourseDesc.Text = "Build a strong foundation in Python through practical examples, clear explanations, and hands-on programming exercises.";
                litTeacherName.Text = "Bryan Yeong";
                litDifficulty.Text = "Easy";
                litDuration.Text = "18 hours";
                litEnrolledCount.Text = "128";
                litAvgScore.Text = "4.8";
                litTotalReviews.Text = "2";
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = @"
                        SELECT 
                            c.CourseTitle,
                            c.CourseDescription,
                            c.DifficultyLevel,
                            c.CourseDuration,
                            ISNULL(s.SubjectName, 'General') AS Language,
                            ISNULL(t.Name, 'Unassigned') AS TeacherName,
                            ISNULL(enrolled.Count, 0) AS EnrolledCount,
                            ISNULL(rev.AvgRating, 0.0) AS AvgScore,
                            ISNULL(rev.TotalReviews, 0) AS TotalReviews
                        FROM [dbo].[Course] c
                        LEFT JOIN [dbo].[Teacher] t ON c.TeacherId = t.TeacherId
                        LEFT JOIN [dbo].[CourseSubject] cs ON c.CourseId = cs.CourseId
                        LEFT JOIN [dbo].[Subject] s ON cs.SubjectId = s.SubjectId
                        OUTER APPLY (
                            SELECT COUNT(DISTINCT lp.LearnerId) AS Count
                            FROM [dbo].[LearnerProgress] lp
                            WHERE lp.CourseId = c.CourseId
                        ) enrolled
                        OUTER APPLY (
                            SELECT AVG(cr.Rating) AS AvgRating, COUNT(cr.ReviewId) AS TotalReviews
                            FROM [dbo].[Course_Review] cr
                            WHERE cr.CourseId = c.CourseId
                        ) rev
                        WHERE c.CourseId = @CourseId";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CourseId", courseId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                litCourseTitle.Text = reader["CourseTitle"].ToString();
                                litCourseDesc.Text = reader["CourseDescription"].ToString();
                                litDifficulty.Text = reader["DifficultyLevel"].ToString();
                                litDuration.Text = reader["CourseDuration"].ToString();
                                litTeacherName.Text = reader["TeacherName"].ToString();
                                litEnrolledCount.Text = reader["EnrolledCount"].ToString();

                                string lang = reader["Language"].ToString();
                                badgeLanguage.InnerText = lang;
                                badgeLanguage.Attributes["class"] = "badge " + GetLanguageBadgeClass(lang);

                                double avg = reader["AvgScore"] != DBNull.Value ? Convert.ToDouble(reader["AvgScore"]) : 0.0;
                                litAvgScore.Text = avg.ToString("0.0");
                                litTotalReviews.Text = reader["TotalReviews"].ToString();
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminCourseReviews Error]: {ex.Message}");
            }
        }

        private void LoadCourseReviews(int courseId)
        {
            DataTable dt = new DataTable();

            if (string.IsNullOrEmpty(connectionString))
            {
                dt.Columns.Add("LearnerName", typeof(string));
                dt.Columns.Add("Rating", typeof(double));
                dt.Columns.Add("SubmissionDate", typeof(DateTime));
                dt.Columns.Add("CourseFeedBack", typeof(string));

                dt.Rows.Add("Wan Hon Kit", 5.0, DateTime.Now.AddDays(-2), "Exceptional explanation of data structures and loops! Highly recommended for all beginner students.");
                dt.Rows.Add("Kylan Shane Sedrick", 4.5, DateTime.Now.AddDays(-5), "Great exercises and code challenges throughout the chapters. Really helped solidify OOP concepts.");

                rptReviews.DataSource = dt;
                rptReviews.DataBind();
                pnlNoReviews.Visible = false;
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = @"
                        SELECT 
                            cr.ReviewId,
                            cr.Rating,
                            cr.CourseFeedBack,
                            cr.SubmissionDate,
                            ISNULL(l.Name, 'Anonymous Student') AS LearnerName
                        FROM [dbo].[Course_Review] cr
                        LEFT JOIN [dbo].[Learner] l ON cr.LearnerId = l.LearnerId
                        WHERE cr.CourseId = @CourseId
                        ORDER BY cr.SubmissionDate DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CourseId", courseId);
                        using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                        {
                            adapter.Fill(dt);
                        }
                    }
                }

                if (dt.Rows.Count > 0)
                {
                    rptReviews.DataSource = dt;
                    rptReviews.DataBind();
                    pnlNoReviews.Visible = false;
                }
                else
                {
                    rptReviews.DataSource = null;
                    rptReviews.DataBind();
                    pnlNoReviews.Visible = true;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminCourseReviews Reviews Error]: {ex.Message}");
                pnlNoReviews.Visible = true;
            }
        }

        protected string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "U";
            string[] parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Substring(0, Math.Min(2, parts[0].Length)).ToUpper();
            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }

        protected string GetLanguageBadgeClass(string language)
        {
            switch (language.Trim().ToLower())
            {
                case "python": return "badge-python";
                case "java": return "badge-java";
                case "c": return "badge-c";
                case "c++":
                case "cpp": return "badge-cpp";
                default: return "badge-python";
            }
        }
    }
}