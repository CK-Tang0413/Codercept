using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;

namespace Codercept
{
    public partial class TeacherChapterContent : System.Web.UI.Page
    {
        protected int ChapterId;

        /// <summary>The number the chapter shows: its position in its course.</summary>
        protected int ChapterNumber;

        private TeacherChapter chapter;
        private List<TeacherContentItem> contents;

        /// <summary>The chapter's subchapters in the order shown (the teacher's drag moves are kept in hfTeacherContentOrder until saved).</summary>
        protected List<TeacherContentItem> Contents
        {
            get
            {
                if (contents == null)
                {
                    List<TeacherContentItem> all = TeacherSubChapterData.GetSubChapters(ChapterId);
                    List<int> order = ParseIds(hfTeacherContentOrder.Value);
                    contents = all.OrderBy(c => order.IndexOf(c.Id) < 0 ? int.MaxValue : order.IndexOf(c.Id)).ToList();
                }
                return contents;
            }
        }

        protected TeacherContentItem Active
        {
            get
            {
                int id;
                int.TryParse(hfTeacherSubchapterId.Value, out id);
                return Contents.FirstOrDefault(c => c.Id == id) ?? Contents.FirstOrDefault();
            }
        }

        /// <summary>The label shown for the active subchapter: its position in the list as arranged (1, 2, 3 ...).</summary>
        protected int ActiveNumber
        {
            get { return Contents.IndexOf(Active) + 1; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // ?chapter=<ChapterId>: a chapter of the signed-in teacher's, otherwise back to Manage Chapters
            int id;
            int.TryParse(Request.QueryString["chapter"], out id);
            chapter = TeacherChapterData.GetChapter(id);
            if (chapter == null) Response.Redirect("~/TeacherChapters.aspx");
            ChapterId = chapter.Id;
            ChapterNumber = chapter.Number;
            bcTeacherChapter.CourseTitle = chapter.CourseTitle;
            bcTeacherChapter.ChapterTitle = "Chapter " + ChapterNumber + " - " + chapter.Title;

            if (!IsPostBack)
            {
                string notice = Request.QueryString["created"];
                if (notice == "1") Master.ShowToast("Subchapter created");
                if (Request.QueryString["subdeleted"] == "1") Master.ShowToast("Subchapter deleted");

                // ?sub=<SubChapterId> (for example right after adding one) selects that subchapter
                int linked;
                if (int.TryParse(Request.QueryString["sub"], out linked) && Contents.Any(c => c.Id == linked))
                {
                    hfTeacherSubchapterId.Value = linked.ToString();
                }
            }
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (Contents.Count == 0) return;

            // The hidden field must name the subchapter that is shown, so Update / Delete act on it even if nothing was clicked
            if (!IsPostBack) hfTeacherSubchapterId.Value = Active.Id.ToString();

            // Picking a subchapter is done in the browser (no postback), so after a postback the boxes already hold what the teacher typed
            if (!IsPostBack)
            {
                txtTeacherSubchapterTitle.Text = Active.Title;
                reTeacherSubchapterDescription.Text = Active.Description;
                txtTeacherSubchapterDuration.Text = Active.Minutes.ToString(CultureInfo.InvariantCulture);
            }

            mdlTeacherDeleteSubchapter.BodyHtml = "This will permanently delete <strong data-tp-sub-delete-name>" + Server.HtmlEncode(Active.Title)
                + "</strong> and its file. This action cannot be undone.";
        }

        protected void btnTeacherUpdateSubchapter_Click(object sender, EventArgs e)
        {
            string title = txtTeacherSubchapterTitle.Text.Trim();
            bool titleError = title.Length < 4 || title.Length > 50;
            fldTeacherSubchapterTitle.Attributes["class"] = titleError ? "form-field has-error" : "form-field";
            hintTeacherSubchapterTitle.InnerText = hintTeacherSubchapterTitle.Attributes[titleError ? "data-err" : "data-ok"];
            if (titleError) return;

            string description = reTeacherSubchapterDescription.Text.Trim();
            if (description.Length == 0)
            {
                Master.ShowToast("Enter a description.");
                return;
            }

            int minutes;
            if (!int.TryParse(txtTeacherSubchapterDuration.Text, NumberStyles.Integer, CultureInfo.InvariantCulture, out minutes)
                || minutes < 1 || minutes > TeacherSubChapterData.MaxMinutes)
            {
                Master.ShowToast("Enter a duration between 1 and " + TeacherSubChapterData.MaxMinutes + " minutes.");
                return;
            }

            // the subchapter to save is the one posted, never "the first one" when the id is not in this chapter's list
            TeacherContentItem sub = PostedSubchapter();
            if (sub == null)
            {
                Master.ShowToast("That subchapter was not found. Reload the page and try again.");
                return;
            }

            // the file: a chosen file replaces it, "Remove file" clears it, otherwise it stays as it is
            string newMedia = null;
            bool changeMedia = false;
            if (dzTeacherSubchapterMedia.PostedFile != null)
            {
                string error;
                newMedia = TeacherMediaStore.Save(dzTeacherSubchapterMedia.PostedFile, chapter.CourseId, out error);
                if (newMedia == null)
                {
                    Master.ShowToast(error);
                    return;
                }
                changeMedia = true;
            }
            else if (hfTeacherSubchapterMediaRemove.Value == "1")
            {
                changeMedia = true;
            }
            hfTeacherSubchapterMediaRemove.Value = "";

            bool orderChanged;
            string oldMedia;
            TeacherChapterData.SaveResult result;
            try
            {
                result = TeacherSubChapterData.UpdateSubChapter(ChapterId, sub.Id, title, description, minutes, ParseIds(hfTeacherContentOrder.Value),
                    changeMedia, newMedia, out oldMedia, out orderChanged);
            }
            catch
            {
                if (newMedia != null) TeacherMediaStore.Delete(newMedia);
                throw;
            }
            contents = null; // reload so the list and the editor show what is stored

            if (result != TeacherChapterData.SaveResult.Saved)
            {
                if (newMedia != null) TeacherMediaStore.Delete(newMedia); // nothing was saved, so the new file is not kept
            }
            else if (changeMedia)
            {
                TeacherMediaStore.Delete(oldMedia); // replaced or removed: the old file goes
            }

            if (result == TeacherChapterData.SaveResult.NotFound)
            {
                Master.ShowToast("That subchapter was not found. Reload the page and try again.");
                return;
            }
            if (result == TeacherChapterData.SaveResult.OrderMismatch)
            {
                hfTeacherContentOrder.Value = "";
                Master.ShowToast("The subchapter list has changed, so nothing was saved. Reload the page and try again.");
                return;
            }
            Master.ShowToast("Subchapter details updated");
        }

        protected void mdlTeacherDeleteSubchapter_Confirmed(object sender, EventArgs e)
        {
            TeacherContentItem sub = PostedSubchapter();
            if (sub == null)
            {
                Master.ShowToast("That subchapter was not found. Reload the page and try again.");
                return;
            }

            string file;
            if (TeacherSubChapterData.DeleteSubChapter(sub.Id, out file) != TeacherChapterData.DeleteResult.Deleted)
            {
                Master.ShowToast("That subchapter was not found. Reload the page and try again.");
                return;
            }

            TeacherMediaStore.Delete(file); // the row is gone, so its file goes too
            Response.Redirect("~/TeacherChapterContent.aspx?chapter=" + ChapterId + "&subdeleted=1");
        }

        /// <summary>The subchapter named by the posted hfTeacherSubchapterId if it is one of this chapter's subchapters, otherwise null.</summary>
        private TeacherContentItem PostedSubchapter()
        {
            int id;
            return int.TryParse(hfTeacherSubchapterId.Value, out id) ? Contents.FirstOrDefault(c => c.Id == id) : null;
        }

        private static List<int> ParseIds(string commaSeparated)
        {
            List<int> ids = new List<int>();
            foreach (string part in (commaSeparated ?? "").Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
            {
                int id;
                if (int.TryParse(part, out id)) ids.Add(id);
            }
            return ids;
        }
    }
}
