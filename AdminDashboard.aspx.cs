using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace Codercept
{
    public partial class Admin_Dashboard : System.Web.UI.Page
    {
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["Codercept_db"]?.ConnectionString
            ?? ConfigurationManager.ConnectionStrings["CoderceptDB"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDashboardStatistics();
                LoadPendingApplications();
                LoadRecentAnnouncements();
            }
        }

        private void LoadDashboardStatistics()
        {
            int totalUsers = 0;
            int pendingApprovals = 0;
            int publishedCourses = 0;
            int totalEnrollments = 0;
            int learnersCount = 0;
            int activeLearnersCount = 0;
            int teachersCount = 0;
            int activeTeachersCount = 0;
            int activeTotal = 0;

            if (string.IsNullOrEmpty(connectionString))
            {
                PopulateStatisticLiterals(0, 0, 0, 0, 0, 0, 0, 0, 0);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        SELECT
                            (
                                (SELECT COUNT(*) FROM [dbo].[Learner] WHERE AccStatus != 'Deleted') +
                                (SELECT COUNT(*) FROM [dbo].[Teacher] WHERE AccStatus != 'Deleted') +
                                (SELECT COUNT(*) FROM [dbo].[Teaching_Assistant] WHERE AccStatus != 'Deleted') +
                                (SELECT COUNT(*) FROM [dbo].[Admin] WHERE AccStatus != 'Deleted')
                            ) AS TotalUsers,
                            (
                                SELECT COUNT(*) FROM (
                                    SELECT t.TeacherId FROM [dbo].[Teacher] t LEFT JOIN [dbo].[Application] a ON t.ApplicationId = a.ApplicationId WHERE t.AccStatus = 'Pending' OR (a.ApprovalStatus = 'Pending' AND a.RoleApplied = 'Teacher')
                                    UNION
                                    SELECT ta.TA_Id FROM [dbo].[Teaching_Assistant] ta LEFT JOIN [dbo].[Application] a ON ta.ApplicationId = a.ApplicationId WHERE ta.AccStatus = 'Pending' OR (a.ApprovalStatus = 'Pending' AND a.RoleApplied = 'Teaching Assistant')
                                    UNION
                                    SELECT a.ApplicationId FROM [dbo].[Application] a WHERE a.ApprovalStatus = 'Pending'
                                        AND NOT EXISTS (SELECT 1 FROM [dbo].[Teacher] t WHERE t.ApplicationId = a.ApplicationId)
                                        AND NOT EXISTS (SELECT 1 FROM [dbo].[Teaching_Assistant] ta WHERE ta.ApplicationId = a.ApplicationId)
                                ) p
                            ) AS PendingApprovals,
                            (SELECT COUNT(*) FROM [dbo].[Course]) AS PublishedCourses,
                            (SELECT COUNT(*) FROM [dbo].[LearnerProgress]) AS TotalEnrollments,
                            (SELECT COUNT(*) FROM [dbo].[Learner] WHERE AccStatus != 'Deleted') AS LearnersCount,
                            (SELECT COUNT(*) FROM [dbo].[Learner] WHERE AccStatus = 'Active') AS ActiveLearners,
                            (SELECT COUNT(*) FROM [dbo].[Teacher] WHERE AccStatus != 'Deleted') AS TeachersCount,
                            (SELECT COUNT(*) FROM [dbo].[Teacher] WHERE AccStatus = 'Active') AS ActiveTeachers,
                            (
                                (SELECT COUNT(*) FROM [dbo].[Learner] WHERE AccStatus = 'Active') +
                                (SELECT COUNT(*) FROM [dbo].[Teacher] WHERE AccStatus = 'Active') +
                                (SELECT COUNT(*) FROM [dbo].[Teaching_Assistant] WHERE AccStatus = 'Active') +
                                (SELECT COUNT(*) FROM [dbo].[Admin] WHERE AccStatus = 'Active')
                            ) AS ActiveTotal";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            totalUsers = reader["TotalUsers"] != DBNull.Value ? Convert.ToInt32(reader["TotalUsers"]) : 0;
                            pendingApprovals = reader["PendingApprovals"] != DBNull.Value ? Convert.ToInt32(reader["PendingApprovals"]) : 0;
                            publishedCourses = reader["PublishedCourses"] != DBNull.Value ? Convert.ToInt32(reader["PublishedCourses"]) : 0;
                            totalEnrollments = reader["TotalEnrollments"] != DBNull.Value ? Convert.ToInt32(reader["TotalEnrollments"]) : 0;
                            learnersCount = reader["LearnersCount"] != DBNull.Value ? Convert.ToInt32(reader["LearnersCount"]) : 0;
                            activeLearnersCount = reader["ActiveLearners"] != DBNull.Value ? Convert.ToInt32(reader["ActiveLearners"]) : 0;
                            teachersCount = reader["TeachersCount"] != DBNull.Value ? Convert.ToInt32(reader["TeachersCount"]) : 0;
                            activeTeachersCount = reader["ActiveTeachers"] != DBNull.Value ? Convert.ToInt32(reader["ActiveTeachers"]) : 0;
                            activeTotal = reader["ActiveTotal"] != DBNull.Value ? Convert.ToInt32(reader["ActiveTotal"]) : 0;
                        }
                    }
                }

                PopulateStatisticLiterals(totalUsers, pendingApprovals, publishedCourses, totalEnrollments,
                                          learnersCount, activeLearnersCount, teachersCount, activeTeachersCount, activeTotal);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminDashboard DB Error]: {ex.Message}");
                PopulateStatisticLiterals(0, 0, 0, 0, 0, 0, 0, 0, 0);
            }
        }

        private void PopulateStatisticLiterals(int totalUsers, int pending, int published, int enrollments,
                                              int learners, int activeLearners, int teachers, int activeTeachers, int activeTotal)
        {
            litBannerPendingCount.Text = pending.ToString();
            litTotalUsers.Text = totalUsers.ToString();
            litPendingApprovals.Text = pending.ToString();
            litPublishedCourses.Text = published.ToString();
            litTotalEnrollments.Text = enrollments.ToString();

            litLearnersCount.Text = learners.ToString();
            litActiveLearnersCount.Text = activeLearners.ToString();
            litTeachersCount.Text = teachers.ToString();
            litActiveTeachersCount.Text = activeTeachers.ToString();
            litActiveTotalCount.Text = activeTotal.ToString();
            litActiveSubTotal.Text = activeTotal.ToString();

            litTotalPendingCount.Text = pending.ToString();
            litViewAllPendingCount.Text = pending.ToString();
        }

        private void LoadPendingApplications()
        {
            DataTable dtPending = new DataTable();
            int totalPending = 0;

            if (string.IsNullOrEmpty(connectionString))
            {
                BindPendingRepeater(dtPending, 0);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string countQuery = @"
                        SELECT COUNT(*) FROM (
                            SELECT t.TeacherId FROM [dbo].[Teacher] t LEFT JOIN [dbo].[Application] a ON t.ApplicationId = a.ApplicationId WHERE t.AccStatus = 'Pending' OR (a.ApprovalStatus = 'Pending' AND a.RoleApplied = 'Teacher')
                            UNION
                            SELECT ta.TA_Id FROM [dbo].[Teaching_Assistant] ta LEFT JOIN [dbo].[Application] a ON ta.ApplicationId = a.ApplicationId WHERE ta.AccStatus = 'Pending' OR (a.ApprovalStatus = 'Pending' AND a.RoleApplied = 'Teaching Assistant')
                            UNION
                            SELECT a.ApplicationId FROM [dbo].[Application] a WHERE a.ApprovalStatus = 'Pending'
                                AND NOT EXISTS (SELECT 1 FROM [dbo].[Teacher] t WHERE t.ApplicationId = a.ApplicationId)
                                AND NOT EXISTS (SELECT 1 FROM [dbo].[Teaching_Assistant] ta WHERE ta.ApplicationId = a.ApplicationId)
                        ) p";

                    using (SqlCommand countCmd = new SqlCommand(countQuery, conn))
                    {
                        totalPending = Convert.ToInt32(countCmd.ExecuteScalar());
                    }

                    string query = @"
                        SELECT TOP 3 * FROM (
                            SELECT 
                                t.TeacherId AS UserId,
                                t.Name AS FullName,
                                t.Email,
                                'Teacher' AS Role,
                                'teacher' AS RoleCategory,
                                ISNULL(a.DateSubmitted, t.DateJoined) AS AppliedDate
                            FROM [dbo].[Teacher] t
                            LEFT JOIN [dbo].[Application] a ON t.ApplicationId = a.ApplicationId
                            WHERE t.AccStatus = 'Pending' OR (a.ApprovalStatus = 'Pending' AND a.RoleApplied = 'Teacher')

                            UNION

                            SELECT 
                                ta.TA_Id AS UserId,
                                ta.Name AS FullName,
                                ta.Email,
                                'Teaching Assistant' AS Role,
                                'assistant' AS RoleCategory,
                                ISNULL(a.DateSubmitted, ta.DateJoined) AS AppliedDate
                            FROM [dbo].[Teaching_Assistant] ta
                            LEFT JOIN [dbo].[Application] a ON ta.ApplicationId = a.ApplicationId
                            WHERE ta.AccStatus = 'Pending' OR (a.ApprovalStatus = 'Pending' AND a.RoleApplied = 'Teaching Assistant')

                            UNION

                            SELECT
                                a.ApplicationId AS UserId,
                                'Applicant #' + CAST(a.ApplicationId AS VARCHAR) AS FullName,
                                'Pending Registration' AS Email,
                                a.RoleApplied AS Role,
                                CASE WHEN a.RoleApplied = 'Teacher' THEN 'teacher' ELSE 'assistant' END AS RoleCategory,
                                a.DateSubmitted AS AppliedDate
                            FROM [dbo].[Application] a
                            WHERE a.ApprovalStatus = 'Pending'
                              AND NOT EXISTS (SELECT 1 FROM [dbo].[Teacher] t WHERE t.ApplicationId = a.ApplicationId)
                              AND NOT EXISTS (SELECT 1 FROM [dbo].[Teaching_Assistant] ta WHERE ta.ApplicationId = a.ApplicationId)
                        ) pending
                        ORDER BY AppliedDate ASC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        adapter.Fill(dtPending);
                    }
                }

                BindPendingRepeater(dtPending, totalPending);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminDashboard Pending Error]: {ex.Message}");
                BindPendingRepeater(dtPending, 0);
            }
        }

        private void BindPendingRepeater(DataTable dtPending, int totalPending)
        {
            litShowingPendingCount.Text = dtPending.Rows.Count.ToString();
            litTotalPendingCount.Text = totalPending.ToString();
            litViewAllPendingCount.Text = totalPending.ToString();
            litBannerPendingCount.Text = totalPending.ToString();
            litPendingApprovals.Text = totalPending.ToString();

            if (dtPending.Rows.Count > 0)
            {
                rptPendingApprovals.DataSource = dtPending;
                rptPendingApprovals.DataBind();
                pnlNoPending.Visible = false;
            }
            else
            {
                rptPendingApprovals.DataSource = null;
                rptPendingApprovals.DataBind();
                pnlNoPending.Visible = true;
            }
        }

        private void LoadRecentAnnouncements()
        {
            DataTable dtRecent = new DataTable();
            int totalRecentCount = 0;

            if (string.IsNullOrEmpty(connectionString))
            {
                BindRecentRepeater(dtRecent, 0);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string countQuery = @"
                        SELECT COUNT(*) 
                        FROM [dbo].[Notification]";

                    using (SqlCommand countCmd = new SqlCommand(countQuery, conn))
                    {
                        totalRecentCount = Convert.ToInt32(countCmd.ExecuteScalar());
                    }

                    string query = @"
                        SELECT TOP 3 
                            Title, 
                            Content, 
                            Type,
                            CASE 
                                WHEN LOWER(Type) LIKE '%warn%' THEN 'warning'
                                WHEN LOWER(Type) LIKE '%announc%' OR LOWER(Type) LIKE '%success%' THEN 'success'
                                ELSE 'info'
                            END AS CardType
                        FROM [dbo].[Notification]
                        ORDER BY DateTime DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        adapter.Fill(dtRecent);
                    }
                }

                BindRecentRepeater(dtRecent, totalRecentCount);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminDashboard Recent Error]: {ex.Message}");
                BindRecentRepeater(dtRecent, 0);
            }
        }

        private void BindRecentRepeater(DataTable dtRecent, int totalRecentCount)
        {
            litShowingRecentCount.Text = dtRecent.Rows.Count.ToString();
            litTotalRecentCount.Text = totalRecentCount.ToString();

            if (dtRecent.Rows.Count > 0)
            {
                rptRecentAnnouncements.DataSource = dtRecent;
                rptRecentAnnouncements.DataBind();
                pnlNoRecent.Visible = false;
            }
            else
            {
                rptRecentAnnouncements.DataSource = null;
                rptRecentAnnouncements.DataBind();
                pnlNoRecent.Visible = true;
            }
        }

        protected string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName))
                return "U";

            string[] names = fullName.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (names.Length == 1)
                return names[0].Substring(0, Math.Min(2, names[0].Length)).ToUpper();

            return (names[0][0].ToString() + names[names.Length - 1][0].ToString()).ToUpper();
        }

        protected string GetAnnouncementIcon(string cardType)
        {
            switch ((cardType ?? "").ToLower())
            {
                case "success": return "fa-solid fa-check";
                case "warning": return "fa-solid fa-triangle-exclamation";
                case "info": return "fa-solid fa-circle-info";
                default: return "fa-solid fa-bell";
            }
        }
    }
}
