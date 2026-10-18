using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class LearnerDashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // 1. Security Check: Kick out unauthenticated users
            if (Session["UserType"] == null || (Session["UserType"].ToString() != "Learner" && Session["UserType"].ToString() != "Guest"))
            {
                Response.Redirect("signIn.aspx");
                return;
            }

            // 2. Populate Data on initial load
            if (!IsPostBack)
            {
                string fullName = Session["UserName"].ToString();

                litWelcomeName.Text = fullName;

                // 3. Guest Mode Logic
                if (Session["UserType"].ToString() == "Guest")
                {
                    phLearnerData.Visible = false; // Hides stats and continue learning
                    litGreetingDesc.Text = "Explore our course catalog to find your next skill. Create a free account to track your progress!";
                    recommendationHeader.InnerText = "Explore Our Courses";
                }
                else
                {
                    // Future-proofing for when you pull real stats from the database
                    litGreetingDesc.Text = "You have 2 active courses. Keep up the momentum!";
                }
            }
        }
    }
}