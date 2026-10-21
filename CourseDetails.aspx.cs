using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class CourseDetails : System.Web.UI.Page
    {
        // 1. Define Dummy Data Structures
        public class DummyTag
        {
            public string Name { get; set; }
            public string CssClass { get; set; }
            public string Icon { get; set; }
            public string CustomStyle { get; set; }
        }

        public class DummyChapter
        {
            public int Id { get; set; }
            public string Title { get; set; }
            public string Duration { get; set; }
            public string Status { get; set; } // "Completed", "Active", "Locked"
            public List<DummyTag> Tags { get; set; }
        }

        public class DummyCourseDetail
        {
            public int Id { get; set; }
            public string Title { get; set; }
            public string Description { get; set; }
            public string Language { get; set; }
            public string Level { get; set; }
            public bool IsFeatured { get; set; }
            public string Instructor { get; set; }
            public string Duration { get; set; }
            public int EnrolledCount { get; set; }
            public string Rating { get; set; }
            public bool IsEnrolled { get; set; }
            public int Progress { get; set; }
            public List<DummyChapter> Chapters { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserType"] == null || (Session["UserType"].ToString() != "Learner" && Session["UserType"].ToString() != "Guest"))
            {
                Response.Redirect("signIn.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadCourseDetails();
            }
        }

        private void LoadCourseDetails()
        {
            // Get ID from URL (e.g., CourseDetails.aspx?id=1). Default to 1 if missing.
            int courseId = 1;
            if (Request.QueryString["id"] != null)
            {
                int.TryParse(Request.QueryString["id"], out courseId);
            }

            // Fetch Dummy Data
            var course = GetDummyCourse(courseId);
            if (course == null) return;

            // Check if Guest
            bool isGuest = Session["UserType"].ToString() == "Guest";

            // Force enrollment to false if they are a guest
            bool userIsEnrolled = isGuest ? false : course.IsEnrolled;

            // Bind Hero Text
            litTitle.Text = course.Title;
            litDescription.Text = course.Description;
            litInstructor.Text = course.Instructor;
            litChapterCount.Text = $"{course.Chapters.Count} chapters";
            litDuration.Text = course.Duration;
            litEnrolledCount.Text = course.EnrolledCount.ToString("N0");
            litRating.Text = course.Rating;

            // Bind Hero Badges
            string badges = $"<span class='badge badge-lang'>{course.Language}</span> <span class='badge badge-level'>{course.Level}</span>";
            if (course.IsFeatured) badges += " <span class='badge badge-featured'>Featured</span>";
            litTags.Text = badges;

            // Setup Enrollment State
            if (userIsEnrolled)
            {
                pnlEnrolledProgress.Visible = true;
                litProgressText.Text = $"{course.Progress}%";
                pnlProgressBarFill.Style.Add("width", $"{course.Progress}%");

                btnCourseAction.Text = "Continue Learning ->";
                btnCourseAction.OnClientClick = ""; // Standard server-side redirect
            }
            else
            {
                pnlEnrolledProgress.Visible = false;
                btnCourseAction.Text = "Enroll Now";

                if (isGuest)
                {
                    // Guests get the modal
                    btnCourseAction.OnClientClick = "showGuestModal(); return false;";
                }
                else
                {
                    // Learners trigger a server click to "enroll"
                    btnCourseAction.OnClientClick = "";
                }
            }

            // Bind Chapters
            rptChapters.DataSource = course.Chapters;
            rptChapters.DataBind();
        }

        protected void btnCourseAction_Click(object sender, EventArgs e)
        {
            // If they are enrolled, go to viewer. If not, this is where you'd run an SQL INSERT to enroll them.
            Response.Redirect("CourseViewer.aspx");
        }

        // 3. Helper Methods for Repeater Inline DataBinding
        protected string GetChapterUrl(string status)
        {
            if (Session["UserType"].ToString() == "Guest") return "javascript:showGuestModal();";
            if (status == "Locked") return "javascript:void(0);"; // Prevent clicking locked items
            return "CourseViewer.aspx?chapter=1";
        }

        protected string GetChapterStyle(string status)
        {
            if (status == "Active") return "border-color: rgba(124, 58, 237, 0.4);";
            if (status == "Locked") return "opacity: 0.6; cursor: not-allowed;";
            return "";
        }

        protected string GetStatusIcon(string status, int index)
        {
            if (status == "Completed")
                return "<svg xmlns='http://www.w3.org/2000/svg' width='18' height='18' fill='none' viewBox='0 0 24 24' stroke='currentColor'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2.5' d='M5 13l4 4L19 7' /></svg>";
            if (status == "Active")
                return "<svg xmlns='http://www.w3.org/2000/svg' width='18' height='18' fill='currentColor' viewBox='0 0 16 16'><path d='M10.804 8 5 4.633v6.734L10.804 8zm.792-.696a.802.802 0 0 1 0 1.392l-6.363 3.692C4.713 12.69 4 12.345 4 11.692V4.308c0-.653.713-.998 1.233-.696l6.363 3.692z'/></svg>";

            // For locked, return the chapter number padded (e.g., "04")
            return status == "Locked" ? index.ToString("D2") : "";
        }

        protected string GetActionIcon(string status)
        {
            if (status == "Locked")
                return "<svg class='ch-icon' xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='currentColor'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z' /></svg>";

            return "<svg class='ch-icon' xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='currentColor'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M9 5l7 7-7 7' /></svg>";
        }

        // 4. Generate the Dummy Data
        private DummyCourseDetail GetDummyCourse(int id)
        {
            // 1. Create a base course object
            var course = new DummyCourseDetail
            {
                Id = id,
                Chapters = new List<DummyChapter>()
            };

            // 2. Set the details based on the exact ID from the Catalog
            switch (id)
            {
                case 1:
                    course.Title = "Python for Beginners";
                    course.Description = "Start your programming journey with Python. Learn syntax, data types, control flow, and functions through hands-on exercises and real projects.";
                    course.Language = "Python";
                    course.Level = "Beginner";
                    course.IsFeatured = true;
                    course.Instructor = "Dr. Sarah Park";
                    course.Duration = "6h total";
                    course.EnrolledCount = 1250;
                    course.Rating = "4.8/5.0";
                    course.IsEnrolled = true;
                    course.Progress = 60;
                    break;

                case 2:
                    course.Title = "Java Fundamentals";
                    course.Description = "Master the fundamentals of Java, the backbone of enterprise software. Learn OOP concepts, type system, control flow, and basics.";
                    course.Language = "Java";
                    course.Level = "Beginner";
                    course.IsFeatured = false;
                    course.Instructor = "Prof. Alan Turing";
                    course.Duration = "8h total";
                    course.EnrolledCount = 980;
                    course.Rating = "4.6/5.0";
                    course.IsEnrolled = true;
                    course.Progress = 33;
                    break;

                case 3:
                    course.Title = "C Programming Essentials";
                    course.Description = "Master C programming — the language that powers operating systems and embedded systems.";
                    course.Language = "C";
                    course.Level = "Intermediate";
                    course.IsFeatured = false;
                    course.Instructor = "Dr. Linus Torvalds";
                    course.Duration = "8h total";
                    course.EnrolledCount = 67;
                    course.Rating = "4.5/5.0";
                    course.IsEnrolled = false;
                    course.Progress = 0;
                    break;

                default:
                    // Fallback for ID 4, 5, 6 (C++ and Advanced courses)
                    course.Title = "C++ Object-Oriented Programming";
                    course.Description = "Deep dive into C++ with a focus on OOP principles. Learn classes, inheritance, polymorphism, and templates.";
                    course.Language = "C++";
                    course.Level = "Intermediate";
                    course.IsFeatured = false;
                    course.Instructor = "Prof. Bjarne Stroustrup";
                    course.Duration = "6h total";
                    course.EnrolledCount = 82;
                    course.Rating = "4.7/5.0";
                    course.IsEnrolled = false;
                    course.Progress = 0;
                    break;
            }

            // 3. Generate chapters based on whether they are enrolled or not
            if (course.IsEnrolled)
            {
                course.Chapters.Add(new DummyChapter { Id = 1, Title = "Introduction", Duration = "45 min", Status = "Completed", Tags = new List<DummyTag> { new DummyTag { Name = "Theory", CssClass = "theory", Icon = "📄" }, new DummyTag { Name = "Video", CssClass = "video", Icon = "▶️" } } });
                course.Chapters.Add(new DummyChapter { Id = 2, Title = "Variables & Data Types", Duration = "60 min", Status = course.Progress >= 50 ? "Completed" : "Active", Tags = new List<DummyTag> { new DummyTag { Name = "Theory", CssClass = "theory", Icon = "📄" }, new DummyTag { Name = "Quiz", CssClass = "quiz", Icon = "⚡" } } });
                course.Chapters.Add(new DummyChapter { Id = 3, Title = "Control Flow", Duration = "75 min", Status = course.Progress >= 50 ? "Active" : "Locked", Tags = new List<DummyTag> { new DummyTag { Name = "Theory", CssClass = "theory", Icon = "📄" }, new DummyTag { Name = "Coding", CssClass = "coding", Icon = "💻" } } });
                course.Chapters.Add(new DummyChapter { Id = 4, Title = "Functions & Modules", Duration = "90 min", Status = "Locked", Tags = new List<DummyTag> { new DummyTag { Name = "Theory", CssClass = "theory", Icon = "📄" }, new DummyTag { Name = "Coding", CssClass = "coding", Icon = "💻" } } });
            }
            else
            {
                // If unenrolled, lock all chapters
                course.Chapters.Add(new DummyChapter { Id = 1, Title = "Introduction", Duration = "45 min", Status = "Locked", Tags = new List<DummyTag> { new DummyTag { Name = "Theory", CssClass = "theory", Icon = "📄" }, new DummyTag { Name = "Video", CssClass = "video", Icon = "▶️" } } });
                course.Chapters.Add(new DummyChapter { Id = 2, Title = "Core Concepts", Duration = "60 min", Status = "Locked", Tags = new List<DummyTag> { new DummyTag { Name = "Theory", CssClass = "theory", Icon = "📄" }, new DummyTag { Name = "Quiz", CssClass = "quiz", Icon = "⚡" } } });
                course.Chapters.Add(new DummyChapter { Id = 3, Title = "Advanced Applications", Duration = "75 min", Status = "Locked", Tags = new List<DummyTag> { new DummyTag { Name = "Theory", CssClass = "theory", Icon = "📄" }, new DummyTag { Name = "Coding", CssClass = "coding", Icon = "💻" } } });
            }

            return course;
        }
    }
}