using System;
using System.Web;

namespace Codercept
{
    public partial class TeacherMediaDropzone : System.Web.UI.UserControl
    {
        public bool Compact { get; set; }

        /// <summary>The uploaded file, if any. The page passes it to TeacherMediaStore.Save, which checks the type and size and stores it.</summary>
        public HttpPostedFile PostedFile
        {
            get { return fuTeacherMedia.HasFile ? fuTeacherMedia.PostedFile : null; }
        }
    }
}
