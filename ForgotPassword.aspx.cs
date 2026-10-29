using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Net;
using System.Net.Mail;

namespace Codercept
{
    public partial class ForgotPassword : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnVerifyEmail_Click(object sender, EventArgs e)
        {
            lblEmailError.Text = "";
            string email = txtEmail.Text.Trim();
            string connString = ConfigurationManager.ConnectionStrings["Codercept_db"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();

                // 1. CHECK ADMIN TABLE
                using (SqlCommand cmd = new SqlCommand("SELECT AdminId, Role FROM [dbo].[Admin] WHERE Email = @Email", con))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            SendOtpAndRedirect(email, reader["Role"].ToString());
                            return;
                        }
                    }
                }

                // 2. CHECK LEARNER TABLE
                using (SqlCommand cmd = new SqlCommand("SELECT LearnerId FROM [dbo].[Learner] WHERE Email = @Email AND AccStatus = 'Active'", con))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    if (cmd.ExecuteScalar() != null)
                    {
                        SendOtpAndRedirect(email, "Learner");
                        return;
                    }
                }

                // 3. CHECK TEACHER TABLE
                using (SqlCommand cmd = new SqlCommand("SELECT TeacherId FROM [dbo].[Teacher] WHERE Email = @Email AND AccStatus = 'Active'", con))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    if (cmd.ExecuteScalar() != null)
                    {
                        SendOtpAndRedirect(email, "Teacher");
                        return;
                    }
                }

                // 4. CHECK TEACHING ASSISTANT TABLE
                using (SqlCommand cmd = new SqlCommand("SELECT TA_Id FROM [dbo].[Teaching_Assistant] WHERE Email = @Email AND AccStatus = 'Active'", con))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    if (cmd.ExecuteScalar() != null)
                    {
                        SendOtpAndRedirect(email, "TA");
                        return;
                    }
                }

                // IF NO MATCH
                lblEmailError.Text = "We couldn't find an active account with that email.";
            }
        }

        private void SendOtpAndRedirect(string email, string role)
        {
            try
            {
                // 1. Generate a 6-digit random OTP
                Random rnd = new Random();
                string otp = rnd.Next(100000, 999999).ToString();

                // 2. Retrieve credentials safely from secrets.config
                string senderEmail = ConfigurationManager.AppSettings["SenderEmail"];
                string senderAppPassword = ConfigurationManager.AppSettings["SenderAppPassword"];

                // 3. Construct the email
                MailMessage mail = new MailMessage();
                mail.From = new MailAddress(senderEmail, "Codercept Team");
                mail.To.Add(email);
                mail.Subject = "Codercept Password Reset - OTP";
                mail.Body = $@"
                    <div style='font-family: Arial, sans-serif; padding: 20px;'>
                        <h2>Password Reset Request</h2>
                        <p>We received a request to reset the password for your Codercept account.</p>
                        <p>Your One-Time Password (OTP) is:</p>
                        <h1 style='color: #7C3AED; letter-spacing: 5px;'>{otp}</h1>
                        <p>This code will expire in a few minutes. If you did not request this reset, please ignore this email.</p>
                    </div>";
                mail.IsBodyHtml = true;

                // 4. Send the email via Gmail's SMTP server
                SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587);
                smtp.Credentials = new NetworkCredential(senderEmail, senderAppPassword);
                smtp.EnableSsl = true;
                smtp.Send(mail);

                // 5. Store data in Session for the verification step
                Session["ResetEmail"] = email;
                Session["ResetRole"] = role;
                Session["ResetOTP"] = otp;
                Session["OTPExpiry"] = DateTime.Now.AddMinutes(5);

                // 6. Redirect to the OTP input page (Create this page next if you haven't)
                Response.Redirect("VerifyOTP.aspx");
            }
            catch (Exception ex)
            {
                lblEmailError.Text = "Error: " + ex.Message;
                //lblEmailError.Text = "There was an error sending the email. Please try again later.";
                // Optionally log the exception: ex.Message
            }
        }
    }
}