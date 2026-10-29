using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
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
            string userRole = (Session["UserRole"] as string) ?? (Session["UserType"] as string);
            bool isSuperAdmin = !string.IsNullOrEmpty(userRole) &&
                (userRole.Equals("SuperAdmin", StringComparison.OrdinalIgnoreCase) ||
                 userRole.Equals("Super Admin", StringComparison.OrdinalIgnoreCase));

            if (!isSuperAdmin)
            {
                ShowModalError("Access denied. Only Super Administrators can create administrator accounts.");
                return;
            }

            string fullName = txtAdminFullName.Text.Trim();
            string email = txtAdminEmail.Text.Trim();
            string role = ddlAdminRole.SelectedValue;

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email))
            {
                ShowModalError("Please provide both full name and email address.");
                return;
            }

            // Determine temporary password: use custom password if provided, or default to <firstName>@1234
            string temporaryPassword = txtAdminPassword.Text.Trim();
            if (string.IsNullOrWhiteSpace(temporaryPassword))
            {
                string[] nameParts = fullName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                string firstName = nameParts.Length > 0 ? nameParts[0] : "Admin";
                temporaryPassword = $"{firstName}@1234";
            }

            if (string.IsNullOrEmpty(connectionString))
            {
                ShowModalError("Database connection is not configured properly.");
                return;
            }

            bool accountCreated = false;

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Check if email already exists in Admin, Teacher, Teaching_Assistant, or Learner tables
                    string checkQuery = @"
                        SELECT 
                            (SELECT COUNT(*) FROM [dbo].[Admin] WHERE Email = @Email) +
                            (SELECT COUNT(*) FROM [dbo].[Teacher] WHERE Email = @Email) +
                            (SELECT COUNT(*) FROM [dbo].[Teaching_Assistant] WHERE Email = @Email) +
                            (SELECT COUNT(*) FROM [dbo].[Learner] WHERE Email = @Email) AS TotalCount";

                    using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@Email", email);
                        int totalExists = Convert.ToInt32(checkCmd.ExecuteScalar());
                        if (totalExists > 0)
                        {
                            ShowModalError($"The email address '{email}' is already registered in the system. Please use a different email address.");
                            return;
                        }
                    }

                    // Hash password using BCrypt (Cost Factor 12)
                    string hashedPassword = BCrypt.Net.BCrypt.HashPassword(temporaryPassword, 12);

                    // Insert new administrator record
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
                System.Diagnostics.Debug.WriteLine($"[CreateAdminAccount Database Error]: {ex.Message}");
                ShowModalError($"An error occurred while creating the account: {ex.Message}");
                return;
            }

            if (accountCreated)
            {
                // Send email with the set temporary password
                string emailErrorMessage;
                bool emailSent = SendAccountCreatedEmail(fullName, email, temporaryPassword, role, out emailErrorMessage);

                if (emailSent)
                {
                    Response.Redirect($"AdminUserManagement.aspx?tab=admin&msg=admin_created&email={HttpUtility.UrlEncode(email)}");
                }
                else
                {
                    Response.Redirect($"AdminUserManagement.aspx?tab=admin&msg=admin_created_email_failed&email={HttpUtility.UrlEncode(email)}&err={HttpUtility.UrlEncode(emailErrorMessage)}");
                }
            }
        }

        private void ShowModalError(string message)
        {
            if (pnlModalError != null && litModalError != null)
            {
                pnlModalError.Visible = true;
                litModalError.Text = HttpUtility.HtmlEncode(message);
            }

            // Ensure the modal re-opens smoothly after postback so user sees the message
            string script = "document.addEventListener('DOMContentLoaded', function() { openAddAdminModal(); });";
            ScriptManager.RegisterStartupScript(this, GetType(), "ReopenAddAdminModalScript", script, true);
        }

        private bool SendAccountCreatedEmail(string fullName, string recipientEmail, string temporaryPassword, string roleTitle, out string errorMessage)
        {
            errorMessage = string.Empty;

            try
            {
                // Retrieve email credentials with fallback to secrets.config file on disk
                string senderEmail = ConfigurationManager.AppSettings["SenderEmail"];
                string senderAppPassword = ConfigurationManager.AppSettings["SenderAppPassword"];

                EnsureEmailCredentials(ref senderEmail, ref senderAppPassword);

                if (string.IsNullOrEmpty(senderEmail) || string.IsNullOrEmpty(senderAppPassword))
                {
                    errorMessage = "Sender email credentials are not configured in secrets.config.";
                    System.Diagnostics.Debug.WriteLine($"[CreateAdminAccount SendEmail]: {errorMessage}");
                    return false;
                }

                MailMessage mail = new MailMessage();
                mail.From = new MailAddress(senderEmail, "Codercept Team");
                mail.To.Add(recipientEmail);
                mail.Subject = "Welcome to Codercept - Administrator Account Credentials";

                string encodedName = HttpUtility.HtmlEncode(fullName);
                string encodedEmail = HttpUtility.HtmlEncode(recipientEmail);
                string encodedPassword = HttpUtility.HtmlEncode(temporaryPassword);
                string encodedRole = HttpUtility.HtmlEncode(roleTitle);

                mail.Body = $@"
                    <div style='font-family: -apple-system, BlinkMacSystemFont, ""Segoe UI"", Roboto, Helvetica, Arial, sans-serif; max-width: 580px; margin: 0 auto; background-color: #ffffff; border: 1px solid #e2e8f0; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);'>
                        <div style='background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%); padding: 32px 28px; text-align: center; color: #ffffff;'>
                            <h1 style='margin: 0; font-size: 24px; font-weight: 700; letter-spacing: -0.5px;'>Codercept Portal</h1>
                            <p style='margin: 8px 0 0 0; font-size: 14px; opacity: 0.9;'>Administrator Access Provisioned</p>
                        </div>
                        <div style='padding: 28px; color: #1e293b; line-height: 1.6;'>
                            <p style='font-size: 16px; margin-top: 0;'>Hello <strong>{encodedName}</strong>,</p>
                            <p style='font-size: 14px; color: #475569;'>An administrator account has been created for you on the Codercept management platform. You have been assigned the <strong>{encodedRole}</strong> privilege level.</p>
                            
                            <div style='background-color: #f8fafc; border: 1px solid #e2e8f0; border-left: 4px solid #6366f1; border-radius: 8px; padding: 18px; margin: 24px 0;'>
                                <div style='font-size: 12px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; color: #64748b; margin-bottom: 12px;'>Your Login Credentials</div>
                                <div style='margin-bottom: 10px; font-size: 14px;'>
                                    <strong style='color: #334155;'>Login Email:</strong> <span style='color: #0f172a; font-family: monospace; font-size: 15px;'>{encodedEmail}</span>
                                </div>
                                <div style='font-size: 14px;'>
                                    <strong style='color: #334155;'>Temporary Password:</strong> <code style='font-size: 16px; font-weight: 700; color: #4f46e5; background: #eef2ff; padding: 2px 8px; border-radius: 4px; border: 1px solid #c7d2fe;'>{encodedPassword}</code>
                                </div>
                            </div>

                            <div style='background-color: #fffbeb; border: 1px solid #fef3c7; border-radius: 8px; padding: 14px; margin-bottom: 24px; font-size: 13px; color: #92400e; display: flex; align-items: flex-start;'>
                                <span><strong>Security Notice:</strong> This temporary password was generated for initial access. Please log in using this password and immediately update it in your profile settings.</span>
                            </div>

                            <p style='font-size: 14px; color: #475569; margin-bottom: 4px;'>You can now access the admin portal and begin managing platform operations.</p>
                            
                            <p style='font-size: 14px; color: #64748b; margin-top: 28px; border-top: 1px solid #f1f5f9; padding-top: 20px;'>
                                Best regards,<br />
                                <strong style='color: #1e293b;'>The Codercept Administration Team</strong>
                            </p>
                        </div>
                    </div>";
                mail.IsBodyHtml = true;

                SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587)
                {
                    Credentials = new NetworkCredential(senderEmail, senderAppPassword),
                    EnableSsl = true
                };

                smtp.Send(mail);
                return true;
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
                System.Diagnostics.Debug.WriteLine($"[CreateAdminAccount SendEmail Error]: {ex.Message}");
                return false;
            }
        }

        private static void EnsureEmailCredentials(ref string senderEmail, ref string senderAppPassword)
        {
            if (string.IsNullOrEmpty(senderEmail) || string.IsNullOrEmpty(senderAppPassword))
            {
                try
                {
                    string secretsPath = HttpContext.Current != null && HttpContext.Current.Server != null
                        ? HttpContext.Current.Server.MapPath("~/secrets.config")
                        : Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "secrets.config");

                    if (File.Exists(secretsPath))
                    {
                        XmlDocument doc = new XmlDocument();
                        doc.Load(secretsPath);
                        XmlNode emailNode = doc.SelectSingleNode("//add[@key='SenderEmail']/@value");
                        XmlNode pwdNode = doc.SelectSingleNode("//add[@key='SenderAppPassword']/@value");
                        if (emailNode != null && !string.IsNullOrWhiteSpace(emailNode.Value))
                        {
                            senderEmail = emailNode.Value.Trim();
                        }
                        if (pwdNode != null && !string.IsNullOrWhiteSpace(pwdNode.Value))
                        {
                            senderAppPassword = pwdNode.Value.Trim();
                        }
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[EnsureEmailCredentials Error]: {ex.Message}");
                }
            }
        }
    }
}
