using System;
using System.Collections.Generic;

namespace Codercept
{
    public partial class TeacherGrading : System.Web.UI.Page
    {
        private List<TeacherCourse> courses;

        /// <summary>TODO (backend): the logged-in teacher's courses with their pending submission counts.</summary>
        protected List<TeacherCourse> Courses
        {
            get
            {
                if (courses == null) courses = TeacherCourseData.GetCourses();
                return courses;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }
    }
}
