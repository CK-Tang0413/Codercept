using System;
using System.Collections.Generic;
using System.Linq;

namespace Codercept
{
    public partial class TeacherLearnerReport : System.Web.UI.Page
    {
        protected TeacherLearner Learner;

        protected int LearnerId;

        // TODO (backend): the course title comes from the selected course (pass courseId in the query string)
        protected string CourseTitle = TeacherSampleData.ReportCourseTitle;

        protected void Page_Load(object sender, EventArgs e)
        {
            List<TeacherLearner> learners = TeacherSampleData.GetLearners();
            int id;
            int.TryParse(Request.QueryString["learner"], out id);
            // TODO (backend): unknown learner, or one not enrolled in this teacher's courses -> redirect
            Learner = learners.FirstOrDefault(l => l.Id == id) ?? learners[0];
            LearnerId = Learner.Id;

            // TODO (backend): load this learner's assessment results for the course
            rptTeacherReportScores.DataSource = TeacherSampleData.GetReportScores();
            rptTeacherReportScores.DataBind();
        }

        protected void btnTeacherSaveReportPdf_Click(object sender, EventArgs e)
        {
            // Same PDF as "Open in new window", sent as a download
            Response.Redirect("TeacherLearnerReportPdf.ashx?download=1&learner=" + LearnerId);
        }
    }
}
