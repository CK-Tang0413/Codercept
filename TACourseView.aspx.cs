using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;

namespace Codercept
{
    public partial class TACourseView : System.Web.UI.Page
    {
        public class QuestionDetail
        {
            public string Type { get; set; }
            public string Content { get; set; }
            public double Score { get; set; }
        }

        public class CurriculumItem
        {
            public int ItemId { get; set; }
            public string Title { get; set; }
            public string Kind { get; set; }
            public string Body { get; set; }
            public string MediaLink { get; set; }
            public List<QuestionDetail> Questions { get; set; } = new List<QuestionDetail>();
        }

        public class ChapterItem
        {
            public int ChapterId { get; set; }
            public int Number { get; set; }
            public string Title { get; set; }
            public string Description { get; set; }
            public string Duration { get; set; }
            public List<CurriculumItem> Items { get; set; } = new List<CurriculumItem>();
        }

        protected int CourseId;
        protected string CourseGlyph = "?";
        protected string CourseTheme = "other";
        protected List<ChapterItem> Chapters = new List<ChapterItem>();
        protected int SelectedChapterId;
        protected ChapterItem ActiveChapter;

        private readonly string connString = TAHelpers.ConnectionString;
        private int TaId { get { return Convert.ToInt32(Session["UserId"]); } }

        protected void Page_Load(object sender, EventArgs e)
        {
            int.TryParse(Request.QueryString["id"], out CourseId);
            if (CourseId <= 0)
            {
                phCourse.Visible = false;
                phNotFound.Visible = true;
                return;
            }

            if (!IsPostBack)
            {
                LoadCourseDetails();
            }
        }

        private void LoadCourseDetails()
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT c.CourseTitle, c.CourseDescription, c.DifficultyLevel, c.CourseDuration, t.Name AS TeacherName,
                           ISNULL((SELECT TOP 1 s.SubjectName FROM [dbo].[CourseSubject] cs
                                   INNER JOIN [dbo].[Subject] s ON s.SubjectId = cs.SubjectId
                                   WHERE cs.CourseId = c.CourseId AND s.SubjectType = 'Language'
                                   ORDER BY s.SubjectId), 'Other') AS Language
                    FROM [dbo].[Course] c
                    INNER JOIN [dbo].[Teacher] t ON t.TeacherId = c.TeacherId
                    WHERE c.CourseId = @CourseId
                      AND EXISTS (
                          SELECT 1 FROM [dbo].[CourseSubject] cs
                          INNER JOIN [dbo].[EducatorSubject] es ON es.SubjectId = cs.SubjectId
                          WHERE cs.CourseId = c.CourseId AND es.TA_Id = @TA_Id
                      )", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", CourseId);
                    cmd.Parameters.AddWithValue("@TA_Id", TaId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            phCourse.Visible = false;
                            phNotFound.Visible = true;
                            return;
                        }

                        string title = reader["CourseTitle"].ToString();
                        string lang = reader["Language"].ToString();
                        string level = reader["DifficultyLevel"].ToString();
                        string dur = reader["CourseDuration"].ToString();
                        string teacher = reader["TeacherName"].ToString();

                        litTitle.Text = Server.HtmlEncode(title);
                        litSubtitle.Text = Server.HtmlEncode(lang + " · " + level + " · " + dur + " · Instructor: " + teacher);

                        CourseGlyph = GlyphOf(lang);
                        CourseTheme = ThemeOf(lang);
                    }
                }

                using (SqlCommand cmd = new SqlCommand(
                    "SELECT ChapterId, ChapterNum, ChapterTitle, ChapterDescription, ChapterDuration FROM [dbo].[Chapter] WHERE CourseId = @CourseId ORDER BY ChapterNum", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", CourseId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            Chapters.Add(new ChapterItem
                            {
                                ChapterId = Convert.ToInt32(reader["ChapterId"]),
                                Number = Convert.ToInt32(Convert.ToDouble(reader["ChapterNum"])),
                                Title = reader["ChapterTitle"].ToString(),
                                Description = reader["ChapterDescription"].ToString(),
                                Duration = reader["ChapterDuration"].ToString()
                            });
                        }
                    }
                }

                if (Chapters.Count == 0) return;

                int.TryParse(Request.QueryString["ch"], out SelectedChapterId);
                ActiveChapter = Chapters.FirstOrDefault(c => c.ChapterId == SelectedChapterId) ?? Chapters.First();
                SelectedChapterId = ActiveChapter.ChapterId;

                // Load items of this chapter
                const string itemsSql = @"
                    SELECT sc.SubChapterId, sc.SubChapterTitle, 'Lesson' AS Kind, sc.SubChapterContent, sc.SubChapterMediaLink, sc.SubChapterOrder AS Ord
                    FROM [dbo].[SubChapter] sc WHERE sc.ChapterId = @ChapterId
                    UNION ALL
                    SELECT q.QuizId, q.QuizTitle, 'Quiz', q.QuizDescription, NULL, 999
                    FROM [dbo].[Quiz] q WHERE q.ChapterId = @ChapterId
                    UNION ALL
                    SELECT a.AssessmentId, a.AssessmentTitle, 'Assessment', a.AssessmentDescription, NULL, 1000
                    FROM [dbo].[Assessment] a WHERE a.ChapterId = @ChapterId
                    ORDER BY Ord";

                using (SqlCommand cmd = new SqlCommand(itemsSql, con))
                {
                    cmd.Parameters.AddWithValue("@ChapterId", SelectedChapterId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            ActiveChapter.Items.Add(new CurriculumItem
                            {
                                ItemId = Convert.ToInt32(reader[0]),
                                Title = reader[1].ToString(),
                                Kind = reader[2].ToString(),
                                Body = reader[3] as string,
                                MediaLink = reader[4] as string
                            });
                        }
                    }
                }

                // Load questions for quizzes and assessments in this chapter
                var quizIds = ActiveChapter.Items.Where(i => i.Kind == "Quiz").Select(i => i.ItemId).ToList();
                var asmIds = ActiveChapter.Items.Where(i => i.Kind == "Assessment").Select(i => i.ItemId).ToList();

                if (quizIds.Count > 0 || asmIds.Count > 0)
                {
                    string qSql = @"
                        SELECT q.QuestionContent, q.QuestionType, q.QuestionScore, q.QuizId, q.AssessmentId
                        FROM [dbo].[Question] q
                        WHERE (q.QuizId IS NOT NULL AND q.QuizId IN (" + (quizIds.Count > 0 ? string.Join(",", quizIds) : "0") + @"))
                           OR (q.AssessmentId IS NOT NULL AND q.AssessmentId IN (" + (asmIds.Count > 0 ? string.Join(",", asmIds) : "0") + @"))
                        ORDER BY q.QuestionOrder, q.QuestionId";

                    using (SqlCommand cmd = new SqlCommand(qSql, con))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int? qId = reader.IsDBNull(3) ? (int?)null : reader.GetInt32(3);
                            int? aId = reader.IsDBNull(4) ? (int?)null : reader.GetInt32(4);

                            CurriculumItem item = null;
                            if (qId.HasValue) item = ActiveChapter.Items.FirstOrDefault(i => i.Kind == "Quiz" && i.ItemId == qId.Value);
                            else if (aId.HasValue) item = ActiveChapter.Items.FirstOrDefault(i => i.Kind == "Assessment" && i.ItemId == aId.Value);

                            if (item != null)
                            {
                                item.Questions.Add(new QuestionDetail
                                {
                                    Content = reader.GetString(0),
                                    Type = reader.GetString(1),
                                    Score = reader.GetDouble(2)
                                });
                            }
                        }
                    }
                }
            }
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
