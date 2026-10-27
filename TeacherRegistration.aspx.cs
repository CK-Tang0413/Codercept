using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class TeacherRegistration : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                pnlAlert.Visible = false;
            }
        }

        protected void btnSubmitRegistration_Click(object sender, EventArgs e)
        {
            pnlAlert.Visible = false;
            lblAlertMessage.Text = "";

            // 1. Gather Step 1 Inputs
            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;
            string confirmPassword = txtConfirmPassword.Text;

            // 2. Gather Step 2 Inputs
            string roleSelection = Request.Form["RoleSelection"];
            string dbRole = (roleSelection == "Assistant") ? "Teaching Assistant" : "Teacher";
            string qualificationName = txtQualification.Text.Trim();
            string subjectArea = txtSubjectArea.Text.Trim();
            bool hasJava = chkJava.Checked;
            bool hasPython = chkPython.Checked;
            bool hasCpp = chkCpp.Checked;
            bool hasC = chkC.Checked;

            // 3. Validation - Step 1 Fields
            if (string.IsNullOrWhiteSpace(fullName))
            {
                ShowError("Please enter your full name.", 1);
                return;
            }

            if (string.IsNullOrWhiteSpace(email) || !email.Contains("@") || !email.Contains("."))
            {
                ShowError("Please enter a valid email address.", 1);
                return;
            }

            if (string.IsNullOrEmpty(password) || password.Length < 8)
            {
                ShowError("Password must be at least 8 characters long.", 1);
                return;
            }

            if (password != confirmPassword)
            {
                ShowError("Passwords do not match.", 1);
                return;
            }

            // 4. Validation - Step 2 Fields
            if (string.IsNullOrWhiteSpace(qualificationName))
            {
                ShowError("Please specify your highest qualification level (e.g., Bachelor of Computer Science).", 2);
                return;
            }

            if (!hasJava && !hasPython && !hasCpp && !hasC && string.IsNullOrWhiteSpace(subjectArea))
            {
                ShowError("Please select at least one programming language or specify a subject area.", 2);
                return;
            }

            if (!fileQualification.HasFile)
            {
                ShowError("Please upload your qualification certificate or transcript.", 2);
                return;
            }

            // Validate file extension and size (10 MB max)
            string fileExt = Path.GetExtension(fileQualification.FileName).ToLowerInvariant();
            string[] allowedExts = { ".pdf", ".png", ".jpg", ".jpeg", ".doc", ".docx" };
            if (!allowedExts.Contains(fileExt))
            {
                ShowError("Invalid file type. Only PDF, PNG, JPG, and DOC/DOCX files are accepted.", 2);
                return;
            }

            if (fileQualification.PostedFile.ContentLength > 10 * 1024 * 1024)
            {
                ShowError("File size exceeds 10MB limit. Please upload a smaller file.", 2);
                return;
            }

            string connString = ConfigurationManager.ConnectionStrings["Codercept_db"].ConnectionString;

            try
            {
                using (SqlConnection con = new SqlConnection(connString))
                {
                    con.Open();

                    // 5. Check Email Uniqueness across all accounts
                    string checkSql = @"
                        SELECT COUNT(*) FROM (
                            SELECT Email FROM [dbo].[Admin] WHERE LOWER(Email) = LOWER(@Email)
                            UNION ALL
                            SELECT Email FROM [dbo].[Learner] WHERE LOWER(Email) = LOWER(@Email)
                            UNION ALL
                            SELECT Email FROM [dbo].[Teacher] WHERE LOWER(Email) = LOWER(@Email)
                            UNION ALL
                            SELECT Email FROM [dbo].[Teaching_Assistant] WHERE LOWER(Email) = LOWER(@Email)
                        ) AS ExistingAccounts";

                    using (SqlCommand checkCmd = new SqlCommand(checkSql, con))
                    {
                        checkCmd.Parameters.AddWithValue("@Email", email);
                        int count = (int)checkCmd.ExecuteScalar();
                        if (count > 0)
                        {
                            ShowError("This email address is already registered. Please sign in or use another email.", 1);
                            return;
                        }
                    }

                    // 6. Save Uploaded File
                    string uploadFolder = Server.MapPath("~/media/uploads/qualifications/");
                    if (!Directory.Exists(uploadFolder))
                    {
                        Directory.CreateDirectory(uploadFolder);
                    }

                    string safeFileName = "qual_" + Guid.NewGuid().ToString("N") + fileExt;
                    string targetFilePath = Path.Combine(uploadFolder, safeFileName);
                    fileQualification.SaveAs(targetFilePath);
                    string dbDocPath = "~/media/uploads/qualifications/" + safeFileName;

                    // 7. Hash Password
                    string hashedPassword = BCrypt.Net.BCrypt.HashPassword(password);

                    // 8. Execute Database Insertion in a Transaction
                    using (SqlTransaction tx = con.BeginTransaction())
                    {
                        try
                        {
                            // A. Insert into Application table
                            int appId;
                            string appSql = @"
                                INSERT INTO [dbo].[Application] 
                                    ([RoleApplied], [QualificationName], [CredentialDocument], [ApprovalStatus], [DateSubmitted])
                                VALUES 
                                    (@RoleApplied, @QualificationName, @CredentialDocument, 'Pending', GETDATE());
                                SELECT SCOPE_IDENTITY();";

                            using (SqlCommand appCmd = new SqlCommand(appSql, con, tx))
                            {
                                appCmd.Parameters.AddWithValue("@RoleApplied", dbRole);
                                appCmd.Parameters.AddWithValue("@QualificationName", qualificationName);
                                appCmd.Parameters.AddWithValue("@CredentialDocument", dbDocPath);
                                appId = Convert.ToInt32(appCmd.ExecuteScalar());
                            }

                            // B. Insert into Teacher or Teaching_Assistant
                            int educatorId;
                            if (dbRole == "Teacher")
                            {
                                string teacherSql = @"
                                    INSERT INTO [dbo].[Teacher]
                                        ([Name], [Email], [Password], [TeachingLevel], [AccStatus], [DateJoined], [ApplicationId])
                                    VALUES
                                        (@Name, @Email, @Password, 'Beginner', 'Pending', GETDATE(), @ApplicationId);
                                    SELECT SCOPE_IDENTITY();";

                                using (SqlCommand teacherCmd = new SqlCommand(teacherSql, con, tx))
                                {
                                    teacherCmd.Parameters.AddWithValue("@Name", fullName);
                                    teacherCmd.Parameters.AddWithValue("@Email", email);
                                    teacherCmd.Parameters.AddWithValue("@Password", hashedPassword);
                                    teacherCmd.Parameters.AddWithValue("@ApplicationId", appId);
                                    educatorId = Convert.ToInt32(teacherCmd.ExecuteScalar());
                                }
                            }
                            else
                            {
                                string taSql = @"
                                    INSERT INTO [dbo].[Teaching_Assistant]
                                        ([Name], [Email], [Password], [TeachingLevel], [AccStatus], [DateJoined], [ApplicationId])
                                    VALUES
                                        (@Name, @Email, @Password, 'Beginner', 'Pending', GETDATE(), @ApplicationId);
                                    SELECT SCOPE_IDENTITY();";

                                using (SqlCommand taCmd = new SqlCommand(taSql, con, tx))
                                {
                                    taCmd.Parameters.AddWithValue("@Name", fullName);
                                    taCmd.Parameters.AddWithValue("@Email", email);
                                    taCmd.Parameters.AddWithValue("@Password", hashedPassword);
                                    taCmd.Parameters.AddWithValue("@ApplicationId", appId);
                                    educatorId = Convert.ToInt32(taCmd.ExecuteScalar());
                                }
                            }

                            // C. Insert into Subject & EducatorSubject
                            List<Tuple<string, string>> subjectsToAdd = new List<Tuple<string, string>>();
                            if (hasJava) subjectsToAdd.Add(new Tuple<string, string>("Java", "Language"));
                            if (hasPython) subjectsToAdd.Add(new Tuple<string, string>("Python", "Language"));
                            if (hasCpp) subjectsToAdd.Add(new Tuple<string, string>("C++", "Language"));
                            if (hasC) subjectsToAdd.Add(new Tuple<string, string>("C", "Language"));

                            if (!string.IsNullOrWhiteSpace(subjectArea))
                            {
                                subjectsToAdd.Add(new Tuple<string, string>(subjectArea, "Domain"));
                            }

                            foreach (var item in subjectsToAdd)
                            {
                                int subjectId = GetOrCreateSubjectId(item.Item1, item.Item2, con, tx);

                                string linkSql;
                                if (dbRole == "Teacher")
                                {
                                    linkSql = @"
                                        IF NOT EXISTS (SELECT 1 FROM [dbo].[EducatorSubject] WHERE TeacherId = @EducatorId AND SubjectId = @SubjectId)
                                        BEGIN
                                            INSERT INTO [dbo].[EducatorSubject] ([TeacherId], [SubjectId]) VALUES (@EducatorId, @SubjectId)
                                        END";
                                }
                                else
                                {
                                    linkSql = @"
                                        IF NOT EXISTS (SELECT 1 FROM [dbo].[EducatorSubject] WHERE TA_Id = @EducatorId AND SubjectId = @SubjectId)
                                        BEGIN
                                            INSERT INTO [dbo].[EducatorSubject] ([TA_Id], [SubjectId]) VALUES (@EducatorId, @SubjectId)
                                        END";
                                }

                                using (SqlCommand linkCmd = new SqlCommand(linkSql, con, tx))
                                {
                                    linkCmd.Parameters.AddWithValue("@EducatorId", educatorId);
                                    linkCmd.Parameters.AddWithValue("@SubjectId", subjectId);
                                    linkCmd.ExecuteNonQuery();
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

                // 9. Redirect to signIn with pending status
                Response.Redirect("signIn.aspx?registered=pending");
            }
            catch (Exception ex)
            {
                ShowError("An error occurred during submission: " + ex.Message, 2);
            }
        }

        private int GetOrCreateSubjectId(string name, string type, SqlConnection con, SqlTransaction tx)
        {
            string selectSql = "SELECT SubjectId FROM [dbo].[Subject] WHERE LOWER(SubjectName) = LOWER(@Name)";
            using (SqlCommand cmd = new SqlCommand(selectSql, con, tx))
            {
                cmd.Parameters.AddWithValue("@Name", name);
                object result = cmd.ExecuteScalar();
                if (result != null && result != DBNull.Value)
                {
                    return Convert.ToInt32(result);
                }
            }

            string insertSql = @"
                INSERT INTO [dbo].[Subject] ([SubjectName], [SubjectType]) 
                VALUES (@Name, @Type); 
                SELECT SCOPE_IDENTITY();";

            using (SqlCommand cmd = new SqlCommand(insertSql, con, tx))
            {
                cmd.Parameters.AddWithValue("@Name", name);
                cmd.Parameters.AddWithValue("@Type", type);
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        private void ShowError(string message, int step)
        {
            pnlAlert.CssClass = "alert-banner error";
            lblAlertMessage.Text = message;
            pnlAlert.Visible = true;
            hfActiveStep.Value = step.ToString();
        }
    }
}