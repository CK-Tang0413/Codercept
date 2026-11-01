using System;

namespace Codercept
{
    public partial class TASideBar : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserName"] != null)
            {
                string fullName = Session["UserName"].ToString();
                litUserNameNav.Text = fullName;
                litUserEmailNav.Text = Session["UserEmail"] != null ? Session["UserEmail"].ToString() : "";

                if (!string.IsNullOrEmpty(fullName))
                {
                    litUserInitial.Text = fullName.Substring(0, 1).ToUpper();
                }

                // Store Session Data in ViewState as a fallback if the Session times out
                if (Session["LogId"] != null) ViewState["LogId"] = Session["LogId"];
                if (Session["UserId"] != null) ViewState["UserId"] = Session["UserId"];
                if (Session["UserRole"] != null) ViewState["UserRole"] = Session["UserRole"];
            }
        }

        protected string GetActiveCssClass(string targetPageName)
        {
            string currentPageName = System.IO.Path.GetFileNameWithoutExtension(Request.Url.AbsolutePath);

            return string.Equals(currentPageName, targetPageName, StringComparison.OrdinalIgnoreCase) ? "active" : "";
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
                ?? "TA";

            // Record logout datetime into [dbo].[User_Log]
            if (logId > 0 || userId > 0)
            {
                UserLogHelper.RecordLogout(logId, userRole, userId);
            }
            else
            {
                UserLogHelper.RecordLogout(Session);
            }

            Session.Clear();
            Session.Abandon();
            Response.Redirect("LandingPage.aspx");
        }
    }
}