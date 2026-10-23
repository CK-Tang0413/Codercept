using System;
using System.Collections.Generic;
using System.Linq;

namespace Codercept
{
    public partial class TeacherCourseSelector : System.Web.UI.UserControl
    {
        private List<TeacherCourse> courses;

        /// <summary>Compact layout (used on the statistics page).</summary>
        public bool Compact { get; set; }

        /// <summary>TODO (backend): load the logged-in teacher's courses from the Course table.</summary>
        public List<TeacherCourse> Courses
        {
            get
            {
                if (courses == null) courses = TeacherSampleData.GetCourses();
                return courses;
            }
            set { courses = value; }
        }

        /// <summary>The CourseId of the chosen tile (the first course when nothing valid was chosen yet).</summary>
        public int SelectedId
        {
            get { return SelectedCourse.Id; }
        }

        public TeacherCourse SelectedCourse
        {
            get
            {
                int id;
                int.TryParse(hfTeacherSelId.Value, out id);
                return Courses.FirstOrDefault(c => c.Id == id) ?? Courses[0];
            }
        }

        /// <summary>True when this request was caused by clicking a course tile.</summary>
        public bool SelectionChanged { get; private set; }

        protected IEnumerable<string> Languages
        {
            get { return Courses.Select(c => c.Language).Distinct(); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            string picked = Request.Form[UniqueID + "$sel"];
            if (!string.IsNullOrEmpty(picked))
            {
                hfTeacherSelId.Value = picked;
                SelectionChanged = true;
            }
        }
    }
}
