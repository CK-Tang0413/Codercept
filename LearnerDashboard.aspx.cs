using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace Codercept
{
    public partial class LearnerDashboard : System.Web.UI.Page
    {
        // Grab the connection string from Web.config
        string connString = ConfigurationManager.ConnectionStrings["Codercept_DB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
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

            LoadRecommendedCourses();

            if (isGuest)
            {
                phLearnerData.Visible = false;
                litGreetingDesc.Text = "Explore our course catalog to find your next skill. Create a free account to track your progress!";
                recommendationHeader.InnerText = "Explore Our Courses";
            }
            else
            {
                phLearnerData.Visible = true;

                // Assuming your login page sets Session["UserId"] to the LearnerId
                int learnerId = Convert.ToInt32(Session["UserId"]);

                LoadActiveCourses(learnerId);
                LoadDashboardStats(learnerId);
            }
        }

        private void LoadActiveCourses(int learnerId)
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                // Joins LearnerProgress, Course, Chapter, and fetches the Primary Subject
                string query = @"
                    SELECT TOP 3
                        c.CourseId, 
                        c.CourseTitle,
                        lp.ChapNum,
                        (SELECT COUNT(*) FROM Chapter WHERE CourseId = c.CourseId) as TotalChapters,
                        (SELECT TOP 1 s.SubjectName FROM CourseSubject cs JOIN Subject s ON cs.SubjectId = s.SubjectId WHERE cs.CourseId = c.CourseId AND s.SubjectType = 'Language') as PrimarySubject,
                        ISNULL((SELECT ChapterTitle FROM Chapter WHERE CourseId = c.CourseId AND ChapterNum = lp.ChapNum), 'Course Completed') as NextChapterTitle
                    FROM LearnerProgress lp
                    JOIN Course c ON lp.CourseId = c.CourseId
                    WHERE lp.LearnerId = @LearnerId
                    ORDER BY lp.EnrolledDate DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // Add dynamic progress percentage column for the UI bar
                    dt.Columns.Add("ProgressPercentage", typeof(int));
                    foreach (DataRow row in dt.Rows)
                    {
                        int currentChapter = Convert.ToInt32(row["ChapNum"]);
                        int totalChapters = Convert.ToInt32(row["TotalChapters"]);

                        // Calculate percentage: e.g. Chapter 3 of 5 means 2 chapters done (40%)
                        int chaptersCompleted = currentChapter - 1;
                        if (currentChapter > totalChapters) chaptersCompleted = totalChapters;

                        int progress = totalChapters > 0 ? (chaptersCompleted * 100) / totalChapters : 0;
                        row["ProgressPercentage"] = progress;
                    }

                    rptActiveCourses.DataSource = dt;
                    rptActiveCourses.DataBind();

                    litGreetingDesc.Text = $"You have {dt.Rows.Count} active course{(dt.Rows.Count != 1 ? "s" : "")}. Keep up the momentum!";
                }
            }
        }

        private void LoadDashboardStats(int learnerId)
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                // 1. Get Enrolled Courses & Total Chapters Done
                string progressQuery = @"
                    SELECT 
                        COUNT(CourseId) as TotalEnrolled,
                        SUM(ChapNum - 1) as TotalChaptersDone
                    FROM LearnerProgress 
                    WHERE LearnerId = @LearnerId";

                using (SqlCommand cmd = new SqlCommand(progressQuery, con))
                {
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            litStatEnrolled.Text = reader["TotalEnrolled"] != DBNull.Value ? reader["TotalEnrolled"].ToString() : "0";
                            litStatChapters.Text = reader["TotalChaptersDone"] != DBNull.Value ? reader["TotalChaptersDone"].ToString() : "0";
                        }
                    }
                    con.Close();
                }

                // 2. Get Average Score from Results table
                string avgQuery = @"
                    SELECT AVG(Average) as OverallAverage 
                    FROM Result r
                    JOIN Attempt a ON r.AttemptId = a.AttemptId
                    WHERE a.LearnerId = @LearnerId";

                using (SqlCommand cmd = new SqlCommand(avgQuery, con))
                {
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    litStatAvgScore.Text = (result != DBNull.Value && result != null) ? $"{Convert.ToDouble(result):F0}%" : "0%";
                    con.Close();
                }

                // 3. Get Total Progress (Average of all course completion percentages)
                string totalProgressQuery = @"
                    SELECT 
                        ISNULL(SUM(lp.ChapNum - 1), 0) as ChaptersDone,
                        ISNULL(SUM(c.TotalChaps), 0) as TotalChapsRequired
                    FROM LearnerProgress lp
                    JOIN (SELECT CourseId, COUNT(*) as TotalChaps FROM Chapter GROUP BY CourseId) c 
                        ON lp.CourseId = c.CourseId
                    WHERE lp.LearnerId = @LearnerId";

                using (SqlCommand cmd = new SqlCommand(totalProgressQuery, con))
                {
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            int done = Convert.ToInt32(reader["ChaptersDone"]);
                            int required = Convert.ToInt32(reader["TotalChapsRequired"]);

                            int totalProgress = required > 0 ? (done * 100) / required : 0;
                            litStatProgress.Text = $"{totalProgress}%";
                        }
                    }
                    con.Close();
                }
            }
        }

        private void LoadRecommendedCourses()
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                // Fetch top 3 highest rated courses
                string query = @"
                    SELECT TOP 3 
                        c.CourseId, 
                        c.CourseTitle, 
                        c.CourseDescription, 
                        c.DifficultyLevel as Level,
                        (SELECT COUNT(*) FROM Chapter WHERE CourseId = c.CourseId) as Chapters,
                        ISNULL((SELECT TOP 1 s.SubjectName FROM CourseSubject cs JOIN Subject s ON cs.SubjectId = s.SubjectId WHERE cs.CourseId = c.CourseId AND s.SubjectType = 'Language'), 'General') as Language,
                        ISNULL((SELECT COUNT(*) FROM LearnerProgress WHERE CourseId = c.CourseId), 0) as EnrolledCount,
                        ISNULL((SELECT ROUND(AVG(Rating), 1) FROM Course_Review WHERE CourseId = c.CourseId), 0.0) as Rating
                    FROM Course c
                    ORDER BY Rating DESC, EnrolledCount DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    rptRecommended.DataSource = dt;
                    rptRecommended.DataBind();
                }
            }
        }
    }
}