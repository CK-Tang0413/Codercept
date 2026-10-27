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
            }
        }

        protected string GetActiveCssClass(string targetPageName)
        {
            string currentPageName = System.IO.Path.GetFileNameWithoutExtension(Request.Url.AbsolutePath);

            return string.Equals(currentPageName, targetPageName, StringComparison.OrdinalIgnoreCase) ? "active" : "";
        }

        protected void lnkSignOut_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("signIn.aspx");
        }
    }
}
