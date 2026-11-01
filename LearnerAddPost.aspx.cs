using System;
using System.Configuration;
using System.Data.SqlClient;

namespace Codercept
{
    public partial class LearnerAddPost : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["Codercept_db"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserType"] == null || Session["UserType"].ToString() != "Learner")
            {
                Response.Redirect("LandingPage.aspx");
                return;
            }
        }

        protected void btnPublishPost_Click(object sender, EventArgs e)
        {
            // Enforce that all client/server validation checks passed successfully
            if (!Page.IsValid)
            {
                return;
            }

            int learnerId = Convert.ToInt32(Session["UserId"]);
            string title = txtPostTitle.Text.Trim();
            string content = txtPostDesc.Text.Trim();

            // Clean tags and store them as comma-separated values
            string rawTags = txtPostTags.Text;
            string formattedTags = "";
            if (!string.IsNullOrWhiteSpace(rawTags))
            {
                var tagsList = rawTags.Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
                for (int i = 0; i < tagsList.Length; i++)
                {
                    formattedTags += tagsList[i].Trim().Replace("#", "");
                    if (i < tagsList.Length - 1) formattedTags += ",";
                }
            }

            int newPostId = 0;

            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = @"
                    INSERT INTO Forum (Title, Content, DatePosted, LearnerId, Tags, IsFlagged, IsHidden) 
                    OUTPUT INSERTED.PostId
                    VALUES (@Title, @Content, GETDATE(), @LearnerId, @Tags, 0, 0)";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@Title", title);
                    cmd.Parameters.AddWithValue("@Content", content);
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    cmd.Parameters.AddWithValue("@Tags", formattedTags);

                    con.Open();
                    newPostId = (int)cmd.ExecuteScalar();
                    con.Close();
                }
            }

            // Store ID in Session so the main Forum page can highlight it immediately
            Session["NewPostId"] = newPostId;
            Response.Redirect("LearnerForum.aspx");
        }
    }
}