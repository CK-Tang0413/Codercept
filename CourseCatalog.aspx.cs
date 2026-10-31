using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class CourseCatalog : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["Codercept_db"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserType"] == null || Session["UserType"].ToString() != "Learner")
            {
                Response.Redirect("signIn.aspx");
                return;
            }

            if (!IsPostBack)
            {
                ViewState["SelectedLang"] = "All";
                ViewState["SelectedLevel"] = "All";
                BindCourses();
            }
        }

        private void BindCourses()
        {
            int learnerId = 0;
            if (Session["UserId"] != null && Session["UserType"].ToString() == "Learner")
            {
                learnerId = Convert.ToInt32(Session["UserId"]);
            }

            string searchTerm = txtSearch.Text.Trim();
            string selectedLang = ViewState["SelectedLang"].ToString();
            string selectedLevel = ViewState["SelectedLevel"].ToString(); // This is now already "Easy", "Medium", or "Hard"

            using (SqlConnection con = new SqlConnection(connString))
            {
                // Dynamic SQL query based on filters (Filters out enrolled courses)
                string query = @"
            SELECT 
                c.CourseId, 
                c.CourseTitle, 
                c.CourseDescription, 
                c.DifficultyLevel,
                c.CourseDuration,
                (SELECT COUNT(*) FROM Chapter WHERE CourseId = c.CourseId) as Chapters,
                ISNULL((SELECT TOP 1 s.SubjectName FROM CourseSubject cs JOIN Subject s ON cs.SubjectId = s.SubjectId WHERE cs.CourseId = c.CourseId AND s.SubjectType = 'Language'), 'General') as Language,
                ISNULL((SELECT COUNT(*) FROM LearnerProgress WHERE CourseId = c.CourseId), 0) as EnrolledCount,
                ISNULL((SELECT ROUND(AVG(Rating), 1) FROM Course_Review WHERE CourseId = c.CourseId), 0.0) as Rating,
                CAST(0 AS BIT) as IsEnrolled,
                0 as CurrentChapter
            FROM Course c
            WHERE c.CourseId NOT IN (
                SELECT CourseId FROM LearnerProgress WHERE LearnerId = @LearnerId
            ) ";

                if (!string.IsNullOrEmpty(searchTerm))
                {
                    query += " AND (c.CourseTitle LIKE @SearchTerm OR c.CourseDescription LIKE @SearchTerm) ";
                }

                if (selectedLang != "All")
                {
                    if (selectedLang == "C++")
                    {
                        query += " AND (SELECT TOP 1 s.SubjectName FROM CourseSubject cs JOIN Subject s ON cs.SubjectId = s.SubjectId WHERE cs.CourseId = c.CourseId AND s.SubjectType = 'Language') = 'C++' ";
                    }
                    else if (selectedLang == "C")
                    {
                        // Exact match for 'C' to prevent pulling in 'C++'
                        query += " AND (SELECT TOP 1 s.SubjectName FROM CourseSubject cs JOIN Subject s ON cs.SubjectId = s.SubjectId WHERE cs.CourseId = c.CourseId AND s.SubjectType = 'Language') = 'C' ";
                    }
                    else
                    {
                        query += " AND (SELECT TOP 1 s.SubjectName FROM CourseSubject cs JOIN Subject s ON cs.SubjectId = s.SubjectId WHERE cs.CourseId = c.CourseId AND s.SubjectType = 'Language') LIKE '%' + @Lang + '%' ";
                    }
                }

                if (selectedLevel != "All")
                {
                    // We no longer need to map the terms; just use selectedLevel directly
                    query += " AND c.DifficultyLevel = @Level ";
                }

                query += " ORDER BY c.DateCreation DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);

                    if (!string.IsNullOrEmpty(searchTerm))
                        cmd.Parameters.AddWithValue("@SearchTerm", "%" + searchTerm + "%");

                    if (selectedLang != "All")
                        cmd.Parameters.AddWithValue("@Lang", selectedLang);

                    if (selectedLevel != "All")
                    {
                        // Directly pass selectedLevel which is "Easy", "Medium", or "Hard"
                        cmd.Parameters.AddWithValue("@Level", selectedLevel);
                    }

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    dt.Columns.Add("LanguageCSS", typeof(string));
                    dt.Columns.Add("ProgressPercentage", typeof(int));

                    foreach (DataRow row in dt.Rows)
                    {
                        string lang = row["Language"].ToString().ToLower();
                        if (lang.Contains("c++") || lang.Contains("cpp")) row["LanguageCSS"] = "cpp";
                        else if (lang == "c") row["LanguageCSS"] = "c";
                        else row["LanguageCSS"] = lang.Replace(" ", "");

                        row["ProgressPercentage"] = 0; // Unenrolled courses always have 0% progress
                    }

                    rptCourses.DataSource = dt;
                    rptCourses.DataBind();

                    litResultsCount.Text = $"{dt.Rows.Count} course{(dt.Rows.Count != 1 ? "s" : "")} found";
                }
            }
        }

        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            BindCourses();
        }

        protected void FilterLang_Click(object sender, EventArgs e)
        {
            LinkButton clickedBtn = (LinkButton)sender;
            ViewState["SelectedLang"] = clickedBtn.CommandArgument;

            btnLangAll.CssClass = "filter-pill";
            btnLangPython.CssClass = "filter-pill";
            btnLangJava.CssClass = "filter-pill";
            btnLangC.CssClass = "filter-pill";
            btnLangCpp.CssClass = "filter-pill";
            clickedBtn.CssClass = "filter-pill active";

            BindCourses();
        }

        protected void FilterLevel_Click(object sender, EventArgs e)
        {
            LinkButton clickedBtn = (LinkButton)sender;
            ViewState["SelectedLevel"] = clickedBtn.CommandArgument;

            // Reset UI states using the new button IDs
            btnLevelAll.CssClass = "filter-pill";
            btnLevelEasy.CssClass = "filter-pill";
            btnLevelMedium.CssClass = "filter-pill";
            btnLevelHard.CssClass = "filter-pill";

            // Set active class on clicked button
            clickedBtn.CssClass = "filter-pill active";

            BindCourses();
        }

        protected void rptCourses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {

        }
    }
}
