using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.SessionState;

namespace Codercept
{
    public static class UserLogHelper
    {
        private static string GetConnectionString()
        {
            return ConfigurationManager.ConnectionStrings["Codercept_db"]?.ConnectionString
                ?? ConfigurationManager.ConnectionStrings["CoderceptDB"]?.ConnectionString;
        }

        /// <summary>
        /// Records a user's login activity into the [dbo].[User_Log] table.
        /// Returns the newly created LogId, or 0 if failed.
        /// </summary>
        public static int RecordLogin(string userType, int userId)
        {
            string connString = GetConnectionString();
            if (string.IsNullOrEmpty(connString) || userId <= 0) return 0;

            try
            {
                using (SqlConnection con = new SqlConnection(connString))
                {
                    con.Open();
                    string query = @"
                        INSERT INTO [dbo].[User_Log] ([StartDateTime], [EndDateTime], [LearnerId], [TeacherId], [TA_Id], [AdminId])
                        VALUES (@StartDateTime, NULL, @LearnerId, @TeacherId, @TA_Id, @AdminId);
                        SELECT CAST(SCOPE_IDENTITY() AS INT);";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@StartDateTime", DateTime.Now);

                        object learnerId = DBNull.Value;
                        object teacherId = DBNull.Value;
                        object taId = DBNull.Value;
                        object adminId = DBNull.Value;

                        string normalizedRole = (userType ?? "").Trim().ToLower();
                        if (normalizedRole == "superadmin" || normalizedRole == "super admin" || normalizedRole == "admin")
                        {
                            adminId = userId;
                        }
                        else if (normalizedRole == "teacher")
                        {
                            teacherId = userId;
                        }
                        else if (normalizedRole == "ta" || normalizedRole == "teaching assistant" || normalizedRole == "assistant")
                        {
                            taId = userId;
                        }
                        else if (normalizedRole == "learner")
                        {
                            learnerId = userId;
                        }

                        cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        cmd.Parameters.AddWithValue("@TA_Id", taId);
                        cmd.Parameters.AddWithValue("@AdminId", adminId);

                        object result = cmd.ExecuteScalar();
                        if (result != null && result != DBNull.Value)
                        {
                            return Convert.ToInt32(result);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[UserLogHelper RecordLogin Error]: {ex.Message}");
            }

            return 0;
        }

        /// <summary>
        /// Records a user's logout timestamp into the [dbo].[User_Log] table.
        /// </summary>
        public static void RecordLogout(HttpSessionState session)
        {
            if (session == null) return;

            int logId = 0;
            if (session["LogId"] != null)
            {
                int.TryParse(session["LogId"].ToString(), out logId);
            }

            int userId = 0;
            if (session["UserId"] != null)
            {
                int.TryParse(session["UserId"].ToString(), out userId);
            }

            string userType = (session["UserRole"] as string) ?? (session["UserType"] as string);

            RecordLogout(logId, userType, userId);
        }

        /// <summary>
        /// Updates the EndDateTime of the specified LogId or the most recent open session for the user.
        /// </summary>
        public static void RecordLogout(int logId, string userType = null, int userId = 0)
        {
            string connString = GetConnectionString();
            if (string.IsNullOrEmpty(connString)) return;

            try
            {
                using (SqlConnection con = new SqlConnection(connString))
                {
                    con.Open();

                    if (logId > 0)
                    {
                        string query = "UPDATE [dbo].[User_Log] SET [EndDateTime] = @EndDateTime WHERE [LogId] = @LogId AND [EndDateTime] IS NULL";
                        using (SqlCommand cmd = new SqlCommand(query, con))
                        {
                            cmd.Parameters.AddWithValue("@EndDateTime", DateTime.Now);
                            cmd.Parameters.AddWithValue("@LogId", logId);
                            int rows = cmd.ExecuteNonQuery();
                            if (rows > 0) return;
                        }
                    }

                    // Fallback: update most recent open session for this user ID and role
                    if (userId > 0 && !string.IsNullOrEmpty(userType))
                    {
                        string column = null;
                        string normalizedRole = userType.Trim().ToLower();
                        if (normalizedRole == "superadmin" || normalizedRole == "super admin" || normalizedRole == "admin")
                        {
                            column = "AdminId";
                        }
                        else if (normalizedRole == "teacher")
                        {
                            column = "TeacherId";
                        }
                        else if (normalizedRole == "ta" || normalizedRole == "teaching assistant" || normalizedRole == "assistant")
                        {
                            column = "TA_Id";
                        }
                        else if (normalizedRole == "learner")
                        {
                            column = "LearnerId";
                        }

                        if (column != null)
                        {
                            string query = $@"
                                UPDATE [dbo].[User_Log] 
                                SET [EndDateTime] = @EndDateTime 
                                WHERE [LogId] = (
                                    SELECT TOP 1 [LogId] 
                                    FROM [dbo].[User_Log] 
                                    WHERE [{column}] = @UserId AND [EndDateTime] IS NULL 
                                    ORDER BY [StartDateTime] DESC
                                )";
                            using (SqlCommand cmd = new SqlCommand(query, con))
                            {
                                cmd.Parameters.AddWithValue("@EndDateTime", DateTime.Now);
                                cmd.Parameters.AddWithValue("@UserId", userId);
                                cmd.ExecuteNonQuery();
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[UserLogHelper RecordLogout Error]: {ex.Message}");
            }
        }
    }
}
