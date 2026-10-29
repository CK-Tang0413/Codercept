using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class UserProfileDetails : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Control initialization logic
        }

        /// <summary>
        /// Resolves a database-stored qualification document path into a web-accessible URL.
        /// </summary>
        public static string ResolveDocUrl(string rawDoc)
        {
            if (string.IsNullOrWhiteSpace(rawDoc)) return "";
            string cleanDoc = rawDoc.Trim().Replace("\\", "/");
            if (cleanDoc.StartsWith("http://", StringComparison.OrdinalIgnoreCase) || cleanDoc.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
            {
                return cleanDoc;
            }
            if (cleanDoc.StartsWith("~/") || cleanDoc.StartsWith("/"))
            {
                string vPath = cleanDoc.StartsWith("~") ? cleanDoc : "~" + cleanDoc;
                try
                {
                    return VirtualPathUtility.ToAbsolute(vPath);
                }
                catch
                {
                    return cleanDoc.StartsWith("/") ? cleanDoc : "/" + cleanDoc.TrimStart('~', '/');
                }
            }
            if (cleanDoc.StartsWith("media/", StringComparison.OrdinalIgnoreCase) || cleanDoc.StartsWith("UploadedCertificates/", StringComparison.OrdinalIgnoreCase))
            {
                try
                {
                    return VirtualPathUtility.ToAbsolute("~/" + cleanDoc);
                }
                catch
                {
                    return "/" + cleanDoc;
                }
            }

            try
            {
                if (HttpContext.Current != null)
                {
                    string qualPath = HttpContext.Current.Server.MapPath("~/media/uploads/qualifications/" + cleanDoc);
                    if (File.Exists(qualPath))
                    {
                        return VirtualPathUtility.ToAbsolute("~/media/uploads/qualifications/" + cleanDoc);
                    }
                    string certPath = HttpContext.Current.Server.MapPath("~/UploadedCertificates/" + cleanDoc);
                    if (File.Exists(certPath))
                    {
                        return VirtualPathUtility.ToAbsolute("~/UploadedCertificates/" + cleanDoc);
                    }
                }
            }
            catch
            {
                // Fallback
            }

            try
            {
                return VirtualPathUtility.ToAbsolute("~/media/uploads/qualifications/" + cleanDoc);
            }
            catch
            {
                return "/media/uploads/qualifications/" + cleanDoc;
            }
        }

        /// <summary>
        /// Extracts the user-friendly file name from the document path.
        /// </summary>
        public static string GetDocumentFileName(string rawDoc)
        {
            if (string.IsNullOrWhiteSpace(rawDoc)) return "";
            string cleanDoc = rawDoc.Trim().Replace("\\", "/");
            string fn = Path.GetFileName(cleanDoc);
            return string.IsNullOrWhiteSpace(fn) ? cleanDoc : fn;
        }
    }
}
