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
            // Only execute if a valid user is logged in
            if (Session["UserType"] != null && Session["UserName"] != null && Session["UserEmail"] != null)
            {
                string fullName = Session["UserName"].ToString();
                litUserNameNav.Text = fullName;
                litUserEmailNav.Text = Session["UserEmail"].ToString();

                if (!string.IsNullOrEmpty(fullName))
                {
                    litUserInitial.Text = fullName.Substring(0, 1).ToUpper();
                }

                // Store Session Data in ViewState as a fallback if the Session times out
                if (Session["LogId"] != null) ViewState["LogId"] = Session["LogId"];
                if (Session["UserId"] != null) ViewState["UserId"] = Session["UserId"];
                if (Session["UserRole"] != null) ViewState["UserRole"] = Session["UserRole"];

                // --- Check if current page is one of the main allowed pages ---
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
            // Safely attempt to retrieve IDs from Session first, fallback to ViewState
            int logId = 0;
            if (Session["LogId"] != null) int.TryParse(Session["LogId"].ToString(), out logId);
            else if (ViewState["LogId"] != null) int.TryParse(ViewState["LogId"].ToString(), out logId);

            int userId = 0;
            if (Session["UserId"] != null) int.TryParse(Session["UserId"].ToString(), out userId);
            else if (ViewState["UserId"] != null) int.TryParse(ViewState["UserId"].ToString(), out userId);

            string userRole = (Session["UserRole"] as string)
                ?? (Session["UserType"] as string)
                ?? (ViewState["UserRole"] as string)
                ?? "Learner";

            // Record logout datetime into [dbo].[User_Log]
            if (logId > 0 || userId > 0)
            {
                UserLogHelper.RecordLogout(logId, userRole, userId);
            }
            else
            {
                // Absolute fallback
                UserLogHelper.RecordLogout(Session);
            }

            // Clear and Destroy Session
            Session.Clear();
            Session.Abandon();
            Response.Redirect("signIn.aspx");
        }
    }
}