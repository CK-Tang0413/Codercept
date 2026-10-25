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
            TeacherProfile profile = TeacherAccountData.GetProfile();
            if (profile == null)
            {
                // the account no longer exists: nothing to show
                Response.Redirect("~/signIn.aspx");
                return;
            }
            Email = profile.Email;
            MemberSince = profile.DateJoined.ToString("MMMM d, yyyy", System.Globalization.CultureInfo.InvariantCulture);

            if (!IsPostBack)
            {
                txtTeacherAccountName.Text = profile.Name;
                txtTeacherAccountAge.Text = profile.Age.HasValue ? profile.Age.Value.ToString() : "";
                txtTeacherAccountAddress.Text = profile.Region;

                // a level that was never set shows a "Select a level" prompt that has to be changed before saving
                if (profile.TeachingLevel != null && ddlTeacherAccountLevel.Items.FindByValue(profile.TeachingLevel) != null)
                {
                    ddlTeacherAccountLevel.SelectedValue = profile.TeachingLevel;
                }
                else
                {
                    ddlTeacherAccountLevel.Items.Insert(0, new System.Web.UI.WebControls.ListItem("Select a level", ""));
                    ddlTeacherAccountLevel.SelectedValue = "";
                }
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
