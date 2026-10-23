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

        protected void Page_Load(object sender, EventArgs e)
        {
            List<TeacherCourse> courses = TeacherSampleData.GetCourses();
            int courseId;
            int.TryParse(Request.QueryString["course"], out courseId);
            // TODO (backend): load the course WHERE CourseId = @CourseId AND TeacherId = @TeacherId; unknown or foreign id -> redirect
            Course = courses.FirstOrDefault(c => c.Id == courseId) ?? courses[0];

            // TODO (backend): load the exam rules for this course (Exam table)
            Rules = TeacherSampleData.GetExamRules();
            if (IsPostBack)
            {
                foreach (TeacherExamRule rule in Rules)
                {
                    string posted = Request.Form["tpRule" + rule.Id];
                    if (posted != null) rule.On = posted == "1";
                }
            }

            if (!IsPostBack)
            {
                foreach (string language in courses.Select(c => c.Language).Distinct())
                {
                    ddlTeacherExamLanguage.Items.Add(language);
                }
                ddlTeacherExamLanguage.SelectedValue = Course.Language;
            }

            // The question cards are plain HTML fields (see TeacherQuestionCard.ascx), so they are rebuilt on every request.
            // TODO (backend): load this exam's questions (Question + MCQ_Option). After a save the page reloads them from the DB.
            BindQuestions();

            // Lets TeacherPortal.js update the language dot when the dropdown changes
            var map = courses.GroupBy(c => c.Language).ToDictionary(g => g.Key, g => new { theme = g.First().Theme, glyph = g.First().Glyph });
            ddlTeacherExamLanguage.Attributes["data-tp-lang-map"] = new JavaScriptSerializer().Serialize(map);
        }

        private void BindQuestions()
        {
            rptTeacherExamQuestions.DataSource = TeacherSampleData.GetExamQuestions(Course.Id);
            rptTeacherExamQuestions.DataBind();
        }

        /// <summary>Rebuilds the questions from the posted tpq{n}_* fields, in the order they were posted (page order).</summary>
        private List<TeacherQuestion> ReadPostedQuestions()
        {
            List<TeacherQuestion> existing = TeacherSampleData.GetExamQuestions(Course.Id);
            int nextId = Math.Max(1, existing.Count == 0 ? 1 : existing.Max(q => q.Id) + 1);
            List<TeacherQuestion> posted = new List<TeacherQuestion>();

            for (int n = 1; Request.Form["tpq" + n + "_text"] != null; n++)
            {
                string prefix = "tpq" + n + "_";
                int id, marks, correct;
                int.TryParse(Request.Form[prefix + "id"], out id);
                if (!int.TryParse(Request.Form[prefix + "marks"], out marks) || marks < 1) marks = 1;
                if (!int.TryParse(Request.Form[prefix + "correct"], out correct)) correct = -1;

                TeacherQuestion question = new TeacherQuestion
                {
                    Id = id > 0 ? id : nextId++,
                    Text = Request.Form[prefix + "text"].Trim(),
                    Marks = marks,
                    Type = Request.Form[prefix + "type"] ?? "MCQ",
                    AcceptedAnswers = Request.Form[prefix + "accepted"] ?? "",
                    ModelAnswer = Request.Form[prefix + "model"] ?? "",
                    MarkingGuide = Request.Form[prefix + "guide"] ?? "",
                    Answers = new List<TeacherAnswer>()
                };
                for (int m = 0; Request.Form[prefix + "a" + m] != null; m++)
                {
                    question.Answers.Add(new TeacherAnswer { Text = Request.Form[prefix + "a" + m], Correct = m == correct });
                }
                posted.Add(question);
            }
            return posted;
        }

        protected void btnTeacherSaveExam_Click(object sender, EventArgs e)
        {
            // Until the database exists the arranged questions are kept in the session (TeacherSampleData.SaveExamQuestions)
            TeacherSampleData.SaveExamQuestions(Course.Id, ReadPostedQuestions());
            BindQuestions(); // show the saved order and text straight away
            // TODO (backend): save the exam. Posted fields:
            //   for the exam of Course.Id (the ?course= value; check the course belongs to the signed-in teacher):
            //   hfTeacherMinMarks, ddlTeacherExamLanguage, tpRule<RuleId> ("1"/"0"),
            //   and per question n (1-based, in page order): tpq{n}_id (QuestionId, 0 = new), tpq{n}_text, tpq{n}_marks, tpq{n}_type,
            //   tpq{n}_a{m} (answers, in order), tpq{n}_correct (index of the correct answer),
            //   tpq{n}_accepted, tpq{n}_model, tpq{n}_guide
            Master.ShowToast("Exam details saved");
        }
    }
}
