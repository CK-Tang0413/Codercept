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
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["CoderceptDB"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string userRole = Session["UserRole"] as string ?? "SuperAdmin";
                pnlSuperAdminAction.Visible = userRole.Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase);

                LoadAllUsers();
            }
        }

        private void LoadAllUsers()
        {
            DataTable dt = new DataTable();

            if (string.IsNullOrEmpty(connectionString))
            {
                // Fallback Mock Data
                dt.Columns.Add("UserId", typeof(int));
                dt.Columns.Add("Name", typeof(string));
                dt.Columns.Add("Email", typeof(string));
                dt.Columns.Add("Role", typeof(string));
                dt.Columns.Add("RoleCategory", typeof(string));
                dt.Columns.Add("AccStatus", typeof(string));
                dt.Columns.Add("DateJoined", typeof(DateTime));
                dt.Columns.Add("Age", typeof(object));
                dt.Columns.Add("Region", typeof(string));
                dt.Columns.Add("TeachingLevel", typeof(string));
                dt.Columns.Add("QualificationName", typeof(string));
                dt.Columns.Add("QualificationDocument", typeof(string));

                dt.Rows.Add(1, "Tang Chee Kin", "tterry616@gmail.com", "SuperAdmin", "admin", "Active", DateTime.Now.AddDays(-120), DBNull.Value, "", "", "", "");
                dt.Rows.Add(2, "Kevin Wong", "kevin.wong@codercept.edu", "Admin", "admin", "Active", DateTime.Now.AddDays(-80), DBNull.Value, "", "", "", "");
                dt.Rows.Add(1, "Dr. Sarah Park", "sarah.park@codercept.edu", "Teacher", "teacher", "Active", DateTime.Now.AddDays(-60), 36, "Selangor", "Advanced", "PhD in Computer Science", "~/media/uploads/1/13551c8f08844826b9841992d3314ee0.jpg");
                dt.Rows.Add(9, "Emma Wilson", "emma.wilson@codercept.edu", "Teacher", "teacher", "Pending", DateTime.Now.AddDays(-3), 28, "Kuala Lumpur", "Intermediate", "Master in Distributed Systems", "~/media/uploads/1/13551c8f08844826b9841992d3314ee0.jpg");
                dt.Rows.Add(1, "Jessica Lee", "jessica.lee@codercept.edu", "Teaching Assistant", "assistant", "Active", DateTime.Now.AddDays(-40), 24, "Selangor", "Intermediate", "Bachelor of Computer Science", "~/media/uploads/1/13551c8f08844826b9841992d3314ee0.jpg");
                dt.Rows.Add(1, "Kylan Shane Sedrick", "kylan1234@gmail.com", "Learner", "learner", "Active", DateTime.Now.AddDays(-30), 21, "Negeri Sembilan", "Student", "", "");
                dt.Rows.Add(2, "Wan Hon Kit", "wan1234@gmail.com", "Learner", "learner", "Active", DateTime.Now.AddDays(-25), 21, "Penang", "Student", "", "");

                rptUsers.DataSource = dt;
                rptUsers.DataBind();
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = @"
                        SELECT AdminId AS UserId, Name, Email, Role, 'admin' AS RoleCategory, AccStatus, 
                               GETDATE() AS DateJoined, NULL AS Age, NULL AS Region, NULL AS TeachingLevel, 
                               NULL AS QualificationName, NULL AS QualificationDocument
                        FROM [dbo].[Admin]
                        UNION ALL
                        SELECT TeacherId AS UserId, Name, Email, 'Teacher' AS Role, 'teacher' AS RoleCategory, AccStatus,
                               DateJoined, Age, Region, TeachingLevel, QualificationName, QualificationDocument
                        FROM [dbo].[Teacher]
                        UNION ALL
                        SELECT TA_Id AS UserId, Name, Email, 'Teaching Assistant' AS Role, 'assistant' AS RoleCategory, AccStatus,
                               DateJoined, Age, Region, TeachingLevel, QualificationName, QualificationDocument
                        FROM [dbo].[Teaching_Assistant]
                        UNION ALL
                        SELECT LearnerId AS UserId, Name, Email, 'Learner' AS Role, 'learner' AS RoleCategory, AccStatus,
                               DateJoined, Age, Address AS Region, Occupation AS TeachingLevel, NULL AS QualificationName, NULL AS QualificationDocument
                        FROM [dbo].[Learner]
                        ORDER BY RoleCategory ASC, Name ASC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        adapter.Fill(dt);
                    }
                }

                rptUsers.DataSource = dt;
                rptUsers.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminUserManagement Load Error]: {ex.Message}");
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
                UpdateUserStatus(userId, roleCategory, "Deleted");
            }

            hfDeleteTargetUserId.Value = string.Empty;
            hfDeleteTargetRole.Value = string.Empty;
            LoadAllUsers();
        }
    }
}