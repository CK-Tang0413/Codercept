using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class LearnerForum : System.Web.UI.Page
    {
        // 1. Data Models
        [Serializable]
        public class DummyPost
        {
            public int Id { get; set; }
            public string Title { get; set; }
            public string Description { get; set; }
            public string Tags { get; set; }
            public bool IsActive { get; set; }
            public int CommentCount { get { return Comments?.Count ?? 0; } }
            public List<DummyComment> Comments { get; set; } = new List<DummyComment>();
        }

        [Serializable]
        public class DummyComment
        {
            public int Id { get; set; }
            public string AuthorName { get; set; }
            public string AvatarInitials { get { return string.IsNullOrEmpty(AuthorName) ? "U" : AuthorName.Substring(0, 1).ToUpper(); } }
            public string RoleDisplay { get; set; }
            public string RoleCssClass { get { return RoleDisplay.ToLower().Replace(" ", ""); } }
            public string Message { get; set; }
            public bool IsPinned { get; set; }
            public bool IsFlagged { get; set; }
            public string ReplyToName { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserType"] == null || Session["UserType"].ToString() != "Learner")
            {
                Response.Redirect("signIn.aspx");
                return;
            }

            if (!IsPostBack)
            {
                InitializeDummyData();
                BindPosts();
            }
        }

        // 2. Data Initialization
        private void InitializeDummyData()
        {
            // Only create the dummy data if it doesn't exist in the Session yet
            if (Session["DummyPosts"] == null)
            {
                var posts = new List<DummyPost>
                {
                    new DummyPost
                    {
                        Id = 1, Title = "What is String in Python?", Description = "I am currently going through the Python for Beginners module and I'm a bit confused about Strings...", Tags = "#Python #Fundamental", IsActive = true,
                        Comments = new List<DummyComment>
                        {
                            new DummyComment { Id = 101, AuthorName = "Kylan Shane", RoleDisplay = "Learner", Message = "String is just a sequence of characters. They are strictly immutable.", IsPinned = false, IsFlagged = false },
                            new DummyComment { Id = 102, AuthorName = "Mr. Elaveenthan", RoleDisplay = "Teacher", Message = "Kylan is correct! Because they are immutable, if you want to 'modify' a string, you actually create a brand new string.", IsPinned = true, IsFlagged = false },
                            new DummyComment { Id = 103, AuthorName = "Unknown User", RoleDisplay = "Learner", Message = "Just copy the answers from ChatGPT for the quiz.", IsPinned = false, IsFlagged = true }
                        }
                    },
                    new DummyPost
                    {
                        Id = 2, Title = "Error setting up Visual Studio for C++", Description = "Every time I try to compile my first Hello World program, it throws an error...", Tags = "#C++ #Environment #Error", IsActive = false,
                        Comments = new List<DummyComment>
                        {
                            new DummyComment { Id = 201, AuthorName = "Alex Chen", RoleDisplay = "TA", Message = "Make sure you installed the C++ Desktop Development workload in the Visual Studio Installer.", IsPinned = false, IsFlagged = false }
                        }
                    }
                };

                // Check if a new post was just created from LearnerAddPost.aspx
                if (Session["NewPost"] != null)
                {
                    // Deactivate all existing posts
                    foreach (var p in posts) p.IsActive = false;

                    // Insert the new post at the top
                    posts.Insert(0, (DummyPost)Session["NewPost"]);
                    Session.Remove("NewPost");
                }

                Session["DummyPosts"] = posts;
            }
            else
            {
                // If the session exists, check for a new post anyway
                if (Session["NewPost"] != null)
                {
                    var posts = (List<DummyPost>)Session["DummyPosts"];
                    foreach (var p in posts) p.IsActive = false;
                    posts.Insert(0, (DummyPost)Session["NewPost"]);
                    Session.Remove("NewPost");
                    Session["DummyPosts"] = posts;
                }
            }
        }

        private void BindPosts()
        {
            var posts = (List<DummyPost>)Session["DummyPosts"];
            rptPosts.DataSource = posts;
            rptPosts.DataBind();

            var activePost = posts.FirstOrDefault(p => p.IsActive);
            if (activePost != null)
            {
                pnlComments.Visible = true;
                litActivePostTitle.Text = activePost.Title;
                rptComments.DataSource = activePost.Comments;
                rptComments.DataBind();
                Session["ActivePostId"] = activePost.Id;
            }
            else
            {
                pnlComments.Visible = false;
            }
        }

        // 3. Swap between discussions
        protected void rptPosts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SelectPost")
            {
                int postId = Convert.ToInt32(e.CommandArgument);
                var posts = (List<DummyPost>)Session["DummyPosts"];

                foreach (var post in posts) { post.IsActive = (post.Id == postId); }

                Session["DummyPosts"] = posts;
                hfReplyToId.Value = ""; // Reset reply state
                txtComment.Attributes["placeholder"] = "Type comment here...";
                BindPosts();
            }
        }

        // 4. Comment Actions (Pin, Flag, Reply)
        protected void rptComments_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int commentId = Convert.ToInt32(e.CommandArgument);
            int activePostId = (int)Session["ActivePostId"];
            var posts = (List<DummyPost>)Session["DummyPosts"];
            var activePost = posts.First(p => p.Id == activePostId);
            var comment = activePost.Comments.First(c => c.Id == commentId);

            if (e.CommandName == "TogglePin")
            {
                comment.IsPinned = !comment.IsPinned;
            }
            else if (e.CommandName == "ToggleFlag")
            {
                comment.IsFlagged = !comment.IsFlagged;
            }
            else if (e.CommandName == "Reply")
            {
                hfReplyToId.Value = comment.AuthorName;
                txtComment.Attributes["placeholder"] = $"Replying to {comment.AuthorName}...";
                return; // Skip rebind to keep UI state
            }

            Session["DummyPosts"] = posts;
            BindPosts();
        }

        // 5. Send a new message
        protected void btnSendComment_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtComment.Text) || Session["ActivePostId"] == null) return;

            int activePostId = (int)Session["ActivePostId"];
            var posts = (List<DummyPost>)Session["DummyPosts"];
            var activePost = posts.First(p => p.Id == activePostId);

            var newComment = new DummyComment
            {
                Id = activePost.Comments.Count > 0 ? activePost.Comments.Max(c => c.Id) + 1 : 1,
                AuthorName = Session["UserName"]?.ToString() ?? "You",
                RoleDisplay = "Learner",
                Message = txtComment.Text.Trim(),
                IsPinned = false,
                IsFlagged = false,
                ReplyToName = hfReplyToId.Value // Pull the replied user's name if set
            };

            activePost.Comments.Add(newComment);

            // Reset Input
            txtComment.Text = "";
            hfReplyToId.Value = "";
            txtComment.Attributes["placeholder"] = "Type comment here...";

            Session["DummyPosts"] = posts;
            BindPosts();
        }

        protected void btnAddPost_Click(object sender, EventArgs e)
        {
            Response.Redirect("LearnerAddPost.aspx");
        }
    }
}