using System;
using System.Collections.Generic;

namespace Codercept
{
    public partial class TAProfile : System.Web.UI.Page
    {
        // 1. Define Dummy Data Structures
        public class DummyQualification
        {
            public string Name { get; set; }
            public string Date { get; set; }
            public string DocumentUrl { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Security Check
            if (Session["UserType"] == null || Session["UserType"].ToString() != "TA")
            {
                Response.Redirect("signIn.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadProfileData();
            }
        }

        private void LoadProfileData()
        {
            // 2. Generate Dummy Data
            txtName.Text = Session["UserName"] != null ? Session["UserName"].ToString() : "";
            txtEmail.Text = Session["UserEmail"] != null ? Session["UserEmail"].ToString() : "";
            txtRegion.Text = "Kuala Lumpur, Malaysia";
            ddlTeachingLevel.SelectedValue = "Beginner";
            txtStatus.Text = "Active";

            var qualifications = new List<DummyQualification>
            {
                new DummyQualification { Name = "BSc (Hons) Computer Science", Date = "June 30, 2023", DocumentUrl = "#" },
                new DummyQualification { Name = "Oracle Certified Associate, Java SE Programmer", Date = "February 15, 2024", DocumentUrl = "#" },
                new DummyQualification { Name = "PCEP - Certified Entry-Level Python Programmer", Date = "August 10, 2024", DocumentUrl = "#" }
            };

            phQualEmpty.Visible = qualifications.Count == 0;
            rptQualifications.DataSource = qualifications;
            rptQualifications.DataBind();

            // 3. Activity stats (hardcoded for the dummy view)
            litStatGraded.Text = "142";
            litStatModerated.Text = "37";
            litStatReplies.Text = "89";
        }

        protected void btnUpdateProfile_Click(object sender, EventArgs e)
        {
            // We will implement this later
            litMessage.Text = "Details updated. (Preview only — saving will be implemented with the backend.)";
            pnlMessage.Visible = true;
        }
    }
}
