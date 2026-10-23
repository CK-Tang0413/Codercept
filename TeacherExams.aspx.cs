using System;
using System.Collections.Generic;

namespace Codercept
{
    public partial class TeacherExams : System.Web.UI.Page
    {
        private List<TeacherCourse> courses;

        /// <summary>The logged-in teacher's courses. TODO (step 2.5): whether each has an exam.</summary>
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
