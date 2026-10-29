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
                                COALESCE(NULLIF(t.QualificationName, ''), NULLIF(a.QualificationName, '')) AS QualificationName,
                                COALESCE(NULLIF(t.QualificationDocument, ''), NULLIF(a.CredentialDocument, '')) AS CredentialDocument,
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
                                COALESCE(NULLIF(ta.QualificationName, ''), NULLIF(a.QualificationName, '')) AS QualificationName,
                                COALESCE(NULLIF(ta.QualificationDocument, ''), NULLIF(a.CredentialDocument, '')) AS CredentialDocument,
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
                        string cleanDoc = credentialDoc.Trim().Replace("\\", "/");
                        string resolvedUrl;

                        if (cleanDoc.StartsWith("http://", StringComparison.OrdinalIgnoreCase) || cleanDoc.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
                        {
                            resolvedUrl = cleanDoc;
                        }
                        else if (cleanDoc.StartsWith("~/") || cleanDoc.StartsWith("/"))
                        {
                            resolvedUrl = ResolveUrl(cleanDoc);
                        }
                        else if (cleanDoc.StartsWith("media/", StringComparison.OrdinalIgnoreCase) || cleanDoc.StartsWith("UploadedCertificates/", StringComparison.OrdinalIgnoreCase))
                        {
                            resolvedUrl = ResolveUrl("~/" + cleanDoc);
                        }
                        else
                        {
                            string qualPath = Server.MapPath("~/media/uploads/qualifications/" + cleanDoc);
                            if (System.IO.File.Exists(qualPath))
                            {
                                resolvedUrl = ResolveUrl("~/media/uploads/qualifications/" + cleanDoc);
                            }
                            else
                            {
                                string certPath = Server.MapPath("~/UploadedCertificates/" + cleanDoc);
                                if (System.IO.File.Exists(certPath))
                                {
                                    resolvedUrl = ResolveUrl("~/UploadedCertificates/" + cleanDoc);
                                }
                                else
                                {
                                    resolvedUrl = ResolveUrl("~/media/uploads/qualifications/" + cleanDoc);
                                }
                            }
                        }
                        string fileName = System.IO.Path.GetFileName(cleanDoc);
                        if (string.IsNullOrWhiteSpace(fileName)) fileName = "Credential Document";
                        string ext = System.IO.Path.GetExtension(cleanDoc).TrimStart('.').ToLower();
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
                    hfApplicantName.Value = fullName;
                    hfApplicantEmail.Value = email;
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
            string roleCategory = hfApplicantRole.Value?.Trim().ToLower() ?? "";
            int.TryParse(hfApplicationId.Value, out int appId);
            string optionalNotes = txtAdminRemarks.Text.Trim();
            string recipientName = hfApplicantName.Value?.Trim() ?? "";
            string recipientEmail = hfApplicantEmail.Value?.Trim() ?? "";
            string roleTitle = roleCategory == "teacher" ? "Teacher" : "Teaching Assistant";

            if (!string.IsNullOrEmpty(connectionString))
            {
                try
                {
                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        conn.Open();
                        using (SqlTransaction tx = conn.BeginTransaction())
                        {
                            try
                            {
                                string appQualName = "";
                                string appQualDoc = "";

                                // 1. Retrieve QualificationName and CredentialDocument from Application table
                                if (appId > 0)
                                {
                                    string appSelectQuery = "SELECT QualificationName, CredentialDocument, RoleApplied FROM [dbo].[Application] WHERE ApplicationId = @appId";
                                    using (SqlCommand appSelectCmd = new SqlCommand(appSelectQuery, conn, tx))
                                    {
                                        appSelectCmd.Parameters.AddWithValue("@appId", appId);
                                        using (SqlDataReader ar = appSelectCmd.ExecuteReader())
                                        {
                                            if (ar.Read())
                                            {
                                                appQualName = ar["QualificationName"] != DBNull.Value ? ar["QualificationName"].ToString() : "";
                                                appQualDoc = ar["CredentialDocument"] != DBNull.Value ? ar["CredentialDocument"].ToString() : "";
                                                if (string.IsNullOrEmpty(roleCategory))
                                                {
                                                    string roleApplied = ar["RoleApplied"]?.ToString() ?? "";
                                                    roleCategory = roleApplied.IndexOf("Assistant", StringComparison.OrdinalIgnoreCase) >= 0 ? "assistant" : "teacher";
                                                }
                                            }
                                        }
                                    }
                                }

                                // If appId was 0 or not linked, attempt to find ApplicationId from Teacher / Teaching_Assistant table
                                if (appId <= 0 && userId > 0)
                                {
                                    string findAppSql = (roleCategory == "teacher")
                                        ? "SELECT ApplicationId, QualificationName, QualificationDocument FROM [dbo].[Teacher] WHERE TeacherId = @Id"
                                        : "SELECT ApplicationId, QualificationName, QualificationDocument FROM [dbo].[Teaching_Assistant] WHERE TA_Id = @Id";
                                    using (SqlCommand findAppCmd = new SqlCommand(findAppSql, conn, tx))
                                    {
                                        findAppCmd.Parameters.AddWithValue("@Id", userId);
                                        using (SqlDataReader far = findAppCmd.ExecuteReader())
                                        {
                                            if (far.Read())
                                            {
                                                if (far["ApplicationId"] != DBNull.Value)
                                                    appId = Convert.ToInt32(far["ApplicationId"]);
                                                if (string.IsNullOrEmpty(appQualName) && far["QualificationName"] != DBNull.Value)
                                                    appQualName = far["QualificationName"].ToString();
                                                if (string.IsNullOrEmpty(appQualDoc) && far["QualificationDocument"] != DBNull.Value)
                                                    appQualDoc = far["QualificationDocument"].ToString();
                                            }
                                        }
                                    }

                                    if (appId > 0 && (string.IsNullOrEmpty(appQualName) || string.IsNullOrEmpty(appQualDoc)))
                                    {
                                        string appSelectQuery = "SELECT QualificationName, CredentialDocument FROM [dbo].[Application] WHERE ApplicationId = @appId";
                                        using (SqlCommand appSelectCmd = new SqlCommand(appSelectQuery, conn, tx))
                                        {
                                            appSelectCmd.Parameters.AddWithValue("@appId", appId);
                                            using (SqlDataReader ar = appSelectCmd.ExecuteReader())
                                            {
                                                if (ar.Read())
                                                {
                                                    if (string.IsNullOrEmpty(appQualName) && ar["QualificationName"] != DBNull.Value)
                                                        appQualName = ar["QualificationName"].ToString();
                                                    if (string.IsNullOrEmpty(appQualDoc) && ar["CredentialDocument"] != DBNull.Value)
                                                        appQualDoc = ar["CredentialDocument"].ToString();
                                                }
                                            }
                                        }
                                    }
                                }

                                // If userId was 0, resolve user by ApplicationId
                                if (userId <= 0 && appId > 0)
                                {
                                    if (roleCategory == "teacher" || string.IsNullOrEmpty(roleCategory))
                                    {
                                        using (SqlCommand cmd = new SqlCommand("SELECT TeacherId, Name, Email FROM [dbo].[Teacher] WHERE ApplicationId = @appId", conn, tx))
                                        {
                                            cmd.Parameters.AddWithValue("@appId", appId);
                                            using (SqlDataReader r = cmd.ExecuteReader())
                                            {
                                                if (r.Read())
                                                {
                                                    userId = Convert.ToInt32(r["TeacherId"]);
                                                    roleCategory = "teacher";
                                                    if (string.IsNullOrEmpty(recipientName)) recipientName = r["Name"]?.ToString() ?? "";
                                                    if (string.IsNullOrEmpty(recipientEmail)) recipientEmail = r["Email"]?.ToString() ?? "";
                                                }
                                            }
                                        }
                                    }

                                    if (userId <= 0 && (roleCategory == "assistant" || string.IsNullOrEmpty(roleCategory)))
                                    {
                                        using (SqlCommand cmd = new SqlCommand("SELECT TA_Id, Name, Email FROM [dbo].[Teaching_Assistant] WHERE ApplicationId = @appId", conn, tx))
                                        {
                                            cmd.Parameters.AddWithValue("@appId", appId);
                                            using (SqlDataReader r = cmd.ExecuteReader())
                                            {
                                                if (r.Read())
                                                {
                                                    userId = Convert.ToInt32(r["TA_Id"]);
                                                    roleCategory = "assistant";
                                                    if (string.IsNullOrEmpty(recipientName)) recipientName = r["Name"]?.ToString() ?? "";
                                                    if (string.IsNullOrEmpty(recipientEmail)) recipientEmail = r["Email"]?.ToString() ?? "";
                                                }
                                            }
                                        }
                                    }
                                }

                                // Retrieve applicant Name and Email from database for accuracy if not yet resolved
                                if (userId > 0 && (string.IsNullOrEmpty(recipientName) || string.IsNullOrEmpty(recipientEmail)))
                                {
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
                                                if (string.IsNullOrEmpty(recipientName)) recipientName = r["Name"]?.ToString() ?? "";
                                                if (string.IsNullOrEmpty(recipientEmail)) recipientEmail = r["Email"]?.ToString() ?? "";
                                            }
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

                                roleTitle = (roleCategory == "teacher") ? "Teacher" : "Teaching Assistant";

                                // 2. Update Application table: status Approved and DateReviewed
                                if (appId > 0)
                                {
                                    string appQuery = "UPDATE [dbo].[Application] SET ApprovalStatus = 'Approved', DateReviewed = GETDATE() WHERE ApplicationId = @appId";
                                    using (SqlCommand cmd = new SqlCommand(appQuery, conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@appId", appId);
                                        cmd.ExecuteNonQuery();
                                    }
                                }

                                // 3. Update Teacher or Teaching_Assistant table:
                                // Write QualificationName and CredentialDocument from Application table into QualificationName and QualificationDocument columns
                                if (roleCategory == "teacher" && userId > 0)
                                {
                                    string tQuery = @"
                                        UPDATE [dbo].[Teacher] 
                                        SET AccStatus = 'Active', 
                                            QualificationName = @QualificationName, 
                                            QualificationDocument = @QualificationDocument,
                                            ApplicationId = CASE WHEN (ApplicationId IS NULL OR ApplicationId = 0) AND @appId > 0 THEN @appId ELSE ApplicationId END
                                        WHERE TeacherId = @id";
                                    using (SqlCommand cmd = new SqlCommand(tQuery, conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@QualificationName", string.IsNullOrWhiteSpace(appQualName) ? (object)DBNull.Value : appQualName);
                                        cmd.Parameters.AddWithValue("@QualificationDocument", string.IsNullOrWhiteSpace(appQualDoc) ? (object)DBNull.Value : appQualDoc);
                                        cmd.Parameters.AddWithValue("@appId", appId);
                                        cmd.Parameters.AddWithValue("@id", userId);
                                        cmd.ExecuteNonQuery();
                                    }
                                }
                                else if (roleCategory == "assistant" && userId > 0)
                                {
                                    string taQuery = @"
                                        UPDATE [dbo].[Teaching_Assistant] 
                                        SET AccStatus = 'Active', 
                                            QualificationName = @QualificationName, 
                                            QualificationDocument = @QualificationDocument,
                                            ApplicationId = CASE WHEN (ApplicationId IS NULL OR ApplicationId = 0) AND @appId > 0 THEN @appId ELSE ApplicationId END
                                        WHERE TA_Id = @id";
                                    using (SqlCommand cmd = new SqlCommand(taQuery, conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@QualificationName", string.IsNullOrWhiteSpace(appQualName) ? (object)DBNull.Value : appQualName);
                                        cmd.Parameters.AddWithValue("@QualificationDocument", string.IsNullOrWhiteSpace(appQualDoc) ? (object)DBNull.Value : appQualDoc);
                                        cmd.Parameters.AddWithValue("@appId", appId);
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

                    // 4. Send approval announcement email to user (referencing ForgotPassword.aspx.cs SMTP approach)
                    SendApplicationDecisionEmail(recipientEmail, recipientName, isApproved: true, remarks: optionalNotes, roleTitle: roleTitle);
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
            string roleCategory = hfApplicantRole.Value?.Trim().ToLower() ?? "";
            int.TryParse(hfApplicationId.Value, out int appId);
            string rejectionReason = txtAdminRemarks.Text.Trim();
            string recipientName = hfApplicantName.Value?.Trim() ?? "";
            string recipientEmail = hfApplicantEmail.Value?.Trim() ?? "";
            string roleTitle = roleCategory == "teacher" ? "Teacher" : "Teaching Assistant";

            if (!string.IsNullOrEmpty(connectionString))
            {
                try
                {
                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        conn.Open();
                        using (SqlTransaction tx = conn.BeginTransaction())
                        {
                            try
                            {
                                // If appId was 0 or not linked, attempt to find ApplicationId from Teacher / Teaching_Assistant table
                                if (appId <= 0 && userId > 0)
                                {
                                    string findAppSql = (roleCategory == "teacher")
                                        ? "SELECT ApplicationId FROM [dbo].[Teacher] WHERE TeacherId = @Id"
                                        : "SELECT ApplicationId FROM [dbo].[Teaching_Assistant] WHERE TA_Id = @Id";
                                    using (SqlCommand findAppCmd = new SqlCommand(findAppSql, conn, tx))
                                    {
                                        findAppCmd.Parameters.AddWithValue("@Id", userId);
                                        object appVal = findAppCmd.ExecuteScalar();
                                        if (appVal != null && appVal != DBNull.Value)
                                            appId = Convert.ToInt32(appVal);
                                    }
                                }

                                // If userId was 0, resolve user by ApplicationId
                                if (userId <= 0 && appId > 0)
                                {
                                    if (roleCategory == "teacher" || string.IsNullOrEmpty(roleCategory))
                                    {
                                        using (SqlCommand cmd = new SqlCommand("SELECT TeacherId, Name, Email FROM [dbo].[Teacher] WHERE ApplicationId = @appId", conn, tx))
                                        {
                                            cmd.Parameters.AddWithValue("@appId", appId);
                                            using (SqlDataReader r = cmd.ExecuteReader())
                                            {
                                                if (r.Read())
                                                {
                                                    userId = Convert.ToInt32(r["TeacherId"]);
                                                    roleCategory = "teacher";
                                                    if (string.IsNullOrEmpty(recipientName)) recipientName = r["Name"]?.ToString() ?? "";
                                                    if (string.IsNullOrEmpty(recipientEmail)) recipientEmail = r["Email"]?.ToString() ?? "";
                                                }
                                            }
                                        }
                                    }

                                    if (userId <= 0 && (roleCategory == "assistant" || string.IsNullOrEmpty(roleCategory)))
                                    {
                                        using (SqlCommand cmd = new SqlCommand("SELECT TA_Id, Name, Email FROM [dbo].[Teaching_Assistant] WHERE ApplicationId = @appId", conn, tx))
                                        {
                                            cmd.Parameters.AddWithValue("@appId", appId);
                                            using (SqlDataReader r = cmd.ExecuteReader())
                                            {
                                                if (r.Read())
                                                {
                                                    userId = Convert.ToInt32(r["TA_Id"]);
                                                    roleCategory = "assistant";
                                                    if (string.IsNullOrEmpty(recipientName)) recipientName = r["Name"]?.ToString() ?? "";
                                                    if (string.IsNullOrEmpty(recipientEmail)) recipientEmail = r["Email"]?.ToString() ?? "";
                                                }
                                            }
                                        }
                                    }
                                }

                                // Retrieve applicant Name and Email for email notification if not yet resolved
                                if (userId > 0 && (string.IsNullOrEmpty(recipientName) || string.IsNullOrEmpty(recipientEmail)))
                                {
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
                                                if (string.IsNullOrEmpty(recipientName)) recipientName = r["Name"]?.ToString() ?? "";
                                                if (string.IsNullOrEmpty(recipientEmail)) recipientEmail = r["Email"]?.ToString() ?? "";
                                            }
                                        }
                                    }
                                }

                                if (string.IsNullOrWhiteSpace(recipientName)) recipientName = HttpUtility.HtmlDecode(litFullName.Text)?.Trim() ?? "Educator";
                                if (string.IsNullOrWhiteSpace(recipientEmail)) recipientEmail = litEmail.Text?.Trim() ?? "";

                                roleTitle = (roleCategory == "teacher") ? "Teacher" : "Teaching Assistant";

                                // 1. Update Application table: Rejected status and reason
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

                    // 3. Send rejection announcement email (referencing ForgotPassword.aspx.cs SMTP approach)
                    SendApplicationDecisionEmail(recipientEmail, recipientName, isApproved: false, remarks: rejectionReason, roleTitle: roleTitle);
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[Reject Application Error]: {ex.Message}");
                }
            }

            Response.Redirect("AdminUserManagement.aspx?tab=pending&msg=application_rejected");
        }

        private void SendApplicationDecisionEmail(string email, string fullName, bool isApproved, string remarks, string roleTitle)
        {
            try
            {
                // Retrieve email credentials safely from secrets.config / Web.config AppSettings (referencing ForgotPassword.aspx.cs)
                string senderEmail = ConfigurationManager.AppSettings["SenderEmail"];
                string senderAppPassword = ConfigurationManager.AppSettings["SenderAppPassword"];

                if (string.IsNullOrEmpty(senderEmail) || string.IsNullOrEmpty(senderAppPassword) || string.IsNullOrEmpty(email))
                {
                    System.Diagnostics.Debug.WriteLine("[AdminReviewApplication SendEmail]: SenderEmail, SenderAppPassword, or recipient email not configured.");
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
                        <h2 style='color: #7C3AED; margin-top: 0;'>Welcome to Codercept!</h2>
                        <p>Hello <strong>{HttpUtility.HtmlEncode(fullName)}</strong>,</p>
                        <p>Congratulations! Your educator application for the position of <strong>{HttpUtility.HtmlEncode(roleTitle)}</strong> at Codercept has been approved.</p>
                        <p>Your account is now active and you can log in to begin teaching on the platform with your registered email and password.</p>";

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
                        <p>Thank you for your interest in joining the Codercept educator community as a <strong>{HttpUtility.HtmlEncode(roleTitle)}</strong>.</p>
                        <p>Following our evaluation of your submitted application and credentials, we regret to inform you that your application has not been approved at this time.</p>
                        <div style='background-color: #fef2f2; border: 1px solid #fecaca; border-left: 4px solid #ef4444; padding: 12px; margin: 16px 0; border-radius: 6px;'>
                            <strong>Feedback from Review Team:</strong><br/>
                            {(string.IsNullOrWhiteSpace(remarks) ? "Submitted qualifications did not meet current verification criteria." : HttpUtility.HtmlEncode(remarks))}
                        </div>";
                }

                mail.Body = $@"
                    <div style='font-family: Arial, sans-serif; padding: 24px; color: #1e293b; line-height: 1.6; max-width: 600px; border: 1px solid #e2e8f0; border-radius: 8px;'>
                        {bodyContent}
                        <p style='margin-top: 24px;'>Best regards,<br/><strong>The Codercept Team</strong></p>
                    </div>";
                mail.IsBodyHtml = true;

                // Send the email via Gmail's SMTP server (referencing ForgotPassword.aspx.cs)
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