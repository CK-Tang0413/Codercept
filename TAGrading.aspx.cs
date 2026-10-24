using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class TAGrading : System.Web.UI.Page
    {
        // Workflow: Pending -> In Progress (draft saved) -> Reviewed (awaiting teacher)
        //           -> Approved (official grade, visible to learner)

        // 1. Define Data Structures
        public class Submission
        {
            public int AttemptId { get; set; }
            public string LearnerName { get; set; }
            public string Title { get; set; }
            public string Type { get; set; }
            public string Course { get; set; }
            public int CourseId { get; set; }
            public int ChapterNum { get; set; }
            public string Submitted { get; set; }
            public string Status { get; set; }
            public string StatusCss { get; set; }
            public string ProgressNotes { get; set; }
            public string CssClass { get; set; }
        }

        public class Question
        {
            public int QuestionId { get; set; }
            public int Number { get; set; }
            public string Content { get; set; }
            public string TypeLabel { get; set; }
            public string Answer { get; set; }
            public string AnswerHtml { get; set; }
            public bool IsCode { get; set; }
            public bool AutoGraded { get; set; }
            public bool Locked { get; set; }      // whole submission is read-only
            public bool ScoreLocked { get; set; } // auto-graded or read-only
            public double MaxScore { get; set; }
            public double ScoreValue { get; set; }
            public string Score { get { return ScoreValue.ToString("0.##", CultureInfo.InvariantCulture); } }
            public string Comment { get; set; }
        }

        private readonly string connString = TAHelpers.ConnectionString;

        protected string CurrentFilter { get; private set; } = "all";

        private int TaId { get { return Convert.ToInt32(Session["UserId"]); } }

        protected void Page_Load(object sender, EventArgs e)
        {
            string filter = (Request.QueryString["filter"] ?? "all").ToLower();
            if (filter == "todo") filter = "pending"; // old links
            CurrentFilter = (filter == "pending" || filter == "reviewed" || filter == "approved") ? filter : "all";

            if (!IsPostBack)
            {
                LoadGradingData();
            }
        }

        protected string GetTabClass(string tab)
        {
            return tab == CurrentFilter ? "active" : "";
        }

        private static bool IsPending(Submission s)
        {
            return s.Status == GradingStatus.Pending || s.Status == GradingStatus.InProgress;
        }

        private static bool IsLocked(string status)
        {
            return status == GradingStatus.Reviewed || status == GradingStatus.Approved;
        }

        // ---------- Data access ----------

        // Everything this TA may see: submitted attempts nobody has claimed, plus their own work (any status).
        private List<Submission> GetVisibleSubmissions()
        {
            const string query = @"
                SELECT
                    a.AttemptId,
                    l.Name AS LearnerName,
                    a.AttemptDate,
                    COALESCE(q.QuizTitle, asm.AssessmentTitle, ex.ExamTitle) AS Title,
                    CASE WHEN a.QuizId IS NOT NULL THEN 'Quiz' WHEN a.AssessmentId IS NOT NULL THEN 'Assessment' ELSE 'Exam' END AS Type,
                    c.CourseId, c.CourseTitle, ch.ChapterNum,
                    COALESCE(gp.ProgressStatus, 'Pending') AS Status,
                    gp.ProgressNotes
                FROM [dbo].[Attempt] a
                INNER JOIN [dbo].[Learner] l ON l.LearnerId = a.LearnerId
                LEFT JOIN [dbo].[Quiz] q ON q.QuizId = a.QuizId
                LEFT JOIN [dbo].[SubChapter] sc ON sc.SubChapterId = q.SubChapterId
                LEFT JOIN [dbo].[Assessment] asm ON asm.AssessmentId = a.AssessmentId
                LEFT JOIN [dbo].[Exam] ex ON ex.ExamId = a.ExamId
                LEFT JOIN [dbo].[Chapter] ch ON ch.ChapterId = COALESCE(sc.ChapterId, asm.ChapterId, ex.ChapterId)
                LEFT JOIN [dbo].[Course] c ON c.CourseId = ch.CourseId
                LEFT JOIN [dbo].[GradingProgress] gp ON gp.AttemptId = a.AttemptId
                WHERE (a.AttemptStatus = 'Submitted' AND (gp.GradingProgId IS NULL OR gp.TA_Id = @TA_Id))
                   OR (a.AttemptStatus = 'Graded' AND gp.TA_Id = @TA_Id)
                ORDER BY CASE WHEN a.AttemptStatus = 'Graded' THEN 1 ELSE 0 END,
                         a.AttemptDate ASC";

            var list = new List<Submission>();

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@TA_Id", TaId);
                con.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string status = reader["Status"].ToString();

                        list.Add(new Submission
                        {
                            AttemptId = Convert.ToInt32(reader["AttemptId"]),
                            LearnerName = reader["LearnerName"].ToString(),
                            Title = reader["Title"].ToString(),
                            Type = reader["Type"].ToString(),
                            Course = reader["CourseTitle"] != DBNull.Value ? reader["CourseTitle"].ToString() : "",
                            CourseId = reader["CourseId"] != DBNull.Value ? Convert.ToInt32(reader["CourseId"]) : 0,
                            ChapterNum = reader["ChapterNum"] != DBNull.Value ? Convert.ToInt32(Convert.ToDouble(reader["ChapterNum"])) : 0,
                            Submitted = TAHelpers.TimeAgo(Convert.ToDateTime(reader["AttemptDate"])),
                            Status = status,
                            StatusCss = TAHelpers.GetStatusCss(status),
                            ProgressNotes = reader["ProgressNotes"] != DBNull.Value ? reader["ProgressNotes"].ToString() : ""
                        });
                    }
                }
            }

            return list;
        }

        private List<Question> GetQuestions(int attemptId, bool locked)
        {
            const string query = @"
                SELECT qn.QuestionId, qn.QuestionContent, qn.QuestionType, qn.QuestionScore,
                       aa.AnswerContent, aa.ObtainedScore, aa.TeacherComment
                FROM [dbo].[Attempt] a
                INNER JOIN [dbo].[Question] qn
                    ON qn.QuizId = a.QuizId OR qn.AssessmentId = a.AssessmentId OR qn.ExamId = a.ExamId
                LEFT JOIN [dbo].[AttemptAnswer] aa ON aa.AttemptId = a.AttemptId AND aa.QuestionId = qn.QuestionId
                WHERE a.AttemptId = @AttemptId
                ORDER BY qn.QuestionId";

            var list = new List<Question>();

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@AttemptId", attemptId);
                con.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    int number = 1;
                    while (reader.Read())
                    {
                        string type = reader["QuestionType"].ToString();
                        bool auto = type == "MCQ";
                        string answer = reader["AnswerContent"] != DBNull.Value ? reader["AnswerContent"].ToString() : "";

                        list.Add(new Question
                        {
                            QuestionId = Convert.ToInt32(reader["QuestionId"]),
                            Number = number++,
                            Content = reader["QuestionContent"].ToString(),
                            TypeLabel = type == "MCQ" ? "Multiple Choice" : type,
                            Answer = answer.Length > 0 ? answer : "(No answer submitted)",
                            AnswerHtml = answer.Length == 0 ? "<em>(No answer submitted)</em>"
                                       : (type == "Code" ? TAHelpers.FormatCodeBlock(answer) : TAHelpers.FormatRichText(answer)),
                            IsCode = type == "Code",
                            AutoGraded = auto,
                            Locked = locked,
                            ScoreLocked = locked || auto,
                            MaxScore = Convert.ToDouble(reader["QuestionScore"]),
                            ScoreValue = reader["ObtainedScore"] != DBNull.Value ? Convert.ToDouble(reader["ObtainedScore"]) : 0,
                            Comment = reader["TeacherComment"] != DBNull.Value ? reader["TeacherComment"].ToString() : ""
                        });
                    }
                }
            }

            return list;
        }

        // ---------- Page binding ----------

        private void LoadGradingData()
        {
            var all = GetVisibleSubmissions();

            // Tab counts (always computed over the full list)
            litCountAll.Text = $"{all.Count}";
            litCountPending.Text = $"{all.Count(IsPending)}";
            litCountReviewed.Text = $"{all.Count(s => s.Status == GradingStatus.Reviewed)}";
            litCountApproved.Text = all.Count(s => s.Status == GradingStatus.Approved).ToString();

            string label = CurrentFilter == "pending" ? "Pending" : CurrentFilter == "reviewed" ? "Reviewed" : CurrentFilter == "approved" ? "Approved" : "All submissions";
            litFilterLabel.Text = label;

            // Apply the active filter
            List<Submission> filtered;
            if (CurrentFilter == "pending") filtered = all.Where(IsPending).ToList();
            else if (CurrentFilter == "reviewed") filtered = all.Where(s => s.Status == GradingStatus.Reviewed).ToList();
            else if (CurrentFilter == "approved") filtered = all.Where(s => s.Status == "Approved").ToList();
            else filtered = all;

            int.TryParse(Request.QueryString["attempt"], out int attemptId);
            var selected = filtered.FirstOrDefault(s => s.AttemptId == attemptId) ?? filtered.FirstOrDefault();
            if (selected != null) selected.CssClass = "selected";

            phListEmpty.Visible = filtered.Count == 0;
            rptSubmissions.DataSource = filtered;
            rptSubmissions.DataBind();

            // Bind the grading panel for the selected submission
            if (selected == null)
            {
                phGradingPanel.Visible = false;
                phNoSelection.Visible = true;
                return;
            }

            phGradingPanel.Visible = true;
            phNoSelection.Visible = false;
            hfAttemptId.Value = selected.AttemptId.ToString();

            // Once submitted, the TA can no longer edit; the teacher owns it from there
            bool locked = IsLocked(selected.Status);
            var questions = GetQuestions(selected.AttemptId, locked);

            litAssessmentTitle.Text = Server.HtmlEncode(selected.Title);
            litLearnerName.Text = Server.HtmlEncode(selected.LearnerName);
            litCourseName.Text = Server.HtmlEncode(selected.Course);
            litSubmitted.Text = selected.Submitted;
            litStatus.Text = selected.Status;

            litChapterRef.Text = selected.ChapterNum > 0 ? $"Chapter {selected.ChapterNum}" : "Course";
            hlCourse.Visible = selected.CourseId > 0;
            hlCourse.NavigateUrl = $"TACourseView.aspx?id={selected.CourseId}&focus={selected.ChapterNum}";

            // Reviewed and Approved replace the Save/Submit buttons with a status badge
            pnlReviewState.Visible = locked;
            if (locked)
            {
                bool approved = selected.Status == GradingStatus.Approved;
                litReviewState.Text = approved ? "Submission approved" : "Submitted for teacher review";
                pnlReviewState.CssClass = "review-state " + (approved ? "state-approved" : "state-reviewed");
            }

            txtOverallFeedback.Text = selected.ProgressNotes;
            txtOverallFeedback.ReadOnly = locked;
            btnSaveDraft.Visible = !locked;
            btnSubmitGrades.Visible = !locked;

            rptQuestions.DataSource = questions;
            rptQuestions.DataBind();

            litTotalScore.Text = questions.Sum(q => q.ScoreValue).ToString("0.##", CultureInfo.InvariantCulture);
            litTotalMax.Text = questions.Sum(q => q.MaxScore).ToString("0.##", CultureInfo.InvariantCulture);
        }

        protected void rptQuestions_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            var question = (Question)e.Item.DataItem;
            var txtScore = (TextBox)e.Item.FindControl("txtScore");
            txtScore.Attributes["min"] = "0";
            txtScore.Attributes["max"] = question.MaxScore.ToString(CultureInfo.InvariantCulture);
            txtScore.Attributes["step"] = "0.5";
        }

        // ---------- Saving ----------

        protected void btnSaveDraft_Click(object sender, EventArgs e)
        {
            SaveGrades(submit: false);
        }

        protected void btnSubmitGrades_Click(object sender, EventArgs e)
        {
            SaveGrades(submit: true);
        }

        private class ScoreEntry
        {
            public int QuestionId { get; set; }
            public double Score { get; set; }
            public double Max { get; set; }
            public string Comment { get; set; }
        }

        private void SaveGrades(bool submit)
        {
            int attemptId;
            if (!int.TryParse(hfAttemptId.Value, out attemptId))
            {
                ShowMessage("No submission selected.", false);
                return;
            }

            // 1. Read and validate what the TA entered
            var entries = new List<ScoreEntry>();
            foreach (RepeaterItem item in rptQuestions.Items)
            {
                var txtScore = (TextBox)item.FindControl("txtScore");
                if (txtScore.ReadOnly) continue; // multiple-choice answers are scored automatically

                var hfQuestionId = (HiddenField)item.FindControl("hfQuestionId");
                var hfMax = (HiddenField)item.FindControl("hfMaxScore");
                var txtComment = (TextBox)item.FindControl("txtComment");

                double score;
                double max = double.Parse(hfMax.Value, CultureInfo.InvariantCulture);
                if (!double.TryParse(txtScore.Text.Trim(), NumberStyles.Float, CultureInfo.InvariantCulture, out score) || score < 0 || score > max)
                {
                    ShowMessage($"Score for question {item.ItemIndex + 1} must be a number between 0 and {max.ToString("0.##", CultureInfo.InvariantCulture)}.", false);
                    return;
                }

                entries.Add(new ScoreEntry
                {
                    QuestionId = int.Parse(hfQuestionId.Value),
                    Score = score,
                    Max = max,
                    Comment = txtComment.Text.Trim()
                });
            }

            string feedback = txtOverallFeedback.Text.Trim();
            if (submit && feedback.Length == 0)
            {
                ShowMessage("Please write overall feedback for the teacher before submitting.", false);
                return;
            }

            // 2. Save inside one transaction
            string error = null;

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    try
                    {
                        error = WriteGrades(con, tx, attemptId, entries, feedback, submit);
                        if (error == null) tx.Commit(); else tx.Rollback();
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }
            }

            if (error != null)
            {
                ShowMessage(error, false);
                return;
            }

            // 3. Re-load so the list, status badge and locked state reflect the new data
            LoadGradingData();
            ShowMessage(submit ? "Review sent to the teacher for approval." : "Draft saved.", true);
        }

        // Returns an error message, or null when everything was written
        private string WriteGrades(SqlConnection con, SqlTransaction tx, int attemptId, List<ScoreEntry> entries, string feedback, bool submit)
        {
            // The attempt must still be waiting to be marked
            using (SqlCommand cmd = new SqlCommand("SELECT AttemptStatus FROM [dbo].[Attempt] WHERE AttemptId = @AttemptId", con, tx))
            {
                cmd.Parameters.AddWithValue("@AttemptId", attemptId);
                object status = cmd.ExecuteScalar();
                if (status == null || status.ToString() != "Submitted")
                {
                    return "This submission is no longer open for marking.";
                }
            }

            // Check who owns the grading row (UPDLOCK stops two TAs claiming the same attempt at once)
            int? gradingId = null;
            string progressStatus = null;
            using (SqlCommand cmd = new SqlCommand("SELECT GradingProgId, TA_Id, ProgressStatus FROM [dbo].[GradingProgress] WITH (UPDLOCK, HOLDLOCK) WHERE AttemptId = @AttemptId", con, tx))
            {
                cmd.Parameters.AddWithValue("@AttemptId", attemptId);
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        if (reader["TA_Id"] == DBNull.Value || Convert.ToInt32(reader["TA_Id"]) != TaId)
                        {
                            return "Another teaching assistant is already marking this submission.";
                        }
                        gradingId = Convert.ToInt32(reader["GradingProgId"]);
                        progressStatus = reader["ProgressStatus"].ToString();
                    }
                }
            }

            if (progressStatus != null && IsLocked(progressStatus))
            {
                return "This submission has already been sent to the teacher and can no longer be edited.";
            }

            // Scores and comments
            foreach (var entry in entries)
            {
                string isCorrect;
                if (!submit && entry.Score == 0 && entry.Comment.Length == 0) isCorrect = "Pending";
                else if (entry.Score >= entry.Max) isCorrect = "Correct";
                else if (entry.Score <= 0) isCorrect = "Incorrect";
                else isCorrect = "Partial";

                const string upsert = @"
                    UPDATE [dbo].[AttemptAnswer]
                       SET ObtainedScore = @Score, IsCorrect = @IsCorrect, TeacherComment = @Comment
                     WHERE AttemptId = @AttemptId AND QuestionId = @QuestionId;
                    IF @@ROWCOUNT = 0
                        INSERT INTO [dbo].[AttemptAnswer] (AttemptId, QuestionId, AnswerContent, IsCorrect, ObtainedScore, TeacherComment)
                        VALUES (@AttemptId, @QuestionId, '', @IsCorrect, @Score, @Comment);";

                using (SqlCommand cmd = new SqlCommand(upsert, con, tx))
                {
                    cmd.Parameters.AddWithValue("@AttemptId", attemptId);
                    cmd.Parameters.AddWithValue("@QuestionId", entry.QuestionId);
                    cmd.Parameters.AddWithValue("@Score", entry.Score);
                    cmd.Parameters.AddWithValue("@IsCorrect", isCorrect);
                    cmd.Parameters.AddWithValue("@Comment", entry.Comment);
                    cmd.ExecuteNonQuery();
                }
            }

            string newStatus = submit ? GradingStatus.Reviewed : GradingStatus.InProgress;

            if (gradingId == null)
            {
                using (SqlCommand cmd = new SqlCommand(
                    "INSERT INTO [dbo].[GradingProgress] (ProgressStatus, ProgressNotes, TA_Id, AttemptId) VALUES (@Status, @Notes, @TA_Id, @AttemptId)", con, tx))
                {
                    cmd.Parameters.AddWithValue("@Status", newStatus);
                    cmd.Parameters.AddWithValue("@Notes", feedback);
                    cmd.Parameters.AddWithValue("@TA_Id", TaId);
                    cmd.Parameters.AddWithValue("@AttemptId", attemptId);
                    cmd.ExecuteNonQuery();
                }
            }
            else
            {
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE [dbo].[GradingProgress] SET ProgressStatus = @Status, ProgressNotes = @Notes WHERE GradingProgId = @Id", con, tx))
                {
                    cmd.Parameters.AddWithValue("@Status", newStatus);
                    cmd.Parameters.AddWithValue("@Notes", feedback);
                    cmd.Parameters.AddWithValue("@Id", gradingId.Value);
                    cmd.ExecuteNonQuery();
                }
            }

            return null;
        }

        private void ShowMessage(string message, bool success)
        {
            litMessage.Text = Server.HtmlEncode(message);
            pnlMessage.CssClass = success ? "toast" : "toast toast-error";
            pnlMessage.Visible = true;
        }
    }
}
