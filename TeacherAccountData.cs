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

        /// <summary>
        /// Saves the signed-in teacher's name, age, address (Teacher.Region; empty is stored as NULL) and teaching level. Only their own row
        /// can change. The caller has already checked the values; false means the account no longer exists.
        /// </summary>
        public static bool UpdateProfile(string name, int age, string region, string teachingLevel)
        {
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                "UPDATE Teacher SET Name = @Name, Age = @Age, Region = @Region, TeachingLevel = @Level WHERE TeacherId = @TeacherId", con))
            {
                cmd.Parameters.AddWithValue("@Name", name);
                cmd.Parameters.AddWithValue("@Age", age);
                cmd.Parameters.AddWithValue("@Region", string.IsNullOrEmpty(region) ? (object)DBNull.Value : region);
                cmd.Parameters.AddWithValue("@Level", teachingLevel);
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                con.Open();
                return cmd.ExecuteNonQuery() == 1;
            }
        }

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
