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
                    // TODO (backend): chapters of selTeacherChapterCourse.SelectedCourse, ordered by their stored position
                    List<TeacherChapter> all = TeacherSampleData.GetChapters();
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
                return Chapters.FirstOrDefault(c => c.Id == id) ?? Chapters[0];
            }
        }

        /// <summary>The label shown for the active chapter: its position in the list as arranged (1, 2, 3 ...).</summary>
        protected int ActiveNumber
        {
            get { return Chapters.IndexOf(Active) + 1; }
        }

        /// <summary>TODO (backend): SubChapter rows of each chapter (the sample list is the same for every chapter).</summary>
        protected List<TeacherContentItem> Contents
        {
            get { return TeacherSampleData.GetChapterContents(); }
        }

        /// <summary>"1 question", "3 questions".</summary>
        protected static string Plural(int count, string noun)
        {
            return count + " " + noun + (count == 1 ? "" : "s");
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack && Request.QueryString["testdeleted"] == "1") Master.ShowToast("Quiz or assessment deleted");

            // Arriving with ?chapter=<id> (for example back from a quiz or subchapter page) selects that chapter
            int linked;
            if (!IsPostBack && int.TryParse(Request.QueryString["chapter"], out linked) && Chapters.Any(c => c.Id == linked))
            {
                hfTeacherChapterId.Value = linked.ToString();
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

            // Picking a chapter is done in the browser (no postback), so the text boxes already hold what the teacher
            // typed on a postback; they are loaded from the chapter only on the first load or after a different course.
            if (!IsPostBack || selTeacherChapterCourse.SelectionChanged)
            {
                txtTeacherChapterTitle.Text = Active.Title;
                txtTeacherChapterDescription.Text = Active.Description;
                txtTeacherChapterDuration.Text = TeacherSampleData.HoursOf(Active.Duration);
            }

            shTeacherChapters.Subtitle = "Arrange and update content for " + selTeacherChapterCourse.SelectedCourse.Title + ".";
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

            // TODO (backend): UPDATE Chapter SET Title, Description, Duration, DateUpdated WHERE ...;
            //   also persist the new chapter order from hfTeacherChapterOrder (comma-separated ChapterIds).
            // Until then the edit is kept in the session only (see TeacherSampleData.SaveChapterEdit).
            TeacherChapter current = Active;
            TeacherSampleData.SaveChapterEdit(new TeacherChapter
            {
                Id = current.Id,
                Number = current.Number,
                Title = txtTeacherChapterTitle.Text.Trim(),
                Description = txtTeacherChapterDescription.Text,
                Duration = TeacherSampleData.FormatHours(hours),
                Created = current.Created,
                Updated = DateTime.Today.ToString("d MMMM yyyy"),
                Test = current.Test
            });
            chapters = null; // reload so the list and the details show the edit

            Master.ShowToast("Chapter details updated");
        }

        private static void MarkError(System.Web.UI.HtmlControls.HtmlGenericControl field, System.Web.UI.HtmlControls.HtmlGenericControl hint, bool error)
        {
            field.Attributes["class"] = error ? "tp-inline-field has-error" : "tp-inline-field";
            hint.InnerText = error ? hint.Attributes["data-err"] : "";
        }

        protected void mdlTeacherDeleteChapter_Confirmed(object sender, EventArgs e)
        {
            // TODO (backend): delete the active chapter (and its subchapters and its quiz or assessment)
            Master.ShowToast("Chapter " + ActiveNumber + " deleted");
        }
    }
}
