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

                if (profile.TeachingLevel != null && ddlTeacherAccountLevel.Items.FindByValue(profile.TeachingLevel) != null)
                {
                    ddlTeacherAccountLevel.SelectedValue = profile.TeachingLevel;
                }
                else
                {
                    ddlTeacherAccountLevel.Items.Insert(0, new System.Web.UI.WebControls.ListItem("Select a level", ""));
                    ddlTeacherAccountLevel.SelectedValue = "";
                }

                ShowQualification(profile);
            }

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
                Master.ShowError("Could not update your details. Please try again.");
                return;
            }

            if (!saved)
            {
                Master.ShowError("Your account could not be found.");
                return;
            }

            Session["UserName"] = name;
            Response.Redirect("~/TeacherAccount.aspx?saved=1");
        }

        private void ShowQualification(TeacherProfile profile)
        {
            bool has = !string.IsNullOrWhiteSpace(profile.QualificationName);
            phTeacherQualEmpty.Visible = !has;
            phTeacherQual.Visible = has;
            if (!has) return;

            litQualName.Text = HttpUtility.HtmlEncode(profile.QualificationName);
            DateTime verified = profile.QualificationVerified ?? profile.DateJoined;
            litQualDate.Text = "Verified on " + verified.ToString("MMMM d, yyyy", System.Globalization.CultureInfo.InvariantCulture);

            string url = TeacherAccountData.DocumentUrl(profile.QualificationDocument);
            lnkQualDocument.Visible = url.Length > 0;
            spnQualNoDocument.Visible = url.Length == 0;
            if (url.Length > 0) lnkQualDocument.HRef = url;
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
                Master.ShowError("The email you typed does not match, so your account was not deactivated.");
                return;
            }

            bool deactivated;
            try
            {
                deactivated = TeacherAccountData.DeactivateAccount();
            }
            catch (SqlException)
            {
                Master.ShowError("Could not deactivate your account. Please try again.");
                return;
            }

            if (!deactivated)
            {
                Master.ShowError("Your account could not be found.");
                return;
            }

            Session.Abandon();
            Response.Redirect("~/LandingPage.aspx");
        }
    }
}
