using System;
using System.Data.SqlClient;
using System.Configuration;
using BCrypt.Net;

namespace Codercept
{
    public partial class signUp : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnSignUp_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                lblSystemError.Text = "";

                string name = txtName.Text.Trim();
                string email = txtEmail.Text.Trim();
                string password = txtPassword.Text;

                string connString = ConfigurationManager.ConnectionStrings["Codercept_db"].ConnectionString;

                using (SqlConnection con = new SqlConnection(connString))
                {
                    con.Open();

                    // ==========================================
                    // 1. VERIFY EMAIL IS UNIQUE ACROSS ALL TABLES
                    // ==========================================
                    if (IsEmailTaken(email, con))
                    {
                        lblSystemError.Text = "An account with this email address already exists.";
                        return;
                    }

                    // ==========================================
                    // 2. HASH PASSWORD & CREATE ACCOUNT
                    // ==========================================
                    string hashedPassword = BCrypt.Net.BCrypt.HashPassword(password);

                    // We set AccStatus to 'Active' immediately since we are holding off on email verification for now
                    string query = @"INSERT INTO [dbo].[Learner] (Name, Email, Password, AccStatus) 
                                     VALUES (@Name, @Email, @Password, 'Active')";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@Name", name);
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.Parameters.AddWithValue("@Password", hashedPassword);

                        try
                        {
                            int rowsAffected = cmd.ExecuteNonQuery();
                            if (rowsAffected > 0)
                            {
                                // Account created successfully, send them to Sign In
                                Response.Redirect("signIn.aspx");
                            }
                            else
                            {
                                lblSystemError.Text = "Failed to create account. Please try again.";
                            }
                        }
                        catch (Exception ex)
                        {
                            lblSystemError.Text = ex.Message;
                            //lblSystemError.Text = "A database error occurred. Please try again later.";
                        }
                    }
                }
            }
        }

        // Helper method to keep your sequential logic clean
        private bool IsEmailTaken(string email, SqlConnection con)
        {
            // Check Admin
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(1) FROM [dbo].[Admin] WHERE Email = @Email", con))
            {
                cmd.Parameters.AddWithValue("@Email", email);
                if ((int)cmd.ExecuteScalar() > 0) return true;
            }

            // Check Learner
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(1) FROM [dbo].[Learner] WHERE Email = @Email", con))
            {
                cmd.Parameters.AddWithValue("@Email", email);
                if ((int)cmd.ExecuteScalar() > 0) return true;
            }

            // Check Teacher
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(1) FROM [dbo].[Teacher] WHERE Email = @Email", con))
            {
                cmd.Parameters.AddWithValue("@Email", email);
                if ((int)cmd.ExecuteScalar() > 0) return true;
            }

            // Check TA
            using (SqlCommand cmd = new SqlCommand("SELECT COUNT(1) FROM [dbo].[Teaching_Assistant] WHERE Email = @Email", con))
            {
                cmd.Parameters.AddWithValue("@Email", email);
                if ((int)cmd.ExecuteScalar() > 0) return true;
            }

            return false;
        }
    }
}