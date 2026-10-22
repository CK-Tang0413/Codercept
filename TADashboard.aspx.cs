using System;
using System.Collections.Generic;
using System.Linq;

namespace Codercept
{
    public partial class TADashboard : System.Web.UI.Page
    {
        // 1. Define Dummy Data Structures
        public class DummyGradingItem
        {
            public int AttemptId { get; set; }
            public string LearnerName { get; set; }
            public string Title { get; set; }
            public string Type { get; set; }
            public string Course { get; set; }
            public string Submitted { get; set; }
            public string Status { get; set; }
            public string StatusCss { get; set; }
        }

        public class DummyForumItem
        {
            public int PostId { get; set; }
            public string Title { get; set; }
            public string Author { get; set; }
            public string Posted { get; set; }
            public string Flag { get; set; }
            public string FlagCss { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Security Check
            if (Session["UserType"] == null || Session["UserType"].ToString() != "TA")
            {
                Response.Redirect("signIn.aspx");
                return;
            }

            if (!IsPostBack)
            {
                litWelcomeName.Text = Session["UserName"] != null ? Session["UserName"].ToString() : "Teaching Assistant";

                LoadDashboardData();
            }
        }

        private void LoadDashboardData()
        {
            // 2. Generate Dummy Data
            var gradingQueue = new List<DummyGradingItem>
            {
                new DummyGradingItem { AttemptId = 101, LearnerName = "Alex Chen", Title = "Functions Assessment", Type = "Assessment", Course = "Python for Beginners", Submitted = "2 hours ago", Status = "Pending", StatusCss = "status-pending" },
                new DummyGradingItem { AttemptId = 102, LearnerName = "Mei Ling", Title = "Control Flow Exam", Type = "Exam", Course = "Java Fundamentals", Submitted = "5 hours ago", Status = "In Progress", StatusCss = "status-inprogress" },
                new DummyGradingItem { AttemptId = 103, LearnerName = "Daniel Tan", Title = "Pointers Quiz", Type = "Quiz", Course = "C Programming Essentials", Submitted = "Yesterday", Status = "Returned", StatusCss = "status-returned" },
                new DummyGradingItem { AttemptId = 104, LearnerName = "Sara Ahmad", Title = "Classes Assessment", Type = "Assessment", Course = "C++ Object-Oriented Programming", Submitted = "Yesterday", Status = "Pending", StatusCss = "status-pending" },
                new DummyGradingItem { AttemptId = 105, LearnerName = "Ravi Kumar", Title = "Flexbox Quiz", Type = "Quiz", Course = "Responsive Web Design", Submitted = "2 days ago", Status = "Pending", StatusCss = "status-pending" }
            };

            var forumActivity = new List<DummyForumItem>
            {
                new DummyForumItem { PostId = 11, Title = "Why does my for loop never terminate?", Author = "Alex Chen", Posted = "1 hour ago", Flag = "Unanswered", FlagCss = "flag-unanswered" },
                new DummyForumItem { PostId = 12, Title = "Selling exam answers - DM me", Author = "Anonymous99", Posted = "3 hours ago", Flag = "Reported", FlagCss = "flag-reported" },
                new DummyForumItem { PostId = 13, Title = "Difference between == and equals()?", Author = "Mei Ling", Posted = "Yesterday", Flag = "Unanswered", FlagCss = "flag-unanswered" },
                new DummyForumItem { PostId = 14, Title = "This course is useless", Author = "Daniel Tan", Posted = "Yesterday", Flag = "Reported", FlagCss = "flag-reported" }
            };

            // 3. Bind Grading Queue
            phQueueEmpty.Visible = gradingQueue.Count == 0;
            rptGradingQueue.Visible = gradingQueue.Count > 0;
            rptGradingQueue.DataSource = gradingQueue;
            rptGradingQueue.DataBind();

            // 4. Bind Forum Activity
            phForumEmpty.Visible = forumActivity.Count == 0;
            rptForumActivity.DataSource = forumActivity;
            rptForumActivity.DataBind();

            // 5. Calculate and Bind Overview Stats
            int reported = forumActivity.Count(f => f.Flag == "Reported");
            int unanswered = forumActivity.Count(f => f.Flag == "Unanswered");
            int forumTotal = reported + unanswered;

            litGreetingDesc.Text = $"You have {gradingQueue.Count} submission{(gradingQueue.Count != 1 ? "s" : "")} waiting to be marked and {forumTotal} forum item{(forumTotal != 1 ? "s" : "")} that need attention.";

            litStatPending.Text = gradingQueue.Count.ToString();
            litStatGraded.Text = "18"; // Hardcoded for the dummy view
            litStatReported.Text = reported.ToString();
            litStatUnanswered.Text = unanswered.ToString();
        }
    }
}
