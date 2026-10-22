using System;
using System.Collections.Generic;

namespace Codercept
{
    public partial class TeacherLearnerReport : System.Web.UI.Page
    {
        protected TeacherLearner Learner;

        protected int LearnerIndex;

        // TODO (backend): the course title comes from the selected course (pass courseId in the query string)
        protected string CourseTitle = TeacherSampleData.ReportCourseTitle;

        protected void Page_Load(object sender, EventArgs e)
        {
            List<TeacherLearner> learners = TeacherSampleData.GetLearners();
            int index;
            if (!int.TryParse(Request.QueryString["learner"], out index) || index < 0 || index >= learners.Count) index = 0;
            LearnerIndex = index;
            Learner = learners[index];

            // TODO (backend): load this learner's assessment results for the course
            rptTeacherReportScores.DataSource = TeacherSampleData.GetReportScores();
            rptTeacherReportScores.DataBind();
        }

        protected void btnTeacherSaveReportPdf_Click(object sender, EventArgs e)
        {
            // Same PDF as "Open in new window", sent as a download
            Response.Redirect("TeacherLearnerReportPdf.ashx?download=1&learner=" + LearnerIndex);
        }
    }
}
