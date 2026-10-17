using System;

namespace Codercept
{
    public partial class LearnerSideBar : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Bind user data here later
        }

        protected string GetActiveCssClass(string targetPageName)
        {
            string currentPageName = System.IO.Path.GetFileNameWithoutExtension(Request.Url.AbsolutePath);

            // Special rule: If we are checking the "LearnerForum" nav button, 
            // but the user is currently on the "LearnerAddPost" page, keep it active.
            if (targetPageName.Equals("LearnerForum", StringComparison.OrdinalIgnoreCase) &&
                currentPageName.Equals("LearnerAddPost", StringComparison.OrdinalIgnoreCase))
            {
                return "active";
            }

            // Standard check for all other pages
            if (string.Equals(currentPageName, targetPageName, StringComparison.OrdinalIgnoreCase))
            {
                return "active";
            }

            return "";
        }

        protected void lnkSignOut_Click(object sender, EventArgs e)
        {
            Response.Redirect("signIn.aspx");
        }
    }
}