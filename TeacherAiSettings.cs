using System;
using System.Configuration;

namespace Codercept
{
    /// <summary>
    /// The Groq settings for the teacher AI features, read from secrets.config (loaded into Web.config's appSettings; the file is not in Git).
    /// The API key is only read here, for the server-side call to Groq: it is never written to a page, a log or an error message.
    ///   GroqApiKey   the key (starts with gsk_)
    ///   GroqModel    the model name, exactly as the Groq console lists it
    ///   GroqBaseUrl  optional; defaults to https://api.groq.com/openai/v1
    ///   AiEnabled    optional kill switch; "false" turns every AI feature off
    ///   AiDailyLimit optional; the most calls to Groq per day for all teachers together (default 300)
    /// </summary>
    public static class TeacherAiSettings
    {
        public const string DefaultBaseUrl = "https://api.groq.com/openai/v1";
        public const int DefaultDailyLimit = 300;

        private static string Read(string name)
        {
            string value = ConfigurationManager.AppSettings[name];
            return value == null ? "" : value.Trim();
        }

        public static string ApiKey
        {
            get { return Read("GroqApiKey"); }
        }

        public static string Model
        {
            get { return Read("GroqModel"); }
        }

        /// <summary>The Groq address without a trailing slash.</summary>
        public static string BaseUrl
        {
            get
            {
                string value = Read("GroqBaseUrl");
                return (value.Length == 0 ? DefaultBaseUrl : value).TrimEnd('/');
            }
        }

        /// <summary>The daily cap from AiDailyLimit; a missing, zero or invalid value gives the default.</summary>
        public static int DailyLimit
        {
            get
            {
                int limit;
                return int.TryParse(Read("AiDailyLimit"), out limit) && limit > 0 ? limit : DefaultDailyLimit;
            }
        }

        /// <summary>False only when AiEnabled is set to "false" (the kill switch).</summary>
        public static bool Enabled
        {
            get { return !string.Equals(Read("AiEnabled"), "false", StringComparison.OrdinalIgnoreCase); }
        }

        /// <summary>Why the AI cannot be used (safe to show in a log or a developer message: it never contains the key), or null when it is ready.</summary>
        public static string Problem()
        {
            if (!Enabled) return "The AI features are turned off (AiEnabled is false in secrets.config).";
            if (ApiKey.Length == 0) return "GroqApiKey is missing in secrets.config.";
            if (Model.Length == 0) return "GroqModel is missing in secrets.config.";

            Uri url;
            if (!Uri.TryCreate(BaseUrl, UriKind.Absolute, out url) || url.Scheme != Uri.UriSchemeHttps)
            {
                return "GroqBaseUrl must be a full https address.";
            }
            return null;
        }

        /// <summary>True when the AI features are switched on and Groq is configured.</summary>
        public static bool IsReady
        {
            get { return Problem() == null; }
        }
    }
}
