using System;

namespace Codercept
{
    public partial class LearnerSideBar : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserType"] != null)
            {
                if (Session["UserType"].ToString() == "Guest")
                {
                    // Hide Learner features and show the sign-up prompt
                    phRestrictedNav.Visible = false;
                    phUserProfile.Visible = false;
                    phGuestAction.Visible = true;
                }
                else if (Session["UserName"] != null && Session["UserEmail"] != null)
                {
                    // Populate standard Learner data
                    string fullName = Session["UserName"].ToString();
                    litUserNameNav.Text = fullName;
                    litUserEmailNav.Text = Session["UserEmail"].ToString();

                    if (!string.IsNullOrEmpty(fullName))
                    {
                        litUserInitial.Text = fullName.Substring(0, 1).ToUpper();
                    }
                }
            }
        }

        protected string GetActiveCssClass(string targetPageName)
        {
            string currentPageName = System.IO.Path.GetFileNameWithoutExtension(Request.Url.AbsolutePath);

            if (targetPageName.Equals("LearnerForum", StringComparison.OrdinalIgnoreCase) &&
                currentPageName.Equals("LearnerAddPost", StringComparison.OrdinalIgnoreCase))
            {
                return "active";
            }

            if (string.Equals(currentPageName, targetPageName, StringComparison.OrdinalIgnoreCase))
            {
                return "active";
            }

            return "";
        }

        protected void lnkSignOut_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("signIn.aspx");
        }
    }
}