using System;
using System.Collections.Generic;
using System.Linq;

namespace Codercept
{
    /// <summary>
    /// Edit (or delete) the one quiz or assessment at the end of a chapter. Opened from Manage Chapters with
    /// ?chapter=&lt;ChapterId&gt;. Once learners have attempted it the questions are read-only (the title, description and file can
    /// still change) and it cannot be deleted.
    /// </summary>
    public partial class TeacherChapterTest : System.Web.UI.Page
    {
        protected TeacherChapter Chapter;

        /// <summary>quiz | assessment</summary>
        protected string Mode;

        /// <summary>"Quiz" | "Assessment"</summary>
        protected string Noun;

        private TeacherTest test;

        protected string BackUrl
        {
            get { return "TeacherChapters.aspx?chapter=" + Chapter.Id; }
        }

        /// <summary>The test's stored file (for the "View current file" row).</summary>
        protected string MediaLink
        {
            get { return test.MediaLink; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // ?chapter=<ChapterId>: a chapter of the signed-in teacher's that has a quiz or an assessment, otherwise back to Manage Chapters
            int chapterId;
            int.TryParse(Request.QueryString["chapter"], out chapterId);
            Chapter = TeacherChapterData.GetChapter(chapterId);
            if (Chapter == null) Response.Redirect("~/TeacherChapters.aspx");
            test = TeacherTestData.GetTest(Chapter.Id);
            if (test == null) Response.Redirect("~/TeacherChapters.aspx?chapter=" + Chapter.Id);

            Mode = test.Type;
            Noun = Mode == "quiz" ? "Quiz" : "Assessment";

            bcTeacherChapter.CourseTitle = Chapter.CourseTitle;
            bcTeacherChapter.ChapterTitle = "Chapter " + Chapter.Number + " - " + Chapter.Title;
            shTeacherDetails.Subtitle = "Update the essential information for this " + Mode + ".";
            qcTeacherNewQuestion.Mode = Mode;

            // Attempted: the questions are shown but cannot be edited (the server ignores them too)
            pnlTeacherLocked.Visible = test.HasAttempts;
            if (test.HasAttempts) divTeacherQuestions.Attributes["inert"] = "inert";

            mdlTeacherDeleteTest.TitleText = "Delete " + Mode + "?";
            mdlTeacherDeleteTest.ConfirmText = "Delete " + Mode;
            mdlTeacherDeleteTest.BodyHtml = "This will permanently delete <strong>" + Server.HtmlEncode(test.Title)
                + "</strong>, its questions and its file. You can then add a quiz or an assessment to this chapter again. This action cannot be undone.";

            if (!IsPostBack)
            {
                txtTeacherTestTitle.Text = test.Title;
                reTeacherTestDescription.Text = test.Description;
            }

            // The question cards are plain HTML fields (see TeacherQuestionCard.ascx), rebuilt on every request: after a postback
            // from what was posted (so nothing the teacher arranged is lost), otherwise from the stored questions.
            BindQuestions(IsPostBack && !test.HasAttempts ? ReadPostedQuestions() : test.Questions);
        }

        private void BindQuestions(List<TeacherQuestion> questions)
        {
            rptTeacherTestQuestions.DataSource = questions;
            rptTeacherTestQuestions.DataBind();
        }

        /// <summary>The posted questions. New ones get ids above every stored question's, so they are never mistaken for a stored one.</summary>
        private List<TeacherQuestion> ReadPostedQuestions()
        {
            return TeacherQuestion.ReadPosted(Request.Unvalidated.Form, test.Questions.Count == 0 ? 1 : test.Questions.Max(q => q.Id) + 1);
        }

        protected void btnTeacherSaveTest_Click(object sender, EventArgs e)
        {
            string title = txtTeacherTestTitle.Text.Trim();
            bool titleError = title.Length < 4 || title.Length > 50;
            fldTeacherTestTitle.Attributes["class"] = titleError ? "form-field has-error" : "form-field";
            hintTeacherTestTitle.InnerText = hintTeacherTestTitle.Attributes[titleError ? "data-err" : "data-ok"];
            if (titleError) return;

            // the questions are saved only while nobody has attempted the test
            List<TeacherQuestion> questions = null;
            if (!test.HasAttempts)
            {
                questions = ReadPostedQuestions();
                string problem = TeacherTestData.Validate(Mode, questions);
                if (problem != null)
                {
                    Master.ShowToast(problem);
                    return;
                }
            }

            // the file: a chosen file replaces it, "Remove file" clears it, otherwise it stays as it is
            string newMedia = null;
            bool changeMedia = false;
            if (dzTeacherTestFile.PostedFile != null)
            {
                string error;
                newMedia = TeacherMediaStore.Save(dzTeacherTestFile.PostedFile, Chapter.CourseId, out error);
                if (newMedia == null)
                {
                    Master.ShowToast(error);
                    return;
                }
                changeMedia = true;
            }
            else if (hfTeacherTestMediaRemove.Value == "1")
            {
                changeMedia = true;
            }
            hfTeacherTestMediaRemove.Value = "";

            string oldMedia;
            TeacherTestData.SaveResult result;
            try
            {
                result = TeacherTestData.UpdateTest(Chapter.Id, Mode, title, reTeacherTestDescription.Text.Trim(), changeMedia, newMedia, questions, out oldMedia);
            }
            catch
            {
                if (newMedia != null) TeacherMediaStore.Delete(newMedia);
                throw;
            }

            if (result != TeacherTestData.SaveResult.Saved)
            {
                if (newMedia != null) TeacherMediaStore.Delete(newMedia); // nothing was saved, so the new file is not kept
                Master.ShowToast(result == TeacherTestData.SaveResult.QuestionsLocked
                    ? "Learners have attempted this " + Mode + " in the meantime, so its questions can no longer be changed. Reload the page."
                    : "That " + Mode + " was not found. Reload the page and try again.");
                return;
            }
            if (changeMedia) TeacherMediaStore.Delete(oldMedia); // replaced or removed: the old file goes

            // show what is stored now
            test = TeacherTestData.GetTest(Chapter.Id);
            BindQuestions(test.Questions);
            Master.ShowToast(Noun + " saved");
        }

        protected void mdlTeacherDeleteTest_Confirmed(object sender, EventArgs e)
        {
            string file;
            TeacherTestData.DeleteResult result = TeacherTestData.DeleteTest(Chapter.Id, Mode, out file);
            if (result == TeacherTestData.DeleteResult.HasAttempts)
            {
                Master.ShowToast("This " + Mode + " cannot be deleted because learners have attempted it. Their results are kept.");
                return;
            }
            if (result == TeacherTestData.DeleteResult.NotFound)
            {
                Master.ShowToast("That " + Mode + " was not found. Reload the page and try again.");
                return;
            }

            TeacherMediaStore.Delete(file); // the rows are gone, so the file goes too
            Response.Redirect("~/TeacherChapters.aspx?chapter=" + Chapter.Id + "&testdeleted=1");
        }
    }
}
