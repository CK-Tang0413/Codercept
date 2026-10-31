using System;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI.HtmlControls;

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
                Response.Redirect("~/LandingPage.aspx");
                return;
            }
            Email = profile.Email;
            MemberSince = profile.DateJoined.ToString("MMMM d, yyyy", System.Globalization.CultureInfo.InvariantCulture);

            if (!IsPostBack)
            {
                if (Request.QueryString["saved"] == "1") Master.ShowToast("Personal details updated");

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
            mdlTeacherDeleteAccount.BodyHtml = "This deactivates your account and signs you out; you will not be able to sign in again. Your courses and their learners' results are kept. Type <strong>"
                + HttpUtility.HtmlEncode(Email) + "</strong> to confirm."
                + "<span class=\"portal-form-field\"><span>Email address</span>"
                + "<input type=\"text\" name=\"tpDeleteEmail\" aria-label=\"Confirm email address\" autocomplete=\"off\" "
                + "placeholder=\"" + HttpUtility.HtmlAttributeEncode(Email) + "\" data-tp-delete-email=\""
                + HttpUtility.HtmlAttributeEncode(Email) + "\" /></span>";
        }

        protected void btnTeacherUpdateAccount_Click(object sender, EventArgs e)
        {
            string name = txtTeacherAccountName.Text.Trim();
            int age;
            string address = txtTeacherAccountAddress.Text.Trim();
            string level = ddlTeacherAccountLevel.SelectedValue;

            // the name is shown in the sidebar, so it cannot hold markup
            bool nameError = name.Length < 2 || name.Length > 50 || name.IndexOfAny(new[] { '<', '>' }) >= 0;
            bool ageError = !int.TryParse(txtTeacherAccountAge.Text.Trim(), out age) || age < 18 || age > 100;
            bool addressError = address.Length > 50;
            bool levelError = !TeacherAccountData.TeachingLevels.Contains(level);

            MarkError(fldTeacherAccountName, hintTeacherAccountName, nameError, "Enter a name of 2 to 50 characters, without < or >.");
            MarkError(fldTeacherAccountAge, hintTeacherAccountAge, ageError, "Enter your age as a whole number from 18 to 100.");
            MarkError(fldTeacherAccountAddress, hintTeacherAccountAddress, addressError, "The address can be at most 50 characters.");
            MarkError(fldTeacherAccountLevel, hintTeacherAccountLevel, levelError, "Choose your teaching level.");
            if (nameError || ageError || addressError || levelError) return;

            bool saved;
            try
            {
                saved = TeacherAccountData.UpdateProfile(name, age, address, level);
            }
            catch (SqlException)
            {
                Master.ShowToast("Could not update your details. Please try again.");
                return;
            }

            if (!saved)
            {
                Master.ShowToast("Your account could not be found.");
                return;
            }

            // the sidebar and greeting read the name from the session; reload the page so they show the new one
            Session["UserName"] = name;
            Response.Redirect("~/TeacherAccount.aspx?saved=1");
        }

        private static void MarkError(HtmlGenericControl field, HtmlGenericControl hint, bool error, string message)
        {
            string css = (field.Attributes["class"] ?? "").Replace(" has-error", "");
            field.Attributes["class"] = error ? css + " has-error" : css;
            hint.InnerText = error ? message : "";
        }

        protected void mdlTeacherDeleteAccount_Confirmed(object sender, EventArgs e)
        {
            if (Request.Form["tpDeleteEmail"] != Email)
            {
                Master.ShowToast("The email you typed does not match, so your account was not deactivated.");
                return;
            }

            bool deactivated;
            try
            {
                deactivated = TeacherAccountData.DeactivateAccount();
            }
            catch (SqlException)
            {
                Master.ShowToast("Could not deactivate your account. Please try again.");
                return;
            }

            if (!deactivated)
            {
                Master.ShowToast("Your account could not be found.");
                return;
            }

            // sign out, as the sidebar's Sign out link does
            Session.Abandon();
            Response.Redirect("~/signIn.aspx");
        }
    }
}
