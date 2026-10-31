using System;
using System.Data.SqlClient;
using System.Configuration;

namespace Codercept
{
    public partial class profile : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["Codercept_db"].ConnectionString;

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
                            txtName.Text = reader["Name"].ToString();
                            txtEmail.Text = reader["Email"].ToString();

                            if (reader["DateJoined"] != DBNull.Value)
                            {
                                DateTime dateJoined = Convert.ToDateTime(reader["DateJoined"]);
                                txtDateJoined.Text = dateJoined.ToString("MMMM dd, yyyy");
                            }

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

        protected void btnUpdateProfile_Click(object sender, EventArgs e)
        {
            // 1. Reset the toast state in case they click it multiple times
            pnlToast.Visible = false;

            int learnerId = Convert.ToInt32(Session["UserId"]);
            string name = txtName.Text.Trim();
            string occupation = txtOccupation.Text.Trim();
            string address = txtAddress.Text.Trim();
            int age = 0;
            int.TryParse(txtAge.Text.Trim(), out age);

            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = "UPDATE [dbo].[Learner] SET Name = @Name, Age = @Age, Occupation = @Occupation, Address = @Address WHERE LearnerId = @LearnerId";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Name", name);
                    cmd.Parameters.AddWithValue("@Age", age > 0 ? (object)age : DBNull.Value);
                    cmd.Parameters.AddWithValue("@Occupation", string.IsNullOrEmpty(occupation) ? (object)DBNull.Value : occupation);
                    cmd.Parameters.AddWithValue("@Address", string.IsNullOrEmpty(address) ? (object)DBNull.Value : address);
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);

                    con.Open();
                    cmd.ExecuteNonQuery();
                    con.Close();
                }
            }

            // Update session name if changed
            Session["UserName"] = name;
            LoadUserProfile();

            // 2. Trigger the success toast notification
            pnlToast.Visible = true;
        }

        protected void btnDeleteAccount_Click(object sender, EventArgs e)
        {
            int learnerId = Convert.ToInt32(Session["UserId"]);

            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();
                // Optional: Delete related progress records first if foreign keys require it, or directly delete learner
                string deleteProgress = "DELETE FROM LearnerProgress WHERE LearnerId = @LearnerId";
                using (SqlCommand cmdProgress = new SqlCommand(deleteProgress, con))
                {
                    cmdProgress.Parameters.AddWithValue("@LearnerId", learnerId);
                    cmdProgress.ExecuteNonQuery();
                }

                string deleteQuery = "DELETE FROM [dbo].[Learner] WHERE LearnerId = @LearnerId";
                using (SqlCommand cmd = new SqlCommand(deleteQuery, con))
                {
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    cmd.ExecuteNonQuery();
                }
                con.Close();
            }

            // Clear session and redirect to sign in
            Session.Clear();
            Session.Abandon();
            Response.Redirect("signIn.aspx");
        }
    }
}