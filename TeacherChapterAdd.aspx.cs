using System;
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
        protected KindLabels Labels;

        // Shown instead of the form when the chapter already has a quiz or an assessment
        protected string ExistingTitle, ExistingText, ExistingType, EditUrl;

        /// <summary>True for a quiz or an assessment (they have questions and show the total marks).</summary>
        protected bool HasQuestions
        {
            get { return kind == "quiz" || kind == "assessment"; }
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

            // TODO (backend): real course/chapter titles
            // ?chapter=<ChapterId>: the chapter this subchapter / quiz / assessment is added to (the first chapter when absent)
            int chapterId;
            int.TryParse(Request.QueryString["chapter"], out chapterId);
            TeacherChapter chapter = TeacherSampleData.GetChapter(chapterId) ?? TeacherSampleData.GetChapters()[0];
            int shownNumber;
            if (!int.TryParse(Request.QueryString["n"], out shownNumber) || shownNumber <= 0) shownNumber = chapter.Number;
            if (kind == "chapter")
            {
                // a new chapter belongs to the course in ?course=<CourseId> (the teacher's first course when absent)
                TeacherCourse course = TeacherCourseData.Pick(TeacherCourseData.GetCourses(), Request.QueryString["course"]);
                if (course == null) Response.Redirect("~/TeacherChapters.aspx");
                bcTeacherChapter.CourseTitle = course.Title;
                bcTeacherChapter.ChapterTitle = "New chapter";
            }
            else
            {
                bcTeacherChapter.CourseTitle = TeacherSampleData.ChapterCourseTitle;
                bcTeacherChapter.ChapterTitle = "Chapter " + shownNumber + " - " + chapter.Title;
            }

            // A chapter has either one quiz or one assessment: if it already has one, offer to edit it instead of adding another
            bool alreadyHasTest = (kind == "quiz" || kind == "assessment") && chapter.Test != null;
            pnlTeacherExists.Visible = alreadyHasTest;
            pnlTeacherForm.Visible = !alreadyHasTest;
            if (alreadyHasTest)
            {
                ExistingType = chapter.Test.Type;
                ExistingTitle = "Chapter " + shownNumber + " already has " + (chapter.Test.Type == "quiz" ? "a quiz" : "an assessment");
                ExistingText = "\"" + chapter.Test.Title + "\". A chapter can have either one quiz or one assessment, so edit the existing one, "
                    + "or delete it first if you want the other kind.";
                EditUrl = "TeacherChapterTest.aspx?chapter=" + chapter.Id + "&n=" + shownNumber;
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
                qcTeacherFirstQuestion.Mode = kind;
                qcTeacherNewQuestion.Mode = kind;
            }

            btnTeacherCreateContent.Text = "<svg aria-hidden=\"true\" class=\"icon\" fill=\"none\" height=\"17\" viewBox=\"0 0 24 24\" width=\"17\"><path d='M12 5v14M5 12h14' /></svg><span>Create "
                + Labels.Noun + "</span>";
        }

        protected void btnTeacherCreateContent_Click(object sender, EventArgs e)
        {
            // TODO (backend): INSERT the new chapter / SubChapter / Quiz / Assessment with the posted values:
            //   txtTeacherContentTitle, dzTeacherContentFile.PostedFile, reTeacherContentDescription.Text, txtTeacherContentDuration,
            //   and for quizzes/assessments the questions posted as tpq{n}_text / _marks / _a{m} / _correct.
            Master.ShowToast(Labels.Title + " created");
        }
    }
}
