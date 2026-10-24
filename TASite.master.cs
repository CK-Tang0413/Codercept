using System;

namespace Codercept
{
    public partial class TASite : System.Web.UI.MasterPage
    {
        protected void Page_Init(object sender, EventArgs e)
        {
            // Runs before the content page's Page_Load, so only signed-in TAs ever reach page code.
            if (Session["UserType"] == null || Session["UserType"].ToString() != "TA")
            {
                Response.Redirect("signIn.aspx");
            }
        }
    }
}
