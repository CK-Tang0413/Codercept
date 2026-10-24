using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class TAForumModeration : System.Web.UI.Page
    {
        // 1. Define Data Structures
        public class Post
        {
            public int PostId { get; set; }
            public string Title { get; set; }
            public string Content { get; set; }
            public string Author { get; set; }
            public string Posted { get; set; }
            public int ReplyCount { get; set; }
            public bool IsVerified { get; set; }
            public bool IsReported { get; set; }
            public bool IsHidden { get; set; }
            public bool IsUnsolved { get { return !IsVerified && !IsHidden; } }
            public string Flag { get { return IsHidden ? "Hidden" : (IsVerified ? "Verified" : "Unsolved"); } }
            public string FlagCss { get { return IsHidden ? "flag-hidden" : (IsVerified ? "flag-verified" : "flag-unsolved"); } }
            // Reported is a moderation state, shown beside the answer status instead of replacing it
            public bool ShowReported { get { return IsReported && !IsHidden; } }
            public string CssClass { get; set; }
        }

        public class Reply
        {
            public int ThreadId { get; set; }
            public string Author { get; set; }
            public string Role { get; set; }
            public string RoleCss { get; set; }
            public string Content { get; set; }
            public string ContentHtml { get { return TAHelpers.FormatRichText(Content); } }
            public string Posted { get; set; }
            public bool IsPinned { get; set; }
            public string CssClass { get { return IsPinned ? "pinned" : ""; } }
        }

        public class ModerationEntry
        {
            public string Action { get; set; }
            public string Moderator { get; set; }
            public string Reason { get; set; }
            public string When { get; set; }
        }

        // A post stays in the staff list until it is deleted; hidden posts remain visible to staff only
        private const string OpenPostFilter = TAHelpers.ForumNotDeleted;

        private readonly string connString = TAHelpers.ConnectionString;

        protected string CurrentFilter { get; private set; } = "all";

        private int TaId { get { return Convert.ToInt32(Session["UserId"]); } }

        protected void Page_Load(object sender, EventArgs e)
        {
            string filter = (Request.QueryString["filter"] ?? "all").ToLower();
            CurrentFilter = (filter == "unsolved" || filter == "verified" || filter == "reported") ? filter : "all";

            if (!IsPostBack)
            {
                LoadForumData();
            }
        }

        protected string GetTabClass(string tab)
        {
            return tab == CurrentFilter ? "active" : "";
        }

        // ---------- Data access ----------

        private List<Post> GetPosts()
        {
            string query = @"
                SELECT f.PostId, f.Title, f.Content, l.Name AS Author, f.DatePosted,
                       (SELECT COUNT(*) FROM [dbo].[Post_Reply] r WHERE r.PostId = f.PostId) AS ReplyCount,
                       CASE WHEN " + TAHelpers.ForumHasVerifiedAnswer + @" THEN 1 ELSE 0 END AS IsVerified,
                       CASE WHEN EXISTS (SELECT 1 FROM [dbo].[Moderate_Forum] m WHERE m.PostId = f.PostId AND m.ModerationAction = 'Flag') THEN 1 ELSE 0 END AS IsReported,
                       CASE WHEN NOT " + TAHelpers.ForumVisibleToLearners + @" THEN 1 ELSE 0 END AS IsHidden
                FROM [dbo].[Forum] f
                INNER JOIN [dbo].[Learner] l ON l.LearnerId = f.LearnerId
                WHERE " + OpenPostFilter + @"
                ORDER BY f.DatePosted DESC";

            var list = new List<Post>();

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(new Post
                        {
                            PostId = Convert.ToInt32(reader["PostId"]),
                            Title = reader["Title"].ToString(),
                            Content = reader["Content"].ToString(),
                            Author = reader["Author"].ToString(),
                            Posted = TAHelpers.TimeAgo(Convert.ToDateTime(reader["DatePosted"])),
                            ReplyCount = Convert.ToInt32(reader["ReplyCount"]),
                            IsVerified = Convert.ToInt32(reader["IsVerified"]) == 1,
                            IsReported = Convert.ToInt32(reader["IsReported"]) == 1,
                            IsHidden = Convert.ToInt32(reader["IsHidden"]) == 1
                        });
                    }
                }
            }

            return list;
        }

        private List<Reply> GetReplies(int postId)
        {
            const string query = @"
                SELECT r.ThreadId, r.ReplyComment, r.IsPinned, r.DateReplied,
                       COALESCE(l.Name, t.Name, ta.Name) AS Author,
                       CASE WHEN r.TeacherId IS NOT NULL THEN 'Teacher' WHEN r.TA_Id IS NOT NULL THEN 'TA' ELSE 'Learner' END AS Role
                FROM [dbo].[Post_Reply] r
                LEFT JOIN [dbo].[Learner] l ON l.LearnerId = r.LearnerId
                LEFT JOIN [dbo].[Teacher] t ON t.TeacherId = r.TeacherId
                LEFT JOIN [dbo].[Teaching_Assistant] ta ON ta.TA_Id = r.TA_Id
                WHERE r.PostId = @PostId
                ORDER BY CASE r.IsPinned WHEN 'Yes' THEN 0 ELSE 1 END, r.DateReplied ASC";

            var list = new List<Reply>();

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@PostId", postId);
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string role = reader["Role"].ToString();

                        list.Add(new Reply
                        {
                            ThreadId = Convert.ToInt32(reader["ThreadId"]),
                            Author = reader["Author"].ToString(),
                            Role = role,
                            RoleCss = role == "Teacher" ? "role-teacher" : (role == "TA" ? "role-ta" : "role-learner"),
                            Content = reader["ReplyComment"].ToString(),
                            Posted = TAHelpers.TimeAgo(Convert.ToDateTime(reader["DateReplied"])),
                            IsPinned = reader["IsPinned"].ToString() == "Yes"
                        });
                    }
                }
            }

            return list;
        }

        private List<ModerationEntry> GetModerationLog(int postId)
        {
            const string query = @"
                SELECT m.ModerationAction, m.ModerateReason, m.DateModerate, ta.Name AS Moderator
                FROM [dbo].[Moderate_Forum] m
                INNER JOIN [dbo].[Teaching_Assistant] ta ON ta.TA_Id = m.TA_Id
                WHERE m.PostId = @PostId
                ORDER BY m.DateModerate DESC, m.ModerationId DESC";

            var list = new List<ModerationEntry>();

            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(query, con))
            {
                cmd.Parameters.AddWithValue("@PostId", postId);
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(new ModerationEntry
                        {
                            Action = reader["ModerationAction"].ToString(),
                            Moderator = reader["Moderator"].ToString(),
                            Reason = reader["ModerateReason"].ToString(),
                            When = TAHelpers.TimeAgo(Convert.ToDateTime(reader["DateModerate"]))
                        });
                    }
                }
            }

            return list;
        }

        // ---------- Page binding ----------

        private void LoadForumData()
        {
            var all = GetPosts();

            // Tab counts (always computed over the full list)
            litCountAll.Text = all.Count.ToString();
            litCountUnsolved.Text = all.Count(p => p.IsUnsolved).ToString();
            litCountVerified.Text = all.Count(p => p.IsVerified).ToString();
            litCountReported.Text = all.Count(p => p.IsReported && !p.IsHidden).ToString();
            litFilterLabel.Text = CurrentFilter == "unsolved" ? "Unsolved" : CurrentFilter == "verified" ? "Verified" : CurrentFilter == "reported" ? "Reported" : "All posts";

            // Apply the active filter
            List<Post> filtered;
            if (CurrentFilter == "unsolved") filtered = all.Where(p => p.IsUnsolved).ToList();
            else if (CurrentFilter == "verified") filtered = all.Where(p => p.IsVerified).ToList();
            else if (CurrentFilter == "reported") filtered = all.Where(p => p.IsReported && !p.IsHidden).ToList();
            else filtered = all;

            int.TryParse(Request.QueryString["post"], out int postId);
            var selected = filtered.FirstOrDefault(p => p.PostId == postId) ?? filtered.FirstOrDefault();
            if (selected != null) selected.CssClass = "selected";

            phListEmpty.Visible = filtered.Count == 0;
            rptPosts.DataSource = filtered;
            rptPosts.DataBind();

            // Bind the thread panel for the selected post
            if (selected == null)
            {
                phThread.Visible = false;
                phNoSelection.Visible = true;
                return;
            }

            phThread.Visible = true;
            phNoSelection.Visible = false;
            hfPostId.Value = selected.PostId.ToString();

            litPostTitle.Text = Server.HtmlEncode(selected.Title);
            litPostAuthor.Text = Server.HtmlEncode(selected.Author);
            litPostTime.Text = selected.Posted;
            litPostBadges.Text = $"<span class='flag-badge {selected.FlagCss}'>{selected.Flag}</span>" + (selected.ShowReported ? "<span class='flag-badge flag-reported'>Reported</span>" : "");
            litPostContent.Text = TAHelpers.FormatRichText(selected.Content);

            txtModReason.Text = "";
            pnlHiddenNotice.Visible = selected.IsHidden;
            btnFlagPost.Enabled = !selected.IsReported && !selected.IsHidden;
            btnHidePost.Enabled = !selected.IsHidden;

            var log = GetModerationLog(selected.PostId);
            phModLog.Visible = log.Count > 0;
            rptModLog.DataSource = log;
            rptModLog.DataBind();

            var replies = GetReplies(selected.PostId);
            litReplyCount.Text = $"{replies.Count} repl{(replies.Count == 1 ? "y" : "ies")}";
            rptReplies.DataSource = replies;
            rptReplies.DataBind();
        }

        // ---------- Actions ----------

        private bool TryGetPostId(out int postId)
        {
            if (int.TryParse(hfPostId.Value, out postId)) return true;
            ShowMessage("No post selected.", false);
            return false;
        }

        // True when the post still exists and has not been removed
        private static bool IsPostOpen(SqlConnection con, int postId)
        {
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(1) FROM [dbo].[Forum] f WHERE f.PostId = @PostId AND " + OpenPostFilter, con))
            {
                cmd.Parameters.AddWithValue("@PostId", postId);
                return (int)cmd.ExecuteScalar() > 0;
            }
        }

        private const string PostGoneMessage = "This post is no longer available.";

        protected void btnReply_Click(object sender, EventArgs e)
        {
            int postId;
            if (!TryGetPostId(out postId)) return;

            string text = txtReply.Text.Trim();
            if (text.Length == 0) { ShowMessage("Reply cannot be empty.", false); return; }
            if (text.Length > 4000) { ShowMessage("Reply is too long (4000 characters maximum).", false); return; }

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                if (!IsPostOpen(con, postId)) { ShowMessage(PostGoneMessage, false); return; }

                using (SqlCommand cmd = new SqlCommand(
                    "INSERT INTO [dbo].[Post_Reply] (ReplyComment, IsPinned, PostId, TA_Id) VALUES (@Text, 'No', @PostId, @TA_Id)", con))
                {
                    cmd.Parameters.AddWithValue("@Text", text);
                    cmd.Parameters.AddWithValue("@PostId", postId);
                    cmd.Parameters.AddWithValue("@TA_Id", TaId);
                    cmd.ExecuteNonQuery();
                }
            }

            txtReply.Text = "";
            LoadForumData();
            ShowMessage("Reply posted.", true);
        }

        protected void rptReplies_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int postId;
            if (!TryGetPostId(out postId)) return;

            int threadId = int.Parse((string)e.CommandArgument);
            string message;

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                if (!IsPostOpen(con, postId)) { ShowMessage(PostGoneMessage, false); return; }

                if (e.CommandName == "Pin")
                {
                    // Only one pinned answer per post: pinning one unpins the others, pinning it again unpins it
                    const string pin = @"
                        DECLARE @WasPinned NVARCHAR(50) = (SELECT IsPinned FROM [dbo].[Post_Reply] WHERE ThreadId = @ThreadId AND PostId = @PostId);
                        UPDATE [dbo].[Post_Reply] SET IsPinned = 'No', DatePinned = NULL WHERE PostId = @PostId;
                        IF @WasPinned = 'No'
                            UPDATE [dbo].[Post_Reply] SET IsPinned = 'Yes', DatePinned = GETDATE() WHERE ThreadId = @ThreadId AND PostId = @PostId;
                        SELECT @WasPinned;";

                    using (SqlCommand cmd = new SqlCommand(pin, con))
                    {
                        cmd.Parameters.AddWithValue("@ThreadId", threadId);
                        cmd.Parameters.AddWithValue("@PostId", postId);
                        object wasPinned = cmd.ExecuteScalar();
                        message = wasPinned == null || wasPinned == DBNull.Value ? "Reply not found."
                                : (wasPinned.ToString() == "Yes" ? "Verified Answer removed." : "Reply marked as the Verified Answer.");
                    }
                }
                else if (e.CommandName == "Delete")
                {
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Post_Reply] WHERE ThreadId = @ThreadId AND PostId = @PostId", con))
                    {
                        cmd.Parameters.AddWithValue("@ThreadId", threadId);
                        cmd.Parameters.AddWithValue("@PostId", postId);
                        message = cmd.ExecuteNonQuery() > 0 ? "Reply deleted." : "Reply not found.";
                    }
                }
                else
                {
                    return;
                }
            }

            LoadForumData();
            ShowMessage(message, true);
        }

        protected void btnFlagPost_Click(object sender, EventArgs e)
        {
            ModeratePost(ModerationAction.Flag, "Post reported. It stays visible and is listed under Reported.");
        }

        protected void btnHidePost_Click(object sender, EventArgs e)
        {
            ModeratePost(ModerationAction.Hide, "Post hidden. Learners can no longer see it.");
        }

        protected void btnDeletePost_Click(object sender, EventArgs e)
        {
            ModeratePost(ModerationAction.Delete, "Post deleted.");
        }

        // Records the action in Moderate_Forum (the moderation log); the post's state is derived from those rows
        private void ModeratePost(string action, string successMessage)
        {
            int postId;
            if (!TryGetPostId(out postId)) return;

            string reason = txtModReason.Text.Trim();
            if (reason.Length == 0) { ShowMessage("Please enter a reason for this action.", false); return; }

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                if (!IsPostOpen(con, postId)) { ShowMessage(PostGoneMessage, false); return; }

                // Hiding or reporting twice would only add noise to the log
                if (action != ModerationAction.Delete)
                {
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(1) FROM [dbo].[Moderate_Forum] WHERE PostId = @PostId AND ModerationAction = @Action", con))
                    {
                        cmd.Parameters.AddWithValue("@PostId", postId);
                        cmd.Parameters.AddWithValue("@Action", action);
                        if ((int)cmd.ExecuteScalar() > 0)
                        {
                            ShowMessage(action == ModerationAction.Flag ? "This post is already reported." : "This post is already hidden.", false);
                            return;
                        }
                    }
                }

                using (SqlCommand cmd = new SqlCommand(
                    "INSERT INTO [dbo].[Moderate_Forum] (PostId, TA_Id, ModerationAction, ModerateReason, DateModerate) VALUES (@PostId, @TA_Id, @Action, @Reason, GETDATE())", con))
                {
                    cmd.Parameters.AddWithValue("@PostId", postId);
                    cmd.Parameters.AddWithValue("@TA_Id", TaId);
                    cmd.Parameters.AddWithValue("@Action", action);
                    cmd.Parameters.AddWithValue("@Reason", reason);
                    cmd.ExecuteNonQuery();
                }
            }

            // A deleted post drops out of the list, so the next post is selected
            LoadForumData();
            ShowMessage(successMessage, true);
        }

        private void ShowMessage(string message, bool success)
        {
            litMessage.Text = Server.HtmlEncode(message);
            pnlMessage.CssClass = success ? "toast" : "toast toast-error";
            pnlMessage.Visible = true;
        }
    }
}
