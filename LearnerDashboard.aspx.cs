using System;
using System.Collections.Generic;
using System.Linq;

namespace Codercept
{
    public partial class LearnerDashboard : System.Web.UI.Page
    {
        // 1. Define Dummy Data Structures
        public class DummyActiveCourse
        {
            public int Id { get; set; }
            public string Title { get; set; }
            public string Language { get; set; }
            public int Progress { get; set; }
            public string NextChapter { get; set; }
            public int ChaptersCompleted { get; set; } // Used to calculate dashboard stats
        }

        public class DummyRecommendedCourse
        {
            public int Id { get; set; }
            public string Title { get; set; }
            public string Description { get; set; }
            public string Language { get; set; }
            public string Level { get; set; }
            public int Chapters { get; set; }
            public string Rating { get; set; }
            public int EnrolledCount { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Security Check
            if (Session["UserType"] == null || (Session["UserType"].ToString() != "Learner" && Session["UserType"].ToString() != "Guest"))
            {
                Response.Redirect("signIn.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string fullName = Session["UserName"] != null ? Session["UserName"].ToString() : "Guest";
                litWelcomeName.Text = fullName;

                LoadDashboardData();
            }
        }

        private void LoadDashboardData()
        {
            bool isGuest = Session["UserType"].ToString() == "Guest";

            // 2. Generate Dummy Data
            var activeCourses = new List<DummyActiveCourse>
            {
                new DummyActiveCourse { Id = 1, Title = "Python for Beginners", Language = "Python", Progress = 60, NextChapter = "Functions", ChaptersCompleted = 3 },
                new DummyActiveCourse { Id = 2, Title = "Java Fundamentals", Language = "Java", Progress = 33, NextChapter = "Control Flow", ChaptersCompleted = 2 }
            };

            var recommendedCourses = new List<DummyRecommendedCourse>
            {
                new DummyRecommendedCourse { Id = 3, Title = "C Programming Essentials", Description = "Master C programming — the language that powers operating systems and embedded systems. Learn pointers, memory management, and more.", Language = "C", Level = "Intermediate", Chapters = 5, Rating = "4.5", EnrolledCount = 67 },
                new DummyRecommendedCourse { Id = 4, Title = "C++ Object-Oriented Programming", Description = "Deep dive into C++ with a focus on OOP principles. Learn classes, inheritance, polymorphism, and templates.", Language = "C++", Level = "Intermediate", Chapters = 4, Rating = "4.7", EnrolledCount = 82 },
                new DummyRecommendedCourse { Id = 5, Title = "Responsive Web Design", Description = "Start building beautiful, responsive websites from scratch using modern HTML5 and CSS3 techniques like Flexbox.", Language = "HTML/CSS", Level = "Beginner", Chapters = 6, Rating = "4.9", EnrolledCount = 124 }
            };

            // 3. Bind Recommended Courses (Visible to everyone)
            rptRecommended.DataSource = recommendedCourses;
            rptRecommended.DataBind();

            if (isGuest)
            {
                phLearnerData.Visible = false;
                litGreetingDesc.Text = "Explore our course catalog to find your next skill. Create a free account to track your progress!";
                recommendationHeader.InnerText = "Explore Our Courses";
            }
            else
            {
                phLearnerData.Visible = true;

                // 4. Bind Active Courses
                rptActiveCourses.DataSource = activeCourses;
                rptActiveCourses.DataBind();

                // 5. Calculate and Bind Overview Stats
                int totalEnrolled = activeCourses.Count;
                int totalChaptersDone = activeCourses.Sum(c => c.ChaptersCompleted);
                int avgProgress = totalEnrolled > 0 ? (int)activeCourses.Average(c => c.Progress) : 0;

                litGreetingDesc.Text = $"You have {totalEnrolled} active course{(totalEnrolled != 1 ? "s" : "")}. Keep up the momentum!";

                litStatEnrolled.Text = totalEnrolled.ToString();
                litStatChapters.Text = totalChaptersDone.ToString();
                litStatProgress.Text = $"{avgProgress}%";
                litStatAvgScore.Text = "83%"; // Hardcoded average score for the dummy view
            }
        }
    }
}