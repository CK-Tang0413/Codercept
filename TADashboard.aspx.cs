using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace Codercept
{
    public partial class TADashboard : System.Web.UI.Page
    {
        // 1. Define Data Structures
        public class GradingItem
        {
            public int AttemptId { get; set; }
            public int CourseId { get; set; }
            public string LearnerName { get; set; }
            public string Title { get; set; }
            public string Type { get; set; }
            public string Course { get; set; }
            public string Submitted { get; set; }
            public string Status { get; set; }
            public string StatusCss { get; set; }
        }

        public class ForumItem
        {
            public int PostId { get; set; }
            public string Title { get; set; }
            public string Author { get; set; }
            public string Posted { get; set; }
            public string Flag { get; set; }
            public string FlagCss { get; set; }
        }

        private readonly string connString = TAHelpers.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                litWelcomeName.Text = Session["UserName"] != null ? Session["UserName"].ToString() : "Teaching Assistant";

                LoadDashboardData(Convert.ToInt32(Session["UserId"]));
            }
        }

        private void LoadDashboardData(int taId)
        {
            int queueTotal;
            var gradingQueue = GetGradingQueue(taId, out queueTotal);

            int toMark, awaiting;
            GetGradingStats(taId, out toMark, out awaiting);

            int unsolvedTotal;
            var forumActivity = GetUnsolvedPosts(out unsolvedTotal);

            // Bind Grading Queue
            phQueueEmpty.Visible = gradingQueue.Count == 0;
            rptGradingQueue.Visible = gradingQueue.Count > 0;
            rptGradingQueue.DataSource = gradingQueue;
            rptGradingQueue.DataBind();

            // Bind Forum Activity
            phForumEmpty.Visible = forumActivity.Count == 0;
            rptForumActivity.DataSource = forumActivity;
            rptForumActivity.DataBind();

            // Overview Stats
            litStatPending.Text = toMark.ToString();
            litStatAwaiting.Text = awaiting.ToString();
            litStatUnsolved.Text = unsolvedTotal.ToString();

            litGreetingDesc.Text = BuildGreeting(toMark, unsolvedTotal);
        }

        // Attempts the learner has submitted that this TA can still work on:
        // nobody has started them (Pending), or this TA has a draft (In Progress).
        private List<GradingItem> GetGradingQueue(int taId, out int total)
        {
            total = 0;
            var items = new List<GradingItem>();

            const string query = @"
                SELECT TOP 5
                    a.AttemptId,
                    l.Name AS LearnerName,
                    a.AttemptDate,
                    COALESCE(q.QuizTitle, asm.AssessmentTitle, ex.ExamTitle) AS Title,
                    CASE WHEN a.QuizId IS NOT NULL THEN 'Quiz' WHEN a.AssessmentId IS NOT NULL THEN 'Assessment' ELSE 'Exam' END AS Type,
                    c.CourseId,
                    c.CourseTitle,
                    COALESCE(gp.ProgressStatus, 'Pending') AS Status,
                    COUNT(*) OVER () AS TotalCount
                FROM [dbo].[Attempt] a
                INNER JOIN [dbo].[Learner] l ON l.LearnerId = a.LearnerId
                LEFT JOIN [dbo].[Quiz] q ON q.QuizId = a.QuizId
                LEFT JOIN [dbo].[Assessment] asm ON asm.AssessmentId = a.AssessmentId
                LEFT JOIN [dbo].[Exam] ex ON ex.ExamId = a.ExamId
                LEFT JOIN [dbo].[Chapter] ch ON ch.ChapterId = COALESCE(q.ChapterId, asm.ChapterId)
                LEFT JOIN [dbo].[Course] c ON c.CourseId = COALESCE(ch.CourseId, ex.CourseId)
                LEFT JOIN [dbo].[GradingProgress] gp ON gp.AttemptId = a.AttemptId
                WHERE (a.AttemptStatus = 'completed' OR a.AttemptStatus = 'Submitted')
                  AND (gp.GradingProgId IS NULL OR (gp.TA_Id = @TA_Id AND gp.ProgressStatus IN ('In Progress', 'in_progress')))
                  AND NOT EXISTS (SELECT 1 FROM [dbo].[Result] r WHERE r.AttemptId = a.AttemptId)
                ORDER BY a.AttemptDate ASC";

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@TA_Id", taId);
                con.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string status = reader["Status"].ToString();
                        total = Convert.ToInt32(reader["TotalCount"]);

                        items.Add(new GradingItem
                        {
                            AttemptId = Convert.ToInt32(reader["AttemptId"]),
                            CourseId = reader["CourseId"] != DBNull.Value ? Convert.ToInt32(reader["CourseId"]) : 0,
                            LearnerName = Server.HtmlEncode(reader["LearnerName"].ToString()),
                            Title = Server.HtmlEncode(reader["Title"].ToString()),
                            Type = reader["Type"].ToString(),
                            Course = reader["CourseTitle"] != DBNull.Value ? Server.HtmlEncode(reader["CourseTitle"].ToString()) : "",
                            Submitted = TAHelpers.TimeAgo(Convert.ToDateTime(reader["AttemptDate"])),
                            Status = status,
                            StatusCss = TAHelpers.GetStatusCss(status)
                        });
                    }
                }
            }

            return items;
        }

        private void GetGradingStats(int taId, out int toMark, out int awaiting)
        {
            const string query = @"
                SELECT
                    (SELECT COUNT(*) FROM [dbo].[Attempt] a
                        LEFT JOIN [dbo].[GradingProgress] gp ON gp.AttemptId = a.AttemptId
                        WHERE (a.AttemptStatus = 'completed' OR a.AttemptStatus = 'Submitted')
                          AND NOT EXISTS (SELECT 1 FROM [dbo].[Result] r WHERE r.AttemptId = a.AttemptId)
                          AND (gp.GradingProgId IS NULL OR (gp.TA_Id = @TA_Id AND gp.ProgressStatus IN ('In Progress', 'in_progress', 'Draft')))) AS ToMark,
                    (SELECT COUNT(*) FROM [dbo].[GradingProgress] WHERE TA_Id = @TA_Id AND ProgressStatus = 'Reviewed') AS Awaiting";

            toMark = awaiting = 0;

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@TA_Id", taId);
                con.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        toMark = Convert.ToInt32(reader["ToMark"]);
                        awaiting = Convert.ToInt32(reader["Awaiting"]);
                    }
                }
            }
        }

        // A post is "unsolved" until one of its replies is pinned as the Verified Answer. Hidden and deleted posts are excluded.
        private List<ForumItem> GetUnsolvedPosts(out int total)
        {
            total = 0;
            var items = new List<ForumItem>();

            string query = @"
                SELECT TOP 5
                    f.PostId, f.Title, l.Name AS Author, f.DatePosted, COUNT(*) OVER () AS TotalCount
                FROM [dbo].[Forum] f
                INNER JOIN [dbo].[Learner] l ON l.LearnerId = f.LearnerId
                WHERE NOT " + TAHelpers.ForumHasVerifiedAnswer + @"
                  AND " + TAHelpers.ForumVisibleToLearners + @"
                ORDER BY f.DatePosted DESC";

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                con.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        total = Convert.ToInt32(reader["TotalCount"]);

                        items.Add(new ForumItem
                        {
                            PostId = Convert.ToInt32(reader["PostId"]),
                            Title = Server.HtmlEncode(reader["Title"].ToString()),
                            Author = Server.HtmlEncode(reader["Author"].ToString()),
                            Posted = TAHelpers.TimeAgo(Convert.ToDateTime(reader["DatePosted"])),
                            Flag = "Unsolved",
                            FlagCss = "flag-unsolved"
                        });
                    }
                }
            }

            return items;
        }

        private static string BuildGreeting(int toMark, int unsolved)
        {
            if (toMark == 0 && unsolved == 0)
            {
                return "You're all caught up. Nothing needs your attention right now.";
            }

            var parts = new List<string>();
            if (toMark > 0) parts.Add($"{toMark} submission{(toMark != 1 ? "s" : "")} to mark");
            if (unsolved > 0) parts.Add($"{unsolved} unsolved forum question{(unsolved != 1 ? "s" : "")}");

            string list = parts.Count == 1
                ? parts[0]
                : string.Join(", ", parts.GetRange(0, parts.Count - 1)) + " and " + parts[parts.Count - 1];

            return "You have " + list + ".";
        }
    }
}
