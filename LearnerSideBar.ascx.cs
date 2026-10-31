using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace Codercept
{
    public partial class LearnerSideBar : System.Web.UI.UserControl
    {
        string connString = ConfigurationManager.ConnectionStrings["Codercept_db"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserType"] != null)
            {
                if (Session["UserType"].ToString() == "Guest")
                {
                    phRestrictedNav.Visible = false;
                    phUserProfile.Visible = false;
                    phGuestAction.Visible = true;
                }
                else if (Session["UserName"] != null && Session["UserEmail"] != null)
                {
                    string fullName = Session["UserName"].ToString();
                    litUserNameNav.Text = fullName;
                    litUserEmailNav.Text = Session["UserEmail"].ToString();

                    if (!string.IsNullOrEmpty(fullName))
                    {
                        litUserInitial.Text = fullName.Substring(0, 1).ToUpper();
                    }

                    // --- NEW: Check if current page is one of the main allowed pages ---
                    string currentPage = System.IO.Path.GetFileNameWithoutExtension(Request.Url.AbsolutePath);

                    bool isMainPage =
                        string.Equals(currentPage, "LearnerDashboard", StringComparison.OrdinalIgnoreCase) ||
                        string.Equals(currentPage, "CourseCatalog", StringComparison.OrdinalIgnoreCase) ||
                        string.Equals(currentPage, "MyProgress", StringComparison.OrdinalIgnoreCase) ||
                        string.Equals(currentPage, "Certificates", StringComparison.OrdinalIgnoreCase) ||
                        string.Equals(currentPage, "LearnerForum", StringComparison.OrdinalIgnoreCase) ||
                        string.Equals(currentPage, "profile", StringComparison.OrdinalIgnoreCase);
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
            UserLogHelper.RecordLogout(Session);
            Session.Clear();
            Session.Abandon();
            Response.Redirect("signIn.aspx");
        }
    }
}