using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Script.Serialization;

namespace Codercept
{
    public partial class TeacherCourseCreate : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            List<TeacherCourse> courses = TeacherCourseData.GetLanguages();
            if (!IsPostBack)
            {
                foreach (string language in courses.Select(c => c.Language).Distinct())
                {
                    ddlTeacherCourseLanguage.Items.Add(language);
                }
            }

            // Lets TeacherPortal.js update the live preview card (thumbnail theme + glyph) per language
            var map = courses.GroupBy(c => c.Language).ToDictionary(g => g.Key, g => new { theme = g.First().Theme, glyph = g.First().Glyph });
            ddlTeacherCourseLanguage.Attributes["data-tp-lang-map"] = new JavaScriptSerializer().Serialize(map);
        }

        protected void btnTeacherCreateCourse_Click(object sender, EventArgs e)
        {
            // Same rules as the client-side check in TeacherPortal.js (server side is the real gate)
            bool titleError = txtTeacherCourseTitle.Text.Trim().Length < 4;
            bool descriptionError = txtTeacherCourseDescription.Text.Trim().Length < 20;
            int hours;
            bool durationError = !int.TryParse(txtTeacherCourseDuration.Text, out hours) || hours <= 0;

            string domainError;
            List<string> domains = TeacherCourseData.CleanDomains(ctlTeacherDomains.Domains, out domainError);
            if (domainError != null) ctlTeacherDomains.ShowError(domainError); else ctlTeacherDomains.ClearError();

            MarkError(fldTeacherTitle, hintTeacherTitle, titleError);
            MarkError(fldTeacherDescription, hintTeacherDescription, descriptionError);
            MarkError(fldTeacherDuration, hintTeacherDuration, durationError);

            if (titleError || descriptionError || durationError || domainError != null) return;

            string language = ddlTeacherCourseLanguage.SelectedValue;
            if (TeacherCourseData.GetLanguages().All(l => l.Language != language))
            {
                Master.ShowToast("Please choose a programming language.");
                return;
            }

            string difficulty = hfTeacherCourseDifficulty.Value;
            if (difficulty != "Easy" && difficulty != "Medium" && difficulty != "Hard") difficulty = "Easy";

            string title = txtTeacherCourseTitle.Text.Trim();
            // Two courses may share a title, but the teacher is told about it
            bool duplicate = TeacherCourseData.GetCourses().Any(c => string.Equals(c.Title, title, StringComparison.OrdinalIgnoreCase));

            int courseId;
            try
            {
                courseId = TeacherCourseData.CreateCourse(title, txtTeacherCourseDescription.Text.Trim(), language, difficulty, hours, domains);
            }
            catch (SqlException)
            {
                Master.ShowToast("Could not create the course. Please try again.");
                return;
            }

            // Manage Courses, with the new course selected (and a toast there)
            Response.Redirect("~/TeacherCourses.aspx?course=" + courseId + "&created=1" + (duplicate ? "&dup=1" : ""));
        }

        private static void MarkError(System.Web.UI.HtmlControls.HtmlGenericControl field, System.Web.UI.HtmlControls.HtmlGenericControl hint, bool error)
        {
            field.Attributes["class"] = error ? "form-field has-error" : field.Attributes["class"].Replace(" has-error", "");
            hint.InnerText = error ? hint.Attributes["data-err"] : hint.Attributes["data-ok"];
        }
    }
}
