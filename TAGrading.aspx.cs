using System;
using System.Collections.Generic;
using System.Linq;

namespace Codercept
{
    public partial class TAGrading : System.Web.UI.Page
    {
        // Workflow: Pending -> In Progress (draft saved) -> Submitted (awaiting teacher)
        //           -> Approved (official grade, visible to learner) or Returned (teacher asks TA to revise)

        // 1. Define Dummy Data Structures
        public class DummySubmission
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
            public string TeacherNote { get; set; }
            public string CssClass { get; set; }
        }

        public class DummyQuestion
        {
            public int QuestionId { get; set; }
            public int Number { get; set; }
            public string Content { get; set; }
            public string TypeLabel { get; set; }
            public string Answer { get; set; }
            public bool IsCode { get; set; }
            public bool AutoGraded { get; set; }
            public bool Locked { get; set; }      // whole submission is read-only
            public bool ScoreLocked { get; set; } // auto-graded or read-only
            public int MaxScore { get; set; }
            public string Score { get; set; }
            public string Comment { get; set; }
        }

        protected string CurrentFilter { get; private set; } = "all";

        protected void Page_Load(object sender, EventArgs e)
        {
            // Security Check
            if (Session["UserType"] == null || Session["UserType"].ToString() != "TA")
            {
                Response.Redirect("signIn.aspx");
                return;
            }

            string filter = (Request.QueryString["filter"] ?? "all").ToLower();
            CurrentFilter = (filter == "todo" || filter == "submitted" || filter == "approved") ? filter : "all";

            if (!IsPostBack)
            {
                LoadGradingData();
            }
        }

        protected string GetTabClass(string tab)
        {
            return tab == CurrentFilter ? "active" : "";
        }

        private static bool IsTodo(DummySubmission s)
        {
            return s.Status == "Pending" || s.Status == "In Progress" || s.Status == "Returned";
        }

        private void LoadGradingData()
        {
            // 2. Generate Dummy Data
            var all = new List<DummySubmission>
            {
                new DummySubmission { AttemptId = 101, CourseId = 1, ChapterNum = 3, LearnerName = "Alex Chen", Title = "Functions Assessment", Type = "Assessment", Course = "Python for Beginners", Submitted = "2 hours ago", Status = "Pending", StatusCss = "status-pending" },
                new DummySubmission { AttemptId = 102, CourseId = 2, ChapterNum = 2, LearnerName = "Mei Ling", Title = "Control Flow Exam", Type = "Exam", Course = "Java Fundamentals", Submitted = "5 hours ago", Status = "In Progress", StatusCss = "status-inprogress" },
                new DummySubmission { AttemptId = 103, CourseId = 3, ChapterNum = 2, LearnerName = "Daniel Tan", Title = "Pointers Quiz", Type = "Quiz", Course = "C Programming Essentials", Submitted = "Yesterday", Status = "Returned", StatusCss = "status-returned",
                    TeacherNote = "Q2 loses marks for not handling an empty list. Please re-check the scoring and add feedback." },
                new DummySubmission { AttemptId = 104, CourseId = 4, ChapterNum = 1, LearnerName = "Sara Ahmad", Title = "Classes Assessment", Type = "Assessment", Course = "C++ Object-Oriented Programming", Submitted = "Yesterday", Status = "Pending", StatusCss = "status-pending" },
                new DummySubmission { AttemptId = 105, CourseId = 5, ChapterNum = 2, LearnerName = "Ravi Kumar", Title = "Flexbox Quiz", Type = "Quiz", Course = "Responsive Web Design", Submitted = "2 days ago", Status = "Submitted", StatusCss = "status-submitted" },
                new DummySubmission { AttemptId = 106, CourseId = 1, ChapterNum = 1, LearnerName = "Kylan Shane Sedrick", Title = "Variables Quiz", Type = "Quiz", Course = "Python for Beginners", Submitted = "3 days ago", Status = "Approved", StatusCss = "status-approved" },
                new DummySubmission { AttemptId = 107, CourseId = 2, ChapterNum = 2, LearnerName = "Wan Hon Kit", Title = "Loops Assessment", Type = "Assessment", Course = "Java Fundamentals", Submitted = "4 days ago", Status = "Approved", StatusCss = "status-approved" }
            };

            // 3. Tab counts (always computed over the full list)
            litCountAll.Text = $" ({all.Count})";
            litCountTodo.Text = $" ({all.Count(IsTodo)})";
            litCountSubmitted.Text = $" ({all.Count(s => s.Status == "Submitted")})";
            litCountApproved.Text = $" ({all.Count(s => s.Status == "Approved")})";

            // 4. Apply the active filter
            List<DummySubmission> filtered;
            if (CurrentFilter == "todo") filtered = all.Where(IsTodo).ToList();
            else if (CurrentFilter == "submitted") filtered = all.Where(s => s.Status == "Submitted").ToList();
            else if (CurrentFilter == "approved") filtered = all.Where(s => s.Status == "Approved").ToList();
            else filtered = all;

            int.TryParse(Request.QueryString["attempt"], out int attemptId);
            var selected = filtered.FirstOrDefault(s => s.AttemptId == attemptId) ?? filtered.FirstOrDefault();
            if (selected != null) selected.CssClass = "selected";

            phListEmpty.Visible = filtered.Count == 0;
            rptSubmissions.DataSource = filtered;
            rptSubmissions.DataBind();

            // 5. Bind the grading panel for the selected submission
            if (selected == null)
            {
                phGradingPanel.Visible = false;
                phNoSelection.Visible = true;
                return;
            }

            // Once submitted, the TA can no longer edit; the teacher owns it from there
            bool locked = selected.Status == "Submitted" || selected.Status == "Approved";
            var questions = BuildQuestions(selected, locked);

            litAssessmentTitle.Text = selected.Title;
            litLearnerName.Text = selected.LearnerName;
            litCourseName.Text = selected.Course;
            litSubmitted.Text = selected.Submitted;
            litStatus.Text = selected.Status;
            litChapterRef.Text = $"Chapter {selected.ChapterNum}";
            hlCourse.NavigateUrl = $"TACourseView.aspx?id={selected.CourseId}&focus={selected.ChapterNum}";

            pnlTeacherNote.Visible = selected.Status == "Returned";
            litTeacherNote.Text = Server.HtmlEncode(selected.TeacherNote ?? "");

            pnlLocked.Visible = locked;
            litLockedText.Text = selected.Status == "Approved"
                ? "This submission was approved by the teacher. The scores are final and visible to the learner."
                : "Submitted to the teacher for approval. Scores are locked until the teacher responds.";

            txtOverallFeedback.ReadOnly = locked;
            if (locked) txtOverallFeedback.Text = "Good understanding of the core concepts. Review edge-case handling in your code.";
            btnSaveDraft.Visible = !locked;
            btnSubmitGrades.Visible = !locked;

            rptQuestions.DataSource = questions;
            rptQuestions.DataBind();

            litTotalScore.Text = questions.Sum(q => int.Parse(q.Score)).ToString();
            litTotalMax.Text = questions.Sum(q => q.MaxScore).ToString();
        }

        private List<DummyQuestion> BuildQuestions(DummySubmission submission, bool locked)
        {
            // Only submissions the TA has worked on already carry suggested scores
            bool scored = locked || submission.Status == "In Progress" || submission.Status == "Returned";

            return new List<DummyQuestion>
            {
                new DummyQuestion
                {
                    QuestionId = 1, Number = 1, TypeLabel = "Short Answer", MaxScore = 10, IsCode = false, AutoGraded = false,
                    Content = "Explain the difference between a parameter and an argument.",
                    Answer = "A parameter is the variable listed in a function's definition, while an argument is the actual value that is passed in when the function is called.",
                    Score = scored ? "9" : "0", Comment = scored ? "Clear and correct." : ""
                },
                new DummyQuestion
                {
                    QuestionId = 2, Number = 2, TypeLabel = "Code", MaxScore = 20, IsCode = true, AutoGraded = false,
                    Content = "Write a function that returns the largest number in a list.",
                    Answer = "def largest(numbers):\n    biggest = numbers[0]\n    for n in numbers:\n        if n > biggest:\n            biggest = n\n    return biggest",
                    Score = scored ? "17" : "0", Comment = scored ? "Works, but does not handle an empty list." : ""
                },
                new DummyQuestion
                {
                    QuestionId = 3, Number = 3, TypeLabel = "Multiple Choice", MaxScore = 5, IsCode = false, AutoGraded = true,
                    Content = "Which keyword is used to return a value from a function?",
                    Answer = "return",
                    Score = "5", Comment = ""
                }
            }.Select(q => { q.Locked = locked; q.ScoreLocked = locked || q.AutoGraded; return q; }).ToList();
        }

        protected void btnSaveDraft_Click(object sender, EventArgs e)
        {
            // We will implement this later
            ShowMessage("Draft saved. (Preview only — saving will be implemented with the backend.)");
        }

        protected void btnSubmitGrades_Click(object sender, EventArgs e)
        {
            // We will implement this later
            ShowMessage("Submitted to the teacher for approval. (Preview only — saving will be implemented with the backend.)");
        }

        private void ShowMessage(string message)
        {
            litMessage.Text = message;
            pnlMessage.Visible = true;
        }
    }
}
