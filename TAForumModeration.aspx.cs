using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class TAForumModeration : System.Web.UI.Page
    {
        protected List<TeacherForumPost> Posts;
        protected TeacherForumPost SelectedPost;
        protected bool MobileDiscussion;

        protected string CurrentFilter { get; private set; } = "all";
        private int TaId { get { return Convert.ToInt32(Session["UserId"]); } }

        protected void Page_Load(object sender, EventArgs e)
        {
            string f = (Request.QueryString["filter"] ?? "").ToLower();
            CurrentFilter = (f == "flagged" || f == "hidden") ? f : "all";

            Posts = GetForumPosts();

            int id;
            if (!int.TryParse(Request.QueryString["postId"], out id))
            {
                int.TryParse(hfTeacherForumPost.Value, out id);
            }
            SelectedPost = Posts.FirstOrDefault(p => p.Id == id) ?? Posts.FirstOrDefault();

            if (IsPostBack)
            {
                HandleAction(Request.Form["tpForumAction"]);
            }

            hfTeacherForumPost.Value = SelectedPost == null ? "" : SelectedPost.Id.ToString();
            MobileDiscussion = hfTeacherForumMobile.Value == "1";
        }

        private void ReloadPosts()
        {
            int id = SelectedPost == null ? 0 : SelectedPost.Id;
            Posts = GetForumPosts();
            SelectedPost = Posts.FirstOrDefault(p => p.Id == id) ?? Posts.FirstOrDefault();
            hfTeacherForumPost.Value = SelectedPost == null ? "" : SelectedPost.Id.ToString();
        }

        private void HandleAction(string action)
        {
            if (string.IsNullOrEmpty(action) || SelectedPost == null) return;
            string[] parts = action.Split(':');

            if (parts[0] == "reply")
            {
                string body = txtTAReply.Text.Trim();
                if (body.Length == 0) return;

                int postId;
                if (!int.TryParse(hfTeacherForumPost.Value, out postId) || !Posts.Any(p => p.Id == postId))
                {
                    Master.ShowToast("Choose a post first, so nothing was saved.");
                    return;
                }
                int parent;
                int? parentId = int.TryParse(hfTeacherReplyingTo.Value, out parent) && parent > 0 ? parent : (int?)null;

                AddReply(postId, body, parentId);
                txtTAReply.Text = "";
                hfTeacherReplyingTo.Value = "";
                ReloadPosts();
                Master.ShowToast("Your reply was posted.");
            }
            else if (parts[0] == "pin" && parts.Length == 3)
            {
                int postId, threadId;
                if (int.TryParse(parts[1], out postId) && int.TryParse(parts[2], out threadId))
                {
                    bool? pinned = TogglePin(postId, threadId);
                    ReloadPosts();
                    if (pinned.HasValue)
                    {
                        Master.ShowToast(pinned.Value ? "Comment pinned to the top." : "Comment unpinned.");
                    }
                }
            }
            else if (parts[0] == "unflag" && parts.Length >= 2)
            {
                int postId;
                if (int.TryParse(parts[1], out postId))
                {
                    using (SqlConnection con = new SqlConnection(TAHelpers.ConnectionString))
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Moderate_Forum] WHERE PostId = @PostId AND ModerateAction = 'Flag'", con))
                    {
                        cmd.Parameters.AddWithValue("@PostId", postId);
                        con.Open();
                        cmd.ExecuteNonQuery();
                    }
                    ReloadPosts();
                    Master.ShowToast("Post flag has been dismissed.");
                }
            }
            else if (parts[0] == "unhide" && parts.Length >= 2)
            {
                int postId;
                if (int.TryParse(parts[1], out postId))
                {
                    using (SqlConnection con = new SqlConnection(TAHelpers.ConnectionString))
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Moderate_Forum] WHERE PostId = @PostId AND ModerateAction = 'Hide'", con))
                    {
                        cmd.Parameters.AddWithValue("@PostId", postId);
                        con.Open();
                        cmd.ExecuteNonQuery();
                    }
                    ReloadPosts();
                    Master.ShowToast("Post has been unhidden and restored to the public forum.");
                }
            }
        }

        protected void btnModerate_Click(object sender, EventArgs e)
        {
            var btn = sender as Button;
            string action = btn != null ? btn.CommandArgument : "Flag";
            int postId;
            if (!int.TryParse(hfModeratePostId.Value, out postId))
            {
                Master.ShowToast("No post was selected for moderation.");
                return;
            }

            string reason = txtModerateReason.Text.Trim();
            if (string.IsNullOrEmpty(reason))
            {
                reason = "Moderated by TA";
            }

            using (SqlConnection con = new SqlConnection(TAHelpers.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                INSERT INTO [dbo].[Moderate_Forum] (PostId, TA_Id, ModerateAction, ModerateReason, DateModerate)
                VALUES (@PostId, @TA_Id, @Action, @Reason, GETDATE())", con))
            {
                cmd.Parameters.AddWithValue("@PostId", postId);
                cmd.Parameters.AddWithValue("@TA_Id", TaId);
                cmd.Parameters.AddWithValue("@Action", action);
                cmd.Parameters.AddWithValue("@Reason", reason);
                con.Open();
                cmd.ExecuteNonQuery();
            }

            txtModerateReason.Text = "";
            ReloadPosts();
            Master.ShowToast(action == "Hide" ? "Post has been hidden from the forum." : "Post has been flagged for moderation.");
        }

        protected void btnUnflag_Click(object sender, EventArgs e)
        {
            int postId;
            if (!int.TryParse(hfModeratePostId.Value, out postId))
            {
                if (SelectedPost != null) postId = SelectedPost.Id;
                else return;
            }

            using (SqlConnection con = new SqlConnection(TAHelpers.ConnectionString))
            using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Moderate_Forum] WHERE PostId = @PostId AND ModerateAction = 'Flag'", con))
            {
                cmd.Parameters.AddWithValue("@PostId", postId);
                con.Open();
                cmd.ExecuteNonQuery();
            }

            ReloadPosts();
            Master.ShowToast("Post flag has been dismissed.");
        }

        protected void btnUnhide_Click(object sender, EventArgs e)
        {
            int postId;
            if (!int.TryParse(hfModeratePostId.Value, out postId))
            {
                if (SelectedPost != null) postId = SelectedPost.Id;
                else return;
            }

            using (SqlConnection con = new SqlConnection(TAHelpers.ConnectionString))
            using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Moderate_Forum] WHERE PostId = @PostId AND ModerateAction = 'Hide'", con))
            {
                cmd.Parameters.AddWithValue("@PostId", postId);
                con.Open();
                cmd.ExecuteNonQuery();
            }

            ReloadPosts();
            Master.ShowToast("Post has been unhidden and restored to the public forum.");
        }

        private List<TeacherForumPost> GetForumPosts()
        {
            var list = new List<TeacherForumPost>();
            string filterSql = "";

            if (CurrentFilter == "flagged")
            {
                filterSql = @"WHERE EXISTS (
                    SELECT 1 FROM [dbo].[Moderate_Forum] m
                    WHERE m.PostId = f.PostId AND m.ModerateAction = 'Flag'
                ) AND NOT EXISTS (
                    SELECT 1 FROM [dbo].[Moderate_Forum] m
                    WHERE m.PostId = f.PostId AND m.ModerateAction = 'Hide'
                )";
            }
            else if (CurrentFilter == "hidden")
            {
                filterSql = @"WHERE EXISTS (
                    SELECT 1 FROM [dbo].[Moderate_Forum] m
                    WHERE m.PostId = f.PostId AND m.ModerateAction = 'Hide'
                )";
            }
            else
            {
                filterSql = @"WHERE NOT EXISTS (
                    SELECT 1 FROM [dbo].[Moderate_Forum] m
                    WHERE m.PostId = f.PostId AND m.ModerateAction = 'Hide'
                )";
            }

            using (SqlConnection con = new SqlConnection(TAHelpers.ConnectionString))
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT f.PostId, f.Title, f.Content, f.Tags,
                           (SELECT TOP 1 m.ModerateReason FROM [dbo].[Moderate_Forum] m WHERE m.PostId = f.PostId AND m.ModerateAction = 'Flag' ORDER BY m.DateModerate DESC) AS FlagReason,
                           (SELECT TOP 1 m.ModerateReason FROM [dbo].[Moderate_Forum] m WHERE m.PostId = f.PostId AND m.ModerateAction = 'Hide' ORDER BY m.DateModerate DESC) AS HideReason
                    FROM [dbo].[Forum] f
                    " + filterSql + @"
                    ORDER BY f.DatePosted DESC, f.PostId DESC", con))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string flagReason = reader.IsDBNull(4) ? null : reader.GetString(4);
                            string hideReason = reader.IsDBNull(5) ? null : reader.GetString(5);
                            list.Add(new TeacherForumPost
                            {
                                Id = reader.GetInt32(0),
                                Title = reader.GetString(1),
                                Excerpt = ExcerptOf(reader.GetString(2)),
                                Tags = TagsOf(reader.IsDBNull(3) ? "" : reader.GetString(3)),
                                Comments = new List<TeacherForumComment>(),
                                IsFlagged = !string.IsNullOrEmpty(flagReason),
                                FlagReason = flagReason,
                                IsHidden = !string.IsNullOrEmpty(hideReason),
                                HideReason = hideReason
                            });
                        }
                    }
                }

                // Fetch replies
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT r.ThreadId, r.PostId, r.ReplyComment, r.IsPinned,
                           COALESCE(l.Name, t.Name, ta.Name, 'Unknown') AS AuthorName,
                           CASE WHEN r.TeacherId IS NOT NULL THEN 'TEACHER'
                                WHEN r.TA_Id IS NOT NULL THEN 'TA'
                                ELSE 'LEARNER' END AS Role,
                           r.ParentThreadId
                    FROM [dbo].[Post_Reply] r
                    LEFT JOIN [dbo].[Learner] l ON l.LearnerId = r.LearnerId
                    LEFT JOIN [dbo].[Teacher] t ON t.TeacherId = r.TeacherId
                    LEFT JOIN [dbo].[Teaching_Assistant] ta ON ta.TA_Id = r.TA_Id
                    ORDER BY r.ThreadId", con))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int postId = reader.GetInt32(1);
                            TeacherForumPost post = list.FirstOrDefault(p => p.Id == postId);
                            if (post == null) continue;

                            string name = reader.GetString(4);
                            post.Comments.Add(new TeacherForumComment
                            {
                                Id = reader.GetInt32(0),
                                Name = name,
                                Initials = name.Length > 0 ? name.Substring(0, 1).ToUpperInvariant() : "U",
                                Role = reader.GetString(5),
                                Body = reader.GetString(2),
                                Pinned = reader.GetString(3) == "Yes",
                                ParentId = reader.IsDBNull(6) ? (int?)null : reader.GetInt32(6)
                            });
                        }
                    }
                }
            }
            return list;
        }

        private void AddReply(int postId, string body, int? parentId)
        {
            using (SqlConnection con = new SqlConnection(TAHelpers.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                INSERT INTO [dbo].[Post_Reply] (ReplyComment, IsPinned, PostId, TA_Id, ParentThreadId, DateReplied)
                VALUES (@Body, 'No', @PostId, @TA_Id, @ParentId, GETDATE())", con))
            {
                cmd.Parameters.AddWithValue("@Body", body);
                cmd.Parameters.AddWithValue("@PostId", postId);
                cmd.Parameters.AddWithValue("@TA_Id", TaId);
                cmd.Parameters.AddWithValue("@ParentId", (object)parentId ?? DBNull.Value);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        private bool? TogglePin(int postId, int threadId)
        {
            using (SqlConnection con = new SqlConnection(TAHelpers.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(@"
                UPDATE [dbo].[Post_Reply]
                SET IsPinned = CASE WHEN IsPinned = 'Yes' THEN 'No' ELSE 'Yes' END,
                    DatePinned = CASE WHEN IsPinned = 'Yes' THEN NULL ELSE GETDATE() END
                OUTPUT inserted.IsPinned
                WHERE ThreadId = @ThreadId AND PostId = @PostId", con))
            {
                cmd.Parameters.AddWithValue("@ThreadId", threadId);
                cmd.Parameters.AddWithValue("@PostId", postId);
                con.Open();
                object now = cmd.ExecuteScalar();
                return now == null ? (bool?)null : (string)now == "Yes";
            }
        }

        private static string ExcerptOf(string content)
        {
            string text = Regex.Replace(content ?? "", @"\s+", " ").Trim();
            return text.Length > 110 ? text.Substring(0, 110).TrimEnd() + "..." : text;
        }

        private static List<string> TagsOf(string tags)
        {
            return (tags ?? "").Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(t => t.Trim())
                .Where(t => t.Length > 0)
                .ToList();
        }
    }
}
