using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;

namespace Codercept
{
    /// <summary>What came out of checking a model reply.</summary>
    public class TeacherAiChecked
    {
        /// <summary>The reply is usable: Data holds the cleaned fields.</summary>
        public bool Ok { get; set; }
        /// <summary>The model said the idea is not suitable (its own {"error": ...}); not a failure of the AI.</summary>
        public bool Refused { get; set; }
        public JObject Data { get; set; }
        /// <summary>For the developer: what was wrong with the reply.</summary>
        public string Why { get; set; }
    }

    /// <summary>
    /// Never trust the model: every field of a JSON reply is read, cut to what the forms allow and checked here before it is sent to the
    /// browser. The limits are the ones of TeacherCourseCreate (title from 4 characters, description from 20, whole hours, up to
    /// TeacherCourseData.MaxDomains domains) and TeacherChapterAdd (title 4 to 50 characters, duration 0.5 to 1000 hours in halves).
    /// The browser then puts the values into the normal form, where the teacher edits them and the normal save checks them again.
    /// </summary>
    public static class TeacherAiReplies
    {
        public const int CourseTitleMax = 80;
        /// <summary>The longest description: the course form's description box holds 300 characters.</summary>
        public const int CourseDescriptionMax = 300;
        public const int DescriptionMax = 1000;
        public const int ChapterTitleMax = 50;
        /// <summary>The most domains the AI suggests (the form allows more).</summary>
        public const int DomainsMax = 3;

        /// <summary>Reads the JSON object out of a reply, also when the model wrapped it in a markdown fence or added a sentence around it.</summary>
        public static JObject ParseObject(string text)
        {
            if (string.IsNullOrWhiteSpace(text)) return null;
            int start = text.IndexOf('{');
            int end = text.LastIndexOf('}');
            if (start < 0 || end <= start) return null;
            try
            {
                return JObject.Parse(text.Substring(start, end - start + 1));
            }
            catch (JsonException)
            {
                return null;
            }
        }

        /// <summary>
        /// Checks a course suggestion: title, description, domains and duration in whole hours. The language must be one of the offered
        /// languages and the difficulty Easy, Medium or Hard; a wrong or missing one is left out (the form keeps its own choice).
        /// </summary>
        public static TeacherAiChecked CheckCourse(string text, IList<string> languages = null)
        {
            JObject reply = ParseObject(text);
            if (reply == null) return Bad("The reply is not a JSON object.");
            if (reply["error"] != null) return new TeacherAiChecked { Refused = true, Why = (string)reply["error"] };

            string title = CutAtWord(Text(reply["title"]), CourseTitleMax);
            if (title.Length < 4) return Bad("The title is missing or too short.");
            string description = CutAtSentence(Text(reply["description"]), CourseDescriptionMax);
            if (description.Length < 20) return Bad("The description is missing or too short.");

            double hours;
            if (!Number(reply["durationHours"], out hours)) return Bad("The duration is not a number.");
            int wholeHours = (int)Math.Max(1, Math.Min(200, Math.Round(hours)));

            // each domain on its own through the form's own check, so one bad name drops only itself
            List<string> domains = new List<string>();
            JArray suggested = reply["domains"] as JArray;
            if (suggested != null)
            {
                foreach (JToken token in suggested)
                {
                    string error;
                    List<string> clean = TeacherCourseData.CleanDomains(new[] { Text(token) }, out error);
                    if (clean != null && clean.Count == 1 && !domains.Any(d => string.Equals(d, clean[0], StringComparison.OrdinalIgnoreCase))) domains.Add(clean[0]);
                    if (domains.Count == DomainsMax) break;
                }
            }

            JObject data = new JObject
            {
                { "title", title },
                { "description", description },
                { "domains", new JArray(domains) },
                { "durationHours", wholeHours }
            };

            string language = languages == null ? null : languages.FirstOrDefault(l => string.Equals(l, Text(reply["language"]), StringComparison.OrdinalIgnoreCase));
            if (language != null) data["language"] = language;
            string difficulty = new[] { "Easy", "Medium", "Hard" }.FirstOrDefault(d => string.Equals(d, Text(reply["difficulty"]), StringComparison.OrdinalIgnoreCase));
            if (difficulty != null) data["difficulty"] = difficulty;

            return new TeacherAiChecked { Ok = true, Data = data };
        }

        /// <summary>Checks a chapter suggestion: title, description and duration in hours (halves, 0.5 to 1000). A title the course already has is refused.</summary>
        public static TeacherAiChecked CheckChapter(string text, IList<string> existingTitles)
        {
            JObject reply = ParseObject(text);
            if (reply == null) return Bad("The reply is not a JSON object.");
            if (reply["error"] != null) return new TeacherAiChecked { Refused = true, Why = (string)reply["error"] };

            string title = CutAtWord(Text(reply["title"]), ChapterTitleMax);
            if (title.Length < 4) return Bad("The title is missing or too short.");
            if (existingTitles != null && existingTitles.Any(t => string.Equals(t, title, StringComparison.OrdinalIgnoreCase))) return Bad("The title repeats an existing chapter.");
            string description = CutAtSentence(Text(reply["description"]), DescriptionMax);
            if (description.Length == 0) return Bad("The description is missing.");

            double hours;
            if (!Number(reply["durationHours"], out hours)) return Bad("The duration is not a number.");
            double halves = Math.Max(0.5, Math.Min(1000, Math.Round(hours * 2, MidpointRounding.AwayFromZero) / 2));

            return new TeacherAiChecked
            {
                Ok = true,
                Data = new JObject { { "title", title }, { "description", description }, { "durationHours", halves } }
            };
        }

        private static TeacherAiChecked Bad(string why)
        {
            return new TeacherAiChecked { Why = why };
        }

        /// <summary>The value as trimmed text with single spaces; only strings and numbers count, anything else is empty.</summary>
        private static string Text(JToken token)
        {
            if (token == null || (token.Type != JTokenType.String && token.Type != JTokenType.Integer && token.Type != JTokenType.Float)) return "";
            return System.Text.RegularExpressions.Regex.Replace(token.ToString().Trim(), @"\s+", " ");
        }

        /// <summary>A number, whether the model wrote 12, 12.5 or "12".</summary>
        private static bool Number(JToken token, out double value)
        {
            value = 0;
            if (token == null) return false;
            if (token.Type == JTokenType.Integer || token.Type == JTokenType.Float)
            {
                value = (double)token;
                return !double.IsNaN(value) && !double.IsInfinity(value);
            }
            return token.Type == JTokenType.String && double.TryParse((string)token, NumberStyles.Float, CultureInfo.InvariantCulture, out value);
        }

        /// <summary>Cuts to the limit at a word end (a title).</summary>
        private static string CutAtWord(string text, int max)
        {
            if (text.Length <= max) return text;
            string cut = text.Substring(0, max);
            int space = cut.LastIndexOf(' ');
            return (space >= max / 2 ? cut.Substring(0, space) : cut).TrimEnd(' ', ',', ';', ':', '-');
        }

        /// <summary>Cuts to the limit at the end of a sentence when there is one (a description).</summary>
        private static string CutAtSentence(string text, int max)
        {
            if (text.Length <= max) return text;
            string cut = text.Substring(0, max);
            int stop = Math.Max(cut.LastIndexOf(". "), cut.LastIndexOf('.') == cut.Length - 1 ? cut.Length - 1 : -1);
            return (stop >= max / 2 ? cut.Substring(0, stop + 1) : cut).TrimEnd();
        }
    }
}
