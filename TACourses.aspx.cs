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
            public string Glyph { get; set; }
            public string Theme { get; set; }
            public int ChapterCount { get; set; }
            public bool IsMine { get; set; }
        }

        private readonly string connString = TAHelpers.ConnectionString;
        private int TaId { get { return Convert.ToInt32(Session["UserId"]); } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCourses();
            }
        }

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
                           1 AS IsMine
                    FROM [dbo].[Course] c
                    INNER JOIN [dbo].[Teacher] t ON t.TeacherId = c.TeacherId
                    WHERE EXISTS (
                        SELECT 1 FROM [dbo].[CourseSubject] cs
                        INNER JOIN [dbo].[EducatorSubject] es ON es.SubjectId = cs.SubjectId
                        WHERE cs.CourseId = c.CourseId AND es.TA_Id = @TA_Id
                    )
                    ORDER BY c.CourseTitle", con))
                {
                    cmd.Parameters.AddWithValue("@TA_Id", TaId);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string subjects = reader["Subjects"].ToString();
                            courses.Add(new CourseItem
                            {
                                CourseId = Convert.ToInt32(reader["CourseId"]),
                                Title = reader["CourseTitle"].ToString(),
                                Description = reader["CourseDescription"].ToString(),
                                Level = reader["DifficultyLevel"].ToString(),
                                Duration = reader["CourseDuration"].ToString(),
                                Teacher = reader["TeacherName"].ToString(),
                                Subjects = subjects,
                                Glyph = GlyphOf(subjects),
                                Theme = ThemeOf(subjects),
                                ChapterCount = Convert.ToInt32(reader["ChapterCount"]),
                                IsMine = true
                            });
                        }
                    }
                }
            }

            return courses;
        }

        private void LoadCourses()
        {
            var courses = GetCourses();
            phNoAssigned.Visible = courses.Count == 0;
            rptCourses.DataSource = courses;
            rptCourses.DataBind();
        }

        private static string GlyphOf(string language)
        {
            if (language.IndexOf("Python", StringComparison.OrdinalIgnoreCase) >= 0) return "py";
            if (language.IndexOf("Java", StringComparison.OrdinalIgnoreCase) >= 0) return "Java";
            if (language.IndexOf("C++", StringComparison.OrdinalIgnoreCase) >= 0) return "C++";
            if (language.IndexOf("C", StringComparison.OrdinalIgnoreCase) >= 0) return "C";
            return "?";
        }

        private static string ThemeOf(string language)
        {
            if (language.IndexOf("Python", StringComparison.OrdinalIgnoreCase) >= 0) return "python";
            if (language.IndexOf("Java", StringComparison.OrdinalIgnoreCase) >= 0) return "java";
            if (language.IndexOf("C++", StringComparison.OrdinalIgnoreCase) >= 0) return "cpp";
            if (language.IndexOf("C", StringComparison.OrdinalIgnoreCase) >= 0) return "c";
            return "other";
        }
    }
}
