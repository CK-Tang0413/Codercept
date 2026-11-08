using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data.SqlClient;
using System.Configuration;

namespace Codercept
{
    public partial class signIn : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString["registered"] == "pending")
                {
                    pnlNotice.Visible = true;
                    litNotice.Text = "<strong>Application Received!</strong> Your educator application has been submitted and is currently pending administrator approval. You will receive an update once approved.";
                }
                else if (Request.QueryString["registered"] == "reapplied")
                {
                    pnlNotice.Visible = true;
                    litNotice.Text = "<strong>Application Re-submitted!</strong> Your updated educator application has been submitted and is currently pending administrator review. You will receive an update once approved.";
                }
            }
        }

        protected void btnSignIn_Click(object sender, EventArgs e)
        {
            lblEmailError.Text = "";
            lblPasswordError.Text = "";

            string email = txtEmail.Text.Trim();
            string passwordInput = txtPassword.Text;
            string connString = ConfigurationManager.ConnectionStrings["Codercept_db"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand("SELECT AdminId, Name, Password, Role, AccStatus FROM [dbo].[Admin] WHERE Email = @Email", con))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            if (reader["AccStatus"].ToString() != "Active")
                            {
                                lblEmailError.Text = "Your account is not active.";
                                return;
                            }

                            if (BCrypt.Net.BCrypt.Verify(passwordInput, reader["Password"].ToString()))
                            {
                                int adminId = Convert.ToInt32(reader["AdminId"]);
                                string role = reader["Role"].ToString();
                                string fullName = reader["Name"].ToString();

                                // --- FIRST-TIME LOGIN CHECK ---
                                string[] nameParts = fullName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                                string firstName = nameParts.Length > 0 ? nameParts[0] : "Admin";
                                string defaultPassword = $"{firstName}@1234";

                                if (passwordInput.Equals(defaultPassword))
                                {
                                    reader.Close();

                                    // Generate OTP and send email for forced reset
                                    SendOtpForcedReset(email, role, fullName);
                                    return;
                                }
                                // ------------------------------

                                Session["UserId"] = adminId;
                                Session["UserType"] = role;
                                Session["UserRole"] = role;
                                Session["UserName"] = fullName;
                                Session["UserEmail"] = email;

                                reader.Close();

                                int logId = UserLogHelper.RecordLogin(role, adminId);
                                if (logId > 0)
                                {
                                    Session["LogId"] = logId;
                                }

                                Response.Redirect("AdminDashboard.aspx");
                            }
                            else
                            {
                                lblPasswordError.Text = "Incorrect password.";
                            }return;
                        }
                    }
                }

                using (SqlCommand cmd = new SqlCommand("SELECT LearnerId, Name, Password, AccStatus FROM [dbo].[Learner] WHERE Email = @Email", con))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            if (reader["AccStatus"].ToString() != "Active")
                            {
                                lblEmailError.Text = "Your account is not active.";
                                return;
                            }

                            if (BCrypt.Net.BCrypt.Verify(passwordInput, reader["Password"].ToString()))
                            {
                                int learnerId = Convert.ToInt32(reader["LearnerId"]);

                                Session["UserId"] = learnerId;
                                Session["UserType"] = "Learner";
                                Session["UserRole"] = "Learner";
                                Session["UserName"] = reader["Name"].ToString();
                                Session["UserEmail"] = email;

                                reader.Close();

                                int logId = UserLogHelper.RecordLogin("Learner", learnerId);
                                if (logId > 0)
                                {
                                    Session["LogId"] = logId;
                                }

                                Response.Redirect("LearnerDashboard.aspx");
                            }
                            else
                            {
                                lblPasswordError.Text = "Incorrect password.";
                            }
                            return;
                        }
                    }
                }

                using (SqlCommand cmd = new SqlCommand("SELECT TeacherId, Name, Password, AccStatus FROM [dbo].[Teacher] WHERE Email = @Email", con))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            if (reader["AccStatus"].ToString() != "Active")
                            {
                                string status = reader["AccStatus"].ToString();
                                if (status.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                                {
                                    lblEmailError.Text = "Your educator application is currently pending administrator review. You will receive an email once processed.";
                                }
                                else if (status.Equals("Rejected", StringComparison.OrdinalIgnoreCase))
                                {
                                    lblEmailError.Text = "Your previous application was not approved. You can submit an updated application with new credentials on the <a href='TeacherRegistration.aspx' style='color:#7c3aed;text-decoration:underline;font-weight:600;'>Teacher Registration</a> page.";
                                }
                                else
                                {
                                    lblEmailError.Text = "Your account is not active.";
                                }
                                return;
                            }

                            if (BCrypt.Net.BCrypt.Verify(passwordInput, reader["Password"].ToString()))
                            {
                                int teacherId = Convert.ToInt32(reader["TeacherId"]);

                                Session["UserId"] = teacherId;
                                Session["UserType"] = "Teacher";
                                Session["UserRole"] = "Teacher";
                                Session["UserName"] = reader["Name"].ToString();
                                Session["UserEmail"] = email;

                                reader.Close();

                                int logId = UserLogHelper.RecordLogin("Teacher", teacherId);
                                if (logId > 0)
                                {
                                    Session["LogId"] = logId;
                                }

                                Response.Redirect("TeacherDashboard.aspx");
                            }
                            else
                            {
                                lblPasswordError.Text = "Incorrect password.";
                            }
                            return;
                        }
                    }
                }

                using (SqlCommand cmd = new SqlCommand("SELECT TA_Id, Name, Password, AccStatus FROM [dbo].[Teaching_Assistant] WHERE Email = @Email", con))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            if (reader["AccStatus"].ToString() != "Active")
                            {
                                string status = reader["AccStatus"].ToString();
                                if (status.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                                {
                                    lblEmailError.Text = "Your educator application is currently pending administrator review. You will receive an email once processed.";
                                }
                                else if (status.Equals("Rejected", StringComparison.OrdinalIgnoreCase))
                                {
                                    lblEmailError.Text = "Your previous application was not approved. You can submit an updated application with new credentials on the <a href='TeacherRegistration.aspx' style='color:#7c3aed;text-decoration:underline;font-weight:600;'>Teacher Registration</a> page.";
                                }
                                else
                                {
                                    lblEmailError.Text = "Your account is not active.";
                                }
                                return;
                            }

                            if (BCrypt.Net.BCrypt.Verify(passwordInput, reader["Password"].ToString()))
                            {
                                int taId = Convert.ToInt32(reader["TA_Id"]);

                                Session["UserId"] = taId;
                                Session["UserType"] = "TA";
                                Session["UserRole"] = "TA";
                                Session["UserName"] = reader["Name"].ToString();
                                Session["UserEmail"] = email;

                                reader.Close();

                                int logId = UserLogHelper.RecordLogin("TA", taId);
                                if (logId > 0)
                                {
                                    Session["LogId"] = logId;
                                }

                                Response.Redirect("TADashboard.aspx");
                            }
                            else
                            {
                                lblPasswordError.Text = "Incorrect password.";
                            }
                            return;
                        }
                    }
                }

                lblEmailError.Text = "Email not found.";
            }
        }

        private void SendOtpForcedReset(string email, string role, string fullName)
        {
            try
            {
                Random rnd = new Random();
                string otp = rnd.Next(100000, 999999).ToString();

                string senderEmail = ConfigurationManager.AppSettings["SenderEmail"];
                string senderAppPassword = ConfigurationManager.AppSettings["SenderAppPassword"];

                System.Net.Mail.MailMessage mail = new System.Net.Mail.MailMessage();
                mail.From = new System.Net.Mail.MailAddress(senderEmail, "Codercept Team");
                mail.To.Add(email);
                mail.Subject = "Codercept - Mandatory Password Update";
                mail.Body = $@"
                    <div style='font-family: Arial, sans-serif; padding: 20px;'>
                        <h2>Action Required: Update Your Password</h2>
                        <p>Hello {fullName},</p>
                        <p>For security reasons, you must change your temporary default password before accessing the Codercept management platform.</p>
                        <p>Your verification code is:</p>
                        <h1 style='color: #7C3AED; letter-spacing: 5px;'>{otp}</h1>
                        <p>This code will expire in 5 minutes.</p>
                    </div>";
                mail.IsBodyHtml = true;

                System.Net.Mail.SmtpClient smtp = new System.Net.Mail.SmtpClient("smtp.gmail.com", 587);
                smtp.Credentials = new System.Net.NetworkCredential(senderEmail, senderAppPassword);
                smtp.EnableSsl = true;
                smtp.Send(mail);

                // Set the session variables
                Session["ResetEmail"] = email;
                Session["ResetRole"] = role;
                Session["ResetOTP"] = otp;
                Session["OTPExpiry"] = DateTime.Now.AddMinutes(5);

                // INSTEAD of Response.Redirect, we trigger a browser pop-up, then redirect via JavaScript
                string script = @"
                    alert('For security reasons, first-time administrators must change their default password. A verification code has been sent to your email.');
                    window.location.href = 'VerifyOTP.aspx';
                ";
                ClientScript.RegisterStartupScript(this.GetType(), "ForceResetAlert", script, true);
            }
            catch (Exception ex)
            {
                lblEmailError.Text = "There was an error generating your security code. Please contact IT support.";
            }
        }

    }
}
