using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace Codercept
{
    /// <summary>One message of a conversation sent to Groq. Role is "user" or "assistant" (the system prompt is passed separately).</summary>
    public class TeacherAiMessage
    {
        public string Role { get; set; }
        public string Content { get; set; }
    }

    /// <summary>Why a call to Groq did not give a reply.</summary>
    public enum TeacherAiError
    {
        None,
        /// <summary>The key, model or address is missing, or the kill switch is off (see TeacherAiSettings.Problem).</summary>
        NotConfigured,
        /// <summary>Groq refused the key (401 / 403).</summary>
        Unauthorized,
        /// <summary>Too many requests (429); RetryAfterSeconds says how long to wait when Groq told us.</summary>
        RateLimited,
        /// <summary>Groq did not answer in time.</summary>
        Timeout,
        /// <summary>Groq could not be reached (no internet, DNS, TLS, a firewall).</summary>
        Network,
        /// <summary>Groq had a problem (5xx).</summary>
        ServerError,
        /// <summary>Groq rejected the request (400 / 404): for example a wrong model name.</summary>
        BadRequest,
        /// <summary>Groq answered, but the answer is empty, cut off or not in the expected shape.</summary>
        BadReply
    }

    /// <summary>The outcome of one call: the reply text, or what went wrong.</summary>
    public class TeacherAiResult
    {
        public bool Success { get { return Error == TeacherAiError.None; } }
        public string Text { get; set; }
        public TeacherAiError Error { get; set; }
        /// <summary>For the developer only (never shown to a user, and it never contains the key): what Groq or the network said.</summary>
        public string Detail { get; set; }
        public int? RetryAfterSeconds { get; set; }
        /// <summary>The tokens Groq counted for the call (prompt and reply), when it said; used for the usage log.</summary>
        public int? TotalTokens { get; set; }

        /// <summary>A short, friendly sentence that is safe to show to a teacher.</summary>
        public string UserMessage
        {
            get
            {
                switch (Error)
                {
                    case TeacherAiError.None: return "";
                    case TeacherAiError.RateLimited:
                        return RetryAfterSeconds.HasValue
                            ? "The assistant is busy. Please try again in " + RetryAfterSeconds.Value + " seconds."
                            : "The assistant is busy. Please try again in a moment.";
                    case TeacherAiError.Timeout: return "The assistant took too long to answer. Please try again.";
                    case TeacherAiError.BadReply: return "The assistant gave an answer that could not be used. Please try again.";
                    default: return "The assistant is unavailable right now. You can still do this manually.";
                }
            }
        }

        public static TeacherAiResult Fail(TeacherAiError error, string detail)
        {
            return new TeacherAiResult { Error = error, Detail = detail };
        }
    }

    /// <summary>
    /// The only code that talks to Groq (an OpenAI-compatible chat API). It runs on the server, so the key never reaches the browser.
    /// It does not log or store the key, the prompts or the replies. Errors come back as a TeacherAiResult, never as an exception.
    /// </summary>
    public static class TeacherAiClient
    {
        /// <summary>One shared HttpClient (a new one per call would run out of sockets). Each call has its own shorter timeout.</summary>
        private static readonly HttpClient Http;

        /// <summary>The default time to wait for an answer.</summary>
        public const int DefaultTimeoutSeconds = 45;

        static TeacherAiClient()
        {
            // Groq needs TLS 1.2 or newer
            ServicePointManager.SecurityProtocol |= SecurityProtocolType.Tls12;
            Http = new HttpClient { Timeout = TimeSpan.FromSeconds(120) };
        }

        /// <summary>
        /// Sends the conversation to the model named in secrets.config and returns its reply. temperature 0.2 keeps answers steady; jsonMode asks
        /// Groq for one JSON object (the prompt must also say so). maxTokens limits the reply length.
        /// </summary>
        public static Task<TeacherAiResult> ChatAsync(string systemPrompt, IList<TeacherAiMessage> messages, double temperature = 0.2,
            bool jsonMode = false, int maxTokens = 1500)
        {
            string problem = TeacherAiSettings.Problem();
            if (problem != null) return Task.FromResult(TeacherAiResult.Fail(TeacherAiError.NotConfigured, problem));

            return SendAsync(TeacherAiSettings.BaseUrl, TeacherAiSettings.ApiKey, TeacherAiSettings.Model, systemPrompt, messages,
                temperature, jsonMode, maxTokens, DefaultTimeoutSeconds);
        }

        /// <summary>The call itself, with every setting passed in (ChatAsync passes the ones from secrets.config).</summary>
        public static async Task<TeacherAiResult> SendAsync(string baseUrl, string apiKey, string model, string systemPrompt,
            IList<TeacherAiMessage> messages, double temperature, bool jsonMode, int maxTokens, int timeoutSeconds)
        {
            if (messages == null || messages.Count == 0) return TeacherAiResult.Fail(TeacherAiError.BadRequest, "There is no message to send.");

            JArray chat = new JArray();
            if (!string.IsNullOrWhiteSpace(systemPrompt)) chat.Add(new JObject { { "role", "system" }, { "content", systemPrompt } });
            foreach (TeacherAiMessage message in messages)
            {
                if (message.Role != "user" && message.Role != "assistant") return TeacherAiResult.Fail(TeacherAiError.BadRequest, "A message role must be user or assistant.");
                chat.Add(new JObject { { "role", message.Role }, { "content", message.Content ?? "" } });
            }

            JObject body = new JObject
            {
                { "model", model },
                { "messages", chat },
                { "temperature", temperature },
                { "max_completion_tokens", maxTokens }
            };
            if (jsonMode) body["response_format"] = new JObject { { "type", "json_object" } };

            using (CancellationTokenSource timeout = new CancellationTokenSource(TimeSpan.FromSeconds(timeoutSeconds)))
            using (HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Post, baseUrl.TrimEnd('/') + "/chat/completions"))
            {
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", apiKey);
                request.Content = new StringContent(body.ToString(Formatting.None), Encoding.UTF8, "application/json");

                try
                {
                    using (HttpResponseMessage response = await Http.SendAsync(request, timeout.Token).ConfigureAwait(false))
                    {
                        string text = await response.Content.ReadAsStringAsync().ConfigureAwait(false);
                        if (!response.IsSuccessStatusCode) return FromErrorResponse(response, text);
                        return FromReply(text);
                    }
                }
                catch (OperationCanceledException)
                {
                    return TeacherAiResult.Fail(TeacherAiError.Timeout, "No answer within " + timeoutSeconds + " seconds.");
                }
                catch (HttpRequestException ex)
                {
                    return TeacherAiResult.Fail(TeacherAiError.Network, ex.GetBaseException().Message);
                }
            }
        }

        /// <summary>Turns an error status into a TeacherAiResult, keeping Groq's own message for the developer.</summary>
        private static TeacherAiResult FromErrorResponse(HttpResponseMessage response, string text)
        {
            int status = (int)response.StatusCode;
            string detail = "HTTP " + status + ": " + ErrorMessageOf(text);

            TeacherAiError error;
            if (status == 401 || status == 403) error = TeacherAiError.Unauthorized;
            else if (status == 429) error = TeacherAiError.RateLimited;
            else if (status >= 500) error = TeacherAiError.ServerError;
            else error = TeacherAiError.BadRequest;

            TeacherAiResult result = TeacherAiResult.Fail(error, detail);
            if (error == TeacherAiError.RateLimited && response.Headers.RetryAfter != null && response.Headers.RetryAfter.Delta.HasValue)
            {
                result.RetryAfterSeconds = (int)Math.Ceiling(response.Headers.RetryAfter.Delta.Value.TotalSeconds);
            }
            return result;
        }

        /// <summary>Groq's error text ({"error":{"message":...}}), or the start of the body when it is not in that shape.</summary>
        private static string ErrorMessageOf(string text)
        {
            try
            {
                JToken message = JObject.Parse(text).SelectToken("error.message");
                if (message != null) return message.ToString();
            }
            catch (JsonException) { }
            return text.Length > 200 ? text.Substring(0, 200) : text;
        }

        /// <summary>Reads choices[0].message.content; an empty or cut-off answer is a BadReply.</summary>
        private static TeacherAiResult FromReply(string text)
        {
            try
            {
                JObject root = JObject.Parse(text);
                JToken choice = root.SelectToken("choices[0]");
                string content = choice == null ? null : (string)choice.SelectToken("message.content");
                string finish = choice == null ? null : (string)choice.SelectToken("finish_reason");

                if (string.IsNullOrWhiteSpace(content)) return TeacherAiResult.Fail(TeacherAiError.BadReply, "The reply was empty (finish_reason: " + finish + ").");
                if (finish == "length") return TeacherAiResult.Fail(TeacherAiError.BadReply, "The reply was cut off by the length limit.");
                JToken used = root.SelectToken("usage.total_tokens");
                return new TeacherAiResult { Text = content.Trim(), TotalTokens = used != null && used.Type == JTokenType.Integer ? (int?)used : null };
            }
            catch (JsonException ex)
            {
                return TeacherAiResult.Fail(TeacherAiError.BadReply, "The reply was not valid JSON: " + ex.Message);
            }
        }
    }
}
