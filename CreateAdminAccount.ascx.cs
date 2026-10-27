using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class CreateAdminAccount : System.Web.UI.UserControl
    {
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        protected void btnSubmitAdmin_Click(object sender, EventArgs e)
        {
            string fullName = txtAdminFullName.Text.Trim();
            string email = txtAdminEmail.Text.Trim();
            string role = ddlAdminRole.SelectedValue;
            string plainPassword = txtAdminPassword.Text.Trim();

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(plainPassword))
            {
                return;
            }

            /* 
             * =========================================================================
             * TODO: Backend Integration - Insert into [dbo].[Admin]
             * =========================================================================
             * 1. Check if email already exists in [dbo].[Admin]:
             *    SELECT COUNT(1) FROM [Admin] WHERE Email = @Email
             * 
             * 2. Hash password with BCrypt (Cost Factor 12):
             *    string passwordHash = BCrypt.Net.BCrypt.HashPassword(plainPassword, 12);
             * 
             * 3. Insert record:
             *    INSERT INTO [dbo].[Admin] (Name, Email, Password, Role)
             *    VALUES (@Name, @Email, @PasswordHash, @Role);
             * 
             * 4. Audit Log (Optional): Record creation in User_Log
             * =========================================================================
             */

            // Refresh the page and show active Admin tab with feedback
            Response.Redirect("AdminUserManagement.aspx?tab=admin&msg=admin_created");
        }
    }
}