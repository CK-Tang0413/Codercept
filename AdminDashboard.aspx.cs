using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace Codercept
{
    public partial class Admin_Dashboard : System.Web.UI.Page
    {
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["CoderceptDB"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDashboardStatistics();
                LoadPendingApplications();
                LoadPinnedAnnouncements();
            }
        }

        private void LoadDashboardStatistics()
        {
            // Fallback/Default values
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
                // Fallback mock statistics if DB is not yet connected
                PopulateStatisticLiterals(9, 3, 6, 454, 5, 3, 3, 2, 5);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Aggregated SQL Query calculating all required statistics in a single round-trip
                    string query = @"
                        SELECT
                            (SELECT COUNT(*) FROM Users WHERE IsDeleted = 0) AS TotalUsers,
                            (SELECT COUNT(*) FROM Users WHERE Status = 'Pending' AND IsDeleted = 0) AS PendingApprovals,
                            (SELECT COUNT(*) FROM Courses WHERE Status = 'Published') AS PublishedCourses,
                            (SELECT ISNULL(SUM(EnrolledCount), 0) FROM Courses) AS TotalEnrollments,
                            (SELECT COUNT(*) FROM Users WHERE Role = 'Learner' AND IsDeleted = 0) AS LearnersCount,
                            (SELECT COUNT(*) FROM Users WHERE Role = 'Learner' AND Status = 'Active' AND IsDeleted = 0) AS ActiveLearners,
                            (SELECT COUNT(*) FROM Users WHERE Role = 'Teacher' AND IsDeleted = 0) AS TeachersCount,
                            (SELECT COUNT(*) FROM Users WHERE Role = 'Teacher' AND Status = 'Active' AND IsDeleted = 0) AS ActiveTeachers,
                            (SELECT COUNT(*) FROM Users WHERE Status = 'Active' AND IsDeleted = 0) AS ActiveTotal";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            totalUsers = Convert.ToInt32(reader["TotalUsers"]);
                            pendingApprovals = Convert.ToInt32(reader["PendingApprovals"]);
                            publishedCourses = Convert.ToInt32(reader["PublishedCourses"]);
                            totalEnrollments = Convert.ToInt32(reader["TotalEnrollments"]);
                            learnersCount = Convert.ToInt32(reader["LearnersCount"]);
                            activeLearnersCount = Convert.ToInt32(reader["ActiveLearners"]);
                            teachersCount = Convert.ToInt32(reader["TeachersCount"]);
                            activeTeachersCount = Convert.ToInt32(reader["ActiveTeachers"]);
                            activeTotal = Convert.ToInt32(reader["ActiveTotal"]);
                        }
                    }
                }

                PopulateStatisticLiterals(totalUsers, pendingApprovals, publishedCourses, totalEnrollments,
                                          learnersCount, activeLearnersCount, teachersCount, activeTeachersCount, activeTotal);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminDashboard DB Error]: {ex.Message}");
                // Graceful fallback to default values on connection error
                PopulateStatisticLiterals(9, 3, 6, 454, 5, 3, 3, 2, 5);
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

            if (string.IsNullOrEmpty(connectionString))
            {
                // Fallback mock data
                dtPending.Columns.Add("UserId", typeof(string));
                dtPending.Columns.Add("FullName", typeof(string));
                dtPending.Columns.Add("Email", typeof(string));
                dtPending.Columns.Add("Role", typeof(string));
                dtPending.Columns.Add("AppliedDate", typeof(DateTime));

                dtPending.Rows.Add("USR_003", "Emma Wilson", "emma.wilson@codelearn.edu", "Teacher", DateTime.Parse("2024-08-20"));
                dtPending.Rows.Add("USR_009", "James Wilson", "james.w@student.edu", "Learner", DateTime.Parse("2024-08-28"));
                dtPending.Rows.Add("USR_011", "David Brown", "david.b@student.edu", "Learner", DateTime.Parse("2024-08-25"));

                BindPendingRepeater(dtPending);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    // Select only the top 3 pending records ordered by submission date
                    string query = @"
                        SELECT TOP 3 UserId, FullName, Email, Role, CreatedAt AS AppliedDate
                        FROM Users
                        WHERE Status = 'Pending' AND IsDeleted = 0
                        ORDER BY CreatedAt ASC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        adapter.Fill(dtPending);
                    }
                }

                BindPendingRepeater(dtPending);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminDashboard Pending Error]: {ex.Message}");
            }
        }

        private void BindPendingRepeater(DataTable dtPending)
        {
            litShowingPendingCount.Text = dtPending.Rows.Count.ToString();

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

        private void LoadPinnedAnnouncements()
        {
            DataTable dtPinned = new DataTable();

            if (string.IsNullOrEmpty(connectionString))
            {
                // Fallback mock data
                dtPinned.Columns.Add("Title", typeof(string));
                dtPinned.Columns.Add("Content", typeof(string));
                dtPinned.Columns.Add("CardType", typeof(string));

                dtPinned.Rows.Add(
                    "New C++ Module Now Available!",
                    "We are excited to announce the launch of \"Data Structures with C++\" by Prof. Michael Torres. Enroll today to master linked lists, trees, and hash tables from scratch.",
                    "success"
                );
                dtPinned.Rows.Add(
                    "Scheduled Maintenance — Sept 5, 2024",
                    "The platform will undergo scheduled maintenance on September 5th from 2:00 AM to 4:00 AM UTC. Some features may be temporarily unavailable during this period.",
                    "warning"
                );

                BindPinnedRepeater(dtPinned);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    // Fetch up to top 2 pinned announcements
                    string query = @"
                        SELECT TOP 2 Title, Content, CardType
                        FROM Announcements
                        WHERE IsPinned = 1
                        ORDER BY CreatedAt DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        adapter.Fill(dtPinned);
                    }
                }

                BindPinnedRepeater(dtPinned);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminDashboard Pinned Error]: {ex.Message}");
            }
        }

        private void BindPinnedRepeater(DataTable dtPinned)
        {
            litShowingPinnedCount.Text = dtPinned.Rows.Count.ToString();
            litTotalPinnedCount.Text = dtPinned.Rows.Count.ToString();

            if (dtPinned.Rows.Count > 0)
            {
                rptPinnedAnnouncements.DataSource = dtPinned;
                rptPinnedAnnouncements.DataBind();
                pnlNoPinned.Visible = false;
            }
            else
            {
                rptPinnedAnnouncements.DataSource = null;
                rptPinnedAnnouncements.DataBind();
                pnlNoPinned.Visible = true;
            }
        }

        // Helper method: Extracts two-letter initials for user avatars (e.g., "Emma Wilson" -> "EW")
        protected string GetInitials(string fullName)
        {
            if (string.IsNullOrWhiteSpace(fullName))
                return "U";

            string[] names = fullName.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (names.Length == 1)
                return names[0].Substring(0, Math.Min(2, names[0].Length)).ToUpper();

            return (names[0][0].ToString() + names[names.Length - 1][0].ToString()).ToUpper();
        }

        // Helper method: Maps card type to FontAwesome icons
        protected string GetAnnouncementIcon(string cardType)
        {
            switch (cardType.ToLower())
            {
                case "success": return "fa-solid fa-check";
                case "warning": return "fa-solid fa-triangle-exclamation";
                case "info": return "fa-solid fa-circle-info";
                default: return "fa-solid fa-bell";
            }
        }
    }
}