using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class VerifyOTP : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Security check: If they somehow reach this page without requesting an OTP, kick them back
            if (Session["ResetEmail"] == null || Session["ResetOTP"] == null)
            {
                Response.Redirect("ForgotPassword.aspx");
            }
        }

        protected void btnVerify_Click(object sender, EventArgs e)
        {
            lblError.Text = "";
            string enteredOTP = txtOTP.Text.Trim();
            string expectedOTP = Session["ResetOTP"].ToString();

            if (string.IsNullOrEmpty(enteredOTP))
            {
                lblError.Text = "Please enter the OTP.";
                return;
            }

            if (Session["OTPExpiry"] != null)
            {
                DateTime expiryTime = (DateTime)Session["OTPExpiry"];
                if (DateTime.Now > expiryTime)
                {
                    lblError.Text = "This OTP has expired. Please go back and request a new one.";
                    Session.Remove("ResetOTP"); // Destroy the expired OTP
                    Session.Remove("OTPExpiry");
                    return;
                }
            }

            if (enteredOTP == expectedOTP)
            {
                // Success! Clear the OTP from session so it cannot be reused
                Session.Remove("ResetOTP");

                // Send them to the final step to type a new password
                Response.Redirect("ResetPassword.aspx");
            }
            else
            {
                lblError.Text = "Invalid OTP. Please try again.";
            }
        }
    }
}