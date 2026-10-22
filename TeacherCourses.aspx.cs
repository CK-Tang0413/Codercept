using System;
using System.Collections.Generic;
using System.Linq;

namespace Codercept
{
    public partial class TeacherCourses : System.Web.UI.Page
    {
        protected TeacherCourse Selected;

        protected void Page_Load(object sender, EventArgs e)
        {
            // TODO (backend): load the programming languages from the database
            List<TeacherCourse> courses = TeacherSampleData.GetCourses();
            if (!IsPostBack)
            {
                foreach (string language in courses.Select(c => c.Language).Distinct())
                {
                    ddlTeacherCourseLanguage.Items.Add(language);
                }
            }

        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            Selected = selTeacherCourse.SelectedCourse;

            // Load the form from the course only when the page first loads or a different course was just picked
            if (!IsPostBack || selTeacherCourse.SelectionChanged)
            {
                txtTeacherCourseTitle.Text = Selected.Title;
                txtTeacherCourseDescription.Text = Selected.Description;
                ddlTeacherCourseLanguage.SelectedValue = Selected.Language;
                ddlTeacherCourseDifficulty.SelectedValue = Selected.Difficulty;
                txtTeacherCourseDuration.Text = Selected.Duration.ToString();
            }

            mdlTeacherDeleteCourse.BodyHtml = "This will permanently delete <strong>" + Server.HtmlEncode(Selected.Title)
                + "</strong>, including its chapters, quizzes, and learner records. This action cannot be undone.";
        }

        protected void btnTeacherUpdateCourse_Click(object sender, EventArgs e)
        {
            bool titleError = txtTeacherCourseTitle.Text.Trim().Length < 4;
            int hours;
            bool durationError = !int.TryParse(txtTeacherCourseDuration.Text, out hours) || hours <= 0;

            MarkError(fldTeacherEditTitle, hintTeacherEditTitle, titleError);
            MarkError(fldTeacherEditDuration, hintTeacherEditDuration, durationError);
            if (titleError || durationError) return;

            string difficulty = ddlTeacherCourseDifficulty.SelectedValue;
            if (difficulty != "Easy" && difficulty != "Medium" && difficulty != "Hard") difficulty = "Easy";

            // TODO (backend): UPDATE Course SET Title, Description, Language, Difficulty, Duration, DateUpdated WHERE CourseId = ...
            // Until then the edit is kept in the session only (see TeacherSampleData.SaveCourseEdit).
            TeacherCourse current = selTeacherCourse.SelectedCourse;
            TeacherCourse language = TeacherSampleData.GetCourses().First(c => c.Language == ddlTeacherCourseLanguage.SelectedValue);
            TeacherSampleData.SaveCourseEdit(selTeacherCourse.SelectedIndex, new TeacherCourse
            {
                Title = txtTeacherCourseTitle.Text.Trim(),
                Description = txtTeacherCourseDescription.Text,
                Language = language.Language,
                Glyph = language.Glyph,
                Theme = language.Theme,
                Difficulty = difficulty,
                Duration = hours,
                Date = current.Date,
                Learners = current.Learners,
                Updated = DateTime.Today.ToString("d MMMM yyyy")
            });
            selTeacherCourse.Courses = null; // reload so tiles and details show the edit

            Master.ShowToast("Course details updated");
        }

        private static void MarkError(System.Web.UI.HtmlControls.HtmlGenericControl field, System.Web.UI.HtmlControls.HtmlGenericControl hint, bool error)
        {
            field.Attributes["class"] = error ? "tp-inline-field has-error" : "tp-inline-field";
            hint.InnerText = error ? hint.Attributes["data-err"] : "";
        }

        protected void mdlTeacherDeleteCourse_Confirmed(object sender, EventArgs e)
        {
            // TODO (backend): delete the course (and its chapters, quizzes and learner records)
            Master.ShowToast(selTeacherCourse.SelectedCourse.Title + " deleted");
        }
    }
}
