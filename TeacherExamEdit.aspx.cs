using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Script.Serialization;

namespace Codercept
{
    public partial class TeacherExamEdit : System.Web.UI.Page
    {
        protected TeacherCourse Course;
        protected List<TeacherExamRule> Rules;

        /// <summary>False when the course has no exam yet: the page then creates it.</summary>
        protected bool ExamExists;

        protected void Page_Load(object sender, EventArgs e)
        {
            // No ?course= means the first course; an id that is not this teacher's course goes back to the exam list
            Course = TeacherCourseData.Pick(TeacherCourseData.GetCourses(), Request.QueryString["course"]);
            if (Course == null) Response.Redirect("~/TeacherExams.aspx");
            ExamExists = TeacherCourseData.GetCourseIdsWithExam().Contains(Course.Id);

            // TODO (backend): load the exam's pass mark, time limit and rules for this course (Exam table)
            Rules = TeacherSampleData.GetExamRules();
            if (IsPostBack)
            {
                foreach (TeacherExamRule rule in Rules)
                {
                    string posted = Request.Form["tpRule" + rule.Id];
                    if (posted != null) rule.On = posted == "1";
                }
            }

            // The question cards are plain HTML fields (see TeacherQuestionCard.ascx), so they are rebuilt on every request:
            // after a postback from what was posted (nothing the teacher arranged is lost), otherwise from the saved questions.
            // A course without an exam starts with no questions.
            // TODO (backend): load this exam's questions (Question + MCQ_Option)
            BindQuestions(IsPostBack ? ReadPostedQuestions() : StoredQuestions());
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            btnTeacherSaveExam.Text = "<svg aria-hidden=\"true\" class=\"icon\" fill=\"none\" height=\"17\" viewBox=\"0 0 24 24\" width=\"17\"><path d='m5 12 4 4L19 6' /></svg><span>"
                + (ExamExists ? "Save exam details" : "Create exam") + "</span>";
        }

        private List<TeacherQuestion> StoredQuestions()
        {
            return ExamExists ? TeacherSampleData.GetExamQuestions(Course.Id) : new List<TeacherQuestion>();
        }

        private void BindQuestions(List<TeacherQuestion> questions)
        {
            rptTeacherExamQuestions.DataSource = questions;
            rptTeacherExamQuestions.DataBind();
        }

        /// <summary>The questions as posted (page order); new ones get ids after the highest saved id.</summary>
        private List<TeacherQuestion> ReadPostedQuestions()
        {
            List<TeacherQuestion> existing = StoredQuestions();
            return TeacherQuestion.ReadPosted(Request.Unvalidated.Form, existing.Count == 0 ? 1 : existing.Max(q => q.Id) + 1);
        }

        protected void btnTeacherSaveExam_Click(object sender, EventArgs e)
        {
            List<TeacherQuestion> questions = ReadPostedQuestions();
            if (questions.Count == 0)
            {
                Master.ShowToast("Add at least one question before saving the exam.");
                return;
            }
            if (questions.Any(q => q.Text.Length == 0))
            {
                Master.ShowToast("Every question needs some text.");
                return;
            }

            // The pass mark is a percentage, the time limit is in minutes (the page's steppers keep them in range)
            int passMark, timeLimit;
            if (!int.TryParse(hfTeacherMinMarks.Value, out passMark) || passMark < 1 || passMark > 100) passMark = 50;
            if (!int.TryParse(hfTeacherTimeLimit.Value, out timeLimit) || timeLimit < 5 || timeLimit > 300) timeLimit = 60;
            hfTeacherMinMarks.Value = passMark.ToString();
            hfTeacherTimeLimit.Value = timeLimit.ToString();

            // TODO (backend): INSERT the Exam row when the course has none, otherwise UPDATE it (check the course belongs to the
            //   signed-in teacher). Posted fields: hfTeacherMinMarks (pass mark %), hfTeacherTimeLimit (minutes),
            //   tpRule<RuleId> ("1"/"0": 1 = strict syntax checking, 2 = use of libraries), and per question n (1-based, page order):
            //   tpq{n}_id (QuestionId, 0 = new), tpq{n}_text, tpq{n}_marks, tpq{n}_type, tpq{n}_a{m} (answers, in order),
            //   tpq{n}_correct (index of the correct answer), tpq{n}_accepted, tpq{n}_model, tpq{n}_guide
            // Until then the arranged questions are kept in the session (TeacherSampleData.SaveExamQuestions).
            bool created = !ExamExists;
            TeacherSampleData.SaveExamQuestions(Course.Id, questions);
            if (created)
            {
                TeacherSampleData.MarkExamCreated(Course.Id);
                ExamExists = true;
            }
            BindQuestions(questions); // show the saved order and text straight away
            Master.ShowToast(created ? "Exam created" : "Exam details saved");
        }
    }
}
