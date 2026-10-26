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
    public partial class Admin_Community : System.Web.UI.Page
    {
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["CoderceptDB"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadAnnouncements();
            }
        }

        private void LoadAnnouncements()
        {
            DataTable dt = new DataTable();

            if (string.IsNullOrEmpty(connectionString))
            {
                // Fallback mock data when running without an active database connection
                dt.Columns.Add("NotificationId", typeof(int));
                dt.Columns.Add("Title", typeof(string));
                dt.Columns.Add("Content", typeof(string));
                dt.Columns.Add("Type", typeof(string));
                dt.Columns.Add("DateTime", typeof(DateTime));
                dt.Columns.Add("IsPinned", typeof(bool));

                dt.Rows.Add(
                    1,
                    "New C++ Module Now Available!",
                    "We are excited to announce the launch of \"Data Structures with C++\" by Prof. Michael Torres. Enroll today to master linked lists, trees, and hash tables from scratch with interactive code sandboxes and real-world projects designed for all skill levels.",
                    "Announcement",
                    DateTime.Now.AddDays(-2),
                    true
                );

                dt.Rows.Add(
                    2,
                    "Python Hackathon 2026 Invitation",
                    "Join us for the CodeLearn National Python Marathon this coming weekend! You will collaborate in teams to solve competitive programming tasks, optimize neuroevolution models, and earn official platform badges and certificates.",
                    "Invitation",
                    DateTime.Now.AddDays(-1),
                    false
                );

                BindRepeater(dt);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Query mapped to [dbo].[Notification], ordering pinned records first
                    string query = @"
                        SELECT NotificationId, Title, Content, Type, DateTime,
                               ISNULL(IsPinned, 0) AS IsPinned
                        FROM Notification
                        ORDER BY IsPinned DESC, DateTime DESC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        adapter.Fill(dt);
                    }
                }

                BindRepeater(dt);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminCommunity Load Error]: {ex.Message}");
                pnlNoAnnouncements.Visible = true;
            }
        }

        private void BindRepeater(DataTable dt)
        {
            litAnnouncementCount.Text = dt.Rows.Count.ToString();

            if (dt.Rows.Count > 0)
            {
                rptAnnouncements.DataSource = dt;
                rptAnnouncements.DataBind();
                pnlNoAnnouncements.Visible = false;
            }
            else
            {
                rptAnnouncements.DataSource = null;
                rptAnnouncements.DataBind();
                pnlNoAnnouncements.Visible = true;
            }
        }

        // 1. Post Announcement (Insert)
        protected void btnPostAnnouncement_Click(object sender, EventArgs e)
        {
            string title = txtTitle.Text.Trim();
            string content = txtContent.Text.Trim();
            string type = ddlType.SelectedValue;
            bool isPinned = chkPinToggle.Checked;

            if (string.IsNullOrEmpty(title) || string.IsNullOrEmpty(content))
            {
                return;
            }

            if (!string.IsNullOrEmpty(connectionString))
            {
                try
                {
                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        conn.Open();

                        string insertQuery = @"
                            INSERT INTO Notification (Title, Content, Type, DateTime, IsPinned)
                            VALUES (@Title, @Content, @Type, GETDATE(), @IsPinned)";

                        using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@Title", title);
                            cmd.Parameters.AddWithValue("@Content", content);
                            cmd.Parameters.AddWithValue("@Type", type);
                            cmd.Parameters.AddWithValue("@IsPinned", isPinned);

                            cmd.ExecuteNonQuery();
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[AdminCommunity Insert Error]: {ex.Message}");
                }
            }

            // Clear inputs and reload list
            txtTitle.Text = string.Empty;
            txtContent.Text = string.Empty;
            chkPinToggle.Checked = false;
            ddlType.SelectedIndex = 0;

            LoadAnnouncements();
        }

        // 2. Command handling: Pin/Unpin & Delete
        protected void rptAnnouncements_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int notificationId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "TogglePin")
            {
                TogglePinStatus(notificationId);
            }
            else if (e.CommandName == "DeleteAnnouncement")
            {
                DeleteAnnouncement(notificationId);
            }

            LoadAnnouncements();
        }

        private void TogglePinStatus(int notificationId)
        {
            if (string.IsNullOrEmpty(connectionString)) return;

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = @"
                        UPDATE Notification
                        SET IsPinned = CASE WHEN ISNULL(IsPinned, 0) = 1 THEN 0 ELSE 1 END
                        WHERE NotificationId = @Id";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Id", notificationId);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminCommunity Pin Error]: {ex.Message}");
            }
        }

        private void DeleteAnnouncement(int notificationId)
        {
            if (string.IsNullOrEmpty(connectionString)) return;

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = "DELETE FROM Notification WHERE NotificationId = @Id";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Id", notificationId);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminCommunity Delete Error]: {ex.Message}");
            }
        }

        // Helper: Truncates content with ellipsis if exceeding max length
        protected string TruncateContent(string text, int maxLength)
        {
            if (string.IsNullOrEmpty(text)) return string.Empty;
            if (text.Length <= maxLength) return text;

            return text.Substring(0, maxLength).TrimEnd() + ".....";
        }

        // Helper: Sanitizes text for JavaScript function call attributes
        protected string AntiXssEncode(string input)
        {
            if (string.IsNullOrEmpty(input)) return string.Empty;

            return input.Replace("\\", "\\\\")
                        .Replace("'", "\\'")
                        .Replace("\"", "&quot;")
                        .Replace("\r\n", " ")
                        .Replace("\n", " ");
        }
    }
}