using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class CourseDetails : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Security Check: Allow BOTH Learners and Guests
            if (Session["UserType"] == null || (Session["UserType"].ToString() != "Learner" && Session["UserType"].ToString() != "Guest"))
            {
                Response.Redirect("signIn.aspx");
                return;
            }

            if (!IsPostBack)
            {
                if (Session["UserType"].ToString() == "Guest")
                {
                    // 1. Hide the progress bar panel
                    pnlEnrolledProgress.Visible = false;

                    // 2. Change the button text to "Enroll"
                    btnCourseAction.Text = "Enroll";

                    // 3. Intercept the click to show the modal
                    btnCourseAction.OnClientClick = "showGuestModal(); return false;";
                }
                else
                {
                    // For logged-in Learners: ensure the progress bar is visible and button text is correct
                    pnlEnrolledProgress.Visible = true;
                    btnCourseAction.Text = "Continue Learning &rarr;";
                }
            }
        }

        protected void btnCourseAction_Click(object sender, EventArgs e)
        {
            // Only logged-in Learners will reach this server-side click event
            Response.Redirect("CourseViewer.aspx");
        }
    }
}