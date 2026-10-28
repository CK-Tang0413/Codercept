using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using BCrypt.Net;

namespace Codercept
{
    public partial class CreateAdminAccount : System.Web.UI.UserControl
    {
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["Codercept_db"]?.ConnectionString 
            ?? ConfigurationManager.ConnectionStrings["CoderceptDB"]?.ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnSubmitAdmin_Click(object sender, EventArgs e)
        {
            string fullName = txtAdminFullName.Text.Trim();
            string email = txtAdminEmail.Text.Trim();
            string role = ddlAdminRole.SelectedValue;

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email))
            {
                return;
            }

            // Derive predefined temporary password: <userFirstName> + alias symbol '@' + 1234
            string[] nameParts = fullName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            string firstName = nameParts.Length > 0 ? nameParts[0] : "Admin";
            string predefinedPassword = $"{firstName}@1234";

            string plainPassword = string.IsNullOrWhiteSpace(txtAdminPassword.Text) ? predefinedPassword : txtAdminPassword.Text.Trim();

            bool accountCreated = false;

            if (!string.IsNullOrEmpty(connectionString))
            {
                try
                {
                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        conn.Open();

                        // 1. Check if email already exists in [dbo].[Admin]
                        string checkQuery = "SELECT COUNT(*) FROM [dbo].[Admin] WHERE Email = @Email";
                        using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                        {
                            checkCmd.Parameters.AddWithValue("@Email", email);
                            int exists = Convert.ToInt32(checkCmd.ExecuteScalar());
                            if (exists > 0)
                            {
                                return;
                            }
                        }

                        // 2. Hash password with BCrypt (Cost Factor 12)
                        string hashedPassword = BCrypt.Net.BCrypt.HashPassword(plainPassword, 12);

                        // 3. Insert into [dbo].[Admin]
                        string insertQuery = @"
                            INSERT INTO [dbo].[Admin] (Name, Email, Password, Role, AccStatus)
                            VALUES (@Name, @Email, @Password, @Role, 'Active')";

                        using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@Name", fullName);
                            cmd.Parameters.AddWithValue("@Email", email);
                            cmd.Parameters.AddWithValue("@Password", hashedPassword);
                            cmd.Parameters.AddWithValue("@Role", role);
                            cmd.ExecuteNonQuery();
                            accountCreated = true;
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[CreateAdminAccount Error]: {ex.Message}");
                }
            }

            // Send notification email announcing successful account creation with predefined password
            if (accountCreated)
            {
                SendAccountCreatedEmail(fullName, email, plainPassword);
            }

            // Refresh the page and show active Admin tab with feedback
            Response.Redirect("AdminUserManagement.aspx?tab=admin&msg=admin_created");
        }

        private void SendAccountCreatedEmail(string fullName, string email, string temporaryPassword)
        {
            try
            {
                // Retrieve email credentials safely from AppSettings (as implemented in ForgotPassword.aspx.cs)
                string senderEmail = ConfigurationManager.AppSettings["SenderEmail"];
                string senderAppPassword = ConfigurationManager.AppSettings["SenderAppPassword"];

                if (string.IsNullOrEmpty(senderEmail) || string.IsNullOrEmpty(senderAppPassword))
                {
                    System.Diagnostics.Debug.WriteLine("[CreateAdminAccount SendEmail]: SenderEmail or SenderAppPassword not configured.");
                    return;
                }

                MailMessage mail = new MailMessage();
                mail.From = new MailAddress(senderEmail, "Codercept Team");
                mail.To.Add(email);
                mail.Subject = "Codercept Administrator Account Created Successfully";
                mail.Body = $@"
                    <div style='font-family: Arial, sans-serif; padding: 24px; color: #1e293b; line-height: 1.6; max-width: 600px; border: 1px solid #e2e8f0; border-radius: 8px;'>
                        <h2 style='color: #6366f1; margin-top: 0;'>Welcome to Codercept!</h2>
                        <p>Hello <strong>{HttpUtility.HtmlEncode(fullName)}</strong>,</p>
                        <p>Your administrator account has been created successfully on the Codercept management portal.</p>
                        <div style='background-color: #f8fafc; border: 1px solid #e2e8f0; border-left: 4px solid #6366f1; padding: 16px; border-radius: 6px; margin: 20px 0;'>
                            <p style='margin: 0 0 8px 0;'><strong>Login Email:</strong> {HttpUtility.HtmlEncode(email)}</p>
                            <p style='margin: 0;'><strong>Predefined Password:</strong> <code style='font-size: 16px; font-weight: bold; color: #6366f1;'>{HttpUtility.HtmlEncode(temporaryPassword)}</code></p>
                        </div>
                        <p>You can use this predefined password to log in to your account. For security purposes, please change your password after logging in.</p>
                        <p style='margin-top: 24px;'>Best regards,<br/><strong>The Codercept Team</strong></p>
                    </div>";
                mail.IsBodyHtml = true;

                SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587);
                smtp.Credentials = new NetworkCredential(senderEmail, senderAppPassword);
                smtp.EnableSsl = true;
                smtp.Send(mail);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[CreateAdminAccount SendEmail Error]: {ex.Message}");
            }
        }
    }
}
