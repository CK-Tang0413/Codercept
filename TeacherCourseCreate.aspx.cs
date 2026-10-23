using System;
using System.Collections.Generic;
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

            MarkError(fldTeacherTitle, hintTeacherTitle, titleError);
            MarkError(fldTeacherDescription, hintTeacherDescription, descriptionError);
            MarkError(fldTeacherDuration, hintTeacherDuration, durationError);

            if (titleError || descriptionError || durationError) return;

            // TODO (backend): INSERT INTO Course (Title, Description, Language, Difficulty, Duration, TeacherId, ...)
            //   values: txtTeacherCourseTitle.Text, txtTeacherCourseDescription.Text, ddlTeacherCourseLanguage.SelectedValue,
            //           hfTeacherCourseDifficulty.Value, hours, Session["UserId"]
            Master.ShowToast("Course created successfully");
        }

        private static void MarkError(System.Web.UI.HtmlControls.HtmlGenericControl field, System.Web.UI.HtmlControls.HtmlGenericControl hint, bool error)
        {
            field.Attributes["class"] = error ? "form-field has-error" : field.Attributes["class"].Replace(" has-error", "");
            hint.InnerText = error ? hint.Attributes["data-err"] : hint.Attributes["data-ok"];
        }
    }
}
