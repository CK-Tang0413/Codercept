using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class TAProfile : System.Web.UI.Page
    {
        // 1. Define Data Structures
        public class QualificationItem
        {
            public string Name { get; set; }
            public string Date { get; set; }
            public string DocumentUrl { get; set; }
            public bool HasDocument { get { return !string.IsNullOrEmpty(DocumentUrl); } }
        }

        private readonly string connString = TAHelpers.ConnectionString;

        private int TaId { get { return Convert.ToInt32(Session["UserId"]); } }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadProfileData();

                // Shown after the post-save redirect (so the sidebar also picks up the new name)
                if (Request.QueryString["saved"] == "1")
                {
                    ShowMessage("Details updated.", true);
                }
            }
        }

        private void LoadProfileData()
        {
            const string query = @"
                SELECT Name, Email, Region, TeachingLevel, AccStatus,
                       (SELECT COUNT(*) FROM [dbo].[GradingProgress] WHERE TA_Id = @TA_Id AND ProgressStatus IN ('Reviewed', 'Approved')) AS Marked,
                       (SELECT COUNT(*) FROM [dbo].[Moderate_Forum] WHERE TA_Id = @TA_Id) AS Moderated,
                       (SELECT COUNT(*) FROM [dbo].[Post_Reply] WHERE TA_Id = @TA_Id) AS Replies
                FROM [dbo].[Teaching_Assistant]
                WHERE TA_Id = @TA_Id";

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@TA_Id", TaId);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            // The account no longer exists
                            Session.Clear();
                            Response.Redirect("signIn.aspx");
                            return;
                        }

                        txtName.Text = reader["Name"].ToString();
                        txtEmail.Text = reader["Email"].ToString();
                        txtRegion.Text = reader["Region"] != DBNull.Value ? reader["Region"].ToString() : "";
                        txtStatus.Text = reader["AccStatus"].ToString();

                        string name = reader["Name"].ToString().Trim();
                        string[] parts = name.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                        string initials = parts.Length == 0 ? "TA" : (parts.Length == 1 ? parts[0].Substring(0, 1) : parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpper();
                        bool active = string.Equals(reader["AccStatus"].ToString(), "Active", StringComparison.OrdinalIgnoreCase);
                        litIdentity.Text =
                            "<div class=\"avatar\">" + Server.HtmlEncode(initials) + "</div>" +
                            "<div class=\"identity-text\"><h2>" + Server.HtmlEncode(name) + "</h2>" +
                            "<div class=\"identity-email\">" + Server.HtmlEncode(reader["Email"].ToString()) + "</div>" +
                            "<div class=\"identity-tags\"><span class=\"tag " + (active ? "tag-active" : "tag-inactive") + "\">" + Server.HtmlEncode(reader["AccStatus"].ToString()) + "</span>" +
                            "<span class=\"tag tag-role\">Teaching Assistant</span></div></div>";

                        string level = reader["TeachingLevel"] != DBNull.Value ? reader["TeachingLevel"].ToString() : "";
                        ListItem levelItem = ddlTeachingLevel.Items.FindByValue(level);
                        if (levelItem != null) ddlTeachingLevel.SelectedValue = level;

                        litStatGraded.Text = reader["Marked"].ToString();
                        litStatModerated.Text = reader["Moderated"].ToString();
                        litStatReplies.Text = reader["Replies"].ToString();
                    }
                }

                // Qualifications
                var qualifications = new List<QualificationItem>();
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT QualificationName, QualificationDate, QualificationDocument FROM [dbo].[Qualification] WHERE TA_Id = @TA_Id ORDER BY QualificationDate DESC", con))
                {
                    cmd.Parameters.AddWithValue("@TA_Id", TaId);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            qualifications.Add(new QualificationItem
                            {
                                Name = reader["QualificationName"].ToString(),
                                Date = Convert.ToDateTime(reader["QualificationDate"]).ToString("MMMM dd, yyyy"),
                                DocumentUrl = SafeDocumentUrl(reader["QualificationDocument"].ToString())
                            });
                        }
                    }
                }

                phQualEmpty.Visible = qualifications.Count == 0;
                rptQualifications.DataSource = qualifications;
                rptQualifications.DataBind();
            }
        }

        // Only app-relative paths are linked, so a stored value can never become a javascript: link
        private string SafeDocumentUrl(string stored)
        {
            if (string.IsNullOrWhiteSpace(stored)) return "";
            stored = stored.Trim();

            if (stored.StartsWith("~/")) return ResolveUrl(stored);
            if (stored.StartsWith("/") && !stored.StartsWith("//")) return stored;
            return "";
        }

        protected void btnUpdateProfile_Click(object sender, EventArgs e)
        {
            string name = txtName.Text.Trim();
            string region = txtRegion.Text.Trim();
            string level = ddlTeachingLevel.SelectedValue;

            if (name.Length == 0) { ShowMessage("Full name is required.", false); return; }
            if (name.Length > 50) { ShowMessage("Full name must be 50 characters or fewer.", false); return; }
            if (region.Length > 50) { ShowMessage("Region must be 50 characters or fewer.", false); return; }

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(
                "UPDATE [dbo].[Teaching_Assistant] SET Name = @Name, Region = @Region, TeachingLevel = @Level WHERE TA_Id = @TA_Id", con))
            {
                cmd.Parameters.AddWithValue("@Name", name);
                cmd.Parameters.AddWithValue("@Region", region.Length > 0 ? (object)region : DBNull.Value);
                cmd.Parameters.AddWithValue("@Level", level);
                cmd.Parameters.AddWithValue("@TA_Id", TaId);
                con.Open();
                cmd.ExecuteNonQuery();
            }

            Session["UserName"] = name;

            // Redirect so the sidebar (already rendered for this request) shows the new name
            Response.Redirect("TAProfile.aspx?saved=1");
        }

        private void ShowMessage(string message, bool success)
        {
            litMessage.Text = Server.HtmlEncode(message);
            pnlMessage.CssClass = success ? "toast" : "toast toast-error";
            pnlMessage.Visible = true;
        }
    }
}
