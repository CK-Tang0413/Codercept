using System;
using System.Collections.Generic;
using System.Linq;

namespace Codercept
{
    public partial class TeacherExamEdit : System.Web.UI.Page
    {
        protected TeacherCourse Course;
        protected List<TeacherExamRule> Rules;

        /// <summary>False when the course has no exam yet: the page then creates it.</summary>
        protected bool ExamExists;

        private TeacherExam exam;

        /// <summary>
        /// Learners have attempted the exam: its pass mark and questions are shown but can no longer change, so every learner is judged the
        /// same way. The title, description, time limit and rules can still be edited.
        /// </summary>
        private bool Locked
        {
            get { return exam != null && exam.HasAttempts; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // No ?course= means the first course; an id that is not this teacher's course goes back to the exam list
            Course = TeacherCourseData.Pick(TeacherCourseData.GetCourses(), Request.QueryString["course"]);
            if (Course == null) Response.Redirect("~/TeacherExams.aspx");
            exam = TeacherExamData.GetExam(Course.Id);
            ExamExists = exam != null;

            // Rule 1 = strict syntax checking, rule 2 = use of libraries: from the stored exam, or the defaults for a new one
            Rules = TeacherSampleData.GetExamRules();
            if (exam != null) ApplyRules(exam.StrictSyntax, exam.AllowLibraries);

            if (!IsPostBack)
            {
                if (exam != null)
                {
                    txtTeacherExamTitle.Text = exam.Title;
                    reTeacherExamDescription.Text = exam.Description;
                    hfTeacherMinMarks.Value = exam.PassMark.ToString();
                    hfTeacherTimeLimit.Value = exam.TimeLimitMinutes.ToString();
                }
            }
            else
            {
                foreach (TeacherExamRule rule in Rules)
                {
                    string posted = Request.Form["tpRule" + rule.Id];
                    if (posted != null) rule.On = posted == "1";
                }
            }

            // Attempted: the pass mark and the questions are shown but read-only (the server refuses changes to them too)
            pnlTeacherExamLocked.Visible = Locked;
            if (Locked)
            {
                hfTeacherMinMarks.Value = exam.PassMark.ToString(); // whatever was posted, the box shows the stored pass mark
                divTeacherPassMark.Attributes["inert"] = "inert";
                secTeacherExamQuestions.Attributes["inert"] = "inert";
            }

            // The question cards are plain HTML fields (see TeacherQuestionCard.ascx), so they are rebuilt on every request:
            // after a postback from what was posted (nothing the teacher arranged is lost), otherwise from the stored questions.
            // A course without an exam starts with no questions.
            BindQuestions(IsPostBack && !Locked ? ReadPostedQuestions() : StoredQuestions());
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            btnTeacherSaveExam.Text = "<svg aria-hidden=\"true\" class=\"icon\" fill=\"none\" height=\"17\" viewBox=\"0 0 24 24\" width=\"17\"><path d='m5 12 4 4L19 6' /></svg><span>"
                + (ExamExists ? "Save exam details" : "Create exam") + "</span>";
        }

        private void ApplyRules(bool strictSyntax, bool allowLibraries)
        {
            foreach (TeacherExamRule rule in Rules)
            {
                if (rule.Id == 1) rule.On = strictSyntax;
                if (rule.Id == 2) rule.On = allowLibraries;
            }
        }

        private List<TeacherQuestion> StoredQuestions()
        {
            return exam != null ? exam.Questions : new List<TeacherQuestion>();
        }

        private void BindQuestions(List<TeacherQuestion> questions)
        {
            rptTeacherExamQuestions.DataSource = questions;
            rptTeacherExamQuestions.DataBind();
        }

        /// <summary>The questions as posted (page order); new ones get ids above every stored question's, so they are never mistaken for a stored one.</summary>
        private List<TeacherQuestion> ReadPostedQuestions()
        {
            List<TeacherQuestion> stored = StoredQuestions();
            return TeacherQuestion.ReadPosted(Request.Unvalidated.Form, stored.Count == 0 ? 1 : stored.Max(q => q.Id) + 1);
        }

        protected void btnTeacherSaveExam_Click(object sender, EventArgs e)
        {
            string title = txtTeacherExamTitle.Text.Trim();
            bool titleError = title.Length < 4 || title.Length > 50;
            fldTeacherExamTitle.Attributes["class"] = titleError ? "form-field has-error" : "form-field";
            hintTeacherExamTitle.InnerText = hintTeacherExamTitle.Attributes[titleError ? "data-err" : "data-ok"];
            if (titleError) return;
            string description = reTeacherExamDescription.Text.Trim();

            // The pass mark and the questions can only change while nobody has attempted the exam
            List<TeacherQuestion> questions = null;
            int passMark;
            if (Locked)
            {
                passMark = exam.PassMark;
            }
            else
            {
                questions = ReadPostedQuestions();
                string problem = TeacherTestData.Validate("exam", questions);
                if (problem != null)
                {
                    Master.ShowToast(problem);
                    return;
                }

                // The pass mark is a percentage (the page's stepper keeps it in range)
                if (!int.TryParse(hfTeacherMinMarks.Value, out passMark) || passMark < TeacherExamData.MinPassMark || passMark > TeacherExamData.MaxPassMark)
                {
                    Master.ShowToast("The pass mark must be between " + TeacherExamData.MinPassMark + "% and " + TeacherExamData.MaxPassMark + "%.");
                    return;
                }
            }

            // The time limit is in minutes
            int timeLimit;
            if (!int.TryParse(hfTeacherTimeLimit.Value, out timeLimit) || timeLimit < TeacherExamData.MinTimeLimit || timeLimit > TeacherExamData.MaxTimeLimit)
            {
                Master.ShowToast("The time limit must be between " + TeacherExamData.MinTimeLimit + " and " + TeacherExamData.MaxTimeLimit + " minutes.");
                return;
            }

            bool strictSyntax = Rules.First(r => r.Id == 1).On;
            bool allowLibraries = Rules.First(r => r.Id == 2).On;

            bool created = !ExamExists;
            if (created)
            {
                int examId;
                TeacherExamData.CreateResult result = TeacherExamData.CreateExam(Course.Id, title, description, passMark, timeLimit, strictSyntax, allowLibraries, questions, out examId);
                if (result == TeacherExamData.CreateResult.NotFound) Response.Redirect("~/TeacherExams.aspx");
                if (result == TeacherExamData.CreateResult.AlreadyExists)
                {
                    Master.ShowToast("This course already has an exam. Reload the page to edit it.");
                    return;
                }
            }
            else
            {
                TeacherExamData.SaveResult result = TeacherExamData.UpdateExam(Course.Id, title, description, passMark, timeLimit, strictSyntax, allowLibraries, questions);
                if (result == TeacherExamData.SaveResult.NotFound) Response.Redirect("~/TeacherExams.aspx");
                if (result == TeacherExamData.SaveResult.Locked)
                {
                    Master.ShowToast("Learners have attempted this exam in the meantime, so its pass mark and questions can no longer be changed. Reload the page.");
                    return;
                }
            }

            // show what is stored now
            exam = TeacherExamData.GetExam(Course.Id);
            ExamExists = true;
            BindQuestions(exam.Questions);
            Master.ShowToast(created ? "Exam created" : "Exam details saved");
        }
    }
}
