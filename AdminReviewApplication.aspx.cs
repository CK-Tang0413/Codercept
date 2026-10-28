using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using BCrypt.Net;

namespace Codercept
{
    public partial class AdminReviewApplication : System.Web.UI.Page
    {
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["Codercept_db"]?.ConnectionString 
            ?? ConfigurationManager.ConnectionStrings["CoderceptDB"]?.ConnectionString;

        protected string CurrentUserId = "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string userId = Request.QueryString["userId"];
                string role = Request.QueryString["role"];

                if (!string.IsNullOrEmpty(userId))
                {
                    CurrentUserId = userId;
                    LoadApplicantDetails(userId, role);
                }
            }
        }

        private void LoadApplicantDetails(string userIdStr, string roleStr)
        {
            if (string.IsNullOrEmpty(userIdStr) || string.IsNullOrEmpty(connectionString)) return;

            if (!int.TryParse(userIdStr, out int userId)) return;

            string roleCategory = roleStr?.Trim().ToLower() ?? "";

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string fullName = "";
                    string email = "";
                    string role = "";
                    string qualificationName = "";
                    string credentialDoc = "";
                    string teachingLevel = "";
                    string region = "";
                    DateTime appliedDate = DateTime.Now;
                    int applicationId = 0;
                    int actualTeacherId = 0;
                    int actualTaId = 0;

                    bool found = false;

                    // 1. Try finding by Teacher
                    if (roleCategory == "teacher" || string.IsNullOrEmpty(roleCategory))
                    {
                        string query = @"
                            SELECT 
                                t.TeacherId,
                                t.Name, 
                                t.Email, 
                                'Teacher' AS Role, 
                                ISNULL(t.QualificationName, a.QualificationName) AS QualificationName,
                                ISNULL(t.QualificationDocument, a.CredentialDocument) AS CredentialDocument,
                                t.TeachingLevel,
                                t.Region,
                                ISNULL(a.DateSubmitted, t.DateJoined) AS AppliedDate,
                                ISNULL(a.ApplicationId, 0) AS ApplicationId
                            FROM [dbo].[Teacher] t
                            LEFT JOIN [dbo].[Application] a ON t.ApplicationId = a.ApplicationId
                            WHERE t.TeacherId = @Id";

                        using (SqlCommand cmd = new SqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@Id", userId);
                            using (SqlDataReader r = cmd.ExecuteReader())
                            {
                                if (r.Read())
                                {
                                    found = true;
                                    actualTeacherId = r.GetInt32(0);
                                    fullName = r["Name"]?.ToString() ?? "";
                                    email = r["Email"]?.ToString() ?? "";
                                    role = "Teacher";
                                    roleCategory = "teacher";
                                    qualificationName = r["QualificationName"]?.ToString() ?? "";
                                    credentialDoc = r["CredentialDocument"]?.ToString() ?? "";
                                    teachingLevel = r["TeachingLevel"]?.ToString() ?? "";
                                    region = r["Region"]?.ToString() ?? "";
                                    if (r["AppliedDate"] != DBNull.Value) appliedDate = Convert.ToDateTime(r["AppliedDate"]);
                                    applicationId = Convert.ToInt32(r["ApplicationId"]);
                                }
                            }
                        }
                    }

                    // 2. Try finding by Teaching Assistant
                    if (!found && (roleCategory == "assistant" || roleCategory == "ta" || roleCategory == "teaching assistant" || string.IsNullOrEmpty(roleCategory)))
                    {
                        string query = @"
                            SELECT 
                                ta.TA_Id,
                                ta.Name, 
                                ta.Email, 
                                'Teaching Assistant' AS Role, 
                                ISNULL(ta.QualificationName, a.QualificationName) AS QualificationName,
                                ISNULL(ta.QualificationDocument, a.CredentialDocument) AS CredentialDocument,
                                ta.TeachingLevel,
                                ta.Region,
                                ISNULL(a.DateSubmitted, ta.DateJoined) AS AppliedDate,
                                ISNULL(a.ApplicationId, 0) AS ApplicationId
                            FROM [dbo].[Teaching_Assistant] ta
                            LEFT JOIN [dbo].[Application] a ON ta.ApplicationId = a.ApplicationId
                            WHERE ta.TA_Id = @Id";

                        using (SqlCommand cmd = new SqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@Id", userId);
                            using (SqlDataReader r = cmd.ExecuteReader())
                            {
                                if (r.Read())
                                {
                                    found = true;
                                    actualTaId = r.GetInt32(0);
                                    fullName = r["Name"]?.ToString() ?? "";
                                    email = r["Email"]?.ToString() ?? "";
                                    role = "Teaching Assistant";
                                    roleCategory = "assistant";
                                    qualificationName = r["QualificationName"]?.ToString() ?? "";
                                    credentialDoc = r["CredentialDocument"]?.ToString() ?? "";
                                    teachingLevel = r["TeachingLevel"]?.ToString() ?? "";
                                    region = r["Region"]?.ToString() ?? "";
                                    if (r["AppliedDate"] != DBNull.Value) appliedDate = Convert.ToDateTime(r["AppliedDate"]);
                                    applicationId = Convert.ToInt32(r["ApplicationId"]);
                                }
                            }
                        }
                    }

                    // 3. Try finding directly by ApplicationId
                    if (!found)
                    {
                        string query = @"
                            SELECT 
                                a.ApplicationId,
                                a.RoleApplied,
                                a.QualificationName,
                                a.CredentialDocument,
                                a.DateSubmitted,
                                ISNULL(t.TeacherId, 0) AS TeacherId,
                                ISNULL(ta.TA_Id, 0) AS TA_Id,
                                ISNULL(t.Name, ISNULL(ta.Name, 'Applicant #' + CAST(a.ApplicationId AS VARCHAR))) AS Name,
                                ISNULL(t.Email, ISNULL(ta.Email, 'N/A')) AS Email,
                                ISNULL(t.TeachingLevel, ISNULL(ta.TeachingLevel, '')) AS TeachingLevel,
                                ISNULL(t.Region, ISNULL(ta.Region, '')) AS Region
                            FROM [dbo].[Application] a
                            LEFT JOIN [dbo].[Teacher] t ON t.ApplicationId = a.ApplicationId
                            LEFT JOIN [dbo].[Teaching_Assistant] ta ON ta.ApplicationId = a.ApplicationId
                            WHERE a.ApplicationId = @Id";

                        using (SqlCommand cmd = new SqlCommand(query, conn))
                        {
                            cmd.Parameters.AddWithValue("@Id", userId);
                            using (SqlDataReader r = cmd.ExecuteReader())
                            {
                                if (r.Read())
                                {
                                    found = true;
                                    applicationId = r.GetInt32(0);
                                    role = r["RoleApplied"]?.ToString() ?? "Teacher";
                                    roleCategory = role.Equals("Teacher", StringComparison.OrdinalIgnoreCase) ? "teacher" : "assistant";
                                    qualificationName = r["QualificationName"]?.ToString() ?? "";
                                    credentialDoc = r["CredentialDocument"]?.ToString() ?? "";
                                    if (r["DateSubmitted"] != DBNull.Value) appliedDate = Convert.ToDateTime(r["DateSubmitted"]);
                                    actualTeacherId = Convert.ToInt32(r["TeacherId"]);
                                    actualTaId = Convert.ToInt32(r["TA_Id"]);
                                    fullName = r["Name"]?.ToString() ?? "";
                                    email = r["Email"]?.ToString() ?? "";
                                    teachingLevel = r["TeachingLevel"]?.ToString() ?? "";
                                    region = r["Region"]?.ToString() ?? "";
                                }
                            }
                        }
                    }

                    if (!found) return;

                    // Fetch subjects (languages & domain specialization)
                    List<string> languages = new List<string>();
                    List<string> domains = new List<string>();

                    string subjectQuery = @"
                        SELECT s.SubjectName, s.SubjectType
                        FROM [dbo].[EducatorSubject] es
                        JOIN [dbo].[Subject] s ON es.SubjectId = s.SubjectId
                        WHERE (es.TeacherId = @TId AND @TId > 0)
                           OR (es.TA_Id = @TaId AND @TaId > 0)";

                    using (SqlCommand cmd = new SqlCommand(subjectQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@TId", actualTeacherId);
                        cmd.Parameters.AddWithValue("@TaId", actualTaId);
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            while (r.Read())
                            {
                                string subName = r["SubjectName"]?.ToString();
                                string subType = r["SubjectType"]?.ToString();
                                if (subType.Equals("Language", StringComparison.OrdinalIgnoreCase))
                                {
                                    languages.Add(subName);
                                }
                                else
                                {
                                    domains.Add(subName);
                                }
                            }
                        }
                    }

                    // Populate UI Controls
                    litFullName.Text = HttpUtility.HtmlEncode(fullName);
                    litEmail.Text = HttpUtility.HtmlEncode(email);
                    litAvatarInitials.Text = GetInitials(fullName);
                    litRoleBadge.Text = roleCategory == "teacher" 
                        ? "<span class='role-badge badge-teacher'>Teacher Applicant</span>" 
                        : "<span class='role-badge badge-ta'>Teaching Assistant Applicant</span>";
                    litAppliedDate.Text = $"Applied on {appliedDate:yyyy-MM-dd}";
                    litAppliedRole.Text = HttpUtility.HtmlEncode(role);
                    litQualificationName.Text = !string.IsNullOrWhiteSpace(qualificationName) ? HttpUtility.HtmlEncode(qualificationName) : "Not Specified";

                    // Specialization
                    string specializationText = domains.Count > 0 
                        ? string.Join(", ", domains) 
                        : (!string.IsNullOrWhiteSpace(teachingLevel) ? $"{teachingLevel} Level Specialization" : "Computer Science & Programming");
                    litSpecialization.Text = HttpUtility.HtmlEncode(specializationText);

                    // Programming languages
                    if (languages.Count > 0)
                    {
                        StringBuilder sb = new StringBuilder();
                        foreach (string lang in languages)
                        {
                            sb.Append($"<span class='lang-chip highlight'>{HttpUtility.HtmlEncode(lang)}</span> ");
                        }
                        litLanguages.Text = sb.ToString();
                    }
                    else
                    {
                        litLanguages.Text = "<span class='lang-chip'>General Programming</span>";
                    }

                    // Verification documents
                    if (!string.IsNullOrWhiteSpace(credentialDoc))
                    {
                        string resolvedUrl = ResolveUrl(credentialDoc);
                        string fileName = System.IO.Path.GetFileName(credentialDoc);
                        if (string.IsNullOrWhiteSpace(fileName)) fileName = "Credential Document";
                        string ext = System.IO.Path.GetExtension(credentialDoc).TrimStart('.').ToLower();
                        string iconClass = "fa-file-pdf";
                        if (new[] { "png", "jpg", "jpeg", "webp", "gif" }.Contains(ext)) iconClass = "fa-file-image";
                        else if (new[] { "doc", "docx" }.Contains(ext)) iconClass = "fa-file-word";

                        litDocuments.Text = $@"
                            <div class='doc-item'>
                                <div class='doc-left'>
                                    <div class='doc-icon'><i class='fa-solid {iconClass}'></i></div>
                                    <div class='doc-meta'>
                                        <h5>{HttpUtility.HtmlEncode(fileName)}</h5>
                                        <p>{ext.ToUpper()} &bull; Attached Document</p>
                                    </div>
                                </div>
                                <button type='button' class='btn-view-doc' onclick=""openDocModal('{HttpUtility.JavaScriptStringEncode(fileName)}', '{HttpUtility.JavaScriptStringEncode(resolvedUrl)}')"" title='Preview Document'>
                                    <i class='fa-solid fa-eye'></i> View
                                </button>
                            </div>";
                    }
                    else
                    {
                        litDocuments.Text = "<div style='color: var(--text-secondary); font-size: 13px; padding: 12px 0;'><i class='fa-solid fa-circle-info'></i> No verification document uploaded.</div>";
                    }

                    // Save state in hidden fields for action postbacks
                    hfApplicantUserId.Value = (roleCategory == "teacher" ? actualTeacherId : actualTaId).ToString();
                    hfApplicantRole.Value = roleCategory;
                    hfApplicationId.Value = applicationId.ToString();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[AdminReviewApplication Load Error]: {ex.Message}");
            }
        }

        protected void btnApproveApplication_Click(object sender, EventArgs e)
        {
            int.TryParse(hfApplicantUserId.Value, out int userId);
            string roleCategory = hfApplicantRole.Value?.ToLower();
            int.TryParse(hfApplicationId.Value, out int appId);
            string optionalNotes = txtAdminRemarks.Text.Trim();

            if (!string.IsNullOrEmpty(connectionString))
            {
                try
                {
                    string recipientName = "";
                    string recipientEmail = "";
                    string predefinedPassword = "";

                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        conn.Open();
                        using (SqlTransaction tx = conn.BeginTransaction())
                        {
                            try
                            {
                                // Retrieve applicant Name and Email from database for 100% accuracy
                                string selectQuery = (roleCategory == "teacher")
                                    ? "SELECT Name, Email FROM [dbo].[Teacher] WHERE TeacherId = @Id"
                                    : "SELECT Name, Email FROM [dbo].[Teaching_Assistant] WHERE TA_Id = @Id";

                                using (SqlCommand selectCmd = new SqlCommand(selectQuery, conn, tx))
                                {
                                    selectCmd.Parameters.AddWithValue("@Id", userId);
                                    using (SqlDataReader r = selectCmd.ExecuteReader())
                                    {
                                        if (r.Read())
                                        {
                                            recipientName = r["Name"]?.ToString() ?? "";
                                            recipientEmail = r["Email"]?.ToString() ?? "";
                                        }
                                    }
                                }

                                if (string.IsNullOrWhiteSpace(recipientName))
                                {
                                    recipientName = HttpUtility.HtmlDecode(litFullName.Text)?.Trim() ?? "Educator";
                                }
                                if (string.IsNullOrWhiteSpace(recipientEmail))
                                {
                                    recipientEmail = litEmail.Text?.Trim() ?? "";
                                }

                                // Derive predefined password: <userfirstname> + alias + 1234
                                // Format: <userFirstName>@1234 (alias symbol '@') matching CreateAdminAccount
                                string[] nameParts = recipientName.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                                string firstName = nameParts.Length > 0 ? nameParts[0] : (roleCategory == "teacher" ? "Teacher" : "Educator");
                                predefinedPassword = $"{firstName}@1234";

                                // Hash predefined password with BCrypt (Cost Factor 12)
                                string hashedPassword = BCrypt.Net.BCrypt.HashPassword(predefinedPassword, 12);

                                // 1. Update Application table
                                if (appId > 0)
                                {
                                    string appQuery = "UPDATE [dbo].[Application] SET ApprovalStatus = 'Approved', DateReviewed = GETDATE() WHERE ApplicationId = @appId";
                                    using (SqlCommand cmd = new SqlCommand(appQuery, conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@appId", appId);
                                        cmd.ExecuteNonQuery();
                                    }
                                }

                                // 2. Update Teacher or Teaching_Assistant table with Active status and hashed predefined password
                                if (roleCategory == "teacher" && userId > 0)
                                {
                                    string tQuery = "UPDATE [dbo].[Teacher] SET AccStatus = 'Active', Password = @Password WHERE TeacherId = @id";
                                    using (SqlCommand cmd = new SqlCommand(tQuery, conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@Password", hashedPassword);
                                        cmd.Parameters.AddWithValue("@id", userId);
                                        cmd.ExecuteNonQuery();
                                    }
                                }
                                else if (roleCategory == "assistant" && userId > 0)
                                {
                                    string taQuery = "UPDATE [dbo].[Teaching_Assistant] SET AccStatus = 'Active', Password = @Password WHERE TA_Id = @id";
                                    using (SqlCommand cmd = new SqlCommand(taQuery, conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@Password", hashedPassword);
                                        cmd.Parameters.AddWithValue("@id", userId);
                                        cmd.ExecuteNonQuery();
                                    }
                                }

                                tx.Commit();
                            }
                            catch (Exception)
                            {
                                tx.Rollback();
                                throw;
                            }
                        }
                    }

                    // Send approval announcement email with predefined password
                    SendApplicationDecisionEmail(recipientEmail, recipientName, isApproved: true, remarks: optionalNotes, temporaryPassword: predefinedPassword);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[Approve Application Error]: {ex.Message}");
                }
            }

            Response.Redirect("AdminUserManagement.aspx?tab=pending&msg=application_approved");
        }

        protected void btnRejectApplication_Click(object sender, EventArgs e)
        {
            int.TryParse(hfApplicantUserId.Value, out int userId);
            string roleCategory = hfApplicantRole.Value?.ToLower();
            int.TryParse(hfApplicationId.Value, out int appId);
            string rejectionReason = txtAdminRemarks.Text.Trim();

            if (!string.IsNullOrEmpty(connectionString))
            {
                try
                {
                    string recipientName = "";
                    string recipientEmail = "";

                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        conn.Open();
                        using (SqlTransaction tx = conn.BeginTransaction())
                        {
                            try
                            {
                                // Retrieve applicant Name and Email for email notification
                                string selectQuery = (roleCategory == "teacher")
                                    ? "SELECT Name, Email FROM [dbo].[Teacher] WHERE TeacherId = @Id"
                                    : "SELECT Name, Email FROM [dbo].[Teaching_Assistant] WHERE TA_Id = @Id";

                                using (SqlCommand selectCmd = new SqlCommand(selectQuery, conn, tx))
                                {
                                    selectCmd.Parameters.AddWithValue("@Id", userId);
                                    using (SqlDataReader r = selectCmd.ExecuteReader())
                                    {
                                        if (r.Read())
                                        {
                                            recipientName = r["Name"]?.ToString() ?? "";
                                            recipientEmail = r["Email"]?.ToString() ?? "";
                                        }
                                    }
                                }

                                // 1. Update Application table
                                if (appId > 0)
                                {
                                    string appQuery = "UPDATE [dbo].[Application] SET ApprovalStatus = 'Rejected', RejectReason = @reason, DateReviewed = GETDATE() WHERE ApplicationId = @appId";
                                    using (SqlCommand cmd = new SqlCommand(appQuery, conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@reason", rejectionReason);
                                        cmd.Parameters.AddWithValue("@appId", appId);
                                        cmd.ExecuteNonQuery();
                                    }
                                }

                                // 2. Update Teacher or Teaching_Assistant table
                                if (roleCategory == "teacher" && userId > 0)
                                {
                                    string tQuery = "UPDATE [dbo].[Teacher] SET AccStatus = 'Rejected' WHERE TeacherId = @id";
                                    using (SqlCommand cmd = new SqlCommand(tQuery, conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@id", userId);
                                        cmd.ExecuteNonQuery();
                                    }
                                }
                                else if (roleCategory == "assistant" && userId > 0)
                                {
                                    string taQuery = "UPDATE [dbo].[Teaching_Assistant] SET AccStatus = 'Rejected' WHERE TA_Id = @id";
                                    using (SqlCommand cmd = new SqlCommand(taQuery, conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@id", userId);
                                        cmd.ExecuteNonQuery();
                                    }
                                }

                                tx.Commit();
                            }
                            catch (Exception)
                            {
                                tx.Rollback();
                                throw;
                            }
                        }
                    }

                    if (string.IsNullOrWhiteSpace(recipientName)) recipientName = HttpUtility.HtmlDecode(litFullName.Text)?.Trim() ?? "Educator";
                    if (string.IsNullOrWhiteSpace(recipientEmail)) recipientEmail = litEmail.Text?.Trim() ?? "";

                    // Send rejection announcement email
                    SendApplicationDecisionEmail(recipientEmail, recipientName, isApproved: false, remarks: rejectionReason);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[Reject Application Error]: {ex.Message}");
                }
            }

            Response.Redirect("AdminUserManagement.aspx?tab=pending&msg=application_rejected");
        }

        private void SendApplicationDecisionEmail(string email, string fullName, bool isApproved, string remarks, string temporaryPassword = null)
        {
            try
            {
                string senderEmail = ConfigurationManager.AppSettings["SenderEmail"];
                string senderAppPassword = ConfigurationManager.AppSettings["SenderAppPassword"];

                if (string.IsNullOrEmpty(senderEmail) || string.IsNullOrEmpty(senderAppPassword) || string.IsNullOrEmpty(email))
                {
                    System.Diagnostics.Debug.WriteLine("[AdminReviewApplication SendEmail]: SenderEmail or SenderAppPassword not configured.");
                    return;
                }

                MailMessage mail = new MailMessage();
                mail.From = new MailAddress(senderEmail, "Codercept Team");
                mail.To.Add(email);
                mail.Subject = isApproved ? "Codercept - Educator Application Approved" : "Codercept - Educator Application Status Update";

                string bodyContent;
                if (isApproved)
                {
                    bodyContent = $@"
                        <h2 style='color: #6366f1; margin-top: 0;'>Welcome to Codercept!</h2>
                        <p>Hello <strong>{HttpUtility.HtmlEncode(fullName)}</strong>,</p>
                        <p>Congratulations! Your educator application for Codercept has been approved. Your account is now active and you can log in to begin teaching on the platform.</p>
                        <div style='background-color: #f8fafc; border: 1px solid #e2e8f0; border-left: 4px solid #6366f1; padding: 16px; border-radius: 6px; margin: 20px 0;'>
                            <p style='margin: 0 0 8px 0;'><strong>Login Email:</strong> {HttpUtility.HtmlEncode(email)}</p>
                            <p style='margin: 0;'><strong>Predefined Password:</strong> <code style='font-size: 16px; font-weight: bold; color: #6366f1;'>{HttpUtility.HtmlEncode(temporaryPassword)}</code></p>
                        </div>
                        <p>You can use this predefined password to log in to your account. For security purposes, please change your password after logging in.</p>";

                    if (!string.IsNullOrWhiteSpace(remarks))
                    {
                        bodyContent += $@"
                        <div style='background-color: #f0fdf4; border: 1px solid #bbf7d0; border-left: 4px solid #10b981; padding: 12px; margin: 16px 0; border-radius: 6px;'>
                            <strong>Review Notes:</strong><br/>
                            {HttpUtility.HtmlEncode(remarks)}
                        </div>";
                    }
                }
                else
                {
                    bodyContent = $@"
                        <h2 style='color: #ef4444; margin-top: 0;'>Application Review Update</h2>
                        <p>Hello <strong>{HttpUtility.HtmlEncode(fullName)}</strong>,</p>
                        <p>Thank you for your interest in joining the Codercept educator community. Following our evaluation of your submitted credentials, we regret to inform you that your application has not been approved at this time.</p>
                        <div style='background-color: #fef2f2; border: 1px solid #fecaca; border-left: 4px solid #ef4444; padding: 12px; margin: 16px 0; border-radius: 6px;'>
                            <strong>Feedback from Review Team:</strong><br/>
                            {HttpUtility.HtmlEncode(remarks)}
                        </div>";
                }

                mail.Body = $@"
                    <div style='font-family: Arial, sans-serif; padding: 24px; color: #1e293b; line-height: 1.6; max-width: 600px; border: 1px solid #e2e8f0; border-radius: 8px;'>
                        {bodyContent}
                        <p style='margin-top: 24px;'>Best regards,<br/><strong>The Codercept Team</strong></p>
                    </div>";
                mail.IsBodyHtml = true;

                SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587);
                smtp.Credentials = new NetworkCredential(senderEmail, senderAppPassword);
                smtp.EnableSsl = true;
                smtp.Send(mail);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[SendApplicationDecisionEmail Error]: {ex.Message}");
            }
        }

        private string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "U";
            string[] parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Substring(0, Math.Min(2, parts[0].Length)).ToUpper();
            return (parts[0][0].ToString() + parts[parts.Length - 1][0].ToString()).ToUpper();
        }
    }
}
