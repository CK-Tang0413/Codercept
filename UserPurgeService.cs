using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Threading;
using System.Web;

namespace Codercept
{
    public class PurgeExecutionResult
    {
        public bool Success { get; set; }
        public int AdminsPurged { get; set; }
        public int TeachersPurged { get; set; }
        public int TAsPurged { get; set; }
        public int LearnersPurged { get; set; }
        public int TotalPurged => AdminsPurged + TeachersPurged + TAsPurged + LearnersPurged;
        public string ErrorMessage { get; set; }
        public DateTime ExecutionTime { get; set; } = DateTime.UtcNow;
    }

    /// <summary>
    /// Service responsible for the automated weekly purge of accounts marked with "Deleted" status
    /// from database table records.
    /// </summary>
    public static class UserPurgeService
    {
        private static Timer _backgroundTimer;
        private static readonly object _purgeLock = new object();

        private static string GetConnectionString()
        {
            string connStr = ConfigurationManager.ConnectionStrings["Codercept_db"]?.ConnectionString
                ?? ConfigurationManager.ConnectionStrings["CoderceptDB"]?.ConnectionString;

            if (!string.IsNullOrEmpty(connStr))
            {
                return connStr;
            }

            // Fallback for background execution or when ConfigurationManager connectionStrings is unavailable
            try
            {
                string dataDir = AppDomain.CurrentDomain.GetData("DataDirectory") as string;
                if (string.IsNullOrEmpty(dataDir))
                {
                    string candidate = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App_Data");
                    if (Directory.Exists(candidate))
                    {
                        dataDir = candidate;
                    }
                }

                if (!string.IsNullOrEmpty(dataDir))
                {
                    string mdfPath = Path.Combine(dataDir, "Codercept_db.mdf");
                    if (File.Exists(mdfPath))
                    {
                        return $@"Data Source=(LocalDB)\MSSQLLocalDB;AttachDbFilename={mdfPath};Integrated Security=True";
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[UserPurgeService.GetConnectionString Fallback Error]: {ex.Message}");
            }

            return null;
        }

        /// <summary>
        /// Starts the background scheduled timer for automated weekly user purge.
        /// Runs a check shortly after startup, and then every 1 hour.
        /// </summary>
        public static void StartScheduledPurge()
        {
            try
            {
                if (_backgroundTimer == null)
                {
                    // Check 30 seconds after startup, then every hour
                    _backgroundTimer = new Timer(TimerCallback, null, TimeSpan.FromSeconds(30), TimeSpan.FromHours(1));
                    System.Diagnostics.Debug.WriteLine("[UserPurgeService] Automated weekly purge timer registered successfully.");
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[UserPurgeService.StartScheduledPurge Error]: {ex.Message}");
            }
        }

        /// <summary>
        /// Stops and disposes the background purge timer.
        /// </summary>
        public static void StopScheduledPurge()
        {
            try
            {
                if (_backgroundTimer != null)
                {
                    _backgroundTimer.Dispose();
                    _backgroundTimer = null;
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[UserPurgeService.StopScheduledPurge Error]: {ex.Message}");
            }
        }

        private static void TimerCallback(object state)
        {
            try
            {
                CheckAndPerformPurgeIfNeeded();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[UserPurgeService Background Timer Error]: {ex.Message}");
            }
        }

        /// <summary>
        /// Checks whether 7 days have passed since the last automated weekly purge (or if today is the weekly cycle),
        /// and if so, performs the database purge.
        /// </summary>
        public static bool CheckAndPerformPurgeIfNeeded(HttpServerUtility server = null, HttpApplicationState application = null)
        {
            lock (_purgeLock)
            {
                try
                {
                    DateTime? lastPurge = GetLastPurgeTime(server, application);
                    bool shouldPurge = false;

                    if (!lastPurge.HasValue)
                    {
                        // First run: if no previous purge recorded, establish schedule and perform purge
                        shouldPurge = true;
                    }
                    else
                    {
                        TimeSpan elapsed = DateTime.UtcNow - lastPurge.Value;
                        if (elapsed.TotalDays >= 7)
                        {
                            shouldPurge = true;
                        }
                        else if (DateTime.UtcNow.DayOfWeek == DayOfWeek.Sunday && lastPurge.Value.Date < DateTime.UtcNow.Date && elapsed.TotalHours >= 24)
                        {
                            shouldPurge = true;
                        }
                    }

                    if (shouldPurge)
                    {
                        PerformPurge(server, application);
                        return true;
                    }
                }
                catch (Exception ex)
                {
                    System.Diagnostics.Debug.WriteLine($"[UserPurgeService.CheckAndPerformPurgeIfNeeded Error]: {ex.Message}");
                }

                return false;
            }
        }

        /// <summary>
        /// Retrieves the timestamp of the last executed weekly purge.
        /// </summary>
        public static DateTime? GetLastPurgeTime(HttpServerUtility server = null, HttpApplicationState application = null)
        {
            try
            {
                if (application != null && application["LastWeeklyUserPurge"] is DateTime dtApp)
                {
                    return dtApp;
                }

                if (HttpContext.Current != null && HttpContext.Current.Application != null && HttpContext.Current.Application["LastWeeklyUserPurge"] is DateTime dtCtx)
                {
                    return dtCtx;
                }

                string filePath = GetPurgeRecordFilePath(server);
                if (File.Exists(filePath))
                {
                    string content = File.ReadAllText(filePath).Trim();
                    if (DateTime.TryParse(content, out DateTime fileDate))
                    {
                        if (application != null) application["LastWeeklyUserPurge"] = fileDate;
                        else if (HttpContext.Current?.Application != null) HttpContext.Current.Application["LastWeeklyUserPurge"] = fileDate;

                        return fileDate;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[UserPurgeService.GetLastPurgeTime Error]: {ex.Message}");
            }

            return null;
        }

        /// <summary>
        /// Returns a human-friendly description of the automated weekly purge status.
        /// </summary>
        public static string GetScheduleStatusDescription(HttpServerUtility server = null, HttpApplicationState application = null)
        {
            DateTime? lastPurge = GetLastPurgeTime(server, application);
            if (!lastPurge.HasValue)
            {
                return "Auto-purge scheduled weekly. Active & monitoring.";
            }

            TimeSpan elapsed = DateTime.UtcNow - lastPurge.Value;
            double daysRemaining = Math.Max(0, 7 - elapsed.TotalDays);
            string lastPurgeStr = lastPurge.Value.ToString("dd MMM yyyy HH:mm UTC");

            if (daysRemaining < 1)
            {
                int hoursRemaining = (int)Math.Max(1, Math.Round(daysRemaining * 24));
                return $"Last purge: {lastPurgeStr}. Next automated weekly purge in approx. {hoursRemaining} hour(s).";
            }
            else
            {
                int d = (int)Math.Ceiling(daysRemaining);
                return $"Last purge: {lastPurgeStr}. Next automated weekly purge in {d} day(s).";
            }
        }

        /// <summary>
        /// Permanently purges user accounts with 'Deleted' status and all their associated records from the database.
        /// </summary>
        public static PurgeExecutionResult PerformPurge(HttpServerUtility server = null, HttpApplicationState application = null)
        {
            lock (_purgeLock)
            {
                var result = new PurgeExecutionResult();

                string connStr = GetConnectionString();
                if (string.IsNullOrEmpty(connStr))
                {
                    result.Success = false;
                    result.ErrorMessage = "Database connection string is missing.";
                    return result;
                }

                try
                {
                    using (SqlConnection conn = new SqlConnection(connStr))
                    {
                        conn.Open();

                        // 1. Purge Deleted Admins (preserving SuperAdmin)
                        string deleteAdminsQuery = "DELETE FROM [dbo].[Admin] WHERE LOWER(AccStatus) = 'deleted' AND Role != 'SuperAdmin'";
                        using (SqlCommand cmd = new SqlCommand(deleteAdminsQuery, conn))
                        {
                            result.AdminsPurged = cmd.ExecuteNonQuery();
                        }

                        // 2. Purge Deleted Teaching Assistants
                        List<int> deletedTaIds = new List<int>();
                        using (SqlCommand cmd = new SqlCommand("SELECT TA_Id FROM [dbo].[Teaching_Assistant] WHERE LOWER(AccStatus) = 'deleted'", conn))
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read()) deletedTaIds.Add(rdr.GetInt32(0));
                        }

                        foreach (int taId in deletedTaIds)
                        {
                            using (SqlTransaction tx = conn.BeginTransaction())
                            {
                                try
                                {
                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Moderate_Forum] WHERE TA_Id = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", taId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Post_Reply] WHERE TA_Id = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", taId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[GradingProgress] WHERE TA_Id = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", taId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[EducatorSubject] WHERE TA_Id = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", taId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[User_Log] WHERE TA_Id = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", taId); cmd.ExecuteNonQuery(); }

                                    int? appId = null;
                                    using (SqlCommand cmd = new SqlCommand("SELECT ApplicationId FROM [dbo].[Teaching_Assistant] WHERE TA_Id = @id", conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@id", taId);
                                        object val = cmd.ExecuteScalar();
                                        if (val != null && val != DBNull.Value) appId = Convert.ToInt32(val);
                                    }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Teaching_Assistant] WHERE TA_Id = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", taId); cmd.ExecuteNonQuery(); }

                                    if (appId.HasValue)
                                    {
                                        using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Application] WHERE ApplicationId = @appId AND NOT EXISTS (SELECT 1 FROM [dbo].[Teacher] WHERE ApplicationId = @appId) AND NOT EXISTS (SELECT 1 FROM [dbo].[Teaching_Assistant] WHERE ApplicationId = @appId)", conn, tx))
                                        { cmd.Parameters.AddWithValue("@appId", appId.Value); cmd.ExecuteNonQuery(); }
                                    }

                                    tx.Commit();
                                    result.TAsPurged++;
                                }
                                catch (Exception ex)
                                {
                                    tx.Rollback();
                                    System.Diagnostics.Debug.WriteLine($"[Purge TA {taId} Error]: {ex.Message}");
                                }
                            }
                        }

                        // 3. Purge Deleted Teachers
                        List<int> deletedTeacherIds = new List<int>();
                        using (SqlCommand cmd = new SqlCommand("SELECT TeacherId FROM [dbo].[Teacher] WHERE LOWER(AccStatus) = 'deleted'", conn))
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read()) deletedTeacherIds.Add(rdr.GetInt32(0));
                        }

                        foreach (int tId in deletedTeacherIds)
                        {
                            using (SqlTransaction tx = conn.BeginTransaction())
                            {
                                try
                                {
                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[EducatorSubject] WHERE TeacherId = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", tId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[GradingProgress] WHERE TeacherId = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", tId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Post_Reply] WHERE TeacherId = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", tId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Post_Reply] WHERE PostId IN (SELECT PostId FROM [dbo].[Forum] WHERE TeacherId = @id)", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", tId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Moderate_Forum] WHERE PostId IN (SELECT PostId FROM [dbo].[Forum] WHERE TeacherId = @id)", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", tId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[ForumRead] WHERE PostId IN (SELECT PostId FROM [dbo].[Forum] WHERE TeacherId = @id) OR TeacherId = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", tId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Forum] WHERE TeacherId = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", tId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[User_Log] WHERE TeacherId = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", tId); cmd.ExecuteNonQuery(); }

                                    List<int> courseIds = new List<int>();
                                    using (SqlCommand cmd = new SqlCommand("SELECT CourseId FROM [dbo].[Course] WHERE TeacherId = @id", conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@id", tId);
                                        using (SqlDataReader cr = cmd.ExecuteReader())
                                        {
                                            while (cr.Read()) courseIds.Add(cr.GetInt32(0));
                                        }
                                    }

                                    foreach (int cId in courseIds)
                                    {
                                        using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[AttemptAnswer] WHERE AttemptId IN (SELECT AttemptId FROM [dbo].[Attempt] WHERE QuizId IN (SELECT QuizId FROM [dbo].[Quiz] WHERE ChapterId IN (SELECT ChapterId FROM [dbo].[Chapter] WHERE CourseId = @cId)) OR AssessmentId IN (SELECT AssessmentId FROM [dbo].[Assessment] WHERE ChapterId IN (SELECT ChapterId FROM [dbo].[Chapter] WHERE CourseId = @cId)) OR ExamId IN (SELECT ExamId FROM [dbo].[Exam] WHERE CourseId = @cId))", conn, tx))
                                        { cmd.Parameters.AddWithValue("@cId", cId); cmd.ExecuteNonQuery(); }

                                        using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Result] WHERE AttemptId IN (SELECT AttemptId FROM [dbo].[Attempt] WHERE QuizId IN (SELECT QuizId FROM [dbo].[Quiz] WHERE ChapterId IN (SELECT ChapterId FROM [dbo].[Chapter] WHERE CourseId = @cId)) OR AssessmentId IN (SELECT AssessmentId FROM [dbo].[Assessment] WHERE ChapterId IN (SELECT ChapterId FROM [dbo].[Chapter] WHERE CourseId = @cId)) OR ExamId IN (SELECT ExamId FROM [dbo].[Exam] WHERE CourseId = @cId))", conn, tx))
                                        { cmd.Parameters.AddWithValue("@cId", cId); cmd.ExecuteNonQuery(); }

                                        using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[GradingProgress] WHERE AttemptId IN (SELECT AttemptId FROM [dbo].[Attempt] WHERE QuizId IN (SELECT QuizId FROM [dbo].[Quiz] WHERE ChapterId IN (SELECT ChapterId FROM [dbo].[Chapter] WHERE CourseId = @cId)) OR AssessmentId IN (SELECT AssessmentId FROM [dbo].[Assessment] WHERE ChapterId IN (SELECT ChapterId FROM [dbo].[Chapter] WHERE CourseId = @cId)) OR ExamId IN (SELECT ExamId FROM [dbo].[Exam] WHERE CourseId = @cId))", conn, tx))
                                        { cmd.Parameters.AddWithValue("@cId", cId); cmd.ExecuteNonQuery(); }

                                        using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Attempt] WHERE QuizId IN (SELECT QuizId FROM [dbo].[Quiz] WHERE ChapterId IN (SELECT ChapterId FROM [dbo].[Chapter] WHERE CourseId = @cId)) OR AssessmentId IN (SELECT AssessmentId FROM [dbo].[Assessment] WHERE ChapterId IN (SELECT ChapterId FROM [dbo].[Chapter] WHERE CourseId = @cId)) OR ExamId IN (SELECT ExamId FROM [dbo].[Exam] WHERE CourseId = @cId)", conn, tx))
                                        { cmd.Parameters.AddWithValue("@cId", cId); cmd.ExecuteNonQuery(); }

                                        using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[MCQ_Option] WHERE QuestionId IN (SELECT QuestionId FROM [dbo].[Question] WHERE QuizId IN (SELECT QuizId FROM [dbo].[Quiz] WHERE ChapterId IN (SELECT ChapterId FROM [dbo].[Chapter] WHERE CourseId = @cId)) OR AssessmentId IN (SELECT AssessmentId FROM [dbo].[Assessment] WHERE ChapterId IN (SELECT ChapterId FROM [dbo].[Chapter] WHERE CourseId = @cId)) OR ExamId IN (SELECT ExamId FROM [dbo].[Exam] WHERE CourseId = @cId))", conn, tx))
                                        { cmd.Parameters.AddWithValue("@cId", cId); cmd.ExecuteNonQuery(); }

                                        using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Question] WHERE QuizId IN (SELECT QuizId FROM [dbo].[Quiz] WHERE ChapterId IN (SELECT ChapterId FROM [dbo].[Chapter] WHERE CourseId = @cId)) OR AssessmentId IN (SELECT AssessmentId FROM [dbo].[Assessment] WHERE ChapterId IN (SELECT ChapterId FROM [dbo].[Chapter] WHERE CourseId = @cId)) OR ExamId IN (SELECT ExamId FROM [dbo].[Exam] WHERE CourseId = @cId)", conn, tx))
                                        { cmd.Parameters.AddWithValue("@cId", cId); cmd.ExecuteNonQuery(); }

                                        using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Quiz] WHERE ChapterId IN (SELECT ChapterId FROM [dbo].[Chapter] WHERE CourseId = @cId)", conn, tx))
                                        { cmd.Parameters.AddWithValue("@cId", cId); cmd.ExecuteNonQuery(); }

                                        using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Assessment] WHERE ChapterId IN (SELECT ChapterId FROM [dbo].[Chapter] WHERE CourseId = @cId)", conn, tx))
                                        { cmd.Parameters.AddWithValue("@cId", cId); cmd.ExecuteNonQuery(); }

                                        using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Exam] WHERE CourseId = @cId", conn, tx))
                                        { cmd.Parameters.AddWithValue("@cId", cId); cmd.ExecuteNonQuery(); }

                                        using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[SubChapter] WHERE ChapterId IN (SELECT ChapterId FROM [dbo].[Chapter] WHERE CourseId = @cId)", conn, tx))
                                        { cmd.Parameters.AddWithValue("@cId", cId); cmd.ExecuteNonQuery(); }

                                        using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Chapter] WHERE CourseId = @cId", conn, tx))
                                        { cmd.Parameters.AddWithValue("@cId", cId); cmd.ExecuteNonQuery(); }

                                        using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Certificate] WHERE CourseId = @cId", conn, tx))
                                        { cmd.Parameters.AddWithValue("@cId", cId); cmd.ExecuteNonQuery(); }

                                        using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Course_Review] WHERE CourseId = @cId", conn, tx))
                                        { cmd.Parameters.AddWithValue("@cId", cId); cmd.ExecuteNonQuery(); }

                                        using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[LearnerProgress] WHERE CourseId = @cId", conn, tx))
                                        { cmd.Parameters.AddWithValue("@cId", cId); cmd.ExecuteNonQuery(); }

                                        using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[CourseSubject] WHERE CourseId = @cId", conn, tx))
                                        { cmd.Parameters.AddWithValue("@cId", cId); cmd.ExecuteNonQuery(); }

                                        using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Course] WHERE CourseId = @cId", conn, tx))
                                        { cmd.Parameters.AddWithValue("@cId", cId); cmd.ExecuteNonQuery(); }
                                    }

                                    int? appId = null;
                                    using (SqlCommand cmd = new SqlCommand("SELECT ApplicationId FROM [dbo].[Teacher] WHERE TeacherId = @id", conn, tx))
                                    {
                                        cmd.Parameters.AddWithValue("@id", tId);
                                        object val = cmd.ExecuteScalar();
                                        if (val != null && val != DBNull.Value) appId = Convert.ToInt32(val);
                                    }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Teacher] WHERE TeacherId = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", tId); cmd.ExecuteNonQuery(); }

                                    if (appId.HasValue)
                                    {
                                        using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Application] WHERE ApplicationId = @appId AND NOT EXISTS (SELECT 1 FROM [dbo].[Teacher] WHERE ApplicationId = @appId) AND NOT EXISTS (SELECT 1 FROM [dbo].[Teaching_Assistant] WHERE ApplicationId = @appId)", conn, tx))
                                        { cmd.Parameters.AddWithValue("@appId", appId.Value); cmd.ExecuteNonQuery(); }
                                    }

                                    tx.Commit();
                                    result.TeachersPurged++;
                                }
                                catch (Exception ex)
                                {
                                    tx.Rollback();
                                    System.Diagnostics.Debug.WriteLine($"[Purge Teacher {tId} Error]: {ex.Message}");
                                }
                            }
                        }

                        // 4. Purge Deleted Learners
                        List<int> deletedLearnerIds = new List<int>();
                        using (SqlCommand cmd = new SqlCommand("SELECT LearnerId FROM [dbo].[Learner] WHERE LOWER(AccStatus) = 'deleted'", conn))
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            while (rdr.Read()) deletedLearnerIds.Add(rdr.GetInt32(0));
                        }

                        foreach (int lId in deletedLearnerIds)
                        {
                            using (SqlTransaction tx = conn.BeginTransaction())
                            {
                                try
                                {
                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[AttemptAnswer] WHERE AttemptId IN (SELECT AttemptId FROM [dbo].[Attempt] WHERE LearnerId = @id)", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", lId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Result] WHERE AttemptId IN (SELECT AttemptId FROM [dbo].[Attempt] WHERE LearnerId = @id)", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", lId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[GradingProgress] WHERE AttemptId IN (SELECT AttemptId FROM [dbo].[Attempt] WHERE LearnerId = @id)", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", lId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Attempt] WHERE LearnerId = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", lId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Certificate] WHERE LearnerId = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", lId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Course_Review] WHERE LearnerId = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", lId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[LearnerProgress] WHERE LearnerId = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", lId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Moderate_Forum] WHERE PostId IN (SELECT PostId FROM [dbo].[Forum] WHERE LearnerId = @id)", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", lId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[ForumRead] WHERE PostId IN (SELECT PostId FROM [dbo].[Forum] WHERE LearnerId = @id)", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", lId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Post_Reply] WHERE PostId IN (SELECT PostId FROM [dbo].[Forum] WHERE LearnerId = @id) OR LearnerId = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", lId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Forum] WHERE LearnerId = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", lId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[User_Log] WHERE LearnerId = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", lId); cmd.ExecuteNonQuery(); }

                                    using (SqlCommand cmd = new SqlCommand("DELETE FROM [dbo].[Learner] WHERE LearnerId = @id", conn, tx))
                                    { cmd.Parameters.AddWithValue("@id", lId); cmd.ExecuteNonQuery(); }

                                    tx.Commit();
                                    result.LearnersPurged++;
                                }
                                catch (Exception ex)
                                {
                                    tx.Rollback();
                                    System.Diagnostics.Debug.WriteLine($"[Purge Learner {lId} Error]: {ex.Message}");
                                }
                            }
                        }
                    }

                    result.Success = true;
                    RecordPurgeTimestamp(result.ExecutionTime, server, application);
                }
                catch (Exception ex)
                {
                    result.Success = false;
                    result.ErrorMessage = ex.Message;
                    System.Diagnostics.Debug.WriteLine($"[UserPurgeService.PerformPurge Error]: {ex.Message}");
                }

                return result;
            }
        }

        private static void RecordPurgeTimestamp(DateTime timestamp, HttpServerUtility server = null, HttpApplicationState application = null)
        {
            try
            {
                if (application != null)
                {
                    application["LastWeeklyUserPurge"] = timestamp;
                }
                else if (HttpContext.Current?.Application != null)
                {
                    HttpContext.Current.Application["LastWeeklyUserPurge"] = timestamp;
                }

                string filePath = GetPurgeRecordFilePath(server);
                string dir = Path.GetDirectoryName(filePath);
                if (!string.IsNullOrEmpty(dir) && !Directory.Exists(dir))
                {
                    Directory.CreateDirectory(dir);
                }

                File.WriteAllText(filePath, timestamp.ToString("o"));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"[UserPurgeService.RecordPurgeTimestamp Error]: {ex.Message}");
            }
        }

        private static string GetPurgeRecordFilePath(HttpServerUtility server = null)
        {
            string dataDir = AppDomain.CurrentDomain.GetData("DataDirectory") as string;
            if (!string.IsNullOrEmpty(dataDir))
            {
                return Path.Combine(dataDir, "last_weekly_purge.txt");
            }

            if (server != null)
            {
                return server.MapPath("~/App_Data/last_weekly_purge.txt");
            }

            if (HttpContext.Current?.Server != null)
            {
                return HttpContext.Current.Server.MapPath("~/App_Data/last_weekly_purge.txt");
            }

            return Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App_Data", "last_weekly_purge.txt");
        }
    }
}
