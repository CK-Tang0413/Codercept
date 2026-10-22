using System;
using System.Web;

namespace Codercept
{
    public partial class TeacherAccount : System.Web.UI.Page
    {
        protected string Email;
        protected string MemberSince;

        protected void Page_Load(object sender, EventArgs e)
        {
            // TODO (backend): load the logged-in teacher's profile (User table: Name, Age, Occupation, Address, Email, CreatedAt)
            Email = Master.UserEmail;
            MemberSince = "October 22, 2026";

            if (!IsPostBack)
            {
                txtTeacherAccountName.Text = Master.UserName;
                txtTeacherAccountAge.Text = "32";
                txtTeacherAccountRole.Text = "Teacher";
                txtTeacherAccountAddress.Text = "Kuala Lumpur, Malaysia";
            }

            // The confirmation field is plain HTML inside the shared modal; its text is re-checked in the confirm handler
            mdlTeacherDeleteAccount.BodyHtml = "This permanently removes your profile and portal access. Type <strong>"
                + HttpUtility.HtmlEncode(Email) + "</strong> to confirm."
                + "<span class=\"portal-form-field\"><span>Email address</span>"
                + "<input type=\"text\" name=\"tpDeleteEmail\" aria-label=\"Confirm email address\" autocomplete=\"off\" "
                + "placeholder=\"" + HttpUtility.HtmlAttributeEncode(Email) + "\" data-tp-delete-email=\""
                + HttpUtility.HtmlAttributeEncode(Email) + "\" /></span>";
        }

        protected void btnTeacherUpdateAccount_Click(object sender, EventArgs e)
        {
            // TODO (backend): UPDATE [User] SET Name = txtTeacherAccountName.Text, Age = txtTeacherAccountAge.Text,
            //   Occupation = txtTeacherAccountRole.Text, Address = txtTeacherAccountAddress.Text WHERE UserId = Session["UserId"]
            Master.ShowToast("Personal details updated");
        }

        protected void mdlTeacherDeleteAccount_Confirmed(object sender, EventArgs e)
        {
            if (Request.Form["tpDeleteEmail"] != Email) return;

            // TODO (backend): delete / deactivate the teacher's account, then sign out (Session.Abandon(); redirect to signIn.aspx)
            Master.ShowToast("Account deletion request confirmed");
        }
    }
}
