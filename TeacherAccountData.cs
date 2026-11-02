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
        /// <summary>Teacher.QualificationName, or null when the teacher has none on record.</summary>
        public string QualificationName { get; set; }
        /// <summary>The stored path of the qualification document (Teacher.QualificationDocument), or null.</summary>
        public string QualificationDocument { get; set; }
        /// <summary>When the application was reviewed (Application.DateReviewed); null for accounts that never had one.</summary>
        public DateTime? QualificationVerified { get; set; }
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

        /// <summary>
        /// Deactivates the signed-in teacher's own account (AccStatus = 'Inactive'); sign-in refuses an account that is not Active. Nothing is
        /// deleted: the teacher's courses, learners' results and forum posts stay as they are. False when the account was not active.
        /// </summary>
        public static bool DeactivateAccount()
        {
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                "UPDATE Teacher SET AccStatus = 'Inactive' WHERE TeacherId = @TeacherId AND AccStatus = 'Active'", con))
            {
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                con.Open();
                return cmd.ExecuteNonQuery() == 1;
            }
        }

        /// <summary>
        /// The browser URL of a stored qualification document, or "" when there is none, the path is not one of the upload folders or the file is missing.
        /// Registration stores "~/media/uploads/qualifications/qual_x.pdf", the sample data "~/UploadedCertificates/x.pdf"; "media/..." and "/media/..." also work.
        /// </summary>
        public static string DocumentUrl(string stored)
        {
            if (string.IsNullOrWhiteSpace(stored)) return "";
            string path = stored.Trim().Replace('\\', '/');
            if (path.StartsWith("~/")) path = path.Substring(2);
            path = path.TrimStart('/');
            if (path.Contains("..") || path.Contains(":")) return "";
            bool known = path.StartsWith("media/uploads/", StringComparison.OrdinalIgnoreCase)
                || path.StartsWith("UploadedCertificates/", StringComparison.OrdinalIgnoreCase);
            if (!known) return "";
            string virtualPath = "~/" + path;
            if (!System.IO.File.Exists(System.Web.HttpContext.Current.Server.MapPath(virtualPath))) return "";
            return System.Web.VirtualPathUtility.ToAbsolute(virtualPath);
        }

        /// <summary>The signed-in teacher's details, or null when the account no longer exists.</summary>
        public static TeacherProfile GetProfile()
        {
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                "SELECT t.Name, t.Email, t.Age, t.Region, t.TeachingLevel, t.DateJoined, t.QualificationName, t.QualificationDocument, a.DateReviewed " +
                "FROM Teacher t LEFT JOIN Application a ON a.ApplicationId = t.ApplicationId WHERE t.TeacherId = @TeacherId", con))
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
                        DateJoined = reader.GetDateTime(5),
                        QualificationName = reader.IsDBNull(6) ? null : reader.GetString(6),
                        QualificationDocument = reader.IsDBNull(7) ? null : reader.GetString(7),
                        QualificationVerified = reader.IsDBNull(8) ? (DateTime?)null : reader.GetDateTime(8)
                    };
                }
            }
        }
    }
}
