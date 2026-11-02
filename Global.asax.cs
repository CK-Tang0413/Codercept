using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Optimization;
using System.Web.Routing;
using System.Web.Security;
using System.Web.SessionState;

namespace Codercept
{
    public class Global : HttpApplication
    {
        void Application_Start(object sender, EventArgs e)
        {
            // Code that runs on application startup
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

            // Initialize automated weekly purge service for deleted user records
            UserPurgeService.StartScheduledPurge();
        }

        void Application_End(object sender, EventArgs e)
        {
            // Cleanup automated weekly purge service
            UserPurgeService.StopScheduledPurge();
        }

        protected void Session_End(object sender, EventArgs e)
        {
            if (Session != null && Session["LogId"] != null)
            {
                int logId;
                if (int.TryParse(Session["LogId"].ToString(), out logId))
                {
                    string userRole = (Session["UserRole"] as string) ?? (Session["UserType"] as string);

                    int userId = 0;
                    if (Session["UserId"] != null)
                    {
                        int.TryParse(Session["UserId"].ToString(), out userId);
                    }
                    UserLogHelper.RecordLogout(logId, userRole, userId);
                }
            }
        }
    }
}
