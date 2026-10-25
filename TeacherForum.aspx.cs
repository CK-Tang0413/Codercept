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
            // only the posts this teacher may see (their own, and those of learners enrolled in their courses)
            Posts = TeacherForumData.GetPosts();

            int id;
            int.TryParse(hfTeacherForumPost.Value, out id);
            SelectedPost = Posts.FirstOrDefault(p => p.Id == id) ?? Posts.FirstOrDefault();

            if (IsPostBack) HandleAction(Request.Form["tpForumAction"]);
            else ShowPublishedToast();

            hfTeacherForumPost.Value = SelectedPost == null ? "" : SelectedPost.Id.ToString();
            MobileDiscussion = hfTeacherForumMobile.Value == "1";
        }

        private void HandleAction(string action)
        {
            if (string.IsNullOrEmpty(action) || SelectedPost == null) return;
            string[] parts = action.Split(':');

            if (parts[0] == "reply")
            {
                if (txtTeacherReply.Text.Trim().Length == 0) return;
                // TODO (Phase 5, step 5.3): INSERT INTO Post_Reply for SelectedPost.Id (ParentThreadId = hfTeacherReplyingTo)
                Master.ShowToast("Replying is added in a later step, so nothing was saved.");
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
                // TODO (Phase 5, step 5.3): UPDATE Post_Reply SET IsPinned / DatePinned for this reply of a post the teacher can see
                Master.ShowToast("Pinning is added in a later step, so nothing was saved.");
            }
            else if (parts[0] == "flag")
            {
                // flagging needs the moderation feature (teaching assistants), which is not built yet
                Master.ShowToast("Flagging comes with moderation, so nothing was saved.");
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
