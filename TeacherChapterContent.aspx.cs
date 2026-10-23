using System;
using System.Collections.Generic;
using System.Linq;

namespace Codercept
{
    public partial class TeacherChapterContent : System.Web.UI.Page
    {
        protected int ChapterId = 1;

        /// <summary>The number the chapter shows (its position in the list as arranged), passed as ?n=; its stored number when absent.</summary>
        protected int ChapterNumber = 1;

        /// <summary>TODO (backend): SubChapter + Quiz rows of the chapter, in display order.</summary>
        protected List<TeacherContentItem> Contents = TeacherSampleData.GetChapterContents();

        protected void Page_Load(object sender, EventArgs e)
        {
            // TODO (backend): load the chapter WHERE ChapterId = @ChapterId AND its course belongs to the signed-in teacher
            int id;
            if (int.TryParse(Request.QueryString["chapter"], out id) && id > 0) ChapterId = id;
            TeacherChapter chapter = TeacherSampleData.GetChapter(ChapterId) ?? TeacherSampleData.GetChapters()[0];
            ChapterId = chapter.Id;
            int shown;
            ChapterNumber = int.TryParse(Request.QueryString["n"], out shown) && shown > 0 ? shown : chapter.Number;
            bcTeacherChapter.CourseTitle = TeacherSampleData.ChapterCourseTitle;
            bcTeacherChapter.ChapterTitle = "Chapter " + ChapterNumber + " - " + chapter.Title;

            if (!IsPostBack)
            {
                txtTeacherSubchapterTitle.Text = Contents[0].Title;
                reTeacherSubchapterDescription.Text = TeacherSampleData.SampleSubchapterDescription;
            }

            // The quiz question cards are plain HTML fields (see TeacherQuestionCard.ascx), rebuilt on every request.
            // TODO (backend): load the quiz's questions from the database
            rptTeacherQuizQuestions.DataSource = TeacherSampleData.GetQuizQuestions();
            rptTeacherQuizQuestions.DataBind();
        }

        protected void btnTeacherUpdateSubchapter_Click(object sender, EventArgs e)
        {
            // TODO (backend): save the subchapter (title, media dzTeacherSubchapterMedia.PostedFile, description)
            //   and, if edited, the quiz questions posted as tpq{n}_text / _marks / _a{m} / _correct
            Master.ShowToast("Subchapter details updated");
        }

        protected void mdlTeacherDeleteSubchapter_Confirmed(object sender, EventArgs e)
        {
            // TODO (backend): delete the subchapter
            Master.ShowToast("Subchapter deleted");
        }
    }
}
