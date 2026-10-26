using System;
using System.Web;

namespace Codercept
{
    public partial class TeacherConfirmModal : System.Web.UI.UserControl
    {
        public string ModalId { get; set; }
        public string TitleText { get; set; }
        /// <summary>Body as HTML. Encode any user data (e.g. course titles) with Server.HtmlEncode before setting.</summary>
        public string BodyHtml { get; set; }
        public string IconName { get { return iconName ?? "trash"; } set { iconName = value; } }
        public string IconCssClass { get { return iconCss ?? "modal-danger-icon"; } set { iconCss = value; } }
        public string ExtraCssClass { get; set; }
        public string CancelText { get { return cancelText ?? "Cancel"; } set { cancelText = value; } }
        public string ConfirmText { get; set; }
        public string ConfirmIcon { get { return confirmIcon ?? "trash"; } set { confirmIcon = value; } }
        /// <summary>primary | secondary | ghost | danger</summary>
        public string ConfirmVariant { get { return confirmVariant ?? "danger"; } set { confirmVariant = value; } }

        /// <summary>Raised when the confirm button is clicked.</summary>
        public event EventHandler Confirmed;

        private string iconName, iconCss, cancelText, confirmIcon, confirmVariant;

        protected void Page_PreRender(object sender, EventArgs e)
        {
            btnTeacherConfirm.CssClass = "button button--" + ConfirmVariant;
            btnTeacherConfirm.Text = TeacherIcons.Svg(ConfirmIcon, 17) + "<span>" + HttpUtility.HtmlEncode(ConfirmText) + "</span>";
        }

        protected void btnTeacherConfirm_Click(object sender, EventArgs e)
        {
            if (Confirmed != null) Confirmed(this, EventArgs.Empty);
        }
    }
}
