using System;
using System.Collections.Generic;
using System.Linq;

namespace Codercept
{
    public partial class TeacherForumAdd : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnTeacherPublishPost_Click(object sender, EventArgs e)
        {
            string title = txtTeacherPostTitle.Text.Trim();
            string description = txtTeacherPostDescription.Text.Trim();

            bool titleError = title.Length == 0;
            bool descriptionError = description.Length == 0;
            MarkError(fldTeacherPostTitle, hintTeacherPostTitle, titleError, "Title is required.");
            MarkError(fldTeacherPostDescription, hintTeacherPostDescription, descriptionError, "Description is required.");
            if (titleError || descriptionError) return;

            // Same parsing as the live preview in TeacherPortal.js: split on commas, drop a leading #, skip blanks
            List<string> tags = txtTeacherPostTags.Text.Split(',')
                .Select(t => t.Trim().TrimStart('#').Trim())
                .Where(t => t.Length > 0)
                .ToList();

            // TODO (backend): INSERT INTO Forum (Title, Description, Tags, AuthorId, CreatedAt)
            //   values: title, description, tags (comma separated), Session["UserId"]
            List<TeacherForumPost> posts = TeacherSampleData.GetForumPosts();
            posts.Insert(0, new TeacherForumPost
            {
                Id = posts.Max(p => p.Id) + 1,
                Title = title,
                Excerpt = description.Length > 110 ? description.Substring(0, 110).TrimEnd() + "..." : description,
                Tags = tags,
                Comments = new List<TeacherForumComment>()
            });

            Session["TeacherFlashToast"] = "Post published successfully";
            Response.Redirect("TeacherForum.aspx");
        }

        private static void MarkError(System.Web.UI.HtmlControls.HtmlGenericControl field, System.Web.UI.HtmlControls.HtmlGenericControl hint, bool error, string message)
        {
            field.Attributes["class"] = error ? "portal-form-field has-error" : "portal-form-field" + (field.ID == "fldTeacherPostDescription" ? " post-description-field" : "");
            hint.InnerText = error ? message : "";
        }
    }
}
