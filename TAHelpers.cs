using System;
using System.Configuration;
using System.Net;
using System.Text.RegularExpressions;

namespace Codercept
{
    // Small helpers shared by the Teaching Assistant pages
    public static class TAHelpers
    {
        public static string ConnectionString
        {
            get { return ConfigurationManager.ConnectionStrings["Codercept_db"].ConnectionString; }
        }

        public static string TimeAgo(DateTime when)
        {
            TimeSpan span = DateTime.Now - when;

            if (span.TotalMinutes < 1) return "Just now";
            if (span.TotalMinutes < 60) return $"{(int)span.TotalMinutes} minute{((int)span.TotalMinutes != 1 ? "s" : "")} ago";
            if (span.TotalHours < 24) return $"{(int)span.TotalHours} hour{((int)span.TotalHours != 1 ? "s" : "")} ago";
            if (span.TotalDays < 2) return "Yesterday";
            return $"{(int)span.TotalDays} days ago";
        }

        // Maps a GradingProgress status (or "Pending") to its badge CSS class
        public static string GetStatusCss(string status)
        {
            switch (status)
            {
                case GradingStatus.InProgress: return "status-inprogress";
                case GradingStatus.Reviewed: return "status-reviewed";
                case GradingStatus.Approved: return "status-approved";
                default: return "status-pending";
            }
        }

        private static readonly Regex CodeFence = new Regex(@"```[ \t]*([A-Za-z0-9+#.\-]*)[ \t]*\r?\n(.*?)```[ \t]*\r?\n?", RegexOptions.Singleline | RegexOptions.Compiled);

        // HTML-encodes user text and turns ```lang fenced blocks into formatted code blocks.
        // The result is safe to write straight into the page; use it inside an element with white-space: pre-wrap.
        public static string FormatRichText(string text)
        {
            if (string.IsNullOrEmpty(text)) return "";

            string encoded = WebUtility.HtmlEncode(text);
            return CodeFence.Replace(encoded, m =>
            {
                string lang = m.Groups[1].Value;
                string label = lang.Length > 0 ? "<span class=\"code-lang\">" + lang + "</span>" : "";
                return "<div class=\"code-wrap\">" + label + "<pre class=\"code-block\"><code>" + m.Groups[2].Value.TrimEnd('\r', '\n') + "</code></pre></div>";
            });
        }

        // SQL conditions on a Forum row aliased "f", shared by the forum page and the dashboard
        // Deleted posts are gone for everyone, hidden posts are only visible to staff
        public const string ForumNotDeleted = "NOT EXISTS (SELECT 1 FROM [dbo].[Moderate_Forum] m WHERE m.PostId = f.PostId AND m.ModerationAction = 'Delete')";
        public const string ForumVisibleToLearners = "NOT EXISTS (SELECT 1 FROM [dbo].[Moderate_Forum] m WHERE m.PostId = f.PostId AND m.ModerationAction IN ('Hide', 'Delete'))";
        // A post is Verified once one of its replies is pinned as the answer
        public const string ForumHasVerifiedAnswer = "EXISTS (SELECT 1 FROM [dbo].[Post_Reply] r WHERE r.PostId = f.PostId AND r.IsPinned = 'Yes')";

        // Wraps a whole answer (for example a Code question) as one code block
        public static string FormatCodeBlock(string code)
        {
            return "<div class=\"code-wrap\"><pre class=\"code-block\"><code>" + WebUtility.HtmlEncode(code ?? "") + "</code></pre></div>";
        }
    }

    // Grading statuses stored in GradingProgress.ProgressStatus ("Pending" means no row exists yet)
    public static class GradingStatus
    {
        public const string Pending = "Pending";
        public const string InProgress = "In Progress";
        public const string Reviewed = "Reviewed";
        public const string Approved = "Approved";
    }

    // Forum moderation actions stored in Moderate_Forum.ModerationAction
    public static class ModerationAction
    {
        public const string Hide = "Hide";
        public const string Flag = "Flag";
        public const string Delete = "Delete";
    }
}
