using System;
using System.Data.SqlClient;
using System.Configuration;

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
                            // Pass exactly what is in the database ("Admin" or "SuperAdmin")
                            ProceedToReset(email, reader["Role"].ToString());
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
                        ProceedToReset(email, "Learner");
                        return;
                    }
                }

                // 3. CHECK TEACHER TABLE
                using (SqlCommand cmd = new SqlCommand("SELECT TeacherId FROM [dbo].[Teacher] WHERE Email = @Email AND AccStatus = 'Active'", con))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    if (cmd.ExecuteScalar() != null)
                    {
                        ProceedToReset(email, "Teacher");
                        return;
                    }
                }

                // 4. CHECK TEACHING ASSISTANT TABLE
                using (SqlCommand cmd = new SqlCommand("SELECT TA_Id FROM [dbo].[Teaching_Assistant] WHERE Email = @Email AND AccStatus = 'Active'", con))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    if (cmd.ExecuteScalar() != null)
                    {
                        ProceedToReset(email, "TA");
                        return;
                    }
                }

                // IF NO MATCH
                lblEmailError.Text = "We couldn't find an active account with that email.";
            }
        }

        private void ProceedToReset(string email, string role)
        {
            // Store the email temporarily so the reset page knows whose password to update
            Session["ResetEmail"] = email;
            Session["ResetRole"] = role;

            // Redirect to the actual password change form
            Response.Redirect("ResetPassword.aspx");
        }
    }
}