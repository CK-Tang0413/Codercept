using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.SessionState;

namespace Codercept
{
    /// <summary>
    /// The only door from the teacher pages to Groq. The browser posts JSON here; the key and the prompts stay on the server.
    ///   POST TeacherAiHandler.ashx   header X-Requested-With: XMLHttpRequest, body { "feature": "course" | "chapter" | "chat", ... }
    ///     course   { text: the idea }                                  -> { ok, feature, data: { title, description, domains, durationHours, language?, difficulty? } }
    ///     chapter  { courseId, text: an idea (may be empty) }          -> { ok, feature, data: { title, description, durationHours } }
    ///     chat     { text: the question, history: [{role, content}] }  -> { ok, feature, text }
    ///   Anything wrong gives { ok: false, message } with a status code: 401 not signed in, 403 not a teacher (or not from our pages), 400 bad
    ///   input, 404 course not found, 405 not POST, 422 the idea is not suitable, 429 too many requests, 502 / 503 the AI is unavailable.
    /// Only a signed-in teacher can use it, the course of a chapter request must be one of theirs (checked in SQL), and every reply is checked
    /// by TeacherAiReplies before it is returned. Nothing is saved: the teacher edits the suggestion and saves it with the normal form.
    /// </summary>
    public class TeacherAiHandler : HttpTaskAsyncHandler, IReadOnlySessionState
    {
        private const int MaxBodyBytes = 20000;
        private const int MaxHistoryMessages = 6;

        public override async Task ProcessRequestAsync(HttpContext context)
        {
            if (context.Request.HttpMethod != "POST") { Send(context, 405, Fail("Use POST.")); return; }

            // the same rule as TeacherSite.master.cs: only a signed-in Teacher
            if (context.Session == null || context.Session["UserType"] == null) { Send(context, 401, Fail("Please sign in again.")); return; }
            if (context.Session["UserType"].ToString() != "Teacher" || !(context.Session["UserId"] is int)) { Send(context, 403, Fail("Only teachers can use the assistant.")); return; }
            int teacherId = (int)context.Session["UserId"];

            // a custom header cannot be sent by another website's form, so a request from our own pages is told apart from a forged one
            if (context.Request.Headers["X-Requested-With"] != "XMLHttpRequest") { Send(context, 403, Fail("This request did not come from the portal.")); return; }

            if (TeacherAiSettings.Problem() != null) { Send(context, 503, Fail("The assistant is not available right now. You can still do this manually.")); return; }

            JObject request = ReadBody(context);
            if (request == null) { Send(context, 400, Fail("The request could not be read.")); return; }

            // whatever goes wrong inside (a field of the wrong type, the database, ...) the browser gets a short JSON message, never an error page
            try
            {
                string feature = Str(request["feature"]);
                if (feature == "course") await Course(context, teacherId, request);
                else if (feature == "chapter") await Chapter(context, teacherId, request);
                else if (feature == "chat") await Chat(context, teacherId, request);
                else Send(context, 400, Fail("Unknown feature."));
            }
            catch (Exception ex) when (!(ex is System.Threading.ThreadAbortException))
            {
                Send(context, 500, Fail("Something went wrong. You can still do this manually."));
            }
        }

        // ---- course: title, description, domains and duration

        private static async Task Course(HttpContext context, int teacherId, JObject request)
        {
            string idea = TeacherAiPrompts.Clean(Str(request["text"]), TeacherAiPrompts.MaxTextLength);
            if (idea.Length < 3) { Send(context, 400, Fail("Describe the course you want to create first.")); return; }
            if (!Allowed(context, teacherId)) return;

            // the languages the platform offers (shared reference data): the model may only choose one of these
            List<string> languages = TeacherCourseData.GetLanguages().Select(l => l.Language).Distinct().ToList();

            TeacherAiChecked checkedReply = null;
            for (int attempt = 0; attempt < 2 && (checkedReply == null || !checkedReply.Ok); attempt++)
            {
                TeacherAiResult result = await Ask(teacherId, "course", TeacherAiPrompts.CourseSystem(languages), One(TeacherAiPrompts.CourseMessage(idea)), true, 2000);
                if (!result.Success) { Unavailable(context, result); return; }
                checkedReply = TeacherAiReplies.CheckCourse(result.Text, languages);
                if (checkedReply.Refused) break;
            }
            Finish(context, "course", checkedReply, "That does not look like a programming course idea.");
        }

        // ---- chapter: title, description and duration

        private static async Task Chapter(HttpContext context, int teacherId, JObject request)
        {
            int courseId;
            if (!int.TryParse(Str(request["courseId"]), out courseId)) { Send(context, 400, Fail("Choose a course first.")); return; }

            // only one of this teacher's own courses (TeacherCourseData reads Course.TeacherId in SQL)
            TeacherCourse course = TeacherCourseData.GetCourses().FirstOrDefault(c => c.Id == courseId);
            if (course == null) { Send(context, 404, Fail("That course could not be found.")); return; }
            List<string> existing = TeacherChapterData.GetChapters(course.Id).Select(c => c.Title).Take(40).ToList();

            string idea = TeacherAiPrompts.Clean(Str(request["text"]), TeacherAiPrompts.MaxTextLength);
            if (!Allowed(context, teacherId)) return;

            TeacherAiChecked checkedReply = null;
            for (int attempt = 0; attempt < 2 && (checkedReply == null || !checkedReply.Ok); attempt++)
            {
                TeacherAiResult result = await Ask(teacherId, "chapter", TeacherAiPrompts.Chapter,
                    One(TeacherAiPrompts.ChapterMessage(course.Title, existing, idea)), true, 2000);
                if (!result.Success) { Unavailable(context, result); return; }
                checkedReply = TeacherAiReplies.CheckChapter(result.Text, existing);
                if (checkedReply.Refused) break;
            }
            Finish(context, "chapter", checkedReply, "That idea does not fit this course.");
        }

        // ---- chat: questions about the teacher portal

        private static async Task Chat(HttpContext context, int teacherId, JObject request)
        {
            List<TeacherAiMessage> messages = new List<TeacherAiMessage>();
            JArray history = request["history"] as JArray;
            if (history != null)
            {
                // the browser keeps the conversation: only the last few messages, only user / assistant roles, each cut to the limit
                foreach (JObject item in history.Skip(Math.Max(0, history.Count - MaxHistoryMessages)).OfType<JObject>())
                {
                    string role = Str(item["role"]);
                    string content = TeacherAiPrompts.Clean(Str(item["content"]), TeacherAiPrompts.MaxTextLength);
                    if ((role == "user" || role == "assistant") && content.Length > 0) messages.Add(new TeacherAiMessage { Role = role, Content = content });
                }
            }
            string question = TeacherAiPrompts.Clean(Str(request["text"]), TeacherAiPrompts.MaxTextLength);
            if (question.Length == 0) { Send(context, 400, Fail("Type a question first.")); return; }
            messages.Add(new TeacherAiMessage { Role = "user", Content = question });
            // the conversation has to start with the teacher and take turns
            while (messages.Count > 1 && messages[0].Role != "user") messages.RemoveAt(0);

            if (!Allowed(context, teacherId)) return;

            TeacherAiResult result = await Ask(teacherId, "chat", TeacherAiPrompts.Chat, messages, false, 1500);
            if (!result.Success) { Unavailable(context, result); return; }

            string answer = result.Text.Length > 1500 ? result.Text.Substring(0, 1500).TrimEnd() + "..." : result.Text;
            Send(context, 200, new JObject { { "ok", true }, { "feature", "chat" }, { "text", answer } });
        }

        // ---- shared

        private static List<TeacherAiMessage> One(string text)
        {
            return new List<TeacherAiMessage> { new TeacherAiMessage { Role = "user", Content = text } };
        }

        /// <summary>One call to Groq, written to the usage log (who, which feature, how it ended, tokens, time: never the text).</summary>
        private static async Task<TeacherAiResult> Ask(int teacherId, string feature, string systemPrompt, IList<TeacherAiMessage> messages, bool jsonMode, int maxTokens)
        {
            Stopwatch watch = Stopwatch.StartNew();
            TeacherAiResult result = await TeacherAiClient.ChatAsync(systemPrompt, messages, 0.2, jsonMode, maxTokens);
            TeacherAiUsage.Record(teacherId, feature, result.Success ? "ok" : result.Error.ToString(), result.TotalTokens, (int)watch.ElapsedMilliseconds);
            return result;
        }

        /// <summary>Applies the daily cap and the per-teacher limit; sends 429 and returns false when either is used up.</summary>
        private static bool Allowed(HttpContext context, int teacherId)
        {
            if (!TeacherAiUsage.UnderDailyLimit())
            {
                Send(context, 429, Fail("The assistant has reached its limit for today. You can still do this manually."));
                return false;
            }
            int wait;
            if (TeacherAiLimiter.TryAcquire(teacherId, out wait)) return true;
            JObject body = Fail("Please wait " + wait + " seconds before asking again.");
            body["retryAfter"] = wait;
            context.Response.AddHeader("Retry-After", wait.ToString());
            Send(context, 429, body);
            return false;
        }

        /// <summary>Sends the checked suggestion, or the right refusal.</summary>
        private static void Finish(HttpContext context, string feature, TeacherAiChecked checkedReply, string refusal)
        {
            if (checkedReply != null && checkedReply.Ok)
            {
                Send(context, 200, new JObject { { "ok", true }, { "feature", feature }, { "data", checkedReply.Data } });
            }
            else if (checkedReply != null && checkedReply.Refused)
            {
                Send(context, 422, Fail(refusal));
            }
            else
            {
                Send(context, 502, Fail("The assistant gave an answer that could not be used. Please try again."));
            }
        }

        private static void Unavailable(HttpContext context, TeacherAiResult result)
        {
            JObject body = Fail(result.UserMessage);
            if (result.RetryAfterSeconds.HasValue) body["retryAfter"] = result.RetryAfterSeconds.Value;
            Send(context, result.Error == TeacherAiError.RateLimited ? 429 : result.Error == TeacherAiError.Timeout ? 504 : 502, body);
        }

        private static JObject ReadBody(HttpContext context)
        {
            if (context.Request.ContentLength <= 0 || context.Request.ContentLength > MaxBodyBytes) return null;
            try
            {
                using (StreamReader reader = new StreamReader(context.Request.InputStream, Encoding.UTF8))
                {
                    return JObject.Parse(reader.ReadToEnd());
                }
            }
            catch (JsonException)
            {
                return null;
            }
        }

        /// <summary>A JSON string or number as text; null for anything else (an object, an array, null), so a wrongly shaped request cannot throw.</summary>
        private static string Str(JToken token)
        {
            JValue value = token as JValue;
            return value == null || value.Value == null ? null : Convert.ToString(value.Value, CultureInfo.InvariantCulture);
        }

        private static JObject Fail(string message)
        {
            return new JObject { { "ok", false }, { "message", message } };
        }

        private static void Send(HttpContext context, int status, JObject body)
        {
            context.Response.Clear();
            context.Response.StatusCode = status;
            context.Response.TrySkipIisCustomErrors = true;
            context.Response.ContentType = "application/json";
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            context.Response.Cache.SetNoStore();
            context.Response.Write(body.ToString(Formatting.None));
        }
    }

    /// <summary>
    /// How often one teacher may use the assistant: at least MinGapSeconds between two requests and at most MaxPerHour per hour. Kept in memory,
    /// so it starts again when the site restarts; it protects the Groq allowance of the whole team from one runaway page or user.
    /// </summary>
    public static class TeacherAiLimiter
    {
        public const int MinGapSeconds = 3;
        public const int MaxPerHour = 30;

        private static readonly Dictionary<int, Queue<DateTime>> Used = new Dictionary<int, Queue<DateTime>>();

        /// <summary>True and the use is counted when allowed; otherwise false and wait is how many seconds to wait.</summary>
        public static bool TryAcquire(int teacherId, out int wait)
        {
            DateTime now = DateTime.UtcNow;
            lock (Used)
            {
                Queue<DateTime> times;
                if (!Used.TryGetValue(teacherId, out times)) { times = new Queue<DateTime>(); Used[teacherId] = times; }
                while (times.Count > 0 && now - times.Peek() > TimeSpan.FromHours(1)) times.Dequeue();

                DateTime last = times.Count == 0 ? DateTime.MinValue : times.Last();
                if (times.Count > 0 && (now - last).TotalSeconds < MinGapSeconds)
                {
                    wait = (int)Math.Ceiling(MinGapSeconds - (now - last).TotalSeconds);
                    return false;
                }
                if (times.Count >= MaxPerHour)
                {
                    wait = (int)Math.Ceiling((times.Peek().AddHours(1) - now).TotalSeconds);
                    return false;
                }
                times.Enqueue(now);
                wait = 0;
                return true;
            }
        }
    }
}
