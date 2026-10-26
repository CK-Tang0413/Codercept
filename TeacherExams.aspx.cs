using System;
using System.Collections.Generic;

namespace Codercept
{
    public partial class TeacherExams : System.Web.UI.Page
    {
        private List<TeacherCourse> courses;

        /// <summary>The logged-in teacher's courses.</summary>
        protected List<TeacherCourse> Courses
        {
            get
            {
                if (courses == null) courses = TeacherCourseData.GetCourses();
                return courses;
            }
        }

        private HashSet<int> examCourseIds;

        /// <summary>CourseIds of the teacher's courses that have their final exam.</summary>
        protected HashSet<int> ExamCourseIds
        {
            get
            {
                if (examCourseIds == null) examCourseIds = TeacherCourseData.GetCourseIdsWithExam();
                return examCourseIds;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }
    }
}
