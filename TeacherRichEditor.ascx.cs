using System;

namespace Codercept
{
    public partial class TeacherRichEditor : System.Web.UI.UserControl
    {
        public string Text
        {
            get { return txtTeacherRichText.Text; }
            set { txtTeacherRichText.Text = value; }
        }
    }
}
