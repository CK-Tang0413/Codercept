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
            // TODO (backend): remove Learner.Id from the selected course (DELETE FROM LearnerProgress WHERE LearnerId = @LearnerId AND CourseId = @CourseId, with the course owned by the teacher)
            Master.ShowToast(Learner.Name + " removed from the course");
        }
    }
}
