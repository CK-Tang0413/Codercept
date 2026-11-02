using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class CourseViewer : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["Codercept_db"].ConnectionString;

        public class NavChapter
        {
            public int Id { get; set; }
            public string Title { get; set; }
            public string Duration { get; set; }
            public string Status { get; set; }
            public bool IsActive { get; set; }
        }

        public class ExamQuestion
        {
            public int QuestionId { get; set; }
            public string Title { get; set; }
            public string Type { get; set; }
            public List<QuizOption> Options { get; set; }
            public string SelectedAnswer { get; set; }
            public bool IsLocked { get; set; }
        }

        public class QuizOption
        {
            public int OptionId { get; set; }
            public int QuestionId { get; set; }
            public string OptionContent { get; set; }
            public bool IsSelected { get; set; }
            public bool IsLocked { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserType"] == null || Session["UserType"].ToString() != "Learner")
            {
                Response.Redirect("LandingPage.aspx");
                return;
            }

            pnlWarning.Visible = false;

            if (!IsPostBack)
            {
                int courseId = 1;
                int activeChapterNum = 1;

                if (Request.QueryString["courseId"] != null) int.TryParse(Request.QueryString["courseId"], out courseId);
                if (Request.QueryString["ch"] != null) int.TryParse(Request.QueryString["ch"], out activeChapterNum);

                int learnerId = Convert.ToInt32(Session["UserId"]);

                ViewState["CourseId"] = courseId;
                ViewState["ActiveChapterNum"] = activeChapterNum;

                LoadCourseViewer(courseId, activeChapterNum, learnerId);
            }
        }

        private void LoadCourseViewer(int courseId, int activeChapterNum, int learnerId)
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                int totalChapters = 0;
                int learnerProgress = 0;

                string courseQuery = "SELECT CourseTitle, (SELECT COUNT(*) FROM Chapter WHERE CourseId = c.CourseId) as TotalChaps, (SELECT ChapNum FROM LearnerProgress WHERE CourseId = c.CourseId AND LearnerId = @LearnerId) as LearnerChap FROM Course c WHERE CourseId = @CourseId";
                using (SqlCommand cmd = new SqlCommand(courseQuery, con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            totalChapters = Convert.ToInt32(reader["TotalChaps"]);
                            if (reader["LearnerChap"] != DBNull.Value) learnerProgress = Convert.ToInt32(reader["LearnerChap"]);
                        }
                    }
                    con.Close();
                }

                if (learnerProgress == 0) Response.Redirect("CourseCatalog.aspx");

                bool hasExam = false;
                int examId = 0;
                string examTitle = "";
                string examDesc = "";
                string examDuration = "";

                string examQuery = "SELECT ExamId, ExamTitle, ExamDescription, TimeLimitMinutes FROM Exam WHERE CourseId = @CourseId";
                using (SqlCommand cmd = new SqlCommand(examQuery, con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            hasExam = true;
                            examId = Convert.ToInt32(reader["ExamId"]);
                            examTitle = reader["ExamTitle"].ToString();
                            examDesc = reader["ExamDescription"].ToString();
                            examDuration = $"{reader["TimeLimitMinutes"]} mins";
                        }
                    }
                    con.Close();
                }

                ViewState["HasFinalExam"] = hasExam;
                ViewState["ExamId"] = examId;

                int maxAllowedChapter = totalChapters + (hasExam ? 1 : 0);

                if (activeChapterNum > learnerProgress)
                {
                    activeChapterNum = learnerProgress;
                    ViewState["ActiveChapterNum"] = activeChapterNum;
                }

                litTotalChapters.Text = (hasExam ? $"{totalChapters} chapters + 1 exam" : $"{totalChapters} chapters");
                ViewState["TotalChapters"] = totalChapters;
                ViewState["LearnerProgress"] = learnerProgress;

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

                if (hasExam)
                {
                    int examChapNum = totalChapters + 1;
                    string examStatus = "locked";

                    if (learnerProgress > examChapNum) examStatus = "completed";
                    else if (learnerProgress == examChapNum) examStatus = "pending";

                    if (GetSubmittedAttemptId(learnerId, "ExamId", examId) > 0)
                    {
                        examStatus = "completed";
                    }

                    sidebarChapters.Add(new NavChapter
                    {
                        Id = examChapNum,
                        Title = "Final Exam",
                        Duration = examDuration,
                        Status = examStatus,
                        IsActive = (examChapNum == activeChapterNum)
                    });
                }

                rptSidebar.DataSource = sidebarChapters;
                rptSidebar.DataBind();

                if (activeChapterNum <= totalChapters)
                {
                    pnlNormalChapter.Visible = true;
                    pnlExamContent.Visible = false;
                    ViewState["ActiveChapterDbId"] = activeChapterDbId;

                    string activeChapQuery = @"
                        SELECT 
                            ch.ChapterNum, ch.ChapterTitle, ch.ChapterDuration, ch.ChapterMediaLink,
                            CAST(CASE WHEN EXISTS (SELECT 1 FROM Quiz WHERE ChapterId = ch.ChapterId) THEN 1 ELSE 0 END AS BIT) as HasQuiz,
                            (SELECT QuizId FROM Quiz WHERE ChapterId = ch.ChapterId) as QuizId,
                            CAST(CASE WHEN EXISTS (SELECT 1 FROM Assessment WHERE ChapterId = ch.ChapterId) THEN 1 ELSE 0 END AS BIT) as HasAssessment,
                            (SELECT AssessmentId FROM Assessment WHERE ChapterId = ch.ChapterId) as AssessmentId
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

                                string mediaLink = reader["ChapterMediaLink"].ToString();
                                pnlMedia.Visible = true;
                                if (!string.IsNullOrEmpty(mediaLink))
                                {
                                    if (mediaLink.EndsWith(".mp4") || mediaLink.EndsWith(".webm"))
                                    {
                                        litMediaHtml.Text = $@"
                                        <video width='100%' controls style='border-radius: 12px; margin-bottom: 2rem; border: 1px solid var(--border-light); background: #000;'>
                                            <source src='{mediaLink}' type='video/mp4'>
                                            Your browser does not support the video tag.
                                        </video>";
                                    }
                                    else if (mediaLink.Contains("youtube.com") || mediaLink.Contains("youtu.be"))
                                    {
                                        litMediaHtml.Text = $@"
                                        <iframe width='100%' style='aspect-ratio: 16/9; border-radius: 12px; margin-bottom: 2rem; border: 1px solid var(--border-light);' 
                                            src='{mediaLink}' frameborder='0' allow='accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture' allowfullscreen>
                                        </iframe>";
                                    }
                                    else
                                    {
                                        litMediaHtml.Text = $"<img src='{mediaLink}' style='width: 100%; border-radius: 12px; margin-bottom: 2rem;' />";
                                    }
                                }
                                else
                                {
                                    litMediaHtml.Text = @"
                                    <div class='challenge-box' style='text-align: center; padding: 3rem 1.5rem; border-style: dashed; margin-bottom: 2rem;'>
                                        <svg style='width: 48px; height: 48px; color: var(--text-muted); margin-bottom: 1rem;' fill='none' stroke='currentColor' viewBox='0 0 24 24'>
                                            <path stroke-linecap='round' stroke-linejoin='round' stroke-width='1.5' d='M15 10l4.553-2.276A1 1 0 0121 8.618v6.764a1 1 0 01-1.447.894L15 14M5 18h8a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z'/>
                                        </svg>
                                        <h3 style='color: var(--text-primary); margin-bottom: 0.5rem;'>No Media Available</h3>
                                    </div>";
                                }

                                using (SqlConnection subCon = new SqlConnection(connString))
                                {
                                    string subQuery = "SELECT SubChapterTitle, SubChapterContent, SubChapterMediaLink FROM SubChapter WHERE ChapterId = @ChapId ORDER BY SubChapterOrder ASC";
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

                                                if (subReader["SubChapterMediaLink"] != DBNull.Value)
                                                {
                                                    string subMedia = subReader["SubChapterMediaLink"].ToString().Trim();
                                                    if (!string.IsNullOrEmpty(subMedia))
                                                    {
                                                        if (subMedia.EndsWith(".mp4", StringComparison.OrdinalIgnoreCase) || subMedia.EndsWith(".webm", StringComparison.OrdinalIgnoreCase))
                                                        {
                                                            theoryHtml += $@"
                                                            <video width='100%' controls style='border-radius: 12px; margin-bottom: 2rem; border: 1px solid var(--border-light); background: #000;'>
                                                                <source src='{subMedia}' type='video/mp4'>
                                                                Your browser does not support the video tag.
                                                            </video>";
                                                        }
                                                        else if (subMedia.Contains("youtube.com") || subMedia.Contains("youtu.be"))
                                                        {
                                                            theoryHtml += $@"
                                                            <iframe width='100%' style='aspect-ratio: 16/9; border-radius: 12px; margin-bottom: 2rem; border: 1px solid var(--border-light);' 
                                                                src='{subMedia}' frameborder='0' allow='accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture' allowfullscreen>
                                                            </iframe>";
                                                        }
                                                        else if (subMedia.EndsWith(".pdf", StringComparison.OrdinalIgnoreCase))
                                                        {
                                                            theoryHtml += $@"
                                                            <object data='{subMedia}' type='application/pdf' style='width: 100%; height: 600px; border-radius: 12px; margin-bottom: 2rem; border: 1px solid var(--border-light);'>
                                                                <p>Your browser does not support PDFs. <a href='{subMedia}' style='color: var(--accent-primary);'>Download the PDF</a>.</p>
                                                            </object>";
                                                        }
                                                        else
                                                        {
                                                            theoryHtml += $"<img src='{subMedia}' style='width: 100%; border-radius: 12px; margin-bottom: 2rem;' />";
                                                        }
                                                    }
                                                }
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

                                ViewState["HasQuiz"] = reader["HasQuiz"];
                                ViewState["QuizId"] = reader["QuizId"] != DBNull.Value ? reader["QuizId"] : 0;
                                ViewState["HasAssessment"] = reader["HasAssessment"];
                                ViewState["AssessmentId"] = reader["AssessmentId"] != DBNull.Value ? reader["AssessmentId"] : 0;

                                if (Convert.ToBoolean(reader["HasQuiz"]))
                                {
                                    pnlQuiz.Visible = true;
                                    LoadQuizQuestions(Convert.ToInt32(reader["QuizId"]), learnerId);
                                }

                                if (Convert.ToBoolean(reader["HasAssessment"]))
                                {
                                    pnlCode.Visible = true;
                                    LoadAssessmentContent(Convert.ToInt32(reader["AssessmentId"]), learnerId);
                                }
                            }
                        }
                        con.Close();
                    }
                }
                else
                {
                    pnlNormalChapter.Visible = false;
                    pnlExamContent.Visible = true;

                    litExamTitle.Text = examTitle;
                    litExamDesc.Text = examDesc;
                    LoadExamQuestions(examId, learnerId);
                }

                litStepIndicator.Text = $"{activeChapterNum} / {maxAllowedChapter}";
                lnkPrev.NavigateUrl = $"CourseViewer.aspx?courseId={courseId}&ch={activeChapterNum - 1}";
                lnkPrev.Visible = activeChapterNum > 1;

                if (activeChapterNum < learnerProgress) litNextText.Text = "Next";
                else litNextText.Text = "Mark Complete & Continue";

                btnNext.Visible = activeChapterNum != maxAllowedChapter;
            }
        }

        protected void rptSidebar_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var chapter = (NavChapter)e.Item.DataItem;
                var litStatusIcon = (Literal)e.Item.FindControl("litStatusIcon");

                if (chapter.Status == "completed")
                {
                    litStatusIcon.Text = "<svg width='12' height='12' fill='none' stroke='currentColor' viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='3' d='M5 13l4 4L19 7'/></svg>";
                }
                else
                {
                    litStatusIcon.Text = chapter.Id.ToString();
                }
            }
        }

        // =====================================================================
        // Shared helpers: find the learner's submitted attempt and load every
        // question of a quiz / assessment / exam together with the saved answer.
        // =====================================================================

        // Returns the newest SUBMITTED attempt (completed / graded), or 0 if there is none.
        // A learner can also have 'in_progress' or 'incomplete' attempts for the same activity,
        // so we must not simply take the first Attempt row.
        private int GetSubmittedAttemptId(int learnerId, string idColumn, int activityId)
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string sql = $"SELECT TOP 1 AttemptId FROM Attempt WHERE LearnerId = @LearnerId AND {idColumn} = @ActivityId AND AttemptStatus IN ('completed', 'graded') ORDER BY AttemptDate DESC, AttemptId DESC";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    cmd.Parameters.AddWithValue("@ActivityId", activityId);
                    con.Open();
                    object res = cmd.ExecuteScalar();
                    return (res == null || res == DBNull.Value) ? 0 : Convert.ToInt32(res);
                }
            }
        }

        // ownerColumn is one of "QuizId", "AssessmentId", "ExamId" (never user input).
        // attemptId > 0 means the learner already submitted: answers are filled in and the inputs are locked.
        private List<ExamQuestion> LoadQuestionsWithAnswers(string ownerColumn, int ownerId, int attemptId)
        {
            List<ExamQuestion> questions = new List<ExamQuestion>();
            Dictionary<int, ExamQuestion> byId = new Dictionary<int, ExamQuestion>();
            Dictionary<int, string> answers = new Dictionary<int, string>();
            bool locked = attemptId > 0;

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();

                // 1. everything the learner submitted for this attempt (one row per question)
                if (locked)
                {
                    using (SqlCommand cmd = new SqlCommand("SELECT QuestionId, AnswerContent FROM AttemptAnswer WHERE AttemptId = @AttemptId", con))
                    {
                        cmd.Parameters.AddWithValue("@AttemptId", attemptId);
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                                answers[Convert.ToInt32(r["QuestionId"])] = r["AnswerContent"] == DBNull.Value ? "" : r["AnswerContent"].ToString();
                        }
                    }
                }

                // 2. the questions
                using (SqlCommand cmd = new SqlCommand($"SELECT QuestionId, QuestionContent, QuestionType FROM Question WHERE {ownerColumn} = @OwnerId ORDER BY QuestionOrder ASC, QuestionId ASC", con))
                {
                    cmd.Parameters.AddWithValue("@OwnerId", ownerId);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            int qId = Convert.ToInt32(r["QuestionId"]);
                            string answer;
                            ExamQuestion q = new ExamQuestion
                            {
                                QuestionId = qId,
                                Title = $"Q. {r["QuestionContent"]}",
                                Type = r["QuestionType"].ToString(),
                                IsLocked = locked,
                                SelectedAnswer = answers.TryGetValue(qId, out answer) ? answer : "",
                                Options = new List<QuizOption>()
                            };
                            questions.Add(q);
                            byId[qId] = q;
                        }
                    }
                }

                // 3. all MCQ options of those questions in one query
                using (SqlCommand cmd = new SqlCommand($"SELECT o.MCQ_OptionId, o.QuestionId, o.OptionContent FROM MCQ_Option o INNER JOIN Question q ON q.QuestionId = o.QuestionId WHERE q.{ownerColumn} = @OwnerId ORDER BY o.OptionOrder ASC", con))
                {
                    cmd.Parameters.AddWithValue("@OwnerId", ownerId);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        while (r.Read())
                        {
                            int qId = Convert.ToInt32(r["QuestionId"]);
                            ExamQuestion q;
                            if (!byId.TryGetValue(qId, out q)) continue;

                            int optId = Convert.ToInt32(r["MCQ_OptionId"]);
                            q.Options.Add(new QuizOption
                            {
                                OptionId = optId,
                                QuestionId = qId,
                                OptionContent = r["OptionContent"].ToString(),
                                IsSelected = locked && optId.ToString() == (q.SelectedAnswer ?? "").Trim(),
                                IsLocked = locked
                            });
                        }
                    }
                }
            }

            return questions;
        }

        private void LoadQuizQuestions(int quizId, int learnerId)
        {
            int attemptId = GetSubmittedAttemptId(learnerId, "QuizId", quizId);

            if (attemptId > 0)
            {
                lblQuizState.Visible = true;
                lblQuizState.Text = "You have already submitted this quiz.";
                lblQuizState.Style.Add("color", "#4ade80");
                btnSubmitQuiz.Enabled = false;
                btnSubmitQuiz.Text = "Submitted";
                btnSubmitQuiz.CssClass = "btn-nav";
            }

            rptQuizQuestions.DataSource = LoadQuestionsWithAnswers("QuizId", quizId, attemptId);
            rptQuizQuestions.DataBind();
        }

        protected void rptQuizQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var question = (ExamQuestion)e.Item.DataItem;
                Repeater rptOptions = (Repeater)e.Item.FindControl("rptOptions");
                rptOptions.DataSource = question.Options;
                rptOptions.DataBind();
            }
        }

        protected void btnSubmitQuiz_Click(object sender, EventArgs e)
        {
            foreach (RepeaterItem item in rptQuizQuestions.Items)
            {
                HiddenField hfQuestionId = (HiddenField)item.FindControl("hfQuestionId");
                int questionId = Convert.ToInt32(hfQuestionId.Value);
                string submittedOptionId = Request.Form[$"quiz_q_{questionId}"];

                if (string.IsNullOrEmpty(submittedOptionId))
                {
                    lblQuizState.Visible = true;
                    lblQuizState.Text = "Please answer all questions before submitting.";
                    lblQuizState.Style.Add("color", "#ef4444");
                    return;
                }
            }

            int learnerId = Convert.ToInt32(Session["UserId"]);
            int quizId = Convert.ToInt32(ViewState["QuizId"]);

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                SqlTransaction transaction = con.BeginTransaction();
                try
                {
                    string attemptQuery = "INSERT INTO Attempt (AttemptDate, AttemptStatus, LearnerId, QuizId) OUTPUT INSERTED.AttemptId VALUES (GETDATE(), 'completed', @LearnerId, @QuizId)";
                    int newAttemptId = 0;
                    using (SqlCommand cmd = new SqlCommand(attemptQuery, con, transaction))
                    {
                        cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                        cmd.Parameters.AddWithValue("@QuizId", quizId);
                        newAttemptId = (int)cmd.ExecuteScalar();
                    }

                    foreach (RepeaterItem item in rptQuizQuestions.Items)
                    {
                        HiddenField hfQuestionId = (HiddenField)item.FindControl("hfQuestionId");
                        int questionId = Convert.ToInt32(hfQuestionId.Value);

                        string submittedOptionId = Request.Form[$"quiz_q_{questionId}"];

                        string ansQuery = "INSERT INTO AttemptAnswer (AttemptId, QuestionId, AnswerContent, IsCorrect, ObtainedScore, TeacherComment) VALUES (@AttemptId, @QuestionId, @AnswerContent, 'pending', 0, '')";
                        using (SqlCommand ansCmd = new SqlCommand(ansQuery, con, transaction))
                        {
                            ansCmd.Parameters.AddWithValue("@AttemptId", newAttemptId);
                            ansCmd.Parameters.AddWithValue("@QuestionId", questionId);
                            ansCmd.Parameters.AddWithValue("@AnswerContent", submittedOptionId);
                            ansCmd.ExecuteNonQuery();
                        }
                    }

                    transaction.Commit();

                    lblQuizState.Visible = true;
                    lblQuizState.Text = "Quiz submitted successfully!";
                    lblQuizState.Style.Add("color", "#4ade80");
                    btnSubmitQuiz.Enabled = false;
                    btnSubmitQuiz.Text = "Submitted";
                    btnSubmitQuiz.CssClass = "btn-nav";

                    LoadQuizQuestions(quizId, learnerId);
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    lblQuizState.Visible = true;
                    lblQuizState.Text = "Error submitting quiz: " + ex.Message;
                    lblQuizState.Style.Add("color", "#ef4444");
                }
                finally
                {
                    con.Close();
                }
            }
        }

        private void LoadAssessmentContent(int assessmentId, int learnerId)
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = "SELECT AssessmentTitle, AssessmentDescription FROM Assessment WHERE AssessmentId = @AssessmentId";
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

            int attemptId = GetSubmittedAttemptId(learnerId, "AssessmentId", assessmentId);

            if (attemptId > 0)
            {
                lblCodeState.Visible = true;
                lblCodeState.Text = "You have already submitted this assessment.";
                lblCodeState.Style.Add("color", "#4ade80");
                btnSubmitAssessment.Enabled = false;
                btnSubmitAssessment.Text = "Submitted";
                btnSubmitAssessment.CssClass = "btn-nav";
            }

            // An assessment can hold several questions (MCQ, fill-in-the-blank and coding),
            // so every question is listed with its own answer, the same way the exam does it.
            rptAssessmentQuestions.DataSource = LoadQuestionsWithAnswers("AssessmentId", assessmentId, attemptId);
            rptAssessmentQuestions.DataBind();
        }

        protected void rptAssessmentQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            var question = (ExamQuestion)e.Item.DataItem;
            Repeater rptOptions = (Repeater)e.Item.FindControl("rptAsmOptions");
            TextBox txtFill = (TextBox)e.Item.FindControl("txtAsmFill");
            TextBox txtCode = (TextBox)e.Item.FindControl("txtAsmCode");

            rptOptions.Visible = (question.Type == "MCQ");
            txtFill.Visible = (question.Type == "FillBlank");
            txtCode.Visible = (question.Type == "Coding");

            if (question.Type == "MCQ")
            {
                rptOptions.DataSource = question.Options;
                rptOptions.DataBind();
            }
            else if (question.Type == "FillBlank")
            {
                txtFill.Text = question.SelectedAnswer;
                txtFill.Enabled = !question.IsLocked;
            }
            else if (question.Type == "Coding")
            {
                txtCode.Text = question.SelectedAnswer;
                txtCode.Enabled = !question.IsLocked;
            }
        }

        protected void btnSubmitAssessment_Click(object sender, EventArgs e)
        {
            int learnerId = Convert.ToInt32(Session["UserId"]);
            int assessmentId = Convert.ToInt32(ViewState["AssessmentId"]);

            // already submitted (for example a second click): just show the saved answers again
            if (GetSubmittedAttemptId(learnerId, "AssessmentId", assessmentId) > 0)
            {
                LoadAssessmentContent(assessmentId, learnerId);
                return;
            }

            // collect one answer per question
            List<KeyValuePair<int, string>> answers = new List<KeyValuePair<int, string>>();
            foreach (RepeaterItem item in rptAssessmentQuestions.Items)
            {
                HiddenField hfQuestionId = (HiddenField)item.FindControl("hfAsmQuestionId");
                HiddenField hfType = (HiddenField)item.FindControl("hfAsmQuestionType");
                int questionId = Convert.ToInt32(hfQuestionId.Value);
                string type = hfType.Value;
                string answer = "";

                if (type == "MCQ") answer = Request.Form[$"asm_q_{questionId}"];
                else if (type == "FillBlank") answer = ((TextBox)item.FindControl("txtAsmFill")).Text.Trim();
                else if (type == "Coding") answer = ((TextBox)item.FindControl("txtAsmCode")).Text.Trim();

                if (string.IsNullOrWhiteSpace(answer))
                {
                    lblCodeState.Visible = true;
                    lblCodeState.Text = "Please answer all assessment questions before submitting.";
                    lblCodeState.Style.Add("color", "#ef4444");
                    return;
                }

                answers.Add(new KeyValuePair<int, string>(questionId, answer));
            }

            if (answers.Count == 0)
            {
                lblCodeState.Visible = true;
                lblCodeState.Text = "Assessment question configuration missing.";
                lblCodeState.Style.Add("color", "#ef4444");
                return;
            }

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                SqlTransaction transaction = con.BeginTransaction();
                try
                {
                    string attemptQuery = "INSERT INTO Attempt (AttemptDate, AttemptStatus, LearnerId, AssessmentId) OUTPUT INSERTED.AttemptId VALUES (GETDATE(), 'completed', @LearnerId, @AssessmentId)";
                    int newAttemptId = 0;
                    using (SqlCommand cmd = new SqlCommand(attemptQuery, con, transaction))
                    {
                        cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                        cmd.Parameters.AddWithValue("@AssessmentId", assessmentId);
                        newAttemptId = (int)cmd.ExecuteScalar();
                    }

                    string ansQuery = "INSERT INTO AttemptAnswer (AttemptId, QuestionId, AnswerContent, IsCorrect, ObtainedScore, TeacherComment) VALUES (@AttemptId, @QuestionId, @AnswerContent, 'pending', 0, '')";
                    foreach (KeyValuePair<int, string> a in answers)
                    {
                        using (SqlCommand ansCmd = new SqlCommand(ansQuery, con, transaction))
                        {
                            ansCmd.Parameters.AddWithValue("@AttemptId", newAttemptId);
                            ansCmd.Parameters.AddWithValue("@QuestionId", a.Key);
                            ansCmd.Parameters.AddWithValue("@AnswerContent", a.Value);
                            ansCmd.ExecuteNonQuery();
                        }
                    }

                    transaction.Commit();

                    LoadAssessmentContent(assessmentId, learnerId);
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    lblCodeState.Visible = true;
                    lblCodeState.Text = "Error submitting assessment: " + ex.Message;
                    lblCodeState.Style.Add("color", "#ef4444");
                }
                finally
                {
                    con.Close();
                }
            }
        }

        private void LoadExamQuestions(int examId, int learnerId)
        {
            int attemptId = GetSubmittedAttemptId(learnerId, "ExamId", examId);

            if (attemptId > 0)
            {
                lblExamState.Visible = true;
                lblExamState.Text = "You have already submitted this exam. Awaiting grading.";
                lblExamState.Style.Add("color", "#4ade80");
                btnSubmitExam.Enabled = false;
                btnSubmitExam.Text = "Submitted";
                btnSubmitExam.CssClass = "btn-nav";
                phExamCheckmark.Visible = true;
            }

            rptExamQuestions.DataSource = LoadQuestionsWithAnswers("ExamId", examId, attemptId);
            rptExamQuestions.DataBind();
        }

        protected void rptExamQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var question = (ExamQuestion)e.Item.DataItem;
                if (question.Type == "MCQ")
                {
                    Repeater rptOptions = (Repeater)e.Item.FindControl("rptExamOptions");
                    if (rptOptions != null)
                    {
                        rptOptions.DataSource = question.Options;
                        rptOptions.DataBind();
                    }
                }
            }
        }

        protected void btnSubmitExam_Click(object sender, EventArgs e)
        {
            foreach (RepeaterItem item in rptExamQuestions.Items)
            {
                HiddenField hfQuestionId = (HiddenField)item.FindControl("hfExamQuestionId");
                HiddenField hfType = (HiddenField)item.FindControl("hfExamQuestionType");
                int questionId = Convert.ToInt32(hfQuestionId.Value);
                string type = hfType.Value;
                string checkAnswer = "";

                if (type == "MCQ")
                {
                    checkAnswer = Request.Form[$"exam_q_{questionId}"];
                }
                else if (type == "FillBlank")
                {
                    TextBox txt = (TextBox)item.FindControl("txtFillBlank");
                    checkAnswer = txt.Text.Trim();
                }
                else if (type == "Coding")
                {
                    TextBox txt = (TextBox)item.FindControl("txtExamCode");
                    checkAnswer = txt.Text.Trim();
                }

                if (string.IsNullOrEmpty(checkAnswer))
                {
                    lblExamState.Visible = true;
                    lblExamState.Text = "Please answer all exam questions before submitting.";
                    lblExamState.Style.Add("color", "#ef4444");
                    return;
                }
            }

            int learnerId = Convert.ToInt32(Session["UserId"]);
            int examId = Convert.ToInt32(ViewState["ExamId"]);

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                SqlTransaction transaction = con.BeginTransaction();
                try
                {
                    string attemptQuery = "INSERT INTO Attempt (AttemptDate, AttemptStatus, LearnerId, ExamId) OUTPUT INSERTED.AttemptId VALUES (GETDATE(), 'completed', @LearnerId, @ExamId)";
                    int newAttemptId = 0;
                    using (SqlCommand cmd = new SqlCommand(attemptQuery, con, transaction))
                    {
                        cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                        cmd.Parameters.AddWithValue("@ExamId", examId);
                        newAttemptId = (int)cmd.ExecuteScalar();
                    }

                    foreach (RepeaterItem item in rptExamQuestions.Items)
                    {
                        HiddenField hfQuestionId = (HiddenField)item.FindControl("hfExamQuestionId");
                        HiddenField hfType = (HiddenField)item.FindControl("hfExamQuestionType");
                        int questionId = Convert.ToInt32(hfQuestionId.Value);
                        string type = hfType.Value;
                        string submittedAnswer = "";

                        if (type == "MCQ")
                        {
                            submittedAnswer = Request.Form[$"exam_q_{questionId}"];
                        }
                        else if (type == "FillBlank")
                        {
                            TextBox txt = (TextBox)item.FindControl("txtFillBlank");
                            submittedAnswer = txt.Text.Trim();
                        }
                        else if (type == "Coding")
                        {
                            TextBox txt = (TextBox)item.FindControl("txtExamCode");
                            submittedAnswer = txt.Text.Trim();
                        }

                        string ansQuery = "INSERT INTO AttemptAnswer (AttemptId, QuestionId, AnswerContent, IsCorrect, ObtainedScore, TeacherComment) VALUES (@AttemptId, @QuestionId, @AnswerContent, 'pending', 0, '')";
                        using (SqlCommand ansCmd = new SqlCommand(ansQuery, con, transaction))
                        {
                            ansCmd.Parameters.AddWithValue("@AttemptId", newAttemptId);
                            ansCmd.Parameters.AddWithValue("@QuestionId", questionId);
                            ansCmd.Parameters.AddWithValue("@AnswerContent", submittedAnswer);
                            ansCmd.ExecuteNonQuery();
                        }
                    }

                    int courseId = Convert.ToInt32(ViewState["CourseId"]);
                    int totalChapters = Convert.ToInt32(ViewState["TotalChapters"]);
                    string progUpdate = "UPDATE LearnerProgress SET ChapNum = @CompletedChapNum WHERE LearnerId = @LearnerId AND CourseId = @CourseId";
                    using (SqlCommand progCmd = new SqlCommand(progUpdate, con, transaction))
                    {
                        progCmd.Parameters.AddWithValue("@CompletedChapNum", totalChapters + 2);
                        progCmd.Parameters.AddWithValue("@LearnerId", learnerId);
                        progCmd.Parameters.AddWithValue("@CourseId", courseId);
                        progCmd.ExecuteNonQuery();
                    }

                    transaction.Commit();

                    lblExamState.Visible = true;
                    lblExamState.Text = "Exam submitted successfully! Awaiting teacher grading.";
                    lblExamState.Style.Add("color", "#4ade80");
                    btnSubmitExam.Enabled = false;
                    btnSubmitExam.Text = "Submitted";
                    btnSubmitExam.CssClass = "btn-nav";

                    LoadExamQuestions(examId, learnerId);
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    lblExamState.Visible = true;
                    lblExamState.Text = "Error submitting exam: " + ex.Message;
                    lblExamState.Style.Add("color", "#ef4444");
                }
                finally
                {
                    con.Close();
                }
            }
        }

        protected void btnNext_Click(object sender, EventArgs e)
        {
            int courseId = Convert.ToInt32(ViewState["CourseId"]);
            int activeChapterNum = Convert.ToInt32(ViewState["ActiveChapterNum"]);
            int totalChapters = Convert.ToInt32(ViewState["TotalChapters"]);
            int learnerId = Convert.ToInt32(Session["UserId"]);

            using (SqlConnection con = new SqlConnection(connString))
            {
                int learnerProgress = 0;
                string checkQuery = "SELECT ChapNum FROM LearnerProgress WHERE LearnerId = @LearnerId AND CourseId = @CourseId";
                using (SqlCommand checkCmd = new SqlCommand(checkQuery, con))
                {
                    checkCmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    checkCmd.Parameters.AddWithValue("@CourseId", courseId);
                    con.Open();
                    object result = checkCmd.ExecuteScalar();
                    if (result != null && result != DBNull.Value) learnerProgress = Convert.ToInt32(result);
                    con.Close();
                }

                if (activeChapterNum == learnerProgress && learnerProgress <= totalChapters)
                {
                    bool canUnlock = true;

                    if (Convert.ToBoolean(ViewState["HasQuiz"]))
                    {
                        int quizId = Convert.ToInt32(ViewState["QuizId"]);
                        canUnlock = CheckActivityCompletion(learnerId, "QuizId", quizId);
                        if (!canUnlock)
                        {
                            ShowWarning("You must complete and submit the Quiz before proceeding to the next chapter.");
                            return;
                        }
                    }

                    if (Convert.ToBoolean(ViewState["HasAssessment"]))
                    {
                        int assessmentId = Convert.ToInt32(ViewState["AssessmentId"]);
                        canUnlock = CheckActivityCompletion(learnerId, "AssessmentId", assessmentId);
                        if (!canUnlock)
                        {
                            ShowWarning("You must complete and submit the Coding Assessment before proceeding to the next chapter.");
                            return;
                        }
                    }

                    if (canUnlock)
                    {
                        int newProgress = learnerProgress + 1;
                        string updateQuery = "UPDATE LearnerProgress SET ChapNum = @NewChap WHERE LearnerId = @LearnerId AND CourseId = @CourseId";
                        using (SqlCommand updateCmd = new SqlCommand(updateQuery, con))
                        {
                            updateCmd.Parameters.AddWithValue("@NewChap", newProgress);
                            updateCmd.Parameters.AddWithValue("@LearnerId", learnerId);
                            updateCmd.Parameters.AddWithValue("@CourseId", courseId);
                            con.Open();
                            updateCmd.ExecuteNonQuery();
                            con.Close();
                        }
                    }
                }
            }

            Response.Redirect($"CourseViewer.aspx?courseId={courseId}&ch={activeChapterNum + 1}");
        }

        private bool CheckActivityCompletion(int learnerId, string idColumn, int activityId)
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = $"SELECT COUNT(*) FROM Attempt WHERE LearnerId = @LearnerId AND {idColumn} = @ActivityId AND AttemptStatus IN ('completed', 'graded')";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    cmd.Parameters.AddWithValue("@ActivityId", activityId);
                    con.Open();
                    int count = Convert.ToInt32(cmd.ExecuteScalar());
                    con.Close();
                    return count > 0;
                }
            }
        }

        private void ShowWarning(string message)
        {
            pnlWarning.Visible = true;
            litWarningMsg.Text = message;
        }
    }
}