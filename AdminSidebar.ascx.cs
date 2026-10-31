using System;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class Admin_Sidebar : System.Web.UI.UserControl
    {
        public bool IsSuperAdmin { get; set; } = false;

        protected void Page_Load(object sender, EventArgs e)
        {
            string userRole = (Session["UserRole"] as string) ?? (Session["UserType"] as string);
            IsSuperAdmin = !string.IsNullOrEmpty(userRole) &&
                (userRole.Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase) ||
                 userRole.Equals("Super Admin", StringComparison.OrdinalIgnoreCase));

            bool isAdmin = !string.IsNullOrEmpty(userRole) &&
                (IsSuperAdmin || userRole.Equals("Admin", StringComparison.OrdinalIgnoreCase));

            if (phLogsNav != null)
            {
                phLogsNav.Visible = isAdmin;
            }

            if (!IsPostBack)
            {
                PopulateProfileInfo();

                // Persist session identity in ViewState as fallback if session state expires
                if (Session["LogId"] != null && int.TryParse(Session["LogId"].ToString(), out int currentLogId))
                {
                    ViewState["LogId"] = currentLogId;
                }
                if (Session["UserId"] != null && int.TryParse(Session["UserId"].ToString(), out int currentUserId))
                {
                    ViewState["UserId"] = currentUserId;
                }
                if (!string.IsNullOrEmpty(userRole))
                {
                    ViewState["UserRole"] = userRole;
                }
            }
        }

        private void PopulateProfileInfo()
        {
            string userName = Session["UserName"] as string;
            string userEmail = Session["UserEmail"] as string;

            if (!string.IsNullOrEmpty(userName))
            {
                litSidebarUserName.Text = HttpUtility.HtmlEncode(userName);
                litAvatarInitials.Text = HttpUtility.HtmlEncode(GetInitials(userName));
            }
            else
            {
                litSidebarUserName.Text = IsSuperAdmin ? "Super Admin" : "System Admin";
                litAvatarInitials.Text = IsSuperAdmin ? "SA" : "AD";
            }

            if (!string.IsNullOrEmpty(userEmail))
            {
                litSidebarUserEmail.Text = HttpUtility.HtmlEncode(userEmail);
            }
            else
            {
                litSidebarUserEmail.Text = IsSuperAdmin ? "superadmin@codercept.edu" : "admin@codercept.edu";
            }
        }

        private string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "A";
            string[] parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Substring(0, Math.Min(2, parts[0].Length)).ToUpper();
            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }

        protected void btnSignOut_Click(object sender, EventArgs e)
        {
            int logId = 0;
            if (Session["LogId"] != null)
            {
                int.TryParse(Session["LogId"].ToString(), out logId);
            }
            else if (ViewState["LogId"] != null)
            {
                int.TryParse(ViewState["LogId"].ToString(), out logId);
            }

            int userId = 0;
            if (Session["UserId"] != null)
            {
                int.TryParse(Session["UserId"].ToString(), out userId);
            }
            else if (ViewState["UserId"] != null)
            {
                int.TryParse(ViewState["UserId"].ToString(), out userId);
            }

            string userRole = (Session["UserRole"] as string) 
                ?? (Session["UserType"] as string) 
                ?? (ViewState["UserRole"] as string)
                ?? (IsSuperAdmin ? "SuperAdmin" : "Admin");

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

        protected string GetActiveCssClass(string keyword)
        {
            string currentPath = Request.Url.AbsolutePath.ToLower();
            string targetKeyword = keyword.ToLower();

            if (currentPath == "/" && targetKeyword == "admindashboard")
            {
                return "active";
            }

            if (currentPath.Contains(targetKeyword))
            {
                return "active";
            }

            return "";
        }
    }
}