using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;

namespace Codercept
{
    /// <summary>
    /// Shared database helper for the Teacher portal. Every teacher query opens its connection here and
    /// gets the signed-in teacher's ID from here, so the pattern is the same on every page:
    ///
    ///   int teacherId = TeacherDb.GetTeacherId();
    ///   using (SqlConnection con = TeacherDb.GetConnection())
    ///   using (SqlCommand cmd = new SqlCommand("SELECT ... FROM Course WHERE TeacherId = @TeacherId", con))
    ///   {
    ///       cmd.Parameters.AddWithValue("@TeacherId", teacherId);
    ///       con.Open();
    ///       ...
    ///   }
    /// </summary>
    public static class TeacherDb
    {
        /// <summary>A new, closed connection to Codercept_db. The caller opens it and disposes it (using block).</summary>
        public static SqlConnection GetConnection()
        {
            string connString = ConfigurationManager.ConnectionStrings["Codercept_db"].ConnectionString;
            return new SqlConnection(connString);
        }

        /// <summary>
        /// The signed-in teacher's TeacherId, read from the session that signIn.aspx.cs filled in.
        /// Anyone who is not a signed-in Teacher is sent to signIn.aspx.
        /// </summary>
        public static int GetTeacherId()
        {
            HttpContext context = HttpContext.Current;
            if (context != null && context.Session != null
                && context.Session["UserType"] as string == "Teacher"
                && context.Session["UserId"] is int)
            {
                return (int)context.Session["UserId"];
            }

            // The master page already blocks non-teachers; this is the second lock in case a page forgets it.
            if (context != null) context.Response.Redirect("~/signIn.aspx");
            throw new UnauthorizedAccessException("A signed-in teacher is required.");
        }
    }
}
