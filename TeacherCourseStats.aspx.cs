using System;

namespace Codercept
{
    public partial class TeacherCourseStats : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            shTeacherResults.Subtitle = "Viewing results for " + selTeacherCourse.SelectedCourse.Title + ".";

            // TODO (backend): load statistics for selTeacherCourse.SelectedCourse
            rptTeacherCourseStats.DataSource = TeacherSampleData.GetCourseStatisticRows();
            rptTeacherCourseStats.DataBind();

            rptTeacherMetrics.DataSource = TeacherSampleData.GetPerformanceMetrics();
            rptTeacherMetrics.DataBind();

            rptTeacherGradeBars.DataSource = TeacherSampleData.GetGradeDistribution();
            rptTeacherGradeBars.DataBind();

            rptTeacherGradeLegend.DataSource = TeacherSampleData.GetGradeDistribution();
            rptTeacherGradeLegend.DataBind();
        }

        protected void btnTeacherSaveCourseStatsPdf_Click(object sender, EventArgs e)
        {
            // TODO (backend): generate and stream the course statistics PDF
            Master.ShowToast("Course statistics PDF is ready");
        }

        protected void btnTeacherSavePerformanceStatsPdf_Click(object sender, EventArgs e)
        {
            // TODO (backend): generate and stream the performance statistics PDF
            Master.ShowToast("Performance statistics PDF is ready");
        }
    }
}
