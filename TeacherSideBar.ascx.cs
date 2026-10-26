using System;

namespace Codercept
{
    public partial class TeacherSideBar : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string fullName = Session["UserName"] != null ? Session["UserName"].ToString() : TeacherSampleData.FallbackName;
            string email = Session["UserEmail"] != null ? Session["UserEmail"].ToString() : TeacherSampleData.FallbackEmail;

            litTeacherNameNav.Text = Server.HtmlEncode(fullName);
            litTeacherEmailNav.Text = email;
            if (!string.IsNullOrEmpty(fullName))
            {
                litTeacherInitial.Text = Server.HtmlEncode(fullName.Substring(0, 1).ToUpper());
            }
        }

        /// <summary>Returns "active" when the current page is any of the given page names (no extension).</summary>
        protected string GetActiveCssClass(params string[] pageNames)
        {
            string currentPageName = System.IO.Path.GetFileNameWithoutExtension(Request.Url.AbsolutePath);

            foreach (string name in pageNames)
            {
                if (string.Equals(currentPageName, name, StringComparison.OrdinalIgnoreCase))
                {
                    return "active";
                }
            }
            return "";
        }

        protected void lnkTeacherSignOut_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("signIn.aspx");
        }
    }
}
