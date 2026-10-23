using System;
using System.Web.Script.Serialization;

namespace Codercept
{
    public partial class TeacherSite : System.Web.UI.MasterPage
    {
        // When true, the portal opens without a Teacher session (design preview only).
        // Keep false: Page_Init below sends everyone who is not a signed-in Teacher to signIn.aspx.
        public static readonly bool PreviewWithoutLogin = false;

        public string UserName
        {
            get { return Session["UserName"] != null ? Session["UserName"].ToString() : TeacherSampleData.FallbackName; }
        }

        public string UserEmail
        {
            get { return Session["UserEmail"] != null ? Session["UserEmail"].ToString() : TeacherSampleData.FallbackEmail; }
        }

        public string UserInitial
        {
            get { return string.IsNullOrEmpty(UserName) ? "T" : UserName.Substring(0, 1).ToUpper(); }
        }

        /// <summary>File timestamp, so the browser reloads css/js after every change instead of using a stale copy.</summary>
        protected string AssetVersion(string virtualPath)
        {
            try { return System.IO.File.GetLastWriteTimeUtc(Server.MapPath(virtualPath)).Ticks.ToString(); }
            catch (Exception) { return "0"; }
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            lnkTeacherCss.Href = "~/css/teacher-portal.css?v=" + AssetVersion("~/css/teacher-portal.css");
        }

        protected void Page_Init(object sender, EventArgs e)
        {
            // Runs before the content page's Page_Load, so unauthorised users never reach page code.
            if (PreviewWithoutLogin) return;

            if (Session["UserType"] == null || Session["UserType"].ToString() != "Teacher")
            {
                Response.Redirect("signIn.aspx");
            }
        }

        /// <summary>Show the prototype's toast after the page loads (call from any content page code-behind).</summary>
        public void ShowToast(string message)
        {
            string js = "document.addEventListener('DOMContentLoaded',function(){TeacherPortal.toast("
                        + new JavaScriptSerializer().Serialize(message) + ");});";
            Page.ClientScript.RegisterStartupScript(GetType(), "tpToast" + Guid.NewGuid().ToString("N"), js, true);
        }
    }
}
