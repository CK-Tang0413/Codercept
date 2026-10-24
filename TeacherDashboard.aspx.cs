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

            rptTeacherStats.DataSource = TeacherDashboardData.GetStats();
            rptTeacherStats.DataBind();

            rptTeacherActivities.DataSource = TeacherDashboardData.GetRecentActivities(4);
            rptTeacherActivities.DataBind();

            rptTeacherRecentCourses.DataSource = TeacherCourseData.GetCourses().Take(3).ToList();
            rptTeacherRecentCourses.DataBind();
        }
    }
}
