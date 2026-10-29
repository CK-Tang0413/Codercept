using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class CourseViewer : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["Codercept_db"].ConnectionString;

        // Data Models for Repeater
        public class NavChapter
        {
            public int Id { get; set; }
            public string Title { get; set; }
            public string Duration { get; set; }
            public string Status { get; set; }
            public bool IsActive { get; set; }
        }

        public class QuizQuestion
        {
            public string Title { get; set; }
            public List<string> Options { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserType"] == null || Session["UserType"].ToString() != "Learner")
            {
                Response.Redirect("signIn.aspx");
                return;
            }

            if (!IsPostBack)
            {
                int courseId = 1;
                int activeChapterNum = 1;

                if (Request.QueryString["courseId"] != null) int.TryParse(Request.QueryString["courseId"], out courseId);
                if (Request.QueryString["ch"] != null) int.TryParse(Request.QueryString["ch"], out activeChapterNum);

                int learnerId = Convert.ToInt32(Session["UserId"]);
                LoadCourseViewer(courseId, activeChapterNum, learnerId);
            }
        }

        private void LoadCourseViewer(int courseId, int activeChapterNum, int learnerId)
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                // 1. Get Course and Learner Progress Info
                string courseQuery = "SELECT CourseTitle, (SELECT COUNT(*) FROM Chapter WHERE CourseId = c.CourseId) as TotalChaps, (SELECT ChapNum FROM LearnerProgress WHERE CourseId = c.CourseId AND LearnerId = @LearnerId) as LearnerChap FROM Course c WHERE CourseId = @CourseId";
                int totalChapters = 0;
                int learnerProgress = 0;
                string courseTitle = "";

                using (SqlCommand cmd = new SqlCommand(courseQuery, con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            courseTitle = reader["CourseTitle"].ToString();
                            totalChapters = Convert.ToInt32(reader["TotalChaps"]);
                            if (reader["LearnerChap"] != DBNull.Value) learnerProgress = Convert.ToInt32(reader["LearnerChap"]);
                        }
                    }
                    con.Close();
                }

                // Redirect if attempting to access an unenrolled course
                if (learnerProgress == 0) Response.Redirect("CourseCatalog.aspx");

                // Auto-Update Progress if they navigated to a new allowed chapter
                if (activeChapterNum > learnerProgress && activeChapterNum <= totalChapters)
                {
                    using (SqlCommand cmd = new SqlCommand("UPDATE LearnerProgress SET ChapNum = @NewChap WHERE LearnerId = @LearnerId AND CourseId = @CourseId", con))
                    {
                        cmd.Parameters.AddWithValue("@NewChap", activeChapterNum);
                        cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                        cmd.Parameters.AddWithValue("@CourseId", courseId);
                        con.Open();
                        cmd.ExecuteNonQuery();
                        con.Close();
                    }
                    learnerProgress = activeChapterNum; // Update local variable to reflect new progress
                }

                litTotalChapters.Text = totalChapters.ToString();

                // 2. Load Sidebar Chapters
                List<NavChapter> sidebarChapters = new List<NavChapter>();
                string chaptersQuery = "SELECT ChapterId, ChapterNum, ChapterTitle, ChapterDuration FROM Chapter WHERE CourseId = @CourseId ORDER BY ChapterNum ASC";
                int activeChapterDbId = 0;

                using (SqlCommand cmd = new SqlCommand(chaptersQuery, con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int cNum = Convert.ToInt32(reader["ChapterNum"]);

                            string status = "locked";
                            if (cNum < learnerProgress) status = "completed";
                            else if (cNum == learnerProgress) status = "pending";

                            if (cNum == activeChapterNum) activeChapterDbId = Convert.ToInt32(reader["ChapterId"]);

                            sidebarChapters.Add(new NavChapter
                            {
                                Id = cNum,
                                Title = reader["ChapterTitle"].ToString(),
                                Duration = reader["ChapterDuration"].ToString(),
                                Status = status,
                                IsActive = (cNum == activeChapterNum)
                            });
                        }
                    }
                    con.Close();
                }

                rptSidebar.DataSource = sidebarChapters;
                rptSidebar.DataBind();

                // 3. Load Main Content for Active Chapter
                string activeChapQuery = @"
                    SELECT 
                        ch.ChapterNum, ch.ChapterTitle, ch.ChapterDuration, ch.ChapterMediaLink,
                        CAST(CASE WHEN EXISTS (SELECT 1 FROM Quiz WHERE ChapterId = ch.ChapterId) THEN 1 ELSE 0 END AS BIT) as HasQuiz,
                        (SELECT QuizId FROM Quiz WHERE ChapterId = ch.ChapterId) as QuizId,
                        CAST(CASE WHEN EXISTS (SELECT 1 FROM Assessment WHERE ChapterId = ch.ChapterId) THEN 1 ELSE 0 END AS BIT) as HasAssessment,
                        (SELECT AssessmentId FROM Assessment WHERE ChapterId = ch.ChapterId) as AssessmentId,
                        CAST(CASE WHEN ch.ChapterNum = (SELECT MAX(ChapterNum) FROM Chapter WHERE CourseId = ch.CourseId) AND EXISTS(SELECT 1 FROM Exam WHERE CourseId = ch.CourseId) THEN 1 ELSE 0 END AS BIT) as HasExam
                    FROM Chapter ch
                    WHERE ch.ChapterId = @ActiveChapId";

                using (SqlCommand cmd = new SqlCommand(activeChapQuery, con))
                {
                    cmd.Parameters.AddWithValue("@ActiveChapId", activeChapterDbId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            litChNumber.Text = reader["ChapterNum"].ToString();
                            litChTitle.Text = reader["ChapterTitle"].ToString();
                            litChDuration.Text = reader["ChapterDuration"].ToString();
                            phCheckmark.Visible = Convert.ToInt32(reader["ChapterNum"]) < learnerProgress;

                            // Dynamic Media Link Rendering
                            string mediaLink = reader["ChapterMediaLink"].ToString();
                            if (!string.IsNullOrEmpty(mediaLink))
                            {
                                pnlMedia.Visible = true;
                                if (mediaLink.EndsWith(".mp4") || mediaLink.EndsWith(".webm") || mediaLink.Contains("youtube"))
                                {
                                    litMediaHtml.Text = $@"
                                    <div class='video-container' style=""background-image: url('{mediaLink}.jpg'); background-size: cover; background-position: center;"">
                                        <div class='play-btn'>
                                            <svg width='24' height='24' fill='currentColor' viewBox='0 0 16 16'>
                                                <path d='M10.804 8 5 4.633v6.734L10.804 8zm.792-.696a.802.802 0 0 1 0 1.392l-6.363 3.692C4.713 12.69 4 12.345 4 11.692V4.308c0-.653.713-.998 1.233-.696l6.363 3.692z'/>
                                            </svg>
                                        </div>
                                        <h3 style='color: white; margin-bottom: 0.5rem;'>Lecture Video</h3>
                                    </div>";
                                }
                                else
                                {
                                    litMediaHtml.Text = $"<img src='{mediaLink}' style='width: 100%; border-radius: 12px; margin-bottom: 2rem;' />";
                                }
                            }

                            // NEW: Use a completely separate connection for the nested SubChapter query
                            using (SqlConnection subCon = new SqlConnection(connString))
                            {
                                string subQuery = "SELECT SubChapterTitle, SubChapterContent FROM SubChapter WHERE ChapterId = @ChapId ORDER BY SubChapterOrder ASC";
                                using (SqlCommand subCmd = new SqlCommand(subQuery, subCon))
                                {
                                    subCmd.Parameters.AddWithValue("@ChapId", activeChapterDbId);
                                    subCon.Open();
                                    using (SqlDataReader subReader = subCmd.ExecuteReader())
                                    {
                                        string theoryHtml = "";
                                        while (subReader.Read())
                                        {
                                            theoryHtml += $"<h2>{subReader["SubChapterTitle"]}</h2><p>{subReader["SubChapterContent"]}</p>";
                                        }
                                        if (!string.IsNullOrEmpty(theoryHtml))
                                        {
                                            pnlTheory.Visible = true;
                                            litTheoryHtml.Text = theoryHtml;
                                        }
                                    }
                                    subCon.Close();
                                }
                            }

                            if (Convert.ToBoolean(reader["HasQuiz"]))
                            {
                                pnlQuiz.Visible = true;
                                int quizId = Convert.ToInt32(reader["QuizId"]);
                                // Removed the "con" parameter so it creates its own connection inside
                                LoadQuizQuestions(quizId);
                            }

                            if (Convert.ToBoolean(reader["HasAssessment"]))
                            {
                                pnlCode.Visible = true;
                                int assessmentId = Convert.ToInt32(reader["AssessmentId"]);
                                // Removed the "con" parameter so it creates its own connection inside
                                LoadAssessmentContent(assessmentId);
                            }

                            pnlExam.Visible = Convert.ToBoolean(reader["HasExam"]);
                        }
                    }
                    con.Close();
                }

                // 4. Setup Footer Navigation Link Logistics
                litStepIndicator.Text = $"{activeChapterNum} / {totalChapters}";

                if (activeChapterNum > 1)
                {
                    lnkPrev.NavigateUrl = $"CourseViewer.aspx?courseId={courseId}&ch={activeChapterNum - 1}";
                    lnkPrev.Visible = true;
                }
                else lnkPrev.Visible = false;

                if (activeChapterNum < totalChapters && activeChapterNum <= learnerProgress)
                {
                    lnkNext.NavigateUrl = $"CourseViewer.aspx?courseId={courseId}&ch={activeChapterNum + 1}";
                    lnkNext.Visible = true;
                }
                else lnkNext.Visible = false;
            }
        }

        // NEW: LoadQuizQuestions now opens its own SqlConnection
        private void LoadQuizQuestions(int quizId)
        {
            List<QuizQuestion> questions = new List<QuizQuestion>();
            string qQuery = "SELECT QuestionId, QuestionContent FROM Question WHERE QuizId = @QuizId ORDER BY QuestionOrder ASC";

            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand(qQuery, con))
                {
                    cmd.Parameters.AddWithValue("@QuizId", quizId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            QuizQuestion q = new QuizQuestion { Title = $"Q. {reader["QuestionContent"]}", Options = new List<string>() };

                            // Load Options (this nested query was already using a safe inner connection)
                            using (SqlConnection con2 = new SqlConnection(connString))
                            {
                                string optQuery = "SELECT OptionContent FROM MCQ_Option WHERE QuestionId = @QuestionId ORDER BY OptionOrder ASC";
                                using (SqlCommand optCmd = new SqlCommand(optQuery, con2))
                                {
                                    optCmd.Parameters.AddWithValue("@QuestionId", reader["QuestionId"]);
                                    con2.Open();
                                    using (SqlDataReader optReader = optCmd.ExecuteReader())
                                    {
                                        while (optReader.Read()) q.Options.Add(optReader["OptionContent"].ToString());
                                    }
                                    con2.Close();
                                }
                            }
                            questions.Add(q);
                        }
                    }
                    con.Close();
                }
            }

            rptQuizQuestions.DataSource = questions;
            rptQuizQuestions.DataBind();
        }

        // NEW: LoadAssessmentContent now opens its own SqlConnection
        private void LoadAssessmentContent(int assessmentId)
        {
            string query = "SELECT AssessmentTitle, AssessmentDescription FROM Assessment WHERE AssessmentId = @AssessmentId";

            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@AssessmentId", assessmentId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            litCodeTitle.Text = reader["AssessmentTitle"].ToString();
                            litCodeDesc.Text = reader["AssessmentDescription"].ToString();
                        }
                    }
                    con.Close();
                }
            }
        }

        protected void rptSidebar_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var chapter = (NavChapter)e.Item.DataItem;
                var litStatusIcon = (Literal)e.Item.FindControl("litStatusIcon");

                if (chapter.Status == "completed")
                    litStatusIcon.Text = "<svg width='12' height='12' fill='none' stroke='currentColor' viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='3' d='M5 13l4 4L19 7'/></svg>";
                else
                    litStatusIcon.Text = chapter.Id.ToString();
            }
        }
    }
}