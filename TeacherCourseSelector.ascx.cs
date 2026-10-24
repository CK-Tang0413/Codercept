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

        /// <summary>The signed-in teacher's courses (Course WHERE TeacherId = @TeacherId).</summary>
        public List<TeacherCourse> Courses
        {
            get
            {
                if (courses == null) courses = TeacherCourseData.GetCourses();
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

        /// <summary>
        /// False when the posted course id is not one of this teacher's courses (a forged or stale id). Showing falls back
        /// to the first course, but anything that changes data must stop instead of acting on a different course.
        /// </summary>
        public bool SelectionIsValid
        {
            get
            {
                if (string.IsNullOrEmpty(hfTeacherSelId.Value)) return true; // nothing picked yet: the first course
                int id;
                return int.TryParse(hfTeacherSelId.Value, out id) && Courses.Any(c => c.Id == id);
            }
        }

        /// <summary>Chooses a course by id before the page is built; an id that is not one of this teacher's courses is ignored.</summary>
        public void Select(int courseId)
        {
            if (Courses.Any(c => c.Id == courseId)) hfTeacherSelId.Value = courseId.ToString();
        }

        /// <summary>True when this request was caused by clicking a course tile.</summary>
        public bool SelectionChanged { get; private set; }

        protected IEnumerable<string> Languages
        {
            get { return Courses.Select(c => c.Language).Distinct(); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // A teacher with no courses has nothing to select: send them to create one
            if (Courses.Count == 0) Response.Redirect("~/TeacherCourseCreate.aspx");

            // Arriving with ?course=<id> (for example after creating a course) selects that course
            int linked;
            if (!IsPostBack && string.IsNullOrEmpty(hfTeacherSelId.Value)
                && int.TryParse(Request.QueryString["course"], out linked) && Courses.Any(c => c.Id == linked))
            {
                hfTeacherSelId.Value = linked.ToString();
            }

            // A posted id that is not one of this teacher's courses is simply not found, so the first course is shown
            string picked = Request.Form[UniqueID + "$sel"];
            if (!string.IsNullOrEmpty(picked))
            {
                hfTeacherSelId.Value = picked;
                SelectionChanged = true;
            }
        }
    }
}
