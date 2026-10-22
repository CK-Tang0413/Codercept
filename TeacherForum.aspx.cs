using System;
using System.Collections.Generic;
using System.Linq;

namespace Codercept
{
    public partial class TeacherForum : System.Web.UI.Page
    {
        protected List<TeacherForumPost> Posts;
        protected TeacherForumPost SelectedPost;
        protected bool MobileDiscussion;

        protected void Page_Load(object sender, EventArgs e)
        {
            // TODO (backend): load the forum posts and their Post_Reply rows
            Posts = TeacherSampleData.GetForumPosts();

            int id;
            int.TryParse(hfTeacherForumPost.Value, out id);
            SelectedPost = Posts.FirstOrDefault(p => p.Id == id) ?? Posts[0];

            if (IsPostBack) HandleAction(Request.Form["tpForumAction"]);
            else ShowPublishedToast();

            hfTeacherForumPost.Value = SelectedPost.Id.ToString();
            MobileDiscussion = hfTeacherForumMobile.Value == "1";
        }

        private void HandleAction(string action)
        {
            if (string.IsNullOrEmpty(action)) return;
            string[] parts = action.Split(':');

            if (parts[0] == "reply")
            {
                string body = txtTeacherReply.Text.Trim();
                if (body.Length == 0) return;

                // TODO (backend): INSERT INTO Post_Reply (PostId = SelectedPost.Id, UserId = Session["UserId"], Body = body,
                //   ParentReplyId from hfTeacherReplyingTo)
                SelectedPost.Comments.Add(new TeacherForumComment
                {
                    Id = Posts.SelectMany(p => p.Comments).Max(c => c.Id) + 1,
                    Name = Master.UserName,
                    Initials = Master.UserInitial,
                    Role = "TEACHER",
                    Body = body
                });
                txtTeacherReply.Text = "";
                hfTeacherReplyingTo.Value = "";
                return;
            }

            int postId, commentId;
            if (parts.Length != 3 || !int.TryParse(parts[1], out postId) || !int.TryParse(parts[2], out commentId)) return;
            TeacherForumPost post = Posts.FirstOrDefault(p => p.Id == postId);
            TeacherForumComment comment = post == null ? null : post.Comments.FirstOrDefault(c => c.Id == commentId);
            if (comment == null) return;
            SelectedPost = post;

            if (parts[0] == "pin")
            {
                // TODO (backend): UPDATE Post_Reply SET IsPinned = ~IsPinned WHERE ReplyId = commentId
                comment.Pinned = !comment.Pinned;
            }
            else if (parts[0] == "flag")
            {
                // TODO (backend): record the flag for moderators (Post_Reply.IsFlagged / a flag table)
                Master.ShowToast("Comment flagged for review");
            }
        }

        private void ShowPublishedToast()
        {
            string message = Session["TeacherFlashToast"] as string;
            if (message == null) return;
            Session.Remove("TeacherFlashToast");
            Master.ShowToast(message);
        }
    }
}
