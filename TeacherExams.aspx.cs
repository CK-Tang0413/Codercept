using System;
using System.Collections.Generic;

namespace Codercept
{
    public partial class TeacherExams : System.Web.UI.Page
    {
        private List<TeacherCourse> courses;

        /// <summary>TODO (backend): the logged-in teacher's courses, with whether each has an exam.</summary>
        protected List<TeacherCourse> Courses
        {
            get
            {
                if (courses == null) courses = TeacherSampleData.GetCourses();
                return courses;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }
    }
}
