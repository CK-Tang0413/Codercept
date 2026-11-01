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
    public partial class Admin_User_Management : System.Web.UI.Page
    {
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["Codercept_db"]?.ConnectionString 
            ?? ConfigurationManager.ConnectionStrings["CoderceptDB"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            string userRole = (Session["UserRole"] as string) ?? (Session["UserType"] as string);
            if (Session["UserId"] == null || string.IsNullOrEmpty(userRole))
            {
                Response.Redirect("LandingPage.aspx");
                return;
            }

            bool isSuperAdmin = userRole.Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase) ||
                                userRole.Equals("Super Admin", StringComparison.OrdinalIgnoreCase);
            bool isAdmin = userRole.Equals("Admin", StringComparison.OrdinalIgnoreCase);

            if (!isSuperAdmin && !isAdmin)
            {
                Response.Redirect("AdminDashboard.aspx");
                return;
            }

            pnlSuperAdminAction.Visible = isSuperAdmin;
            if (CreateAdminAccountCtrl != null)
            {
                CreateAdminAccountCtrl.Visible = isSuperAdmin;
            }

            if (!IsPostBack)
            {
                // Automated weekly removal check: removes users with 'Deleted' status automatically every week
                UserPurgeService.CheckAndPerformPurgeIfNeeded(Server, Application);

                LoadAllUsers();
                UpdatePurgeBannerInfo();
                CheckQueryStringNotifications();
            }
        }


        private void CheckQueryStringNotifications()
        {
            string msg = Request.QueryString["msg"];
            if (string.IsNullOrEmpty(msg) || pnlNotification == null) return;

            string email = Request.QueryString["email"];
            string safeEmail = !string.IsNullOrEmpty(email) ? HttpUtility.HtmlEncode(email) : "the specified address";

            if (msg.Equals("admin_created", StringComparison.OrdinalIgnoreCase))
            {
                pnlNotification.Visible = true;
                pnlNotification.CssClass = "alert-banner alert-success";
                litNotificationIcon.Text = "<i class=\"fa-solid fa-circle-check\" style=\"color: #10b981;\"></i>";
                litNotificationMessage.Text = $"<strong>Administrator Account Created!</strong> An email containing the temporary password has been sent to <strong>{safeEmail}</strong>.";
            }
            else if (msg.Equals("admin_created_email_failed", StringComparison.OrdinalIgnoreCase))
            {
                string err = Request.QueryString["err"];
                string errDetails = !string.IsNullOrEmpty(err) ? $" (Reason: {HttpUtility.HtmlEncode(err)})" : "";
                pnlNotification.Visible = true;
                pnlNotification.CssClass = "alert-banner alert-warning";
                litNotificationIcon.Text = "<i class=\"fa-solid fa-triangle-exclamation\" style=\"color: #f59e0b;\"></i>";
                litNotificationMessage.Text = $"<strong>Administrator Account Created:</strong> The account was successfully created, but the system encountered an issue sending the temporary password email to <strong>{safeEmail}</strong>{errDetails}. Please provide the temporary password to the administrator manually.";
            }
            else if (msg.Equals("application_approved", StringComparison.OrdinalIgnoreCase))
            {
                pnlNotification.Visible = true;
                pnlNotification.CssClass = "alert-banner alert-success";
                litNotificationIcon.Text = "<i class=\"fa-solid fa-circle-check\" style=\"color: #10b981;\"></i>";
                litNotificationMessage.Text = "<strong>Application Approved!</strong> The educator account is now active, and an approval confirmation email has been dispatched.";
            }
            else if (msg.Equals("application_rejected", StringComparison.OrdinalIgnoreCase))
            {
                pnlNotification.Visible = true;
                pnlNotification.CssClass = "alert-banner alert-danger";
                litNotificationIcon.Text = "<i class=\"fa-solid fa-circle-xmark\" style=\"color: #ef4444;\"></i>";
                litNotificationMessage.Text = "<strong>Application Rejected.</strong> The applicant has been notified of the decision via email.";
            }
        }

        private void UpdatePurgeBannerInfo()
        {
            if (litPurgeScheduleInfo != null)
            {
                litPurgeScheduleInfo.Text = "<span style='display:inline-block; margin-left: 6px; opacity: 0.9;'>&bull; " + 
                    HttpUtility.HtmlEncode(UserPurgeService.GetScheduleStatusDescription(Server, Application)) + "</span>";
            }
        }

        private void LoadAllUsers()
        {
            DataTable dt = new DataTable();

            if (string.IsNullOrEmpty(connectionString))
            {
                rptUsers.DataSource = null;
                rptUsers.DataBind();
                litUserCount.Text = "0";
                litDeletedCount.Text = "0";
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = @"
                        SELECT 
                            AdminId AS UserId, 
                            Name, 
                            Email, 
                            Role, 
                            'admin' AS RoleCategory, 
                            ISNULL(AccStatus, 'Active') AS AccStatus, 
                            CAST(NULL AS DATETIME) AS DateJoined, 
                            NULL AS Age, 
                            NULL AS Region, 
                            NULL AS TeachingLevel, 
                            NULL AS QualificationName, 
                            NULL AS QualificationDocument,
                            NULL AS SubjectTeaching,
                            NULL AS Address,
                            NULL AS Occupation,
                            NULL AS ProgressCourses,
                            NULL AS CompletedCourses
                        FROM [dbo].[Admin]

                        UNION ALL

                        SELECT 
                            t.TeacherId AS UserId, 
                            t.Name, 
                            t.Email, 
                            'Teacher' AS Role, 
                            'teacher' AS RoleCategory, 
                            ISNULL(t.AccStatus, 'Active') AS AccStatus,
                            t.DateJoined, 
                            t.Age, 
                            t.Region, 
                            t.TeachingLevel, 
                            ISNULL(t.QualificationName, a.QualificationName) AS QualificationName, 
                            COALESCE(NULLIF(t.QualificationDocument, ''), NULLIF(a.CredentialDocument, '')) AS QualificationDocument,
                            (
                                SELECT STRING_AGG(s.SubjectName, ', ')
                                FROM [dbo].[EducatorSubject] es
                                JOIN [dbo].[Subject] s ON es.SubjectId = s.SubjectId
                                WHERE es.TeacherId = t.TeacherId
                            ) AS SubjectTeaching,
                            NULL AS Address,
                            NULL AS Occupation,
                            NULL AS ProgressCourses,
                            NULL AS CompletedCourses
                        FROM [dbo].[Teacher] t
                        LEFT JOIN [dbo].[Application] a ON t.ApplicationId = a.ApplicationId

                        UNION ALL

                        SELECT 
                            ta.TA_Id AS UserId, 
                            ta.Name, 
                            ta.Email, 
                            'Teaching Assistant' AS Role, 
                            'assistant' AS RoleCategory, 
                            ISNULL(ta.AccStatus, 'Active') AS AccStatus,
                            ta.DateJoined, 
                            ta.Age, 
                            ta.Region, 
                            ta.TeachingLevel, 
                            ISNULL(ta.QualificationName, a.QualificationName) AS QualificationName, 
                            COALESCE(NULLIF(ta.QualificationDocument, ''), NULLIF(a.CredentialDocument, '')) AS QualificationDocument,
                            (
                                SELECT STRING_AGG(s.SubjectName, ', ')
                                FROM [dbo].[EducatorSubject] es
                                JOIN [dbo].[Subject] s ON es.SubjectId = s.SubjectId
                                WHERE es.TA_Id = ta.TA_Id
                            ) AS SubjectTeaching,
                            NULL AS Address,
                            NULL AS Occupation,
                            NULL AS ProgressCourses,
                            NULL AS CompletedCourses
                        FROM [dbo].[Teaching_Assistant] ta
                        LEFT JOIN [dbo].[Application] a ON ta.ApplicationId = a.ApplicationId

                        UNION ALL

                        SELECT 
                            l.LearnerId AS UserId, 
                            l.Name, 
                            l.Email, 
                            'Learner' AS Role, 
                            'learner' AS RoleCategory, 
                            ISNULL(l.AccStatus, 'Active') AS AccStatus,
                            l.DateJoined, 
                            l.Age, 
                            l.Address AS Region, 
                            l.Occupation AS TeachingLevel, 
                            NULL AS QualificationName, 
                            NULL AS QualificationDocument,
                            NULL AS SubjectTeaching,
                            l.Address,
                            l.Occupation,
                            ISNULL((
                                SELECT STRING_AGG(c.CourseTitle, ', ')
                                FROM [dbo].[LearnerProgress] lp
                                JOIN [dbo].[Course] c ON lp.CourseId = c.CourseId
                                WHERE lp.LearnerId = l.LearnerId
                                  AND NOT EXISTS (
                                      SELECT 1 FROM [dbo].[Certificate] cert 
                                      WHERE cert.LearnerId = l.LearnerId AND cert.CourseId = lp.CourseId
                                  )
                            ), 'None in progress') AS ProgressCourses,
                            ISNULL((
                                SELECT STRING_AGG(c.CourseTitle, ', ')
                                FROM (
                                    SELECT DISTINCT cert.CourseId
                                    FROM [dbo].[Certificate] cert
                                    WHERE cert.LearnerId = l.LearnerId
                                ) userCerts
                                JOIN [dbo].[Course] c ON userCerts.CourseId = c.CourseId
                            ), 'None completed') AS CompletedCourses
                        FROM [dbo].[Learner] l

                        ORDER BY RoleCategory ASC, Name ASC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        adapter.Fill(dt);
                    }
                }

                rptUsers.DataSource = dt;
                rptUsers.DataBind();

                int activeUsers = dt.AsEnumerable().Count(r => !r.Field<string>("AccStatus").Equals("Deleted", StringComparison.OrdinalIgnoreCase));
                int deletedUsers = dt.AsEnumerable().Count(r => r.Field<string>("AccStatus").Equals("Deleted", StringComparison.OrdinalIgnoreCase));

                litUserCount.Text = activeUsers.ToString();
                litDeletedCount.Text = deletedUsers.ToString();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminUserManagement Load Error]: {ex.Message}");
                rptUsers.DataSource = null;
                rptUsers.DataBind();
                litUserCount.Text = "0";
                litDeletedCount.Text = "0";
            }
        }

        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string[] args = e.CommandArgument.ToString().Split('|');
            if (args.Length >= 3 && e.CommandName == "ToggleStatus")
            {
                int userId = Convert.ToInt32(args[0]);
                string roleCategory = args[1];
                string currentStatus = args[2];

                // Guard: Pending educator accounts must go through application review first
                if (currentStatus.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                {
                    return;
                }

                string nextStatus = currentStatus.Equals("Active", StringComparison.OrdinalIgnoreCase) ? "Inactive" : "Active";

                UpdateUserStatus(userId, roleCategory, nextStatus);
                LoadAllUsers();
            }
        }

        private void UpdateUserStatus(int userId, string roleCategory, string newStatus)
        {
            if (string.IsNullOrEmpty(connectionString)) return;

            string tableName = GetTableName(roleCategory);
            string idCol = GetIdColumn(roleCategory);

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = $"UPDATE [dbo].[{tableName}] SET AccStatus = @Status WHERE [{idCol}] = @Id";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Status", newStatus);
                        cmd.Parameters.AddWithValue("@Id", userId);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminUserManagement Update Error]: {ex.Message}");
            }
        }

        private string GetTableName(string roleCategory)
        {
            switch (roleCategory.ToLower())
            {
                case "admin": return "Admin";
                case "teacher": return "Teacher";
                case "assistant": return "Teaching_Assistant";
                default: return "Learner";
            }
        }

        private string GetIdColumn(string roleCategory)
        {
            switch (roleCategory.ToLower())
            {
                case "admin": return "AdminId";
                case "teacher": return "TeacherId";
                case "assistant": return "TA_Id";
                default: return "LearnerId";
            }
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

        protected string GetStatusBadgeClass(string status)
        {
            switch (status.Trim().ToLower())
            {
                case "active": return "badge-active";
                case "pending": return "badge-pending";
                case "deleted": return "badge-deleted";
                default: return "badge-inactive";
            }
        }

        protected void btnConfirmSoftDelete_Click(object sender, EventArgs e)
        {
            if (int.TryParse(hfDeleteTargetUserId.Value, out int userId))
            {
                string roleCategory = hfDeleteTargetRole.Value;
                // Guard: Pending educator accounts cannot be moved to deleted without review
                if (!IsUserPending(userId, roleCategory))
                {
                    UpdateUserStatus(userId, roleCategory, "Deleted");
                }
            }

            hfDeleteTargetUserId.Value = string.Empty;
            hfDeleteTargetRole.Value = string.Empty;
            LoadAllUsers();
            UpdatePurgeBannerInfo();
        }

        private bool IsUserPending(int userId, string roleCategory)
        {
            if (string.IsNullOrEmpty(connectionString)) return false;
            string tableName = GetTableName(roleCategory);
            string idCol = GetIdColumn(roleCategory);

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = $"SELECT AccStatus FROM [dbo].[{tableName}] WHERE [{idCol}] = @Id";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Id", userId);
                        object statusObj = cmd.ExecuteScalar();
                        if (statusObj != null && statusObj != DBNull.Value)
                        {
                            return statusObj.ToString().Equals("Pending", StringComparison.OrdinalIgnoreCase);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminUserManagement IsUserPending Error]: {ex.Message}");
            }
            return false;
        }

        protected void btnRunWeeklyPurge_Click(object sender, EventArgs e)
        {
            UserPurgeService.PerformPurge(Server, Application);
            LoadAllUsers();
            UpdatePurgeBannerInfo();
        }
    }
}
