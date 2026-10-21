using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class CourseCatalog : System.Web.UI.Page
    {
        // 1. Define the Dummy Data Structure
        public class DummyCourse
        {
            public int Id { get; set; }
            public string Title { get; set; }
            public string Description { get; set; }
            public string Language { get; set; }
            public string LanguageCSS { get; set; } // Used to match your CSS classes (e.g. "python", "cpp")
            public string Level { get; set; }
            public int Chapters { get; set; }
            public string Duration { get; set; }
            public string Rating { get; set; }
            public bool IsEnrolled { get; set; }
            public int Progress { get; set; }
            public int EnrolledCount { get; set; }
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
                // Set default filters
                ViewState["SelectedLang"] = "All";
                ViewState["SelectedLevel"] = "All";
                BindCourses();
            }
        }

        // 2. Generate the Dummy Data (Simulating a SQL Fetch)
        private List<DummyCourse> GetDummyData()
        {
            return new List<DummyCourse>
            {
                new DummyCourse { Id = 1, Title = "Python for Beginners", Description = "Start your programming journey with Python. Learn syntax, data types, control flow, and functions.", Language = "Python", LanguageCSS = "python", Level = "Beginner", Chapters = 5, Duration = "6h", Rating = "4.8", IsEnrolled = true, Progress = 60, EnrolledCount = 1250 },
                new DummyCourse { Id = 2, Title = "Java Fundamentals", Description = "Master the fundamentals of Java. Learn OOP concepts, type system, control flow, and basics.", Language = "Java", LanguageCSS = "java", Level = "Beginner", Chapters = 6, Duration = "8h", Rating = "4.6", IsEnrolled = true, Progress = 33, EnrolledCount = 980 },
                new DummyCourse { Id = 3, Title = "C Programming Essentials", Description = "Master C programming — the language that powers operating systems and embedded systems.", Language = "C", LanguageCSS = "c", Level = "Intermediate", Chapters = 5, Duration = "8h", Rating = "4.5", IsEnrolled = false, Progress = 0, EnrolledCount = 67 },
                new DummyCourse { Id = 4, Title = "C++ Object-Oriented Programming", Description = "Deep dive into C++ with a focus on OOP principles. Learn classes, inheritance, and polymorphism.", Language = "C++", LanguageCSS = "cpp", Level = "Intermediate", Chapters = 4, Duration = "6h", Rating = "4.7", IsEnrolled = false, Progress = 0, EnrolledCount = 82 },
                new DummyCourse { Id = 5, Title = "Advanced Python — Data Structures", Description = "Level up with Python by mastering data structures and algorithms. Essential prep for technical interviews.", Language = "Python", LanguageCSS = "python", Level = "Advanced", Chapters = 3, Duration = "5h", Rating = "4.9", IsEnrolled = false, Progress = 0, EnrolledCount = 45 },
                new DummyCourse { Id = 6, Title = "Data Structures with C++", Description = "Implement fundamental data structures from scratch in C++: linked lists, binary trees, hash tables.", Language = "C++", LanguageCSS = "cpp", Level = "Advanced", Chapters = 3, Duration = "5h", Rating = "4.4", IsEnrolled = false, Progress = 0, EnrolledCount = 38 }
            };
        }

        // 3. The Core Filtering Engine
        private void BindCourses()
        {
            var courses = GetDummyData();

            string searchTerm = txtSearch.Text.Trim().ToLower();
            string selectedLang = ViewState["SelectedLang"].ToString();
            string selectedLevel = ViewState["SelectedLevel"].ToString();

            // Apply Search Filter
            if (!string.IsNullOrEmpty(searchTerm))
            {
                courses = courses.Where(c => c.Title.ToLower().Contains(searchTerm) || c.Description.ToLower().Contains(searchTerm)).ToList();
            }

            // Apply Language Filter
            if (selectedLang != "All")
            {
                courses = courses.Where(c => c.Language == selectedLang).ToList();
            }

            // Apply Level Filter
            if (selectedLevel != "All")
            {
                courses = courses.Where(c => c.Level == selectedLevel).ToList();
            }

            // Bind to UI
            rptCourses.DataSource = courses;
            rptCourses.DataBind();
            litResultsCount.Text = $"{courses.Count} course{(courses.Count != 1 ? "s" : "")} found";
        }

        // 4. Event Handlers
        protected void txtSearch_TextChanged(object sender, EventArgs e)
        {
            BindCourses();
        }

        protected void FilterLang_Click(object sender, EventArgs e)
        {
            LinkButton clickedBtn = (LinkButton)sender;
            ViewState["SelectedLang"] = clickedBtn.CommandArgument;

            // Reset UI states
            btnLangAll.CssClass = "filter-pill";
            btnLangPython.CssClass = "filter-pill";
            btnLangJava.CssClass = "filter-pill";
            btnLangC.CssClass = "filter-pill";
            btnLangCpp.CssClass = "filter-pill";

            // Set active class on clicked button
            clickedBtn.CssClass = "filter-pill active";

            BindCourses();
        }

        protected void FilterLevel_Click(object sender, EventArgs e)
        {
            LinkButton clickedBtn = (LinkButton)sender;
            ViewState["SelectedLevel"] = clickedBtn.CommandArgument;

            // Reset UI states
            btnLevelAll.CssClass = "filter-pill";
            btnLevelBeginner.CssClass = "filter-pill";
            btnLevelIntermediate.CssClass = "filter-pill";
            btnLevelAdvanced.CssClass = "filter-pill";

            // Set active class on clicked button
            clickedBtn.CssClass = "filter-pill active";

            BindCourses();
        }
    }
}