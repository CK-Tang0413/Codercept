using System;
using System.Web;

namespace Codercept
{
    public partial class TeacherMediaDropzone : System.Web.UI.UserControl
    {
        public bool Compact { get; set; }

        /// <summary>The uploaded file, if any. TODO (backend): validate type/size (25 MB) and store it.</summary>
        public HttpPostedFile PostedFile
        {
            get { return fuTeacherMedia.HasFile ? fuTeacherMedia.PostedFile : null; }
        }
    }
}
