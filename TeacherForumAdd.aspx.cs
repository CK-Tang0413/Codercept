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

            // Same parsing as the live preview in TeacherPortal.js: split on commas, drop a leading #, skip blanks (and repeats)
            List<string> tags = txtTeacherPostTags.Text.Split(',')
                .Select(t => t.Trim().TrimStart('#').Trim())
                .Where(t => t.Length > 0)
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToList();

            string titleMessage = title.Length == 0 ? "Title is required."
                : title.Length > TeacherForumData.MaxTitleLength ? "Title can be at most " + TeacherForumData.MaxTitleLength + " characters." : null;
            string descriptionMessage = description.Length == 0 ? "Description is required."
                : description.Length > TeacherForumData.MaxDescriptionLength ? "Description can be at most " + TeacherForumData.MaxDescriptionLength + " characters." : null;
            string tagsMessage = string.Join(",", tags).Length > TeacherForumData.MaxTagsLength
                ? "Tags are too long: " + TeacherForumData.MaxTagsLength + " characters at most in total." : null;

            MarkError(fldTeacherPostTitle, hintTeacherPostTitle, titleMessage != null, titleMessage);
            MarkError(fldTeacherPostDescription, hintTeacherPostDescription, descriptionMessage != null, descriptionMessage);
            // the Tags help text is the one written in the page unless there is an error
            fldTeacherPostTags.Attributes["class"] = tagsMessage != null ? "portal-form-field has-error" : "portal-form-field";
            hintTeacherPostTags.InnerText = tagsMessage ?? "Separate tags with commas. Hashtags will be added automatically.";
            if (titleMessage != null || descriptionMessage != null || tagsMessage != null) return;

            int postId = TeacherForumData.CreatePost(title, description, tags);
            if (postId == 0)
            {
                Master.ShowToast("The post could not be saved, so nothing was published.");
                return;
            }

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
