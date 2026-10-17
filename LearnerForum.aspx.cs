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

        }

        protected void btnAddPost_Click(object sender, EventArgs e)
        {
            Response.Redirect("LearnerAddPost.aspx");
        }
    }
}