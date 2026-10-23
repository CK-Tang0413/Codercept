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
                for (int i = 0; i < Rules.Count; i++)
                {
                    string posted = Request.Form["tpRule" + i];
                    if (posted != null) Rules[i].On = posted == "1";
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
            rptTeacherExamQuestions.DataSource = TeacherSampleData.GetExamQuestions();
            rptTeacherExamQuestions.DataBind();

            // Lets TeacherPortal.js update the language dot when the dropdown changes
            var map = courses.GroupBy(c => c.Language).ToDictionary(g => g.Key, g => new { theme = g.First().Theme, glyph = g.First().Glyph });
            ddlTeacherExamLanguage.Attributes["data-tp-lang-map"] = new JavaScriptSerializer().Serialize(map);
        }

        protected void btnTeacherSaveExam_Click(object sender, EventArgs e)
        {
            // TODO (backend): save the exam. Posted fields:
            //   hfTeacherMinMarks, ddlTeacherExamLanguage, tpRule0..tpRule3 ("1"/"0"),
            //   and per question n (1-based, in page order): tpq{n}_text, tpq{n}_marks, tpq{n}_type,
            //   tpq{n}_a{m} (answers, in order), tpq{n}_correct (index of the correct answer),
            //   tpq{n}_accepted, tpq{n}_model, tpq{n}_guide
            Master.ShowToast("Exam details saved");
        }
    }
}
