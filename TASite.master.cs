using System;
using System.Web.Script.Serialization;

namespace Codercept
{
    public partial class TASite : System.Web.UI.MasterPage
    {
        public string UserName
        {
            get { return Session["UserName"] != null ? Session["UserName"].ToString() : "Teaching Assistant"; }
        }

        public string UserEmail
        {
            get { return Session["UserEmail"] != null ? Session["UserEmail"].ToString() : ""; }
        }

        public string UserInitial
        {
            get { return string.IsNullOrEmpty(UserName) ? "T" : UserName.Substring(0, 1).ToUpper(); }
        }

        protected string AssetVersion(string virtualPath)
        {
            try { return System.IO.File.GetLastWriteTimeUtc(Server.MapPath(virtualPath)).Ticks.ToString(); }
            catch (Exception) { return "0"; }
        }

        protected void Page_Init(object sender, EventArgs e)
        {
            // Runs before the content page's Page_Load, so only signed-in TAs ever reach page code.
            if (Session["UserType"] == null || Session["UserType"].ToString() != "TA")
            {
                Response.Redirect("signIn.aspx");
            }
        }

        public void ShowToast(string message)
        {
            string js = "document.addEventListener('DOMContentLoaded',function(){TeacherPortal.toast("
                        + new JavaScriptSerializer().Serialize(message) + ");});";
            Page.ClientScript.RegisterStartupScript(GetType(), "tpToast" + Guid.NewGuid().ToString("N"), js, true);
        }
    }
}
