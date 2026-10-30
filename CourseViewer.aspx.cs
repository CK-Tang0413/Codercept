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
                Response.Redirect("signIn.aspx");
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

                // Check if this course has a Final Exam configured
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

                // Load Sidebar
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

                // Add Exam to Sidebar if it exists
                if (hasExam)
                {
                    int examChapNum = totalChapters + 1;
                    string examStatus = "locked";

                    // If they have completed the exam, their progress might exceed examChapNum, or attempt is graded
                    if (learnerProgress > examChapNum) examStatus = "completed";
                    else if (learnerProgress == examChapNum) examStatus = "pending";

                    // Check actual Attempt status to mark as completed even if progress maxes out
                    string checkExamAttempt = "SELECT AttemptStatus FROM Attempt WHERE LearnerId = @LearnerId AND ExamId = @ExamId";
                    using (SqlCommand cmd = new SqlCommand(checkExamAttempt, con))
                    {
                        cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                        cmd.Parameters.AddWithValue("@ExamId", examId);
                        con.Open();
                        object res = cmd.ExecuteScalar();
                        if (res != null && (res.ToString() == "completed" || res.ToString() == "graded"))
                        {
                            examStatus = "completed";
                        }
                        con.Close();
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

                // Load Right Panel Content (Standard Chapter vs Exam)
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
                                    if (mediaLink.EndsWith(".mp4") || mediaLink.EndsWith(".webm") || mediaLink.Contains("youtube"))
                                    {
                                        litMediaHtml.Text = $@"
                                        <div class='video-container' style=""background-image: url('{mediaLink}.jpg'); background-size: cover; background-position: center;"">
                                            <div class='play-btn'>
                                                <svg width='24' height='24' fill='currentColor' viewBox='0 0 16 16'><path d='M10.804 8 5 4.633v6.734L10.804 8zm.792-.696a.802.802 0 0 1 0 1.392l-6.363 3.692C4.713 12.69 4 12.345 4 11.692V4.308c0-.653.713-.998 1.233-.696l6.363 3.692z'/></svg>
                                            </div>
                                            <h3 style='color: white; margin-bottom: 0.5rem;'>Lecture Video</h3>
                                        </div>";
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
                    // WE ARE ON THE FINAL EXAM PAGE
                    pnlNormalChapter.Visible = false;
                    pnlExamContent.Visible = true;

                    litExamTitle.Text = examTitle;
                    litExamDesc.Text = examDesc;
                    LoadExamQuestions(examId, learnerId);
                }

                // Setup Navigation Bottom Links
                litStepIndicator.Text = $"{activeChapterNum} / {maxAllowedChapter}";
                lnkPrev.NavigateUrl = $"CourseViewer.aspx?courseId={courseId}&ch={activeChapterNum - 1}";
                lnkPrev.Visible = activeChapterNum > 1;

                if (activeChapterNum < learnerProgress) litNextText.Text = "Next";
                else litNextText.Text = "Mark Complete & Continue";

                // Hide Next button if we are on the very last available section (Exam or final chapter)
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

        // ========================================================
        // 1. QUIZ SUBMISSION LOGIC (Normal Chapter)
        // ========================================================
        private void LoadQuizQuestions(int quizId, int learnerId)
        {
            List<ExamQuestion> questions = new List<ExamQuestion>();
            bool isAlreadySubmitted = false;

            using (SqlConnection con = new SqlConnection(connString))
            {
                string checkQuery = "SELECT AttemptId, AttemptStatus FROM Attempt WHERE LearnerId = @LearnerId AND QuizId = @QuizId";
                int existingAttemptId = 0;
                using (SqlCommand checkCmd = new SqlCommand(checkQuery, con))
                {
                    checkCmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    checkCmd.Parameters.AddWithValue("@QuizId", quizId);
                    con.Open();
                    using (SqlDataReader reader = checkCmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            existingAttemptId = Convert.ToInt32(reader["AttemptId"]);
                            string status = reader["AttemptStatus"].ToString();
                            isAlreadySubmitted = (status == "completed" || status == "graded");
                        }
                    }
                    con.Close();
                }

                if (isAlreadySubmitted)
                {
                    lblQuizState.Visible = true;
                    lblQuizState.Text = "You have already submitted this quiz.";
                    lblQuizState.Style.Add("color", "#4ade80");
                    btnSubmitQuiz.Enabled = false;
                    btnSubmitQuiz.Text = "Submitted";
                    btnSubmitQuiz.CssClass = "btn-nav";
                }

                string qQuery = "SELECT QuestionId, QuestionContent FROM Question WHERE QuizId = @QuizId ORDER BY QuestionOrder ASC";
                using (SqlCommand cmd = new SqlCommand(qQuery, con))
                {
                    cmd.Parameters.AddWithValue("@QuizId", quizId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int questionId = Convert.ToInt32(reader["QuestionId"]);
                            ExamQuestion q = new ExamQuestion
                            {
                                QuestionId = questionId,
                                Title = $"Q. {reader["QuestionContent"]}",
                                Options = new List<QuizOption>()
                            };

                            string submittedOptionId = "";
                            if (isAlreadySubmitted && existingAttemptId > 0)
                            {
                                using (SqlConnection ansCon = new SqlConnection(connString))
                                {
                                    string ansQuery = "SELECT AnswerContent FROM AttemptAnswer WHERE AttemptId = @AttemptId AND QuestionId = @QuestionId";
                                    using (SqlCommand ansCmd = new SqlCommand(ansQuery, ansCon))
                                    {
                                        ansCmd.Parameters.AddWithValue("@AttemptId", existingAttemptId);
                                        ansCmd.Parameters.AddWithValue("@QuestionId", questionId);
                                        ansCon.Open();
                                        object res = ansCmd.ExecuteScalar();
                                        if (res != null) submittedOptionId = res.ToString();
                                        ansCon.Close();
                                    }
                                }
                            }
                            q.SelectedAnswer = submittedOptionId;

                            using (SqlConnection con2 = new SqlConnection(connString))
                            {
                                string optQuery = "SELECT MCQ_OptionId, OptionContent FROM MCQ_Option WHERE QuestionId = @QuestionId ORDER BY OptionOrder ASC";
                                using (SqlCommand optCmd = new SqlCommand(optQuery, con2))
                                {
                                    optCmd.Parameters.AddWithValue("@QuestionId", questionId);
                                    con2.Open();
                                    using (SqlDataReader optReader = optCmd.ExecuteReader())
                                    {
                                        while (optReader.Read())
                                        {
                                            int optId = Convert.ToInt32(optReader["MCQ_OptionId"]);
                                            q.Options.Add(new QuizOption
                                            {
                                                OptionId = optId,
                                                QuestionId = questionId,
                                                OptionContent = optReader["OptionContent"].ToString(),
                                                IsSelected = (optId.ToString() == submittedOptionId),
                                                IsLocked = isAlreadySubmitted
                                            });
                                        }
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
                        if (string.IsNullOrEmpty(submittedOptionId)) submittedOptionId = "0";

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

        // ========================================================
        // 2. ASSESSMENT SUBMISSION LOGIC (Normal Chapter)
        // ========================================================
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

                string checkQuery = "SELECT AttemptId, AttemptStatus FROM Attempt WHERE LearnerId = @LearnerId AND AssessmentId = @AssessmentId";
                int existingAttemptId = 0;
                bool isAlreadySubmitted = false;

                using (SqlCommand checkCmd = new SqlCommand(checkQuery, con))
                {
                    checkCmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    checkCmd.Parameters.AddWithValue("@AssessmentId", assessmentId);
                    con.Open();
                    using (SqlDataReader reader = checkCmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            existingAttemptId = Convert.ToInt32(reader["AttemptId"]);
                            string status = reader["AttemptStatus"].ToString();
                            isAlreadySubmitted = (status == "completed" || status == "graded");
                        }
                    }
                    con.Close();
                }

                if (isAlreadySubmitted && existingAttemptId > 0)
                {
                    lblCodeState.Visible = true;
                    lblCodeState.Text = "You have already submitted this assessment.";
                    lblCodeState.Style.Add("color", "#4ade80");
                    btnSubmitAssessment.Enabled = false;
                    btnSubmitAssessment.Text = "Submitted";
                    btnSubmitAssessment.CssClass = "btn-nav";
                    txtCodeEditor.Enabled = false;

                    string getAnsQuery = "SELECT TOP 1 AnswerContent FROM AttemptAnswer WHERE AttemptId = @AttemptId";
                    using (SqlCommand ansCmd = new SqlCommand(getAnsQuery, con))
                    {
                        ansCmd.Parameters.AddWithValue("@AttemptId", existingAttemptId);
                        con.Open();
                        object res = ansCmd.ExecuteScalar();
                        if (res != null) txtCodeEditor.Text = res.ToString();
                        con.Close();
                    }
                }
            }
        }

        protected void btnSubmitAssessment_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtCodeEditor.Text))
            {
                lblCodeState.Visible = true;
                lblCodeState.Text = "Cannot submit an empty code block.";
                lblCodeState.Style.Add("color", "#ef4444");
                return;
            }

            int learnerId = Convert.ToInt32(Session["UserId"]);
            int assessmentId = Convert.ToInt32(ViewState["AssessmentId"]);

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                SqlTransaction transaction = con.BeginTransaction();
                try
                {
                    int questionId = 0;
                    string qQuery = "SELECT TOP 1 QuestionId FROM Question WHERE AssessmentId = @AssessmentId";
                    using (SqlCommand qCmd = new SqlCommand(qQuery, con, transaction))
                    {
                        qCmd.Parameters.AddWithValue("@AssessmentId", assessmentId);
                        object res = qCmd.ExecuteScalar();
                        if (res != null) questionId = Convert.ToInt32(res);
                    }

                    if (questionId == 0) throw new Exception("Assessment question configuration missing.");

                    string attemptQuery = "INSERT INTO Attempt (AttemptDate, AttemptStatus, LearnerId, AssessmentId) OUTPUT INSERTED.AttemptId VALUES (GETDATE(), 'completed', @LearnerId, @AssessmentId)";
                    int newAttemptId = 0;
                    using (SqlCommand cmd = new SqlCommand(attemptQuery, con, transaction))
                    {
                        cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                        cmd.Parameters.AddWithValue("@AssessmentId", assessmentId);
                        newAttemptId = (int)cmd.ExecuteScalar();
                    }

                    string ansQuery = "INSERT INTO AttemptAnswer (AttemptId, QuestionId, AnswerContent, IsCorrect, ObtainedScore, TeacherComment) VALUES (@AttemptId, @QuestionId, @AnswerContent, 'pending', 0, '')";
                    using (SqlCommand ansCmd = new SqlCommand(ansQuery, con, transaction))
                    {
                        ansCmd.Parameters.AddWithValue("@AttemptId", newAttemptId);
                        ansCmd.Parameters.AddWithValue("@QuestionId", questionId);
                        ansCmd.Parameters.AddWithValue("@AnswerContent", txtCodeEditor.Text.Trim());
                        ansCmd.ExecuteNonQuery();
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

        // ========================================================
        // 3. FINAL EXAM LOAD & SUBMISSION LOGIC
        // ========================================================
        private void LoadExamQuestions(int examId, int learnerId)
        {
            List<ExamQuestion> questions = new List<ExamQuestion>();
            bool isAlreadySubmitted = false;
            int existingAttemptId = 0;

            using (SqlConnection con = new SqlConnection(connString))
            {
                string checkQuery = "SELECT AttemptId, AttemptStatus FROM Attempt WHERE LearnerId = @LearnerId AND ExamId = @ExamId";
                using (SqlCommand checkCmd = new SqlCommand(checkQuery, con))
                {
                    checkCmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    checkCmd.Parameters.AddWithValue("@ExamId", examId);
                    con.Open();
                    using (SqlDataReader reader = checkCmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            existingAttemptId = Convert.ToInt32(reader["AttemptId"]);
                            string status = reader["AttemptStatus"].ToString();
                            isAlreadySubmitted = (status == "completed" || status == "graded");
                        }
                    }
                    con.Close();
                }

                if (isAlreadySubmitted)
                {
                    lblExamState.Visible = true;
                    lblExamState.Text = "You have already submitted this exam. Awaiting grading.";
                    lblExamState.Style.Add("color", "#4ade80");
                    btnSubmitExam.Enabled = false;
                    btnSubmitExam.Text = "Submitted";
                    btnSubmitExam.CssClass = "btn-nav";
                    phExamCheckmark.Visible = true; // Show completion badge
                }

                string qQuery = "SELECT QuestionId, QuestionContent, QuestionType FROM Question WHERE ExamId = @ExamId ORDER BY QuestionOrder ASC";
                using (SqlCommand cmd = new SqlCommand(qQuery, con))
                {
                    cmd.Parameters.AddWithValue("@ExamId", examId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int qId = Convert.ToInt32(reader["QuestionId"]);
                            string type = reader["QuestionType"].ToString();

                            ExamQuestion q = new ExamQuestion
                            {
                                QuestionId = qId,
                                Title = $"Q. {reader["QuestionContent"]}",
                                Type = type,
                                IsLocked = isAlreadySubmitted,
                                Options = new List<QuizOption>()
                            };

                            // Fetch previous answer if submitted
                            string submittedAnswer = "";
                            if (isAlreadySubmitted && existingAttemptId > 0)
                            {
                                using (SqlConnection ansCon = new SqlConnection(connString))
                                {
                                    string ansQuery = "SELECT AnswerContent FROM AttemptAnswer WHERE AttemptId = @AttemptId AND QuestionId = @QuestionId";
                                    using (SqlCommand ansCmd = new SqlCommand(ansQuery, ansCon))
                                    {
                                        ansCmd.Parameters.AddWithValue("@AttemptId", existingAttemptId);
                                        ansCmd.Parameters.AddWithValue("@QuestionId", qId);
                                        ansCon.Open();
                                        object res = ansCmd.ExecuteScalar();
                                        if (res != null) submittedAnswer = res.ToString();
                                        ansCon.Close();
                                    }
                                }
                            }
                            q.SelectedAnswer = submittedAnswer;

                            // If MCQ, load options
                            if (type == "MCQ")
                            {
                                using (SqlConnection con2 = new SqlConnection(connString))
                                {
                                    string optQuery = "SELECT MCQ_OptionId, OptionContent FROM MCQ_Option WHERE QuestionId = @QuestionId ORDER BY OptionOrder ASC";
                                    using (SqlCommand optCmd = new SqlCommand(optQuery, con2))
                                    {
                                        optCmd.Parameters.AddWithValue("@QuestionId", qId);
                                        con2.Open();
                                        using (SqlDataReader optReader = optCmd.ExecuteReader())
                                        {
                                            while (optReader.Read())
                                            {
                                                int optId = Convert.ToInt32(optReader["MCQ_OptionId"]);
                                                q.Options.Add(new QuizOption
                                                {
                                                    OptionId = optId,
                                                    QuestionId = qId,
                                                    OptionContent = optReader["OptionContent"].ToString(),
                                                    IsSelected = (optId.ToString() == submittedAnswer),
                                                    IsLocked = isAlreadySubmitted
                                                });
                                            }
                                        }
                                        con2.Close();
                                    }
                                }
                            }
                            questions.Add(q);
                        }
                    }
                    con.Close();
                }
            }

            rptExamQuestions.DataSource = questions;
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
                            if (string.IsNullOrEmpty(submittedAnswer)) submittedAnswer = "0";
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

                    // Advance LearnerProgress past the exam (TotalChapters + 2) so the course is officially marked 100% complete
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

        // ========================================================
        // 4. PROGRESS VALIDATION
        // ========================================================
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