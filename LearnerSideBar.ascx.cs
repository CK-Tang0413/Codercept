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
                    phNotificationBell.Visible = false;
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

                    if (isMainPage)
                    {
                        phNotificationBell.Visible = true;
                        LoadNotifications();
                    }
                    else
                    {
                        phNotificationBell.Visible = false; // Hide on sub-interfaces like CourseDetails, CourseViewer, LearnerAddPost, etc.
                    }
                }
            }
        }

        private void LoadNotifications()
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = @"
                    SELECT [NotificationId], [Title], [Content], [Type], [DateTime]
                    FROM [dbo].[Notification]
                    ORDER BY [DateTime] DESC, [NotificationId] DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptNotifications.DataSource = dt;
                            rptNotifications.DataBind();

                            // Find the highest NotificationId so the client knows what is new
                            int maxId = 0;
                            foreach (DataRow row in dt.Rows)
                            {
                                int currentId = Convert.ToInt32(row["NotificationId"]);
                                if (currentId > maxId) maxId = currentId;
                            }

                            litLatestNotifId.Text = maxId.ToString();
                            pnlNotifBadge.Visible = true;
                            litNotifCount.Text = dt.Rows.Count.ToString();
                            pnlNoNotifications.Visible = false;
                        }
                        else
                        {
                            litLatestNotifId.Text = "0";
                            pnlNotifBadge.Visible = false;
                            pnlNoNotifications.Visible = true;
                        }
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
            UserLogHelper.RecordLogout(Session);
            Session.Clear();
            Session.Abandon();
            Response.Redirect("signIn.aspx");
        }
    }
}