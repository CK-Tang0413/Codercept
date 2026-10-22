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
                        int n;
                        if (int.TryParse(part, out n)) order.Add(n);
                    }
                    chapters = all.OrderBy(c => order.IndexOf(c.Number) < 0 ? int.MaxValue : order.IndexOf(c.Number)).ToList();
                }
                return chapters;
            }
        }

        protected TeacherChapter Active
        {
            get
            {
                int n;
                int.TryParse(hfTeacherChapterNumber.Value, out n);
                return Chapters.FirstOrDefault(c => c.Number == n) ?? Chapters[0];
            }
        }

        /// <summary>TODO (backend): SubChapter + Quiz rows of the active chapter.</summary>
        protected List<TeacherContentItem> Contents
        {
            get { return TeacherSampleData.GetChapterContents(); }
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            // A different course means start again from its first chapter
            if (selTeacherChapterCourse.SelectionChanged)
            {
                hfTeacherChapterNumber.Value = "1";
                hfTeacherChapterOrder.Value = "";
                chapters = null;
            }

            string key = hfTeacherChapterNumber.Value;
            bool chapterChanged = !IsPostBack || ViewState["tpChapter"] as string != key || selTeacherChapterCourse.SelectionChanged;
            ViewState["tpChapter"] = key;
            if (chapterChanged)
            {
                txtTeacherChapterTitle.Text = Active.Title;
                txtTeacherChapterDescription.Text = Active.Description;
                txtTeacherChapterDuration.Text = TeacherSampleData.HoursOf(Active.Duration);
            }

            shTeacherChapters.Subtitle = "Arrange and update content for " + selTeacherChapterCourse.SelectedCourse.Title + ".";
            mdlTeacherDeleteChapter.BodyHtml = "This will permanently delete <strong>Chapter " + Active.Number + " - " + Server.HtmlEncode(Active.Title)
                + "</strong>, including its subchapters and quizzes. This action cannot be undone.";
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
            //   also persist the new chapter order from hfTeacherChapterOrder (comma-separated chapter numbers).
            // Until then the edit is kept in the session only (see TeacherSampleData.SaveChapterEdit).
            TeacherChapter current = Active;
            TeacherSampleData.SaveChapterEdit(new TeacherChapter
            {
                Number = current.Number,
                Title = txtTeacherChapterTitle.Text.Trim(),
                Description = txtTeacherChapterDescription.Text,
                Duration = TeacherSampleData.FormatHours(hours),
                Created = current.Created,
                Updated = DateTime.Today.ToString("d MMMM yyyy")
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
            // TODO (backend): delete the active chapter (and its subchapters and quizzes)
            Master.ShowToast("Chapter " + Active.Number + " deleted");
        }
    }
}
