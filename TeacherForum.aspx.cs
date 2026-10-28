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
            // the teacher is looking at these posts now, so they stop counting as unread on the dashboard
            TeacherForumData.MarkRead(Posts.Select(p => p.Id));

            int id;
            int.TryParse(hfTeacherForumPost.Value, out id);
            SelectedPost = Posts.FirstOrDefault(p => p.Id == id) ?? Posts.FirstOrDefault();

            if (IsPostBack) HandleAction(Request.Form["tpForumAction"]);
            else ShowPublishedToast();

            hfTeacherForumPost.Value = SelectedPost == null ? "" : SelectedPost.Id.ToString();
            MobileDiscussion = hfTeacherForumMobile.Value == "1";
        }

        /// <summary>Reads the posts again after a change, keeping the same post selected.</summary>
        private void ReloadPosts()
        {
            int id = SelectedPost == null ? 0 : SelectedPost.Id;
            Posts = TeacherForumData.GetPosts();
            SelectedPost = Posts.FirstOrDefault(p => p.Id == id) ?? Posts.FirstOrDefault();
        }

        private void HandleAction(string action)
        {
            if (string.IsNullOrEmpty(action) || SelectedPost == null) return;
            string[] parts = action.Split(':');

            if (parts[0] == "reply")
            {
                string body = txtTeacherReply.Text.Trim();
                if (body.Length == 0) return;

                // the post is the one named by the page, and only when it is one of this teacher's own: never "the first post" as a fallback
                int postId;
                if (!int.TryParse(hfTeacherForumPost.Value, out postId) || !Posts.Any(p => p.Id == postId))
                {
                    Master.ShowToast("Choose a post first, so nothing was saved.");
                    return;
                }
                int parent;
                int? parentId = int.TryParse(hfTeacherReplyingTo.Value, out parent) && parent > 0 ? parent : (int?)null;

                ForumReplyResult result = TeacherForumData.AddReply(postId, body, parentId);
                if (result == ForumReplyResult.Saved)
                {
                    txtTeacherReply.Text = "";
                    hfTeacherReplyingTo.Value = "";
                    SelectedPost = Posts.First(p => p.Id == postId);
                    ReloadPosts();
                }
                else if (result == ForumReplyResult.TooLong)
                {
                    Master.ShowToast("A reply can be at most " + TeacherForumData.MaxReplyLength + " characters, so nothing was saved.");
                }
                else
                {
                    Master.ShowToast("That post or comment could not be found, so nothing was saved.");
                }
                return;
            }

            if (parts[0] == "moderate" && parts.Length == 2)
            {
                // Flag or Hide: the post is the one named by the dialog, and only when it is one of the posts shown here (never "the first post")
                int modPostId;
                if (!int.TryParse(Request.Unvalidated.Form["tpModeratePost"], out modPostId) || !Posts.Any(p => p.Id == modPostId))
                {
                    Master.ShowToast("That post could not be found, so nothing was changed.");
                    return;
                }
                string verb = parts[1] == "hide" ? "Hide" : "Flag";
                ForumModerateResult done = TeacherForumData.Moderate(modPostId, verb, Request.Unvalidated.Form["tpModerateReason"]);
                switch (done)
                {
                    case ForumModerateResult.Done:
                        ReloadPosts();
                        Master.ShowToast(verb == "Hide" ? "Post hidden" : "Post flagged");
                        break;
                    case ForumModerateResult.AlreadyFlagged:
                        Master.ShowToast("This post is already flagged.");
                        break;
                    case ForumModerateResult.ReasonMissing:
                        Master.ShowToast("Enter the reason for this action, so nothing was changed.");
                        break;
                    case ForumModerateResult.ReasonTooLong:
                        Master.ShowToast("The reason can be at most " + TeacherForumData.MaxReasonLength + " characters, so nothing was changed.");
                        break;
                    default:
                        Master.ShowToast("That post could not be found, so nothing was changed.");
                        break;
                }
                return;
            }

            int pinPostId, commentId;
            if (parts.Length != 3 || !int.TryParse(parts[1], out pinPostId) || !int.TryParse(parts[2], out commentId)) return;
            TeacherForumPost post = Posts.FirstOrDefault(p => p.Id == pinPostId);
            TeacherForumComment comment = post == null ? null : post.Comments.FirstOrDefault(c => c.Id == commentId);
            if (comment == null) return;
            SelectedPost = post;

            if (parts[0] == "pin")
            {
                // saved in SQL only for a reply of a post this teacher can see; the page then shows the new state
                if (TeacherForumData.TogglePin(post.Id, comment.Id) == null) Master.ShowToast("That comment could not be found, so nothing was saved.");
                else ReloadPosts();
            }
        }

        private void ShowPublishedToast()
        {
            string message = Session["TeacherFlashToast"] as string;
            if (message == null) return;
            Session.Remove("TeacherFlashToast");
            Master.ShowToast(message);
        }

        protected void btnTeacherDismissFlag_Click(object sender, EventArgs e)
        {
            if (SelectedPost == null) return;
            TeacherForumData.DismissFlag(SelectedPost.Id);
            ReloadPosts();
            Master.ShowToast("Post flag has been dismissed.");
        }
    }
}
