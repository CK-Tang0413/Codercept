using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Codercept
{
    public partial class TeacherLearners : System.Web.UI.Page
    {
        private List<TeacherLearner> learners;

        /// <summary>Show the Add learner dialog again (with its error) after a refused add.</summary>
        protected bool ReopenAddLearner;

        protected string CourseTitle { get { return selTeacherCourse.SelectedCourse.Title; } }

        /// <summary>The learners enrolled in the chosen course (only this teacher's courses return anything).</summary>
        protected List<TeacherLearner> Learners
        {
            get
            {
                if (learners == null) learners = TeacherLearnerData.GetLearners(selTeacherCourse.SelectedCourse.Id);
                return learners;
            }
        }

        /// <summary>
        /// The learner picked in the list (hfTeacherLearnerId holds the LearnerId); the first learner until one is picked or when the id is
        /// not one of this course's learners. Null when nobody is enrolled.
        /// </summary>
        protected TeacherLearner Learner
        {
            get
            {
                int id;
                int.TryParse(hfTeacherLearnerId.Value, out id);
                return Learners.FirstOrDefault(l => l.Id == id) ?? Learners.FirstOrDefault();
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            string picked = Request.Form["tpLearnerPick"];
            if (!string.IsNullOrEmpty(picked)) hfTeacherLearnerId.Value = picked;
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            shTeacherLearners.Subtitle = "View learner progress and performance in " + selTeacherCourse.SelectedCourse.Title + ".";
            // the hidden field always names the learner the page shows, so the next postback acts on exactly that one
            hfTeacherLearnerId.Value = Learner == null ? "" : Learner.Id.ToString();
            if (Learner == null) return; // nobody enrolled: the page shows a message instead
            mdlTeacherRemoveLearner.BodyHtml = "<strong>" + Server.HtmlEncode(Learner.Name) + "</strong> will be removed from this course. "
                + "Their submitted work and progress history will no longer appear in this learner list.";
        }

        /// <summary>A plain value of the profile; "-" (not known) shows as "Not available yet".</summary>
        protected string Plain(string value)
        {
            if (value == "-") return "<span class=\"not-available\">Not available yet</span>";
            return "<strong>" + HttpUtility.HtmlEncode(value) + "</strong>";
        }

        /// <summary>One "icon / label / value" row of the profile. "-" means no data yet.</summary>
        protected string InfoRow(string icon, string label, string value, bool badge)
        {
            string shown;
            if (value == "-") shown = "<span class=\"not-available\">Not available yet</span>";
            else if (badge) shown = "<span class=\"badge badge--success\">" + HttpUtility.HtmlEncode(value) + "</span>";
            else shown = "<strong>" + HttpUtility.HtmlEncode(value) + "</strong>";

            return "<div class=\"learner-info-row\"><span class=\"learner-info-icon\">" + TeacherIcons.Svg(icon, 15) + "</span><span>"
                + HttpUtility.HtmlEncode(label) + "</span>" + shown + "</div>";
        }

        protected void btnTeacherAddLearner_Click(object sender, EventArgs e)
        {
            // a stale or forged course id must not enrol the learner in the first course instead
            if (!selTeacherCourse.SelectionIsValid)
            {
                Master.ShowToast("Choose a course first, so nobody was added.");
                return;
            }

            string email = txtTeacherAddLearnerEmail.Text.Trim();
            int learnerId;
            string name;
            AddLearnerResult result = TeacherLearnerData.AddLearner(selTeacherCourse.SelectedCourse.Id, email, out learnerId, out name);

            string error = null;
            if (result == AddLearnerResult.InvalidEmail) error = "Enter a valid email address.";
            else if (result == AddLearnerResult.NotFound) error = "No active learner account was found for that email.";
            else if (result == AddLearnerResult.AlreadyEnrolled) error = "That learner is already enrolled in this course.";
            else if (result == AddLearnerResult.CourseNotFound) error = "That course could not be found.";

            fldTeacherAddLearner.Attributes["class"] = error == null ? "portal-form-field" : "portal-form-field has-error";
            hintTeacherAddLearner.InnerText = error ?? "";
            if (error != null)
            {
                ReopenAddLearner = true;
                return;
            }

            txtTeacherAddLearnerEmail.Text = "";
            learners = null; // read the list again with them
            hfTeacherLearnerId.Value = learnerId.ToString(); // show the new learner
            Master.ShowToast(name + " added to the course");
        }

        protected void mdlTeacherRemoveLearner_Confirmed(object sender, EventArgs e)
        {
            // Never "the first learner" as a fallback: a stale or forged course id, or a learner id that is not in this course's list (for
            // example a repeated click after they were removed), removes nobody. The page writes the learner it shows into the hidden field
            // on every render, so the id posted here is the one the dialog named.
            int id;
            TeacherLearner learner = selTeacherCourse.SelectionIsValid && int.TryParse(hfTeacherLearnerId.Value, out id)
                ? Learners.FirstOrDefault(l => l.Id == id) : null;
            if (learner == null)
            {
                Master.ShowToast("Choose a course and a learner first, so nobody was removed.");
                return;
            }

            if (TeacherLearnerData.RemoveLearner(selTeacherCourse.SelectedCourse.Id, learner.Id))
            {
                hfTeacherLearnerId.Value = "";
                learners = null; // read the list again without them
                Master.ShowToast(learner.Name + " removed from the course");
            }
            else
            {
                Master.ShowToast(learner.Name + " is not enrolled in this course, so nothing was removed.");
            }
        }
    }
}
