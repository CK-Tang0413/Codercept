using System;
using System.Collections.Generic;

namespace Codercept
{
    public partial class LearnerAddPost : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserType"] == null || Session["UserType"].ToString() != "Learner")
            {
                Response.Redirect("signIn.aspx");
                return;
            }
        }

        // Add the OnClick event handler for the Submit button
        protected void btnPublishPost_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtPostTitle.Text) || string.IsNullOrWhiteSpace(txtPostDesc.Text))
            {
                return; // Prevent empty posts
            }

            // Format tags (ensure they have hashtags)
            string rawTags = txtPostTags.Text;
            string formattedTags = "";
            if (!string.IsNullOrWhiteSpace(rawTags))
            {
                var tagsList = rawTags.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                foreach (var tag in tagsList)
                {
                    formattedTags += "#" + tag.Trim().Replace(" ", "").Replace("#", "") + " ";
                }
            }

            // Create the new post object using the same structure as the Forum page
            var newPost = new LearnerForum.DummyPost
            {
                Id = new Random().Next(100, 999), // Random ID
                Title = txtPostTitle.Text.Trim(),
                Description = txtPostDesc.Text.Trim(),
                Tags = formattedTags.Trim(),
                IsActive = true, // Make it active immediately
                Comments = new List<LearnerForum.DummyComment>() // Empty comment list
            };

            // Store in Session so the Forum page can grab it
            Session["NewPost"] = newPost;

            // Redirect back to the forum
            Response.Redirect("LearnerForum.aspx");
        }
    }
}