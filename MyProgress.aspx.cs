using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class MyProgress : System.Web.UI.Page
    {
        // 1. Define Dummy Data Structure
        public class DummyProgress
        {
            public string CourseName { get; set; }
            public string Language { get; set; }
            public string LangClass { get; set; } // Matches your CSS (e.g., "lang-python")
            public int Progress { get; set; }
            public string QuizAvg { get; set; }
            public string CodeAvg { get; set; }
            public string Grade { get; set; }

            // Auto-calculate the CSS class based on the Grade letter
            public string GradeClass
            {
                get
                {
                    if (Grade == "A") return "grade-a";
                    if (Grade == "B") return "grade-b";
                    if (Grade == "C") return "grade-c";
                    if (Grade == "D") return "grade-d";
                    if (Grade == "F") return "grade-f";
                    return ""; // For "-" or pending grades
                }
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserType"] == null || Session["UserType"].ToString() != "Learner")
            {
                Response.Redirect("signIn.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadProgressData();
            }
        }

        private void LoadProgressData()
        {
            // 2. Generate Dummy Data
            var progressList = new List<DummyProgress>
            {
                new DummyProgress
                {
                    CourseName = "Python for Beginners",
                    Language = "Python",
                    LangClass = "lang-python",
                    Progress = 60,
                    QuizAvg = "90%",
                    CodeAvg = "85%",
                    Grade = "B"
                },
                new DummyProgress
                {
                    CourseName = "Java Fundamentals",
                    Language = "Java",
                    LangClass = "lang-java",
                    Progress = 33,
                    QuizAvg = "67%",
                    CodeAvg = "–",
                    Grade = "D"
                }
            };

            // 3. Bind to the UI Grid
            rptGrades.DataSource = progressList;
            rptGrades.DataBind();

            // 4. Calculate Overview Stats dynamically based on the list
            int activeCount = progressList.Count(p => p.Progress > 0 && p.Progress < 100);
            int completedCount = progressList.Count(p => p.Progress == 100);

            litActiveCourses.Text = activeCount.ToString();
            litCompletedCourses.Text = completedCount.ToString();

            // Hardcoded averages for the dummy view
            litQuizAvg.Text = "82%";
            litCodeAvg.Text = "85%";
        }
    }
}