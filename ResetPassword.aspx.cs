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

                // Hash the password automatically generating a secure salt
                string hashedPassword = BCrypt.Net.BCrypt.HashPassword(newPassword);

                // Determine the correct table based on the role stored in the session
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

                // Update the hashed password in the correct table
                using (SqlConnection con = new SqlConnection(connString))
                {
                    // Using string interpolation for the table name is safe here because 
                    // the table name is strictly controlled by our switch statement above, not user input.
                    string query = $"UPDATE {tableName} SET Password = @Password WHERE Email = @Email";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@Password", hashedPassword);
                        cmd.Parameters.AddWithValue("@Email", email);

                        try
                        {
                            con.Open();
                            int rowsAffected = cmd.ExecuteNonQuery();

                            if (rowsAffected > 0)
                            {
                                // Success! Hide the form and clear the session
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
                            // For debugging, you can log ex.Message, but show a generic error to the user
                            lblSystemError.Text = "A database error occurred. Please try again later.";
                        }
                    }
                }
            }
        }
    }
}