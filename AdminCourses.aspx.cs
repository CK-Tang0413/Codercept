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
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["CoderceptDB"]?.ConnectionString;

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
                // Fallback Mock Data if connection string is not yet populated
                dt.Columns.Add("CourseId", typeof(int));
                dt.Columns.Add("CourseTitle", typeof(string));
                dt.Columns.Add("DifficultyLevel", typeof(string));
                dt.Columns.Add("Language", typeof(string));
                dt.Columns.Add("TeacherName", typeof(string));
                dt.Columns.Add("EnrolledCount", typeof(int));
                dt.Columns.Add("Rating", typeof(decimal));
                dt.Columns.Add("Status", typeof(string));

                dt.Rows.Add(1, "Python for Beginners", "Beginner", "Python", "Dr. Sarah Park", 128, 4.8m, "Published");
                dt.Rows.Add(2, "Java Fundamentals", "Beginner", "Java", "Prof. Michael Torres", 94, 4.6m, "Published");
                dt.Rows.Add(3, "C Programming Essentials", "Intermediate", "C", "Prof. Michael Torres", 67, 4.5m, "Published");
                dt.Rows.Add(4, "C++ Object-Oriented Programming", "Intermediate", "C++", "Dr. Sarah Park", 82, 4.7m, "Published");
                dt.Rows.Add(5, "Advanced Python — Data Structures & Algorithms", "Advanced", "Python", "Dr. Sarah Park", 45, 4.9m, "Draft");
                dt.Rows.Add(6, "Data Structures with C++", "Advanced", "C++", "Prof. Michael Torres", 38, 4.4m, "Published");

                BindRepeater(dt);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Query joining Course, Teacher, and calculating enrollment counts and average rating
                    string query = @"
                        SELECT 
                            c.CourseId,
                            c.CourseTitle,
                            c.DifficultyLevel,
                            ISNULL(s.SubjectName, 'General') AS Language,
                            ISNULL(t.Name, 'Unassigned') AS TeacherName,
                            ISNULL(enrolled.Count, 0) AS EnrolledCount,
                            ISNULL(reviews.AvgRating, 5.0) AS Rating,
                            ISNULL(c.Status, 'Published') AS Status
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
                            SELECT AVG(cr.Rating) AS AvgRating
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
            }
        }

        private void BindRepeater(DataTable dt)
        {
            if (dt.Rows.Count > 0)
            {
                rptCourses.DataSource = dt;
                rptCourses.DataBind();
                pnlNoCourses.Visible = false;

                // Compute counts
                int totalCourses = dt.Rows.Count;
                int publishedCount = 0;
                foreach (DataRow row in dt.Rows)
                {
                    if (row["Status"].ToString().Equals("Published", StringComparison.OrdinalIgnoreCase))
                    {
                        publishedCount++;
                    }
                }

                litCourseSummary.Text = $"{totalCourses} total courses, {publishedCount} published";
            }
            else
            {
                rptCourses.DataSource = null;
                rptCourses.DataBind();
                pnlNoCourses.Visible = true;
                litCourseSummary.Text = "0 total courses";
            }
        }

        protected void rptCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "TogglePublish")
            {
                // Format: "CourseId|CurrentStatus"
                string[] parts = e.CommandArgument.ToString().Split('|');
                if (parts.Length == 2)
                {
                    int courseId = Convert.ToInt32(parts[0]);
                    string currentStatus = parts[1];

                    // Switch status: Published -> Draft, Draft/Unpublished -> Published
                    string newStatus = currentStatus.Equals("Published", StringComparison.OrdinalIgnoreCase)
                        ? "Draft"
                        : "Published";

                    UpdateCourseStatusInDatabase(courseId, newStatus);

                    // Refresh course list and statistics
                    LoadCourses();
                }
            }
        }

        private void UpdateCourseStatusInDatabase(int courseId, string newStatus)
        {
            if (string.IsNullOrEmpty(connectionString)) return;

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string updateQuery = @"
                        UPDATE [dbo].[Course]
                        SET [Status] = @Status,
                            [DateUpdate] = GETDATE()
                        WHERE [CourseId] = @CourseId";

                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Status", newStatus);
                        cmd.Parameters.AddWithValue("@CourseId", courseId);

                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminCourses Update Status Error]: {ex.Message}");
            }
        }

        // Helper: CSS styling for course language badges
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