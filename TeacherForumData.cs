using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text.RegularExpressions;

namespace Codercept
{
    /// <summary>What happened when a teacher replied to a forum post.</summary>
    public enum ForumReplyResult
    {
        Saved,
        /// <summary>The post is not one this teacher can see, or the reply it answers is not on that post.</summary>
        NotFound,
        TooLong
    }

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

        /// <summary>Forum.Title is NVARCHAR(255); the form allows 150.</summary>
        public const int MaxTitleLength = 150;

        /// <summary>The longest post text the form accepts.</summary>
        public const int MaxDescriptionLength = 5000;

        /// <summary>Forum.Tags is NVARCHAR(255): all the tags joined with commas must fit.</summary>
        public const int MaxTagsLength = 255;

        /// <summary>The longest reply a teacher can write.</summary>
        public const int MaxReplyLength = 2000;

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
                    "SELECT r.ThreadId, r.PostId, r.ReplyComment, r.IsPinned, l.Name, t.Name, r.ParentThreadId " +
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
                                Pinned = reader.GetString(3) == "Yes",
                                ParentId = reader.IsDBNull(6) ? (int?)null : reader.GetInt32(6)
                            });
                        }
                    }
                }
            }
            return posts;
        }

        /// <summary>
        /// Saves a new post written by the signed-in teacher (Forum.TeacherId; LearnerId stays NULL because a post has exactly one author).
        /// Returns the new PostId, or 0 when the title, text or tags break their limits (the page checks them first and shows the message;
        /// this is the second lock). Tags are stored comma-separated, or NULL when there are none.
        /// </summary>
        public static int CreatePost(string title, string description, List<string> tags)
        {
            title = (title ?? "").Trim();
            description = (description ?? "").Trim();
            string joined = string.Join(",", tags ?? new List<string>());
            if (title.Length == 0 || title.Length > MaxTitleLength) return 0;
            if (description.Length == 0 || description.Length > MaxDescriptionLength) return 0;
            if (joined.Length > MaxTagsLength) return 0;

            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                "INSERT INTO Forum (Title, Content, DatePosted, LearnerId, Tags, TeacherId) " +
                "VALUES (@Title, @Content, GETDATE(), NULL, @Tags, @TeacherId); SELECT CAST(SCOPE_IDENTITY() AS INT)", con))
            {
                cmd.Parameters.AddWithValue("@Title", title);
                cmd.Parameters.AddWithValue("@Content", description);
                cmd.Parameters.AddWithValue("@Tags", joined.Length == 0 ? (object)DBNull.Value : joined);
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                con.Open();
                return (int)cmd.ExecuteScalar();
            }
        }

        /// <summary>
        /// Saves the signed-in teacher's reply to a post (Post_Reply.TeacherId; IsPinned starts as 'No'). One statement does the whole check:
        /// the row is only inserted when the post is one the teacher can see, and, for a reply to a reply, when parentThreadId is a reply of
        /// that same post. So a forged post or reply id inserts nothing.
        /// </summary>
        public static ForumReplyResult AddReply(int postId, string body, int? parentThreadId)
        {
            body = (body ?? "").Trim();
            if (body.Length == 0) return ForumReplyResult.NotFound;
            if (body.Length > MaxReplyLength) return ForumReplyResult.TooLong;

            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                "INSERT INTO Post_Reply (ReplyComment, IsPinned, DatePinned, PostId, LearnerId, TeacherId, TA_Id, ParentThreadId) " +
                "SELECT @Body, 'No', NULL, f.PostId, NULL, @TeacherId, NULL, @ParentThreadId FROM Forum f " +
                "WHERE f.PostId = @PostId AND " + Visible + " " +
                "AND (@ParentThreadId IS NULL OR EXISTS (SELECT 1 FROM Post_Reply p WHERE p.ThreadId = @ParentThreadId AND p.PostId = f.PostId))", con))
            {
                cmd.Parameters.AddWithValue("@Body", body);
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                cmd.Parameters.AddWithValue("@PostId", postId);
                cmd.Parameters.AddWithValue("@ParentThreadId", parentThreadId.HasValue ? (object)parentThreadId.Value : DBNull.Value);
                con.Open();
                return cmd.ExecuteNonQuery() == 1 ? ForumReplyResult.Saved : ForumReplyResult.NotFound;
            }
        }

        /// <summary>
        /// Pins a reply, or unpins it when it is pinned (IsPinned 'Yes' / 'No'; DatePinned is set when pinning and cleared when unpinning).
        /// Returns whether it is pinned now, or null when the reply is not a reply of that post or the post is not one this teacher can see.
        /// </summary>
        public static bool? TogglePin(int postId, int threadId)
        {
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                "UPDATE r SET IsPinned = CASE WHEN r.IsPinned = 'Yes' THEN 'No' ELSE 'Yes' END, " +
                "DatePinned = CASE WHEN r.IsPinned = 'Yes' THEN NULL ELSE GETDATE() END " +
                "OUTPUT INSERTED.IsPinned " +
                "FROM Post_Reply r INNER JOIN Forum f ON f.PostId = r.PostId " +
                "WHERE r.ThreadId = @ThreadId AND r.PostId = @PostId AND " + Visible, con))
            {
                cmd.Parameters.AddWithValue("@ThreadId", threadId);
                cmd.Parameters.AddWithValue("@PostId", postId);
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                con.Open();
                object now = cmd.ExecuteScalar();
                return now == null ? (bool?)null : (string)now == "Yes";
            }
        }

        /// <summary>
        /// Records that the signed-in teacher has seen these posts (ForumRead rows), skipping the ones already recorded. Only learners' posts
        /// are recorded, and only those the teacher can see (the same Visible check as everywhere), so a forged id records nothing. The
        /// "not recorded yet" check is locked so that two requests at once cannot both insert the same row.
        /// </summary>
        public static void MarkRead(IEnumerable<int> postIds)
        {
            List<int> ids = postIds.Distinct().ToList();
            if (ids.Count == 0) return;
            int teacherId = TeacherDb.GetTeacherId();

            string[] names = ids.Select((id, i) => "@Post" + i).ToArray();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                "INSERT INTO ForumRead (PostId, TeacherId, DateRead) SELECT f.PostId, @TeacherId, GETDATE() FROM Forum f " +
                "WHERE f.TeacherId IS NULL AND f.PostId IN (" + string.Join(", ", names) + ") AND " + Visible + " " +
                "AND NOT EXISTS (SELECT 1 FROM ForumRead fr WITH (UPDLOCK, HOLDLOCK) WHERE fr.PostId = f.PostId AND fr.TeacherId = @TeacherId)", con))
            {
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                for (int i = 0; i < ids.Count; i++) cmd.Parameters.AddWithValue(names[i], ids[i]);
                con.Open();
                cmd.ExecuteNonQuery();
            }
        }

        /// <summary>
        /// How many learner posts the signed-in teacher can see but has not opened yet (no ForumRead row; their own posts never count),
        /// and how many of those were posted today.
        /// </summary>
        public static void CountUnread(out int unread, out int today)
        {
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                "SELECT COUNT(*), ISNULL(SUM(CASE WHEN CAST(f.DatePosted AS DATE) = CAST(GETDATE() AS DATE) THEN 1 ELSE 0 END), 0) FROM Forum f " +
                "WHERE f.TeacherId IS NULL AND " + Visible + " " +
                "AND NOT EXISTS (SELECT 1 FROM ForumRead fr WHERE fr.PostId = f.PostId AND fr.TeacherId = @TeacherId)", con))
            {
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    reader.Read();
                    unread = reader.GetInt32(0);
                    today = reader.GetInt32(1);
                }
            }
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
