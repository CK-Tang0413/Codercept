using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;

namespace Codercept
{
    public partial class TACourses : System.Web.UI.Page
    {
        public class CourseItem
        {
            public int CourseId { get; set; }
            public string Title { get; set; }
            public string Description { get; set; }
            public string Level { get; set; }
            public string Duration { get; set; }
            public string Teacher { get; set; }
            public string Subjects { get; set; }
            public int ChapterCount { get; set; }
            public bool IsMine { get; set; }
        }

        private readonly string connString = TAHelpers.ConnectionString;

        protected string CurrentScope { get; private set; } = "all";

        private int TaId { get { return Convert.ToInt32(Session["UserId"]); } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCourses();
            }
        }

        protected string GetOptionClass(string scope)
        {
            return scope == CurrentScope ? "active" : "";
        }

        // "My courses" = courses that share a programming-language subject with this TA (EducatorSubject + CourseSubject)
        private List<CourseItem> GetCourses()
        {
            var courses = new List<CourseItem>();

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT c.CourseId, c.CourseTitle, c.CourseDescription, c.DifficultyLevel, c.CourseDuration, t.Name AS TeacherName,
                           (SELECT COUNT(*) FROM [dbo].[Chapter] ch WHERE ch.CourseId = c.CourseId) AS ChapterCount,
                           ISNULL(STUFF((SELECT ', ' + s.SubjectName
                                         FROM [dbo].[CourseSubject] cs
                                         INNER JOIN [dbo].[Subject] s ON s.SubjectId = cs.SubjectId
                                         WHERE cs.CourseId = c.CourseId
                                         ORDER BY s.SubjectName
                                         FOR XML PATH('')), 1, 2, ''), '') AS Subjects,
                           CASE WHEN EXISTS (SELECT 1 FROM [dbo].[CourseSubject] cs
                                             INNER JOIN [dbo].[EducatorSubject] es ON es.SubjectId = cs.SubjectId
                                             WHERE cs.CourseId = c.CourseId AND es.TA_Id = @TA_Id) THEN 1 ELSE 0 END AS IsMine
                    FROM [dbo].[Course] c
                    INNER JOIN [dbo].[Teacher] t ON t.TeacherId = c.TeacherId
                    ORDER BY c.CourseTitle", con))
                {
                    cmd.Parameters.AddWithValue("@TA_Id", TaId);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            courses.Add(new CourseItem
                            {
                                CourseId = Convert.ToInt32(reader["CourseId"]),
                                Title = Server.HtmlEncode(reader["CourseTitle"].ToString()),
                                Description = Server.HtmlEncode(reader["CourseDescription"].ToString()),
                                Level = Server.HtmlEncode(reader["DifficultyLevel"].ToString()),
                                Duration = Server.HtmlEncode(reader["CourseDuration"].ToString()),
                                Teacher = Server.HtmlEncode(reader["TeacherName"].ToString()),
                                Subjects = Server.HtmlEncode(reader["Subjects"].ToString()),
                                ChapterCount = Convert.ToInt32(reader["ChapterCount"]),
                                IsMine = Convert.ToInt32(reader["IsMine"]) == 1
                            });
                        }
                    }
                }
            }

            return courses;
        }

        private void LoadCourses()
        {
            var all = GetCourses();
            int mineCount = all.Count(c => c.IsMine);

            // Default to the TA's own courses; fall back to everything when no subject is assigned yet
            string scope = (Request.QueryString["scope"] ?? "").ToLower();
            CurrentScope = scope == "all" ? "all" : scope == "mine" ? "mine" : (mineCount > 0 ? "mine" : "all");

            litCountAll.Text = all.Count.ToString();
            litCountMine.Text = mineCount.ToString();
            litFilterLabel.Text = CurrentScope == "mine" ? "My courses" : "All courses";

            var shown = CurrentScope == "mine" ? all.Where(c => c.IsMine).ToList() : all;

            phNoAssigned.Visible = CurrentScope == "mine" && mineCount == 0;
            phEmpty.Visible = shown.Count == 0 && !phNoAssigned.Visible;
            rptCourses.DataSource = shown;
            rptCourses.DataBind();
        }
    }
}
