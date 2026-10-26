using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;

namespace Codercept
{
    /// <summary>
    /// Dashboard figures for the signed-in teacher. Every query is limited to the teacher's own courses (Course.TeacherId = @TeacherId).
    /// </summary>
    public static class TeacherDashboardData
    {
        /// <summary>The four cards at the top of the dashboard.</summary>
        public static List<TeacherStat> GetStats()
        {
            int courses, addedThisMonth, learners;
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                "SELECT (SELECT COUNT(*) FROM Course WHERE TeacherId = @TeacherId), " +
                "       (SELECT COUNT(*) FROM Course WHERE TeacherId = @TeacherId AND DateCreation >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)), " +
                "       (SELECT COUNT(DISTINCT lp.LearnerId) FROM LearnerProgress lp INNER JOIN Course c ON c.CourseId = lp.CourseId WHERE c.TeacherId = @TeacherId)", con))
            {
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    reader.Read();
                    courses = reader.GetInt32(0);
                    addedThisMonth = reader.GetInt32(1);
                    learners = reader.GetInt32(2);
                }
            }

            int pending = TeacherCourseData.GetPendingCounts().Values.Sum();
            int unreadPosts, unreadToday;
            TeacherForumData.CountUnread(out unreadPosts, out unreadToday);

            return new List<TeacherStat>
            {
                new TeacherStat { Label = "Total courses", Value = courses.ToString(), Hint = addedThisMonth + " added this month", Icon = "book", Tone = "indigo" },
                new TeacherStat { Label = "Total learners", Value = learners.ToString(), Hint = "Across all your courses", Icon = "learners", Tone = "teal" },
                new TeacherStat
                {
                    Label = "Pending gradings", Value = pending.ToString(), Icon = "clock", Tone = "amber",
                    Hint = pending > 0 ? "Needs your attention" : "You're all caught up",
                    Badge = pending > 0 ? "Action needed" : null
                },
                new TeacherStat
                {
                    Label = "Unread forum posts", Value = unreadPosts.ToString(), Icon = "message", Tone = "rose",
                    Hint = unreadPosts == 0 ? "You're all caught up" : unreadToday > 0 ? unreadToday + " new today" : "Open the forum to catch up"
                }
            };
        }

        /// <summary>
        /// The newest learner activity in the teacher's courses: a learner who finished (submitted) or is working on a quiz,
        /// assessment or exam. A submission that has no Result yet gets a "Mark answers" button.
        /// </summary>
        public static List<TeacherActivity> GetRecentActivities(int count)
        {
            string[] tones = { "teal", "blue", "amber", "rose" };
            List<TeacherActivity> list = new List<TeacherActivity>();
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(
                TeacherCourseData.CourseAttemptsCte +
                "SELECT TOP (@Count) ca.AttemptDate, ca.AttemptStatus, ca.LearnerId, ca.Title, c.CourseTitle, l.Name, " +
                "       CASE WHEN EXISTS (SELECT 1 FROM Result r WHERE r.AttemptId = ca.AttemptId) THEN 0 ELSE 1 END AS Ungraded, ca.CourseId, ca.AttemptId " +
                "FROM CourseAttempt ca " +
                "INNER JOIN Course c ON c.CourseId = ca.CourseId " +
                "INNER JOIN Learner l ON l.LearnerId = ca.LearnerId " +
                "WHERE c.TeacherId = @TeacherId AND ca.AttemptStatus IN ('completed', 'in_progress') " +
                "ORDER BY ca.AttemptDate DESC, ca.AttemptId DESC", con))
            {
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                cmd.Parameters.AddWithValue("@Count", count);
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        bool completed = reader.GetString(1) == "completed";
                        string name = reader.GetString(5);
                        list.Add(new TeacherActivity
                        {
                            Time = TimeLabel(reader.GetDateTime(0)),
                            Initials = InitialsOf(name),
                            Tone = tones[reader.GetInt32(2) % tones.Length],
                            Name = name,
                            Action = completed ? "submitted" : "started",
                            Type = completed ? "submitted" : "started",
                            Detail = reader.GetString(4) + " — " + reader.GetString(3),
                            HasButton = completed && reader.GetInt32(6) == 1,
                            CourseId = reader.GetInt32(7),
                            AttemptId = reader.GetInt32(8)
                        });
                    }
                }
            }
            return list;
        }

        private static string TimeLabel(DateTime when)
        {
            if (when.Date == DateTime.Today) return when.ToString("h:mm tt", CultureInfo.InvariantCulture);
            if (when.Date == DateTime.Today.AddDays(-1)) return "Yesterday";
            return when.ToString("d MMM", CultureInfo.InvariantCulture);
        }

        private static string InitialsOf(string name)
        {
            string[] words = (name ?? "").Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (words.Length == 0) return "?";
            return (words[0].Substring(0, 1) + (words.Length > 1 ? words[1].Substring(0, 1) : "")).ToUpperInvariant();
        }
    }
}
