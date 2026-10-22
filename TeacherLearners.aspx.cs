using System;
using System.Collections.Generic;
using System.Web;

namespace Codercept
{
    public partial class TeacherLearners : System.Web.UI.Page
    {
        private List<TeacherLearner> learners;

        /// <summary>TODO (backend): learners enrolled in selTeacherCourse.SelectedCourse.</summary>
        protected List<TeacherLearner> Learners
        {
            get
            {
                if (learners == null) learners = TeacherSampleData.GetLearners();
                return learners;
            }
        }

        protected int SelectedLearnerIndex
        {
            get
            {
                int i;
                if (int.TryParse(hfTeacherLearnerIndex.Value, out i) && i >= 0 && i < Learners.Count) return i;
                return 0;
            }
        }

        protected TeacherLearner Learner
        {
            get { return Learners[SelectedLearnerIndex]; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            string picked = Request.Form["tpLearnerPick"];
            if (!string.IsNullOrEmpty(picked)) hfTeacherLearnerIndex.Value = picked;
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            shTeacherLearners.Subtitle = "View learner progress and performance in " + selTeacherCourse.SelectedCourse.Title + ".";
            mdlTeacherRemoveLearner.BodyHtml = "<strong>" + Server.HtmlEncode(Learner.Name) + "</strong> will be removed from this course. "
                + "Their submitted work and progress history will no longer appear in this learner list.";
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
            // TODO (backend): remove Learner (SelectedLearnerIndex) from the selected course
            Master.ShowToast(Learner.Name + " removed from the course");
        }
    }
}
