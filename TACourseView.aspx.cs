using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text;

namespace Codercept
{
    // Read-only copy of the learner's course view, so the TA can see exactly what was taught in a chapter.
    // Nothing on this page writes to the database.
    public partial class TACourseView : System.Web.UI.Page
    {
        // 1. Define Data Structures
        private class Question
        {
            public string Type { get; set; }
            public string Content { get; set; }
            public double Score { get; set; }
        }

        private class Item
        {
            public int ChapterId { get; set; }
            public int ItemId { get; set; }
            public double Order { get; set; }
            public string Title { get; set; }
            public string Kind { get; set; }
            public string Body { get; set; }
            public string MediaLink { get; set; }
            public List<Question> Questions { get; } = new List<Question>();
            public string Anchor { get { return "item-" + Kind.ToLower() + "-" + ItemId; } }
        }

        private class Chapter
        {
            public int ChapterId { get; set; }
            public int Number { get; set; }
            public string Title { get; set; }
            public string Description { get; set; }
            public string Duration { get; set; }
            public string MediaLink { get; set; }
            public List<Item> Items { get; } = new List<Item>();
        }

        private readonly string connString = TAHelpers.ConnectionString;

        private static string H(string text) { return System.Web.HttpUtility.HtmlEncode(text ?? ""); }

        // Only web links are rendered as clickable media
        private static string SafeLink(string url)
        {
            if (string.IsNullOrWhiteSpace(url)) return null;
            Uri uri;
            if (Uri.TryCreate(url.Trim(), UriKind.Absolute, out uri) && (uri.Scheme == Uri.UriSchemeHttp || uri.Scheme == Uri.UriSchemeHttps))
                return System.Web.HttpUtility.HtmlAttributeEncode(uri.AbsoluteUri);
            return null;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCourse();
            }
        }

        private void LoadCourse()
        {
            int.TryParse(Request.QueryString["id"], out int courseId);
            int taId = Convert.ToInt32(Session["UserId"]);

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();

                // Course header
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT c.CourseTitle, c.CourseDescription, c.DifficultyLevel, c.CourseDuration, t.Name AS TeacherName,
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
                    WHERE c.CourseId = @CourseId", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    cmd.Parameters.AddWithValue("@TA_Id", taId);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            phCourse.Visible = false;
                            phNotFound.Visible = true;
                            return;
                        }

                        litTitle.Text = H(reader["CourseTitle"].ToString());
                        litDescription.Text = H(reader["CourseDescription"].ToString());
                        litLevel.Text = H(reader["DifficultyLevel"].ToString());
                        litDuration.Text = H(reader["CourseDuration"].ToString());
                        litTeacher.Text = H(reader["TeacherName"].ToString());

                        string subjects = reader["Subjects"].ToString();
                        litSubjects.Text = subjects.Length > 0 ? "<span class=\"tag tag-subject\">" + H(subjects) + "</span>" : "";
                        litMine.Text = Convert.ToInt32(reader["IsMine"]) == 1 ? "<span class=\"tag tag-mine\">My course</span>" : "";
                    }
                }

                var chapters = new List<Chapter>();
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT ChapterId, ChapterNum, ChapterTitle, ChapterDescription, ChapterDuration, ChapterMediaLink FROM [dbo].[Chapter] WHERE CourseId = @CourseId ORDER BY ChapterNum", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            chapters.Add(new Chapter
                            {
                                ChapterId = Convert.ToInt32(reader["ChapterId"]),
                                Number = Convert.ToInt32(Convert.ToDouble(reader["ChapterNum"])),
                                Title = reader["ChapterTitle"].ToString(),
                                Description = reader["ChapterDescription"].ToString(),
                                Duration = reader["ChapterDuration"].ToString(),
                                MediaLink = reader["ChapterMediaLink"] as string
                            });
                        }
                    }
                }

                // Lessons, quizzes (shown right after their lesson), then the chapter assessment and exam
                const string itemsQuery = @"
                    SELECT sc.ChapterId, sc.SubChapterOrder AS Ord, sc.SubChapterId AS ItemId, sc.SubChapterTitle AS Title, 'Lesson' AS Kind, sc.SubChapterContent AS Body, sc.SubChapterMediaLink AS Media
                    FROM [dbo].[SubChapter] sc INNER JOIN [dbo].[Chapter] ch ON ch.ChapterId = sc.ChapterId WHERE ch.CourseId = @CourseId
                    UNION ALL
                    SELECT sc.ChapterId, sc.SubChapterOrder + 0.5, q.QuizId, q.QuizTitle, 'Quiz', q.QuizDescription, NULL
                    FROM [dbo].[Quiz] q INNER JOIN [dbo].[SubChapter] sc ON sc.SubChapterId = q.SubChapterId
                    INNER JOIN [dbo].[Chapter] ch ON ch.ChapterId = sc.ChapterId WHERE ch.CourseId = @CourseId
                    UNION ALL
                    SELECT a.ChapterId, 1000, a.AssessmentId, a.AssessmentTitle, 'Assessment', a.AssessmentDescription, NULL
                    FROM [dbo].[Assessment] a INNER JOIN [dbo].[Chapter] ch ON ch.ChapterId = a.ChapterId WHERE ch.CourseId = @CourseId
                    UNION ALL
                    SELECT e.ChapterId, 1001, e.ExamId, e.ExamTitle, 'Exam', e.ExamDescription, NULL
                    FROM [dbo].[Exam] e INNER JOIN [dbo].[Chapter] ch ON ch.ChapterId = e.ChapterId WHERE ch.CourseId = @CourseId
                    ORDER BY ChapterId, Ord";

                var allItems = new List<Item>();
                using (SqlCommand cmd = new SqlCommand(itemsQuery, con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var chapter = chapters.FirstOrDefault(c => c.ChapterId == Convert.ToInt32(reader["ChapterId"]));
                            if (chapter == null) continue;

                            var item = new Item
                            {
                                ChapterId = chapter.ChapterId,
                                ItemId = Convert.ToInt32(reader["ItemId"]),
                                Order = Convert.ToDouble(reader["Ord"]),
                                Title = reader["Title"].ToString(),
                                Kind = reader["Kind"].ToString(),
                                Body = reader["Body"] as string,
                                MediaLink = reader["Media"] as string
                            };
                            chapter.Items.Add(item);
                            allItems.Add(item);
                        }
                    }
                }

                const string questionsQuery = @"
                    SELECT q.QuestionContent, q.QuestionType, q.QuestionScore, q.QuizId, q.AssessmentId, q.ExamId
                    FROM [dbo].[Question] q
                    WHERE q.QuizId IN (SELECT qz.QuizId FROM [dbo].[Quiz] qz
                                       INNER JOIN [dbo].[SubChapter] sc ON sc.SubChapterId = qz.SubChapterId
                                       INNER JOIN [dbo].[Chapter] ch ON ch.ChapterId = sc.ChapterId WHERE ch.CourseId = @CourseId)
                       OR q.AssessmentId IN (SELECT a.AssessmentId FROM [dbo].[Assessment] a
                                             INNER JOIN [dbo].[Chapter] ch ON ch.ChapterId = a.ChapterId WHERE ch.CourseId = @CourseId)
                       OR q.ExamId IN (SELECT e.ExamId FROM [dbo].[Exam] e
                                       INNER JOIN [dbo].[Chapter] ch ON ch.ChapterId = e.ChapterId WHERE ch.CourseId = @CourseId)
                    ORDER BY q.QuestionId";

                using (SqlCommand cmd = new SqlCommand(questionsQuery, con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string kind;
                            int itemId;
                            if (reader["QuizId"] != DBNull.Value) { kind = "Quiz"; itemId = Convert.ToInt32(reader["QuizId"]); }
                            else if (reader["AssessmentId"] != DBNull.Value) { kind = "Assessment"; itemId = Convert.ToInt32(reader["AssessmentId"]); }
                            else { kind = "Exam"; itemId = Convert.ToInt32(reader["ExamId"]); }

                            var item = allItems.FirstOrDefault(i => i.Kind == kind && i.ItemId == itemId);
                            if (item == null) continue;

                            item.Questions.Add(new Question
                            {
                                Type = reader["QuestionType"].ToString(),
                                Content = reader["QuestionContent"].ToString(),
                                Score = Convert.ToDouble(reader["QuestionScore"])
                            });
                        }
                    }
                }

                litChapterCount.Text = chapters.Count.ToString();

                if (chapters.Count == 0)
                {
                    litOutline.Text = "";
                    litChapter.Text = "<p class=\"empty-state\">This course has no chapters yet.</p>";
                    return;
                }

                // Chapter to show: ?ch= (also ?focus= from the grading page), otherwise the first
                int.TryParse(Request.QueryString["ch"] ?? Request.QueryString["focus"], out int chNumber);
                var current = chapters.FirstOrDefault(c => c.Number == chNumber) ?? chapters[0];
                int index = chapters.IndexOf(current);

                litOutline.Text = BuildOutline(courseId, chapters, current);
                litChapter.Text = BuildChapter(courseId, chapters, current, index);
            }
        }

        // ---------- Rendering ----------

        private static string ChapterUrl(int courseId, Chapter c) { return "TACourseView.aspx?id=" + courseId + "&amp;ch=" + c.Number; }

        private string BuildOutline(int courseId, List<Chapter> chapters, Chapter current)
        {
            var sb = new StringBuilder();
            foreach (var c in chapters)
            {
                bool active = c == current;
                sb.Append("<a href=\"").Append(ChapterUrl(courseId, c)).Append("\" class=\"nav-chapter").Append(active ? " active" : "").Append("\">");
                sb.Append("<div class=\"nav-num\">").Append(c.Number).Append("</div>");
                sb.Append("<div class=\"nav-details\"><div class=\"nav-title\">").Append(H(c.Title)).Append("</div>");
                sb.Append("<div class=\"nav-time\">").Append(H(c.Duration)).Append("</div></div></a>");

                if (active)
                {
                    foreach (var item in c.Items)
                    {
                        sb.Append("<a href=\"#").Append(item.Anchor).Append("\" class=\"nav-sub\"><span class=\"kind-dot kind-").Append(item.Kind.ToLower()).Append("\"></span>")
                          .Append(H(item.Title)).Append("</a>");
                    }
                }
            }
            return sb.ToString();
        }

        private string BuildQuestions(Item item)
        {
            if (item.Questions.Count == 0) return "";

            var sb = new StringBuilder();
            int n = 1;
            foreach (var q in item.Questions)
            {
                sb.Append("<div class=\"quiz-question\"><div class=\"q-top\"><span>").Append(H(q.Type)).Append("</span><span>")
                  .Append(q.Score.ToString("0.##", CultureInfo.InvariantCulture)).Append(" marks</span></div>")
                  .Append("<div class=\"q-title\"><span>Q").Append(n++).Append(".</span>").Append(TAHelpers.FormatRichText(q.Content)).Append("</div></div>");
            }
            return sb.ToString();
        }

        private string BuildItem(Item item)
        {
            var sb = new StringBuilder();
            string label = item.Kind == "Lesson" ? "Lesson" : item.Kind == "Quiz" ? "Knowledge Check" : item.Kind == "Assessment" ? "Chapter Assessment" : "Exam";

            sb.Append("<section class=\"content-item\" id=\"").Append(item.Anchor).Append("\">");
            sb.Append("<div class=\"section-divider\">").Append(label).Append(": ").Append(H(item.Title)).Append("</div>");

            if (!string.IsNullOrWhiteSpace(item.Body))
            {
                sb.Append(item.Kind == "Lesson" ? "<div class=\"theory-content\">" : "<p class=\"item-desc\">")
                  .Append(TAHelpers.FormatRichText(item.Body))
                  .Append(item.Kind == "Lesson" ? "</div>" : "</p>");
            }

            string media = SafeLink(item.MediaLink);
            if (media != null)
                sb.Append("<a class=\"media-link\" href=\"").Append(media).Append("\" target=\"_blank\" rel=\"noopener noreferrer\">Open lesson media &rarr;</a>");

            sb.Append(BuildQuestions(item));
            sb.Append("</section>");
            return sb.ToString();
        }

        private string BuildChapter(int courseId, List<Chapter> chapters, Chapter c, int index)
        {
            var sb = new StringBuilder();

            sb.Append("<div class=\"content-header\"><span class=\"ch-label\">Ch. ").Append(c.Number).Append(" &bull; ").Append(H(c.Duration)).Append("</span>");
            sb.Append("<h2 class=\"ch-main-title\">").Append(H(c.Title)).Append("</h2></div>");

            if (!string.IsNullOrWhiteSpace(c.Description))
                sb.Append("<p class=\"chapter-desc\">").Append(H(c.Description)).Append("</p>");

            string media = SafeLink(c.MediaLink);
            if (media != null)
            {
                sb.Append("<div class=\"section-divider\">Video Lecture</div><a class=\"video-card\" href=\"").Append(media)
                  .Append("\" target=\"_blank\" rel=\"noopener noreferrer\"><span class=\"play-btn\">&#9654;</span><span>Open the chapter video</span></a>");
            }

            if (c.Items.Count == 0)
                sb.Append("<p class=\"empty-state\">Nothing has been added to this chapter yet.</p>");

            foreach (var item in c.Items) sb.Append(BuildItem(item));

            // Footer: previous / next chapter
            sb.Append("<div class=\"viewer-footer\">");
            if (index > 0)
                sb.Append("<a class=\"btn-nav\" href=\"").Append(ChapterUrl(courseId, chapters[index - 1])).Append("\">&larr; Previous</a>");
            else
                sb.Append("<span></span>");
            sb.Append("<span class=\"step-indicator\">").Append(index + 1).Append(" / ").Append(chapters.Count).Append("</span>");
            if (index < chapters.Count - 1)
                sb.Append("<a class=\"btn-nav primary\" href=\"").Append(ChapterUrl(courseId, chapters[index + 1])).Append("\">Next &rarr;</a>");
            else
                sb.Append("<span></span>");
            sb.Append("</div>");

            return sb.ToString();
        }
    }
}
