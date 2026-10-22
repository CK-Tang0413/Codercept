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

        /// <summary>Where "Back to previous page" goes: subchapters and quizzes belong to a chapter's content page.</summary>
        protected string BackUrl
        {
            get
            {
                int n;
                string chapter = int.TryParse(Request.QueryString["chapter"], out n) && n > 0 ? n.ToString() : "1";
                return (kind == "subchapter" || kind == "quiz") ? "TeacherChapterContent.aspx?chapter=" + chapter : "TeacherChapters.aspx";
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
            bcTeacherChapter.CourseTitle = TeacherSampleData.ChapterCourseTitle;
            bcTeacherChapter.ChapterTitle = "Chapter 1 - " + TeacherSampleData.GetChapters()[0].Title;

            shTeacherDetails.Subtitle = "Add the essential information for this " + Labels.Noun + ".";
            txtTeacherContentTitle.Attributes["placeholder"] = "Enter " + Labels.Noun + " title";
            pnlTeacherDuration.Visible = kind == "chapter" || kind == "subchapter";

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
