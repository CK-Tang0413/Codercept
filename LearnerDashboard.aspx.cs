using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace Codercept
{
    public partial class LearnerDashboard : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["Codercept_DB"].ConnectionString;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserType"] == null || Session["UserType"].ToString() != "Learner")
            {
                Response.Redirect("LandingPage.aspx");
                return;
            }

            if (!IsPostBack)
            {
                string fullName = Session["UserName"] != null ? Session["UserName"].ToString() : "Learner";
                litWelcomeName.Text = fullName;

                LoadDashboardData();
                LoadNotifications();
            }
        }

        private void LoadNotifications()
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = @"
                    SELECT [NotificationId], [Title], [Content], [Type], [DateTime]
                    FROM [dbo].[Notification]
                    ORDER BY [DateTime] DESC, [NotificationId] DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    SqlDataAdapter sda = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    sda.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptNotifications.DataSource = dt;
                        rptNotifications.DataBind();

                        int maxId = 0;
                        foreach (DataRow row in dt.Rows)
                        {
                            int currentId = Convert.ToInt32(row["NotificationId"]);
                            if (currentId > maxId) maxId = currentId;
                        }

                        hfLatestNotifId.Value = maxId.ToString();
                        pnlNotifBadge.Visible = true;
                        litNotifCount.Text = dt.Rows.Count.ToString();
                        pnlNoNotifications.Visible = false;
                    }
                    else
                    {
                        hfLatestNotifId.Value = "0";
                        pnlNotifBadge.Visible = false;
                        pnlNoNotifications.Visible = true;
                    }
                }
            }
        }

        private void LoadDashboardData()
        {
            LoadRecommendedCourses();
            phLearnerData.Visible = true;

            int learnerId = Convert.ToInt32(Session["UserId"]);
            LoadActiveCourses(learnerId);
            LoadDashboardStats(learnerId);
        }

        private void LoadActiveCourses(int learnerId)
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                // Added c.DifficultyLevel and renamed PrimarySubject to Language to match Eval()
                string query = @"
                    SELECT TOP 3
                        c.CourseId, 
                        c.CourseTitle,
                        c.DifficultyLevel,
                        lp.ChapNum,
                        (SELECT COUNT(*) FROM Chapter WHERE CourseId = c.CourseId) as TotalChapters,
                        ISNULL((SELECT TOP 1 s.SubjectName FROM CourseSubject cs JOIN Subject s ON cs.SubjectId = s.SubjectId WHERE cs.CourseId = c.CourseId AND s.SubjectType = 'Language'), 'General') as Language,
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

                    dt.Columns.Add("ProgressPercentage", typeof(int));
                    dt.Columns.Add("LanguageCSS", typeof(string));

                    foreach (DataRow row in dt.Rows)
                    {
                        int currentChapter = Convert.ToInt32(row["ChapNum"]);
                        int totalChapters = Convert.ToInt32(row["TotalChapters"]);

                        int chaptersCompleted = currentChapter - 1;
                        if (currentChapter > totalChapters) chaptersCompleted = totalChapters;

                        row["ProgressPercentage"] = totalChapters > 0 ? (chaptersCompleted * 100) / totalChapters : 0;

                        // Parse Language for CSS
                        string lang = row["Language"].ToString().ToLower();
                        if (lang.Contains("c++") || lang.Contains("cpp")) row["LanguageCSS"] = "cpp";
                        else if (lang == "c") row["LanguageCSS"] = "c";
                        else row["LanguageCSS"] = lang.Replace(" ", "");
                    }

                    rptActiveCourses.DataSource = dt;
                    rptActiveCourses.DataBind();

                    litGreetingDesc.Text = $"You have {dt.Rows.Count} active course{(dt.Rows.Count != 1 ? "s" : "")}. Keep up the momentum!";
                }
            }
        }

        private void LoadRecommendedCourses()
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                // Updated Query: Filters out courses the user is already enrolled in
                string query = @"
                    SELECT TOP 3 
                        c.CourseId, 
                        c.CourseTitle, 
                        c.CourseDescription, 
                        c.DifficultyLevel,
                        c.CourseDuration,
                        (SELECT COUNT(*) FROM Chapter WHERE CourseId = c.CourseId) as Chapters,
                        ISNULL((SELECT TOP 1 s.SubjectName FROM CourseSubject cs JOIN Subject s ON cs.SubjectId = s.SubjectId WHERE cs.CourseId = c.CourseId AND s.SubjectType = 'Language'), 'General') as Language,
                        ISNULL((SELECT COUNT(*) FROM LearnerProgress WHERE CourseId = c.CourseId), 0) as EnrolledCount,
                        ISNULL((SELECT ROUND(AVG(Rating), 1) FROM Course_Review WHERE CourseId = c.CourseId), 0.0) as Rating,
                        CAST(0 AS BIT) as IsEnrolled,
                        0 as CurrentChapter
                    FROM Course c
                    WHERE c.CourseId NOT IN (
                        SELECT CourseId FROM LearnerProgress WHERE LearnerId = @LearnerId
                    )
                    ORDER BY Rating DESC, EnrolledCount DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@LearnerId", Session["UserId"] != null ? Convert.ToInt32(Session["UserId"]) : 0);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    dt.Columns.Add("LanguageCSS", typeof(string));
                    dt.Columns.Add("ProgressPercentage", typeof(int));

                    foreach (DataRow row in dt.Rows)
                    {
                        // Parse Language for CSS
                        string lang = row["Language"].ToString().ToLower();
                        if (lang.Contains("c++") || lang.Contains("cpp")) row["LanguageCSS"] = "cpp";
                        else if (lang == "c") row["LanguageCSS"] = "c";
                        else row["LanguageCSS"] = lang.Replace(" ", "");

                        // By definition, these are unenrolled courses
                        row["ProgressPercentage"] = 0;
                    }

                    rptRecommended.DataSource = dt;
                    rptRecommended.DataBind();
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

        protected void rptRecommended_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {

        }
    }
}