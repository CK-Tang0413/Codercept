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

        /// <summary>
        /// The learner's newest attempt at one quiz, assessment or exam (ownerColumn is QuizId, AssessmentId or ExamId): its id, or 0 when there is none,
        /// and whether it was submitted. A learner can have more than one attempt row for the same test (older sample data, a repeated post), and
        /// reading "the first row" showed an older attempt's answers, so the newest one is always chosen.
        /// </summary>
        private int FindLatestAttempt(string ownerColumn, int ownerId, int learnerId, out bool submitted)
        {
            submitted = false;
            if (ownerColumn != "QuizId" && ownerColumn != "AssessmentId" && ownerColumn != "ExamId") return 0;
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT TOP 1 AttemptId, AttemptStatus FROM Attempt WHERE LearnerId = @LearnerId AND " + ownerColumn + " = @OwnerId " +
                "ORDER BY AttemptDate DESC, AttemptId DESC", con))
            {
                cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                cmd.Parameters.AddWithValue("@OwnerId", ownerId);
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (!reader.Read()) return 0;
                    string status = reader["AttemptStatus"].ToString();
                    submitted = (status == "completed" || status == "graded");
                    return Convert.ToInt32(reader["AttemptId"]);
                }
            }
        }

        /// <summary>What the learner answered in one attempt, by QuestionId: the option id of a multiple-choice question, the text of the others.</summary>
        private Dictionary<int, string> LoadAttemptAnswers(int attemptId)
        {
            Dictionary<int, string> answers = new Dictionary<int, string>();
            if (attemptId <= 0) return answers;
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("SELECT QuestionId, AnswerContent FROM AttemptAnswer WHERE AttemptId = @AttemptId", con))
            {
                cmd.Parameters.AddWithValue("@AttemptId", attemptId);
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read()) answers[Convert.ToInt32(reader["QuestionId"])] = reader["AnswerContent"] == DBNull.Value ? "" : reader["AnswerContent"].ToString();
                }
            }
            return answers;
        }

        /// <summary>True when the stored answer of a multiple-choice question is this option (its id, or, for older data, its text).</summary>
        private static bool IsChosenOption(int optionId, string optionContent, string answer)
        {
            if (string.IsNullOrWhiteSpace(answer)) return false;
            answer = answer.Trim();
            return answer == optionId.ToString() || string.Equals(answer, (optionContent ?? "").Trim(), StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>
        /// The questions of a quiz, assessment or exam in order, with the options of each multiple-choice question. When the learner has already
        /// submitted it, the newest attempt's answers are filled in (the chosen option, the typed text) and every input is locked.
        /// </summary>
        private List<ExamQuestion> BuildQuestions(string ownerColumn, int ownerId, int learnerId, out bool submitted)
        {
            int attemptId = FindLatestAttempt(ownerColumn, ownerId, learnerId, out submitted);
            Dictionary<int, string> answers = submitted ? LoadAttemptAnswers(attemptId) : new Dictionary<int, string>();

            List<ExamQuestion> questions = new List<ExamQuestion>();
            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT QuestionId, QuestionContent, QuestionType FROM Question WHERE " + ownerColumn + " = @OwnerId ORDER BY QuestionOrder ASC, QuestionId ASC", con))
                {
                    cmd.Parameters.AddWithValue("@OwnerId", ownerId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int questionId = Convert.ToInt32(reader["QuestionId"]);
                            string given;
                            answers.TryGetValue(questionId, out given);
                            questions.Add(new ExamQuestion
                            {
                                QuestionId = questionId,
                                Title = $"Q. {reader["QuestionContent"]}",
                                Type = reader["QuestionType"].ToString(),
                                SelectedAnswer = given ?? "",
                                IsLocked = submitted,
                                Options = new List<QuizOption>()
                            });
                        }
                    }
                }

                foreach (ExamQuestion q in questions.Where(x => x.Type == "MCQ"))
                {
                    using (SqlCommand optCmd = new SqlCommand("SELECT MCQ_OptionId, OptionContent FROM MCQ_Option WHERE QuestionId = @QuestionId ORDER BY OptionOrder ASC, MCQ_OptionId ASC", con))
                    {
                        optCmd.Parameters.AddWithValue("@QuestionId", q.QuestionId);
                        using (SqlDataReader optReader = optCmd.ExecuteReader())
                        {
                            while (optReader.Read())
                            {
                                int optId = Convert.ToInt32(optReader["MCQ_OptionId"]);
                                string content = optReader["OptionContent"].ToString();
                                q.Options.Add(new QuizOption
                                {
                                    OptionId = optId,
                                    QuestionId = q.QuestionId,
                                    OptionContent = content,
                                    IsSelected = IsChosenOption(optId, content, q.SelectedAnswer),
                                    IsLocked = submitted
                                });
                            }
                        }
                    }
                }
            }
            return questions;
        }

        /// <summary>The answer the form holds for one question of a quiz, assessment or exam ("" when unanswered). prefix is quiz_q_, asm_q_ or exam_q_ for multiple choice.</summary>
        private static string ReadAnswer(RepeaterItem item, string prefix, string questionIdField, string typeField, string fillField, string codeField, out int questionId)
        {
            questionId = Convert.ToInt32(((HiddenField)item.FindControl(questionIdField)).Value);
            string type = typeField == null ? "MCQ" : ((HiddenField)item.FindControl(typeField)).Value;
            if (type == "MCQ") return (System.Web.HttpContext.Current.Request.Form[prefix + questionId] ?? "").Trim();
            TextBox box = (TextBox)item.FindControl(type == "FillBlank" ? fillField : codeField);
            return box == null ? "" : box.Text.Trim();
        }

        /// <summary>Saves one submission (attempt + one answer per question) in a single transaction. Returns false, with nothing saved, when the learner already submitted it.</summary>
        private bool SaveSubmission(string ownerColumn, int ownerId, int learnerId, Dictionary<int, string> answers, string extraSql, params SqlParameter[] extraParameters)
        {
            bool alreadySubmitted;
            if (FindLatestAttempt(ownerColumn, ownerId, learnerId, out alreadySubmitted) > 0 && alreadySubmitted) return false;

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                SqlTransaction transaction = con.BeginTransaction();
                try
                {
                    int newAttemptId;
                    using (SqlCommand cmd = new SqlCommand(
                        "INSERT INTO Attempt (AttemptDate, AttemptStatus, LearnerId, " + ownerColumn + ") OUTPUT INSERTED.AttemptId VALUES (GETDATE(), 'completed', @LearnerId, @OwnerId)", con, transaction))
                    {
                        cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                        cmd.Parameters.AddWithValue("@OwnerId", ownerId);
                        newAttemptId = (int)cmd.ExecuteScalar();
                    }

                    foreach (KeyValuePair<int, string> answer in answers)
                    {
                        using (SqlCommand ansCmd = new SqlCommand(
                            "INSERT INTO AttemptAnswer (AttemptId, QuestionId, AnswerContent, IsCorrect, ObtainedScore, TeacherComment) VALUES (@AttemptId, @QuestionId, @AnswerContent, 'pending', 0, '')", con, transaction))
                        {
                            ansCmd.Parameters.AddWithValue("@AttemptId", newAttemptId);
                            ansCmd.Parameters.AddWithValue("@QuestionId", answer.Key);
                            ansCmd.Parameters.AddWithValue("@AnswerContent", answer.Value);
                            ansCmd.ExecuteNonQuery();
                        }
                    }

                    if (!string.IsNullOrEmpty(extraSql))
                    {
                        using (SqlCommand extra = new SqlCommand(extraSql, con, transaction))
                        {
                            extra.Parameters.AddRange(extraParameters);
                            extra.ExecuteNonQuery();
                        }
                    }

                    transaction.Commit();
                    return true;
                }
                catch
                {
                    transaction.Rollback();
                    throw;
                }
            }
        }

        private void LoadQuizQuestions(int quizId, int learnerId)
        {
            bool isAlreadySubmitted;
            List<ExamQuestion> questions = BuildQuestions("QuizId", quizId, learnerId, out isAlreadySubmitted);

            if (isAlreadySubmitted)
            {
                lblQuizState.Visible = true;
                lblQuizState.Text = "You have already submitted this quiz.";
                lblQuizState.Style.Add("color", "#4ade80");
                btnSubmitQuiz.Enabled = false;
                btnSubmitQuiz.Text = "Submitted";
                btnSubmitQuiz.CssClass = "btn-nav";
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
            Dictionary<int, string> answers = new Dictionary<int, string>();
            foreach (RepeaterItem item in rptQuizQuestions.Items)
            {
                int questionId;
                string answer = ReadAnswer(item, "quiz_q_", "hfQuestionId", null, null, null, out questionId);
                if (string.IsNullOrEmpty(answer))
                {
                    lblQuizState.Visible = true;
                    lblQuizState.Text = "Please answer all questions before submitting.";
                    lblQuizState.Style.Add("color", "#ef4444");
                    return;
                }
                answers[questionId] = answer;
            }

            int learnerId = Convert.ToInt32(Session["UserId"]);
            int quizId = Convert.ToInt32(ViewState["QuizId"]);

            try
            {
                if (!SaveSubmission("QuizId", quizId, learnerId, answers, null))
                {
                    lblQuizState.Visible = true;
                    lblQuizState.Text = "You have already submitted this quiz.";
                    lblQuizState.Style.Add("color", "#4ade80");
                }
                else
                {
                    lblQuizState.Visible = true;
                    lblQuizState.Text = "Quiz submitted successfully!";
                    lblQuizState.Style.Add("color", "#4ade80");
                }
                LoadQuizQuestions(quizId, learnerId);
            }
            catch (Exception ex)
            {
                lblQuizState.Visible = true;
                lblQuizState.Text = "Error submitting quiz: " + ex.Message;
                lblQuizState.Style.Add("color", "#ef4444");
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

            // every question of the assessment (multiple choice, fill in the blank and coding), with the newest attempt's answers once submitted
            bool isAlreadySubmitted;
            List<ExamQuestion> questions = BuildQuestions("AssessmentId", assessmentId, learnerId, out isAlreadySubmitted);

            if (isAlreadySubmitted)
            {
                lblCodeState.Visible = true;
                lblCodeState.Text = "You have already submitted this assessment.";
                lblCodeState.Style.Add("color", "#4ade80");
                btnSubmitAssessment.Enabled = false;
                btnSubmitAssessment.Text = "Submitted";
                btnSubmitAssessment.CssClass = "btn-nav";
            }

            rptAssessmentQuestions.DataSource = questions;
            rptAssessmentQuestions.DataBind();
        }

        protected void rptAssessmentQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var question = (ExamQuestion)e.Item.DataItem;
                if (question.Type == "MCQ")
                {
                    Repeater rptOptions = (Repeater)e.Item.FindControl("rptAssessmentOptions");
                    if (rptOptions != null)
                    {
                        rptOptions.DataSource = question.Options;
                        rptOptions.DataBind();
                    }
                }
            }
        }

        protected void btnSubmitAssessment_Click(object sender, EventArgs e)
        {
            Dictionary<int, string> answers = new Dictionary<int, string>();
            foreach (RepeaterItem item in rptAssessmentQuestions.Items)
            {
                int questionId;
                string answer = ReadAnswer(item, "asm_q_", "hfAsmQuestionId", "hfAsmQuestionType", "txtAsmFill", "txtAsmCode", out questionId);
                if (string.IsNullOrEmpty(answer))
                {
                    lblCodeState.Visible = true;
                    lblCodeState.Text = "Please answer all questions before submitting.";
                    lblCodeState.Style.Add("color", "#ef4444");
                    return;
                }
                answers[questionId] = answer;
            }

            int learnerId = Convert.ToInt32(Session["UserId"]);
            int assessmentId = Convert.ToInt32(ViewState["AssessmentId"]);

            try
            {
                if (answers.Count == 0) throw new Exception("Assessment question configuration missing.");

                if (!SaveSubmission("AssessmentId", assessmentId, learnerId, answers, null))
                {
                    lblCodeState.Visible = true;
                    lblCodeState.Text = "You have already submitted this assessment.";
                    lblCodeState.Style.Add("color", "#4ade80");
                }
                LoadAssessmentContent(assessmentId, learnerId);
            }
            catch (Exception ex)
            {
                lblCodeState.Visible = true;
                lblCodeState.Text = "Error submitting assessment: " + ex.Message;
                lblCodeState.Style.Add("color", "#ef4444");
            }
        }

        private void LoadExamQuestions(int examId, int learnerId)
        {
            bool isAlreadySubmitted;
            List<ExamQuestion> questions = BuildQuestions("ExamId", examId, learnerId, out isAlreadySubmitted);

            if (isAlreadySubmitted)
            {
                lblExamState.Visible = true;
                lblExamState.Text = "You have already submitted this exam. Awaiting grading.";
                lblExamState.Style.Add("color", "#4ade80");
                btnSubmitExam.Enabled = false;
                btnSubmitExam.Text = "Submitted";
                btnSubmitExam.CssClass = "btn-nav";
                phExamCheckmark.Visible = true;
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
            Dictionary<int, string> answers = new Dictionary<int, string>();
            foreach (RepeaterItem item in rptExamQuestions.Items)
            {
                int questionId;
                string answer = ReadAnswer(item, "exam_q_", "hfExamQuestionId", "hfExamQuestionType", "txtFillBlank", "txtExamCode", out questionId);
                if (string.IsNullOrEmpty(answer))
                {
                    lblExamState.Visible = true;
                    lblExamState.Text = "Please answer all exam questions before submitting.";
                    lblExamState.Style.Add("color", "#ef4444");
                    return;
                }
                answers[questionId] = answer;
            }

            int learnerId = Convert.ToInt32(Session["UserId"]);
            int examId = Convert.ToInt32(ViewState["ExamId"]);
            int courseId = Convert.ToInt32(ViewState["CourseId"]);
            int totalChapters = Convert.ToInt32(ViewState["TotalChapters"]);

            try
            {
                // the learner's progress moves past the exam in the same transaction as the attempt
                bool saved = SaveSubmission("ExamId", examId, learnerId, answers,
                    "UPDATE LearnerProgress SET ChapNum = @CompletedChapNum WHERE LearnerId = @LearnerId AND CourseId = @CourseId",
                    new SqlParameter("@CompletedChapNum", totalChapters + 2), new SqlParameter("@LearnerId", learnerId), new SqlParameter("@CourseId", courseId));

                lblExamState.Visible = true;
                lblExamState.Text = saved ? "Exam submitted successfully! Awaiting teacher grading." : "You have already submitted this exam. Awaiting grading.";
                lblExamState.Style.Add("color", "#4ade80");
                LoadExamQuestions(examId, learnerId);
            }
            catch (Exception ex)
            {
                lblExamState.Visible = true;
                lblExamState.Text = "Error submitting exam: " + ex.Message;
                lblExamState.Style.Add("color", "#ef4444");
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