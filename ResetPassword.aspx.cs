using System;
using System.Data.SqlClient;
using System.Configuration;
using BCrypt.Net;

namespace Codercept
{
    public partial class ResetPassword : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["ResetEmail"] == null || Session["ResetRole"] == null)
            {
                Response.Redirect("ForgotPassword.aspx");
            }
        }

        protected void btnResetPassword_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                string newPassword = txtNewPassword.Text;
                string email = Session["ResetEmail"].ToString();
                string role = Session["ResetRole"].ToString();

                string tableName = "";
                switch (role)
                {
                    case "SuperAdmin":
                    case "Admin":
                        tableName = "[dbo].[Admin]";
                        break;
                    case "Learner":
                        tableName = "[dbo].[Learner]";
                        break;
                    case "Teacher":
                        tableName = "[dbo].[Teacher]";
                        break;
                    case "TA":
                        tableName = "[dbo].[Teaching_Assistant]";
                        break;
                }

                if (string.IsNullOrEmpty(tableName))
                {
                    lblSystemError.Text = "Invalid user role.";
                    return;
                }

                string connString = ConfigurationManager.ConnectionStrings["Codercept_db"].ConnectionString;

                using (SqlConnection con = new SqlConnection(connString))
                {
                    con.Open();

                    // --- NEW VALIDATION: Check against default <FirstName>@1234 pattern ---
                    string nameQuery = $"SELECT Name FROM {tableName} WHERE Email = @Email";
                    using (SqlCommand nameCmd = new SqlCommand(nameQuery, con))
                    {
                        nameCmd.Parameters.AddWithValue("@Email", email);
                        object result = nameCmd.ExecuteScalar();

                        if (result != null)
                        {
                            string fullName = result.ToString();
                            string[] nameParts = fullName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                            string firstName = nameParts.Length > 0 ? nameParts[0] : "Admin";
                            string defaultPassword = $"{firstName}@1234";

                            if (newPassword.Equals(defaultPassword))
                            {
                                lblSystemError.Text = "You cannot use the default temporary password. Please choose a stronger, unique password.";
                                return;
                            }
                        }
                    }
                    // ----------------------------------------------------------------------

                    string hashedPassword = BCrypt.Net.BCrypt.HashPassword(newPassword);
                    string query = $"UPDATE {tableName} SET Password = @Password WHERE Email = @Email";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@Password", hashedPassword);
                        cmd.Parameters.AddWithValue("@Email", email);

                        try
                        {
                            int rowsAffected = cmd.ExecuteNonQuery();

                            if (rowsAffected > 0)
                            {
                                pnlResetForm.Visible = false;
                                lblSuccess.Text = "Password successfully updated! You can now sign in.";
                                lblSuccess.Visible = true;
                                lblSystemError.Text = "";

                                Session.Remove("ResetEmail");
                                Session.Remove("ResetRole");
                            }
                            else
                            {
                                lblSystemError.Text = "An error occurred while updating the password.";
                            }
                        }
                        catch (Exception ex)
                        {
                            lblSystemError.Text = "A database error occurred. Please try again later.";
                        }
                    }
                }
            }
        }
    }
}