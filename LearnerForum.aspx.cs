using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class LearnerForum : System.Web.UI.Page
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
                // Check if returning from LearnerAddPost
                if (Session["NewPostId"] != null)
                {
                    ViewState["ActivePostId"] = Session["NewPostId"].ToString();
                    Session.Remove("NewPostId");
                }

                BindPosts();
            }
        }

        private void BindPosts()
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                // 1. Load visible posts (Exclude hidden moderation posts)
                string postQuery = @"
                    SELECT 
                        f.PostId, 
                        f.Title, 
                        f.Content, 
                        f.Tags,
                        f.DatePosted,
                        (SELECT COUNT(*) FROM Post_Reply WHERE PostId = f.PostId) as ReplyCount
                    FROM Forum f
                    WHERE f.IsHidden = 0
                    ORDER BY f.DatePosted DESC";

                using (SqlCommand cmd = new SqlCommand(postQuery, con))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        dt.Columns.Add("IsActive", typeof(bool));

                        // If there is no active post in ViewState but posts exist, select the first one
                        if (ViewState["ActivePostId"] == null && dt.Rows.Count > 0)
                        {
                            ViewState["ActivePostId"] = dt.Rows[0]["PostId"].ToString();
                        }

                        // Determine the active row
                        foreach (DataRow row in dt.Rows)
                        {
                            bool isActive = ViewState["ActivePostId"] != null && row["PostId"].ToString() == ViewState["ActivePostId"].ToString();
                            row["IsActive"] = isActive;

                            if (isActive)
                            {
                                litActivePostTitle.Text = row["Title"].ToString();
                            }
                        }

                        rptPosts.DataSource = dt;
                        rptPosts.DataBind();
                    }
                }

                // 2. Load comments for the active post
                if (ViewState["ActivePostId"] != null)
                {
                    pnlComments.Visible = true;

                    string commentQuery = @"
                        SELECT 
                            pr.ThreadId,
                            pr.ReplyComment,
                            pr.IsPinned,
                            pr.DateReplied,
                            pr.ParentThreadId,
                            COALESCE(l.Name, t.Name, ta.Name, 'System') as AuthorName,
                            CASE 
                                WHEN pr.LearnerId IS NOT NULL THEN 'Learner'
                                WHEN pr.TeacherId IS NOT NULL THEN 'Teacher'
                                WHEN pr.TA_Id IS NOT NULL THEN 'TA'
                                ELSE 'System'
                            END as Role
                        FROM Post_Reply pr
                        LEFT JOIN Learner l ON pr.LearnerId = l.LearnerId
                        LEFT JOIN Teacher t ON pr.TeacherId = t.TeacherId
                        LEFT JOIN Teaching_Assistant ta ON pr.TA_Id = ta.TA_Id
                        WHERE pr.PostId = @PostId
                        ORDER BY 
                            CASE WHEN pr.IsPinned = 'Yes' THEN 1 ELSE 2 END, -- Pinned first
                            pr.DateReplied ASC";

                    using (SqlCommand cmd = new SqlCommand(commentQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@PostId", Convert.ToInt32(ViewState["ActivePostId"]));
                        using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            sda.Fill(dt);

                            rptComments.DataSource = dt;
                            rptComments.DataBind();
                        }
                    }
                }
                else
                {
                    pnlComments.Visible = false;
                }
            }
        }

        protected void rptPosts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectPost")
            {
                ViewState["ActivePostId"] = e.CommandArgument.ToString();

                // Reset input box when changing threads
                hfReplyToId.Value = "";
                txtComment.Attributes["placeholder"] = "Type comment here...";

                BindPosts();
            }
        }

        protected void btnSendComment_Click(object sender, EventArgs e)
        {
            string message = txtComment.Text.Trim();
            if (string.IsNullOrEmpty(message) || ViewState["ActivePostId"] == null) return;

            int postId = Convert.ToInt32(ViewState["ActivePostId"]);
            int learnerId = Convert.ToInt32(Session["UserId"]);

            // Allow parsing ParentThreadId if they clicked reply
            int? parentThreadId = null;
            if (!string.IsNullOrEmpty(hfReplyToId.Value))
            {
                parentThreadId = Convert.ToInt32(hfReplyToId.Value);
            }

            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = @"
                    INSERT INTO Post_Reply (ReplyComment, IsPinned, PostId, LearnerId, ParentThreadId) 
                    VALUES (@ReplyComment, 'No', @PostId, @LearnerId, @ParentThreadId)";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@ReplyComment", message);
                    cmd.Parameters.AddWithValue("@PostId", postId);
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    cmd.Parameters.AddWithValue("@ParentThreadId", (object)parentThreadId ?? DBNull.Value);

                    con.Open();
                    cmd.ExecuteNonQuery();
                    con.Close();
                }
            }
            // Reset Input & Reply Banner
            txtComment.Text = "";
            hfReplyToId.Value = "";
            pnlReplyPreview.Visible = false;
            txtComment.Attributes["placeholder"] = "Type comment here...";
            BindPosts();
        }

        protected void rptComments_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int threadId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "Reply")
            {
                // Store the ThreadId of the comment we are replying to
                hfReplyToId.Value = threadId.ToString();

                // Find the author name of the comment being replied to for the banner
                string authorName = "User";
                using (SqlConnection con = new SqlConnection(connString))
                {
                    string q = "SELECT COALESCE(l.Name, t.Name, ta.Name, 'System') FROM Post_Reply pr LEFT JOIN Learner l ON pr.LearnerId = l.LearnerId LEFT JOIN Teacher t ON pr.TeacherId = t.TeacherId LEFT JOIN Teaching_Assistant ta ON pr.TA_Id = ta.TA_Id WHERE pr.ThreadId = @ThreadId";
                    using (SqlCommand cmd = new SqlCommand(q, con))
                    {
                        cmd.Parameters.AddWithValue("@ThreadId", threadId);
                        con.Open();
                        object result = cmd.ExecuteScalar();
                        con.Close();
                        if (result != null) authorName = result.ToString();
                    }
                }

                // Show the sleek preview banner
                litReplyingToUser.Text = authorName;
                pnlReplyPreview.Visible = true;
                txtComment.Attributes["placeholder"] = $"Write a reply to {authorName}...";
                txtComment.Focus();
            }
        }

        // Event handler to cancel/close the active reply state
        protected void btnCancelReply_Click(object sender, EventArgs e)
        {
            hfReplyToId.Value = "";
            pnlReplyPreview.Visible = false;
            txtComment.Attributes["placeholder"] = "Type comment here...";
            txtComment.Text = "";
        }

        // Hide moderation controls (Pin/Flag) because the current user is a Learner
        protected void rptComments_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                PlaceHolder phModControls = (PlaceHolder)e.Item.FindControl("phModControls");
                if (phModControls != null)
                {
                    phModControls.Visible = false;
                }
            }
        }

        protected void btnAddPost_Click(object sender, EventArgs e)
        {
            Response.Redirect("LearnerAddPost.aspx");
        }

        // --- Frontend UI Helpers ---

        protected string GetFormattedTags(object tagsObj)
        {
            if (tagsObj == DBNull.Value || tagsObj == null) return "";
            string[] tags = tagsObj.ToString().Split(',');
            return string.Join(" ", tags.Select(t => $"#{t.Trim()}"));
        }

        protected string GetInitials(string name)
        {
            if (string.IsNullOrEmpty(name)) return "U";
            var parts = name.Split(' ');
            if (parts.Length == 1) return parts[0].Substring(0, 1).ToUpper();
            return (parts[0].Substring(0, 1) + parts[1].Substring(0, 1)).ToUpper();
        }

        protected string GetReplyToName(object parentThreadId)
        {
            if (parentThreadId == DBNull.Value || parentThreadId == null || string.IsNullOrEmpty(parentThreadId.ToString())) return "";

            // Since we need to get the author of the parent thread, we do a quick lookup
            using (SqlConnection con = new SqlConnection(connString))
            {
                string q = "SELECT COALESCE(l.Name, t.Name, ta.Name, 'System') FROM Post_Reply pr LEFT JOIN Learner l ON pr.LearnerId = l.LearnerId LEFT JOIN Teacher t ON pr.TeacherId = t.TeacherId LEFT JOIN Teaching_Assistant ta ON pr.TA_Id = ta.TA_Id WHERE pr.ThreadId = @ThreadId";
                using (SqlCommand cmd = new SqlCommand(q, con))
                {
                    cmd.Parameters.AddWithValue("@ThreadId", parentThreadId);
                    con.Open();
                    object result = cmd.ExecuteScalar();
                    con.Close();
                    return result != null ? result.ToString() : "Unknown User";
                }
            }
        }
    }
}