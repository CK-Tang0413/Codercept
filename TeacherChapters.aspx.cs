using System;
using System.Collections.Generic;
using System.Linq;

namespace Codercept
{
    public partial class TeacherChapters : System.Web.UI.Page
    {
        private List<TeacherChapter> chapters;

        /// <summary>The selected course's chapters in the order shown (the teacher's up/down moves are kept in hfTeacherChapterOrder).</summary>
        protected List<TeacherChapter> Chapters
        {
            get
            {
                if (chapters == null)
                {
                    List<TeacherChapter> all = TeacherChapterData.GetChapters(selTeacherChapterCourse.SelectedId);
                    List<int> order = new List<int>();
                    foreach (string part in hfTeacherChapterOrder.Value.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
                    {
                        int id;
                        if (int.TryParse(part, out id)) order.Add(id);
                    }
                    chapters = all.OrderBy(c => order.IndexOf(c.Id) < 0 ? int.MaxValue : order.IndexOf(c.Id)).ToList();
                }
                return chapters;
            }
        }

        protected TeacherChapter Active
        {
            get
            {
                int id;
                int.TryParse(hfTeacherChapterId.Value, out id);
                return Chapters.FirstOrDefault(c => c.Id == id) ?? Chapters.FirstOrDefault();
            }
        }

        /// <summary>The label shown for the active chapter: its position in the list as arranged (1, 2, 3 ...).</summary>
        protected int ActiveNumber
        {
            get { return Chapters.IndexOf(Active) + 1; }
        }

        /// <summary>"1 question", "3 questions".</summary>
        protected static string Plural(int count, string noun)
        {
            return count + " " + noun + (count == 1 ? "" : "s");
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && Request.QueryString["testdeleted"] == "1") Master.ShowToast("Quiz or assessment deleted");

            // The course and chapter are chosen here, before the course selector loads, so the chapter list is read for the right course.
            // ?course=<id> chooses the course; ?chapter=<id> (for example back from a quiz or subchapter page) chooses that
            // chapter, and its course when ?course= is missing. Ids that are not this teacher's are ignored.
            if (!IsPostBack)
            {
                int linkedCourse;
                if (int.TryParse(Request.QueryString["course"], out linkedCourse)) selTeacherChapterCourse.Select(linkedCourse);

                int linked;
                if (int.TryParse(Request.QueryString["chapter"], out linked))
                {
                    if (string.IsNullOrEmpty(Request.QueryString["course"]))
                    {
                        int courseOfChapter = TeacherChapterData.GetCourseIdOfChapter(linked);
                        if (courseOfChapter > 0) selTeacherChapterCourse.Select(courseOfChapter);
                    }
                    if (Chapters.Any(c => c.Id == linked)) hfTeacherChapterId.Value = linked.ToString();
                }
            }
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            // A different course means start again from its first chapter
            if (selTeacherChapterCourse.SelectionChanged)
            {
                hfTeacherChapterId.Value = "";
                hfTeacherChapterOrder.Value = "";
                chapters = null;
            }

            // A course without chapters shows a short message and the Add chapter button instead of the chapter list (see the page)
            shTeacherChapters.Subtitle = "Arrange and update content for " + selTeacherChapterCourse.SelectedCourse.Title + ".";
            if (Chapters.Count == 0) return;

            // Picking a chapter is done in the browser (no postback), so the text boxes already hold what the teacher
            // typed on a postback; they are loaded from the chapter only on the first load or after a different course.
            if (!IsPostBack || selTeacherChapterCourse.SelectionChanged)
            {
                txtTeacherChapterTitle.Text = Active.Title;
                txtTeacherChapterDescription.Text = Active.Description;
                txtTeacherChapterDuration.Text = TeacherSampleData.HoursOf(Active.Duration);
            }

            mdlTeacherDeleteChapter.BodyHtml = "This will permanently delete <strong data-tp-ch-delete-name>Chapter " + ActiveNumber + " - " + Server.HtmlEncode(Active.Title)
                + "</strong>, including its subchapters and its quiz or assessment. This action cannot be undone.";
        }

        protected void btnTeacherUpdateChapter_Click(object sender, EventArgs e)
        {
            bool titleError = txtTeacherChapterTitle.Text.Trim().Length < 4;
            decimal hours;
            bool durationError = !decimal.TryParse(txtTeacherChapterDuration.Text, System.Globalization.NumberStyles.Number,
                System.Globalization.CultureInfo.InvariantCulture, out hours) || hours <= 0;

            MarkError(fldTeacherChapterTitle, hintTeacherChapterTitle, titleError);
            MarkError(fldTeacherChapterDuration, hintTeacherChapterDuration, durationError);
            if (titleError || durationError) return;

            // TODO (step 3.2): UPDATE Chapter SET Title, Description, Duration, DateUpdate WHERE ChapterId = @ChapterId AND its course is
            //   the signed-in teacher's; also persist the new chapter order from hfTeacherChapterOrder (comma-separated ChapterIds).
            Master.ShowToast("Saving chapter changes is added in the next step, so nothing was saved.");
        }

        private static void MarkError(System.Web.UI.HtmlControls.HtmlGenericControl field, System.Web.UI.HtmlControls.HtmlGenericControl hint, bool error)
        {
            field.Attributes["class"] = error ? "tp-inline-field has-error" : "tp-inline-field";
            hint.InnerText = error ? hint.Attributes["data-err"] : "";
        }

        protected void mdlTeacherDeleteChapter_Confirmed(object sender, EventArgs e)
        {
            // TODO (step 3.2): delete the active chapter (and its subchapters and its quiz or assessment), checking ownership in SQL
            Master.ShowToast("Deleting chapters is added in the next step, so nothing was deleted.");
        }
    }
}
