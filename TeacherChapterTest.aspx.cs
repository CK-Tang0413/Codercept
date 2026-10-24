using System;
using System.Collections.Generic;
using System.Linq;

namespace Codercept
{
    /// <summary>
    /// Edit (or delete) the one quiz or assessment at the end of a chapter. Opened from Manage Chapters with
    /// ?chapter=&lt;ChapterId&gt;&amp;n=&lt;the number the chapter shows&gt;.
    /// </summary>
    public partial class TeacherChapterTest : System.Web.UI.Page
    {
        protected TeacherChapter Chapter;

        /// <summary>quiz | assessment</summary>
        protected string Mode;

        /// <summary>"Quiz" | "Assessment"</summary>
        protected string Noun;

        private int chapterNumber;

        protected string BackUrl
        {
            get { return "TeacherChapters.aspx?chapter=" + Chapter.Id; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // TODO (backend): load the chapter WHERE ChapterId = @ChapterId AND its course belongs to the signed-in teacher;
            //   unknown or foreign id, or a chapter without a quiz/assessment -> back to Manage Chapters
            int chapterId;
            int.TryParse(Request.QueryString["chapter"], out chapterId);
            Chapter = TeacherSampleData.GetChapter(chapterId);
            if (Chapter == null || Chapter.Test == null) Response.Redirect("~/TeacherChapters.aspx");

            Mode = Chapter.Test.Type;
            Noun = Mode == "quiz" ? "Quiz" : "Assessment";
            if (!int.TryParse(Request.QueryString["n"], out chapterNumber) || chapterNumber <= 0) chapterNumber = Chapter.Number;

            bcTeacherChapter.CourseTitle = TeacherSampleData.ChapterCourseTitle;
            bcTeacherChapter.ChapterTitle = "Chapter " + chapterNumber + " - " + Chapter.Title;
            shTeacherDetails.Subtitle = "Update the essential information for this " + Mode + ".";
            qcTeacherNewQuestion.Mode = Mode;

            mdlTeacherDeleteTest.TitleText = "Delete " + Mode + "?";
            mdlTeacherDeleteTest.ConfirmText = "Delete " + Mode;
            mdlTeacherDeleteTest.BodyHtml = "This will permanently delete <strong>" + Server.HtmlEncode(Chapter.Test.Title)
                + "</strong> and its questions. You can then add a quiz or an assessment to this chapter again. This action cannot be undone.";

            if (!IsPostBack)
            {
                txtTeacherTestTitle.Text = Chapter.Test.Title;
                reTeacherTestDescription.Text = TeacherSampleData.SampleTestDescription;
            }

            // The question cards are plain HTML fields (see TeacherQuestionCard.ascx), rebuilt on every request: after a postback
            // from what was posted (so nothing the teacher arranged is lost), otherwise from the saved questions.
            // TODO (backend): load the quiz's / assessment's Question + MCQ_Option rows
            BindQuestions(IsPostBack ? ReadPostedQuestions() : TeacherSampleData.GetTestQuestions(Chapter));
        }

        private void BindQuestions(List<TeacherQuestion> questions)
        {
            rptTeacherTestQuestions.DataSource = questions;
            rptTeacherTestQuestions.DataBind();
        }

        private List<TeacherQuestion> ReadPostedQuestions()
        {
            List<TeacherQuestion> existing = TeacherSampleData.GetTestQuestions(Chapter);
            return TeacherQuestion.ReadPosted(Request.Unvalidated.Form, existing.Count == 0 ? 1 : existing.Max(q => q.Id) + 1);
        }

        protected void btnTeacherSaveTest_Click(object sender, EventArgs e)
        {
            string title = txtTeacherTestTitle.Text.Trim();
            bool titleError = title.Length < 4;
            fldTeacherTestTitle.Attributes["class"] = titleError ? "form-field has-error" : "form-field";
            hintTeacherTestTitle.InnerText = hintTeacherTestTitle.Attributes[titleError ? "data-err" : "data-ok"];
            if (titleError) return;

            List<TeacherQuestion> questions = ReadPostedQuestions();
            if (questions.Count == 0)
            {
                Master.ShowToast("Add at least one question before saving.");
                return;
            }
            if (questions.Any(q => q.Text.Length == 0))
            {
                Master.ShowToast("Every question needs some text.");
                return;
            }

            // TODO (backend): save the quiz / assessment. Posted fields:
            //   txtTeacherTestTitle, dzTeacherTestFile.PostedFile, reTeacherTestDescription.Text, and per question n (1-based, page order):
            //   tpq{n}_id (QuestionId, 0 = new), tpq{n}_text, tpq{n}_marks, tpq{n}_type, tpq{n}_a{m}, tpq{n}_correct,
            //   tpq{n}_accepted, tpq{n}_model, tpq{n}_guide
            // Until then the title, the questions and their order are kept in the session (TeacherSampleData.SaveChapterTest).
            TeacherSampleData.SaveChapterTest(Chapter.Id, title, questions);
            Chapter = TeacherSampleData.GetChapter(Chapter.Id);
            BindQuestions(questions); // show the saved order and text straight away
            Master.ShowToast(Noun + " saved");
        }

        protected void mdlTeacherDeleteTest_Confirmed(object sender, EventArgs e)
        {
            // TODO (backend): delete the quiz / assessment and its questions (MCQ_Option, Question), checking ownership in SQL;
            //   refuse when learners have attempts on it
            TeacherSampleData.SaveChapterTest(Chapter.Id, null, null);
            Response.Redirect("~/TeacherChapters.aspx?chapter=" + Chapter.Id + "&testdeleted=1");
        }
    }
}
