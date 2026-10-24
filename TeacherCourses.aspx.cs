using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class TeacherCourses : System.Web.UI.Page
    {
        protected TeacherCourse Selected;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString["created"] == "1")
                {
                    Master.ShowToast(Request.QueryString["dup"] == "1"
                        ? "Course created. You already have another course with this title."
                        : "Course created successfully");
                }
                else if (Request.QueryString["deleted"] == "1")
                {
                    Master.ShowToast("Course deleted");
                }
            }

            List<TeacherCourse> courses = TeacherCourseData.GetLanguages();
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
                // a course with no language yet shows a "Select a language" prompt that must be changed before saving
                ListItem prompt = ddlTeacherCourseLanguage.Items.FindByValue("");
                bool noLanguage = Selected.Language == TeacherCourseData.OtherLanguage;
                if (prompt != null && !noLanguage) ddlTeacherCourseLanguage.Items.Remove(prompt);
                if (prompt == null && noLanguage) ddlTeacherCourseLanguage.Items.Insert(0, new ListItem("Select a language", ""));
                ddlTeacherCourseLanguage.SelectedValue = noLanguage ? "" : Selected.Language;
                ctlTeacherDomains.Domains = Selected.Domains;
                MarkError(fldTeacherEditLanguage, hintTeacherEditLanguage, false);
                ctlTeacherDomains.ClearError();
                ddlTeacherCourseDifficulty.SelectedValue = Selected.Difficulty;
                txtTeacherCourseDuration.Text = Selected.Duration.ToString();
            }

            mdlTeacherDeleteCourse.BodyHtml = "This will permanently delete <strong>" + Server.HtmlEncode(Selected.Title)
                + "</strong>, including its chapters, quizzes, and exams. A course that learners are enrolled in cannot be deleted. This action cannot be undone.";
        }

        protected void btnTeacherUpdateCourse_Click(object sender, EventArgs e)
        {
            if (!selTeacherCourse.SelectionIsValid)
            {
                Master.ShowToast("That course could not be found.");
                return;
            }

            bool titleError = txtTeacherCourseTitle.Text.Trim().Length < 4;
            int hours;
            bool durationError = !int.TryParse(txtTeacherCourseDuration.Text, out hours) || hours <= 0;

            string language = ddlTeacherCourseLanguage.SelectedValue;
            bool languageError = TeacherCourseData.GetLanguages().All(l => l.Language != language);

            string domainError;
            List<string> domains = TeacherCourseData.CleanDomains(ctlTeacherDomains.Domains, out domainError);

            MarkError(fldTeacherEditTitle, hintTeacherEditTitle, titleError);
            MarkError(fldTeacherEditDuration, hintTeacherEditDuration, durationError);
            MarkError(fldTeacherEditLanguage, hintTeacherEditLanguage, languageError);
            if (domainError != null) ctlTeacherDomains.ShowError(domainError); else ctlTeacherDomains.ClearError();
            if (titleError || durationError || languageError || domainError != null) return;

            string difficulty = ddlTeacherCourseDifficulty.SelectedValue;
            if (difficulty != "Easy" && difficulty != "Medium" && difficulty != "Hard") difficulty = "Easy";

            bool saved;
            try
            {
                saved = TeacherCourseData.UpdateCourse(selTeacherCourse.SelectedId, txtTeacherCourseTitle.Text.Trim(),
                    txtTeacherCourseDescription.Text, language, difficulty, hours, domains);
            }
            catch (SqlException)
            {
                Master.ShowToast("Could not update the course. Please try again.");
                return;
            }

            if (!saved)
            {
                Master.ShowToast("That course could not be found.");
                return;
            }

            ctlTeacherDomains.Domains = domains; // show the tidied-up list
            selTeacherCourse.Courses = null; // reload so tiles and details show the saved values
            Master.ShowToast("Course details updated");
        }

        private static void MarkError(System.Web.UI.HtmlControls.HtmlGenericControl field, System.Web.UI.HtmlControls.HtmlGenericControl hint, bool error)
        {
            field.Attributes["class"] = error ? "tp-inline-field has-error" : "tp-inline-field";
            hint.InnerText = error ? hint.Attributes["data-err"] : "";
        }

        protected void mdlTeacherDeleteCourse_Confirmed(object sender, EventArgs e)
        {
            if (!selTeacherCourse.SelectionIsValid)
            {
                Master.ShowToast("That course could not be found.");
                return;
            }

            CourseDeleteResult result;
            try
            {
                result = TeacherCourseData.DeleteCourse(selTeacherCourse.SelectedId);
            }
            catch (SqlException)
            {
                Master.ShowToast("Could not delete the course. Please try again.");
                return;
            }

            switch (result)
            {
                case CourseDeleteResult.Deleted:
                    // reload the page so the course list and the details show what is left
                    Response.Redirect("~/TeacherCourses.aspx?deleted=1");
                    break;
                case CourseDeleteResult.HasLearnerData:
                    Master.ShowToast("This course can't be deleted because learners are enrolled in it or have progress, certificates or reviews for it.");
                    break;
                default:
                    Master.ShowToast("That course could not be found.");
                    break;
            }
        }
    }
}
