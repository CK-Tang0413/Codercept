using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class Admin_Sidebar : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        // Add this helper method
        protected string GetActiveCssClass(string keyword)
        {
            // Get the current URL path in lowercase
            string currentPath = Request.Url.AbsolutePath.ToLower();
            string targetKeyword = keyword.ToLower();

            // If viewing the root domain directory, default to highlighting the Dashboard
            if (currentPath == "/" && targetKeyword == "admindashboard")
            {
                return "active";
            }

            // Check if the URL contains the keyword (e.g. matches "admindashboard" inside "/AdminDashboard")
            if (currentPath.Contains(targetKeyword))
            {
                return "active";
            }

            return "";
        }
    }
}