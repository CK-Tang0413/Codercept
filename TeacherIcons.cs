using System.Collections.Generic;

namespace Codercept
{
    /// <summary>
    /// Inline SVG icons of the teacher portal (ported 1:1 from the prototype's Icon component).
    /// Usage in markup:  &lt;%= TeacherIcons.Svg("plus", 17) %&gt;
    /// </summary>
    public static class TeacherIcons
    {
        private static readonly Dictionary<string, string> Paths = new Dictionary<string, string>
        {
            { "dashboard", "<rect x='3' y='3' width='7' height='7' rx='2' /><rect x='14' y='3' width='7' height='7' rx='2' /><rect x='3' y='14' width='7' height='7' rx='2' /><rect x='14' y='14' width='7' height='7' rx='2' />" },
            { "courses", "<path d='M4 19.5A2.5 2.5 0 0 1 6.5 17H20' /><path d='M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2Z' />" },
            { "chapters", "<path d='M8 6h13M8 12h13M8 18h13' /><path d='m3 6 .01 0M3 12l.01 0M3 18l.01 0' />" },
            { "exams", "<path d='M9 5h6M9 11h6M9 17h3' /><path d='M5 3h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2Z' /><path d='m16 17 1.5 1.5L21 15' />" },
            { "learners", "<path d='M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2' /><circle cx='9' cy='7' r='4' /><path d='M22 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75' />" },
            { "grade", "<path d='M9 5h6M9 3v4M6 5H4a2 2 0 0 0-2 2v13a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2h-2' /><path d='m8 15 2.5 2.5L16 12' />" },
            { "forum", "<path d='M21 15a4 4 0 0 1-4 4H8l-5 3V7a4 4 0 0 1 4-4h10a4 4 0 0 1 4 4Z' /><path d='M8 9h8M8 13h5' />" },
            { "book", "<path d='M4 19.5A2.5 2.5 0 0 1 6.5 17H20' /><path d='M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2Z' />" },
            { "clock", "<circle cx='12' cy='12' r='9' /><path d='M12 7v5l3 2' />" },
            { "message", "<path d='M21 15a4 4 0 0 1-4 4H8l-5 3V7a4 4 0 0 1 4-4h10a4 4 0 0 1 4 4Z' /><path d='M8 10h8M8 14h4' />" },
            { "trend", "<path d='m3 17 6-6 4 4 8-8M15 7h6v6' />" },
            { "arrow", "<path d='M5 12h14m-5-5 5 5-5 5' />" },
            { "edit", "<path d='M12 20h9' /><path d='M16.5 3.5a2.12 2.12 0 0 1 3 3L8 18l-4 1 1-4Z' />" },
            { "users", "<path d='M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2' /><circle cx='9' cy='7' r='4' /><path d='M22 21v-2a4 4 0 0 0-3-3.87' />" },
            { "plus", "<path d='M12 5v14M5 12h14' />" },
            { "check", "<path d='m5 12 4 4L19 6' />" },
            { "logout", "<path d='M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4' /><path d='m16 17 5-5-5-5M21 12H9' />" },
            { "menu", "<path d='M4 6h16M4 12h16M4 18h16' />" },
            { "close", "<path d='m6 6 12 12M18 6 6 18' />" },
            { "search", "<circle cx='11' cy='11' r='7' /><path d='m20 20-4-4' />" },
            { "filter", "<path d='M4 5h16M7 12h10M10 19h4' />" },
            { "grid", "<rect x='3' y='3' width='7' height='7' rx='1' /><rect x='14' y='3' width='7' height='7' rx='1' /><rect x='3' y='14' width='7' height='7' rx='1' /><rect x='14' y='14' width='7' height='7' rx='1' />" },
            { "list", "<path d='M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01' />" },
            { "chevron", "<path d='m9 18 6-6-6-6' />" },
            { "calendar", "<rect x='3' y='5' width='18' height='16' rx='2' /><path d='M16 3v4M8 3v4M3 10h18' />" },
            { "code", "<path d='m8 9-3 3 3 3M16 9l3 3-3 3M14 5l-4 14' />" },
            { "layers", "<path d='m12 2 9 5-9 5-9-5 9-5Z' /><path d='m3 12 9 5 9-5M3 17l9 5 9-5' />" },
            { "award", "<circle cx='12' cy='8' r='6' /><path d='m8.8 13-1.3 9 4.5-2 4.5 2-1.3-9' />" },
            { "chart", "<path d='M4 20V10M10 20V4M16 20v-7M22 20H2' />" },
            { "download", "<path d='M12 3v12m-5-5 5 5 5-5M5 21h14' />" },
            { "trash", "<path d='M3 6h18M8 6V4h8v2M19 6l-1 15H6L5 6M10 11v5M14 11v5' />" },
            { "info", "<circle cx='12' cy='12' r='9' /><path d='M12 11v5M12 8h.01' />" },
            { "grip", "<circle cx='8' cy='6' r='1' /><circle cx='16' cy='6' r='1' /><circle cx='8' cy='12' r='1' /><circle cx='16' cy='12' r='1' /><circle cx='8' cy='18' r='1' /><circle cx='16' cy='18' r='1' />" },
            { "up", "<path d='m6 15 6-6 6 6' />" },
            { "down", "<path d='m6 9 6 6 6-6' />" },
            { "question", "<circle cx='12' cy='12' r='9' /><path d='M9.8 9a2.3 2.3 0 1 1 3.2 2.1c-.7.35-1 1-1 1.9M12 17h.01' />" },
            { "upload", "<path d='M12 16V4m-4 4 4-4 4 4' /><path d='M5 14v5h14v-5' />" },
            { "link", "<path d='M10 13a5 5 0 0 0 7.5.5l2-2a5 5 0 0 0-7-7l-1.1 1.1' /><path d='M14 11a5 5 0 0 0-7.5-.5l-2 2a5 5 0 0 0 7 7l1.1-1.1' />" },
            { "bold", "<path d='M7 5h6a4 4 0 0 1 0 8H7V5Zm0 8h7a3.5 3.5 0 0 1 0 7H7v-7Z' />" },
            { "italic", "<path d='M10 5h8M6 19h8M14 5 10 19' />" },
            { "x", "<path d='m6 6 12 12M18 6 6 18' />" },
            { "file", "<path d='M6 2h8l5 5v15H6Z' /><path d='M14 2v6h5' />" },
            { "print", "<path d='M6 9V3h12v6M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2' /><path d='M6 14h12v7H6Z' />" },
            { "external", "<path d='M14 3h7v7M10 14 21 3M21 14v5a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5' />" },
            { "send", "<path d='m22 2-7 20-4-9-9-4Z' /><path d='M22 2 11 13' />" },
        };

        public static string Svg(string name, int size = 20)
        {
            string inner;
            if (!Paths.TryGetValue(name, out inner)) inner = "";
            return "<svg aria-hidden='true' class='icon' fill='none' height='" + size + "' viewBox='0 0 24 24' width='" + size + "'>" + inner + "</svg>";
        }
    }
}
