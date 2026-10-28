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
    public partial class Admin_Courses : System.Web.UI.Page
    {
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["Codercept_db"]?.ConnectionString 
            ?? ConfigurationManager.ConnectionStrings["CoderceptDB"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCourses();
            }
        }

        private void LoadCourses()
        {
            DataTable dt = new DataTable();

            if (string.IsNullOrEmpty(connectionString))
            {
                pnlNoCourses.Visible = true;
                litCourseSummary.Text = "Database connection not found";
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        SELECT 
                            c.CourseId,
                            c.CourseTitle,
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
                            ISNULL(reviews.AvgRating, 0.0) AS Rating,
                            ISNULL(reviews.TotalReviews, 0) AS ReviewCount
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
                        ) reviews
                        ORDER BY c.CourseId ASC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        adapter.Fill(dt);
                    }
                }

                BindRepeater(dt);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminCourses Load Error]: {ex.Message}");
                pnlNoCourses.Visible = true;
                litCourseSummary.Text = "Error loading courses from database";
            }
        }

        private void BindRepeater(DataTable dt)
        {
            if (dt != null && dt.Rows.Count > 0)
            {
                rptCourses.DataSource = dt;
                rptCourses.DataBind();
                pnlNoCourses.Visible = false;

                litCourseSummary.Text = $"{dt.Rows.Count} active courses available";
            }
            else
            {
                rptCourses.DataSource = null;
                rptCourses.DataBind();
                pnlNoCourses.Visible = true;
                litCourseSummary.Text = "0 courses available";
            }
        }

        protected void rptCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // Optional repeater actions
        }

        // Helper: CSS styling for course language badges
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
