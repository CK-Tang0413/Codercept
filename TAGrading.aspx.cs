using System;
using System.Collections.Generic;

namespace Codercept
{
    public partial class TAGrading : System.Web.UI.Page
    {
        private List<TeacherCourse> courses;

        private int TaId { get { return Convert.ToInt32(Session["UserId"]); } }

        protected List<TeacherCourse> Courses
        {
            get
            {
                if (courses == null) courses = TAGradingData.GetCourses(TaId);
                return courses;
            }
        }

        private Dictionary<int, TACourseGradingStats> gradingStats;

        protected TACourseGradingStats StatsOf(int courseId)
        {
            if (gradingStats == null) gradingStats = TAGradingData.GetGradingStats(TaId);
            TACourseGradingStats s;
            return gradingStats.TryGetValue(courseId, out s) ? s : new TACourseGradingStats();
        }

        protected int PendingOf(int courseId)
        {
            TACourseGradingStats s = StatsOf(courseId);
            return s.ToMark + s.Draft;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }
    }
}
