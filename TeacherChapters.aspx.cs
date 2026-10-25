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
            if (!IsPostBack)
            {
                string notice = Request.QueryString["created"];
                if (notice == "1") Master.ShowToast("Chapter created");
                else if (notice == "dup") Master.ShowToast("Chapter created. Another chapter in this course has the same title.");
                if (Request.QueryString["chapterdeleted"] == "1") Master.ShowToast("Chapter deleted");
                if (Request.QueryString["testcreated"] == "quiz") Master.ShowToast("Quiz created");
                if (Request.QueryString["testcreated"] == "assessment") Master.ShowToast("Assessment created");
                if (Request.QueryString["testdeleted"] == "1") Master.ShowToast("Quiz or assessment deleted");
            }

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

            // The hidden field must name the chapter that is shown, so Update / Delete act on it even if nothing was clicked
            if (!IsPostBack || selTeacherChapterCourse.SelectionChanged) hfTeacherChapterId.Value = Active.Id.ToString();

            // Picking a chapter is done in the browser (no postback), so the text boxes already hold what the teacher
            // typed on a postback; they are loaded from the chapter only on the first load or after a different course.
            if (!IsPostBack || selTeacherChapterCourse.SelectionChanged)
            {
                txtTeacherChapterTitle.Text = Active.Title;
                txtTeacherChapterDescription.Text = Active.Description;
                txtTeacherChapterDuration.Text = TeacherChapterData.HoursOf(Active.Duration);
            }

            mdlTeacherDeleteChapter.BodyHtml = "This will permanently delete <strong data-tp-ch-delete-name>Chapter " + ActiveNumber + " - " + Server.HtmlEncode(Active.Title)
                + "</strong>, including its subchapters, its files and its quiz or assessment."
                + (TeacherChapterData.CourseHasLearners(selTeacherChapterCourse.SelectedId) ? " Enrolled learners keep their progress; it moves up with the chapters that remain." : "")
                + " This action cannot be undone.";
        }

        protected void btnTeacherUpdateChapter_Click(object sender, EventArgs e)
        {
            string title = txtTeacherChapterTitle.Text.Trim();
            bool titleError = title.Length < 4 || title.Length > 50;
            decimal hours;
            bool durationError = !decimal.TryParse(txtTeacherChapterDuration.Text, System.Globalization.NumberStyles.Number,
                System.Globalization.CultureInfo.InvariantCulture, out hours) || hours < 0.5m || hours > 1000;

            MarkError(fldTeacherChapterTitle, hintTeacherChapterTitle, titleError);
            MarkError(fldTeacherChapterDuration, hintTeacherChapterDuration, durationError);
            if (titleError || durationError) return;

            // The chapter to save is the one posted, never "the first one" when the id is not in this course's list
            TeacherChapter chapter = PostedChapter();
            if (!selTeacherChapterCourse.SelectionIsValid || chapter == null)
            {
                Master.ShowToast("That chapter was not found. Reload the page and try again.");
                return;
            }

            int courseId = selTeacherChapterCourse.SelectedId;
            bool duplicate = TeacherChapterData.TitleExists(courseId, title, chapter.Id);

            // the order the teacher arranged (moves are kept in hfTeacherChapterOrder and saved together with the details)
            List<int> order = new List<int>();
            foreach (string part in hfTeacherChapterOrder.Value.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
            {
                int id;
                if (int.TryParse(part, out id)) order.Add(id);
            }

            // the chapter's file: a chosen file replaces it, "Remove file" clears it, otherwise it stays as it is
            string newMedia = null;
            bool changeMedia = false;
            if (dzTeacherChapterFile.PostedFile != null)
            {
                string error;
                newMedia = TeacherMediaStore.Save(dzTeacherChapterFile.PostedFile, courseId, out error);
                if (newMedia == null)
                {
                    Master.ShowToast(error);
                    return;
                }
                changeMedia = true;
            }
            else if (hfTeacherChapterMediaRemove.Value == "1")
            {
                changeMedia = true;
            }
            hfTeacherChapterMediaRemove.Value = "";

            bool orderChanged;
            string oldMedia;
            TeacherChapterData.SaveResult result;
            try
            {
                result = TeacherChapterData.UpdateChapter(courseId, chapter.Id, title, txtTeacherChapterDescription.Text, hours, order,
                    changeMedia, newMedia, out oldMedia, out orderChanged);
            }
            catch
            {
                if (newMedia != null) TeacherMediaStore.Delete(newMedia);
                throw;
            }
            chapters = null; // reload so the list and the details show what is stored

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
                Master.ShowToast("That chapter was not found. Reload the page and try again.");
                return;
            }
            if (result == TeacherChapterData.SaveResult.OrderMismatch)
            {
                hfTeacherChapterOrder.Value = "";
                Master.ShowToast("The chapter list has changed, so nothing was saved. Reload the page and try again.");
                return;
            }

            string message = "Chapter details updated";
            if (duplicate) message += ". Another chapter in this course has the same title.";
            if (orderChanged && TeacherChapterData.CourseHasLearners(courseId))
            {
                message += ". Learners are enrolled: their saved progress is kept by chapter position, so check it after moving chapters.";
            }
            Master.ShowToast(message);
        }

        /// <summary>The chapter named by the posted hfTeacherChapterId if it is one of the selected course's chapters, otherwise null.</summary>
        private TeacherChapter PostedChapter()
        {
            int id;
            return int.TryParse(hfTeacherChapterId.Value, out id) ? Chapters.FirstOrDefault(c => c.Id == id) : null;
        }

        private static void MarkError(System.Web.UI.HtmlControls.HtmlGenericControl field, System.Web.UI.HtmlControls.HtmlGenericControl hint, bool error)
        {
            field.Attributes["class"] = error ? "tp-inline-field has-error" : "tp-inline-field";
            hint.InnerText = error ? hint.Attributes["data-err"] : "";
        }

        protected void mdlTeacherDeleteChapter_Confirmed(object sender, EventArgs e)
        {
            TeacherChapter chapter = PostedChapter();
            if (!selTeacherChapterCourse.SelectionIsValid || chapter == null)
            {
                Master.ShowToast("That chapter was not found. Reload the page and try again.");
                return;
            }

            List<string> files;
            TeacherChapterData.DeleteResult result = TeacherChapterData.DeleteChapter(chapter.Id, out files);
            if (result == TeacherChapterData.DeleteResult.HasAttempts)
            {
                Master.ShowToast("This chapter cannot be deleted because learners have attempted its quiz or assessment. Their results are kept.");
                return;
            }
            if (result == TeacherChapterData.DeleteResult.NotFound)
            {
                Master.ShowToast("That chapter was not found. Reload the page and try again.");
                return;
            }

            foreach (string file in files) TeacherMediaStore.Delete(file); // the rows are gone, so their files go too
            Response.Redirect("~/TeacherChapters.aspx?course=" + selTeacherChapterCourse.SelectedId + "&chapterdeleted=1");
        }
    }
}
