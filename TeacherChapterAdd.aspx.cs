using System;
using System.Collections.Generic;
using System.Linq;

namespace Codercept
{
    public partial class TeacherChapterAdd : System.Web.UI.Page
    {
        protected class KindLabels
        {
            public string Title, Noun, Hint;
        }

        private string kind = "chapter";

        // the course a new chapter is added to (kind = chapter): one of the signed-in teacher's courses
        private TeacherCourse course;

        // the chapter a new subchapter, quiz or assessment is added to: one of the signed-in teacher's chapters
        private TeacherChapter parent;
        protected KindLabels Labels;

        // Shown instead of the form when the chapter already has a quiz or an assessment
        protected string ExistingTitle, ExistingText, ExistingType, EditUrl;

        /// <summary>True for a quiz or an assessment (they have questions and show the total marks).</summary>
        protected bool HasQuestions
        {
            get { return kind == "quiz" || kind == "assessment"; }
        }

        /// <summary>quiz | assessment: how the question cards are drawn.</summary>
        protected string QuestionMode
        {
            get { return kind; }
        }

        /// <summary>A chapter's duration is in hours (as on Manage Chapters); a subchapter's is in minutes.</summary>
        protected string DurationUnit
        {
            get { return kind == "chapter" ? "hours" : "minutes"; }
        }

        /// <summary>
        /// Where "Back to previous page" goes: a subchapter goes back to the chapter's subchapter list; a quiz or assessment
        /// back to Manage Chapters with that chapter selected; a new chapter back to Manage Chapters for its course.
        /// </summary>
        protected string BackUrl
        {
            get
            {
                int n;
                string chapter = int.TryParse(Request.QueryString["chapter"], out n) && n > 0 ? n.ToString() : "1";
                string shown = int.TryParse(Request.QueryString["n"], out n) && n > 0 ? "&n=" + n : "";
                if (kind == "subchapter") return "TeacherChapterContent.aspx?chapter=" + chapter + shown;
                if (kind == "quiz" || kind == "assessment") return "TeacherChapters.aspx?chapter=" + chapter;
                return int.TryParse(Request.QueryString["course"], out n) && n > 0 ? "TeacherChapters.aspx?course=" + n : "TeacherChapters.aspx";
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            string requested = (Request.QueryString["kind"] ?? "").ToLowerInvariant();
            if (requested == "subchapter" || requested == "quiz" || requested == "assessment") kind = requested;

            switch (kind)
            {
                case "subchapter": Labels = new KindLabels { Title = "Add Subchapter", Noun = "subchapter", Hint = "Add focused learning material to this chapter." }; break;
                case "quiz": Labels = new KindLabels { Title = "Add Quiz", Noun = "quiz", Hint = "Create a short knowledge check for learners." }; break;
                case "assessment": Labels = new KindLabels { Title = "Add Chapter Assessment", Noun = "chapter assessment", Hint = "Create a graded assessment for this chapter." }; break;
                default: Labels = new KindLabels { Title = "Add Chapter", Noun = "chapter", Hint = "Create a new chapter for this course." }; break;
            }

            if (kind == "chapter")
            {
                // a new chapter belongs to the course in ?course=<CourseId> (the teacher's first course when absent)
                course = TeacherCourseData.Pick(TeacherCourseData.GetCourses(), Request.QueryString["course"]);
                if (course == null) Response.Redirect("~/TeacherChapters.aspx");
                bcTeacherChapter.CourseTitle = course.Title;
                bcTeacherChapter.ChapterTitle = "New chapter";
            }
            else
            {
                // ?chapter=<ChapterId>: a chapter of the signed-in teacher's, otherwise back to Manage Chapters
                int chapterId;
                int.TryParse(Request.QueryString["chapter"], out chapterId);
                parent = TeacherChapterData.GetChapter(chapterId);
                if (parent == null) Response.Redirect("~/TeacherChapters.aspx");
                bcTeacherChapter.CourseTitle = parent.CourseTitle;
                bcTeacherChapter.ChapterTitle = "Chapter " + parent.Number + " - " + parent.Title;
            }

            // A chapter has either one quiz or one assessment: if it already has one, offer to edit it instead of adding another
            bool alreadyHasTest = HasQuestions && parent.Test != null;
            pnlTeacherExists.Visible = alreadyHasTest;
            pnlTeacherForm.Visible = !alreadyHasTest;
            if (alreadyHasTest)
            {
                ExistingType = parent.Test.Type;
                ExistingTitle = "Chapter " + parent.Number + " already has " + (parent.Test.Type == "quiz" ? "a quiz" : "an assessment");
                ExistingText = "\"" + parent.Test.Title + "\". A chapter can have either one quiz or one assessment, so edit the existing one, "
                    + "or delete it first if you want the other kind.";
                EditUrl = "TeacherChapterTest.aspx?chapter=" + parent.Id;
            }

            shTeacherDetails.Subtitle = "Add the essential information for this " + Labels.Noun + ".";
            txtTeacherContentTitle.Attributes["placeholder"] = "Enter " + Labels.Noun + " title";
            pnlTeacherDuration.Visible = kind == "chapter" || kind == "subchapter";
            if (kind == "chapter")
            {
                txtTeacherContentDuration.Attributes["min"] = "0.5";
                txtTeacherContentDuration.Attributes["step"] = "0.5";
            }

            bool hasQuestions = kind == "quiz" || kind == "assessment";
            phTeacherQuestions.Visible = hasQuestions;
            if (hasQuestions)
            {
                qcTeacherNewQuestion.Mode = kind;

                // The question cards are plain HTML fields (see TeacherQuestionCard.ascx), rebuilt on every request: after a postback
                // from what was posted (so a refused save loses nothing), otherwise one empty question to start from.
                rptTeacherQuestions.DataSource = IsPostBack
                    ? TeacherQuestion.ReadPosted(Request.Unvalidated.Form, 1)
                    : new List<TeacherQuestion> { TeacherQuestion.Blank() };
                rptTeacherQuestions.DataBind();
            }

            btnTeacherCreateContent.Text = "<svg aria-hidden=\"true\" class=\"icon\" fill=\"none\" height=\"17\" viewBox=\"0 0 24 24\" width=\"17\"><path d='M12 5v14M5 12h14' /></svg><span>Create "
                + Labels.Noun + "</span>";
        }

        protected void btnTeacherCreateContent_Click(object sender, EventArgs e)
        {
            string title = txtTeacherContentTitle.Text.Trim();
            bool titleError = title.Length < 4 || title.Length > 50;
            fldTeacherContentTitle.Attributes["class"] = titleError ? "form-field has-error" : "form-field";
            hintTeacherContentTitle.InnerText = hintTeacherContentTitle.Attributes[titleError ? "data-err" : "data-ok"];
            if (titleError) return;

            string description = reTeacherContentDescription.Text.Trim();
            if (description.Length == 0 && !HasQuestions)
            {
                Master.ShowToast("Enter a description.");
                return;
            }

            // a quiz or assessment is saved with its questions: check them first
            List<TeacherQuestion> questions = null;
            if (HasQuestions)
            {
                questions = TeacherQuestion.ReadPosted(Request.Unvalidated.Form, 1);
                string problem = TeacherTestData.Validate(kind, questions);
                if (problem != null)
                {
                    Master.ShowToast(problem);
                    return;
                }
            }

            // a chapter's duration is in hours (0.5 to 1000); a subchapter's is in whole minutes (1 to 600); a test has none
            decimal hours = 0;
            int minutes = 0;
            if (HasQuestions)
            {
                // no duration
            }
            else if (kind == "chapter")
            {
                if (!decimal.TryParse(txtTeacherContentDuration.Text, System.Globalization.NumberStyles.Number,
                    System.Globalization.CultureInfo.InvariantCulture, out hours) || hours < 0.5m || hours > 1000)
                {
                    Master.ShowToast("Enter a duration between 0.5 and 1000 hours.");
                    return;
                }
            }
            else if (!int.TryParse(txtTeacherContentDuration.Text, System.Globalization.NumberStyles.Integer,
                System.Globalization.CultureInfo.InvariantCulture, out minutes) || minutes < 1 || minutes > TeacherSubChapterData.MaxMinutes)
            {
                Master.ShowToast("Enter a duration between 1 and " + TeacherSubChapterData.MaxMinutes + " minutes.");
                return;
            }

            // the file is saved first so a refused file stops everything; if the row cannot be added the file is removed again
            int courseId = kind == "chapter" ? course.Id : parent.CourseId;
            string mediaLink = null;
            if (dzTeacherContentFile.PostedFile != null)
            {
                string error;
                mediaLink = TeacherMediaStore.Save(dzTeacherContentFile.PostedFile, courseId, out error);
                if (mediaLink == null)
                {
                    Master.ShowToast(error);
                    return;
                }
            }

            int newId;
            bool duplicate = false;
            try
            {
                if (kind == "chapter")
                {
                    duplicate = TeacherChapterData.TitleExists(course.Id, title, 0);
                    newId = TeacherChapterData.CreateChapter(course.Id, title, description, hours, mediaLink);
                }
                else if (kind == "subchapter")
                {
                    newId = TeacherSubChapterData.CreateSubChapter(parent.Id, title, description, minutes, mediaLink);
                }
                else
                {
                    TeacherTestData.CreateResult created = TeacherTestData.CreateTest(parent.Id, kind, title, description, mediaLink, questions, out newId);
                    if (created == TeacherTestData.CreateResult.AlreadyHasTest)
                    {
                        // somebody added one in the meantime: show the "already has" page instead
                        if (mediaLink != null) TeacherMediaStore.Delete(mediaLink);
                        Response.Redirect("~/TeacherChapterAdd.aspx?kind=" + kind + "&chapter=" + parent.Id);
                    }
                }
            }
            catch
            {
                if (mediaLink != null) TeacherMediaStore.Delete(mediaLink);
                throw;
            }
            if (newId == 0)
            {
                if (mediaLink != null) TeacherMediaStore.Delete(mediaLink);
                Response.Redirect("~/TeacherChapters.aspx");
            }

            // back to where the new item is listed, with it selected
            if (kind == "chapter")
            {
                Response.Redirect("~/TeacherChapters.aspx?chapter=" + newId + "&created=" + (duplicate ? "dup" : "1"));
            }
            if (kind == "subchapter")
            {
                Response.Redirect("~/TeacherChapterContent.aspx?chapter=" + parent.Id + "&sub=" + newId + "&created=1");
            }
            Response.Redirect("~/TeacherChapters.aspx?chapter=" + parent.Id + "&testcreated=" + kind);
        }
    }
}
