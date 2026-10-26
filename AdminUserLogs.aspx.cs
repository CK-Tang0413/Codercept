using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class AdminUserLogs : System.Web.UI.Page
    {
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["CoderceptDB"]?.ConnectionString;
        protected bool IsSuperAdmin { get; set; } = false;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Retrieve role stored in Session upon authentication
            string userRole = Session["UserRole"] as string;

            // Default fallback for development/testing if session is empty:
            if (string.IsNullOrEmpty(userRole))
            {
                userRole = "SuperAdmin";
            }

            IsSuperAdmin = userRole.Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase);

            // Hide the Admin tab on frontend if the user is not a SuperAdmin
            phAdminTab.Visible = IsSuperAdmin;

            if (!IsPostBack)
            {
                LoadUserActivityLogs();
            }
        }

        private void LoadUserActivityLogs()
        {
            DataTable dt = new DataTable();

            if (string.IsNullOrEmpty(connectionString))
            {
                // Fallback structured mock data
                dt.Columns.Add("LogId", typeof(int));
                dt.Columns.Add("UserId", typeof(int));
                dt.Columns.Add("UserName", typeof(string));
                dt.Columns.Add("Email", typeof(string));
                dt.Columns.Add("Role", typeof(string));
                dt.Columns.Add("RoleCategory", typeof(string)); // Used by client-side tab filter
                dt.Columns.Add("DateJoined", typeof(DateTime));
                dt.Columns.Add("StartDateTime", typeof(DateTime));
                dt.Columns.Add("EndDateTime", typeof(DateTime));

                dt.Rows.Add(101, 1, "Kylan Shane Sedrick", "kylan1234@gmail.com", "Learner", "learner", DateTime.Now.AddDays(-60), DateTime.Now.AddHours(-3), DateTime.Now.AddHours(-1).AddMinutes(-15));
                dt.Rows.Add(102, 2, "Wan Hon Kit", "wan1234@gmail.com", "Learner", "learner", DateTime.Now.AddDays(-30), DateTime.Now.AddHours(-1), DateTime.Now.AddMinutes(-10));
                dt.Rows.Add(103, 1, "Dr. Sarah Park", "sarah.park@codelearn.edu", "Teacher", "teacher", DateTime.Now.AddDays(-120), DateTime.Now.AddHours(-4), DateTime.Now.AddHours(-2));
                dt.Rows.Add(104, 1, "Jessica Lee", "jessica.lee@student.edu", "Teaching Assistant", "assistant", DateTime.Now.AddDays(-45), DateTime.Now.AddHours(-5), DateTime.Now.AddHours(-4).AddMinutes(-20));

                // Include Admin mock data only if SuperAdmin
                if (IsSuperAdmin)
                {
                    dt.Rows.Add(105, 1, "Tang Chee Kin", "tterry616@gmail.com", "SuperAdmin", "admin", DateTime.Now.AddDays(-100), DateTime.Now.AddMinutes(-50), DateTime.Now.AddMinutes(10));
                    dt.Rows.Add(106, 2, "Kevin Wong", "kevin.wong@codelearn.edu", "Admin", "admin", DateTime.Now.AddDays(-80), DateTime.Now.AddHours(-6), DateTime.Now.AddHours(-4));
                }

                BindLogs(dt);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // If not SuperAdmin, filter out any admin log entries at the SQL level
                    string adminFilterCondition = IsSuperAdmin ? "" : "WHERE ul.AdminId IS NULL";

                    string query = $@"
                        SELECT 
                            ul.LogId,
                            ul.StartDateTime,
                            ul.EndDateTime,
                            CASE 
                                WHEN ul.LearnerId IS NOT NULL THEN ul.LearnerId
                                WHEN ul.TeacherId IS NOT NULL THEN ul.TeacherId
                                WHEN ul.TA_Id IS NOT NULL THEN ul.TA_Id
                                WHEN ul.AdminId IS NOT NULL THEN ul.AdminId
                                ELSE 0 
                            END AS UserId,
                            CASE 
                                WHEN ul.AdminId IS NOT NULL THEN ISNULL(adm.Role, 'Admin')
                                WHEN ul.TeacherId IS NOT NULL THEN 'Teacher'
                                WHEN ul.TA_Id IS NOT NULL THEN 'Teaching Assistant'
                                WHEN ul.LearnerId IS NOT NULL THEN 'Learner'
                                ELSE 'Unknown' 
                            END AS Role,
                            CASE 
                                WHEN ul.AdminId IS NOT NULL THEN 'admin'
                                WHEN ul.TeacherId IS NOT NULL THEN 'teacher'
                                WHEN ul.TA_Id IS NOT NULL THEN 'assistant'
                                WHEN ul.LearnerId IS NOT NULL THEN 'learner'
                                ELSE 'unknown' 
                            END AS RoleCategory,
                            COALESCE(adm.Name, l.Name, t.Name, ta.Name, 'System User') AS UserName,
                            COALESCE(adm.Email, l.Email, t.Email, ta.Email, 'unknown@codercept.edu') AS Email,
                            COALESCE(l.DateJoined, GETDATE()) AS DateJoined
                        FROM [dbo].[User_Log] ul
                        LEFT JOIN [dbo].[Learner] l ON ul.LearnerId = l.LearnerId
                        LEFT JOIN [dbo].[Teacher] t ON ul.TeacherId = t.TeacherId
                        LEFT JOIN [dbo].[Teaching_Assistant] ta ON ul.TA_Id = ta.TA_Id
                        LEFT JOIN [dbo].[Admin] adm ON ul.AdminId = adm.AdminId
                        {adminFilterCondition}
                        ORDER BY ul.StartDateTime DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        adapter.Fill(dt);
                    }
                }

                BindLogs(dt);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminUserLogs Error]: {ex.Message}");
                pnlNoLogs.Visible = true;
            }
        }

        private void BindLogs(DataTable dt)
        {
            if (dt.Rows.Count > 0)
            {
                rptUserLogs.DataSource = dt;
                rptUserLogs.DataBind();
                pnlNoLogs.Visible = false;

                // Compute KPI statistics
                int totalSessions = dt.Rows.Count;
                int activeSessions = 0;
                double totalMinutes = 0;
                var uniqueUsers = new System.Collections.Generic.HashSet<string>();

                foreach (DataRow row in dt.Rows)
                {
                    DateTime start = Convert.ToDateTime(row["StartDateTime"]);
                    DateTime end = Convert.ToDateTime(row["EndDateTime"]);
                    string email = row["Email"].ToString();

                    if (!uniqueUsers.Contains(email))
                        uniqueUsers.Add(email);

                    if (IsSessionActive(end))
                        activeSessions++;

                    totalMinutes += (end - start).TotalMinutes;
                }

                litTotalSessions.Text = totalSessions.ToString("N0");
                litActiveSessions.Text = activeSessions.ToString();
                litAvgDuration.Text = $"{(int)(totalMinutes / totalSessions)}m";
                litUniqueUsers.Text = uniqueUsers.Count.ToString();
            }
            else
            {
                rptUserLogs.DataSource = null;
                rptUserLogs.DataBind();
                pnlNoLogs.Visible = true;

                litTotalSessions.Text = "0";
                litActiveSessions.Text = "0";
                litAvgDuration.Text = "0m";
                litUniqueUsers.Text = "0";
            }
        }

        protected string CalculateDuration(DateTime start, DateTime end)
        {
            TimeSpan span = end - start;
            if (span.TotalMinutes < 1) return "< 1m";

            int hours = (int)span.TotalHours;
            int minutes = span.Minutes;

            if (hours > 0)
                return $"{hours}h {minutes}m";

            return $"{minutes}m";
        }

        protected bool IsSessionActive(DateTime end)
        {
            return end >= DateTime.Now.AddMinutes(-5);
        }

        protected string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "U";
            string[] parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Substring(0, Math.Min(2, parts[0].Length)).ToUpper();
            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }

        protected string GetRoleBadgeClass(string role)
        {
            switch (role.Trim().ToLower())
            {
                case "superadmin":
                case "admin": return "badge-admin";
                case "teacher": return "badge-teacher";
                case "teaching assistant": return "badge-ta";
                default: return "badge-learner";
            }
        }
    }
}