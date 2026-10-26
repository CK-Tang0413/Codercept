using System;
using System.Collections.Generic;

namespace Codercept
{
    public partial class TeacherGrading : System.Web.UI.Page
    {
        private List<TeacherCourse> courses;

        /// <summary>The logged-in teacher's courses (see PendingOf for their pending submission counts).</summary>
        protected List<TeacherCourse> Courses
        {
            get
            {
                if (courses == null) courses = TeacherCourseData.GetCourses();
                return courses;
            }
        }

        private Dictionary<int, int> pendingCounts;

        /// <summary>Submissions waiting for grading in a course (0 when none).</summary>
        protected int PendingOf(int courseId)
        {
            if (pendingCounts == null) pendingCounts = TeacherCourseData.GetPendingCounts();
            int count;
            return pendingCounts.TryGetValue(courseId, out count) ? count : 0;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }
    }
}
