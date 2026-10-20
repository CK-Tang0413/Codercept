using System;
using System.Data.SqlClient;
using System.Configuration;

namespace Codercept
{
    public partial class profile : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserType"] == null || Session["UserType"].ToString() != "Learner")
            {
                Response.Redirect("signIn.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadUserProfile();
            }
        }

        private void LoadUserProfile()
        {
            string connString = ConfigurationManager.ConnectionStrings["Codercept_db"].ConnectionString;
            int learnerId = Convert.ToInt32(Session["UserId"]);

            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = "SELECT Name, Email, Age, Occupation, DateJoined, Address FROM [dbo].[Learner] WHERE LearnerId = @LearnerId";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    con.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            // 1. Core Fields (Always have data)
                            txtName.Text = reader["Name"].ToString();
                            txtEmail.Text = reader["Email"].ToString();

                            // 2. Format the Date (e.g., "October 20, 2026")
                            if (reader["DateJoined"] != DBNull.Value)
                            {
                                DateTime dateJoined = Convert.ToDateTime(reader["DateJoined"]);
                                txtDateJoined.Text = dateJoined.ToString("MMMM dd, yyyy");
                            }

                            // 3. Optional Fields (Check for NULL before displaying)
                            if (reader["Age"] != DBNull.Value)
                            {
                                txtAge.Text = reader["Age"].ToString();
                            }

                            if (reader["Occupation"] != DBNull.Value)
                            {
                                txtOccupation.Text = reader["Occupation"].ToString();
                            }

                            if (reader["Address"] != DBNull.Value)
                            {
                                txtAddress.Text = reader["Address"].ToString();
                            }
                        }
                    }
                }
            }
        }

        protected void btnDeleteAccount_Click(object sender, EventArgs e)
        {
            // We will implement this later
        }

        protected void btnUpdateProfile_Click(object sender, EventArgs e)
        {
            // We will implement this later
        }
    }
}