# Teacher AI assistant (Groq)

The teacher portal has three AI helpers. They only **suggest**: a teacher reads the suggestion, edits it and saves it with the normal form.

| Where | What it does |
|---|---|
| Create a Course, "Suggest with AI" | Suggests a title, description, programming language, difficulty, domains and duration from the teacher's idea |
| Add Chapter, "Suggest with AI" | Reads the course and its existing chapters, then suggests the next chapter (title, description, duration) |
| Round chat button on every teacher page | Answers questions about how the Teacher Portal works (only from a fixed list of facts) |

Only signed-in teachers can use it. Nothing was added to learner or admin pages.

## Files

| File | Job |
|---|---|
| `TeacherAiSettings.cs` | Reads the settings from `secrets.config` and decides if the AI is ready |
| `TeacherAiClient.cs` | The one place that calls Groq (key, timeout, error handling). Never throws, never logs the key |
| `TeacherAiPrompts.cs` | The three system prompts, the FACTS list of the chatbot, and the text cleaning / redaction |
| `TeacherAiReplies.cs` | Checks every model reply before it is used |
| `TeacherAiHandler.ashx` + `.cs` | The only door from the browser: `POST TeacherAiHandler.ashx` |
| `TeacherAiUsage.cs` | The usage log and the daily cap |
| `TeacherPortal.js` (sections `[ai]`, `initAiCourse`, `initAiChapter`, `initChat`) | The buttons, dialogs and chat panel |
| `TeacherCourseCreate.aspx`, `TeacherChapterAdd.aspx`, `TeacherSite.master` | The markup of the buttons, dialogs and chat |
| `Database/database_setup.sql` | Table `Teacher_AiUsage` |

## Set up (each developer, once)

1. Make a free key at the Groq console (https://console.groq.com).
2. Copy `secrets.example.config` to `secrets.config` (it is not in Git) and fill in your own values:
   - `GroqApiKey`: your key (starts with `gsk_`)
   - `GroqModel`: the model name exactly as the console lists it (we use `openai/gpt-oss-120b`)
   - `GroqBaseUrl`: optional, defaults to `https://api.groq.com/openai/v1`
   - `AiEnabled`: `false` is the kill switch; the buttons and the chat disappear and the endpoint answers 503
   - `AiDailyLimit`: optional, most calls per day for all teachers together (default 300)
3. Run `Database/database_setup.sql` (it creates `Teacher_AiUsage`).
4. Changing `secrets.config` restarts the site after a few seconds, which signs everyone out.

**Never put a real key anywhere else** (not in code, `Web.config`, a chat, a screenshot or a commit). If a key leaks, delete it in the Groq console and make a new one.

## The endpoint

`POST TeacherAiHandler.ashx`, header `X-Requested-With: XMLHttpRequest`, JSON body:

- `{ "feature": "course", "text": "the idea" }` returns `data: { title, description, domains, durationHours, language?, difficulty? }`
- `{ "feature": "chapter", "courseId": 8, "text": "optional idea" }` returns `data: { title, description, durationHours }`
- `{ "feature": "chat", "text": "the question", "history": [{ "role", "content" }] }` returns `text`

Errors are `{ "ok": false, "message": "..." }` with a status code: 400 bad input, 401 not signed in, 403 not a teacher or not from our pages, 404 course is not the teacher's, 405 not POST, 422 idea not suitable, 429 too many requests or daily cap, 500 unexpected, 502/503/504 the AI is unavailable.

## Safety rules (kept by the code)

1. The key lives only in `secrets.config`, and is read only by `TeacherAiSettings` and `TeacherAiClient`.
2. The browser never calls Groq; it calls the handler.
3. The AI only suggests; a person saves with the normal form (which validates again).
4. Every call needs a signed-in teacher. A chapter request checks the course is the teacher's own in SQL.
5. No personal data in prompts: the teacher's name, email and id are never sent, and `TeacherAiPrompts.Redact` masks emails, numbers of 9+ digits and key-shaped text in what the teacher types.
6. Every reply is checked (`TeacherAiReplies`): lengths, whole hours, the language must be one the platform offers, the difficulty must be Easy, Medium or Hard, a chapter title may not repeat an existing one. Anything else is dropped or the reply is refused.
7. The teacher's text is wrapped in `<<< >>>` and the prompts say it is data, not instructions. Chat answers are shown with `textContent`, never as HTML.
8. A forged request is stopped by the required header, an oversized or malformed body gives 400, and anything unexpected gives a short 500 message, never an error page.

## Limits and cost

- One call every 3 seconds and 30 calls per hour for each teacher (in memory, resets when the site restarts).
- The daily cap (`AiDailyLimit`) counts today's rows in `Teacher_AiUsage` for all teachers.
- Text is cut to 1000 characters, chat sends the last 6 messages, replies are limited to 2000 (suggestions) or 1500 (chat) tokens, and a call times out after 45 seconds.
- `Teacher_AiUsage` has one row per call to Groq: teacher, feature, outcome (`ok` or the error name), tokens, milliseconds, date. **It never stores a question or an answer.**
  Useful query: `SELECT Feature, Outcome, COUNT(*), SUM(TotalTokens) FROM Teacher_AiUsage GROUP BY Feature, Outcome`.

## When something changes

- A teacher-portal feature changes: update its line in the FACTS list in `TeacherAiPrompts.cs` (the chatbot only knows what is listed there).
- A form limit changes (title length, hours, domains): update `TeacherAiReplies.cs` and the prompt text so they match.
- A new language is added to the `Subject` table: nothing to do, the language list is read from the database.
- Prompts were first tried in the Groq Playground at temperature 0.2; try a prompt change there and with a few unsuitable ideas before you save it.

## Troubleshooting

| Symptom | Likely cause |
|---|---|
| No "Suggest with AI" buttons and no chat button | `AiEnabled` is `false`, or the key or model is missing in `secrets.config` |
| "The assistant is unavailable right now" | Wrong key (401), wrong model name (404), no internet, or Groq is down; see `Detail` in the client result while debugging |
| "The assistant is busy" | Groq's own rate limit (429); wait a few seconds |
| "reached its limit for today" | The daily cap; raise `AiDailyLimit` or wait for tomorrow |
| "Please wait N seconds" | The per-teacher limit |
| Empty or cut-off replies | `max_completion_tokens` too small for this reasoning model |

## What was tested

Real calls to Groq as Bryan: all three features, unsuitable ideas, the language and difficulty choice, forged course ids, malformed JSON and wrongly typed fields, oversized bodies, signed-out and missing-header calls, prompt-injection attempts in all three features (including a forged `system` history message), the redaction of emails, phone, IC, card and key-shaped text, the hourly limiter, the daily cap, the kill switch, and a search of the files, Git history and stashes for the real key (none found). Not tested: a learner session against the endpoint (the learner seed passwords are hashed), and Groq's own 429 answer.
