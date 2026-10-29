using System.Data.SqlClient;
using System.Diagnostics;

namespace Codercept
{
    /// <summary>
    /// What the assistant costs. Every call sent to Groq adds one row to Teacher_AiUsage: the teacher, the feature, how it ended, the tokens
    /// Groq counted and the milliseconds it took. The text of a question or an answer is never stored. The same table gives the daily cap
    /// (AiDailyLimit in secrets.config), which is shared by all teachers because the Groq allowance is shared.
    /// </summary>
    public static class TeacherAiUsage
    {
        /// <summary>True while today's calls (all teachers) are below the daily cap. When the database cannot be read the answer is false: no cap check, no spending.</summary>
        public static bool UnderDailyLimit()
        {
            try
            {
                using (SqlConnection con = TeacherDb.GetConnection())
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Teacher_AiUsage WHERE DateUsed >= CAST(GETDATE() AS DATE)", con))
                {
                    con.Open();
                    return (int)cmd.ExecuteScalar() < TeacherAiSettings.DailyLimit;
                }
            }
            catch (SqlException)
            {
                return false;
            }
        }

        /// <summary>Adds one row. A failure to write the log never breaks the feature.</summary>
        public static void Record(int teacherId, string feature, string outcome, int? tokens, int milliseconds)
        {
            try
            {
                using (SqlConnection con = TeacherDb.GetConnection())
                using (SqlCommand cmd = new SqlCommand(
                    "INSERT INTO Teacher_AiUsage (TeacherId, Feature, Outcome, TotalTokens, DurationMs) VALUES (@TeacherId, @Feature, @Outcome, @Tokens, @Ms)", con))
                {
                    cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                    cmd.Parameters.AddWithValue("@Feature", feature);
                    cmd.Parameters.AddWithValue("@Outcome", outcome);
                    cmd.Parameters.AddWithValue("@Tokens", tokens.HasValue ? (object)tokens.Value : System.DBNull.Value);
                    cmd.Parameters.AddWithValue("@Ms", milliseconds);
                    con.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException ex)
            {
                Trace.TraceWarning("TeacherAiUsage: could not write the usage log: " + ex.Message);
            }
        }
    }
}
