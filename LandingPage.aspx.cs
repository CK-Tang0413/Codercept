using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class LandingPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // If user is already logged in, you can optionally redirect them to their dashboard
                if (Session["UserType"] != null)
                {
                    if (Session["UserType"].ToString() == "Learner") Response.Redirect("LearnerDashboard.aspx");
                    if (Session["UserType"].ToString() == "Teacher") Response.Redirect("TeacherDashboard.aspx");
                    if (Session["UserType"].ToString() == "Admin" || Session["UserType"].ToString() == "SuperAdmin") Response.Redirect("AdminDashboard.aspx");
                }

                LoadCoursePreview();
            }
        }

        private void LoadCoursePreview()
        {
            string connString = ConfigurationManager.ConnectionStrings["Codercept_db"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connString))
            {
                // Fetch the Top 6 highest rated & most enrolled courses for the public preview
                string query = @"
                    SELECT TOP 6 
                        c.CourseId, 
                        c.CourseTitle, 
                        c.CourseDescription, 
                        c.DifficultyLevel,
                        c.CourseDuration,
                        (SELECT COUNT(*) FROM Chapter WHERE CourseId = c.CourseId) as Chapters,
                        ISNULL((SELECT TOP 1 s.SubjectName FROM CourseSubject cs JOIN Subject s ON cs.SubjectId = s.SubjectId WHERE cs.CourseId = c.CourseId AND s.SubjectType = 'Language'), 'General') as Language,
                        ISNULL((SELECT COUNT(*) FROM LearnerProgress WHERE CourseId = c.CourseId), 0) as EnrolledCount,
                        ISNULL((SELECT ROUND(AVG(Rating), 1) FROM Course_Review WHERE CourseId = c.CourseId), 0.0) as Rating
                    FROM Course c
                    ORDER BY Rating DESC, EnrolledCount DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // Add dynamic CSS class for thumbnail background
                    dt.Columns.Add("LanguageCSS", typeof(string));

                    foreach (DataRow row in dt.Rows)
                    {
                        string lang = row["Language"].ToString().ToLower();
                        if (lang.Contains("c++") || lang.Contains("cpp")) row["LanguageCSS"] = "cpp";
                        else if (lang == "c") row["LanguageCSS"] = "c";
                        else row["LanguageCSS"] = lang.Replace(" ", "");
                    }

                    rptPublicCourses.DataSource = dt;
                    rptPublicCourses.DataBind();
                }
            }
        }
    }
}