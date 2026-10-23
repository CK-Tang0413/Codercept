using System;
using System.Linq;

namespace Codercept
{
    public partial class TeacherDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            litTeacherFirstName.Text = Server.HtmlEncode(Master.UserName.Split(' ')[0]);

            // TODO (backend): replace the sample data with queries for the logged-in teacher
            rptTeacherStats.DataSource = TeacherSampleData.GetDashboardStats();
            rptTeacherStats.DataBind();

            rptTeacherActivities.DataSource = TeacherSampleData.GetRecentActivities();
            rptTeacherActivities.DataBind();

            rptTeacherRecentCourses.DataSource = TeacherCourseData.GetCourses().Take(3).ToList();
            rptTeacherRecentCourses.DataBind();
        }
    }
}
