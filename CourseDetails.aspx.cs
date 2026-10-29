using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class CourseDetails : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["Codercept_db"].ConnectionString;

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
            int courseId = 1;
            if (Request.QueryString["id"] != null)
            {
                int.TryParse(Request.QueryString["id"], out courseId);
            }

            bool isGuest = Session["UserType"].ToString() == "Guest";
            int learnerId = isGuest ? 0 : Convert.ToInt32(Session["UserId"]);
            bool userIsEnrolled = false;
            int learnerProgressChapter = 0;

            using (SqlConnection con = new SqlConnection(connString))
            {
                // 1. Fetch Main Course Details
                string courseQuery = @"
                    SELECT 
                        c.CourseId, 
                        c.CourseTitle, 
                        c.CourseDescription, 
                        c.DifficultyLevel,
                        c.CourseDuration,
                        t.Name as TeacherName,
                        (SELECT COUNT(*) FROM Chapter WHERE CourseId = c.CourseId) as TotalChapters,
                        ISNULL((SELECT TOP 1 s.SubjectName FROM CourseSubject cs JOIN Subject s ON cs.SubjectId = s.SubjectId WHERE cs.CourseId = c.CourseId AND s.SubjectType = 'Language'), 'General') as Language,
                        ISNULL((SELECT COUNT(*) FROM LearnerProgress WHERE CourseId = c.CourseId), 0) as EnrolledCount,
                        ISNULL((SELECT ROUND(AVG(Rating), 1) FROM Course_Review WHERE CourseId = c.CourseId), 0.0) as Rating,
                        lp.ChapNum as LearnerCurrentChapter
                    FROM Course c
                    JOIN Teacher t ON c.TeacherId = t.TeacherId
                    LEFT JOIN LearnerProgress lp ON c.CourseId = lp.CourseId AND lp.LearnerId = @LearnerId
                    WHERE c.CourseId = @CourseId";

                using (SqlCommand cmd = new SqlCommand(courseQuery, con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            litTitle.Text = reader["CourseTitle"].ToString();
                            litDescription.Text = reader["CourseDescription"].ToString();
                            litInstructor.Text = reader["TeacherName"].ToString();

                            int totalChapters = Convert.ToInt32(reader["TotalChapters"]);
                            litChapterCount.Text = $"{totalChapters} chapters";
                            litDuration.Text = reader["CourseDuration"].ToString();
                            litEnrolledCount.Text = Convert.ToInt32(reader["EnrolledCount"]).ToString("N0");
                            litRating.Text = $"{reader["Rating"]}/5.0";

                            // Setup Badges
                            string lang = reader["Language"].ToString();
                            string level = reader["DifficultyLevel"].ToString();
                            string cssLevel = level == "Easy" ? "beginner" : (level == "Medium" ? "intermediate" : "advanced"); // Fallback mapped colors

                            string badges = $"<span class='badge badge-lang'>{lang}</span> <span class='badge badge-level' style='text-transform: capitalize;'>{level}</span>";
                            litTags.Text = badges;

                            // Check Enrollment
                            if (reader["LearnerCurrentChapter"] != DBNull.Value)
                            {
                                userIsEnrolled = true;
                                learnerProgressChapter = Convert.ToInt32(reader["LearnerCurrentChapter"]);

                                int chaptersCompleted = learnerProgressChapter - 1;
                                if (learnerProgressChapter > totalChapters) chaptersCompleted = totalChapters;

                                int progressPct = totalChapters > 0 ? (chaptersCompleted * 100) / totalChapters : 0;

                                pnlEnrolledProgress.Visible = true;
                                litProgressText.Text = $"{progressPct}%";
                                pnlProgressBarFill.Style.Add("width", $"{progressPct}%");

                                btnCourseAction.Text = "Continue Learning ->";
                                btnCourseAction.CommandArgument = courseId.ToString();
                                btnCourseAction.OnClientClick = "";
                            }
                            else
                            {
                                pnlEnrolledProgress.Visible = false;
                                btnCourseAction.Text = "Enroll Now";
                                btnCourseAction.CommandArgument = courseId.ToString();

                                if (isGuest)
                                {
                                    btnCourseAction.OnClientClick = "showGuestModal(); return false;";
                                }
                                else
                                {
                                    btnCourseAction.OnClientClick = "";
                                }
                            }
                        }
                        else
                        {
                            // Course not found
                            Response.Redirect("CourseCatalog.aspx");
                        }
                    }
                }

                // 2. Fetch Chapter List
                string chapterQuery = @"
                    SELECT 
                        ch.ChapterNum,
                        ch.ChapterTitle,
                        ch.ChapterDuration,
                        CASE WHEN ch.ChapterMediaLink IS NOT NULL THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END as HasVideo,
                        (SELECT COUNT(*) FROM SubChapter WHERE ChapterId = ch.ChapterId) as SubChapterCount,
                        CAST(CASE WHEN EXISTS (SELECT 1 FROM Quiz WHERE ChapterId = ch.ChapterId) THEN 1 ELSE 0 END AS BIT) as HasQuiz,
                        CAST(CASE WHEN EXISTS (SELECT 1 FROM Assessment WHERE ChapterId = ch.ChapterId) THEN 1 ELSE 0 END AS BIT) as HasAssessment,
                        CAST(CASE WHEN ch.ChapterNum = (SELECT MAX(ChapterNum) FROM Chapter WHERE CourseId = ch.CourseId) AND EXISTS(SELECT 1 FROM Exam WHERE CourseId = ch.CourseId) THEN 1 ELSE 0 END AS BIT) as HasExam
                    FROM Chapter ch
                    WHERE ch.CourseId = @CourseId
                    ORDER BY ch.ChapterNum ASC";

                using (SqlCommand cmd = new SqlCommand(chapterQuery, con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    dt.Columns.Add("Status", typeof(string));

                    foreach (DataRow row in dt.Rows)
                    {
                        int chapNum = Convert.ToInt32(row["ChapterNum"]);

                        if (!userIsEnrolled)
                        {
                            row["Status"] = "Locked";
                        }
                        else
                        {
                            if (chapNum < learnerProgressChapter) row["Status"] = "Completed";
                            else if (chapNum == learnerProgressChapter) row["Status"] = "Active";
                            else row["Status"] = "Locked";
                        }
                    }

                    rptChapters.DataSource = dt;
                    rptChapters.DataBind();
                }
            }
        }

        protected void btnCourseAction_Click(object sender, EventArgs e)
        {
            if (Session["UserType"].ToString() == "Guest") return;

            int courseId = Convert.ToInt32(((Button)sender).CommandArgument);
            int learnerId = Convert.ToInt32(Session["UserId"]);

            // Check if already enrolled
            bool isEnrolled = false;
            using (SqlConnection con = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM LearnerProgress WHERE LearnerId = @LearnerId AND CourseId = @CourseId", con))
                {
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    con.Open();
                    isEnrolled = Convert.ToInt32(cmd.ExecuteScalar()) > 0;
                    con.Close();
                }

                if (!isEnrolled)
                {
                    // Enroll them (Start at chapter 1)
                    using (SqlCommand cmd = new SqlCommand("INSERT INTO LearnerProgress (LearnerId, CourseId, ChapNum, EnrolledDate) VALUES (@LearnerId, @CourseId, 1, GETDATE())", con))
                    {
                        cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                        cmd.Parameters.AddWithValue("@CourseId", courseId);
                        con.Open();
                        cmd.ExecuteNonQuery();
                        con.Close();
                    }
                }
            }

            // After enrolling (or if already enrolled), redirect to the viewer to begin learning
            Response.Redirect($"CourseViewer.aspx?courseId={courseId}&ch=1");
        }

        // 3. Helper Methods for Repeater Inline DataBinding
        protected string GetChapterUrl(string status, int chapterNum)
        {
            if (Session["UserType"].ToString() == "Guest") return "javascript:showGuestModal();";
            if (status == "Locked") return "javascript:void(0);";

            int courseId = 1;
            if (Request.QueryString["id"] != null) int.TryParse(Request.QueryString["id"], out courseId);

            return $"CourseViewer.aspx?courseId={courseId}&ch={chapterNum}";
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

            return status == "Locked" ? index.ToString("D2") : "";
        }

        protected string GetActionIcon(string status)
        {
            if (status == "Locked")
                return "<svg class='ch-icon' xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='currentColor'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z' /></svg>";

            return "<svg class='ch-icon' xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='currentColor'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M9 5l7 7-7 7' /></svg>";
        }
    }
}