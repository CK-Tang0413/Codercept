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
            }
        }

        protected void btnSignIn_Click(object sender, EventArgs e)
        {
            // Clear previous errors
            lblEmailError.Text = "";
            lblPasswordError.Text = "";

            string email = txtEmail.Text.Trim();
            string passwordInput = txtPassword.Text;
            string connString = ConfigurationManager.ConnectionStrings["Codercept_db"].ConnectionString;

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();

                // ==========================================
                // 1. CHECK ADMIN TABLE
                // ==========================================
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

                            // Use BCrypt to safely verify the hashed password
                            if (BCrypt.Net.BCrypt.Verify(passwordInput, reader["Password"].ToString()))
                            {
                                int adminId = Convert.ToInt32(reader["AdminId"]);
                                string role = reader["Role"].ToString();

                                Session["UserId"] = adminId;
                                Session["UserType"] = role; // Dynamically captures "Admin" or "SuperAdmin"
                                Session["UserRole"] = role;
                                Session["UserName"] = reader["Name"].ToString();
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
                            }
                            return;
                        }
                    }
                }

                // ==========================================
                // 2. CHECK LEARNER TABLE
                // ==========================================
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

                // ==========================================
                // 3. CHECK TEACHER TABLE
                // ==========================================
                using (SqlCommand cmd = new SqlCommand("SELECT TeacherId, Name, Password, AccStatus FROM [dbo].[Teacher] WHERE Email = @Email", con))
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

                // ==========================================
                // 4. CHECK TEACHING ASSISTANT TABLE
                // ==========================================
                using (SqlCommand cmd = new SqlCommand("SELECT TA_Id, Name, Password, AccStatus FROM [dbo].[Teaching_Assistant] WHERE Email = @Email", con))
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

                // ==========================================
                // 5. NO MATCH FOUND IN ANY TABLE
                // ==========================================
                lblEmailError.Text = "Email not found.";
            }
        }

        protected void btnGuest_Click(object sender, EventArgs e)
        {
            // Assign generic guest attributes to bypass the login check securely
            Session["UserType"] = "Guest";
            Session["UserRole"] = "Guest";
            Session["UserName"] = "Future Coder"; // Used for the dashboard greeting
            Session["UserEmail"] = "";

            Response.Redirect("LearnerDashboard.aspx");
        }
    }
}
