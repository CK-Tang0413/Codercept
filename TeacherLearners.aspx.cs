using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Codercept
{
    public partial class TeacherLearners : System.Web.UI.Page
    {
        private List<TeacherLearner> learners;

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
            // TODO (backend): open/process "add learner to course" (INSERT enrolment)
            Master.ShowToast("Add learner selected");
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
