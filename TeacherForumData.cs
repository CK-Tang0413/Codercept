using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text.RegularExpressions;

namespace Codercept
{
    /// <summary>
    /// Database queries for the teacher forum. A forum post has no course, so which posts a teacher sees is decided here, in SQL:
    /// the posts the teacher wrote, and the posts of learners who are enrolled (LearnerProgress) in one of the teacher's courses
    /// (Course.TeacherId). Replies are read only for those posts.
    /// </summary>
    public static class TeacherForumData
    {
        /// <summary>The posts of Forum f the signed-in teacher may see.</summary>
        private const string Visible =
            "(f.TeacherId = @TeacherId OR EXISTS (SELECT 1 FROM LearnerProgress lp INNER JOIN Course c ON c.CourseId = lp.CourseId " +
            "WHERE lp.LearnerId = f.LearnerId AND c.TeacherId = @TeacherId))";

        /// <summary>The longest excerpt shown on a post card.</summary>
        private const int ExcerptLength = 110;

        /// <summary>The posts the signed-in teacher can see, newest first, each with its replies in the order they were written.</summary>
        public static List<TeacherForumPost> GetPosts()
        {
            List<TeacherForumPost> posts = new List<TeacherForumPost>();
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand(
                    "SELECT f.PostId, f.Title, f.Content, f.Tags FROM Forum f WHERE " + Visible + " ORDER BY f.DatePosted DESC, f.PostId DESC", con))
                {
                    cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            posts.Add(new TeacherForumPost
                            {
                                Id = reader.GetInt32(0),
                                Title = reader.GetString(1),
                                Excerpt = ExcerptOf(reader.GetString(2)),
                                Tags = TagsOf(reader.IsDBNull(3) ? "" : reader.GetString(3)),
                                Comments = new List<TeacherForumComment>()
                            });
                        }
                    }
                }

                // teaching-assistant replies (TA_Id) are not shown yet
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT r.ThreadId, r.PostId, r.ReplyComment, r.IsPinned, l.Name, t.Name " +
                    "FROM Post_Reply r INNER JOIN Forum f ON f.PostId = r.PostId " +
                    "LEFT JOIN Learner l ON l.LearnerId = r.LearnerId LEFT JOIN Teacher t ON t.TeacherId = r.TeacherId " +
                    "WHERE r.TA_Id IS NULL AND " + Visible + " ORDER BY r.ThreadId", con))
                {
                    cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int postId = reader.GetInt32(1);
                            TeacherForumPost post = posts.FirstOrDefault(p => p.Id == postId);
                            if (post == null) continue;
                            bool byTeacher = !reader.IsDBNull(5);
                            string name = byTeacher ? reader.GetString(5) : reader.IsDBNull(4) ? "Unknown" : reader.GetString(4);
                            post.Comments.Add(new TeacherForumComment
                            {
                                Id = reader.GetInt32(0),
                                Name = name,
                                Initials = name.Substring(0, 1).ToUpperInvariant(),
                                Role = byTeacher ? "TEACHER" : "LEARNER",
                                Body = reader.GetString(2),
                                Pinned = reader.GetString(3) == "Yes"
                            });
                        }
                    }
                }
            }
            return posts;
        }

        /// <summary>The post text on one line, cut to about ExcerptLength characters.</summary>
        private static string ExcerptOf(string content)
        {
            string text = Regex.Replace(content ?? "", @"\s+", " ").Trim();
            return text.Length > ExcerptLength ? text.Substring(0, ExcerptLength).TrimEnd() + "..." : text;
        }

        /// <summary>"Python,Fundamental" -> two tags (Forum.Tags is comma-separated).</summary>
        private static List<string> TagsOf(string tags)
        {
            return tags.Split(',').Select(t => t.Trim()).Where(t => t.Length > 0).ToList();
        }
    }
}
