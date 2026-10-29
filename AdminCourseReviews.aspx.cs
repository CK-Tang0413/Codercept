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
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["Codercept_db"]?.ConnectionString 
            ?? ConfigurationManager.ConnectionStrings["CoderceptDB"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int courseId = 0;
                if (Request.QueryString["courseId"] != null && int.TryParse(Request.QueryString["courseId"], out int id))
                {
                    courseId = id;
                }
                else
                {
                    courseId = GetFirstCourseId();
                }

                if (courseId > 0)
                {
                    LoadCourseDetails(courseId);
                    LoadCourseReviews(courseId);
                }
                else
                {
                    litCourseTitle.Text = "No Courses Available";
                    litCourseDesc.Text = "There are no courses currently in the database.";
                    pnlNoReviews.Visible = true;
                }
            }
        }

        private int GetFirstCourseId()
        {
            if (string.IsNullOrEmpty(connectionString)) return 0;
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("SELECT TOP 1 CourseId FROM [dbo].[Course] ORDER BY CourseId ASC", conn))
                    {
                        object result = cmd.ExecuteScalar();
                        if (result != null && int.TryParse(result.ToString(), out int id))
                        {
                            return id;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminCourseReviews GetFirstCourseId Error]: {ex.Message}");
            }
            return 0;
        }

        private void LoadCourseDetails(int courseId)
        {
            if (string.IsNullOrEmpty(connectionString))
            {
                litCourseTitle.Text = "Database Connection Error";
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
                            ISNULL((SELECT TOP 1 s.SubjectName 
                                    FROM [dbo].[CourseSubject] cs 
                                    INNER JOIN [dbo].[Subject] s ON cs.SubjectId = s.SubjectId 
                                    WHERE cs.CourseId = c.CourseId AND s.SubjectType = 'Language' 
                                    ORDER BY s.SubjectId),
                                   ISNULL((SELECT TOP 1 s2.SubjectName 
                                           FROM [dbo].[CourseSubject] cs2 
                                           INNER JOIN [dbo].[Subject] s2 ON cs2.SubjectId = s2.SubjectId 
                                           WHERE cs2.CourseId = c.CourseId 
                                           ORDER BY s2.SubjectId), 'General')) AS Language,
                            ISNULL(t.Name, 'Unassigned') AS TeacherName,
                            ISNULL(enrolled.Count, 0) AS EnrolledCount,
                            ISNULL(rev.AvgRating, 0.0) AS AvgScore,
                            ISNULL(rev.TotalReviews, 0) AS TotalReviews
                        FROM [dbo].[Course] c
                        LEFT JOIN [dbo].[Teacher] t ON c.TeacherId = t.TeacherId
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
                            else
                            {
                                litCourseTitle.Text = "Course Not Found";
                                litCourseDesc.Text = "The specified course could not be located in the database.";
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
                pnlNoReviews.Visible = true;
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
            if (string.IsNullOrWhiteSpace(language)) return "badge-python";
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
