using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class LearnerForum : System.Web.UI.Page
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
                // Your normal page loading logic goes here
            }
        }

        protected void btnAddPost_Click(object sender, EventArgs e)
        {
            Response.Redirect("LearnerAddPost.aspx");
        }
    }
}