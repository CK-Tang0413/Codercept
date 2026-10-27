using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Codercept
    {
        public partial class AdminReviewApplication : System.Web.UI.Page
        {
            protected string CurrentUserId = "USR_003"; // Default fallback ID

            protected void Page_Load(object sender, EventArgs e)
            {
                if (!IsPostBack)
                {
                    if (!string.IsNullOrEmpty(Request.QueryString["userId"]))
                    {
                        CurrentUserId = Request.QueryString["userId"];
                    }

                    /* 
                     * TODO: Backend Integration - Load Applicant Profile
                     * Example:
                     * var applicant = UserRepository.GetById(CurrentUserId);
                     * litFullName.Text = applicant.FullName;
                     * litEmail.Text = applicant.Email;
                     * ...
                     */
                }
            }

            protected void btnApproveApplication_Click(object sender, EventArgs e)
            {
                string optionalNotes = txtAdminRemarks.Text.Trim();

                /* 
                 * TODO: Backend Integration - Approve Application
                 * 1. Update Database record:
                 *    - Application.Status = "Approved"
                 *    - User.Status = "Active"
                 *    - User.ApprovedDate = DateTime.UtcNow
                 *    - User.AdminRemarks = optionalNotes
                 * 
                 * 2. Send approval email with login credentials/link to applicant
                 */

                // Redirect back to User Management, passing approvedUserId to switch status pill to Active
                Response.Redirect($"AdminUserManagement.aspx?approvedUserId={CurrentUserId}");
            }

            protected void btnRejectApplication_Click(object sender, EventArgs e)
            {
                string rejectionReason = txtAdminRemarks.Text.Trim();

                /* 
                 * TODO: Backend Integration - Reject Application
                 * 1. Update Database record:
                 *    - Application.Status = "Rejected"
                 *    - Application.RejectionReason = rejectionReason
                 *    - Application.ReviewedDate = DateTime.UtcNow
                 * 
                 * 2. Send rejection notification email containing 'rejectionReason' to candidate
                 */

                Response.Redirect("AdminUserManagement.aspx?msg=rejected");
            }
        }
}