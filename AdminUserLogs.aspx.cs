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
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["Codercept_db"]?.ConnectionString 
            ?? ConfigurationManager.ConnectionStrings["CoderceptDB"]?.ConnectionString;
        protected bool IsSuperAdmin { get; set; } = false;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Retrieve role stored in Session upon authentication
            string userRole = (Session["UserRole"] as string) ?? (Session["UserType"] as string);

            // Redirect unauthenticated users
            if (Session["UserId"] == null || string.IsNullOrEmpty(userRole))
            {
                Response.Redirect("LandingPage.aspx");
                return;
            }

            IsSuperAdmin = userRole.Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase) ||
                           userRole.Equals("Super Admin", StringComparison.OrdinalIgnoreCase);

            bool isAdmin = userRole.Equals("Admin", StringComparison.OrdinalIgnoreCase);

            // Allow both SuperAdmin and Admin to access the user log interface; redirect unauthorized roles
            if (!IsSuperAdmin && !isAdmin)
            {
                Response.Redirect("AdminDashboard.aspx");
                return;
            }

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
                pnlNoLogs.Visible = true;
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
                            COALESCE(adm.AccStatus, l.AccStatus, t.AccStatus, ta.AccStatus, 'Active') AS AccStatus,
                            COALESCE(l.DateJoined, t.DateJoined, ta.DateJoined, GETDATE()) AS DateJoined,
                            COALESCE(l.Age, t.Age, ta.Age) AS Age,
                            COALESCE(t.Region, ta.Region, 'N/A') AS Region,
                            COALESCE(t.TeachingLevel, ta.TeachingLevel, 'N/A') AS TeachingLevel,
                            COALESCE(t.QualificationName, ta.QualificationName, a_t.QualificationName, a_ta.QualificationName, 'N/A') AS QualificationName,
                            COALESCE(NULLIF(t.QualificationDocument, ''), NULLIF(ta.QualificationDocument, ''), NULLIF(a_t.CredentialDocument, ''), NULLIF(a_ta.CredentialDocument, ''), '') AS QualificationDocument,
                            l.Address,
                            l.Occupation,
                            ISNULL(
                                CASE 
                                    WHEN ul.TeacherId IS NOT NULL THEN (
                                        SELECT STRING_AGG(s.SubjectName, ', ')
                                        FROM [dbo].[EducatorSubject] es
                                        JOIN [dbo].[Subject] s ON es.SubjectId = s.SubjectId
                                        WHERE es.TeacherId = ul.TeacherId
                                    )
                                    WHEN ul.TA_Id IS NOT NULL THEN (
                                        SELECT STRING_AGG(s.SubjectName, ', ')
                                        FROM [dbo].[EducatorSubject] es
                                        JOIN [dbo].[Subject] s ON es.SubjectId = s.SubjectId
                                        WHERE es.TA_Id = ul.TA_Id
                                    )
                                    ELSE 'N/A'
                                END, 'N/A'
                            ) AS SubjectTeaching,
                            ISNULL((
                                SELECT STRING_AGG(c.CourseTitle, ', ')
                                FROM [dbo].[LearnerProgress] lp
                                JOIN [dbo].[Course] c ON lp.CourseId = c.CourseId
                                WHERE lp.LearnerId = ul.LearnerId
                                  AND NOT EXISTS (
                                      SELECT 1 FROM [dbo].[Certificate] cert 
                                      WHERE cert.LearnerId = ul.LearnerId AND cert.CourseId = lp.CourseId
                                  )
                            ), 'None in progress') AS ProgressCourses,
                            ISNULL((
                                SELECT STRING_AGG(c.CourseTitle, ', ')
                                FROM (
                                    SELECT DISTINCT cert.CourseId
                                    FROM [dbo].[Certificate] cert
                                    WHERE cert.LearnerId = ul.LearnerId
                                ) userCerts
                                JOIN [dbo].[Course] c ON userCerts.CourseId = c.CourseId
                            ), 'None completed') AS CompletedCourses
                        FROM [dbo].[User_Log] ul
                        LEFT JOIN [dbo].[Learner] l ON ul.LearnerId = l.LearnerId
                        LEFT JOIN [dbo].[Teacher] t ON ul.TeacherId = t.TeacherId
                        LEFT JOIN [dbo].[Teaching_Assistant] ta ON ul.TA_Id = ta.TA_Id
                        LEFT JOIN [dbo].[Admin] adm ON ul.AdminId = adm.AdminId
                        LEFT JOIN [dbo].[Application] a_t ON t.ApplicationId = a_t.ApplicationId
                        LEFT JOIN [dbo].[Application] a_ta ON ta.ApplicationId = a_ta.ApplicationId
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
            if (dt != null && dt.Rows.Count > 0)
            {
                rptUserLogs.DataSource = dt;
                rptUserLogs.DataBind();
                pnlNoLogs.Visible = false;

                // Compute KPI statistics
                int totalSessions = dt.Rows.Count;
                int activeSessions = 0;
                double totalMinutes = 0;
                var uniqueUsers = new HashSet<string>(StringComparer.OrdinalIgnoreCase);

                foreach (DataRow row in dt.Rows)
                {
                    DateTime start = row["StartDateTime"] != DBNull.Value ? Convert.ToDateTime(row["StartDateTime"]) : DateTime.Now;
                    DateTime end = (row["EndDateTime"] != DBNull.Value) ? Convert.ToDateTime(row["EndDateTime"]) : start;
                    string email = row["Email"]?.ToString() ?? "";

                    if (!string.IsNullOrWhiteSpace(email) && !uniqueUsers.Contains(email))
                        uniqueUsers.Add(email);

                    if (IsSessionActive(row["EndDateTime"]))
                        activeSessions++;

                    double minutes = (end - start).TotalMinutes;
                    if (minutes > 0)
                        totalMinutes += minutes;
                }

                litTotalSessions.Text = totalSessions.ToString("N0");
                litActiveSessions.Text = activeSessions.ToString();
                int avgTotalMin = totalSessions > 0 ? (int)(totalMinutes / totalSessions) : 0;
                litAvgDuration.Text = avgTotalMin >= 60 ? $"{avgTotalMin / 60}h {avgTotalMin % 60}m" : $"{avgTotalMin}m";
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

        protected string CalculateDuration(object startObj, object endObj)
        {
            if (startObj == null || startObj == DBNull.Value) return "< 1m";
            DateTime start = Convert.ToDateTime(startObj);
            DateTime end = (endObj != null && endObj != DBNull.Value) ? Convert.ToDateTime(endObj) : DateTime.Now;

            TimeSpan span = end - start;
            if (span.TotalMinutes < 1) return "< 1m";

            int hours = (int)span.TotalHours;
            int minutes = span.Minutes;

            if (hours > 0)
                return $"{hours}h {minutes}m";

            return $"{minutes}m";
        }

        protected bool IsSessionActive(object endObj)
        {
            if (endObj == null || endObj == DBNull.Value) return true;
            return false;
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
