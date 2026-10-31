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
            if (Session["UserType"] == null || Session["UserType"].ToString() != "Learner")
            {
                Response.Redirect("LandingPage.aspx");
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

            int learnerId = Convert.ToInt32(Session["UserId"]);
            bool userIsEnrolled = false;
            int learnerProgressChapter = 0;

            using (SqlConnection con = new SqlConnection(connString))
            {
                // 1. Fetch Main Course Details (Added HasCompletedExam subquery)
                string courseQuery = @"
                    SELECT 
                        c.CourseId, 
                        c.CourseTitle, 
                        c.CourseDescription, 
                        c.DifficultyLevel,
                        c.CourseDuration,
                        t.Name as TeacherName,
                        (SELECT COUNT(*) FROM Chapter WHERE CourseId = c.CourseId) as TotalChapters,
                        (SELECT COUNT(*) FROM Exam WHERE CourseId = c.CourseId) as ExamCount,
                        CAST(CASE WHEN EXISTS (
                            SELECT 1 FROM Attempt a 
                            JOIN Exam e ON a.ExamId = e.ExamId 
                            WHERE e.CourseId = c.CourseId AND a.LearnerId = @LearnerId AND a.AttemptStatus IN ('completed', 'graded')
                        ) THEN 1 ELSE 0 END AS BIT) as HasCompletedExam,
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

                            string lang = reader["Language"].ToString();
                            string level = reader["DifficultyLevel"].ToString();
                            string cssLevel = level == "Easy" ? "beginner" : (level == "Medium" ? "intermediate" : "advanced");

                            string badges = $"<span class='badge badge-lang'>{lang}</span> <span class='badge badge-level' style='text-transform: capitalize;'>{level}</span>";
                            litTags.Text = badges;

                            // Check Enrollment & Progress
                            // Check Enrollment & Progress
                            if (reader["LearnerCurrentChapter"] != DBNull.Value)
                            {
                                userIsEnrolled = true;
                                learnerProgressChapter = Convert.ToInt32(reader["LearnerCurrentChapter"]);

                                bool hasExam = Convert.ToInt32(reader["ExamCount"]) > 0;
                                bool hasCompletedExam = Convert.ToBoolean(reader["HasCompletedExam"]);
                                int maxAllowedChapter = totalChapters + (hasExam ? 1 : 0);

                                bool isCourseCompleted = (learnerProgressChapter > maxAllowedChapter)
                                    || (hasExam && hasCompletedExam && learnerProgressChapter >= totalChapters);

                                int chaptersCompleted = isCourseCompleted
                                    ? maxAllowedChapter
                                    : Math.Max(0, learnerProgressChapter - 1);

                                int progressPct = maxAllowedChapter > 0
                                    ? (int)Math.Round((double)chaptersCompleted / maxAllowedChapter * 100)
                                    : 0;

                                pnlEnrolledProgress.Visible = true;
                                litProgressText.Text = $"{progressPct}%";
                                pnlProgressBarFill.Style.Add("width", $"{progressPct}%");

                                btnCourseAction.Text = "Continue Learning ->";
                                btnCourseAction.CommandArgument = courseId.ToString();
                                btnCourseAction.OnClientClick = "";

                                // Show Review options when course is 100% completed
                                if (isCourseCompleted)
                                {
                                    learnerProgressChapter = maxAllowedChapter + 1;
                                    btnCourseAction.Text = "Review Material";

                                    using (SqlConnection reviewCon = new SqlConnection(connString))
                                    {
                                        using (SqlCommand reviewCmd = new SqlCommand("SELECT COUNT(*) FROM Course_Review WHERE CourseId = @CourseId AND LearnerId = @LearnerId", reviewCon))
                                        {
                                            reviewCmd.Parameters.AddWithValue("@CourseId", courseId);
                                            reviewCmd.Parameters.AddWithValue("@LearnerId", learnerId);
                                            reviewCon.Open();
                                            int reviewCount = Convert.ToInt32(reviewCmd.ExecuteScalar());
                                            reviewCon.Close();

                                            if (reviewCount > 0)
                                            {
                                                btnShowReviewModal.Visible = false;
                                                lblReviewSubmitted.Visible = true;
                                            }
                                            else
                                            {
                                                btnShowReviewModal.Visible = true;
                                                litReviewCourseTitle.Text = reader["CourseTitle"].ToString();
                                            }
                                        }
                                    }
                                }
                            }
                            else
                            {
                                // --- User is NOT enrolled ---
                                userIsEnrolled = false;

                                // Hide the progress bar
                                pnlEnrolledProgress.Visible = false;

                                // Reset the button to "Enroll Now"
                                btnCourseAction.Text = "Enroll Now";
                                btnCourseAction.CommandArgument = courseId.ToString();
                                btnCourseAction.OnClientClick = ""; // Removed guest modal popup
                            }
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

                // RENAMED from 'cmd' to 'chapterCmd' to resolve CS0136 scope collision
                using (SqlCommand chapterCmd = new SqlCommand(chapterQuery, con))
                {
                    chapterCmd.Parameters.AddWithValue("@CourseId", courseId);
                    SqlDataAdapter da = new SqlDataAdapter(chapterCmd);
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

            Response.Redirect($"CourseViewer.aspx?courseId={courseId}&ch=1");
        }

        // --- NEW REVIEW MODAL HANDLERS ---
        protected void btnShowReviewModal_Click(object sender, EventArgs e)
        {
            pnlReviewModal.Visible = true;
        }

        protected void btnCancelReview_Click(object sender, EventArgs e)
        {
            pnlReviewModal.Visible = false;
        }

        protected void btnSubmitReview_Click(object sender, EventArgs e)
        {
            int courseId = 1;
            if (Request.QueryString["id"] != null) int.TryParse(Request.QueryString["id"], out courseId);

            int learnerId = Convert.ToInt32(Session["UserId"]);
            double rating = Convert.ToDouble(ddlRating.SelectedValue);
            string feedback = txtFeedback.Text.Trim();

            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = "INSERT INTO Course_Review (CourseFeedBack, Rating, SubmissionDate, CourseId, LearnerId) VALUES (@Feedback, @Rating, GETDATE(), @CourseId, @LearnerId)";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Feedback", string.IsNullOrEmpty(feedback) ? "No written feedback provided." : feedback);
                    cmd.Parameters.AddWithValue("@Rating", rating);
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);

                    con.Open();
                    cmd.ExecuteNonQuery();
                    con.Close();
                }
            }

            pnlReviewModal.Visible = false;
            LoadCourseDetails(); // Reload page to update UI
        }

        // --- Helper Methods ---
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