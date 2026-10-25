using System;
using System.Data.SqlClient;

namespace Codercept
{
    /// <summary>The signed-in teacher's own details (what the My Account page shows).</summary>
    public class TeacherProfile
    {
        public string Name { get; set; }
        public string Email { get; set; }
        public int? Age { get; set; }
        /// <summary>Teacher.Region, shown as "Address" on the My Account page.</summary>
        public string Region { get; set; }
        /// <summary>Beginner, Intermediate or Advanced; null when it was never set.</summary>
        public string TeachingLevel { get; set; }
        public DateTime DateJoined { get; set; }
    }

    /// <summary>
    /// Database queries for the teacher's own account. Every query is filtered on the signed-in teacher's id (TeacherDb.GetTeacherId()),
    /// so a teacher can only ever read or change their own row.
    /// </summary>
    public static class TeacherAccountData
    {
        /// <summary>The levels a teacher can choose from, as stored in Teacher.TeachingLevel.</summary>
        public static readonly string[] TeachingLevels = { "Beginner", "Intermediate", "Advanced" };

        /// <summary>The signed-in teacher's details, or null when the account no longer exists.</summary>
        public static TeacherProfile GetProfile()
        {
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                "SELECT Name, Email, Age, Region, TeachingLevel, DateJoined FROM Teacher WHERE TeacherId = @TeacherId", con))
            {
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (!reader.Read()) return null;
                    return new TeacherProfile
                    {
                        Name = reader.GetString(0),
                        Email = reader.GetString(1),
                        Age = reader.IsDBNull(2) ? (int?)null : reader.GetInt32(2),
                        Region = reader.IsDBNull(3) ? "" : reader.GetString(3),
                        TeachingLevel = reader.IsDBNull(4) ? null : reader.GetString(4),
                        DateJoined = reader.GetDateTime(5)
                    };
                }
            }
        }
    }
}
