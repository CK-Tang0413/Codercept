using System;
using System.Collections.Generic;
using System.Web;

namespace Codercept
{
    /// <summary>
    /// Sample (hard-coded) data for the teacher portal, ported from the prototype's arrays.
    /// Pages bind to these through Repeaters so that the data source can later be switched to SQL
    /// without touching the markup.
    /// TODO (backend): replace each Get...() method with a query (tables: Course, Chapter, SubChapter,
    /// Assessment, Exam, Quiz, Question, MCQ_Option, Attempt, Result, GradingProgress, Forum, Post_Reply).
    /// </summary>
    public static class TeacherSampleData
    {
        // Shown in the sidebar when no session user is available (prototype values).
        public const string FallbackName = "Bryan Yeong";
        public const string FallbackEmail = "bryanyeong@edu.com.my";

        // TODO (backend): the report course comes from the selected course
        public const string ReportCourseTitle = "C Programming Essentials";

        private const string EditsKey = "TeacherCourseEdits";

        /// <summary>
        /// Sample courses, with any edits made this session applied on top.
        /// TODO (backend): remove the session overlay and read from the Course table instead.
        /// </summary>
        public static List<TeacherCourse> GetCourses()
        {
            List<TeacherCourse> list = BuildCourses();
            HttpContext ctx = HttpContext.Current;
            Dictionary<int, TeacherCourse> edits = (ctx != null && ctx.Session != null)
                ? ctx.Session[EditsKey] as Dictionary<int, TeacherCourse> : null;
            if (edits != null)
            {
                foreach (KeyValuePair<int, TeacherCourse> edit in edits)
                {
                    if (edit.Key >= 0 && edit.Key < list.Count) list[edit.Key] = edit.Value;
                }
            }
            return list;
        }

        /// <summary>Keeps an edited course for this session only. TODO (backend): replace with an UPDATE on Course.</summary>
        public static void SaveCourseEdit(int index, TeacherCourse edited)
        {
            HttpContext ctx = HttpContext.Current;
            if (ctx == null || ctx.Session == null) return;
            Dictionary<int, TeacherCourse> edits = ctx.Session[EditsKey] as Dictionary<int, TeacherCourse>;
            if (edits == null) edits = new Dictionary<int, TeacherCourse>();
            edits[index] = edited;
            ctx.Session[EditsKey] = edits;
        }

        private static List<TeacherCourse> BuildCourses()
        {
            return new List<TeacherCourse>
            {
                new TeacherCourse { Title = "Python Programming Fundamentals", Glyph = "py", Theme = "python", Date = "12 May 2024", Learners = "84 learners", Language = "Python", Difficulty = "Easy", Duration = 18, Updated = "24 May 2024", Description = "Build a strong foundation in Python through practical examples, clear explanations, and hands-on programming exercises." },
                new TeacherCourse { Title = "Java Programming Masterclass", Glyph = "Java", Theme = "java", Date = "28 April 2024", Learners = "63 learners", Language = "Java", Difficulty = "Hard", Duration = 32, Updated = "18 May 2024", Description = "Master object-oriented Java, from core syntax and collections to robust application architecture and testing." },
                new TeacherCourse { Title = "Web Development Fundamentals", Glyph = "</>", Theme = "web", Date = "16 April 2024", Learners = "112 learners", Language = "HTML/CSS", Difficulty = "Easy", Duration = 20, Updated = "20 May 2024", Description = "Learn to create accessible, responsive websites with semantic HTML and modern CSS layout techniques." },
                new TeacherCourse { Title = "Modern JavaScript: From Syntax to Applications", Glyph = "JS", Theme = "javascript", Date = "4 April 2024", Learners = "48 learners", Language = "JavaScript", Difficulty = "Medium", Duration = 26, Updated = "15 May 2024", Description = "Explore modern JavaScript concepts and apply them to interactive, maintainable web applications." },
                new TeacherCourse { Title = "C++ Algorithms & Data Structures", Glyph = "C++", Theme = "cpp", Date = "22 March 2024", Learners = "37 learners", Language = "C++", Difficulty = "Hard", Duration = 36, Updated = "2 May 2024", Description = "Develop efficient problem-solving skills with C++ algorithms, data structures, and complexity analysis." },
                new TeacherCourse { Title = "TypeScript for JavaScript Developers", Glyph = "TS", Theme = "typescript", Date = "10 March 2024", Learners = "51 learners", Language = "TypeScript", Difficulty = "Medium", Duration = 16, Updated = "30 April 2024", Description = "Add type safety to JavaScript projects and build more reliable applications with modern TypeScript." }
            };
        }

        public static List<TeacherStat> GetDashboardStats()
        {
            return new List<TeacherStat>
            {
                new TeacherStat { Label = "Total courses", Value = "8", Hint = "2 added this month", Icon = "book", Tone = "indigo" },
                new TeacherStat { Label = "Total learners", Value = "326", Hint = "12% from last month", Icon = "learners", Tone = "teal" },
                new TeacherStat { Label = "Pending gradings", Value = "14", Hint = "Needs your attention", Icon = "clock", Tone = "amber", Badge = "Action needed" },
                new TeacherStat { Label = "Unread forum posts", Value = "9", Hint = "3 new today", Icon = "message", Tone = "rose" }
            };
        }

        /// <summary>Badge tone used for a course difficulty (Easy/Medium/Hard).</summary>
        public static string DifficultyTone(string difficulty)
        {
            if (difficulty == "Easy") return "success";
            if (difficulty == "Medium") return "warning";
            return "danger";
        }

        public static List<TeacherDetailItem> GetCourseStatisticRows()
        {
            return new List<TeacherDetailItem>
            {
                new TeacherDetailItem { Icon = "layers", Label = "Total chapters", Value = "12" },
                new TeacherDetailItem { Icon = "chapters", Label = "Subchapters/quizzes", Value = "38" },
                new TeacherDetailItem { Icon = "users", Label = "Learners attended", Value = "84" },
                new TeacherDetailItem { Icon = "award", Label = "Learners completed", Value = "62" },
                new TeacherDetailItem { Icon = "clock", Label = "Average completion time", Value = "16.4 hours" }
            };
        }

        public static List<TeacherDetailItem> GetPerformanceMetrics()
        {
            return new List<TeacherDetailItem>
            {
                new TeacherDetailItem { Label = "Average", Value = "78.4" },
                new TeacherDetailItem { Label = "Median", Value = "80.0" },
                new TeacherDetailItem { Label = "Minimum", Value = "42.0" },
                new TeacherDetailItem { Label = "Maximum", Value = "98.0" },
                new TeacherDetailItem { Label = "Std. deviation", Value = "12.6" }
            };
        }

        public static List<TeacherGrade> GetGradeDistribution()
        {
            return new List<TeacherGrade>
            {
                new TeacherGrade { Grade = "A", Count = 18, Value = 82 },
                new TeacherGrade { Grade = "B", Count = 24, Value = 100 },
                new TeacherGrade { Grade = "C", Count = 19, Value = 86 },
                new TeacherGrade { Grade = "D", Count = 14, Value = 64 },
                new TeacherGrade { Grade = "E", Count = 6, Value = 36 },
                new TeacherGrade { Grade = "F", Count = 3, Value = 22 }
            };
        }

        /// <summary>TODO (backend): learners enrolled in the selected course (Learner + LearnerProgress + Result).</summary>
        public static List<TeacherLearner> GetLearners()
        {
            return new List<TeacherLearner>
            {
                new TeacherLearner { Initials = "TC", Name = "Tang Chee Kin", Email = "tang.cheekin@student.edu.my", Tone = "indigo", Age = "21", Gender = "Male", Level = "Intermediate", Chapter = "Chapter 8 of 12", Progress = 67, Quizzes = "18 of 24", ExamDate = "24 May 2024", Enrolled = "12 February 2024", Accessed = "28 May 2024", Completed = "-", Score = "86%", Grade = "A", Average = "81%" },
                new TeacherLearner { Initials = "AL", Name = "Amanda Lee", Email = "amanda.lee@student.edu.my", Tone = "teal", Age = "20", Gender = "Female", Level = "Beginner", Chapter = "Chapter 10 of 12", Progress = 83, Quizzes = "21 of 24", ExamDate = "-", Enrolled = "18 February 2024", Accessed = "29 May 2024", Completed = "-", Score = "-", Grade = "-", Average = "88%" },
                new TeacherLearner { Initials = "MK", Name = "Muhammad Khairul", Email = "khairul@student.edu.my", Tone = "blue", Age = "22", Gender = "Male", Level = "Advanced", Chapter = "Chapter 12 of 12", Progress = 100, Quizzes = "24 of 24", ExamDate = "18 May 2024", Enrolled = "4 January 2024", Accessed = "26 May 2024", Completed = "18 May 2024", Score = "92%", Grade = "A", Average = "90%" },
                new TeacherLearner { Initials = "JT", Name = "Jessica Tan", Email = "jessica.tan@student.edu.my", Tone = "amber", Age = "19", Gender = "Female", Level = "Beginner", Chapter = "Chapter 5 of 12", Progress = 42, Quizzes = "10 of 24", ExamDate = "-", Enrolled = "2 March 2024", Accessed = "27 May 2024", Completed = "-", Score = "-", Grade = "-", Average = "74%" },
                new TeacherLearner { Initials = "RK", Name = "Ravi Kumar", Email = "ravi.kumar@student.edu.my", Tone = "rose", Age = "23", Gender = "Male", Level = "Intermediate", Chapter = "Chapter 7 of 12", Progress = 58, Quizzes = "15 of 24", ExamDate = "-", Enrolled = "22 February 2024", Accessed = "25 May 2024", Completed = "-", Score = "-", Grade = "-", Average = "79%" }
            };
        }

        /// <summary>Prototype rule: every third course (starting with the second) has no exam yet. TODO (backend): Exam table.</summary>
        public static bool HasExam(int courseIndex)
        {
            return courseIndex % 3 != 1;
        }

        /// <summary>Course used by the chapter pages' breadcrumb (prototype value). TODO (backend): selected course.</summary>
        public const string ChapterCourseTitle = "Python Programming Fundamentals";

        private const string ChapterEditsKey = "TeacherChapterEdits";

        /// <summary>
        /// Sample chapters with this session's edits applied on top.
        /// TODO (backend): remove the session overlay and read the Chapter table instead.
        /// </summary>
        public static List<TeacherChapter> GetChapters()
        {
            List<TeacherChapter> list = BuildChapters();
            HttpContext ctx = HttpContext.Current;
            Dictionary<int, TeacherChapter> edits = (ctx != null && ctx.Session != null)
                ? ctx.Session[ChapterEditsKey] as Dictionary<int, TeacherChapter> : null;
            if (edits != null)
            {
                for (int i = 0; i < list.Count; i++)
                {
                    TeacherChapter edited;
                    if (edits.TryGetValue(list[i].Number, out edited)) list[i] = edited;
                }
            }
            return list;
        }

        /// <summary>Keeps an edited chapter for this session only. TODO (backend): replace with an UPDATE on Chapter.</summary>
        public static void SaveChapterEdit(TeacherChapter edited)
        {
            HttpContext ctx = HttpContext.Current;
            if (ctx == null || ctx.Session == null) return;
            Dictionary<int, TeacherChapter> edits = ctx.Session[ChapterEditsKey] as Dictionary<int, TeacherChapter>;
            if (edits == null) edits = new Dictionary<int, TeacherChapter>();
            edits[edited.Number] = edited;
            ctx.Session[ChapterEditsKey] = edits;
        }

        /// <summary>"2.5 hours" -> "2.5" (for the duration text box).</summary>
        public static string HoursOf(string duration)
        {
            return (duration ?? "").Replace("hours", "").Replace("hour", "").Trim();
        }

        /// <summary>2.5 -> "2.5 hours", 1 -> "1 hour".</summary>
        public static string FormatHours(decimal hours)
        {
            string text = hours.ToString("0.##", System.Globalization.CultureInfo.InvariantCulture);
            return text + (text == "1" ? " hour" : " hours");
        }

        private static List<TeacherChapter> BuildChapters()
        {
            return new List<TeacherChapter>
            {
                new TeacherChapter { Number = 1, Title = "Introduction to C", Description = "Get familiar with the C programming language, its history, development environment, and the structure of a first program.", Duration = "2 hours", Created = "12 May 2024", Updated = "18 May 2024" },
                new TeacherChapter { Number = 2, Title = "Variables and Data Types", Description = "Understand variables, constants, primitive data types, and common type conversions in C.", Duration = "3 hours", Created = "14 May 2024", Updated = "20 May 2024" },
                new TeacherChapter { Number = 3, Title = "Operators and Expressions", Description = "Use arithmetic, logical, relational, and assignment operators to build useful expressions.", Duration = "2.5 hours", Created = "16 May 2024", Updated = "22 May 2024" },
                new TeacherChapter { Number = 4, Title = "Control Flow", Description = "Control program execution with conditional statements, switch cases, loops, and branching.", Duration = "4 hours", Created = "18 May 2024", Updated = "24 May 2024" },
                new TeacherChapter { Number = 5, Title = "Functions and Scope", Description = "Break programs into reusable functions and understand parameters, return values, and scope.", Duration = "3.5 hours", Created = "20 May 2024", Updated = "26 May 2024" }
            };
        }

        /// <summary>TODO (backend): SubChapter + Quiz rows of the selected chapter, in display order.</summary>
        public static List<TeacherContentItem> GetChapterContents()
        {
            return new List<TeacherContentItem>
            {
                new TeacherContentItem { Type = "subchapter", Title = "What is C Programming?" },
                new TeacherContentItem { Type = "subchapter", Title = "Setting Up Your Environment" },
                new TeacherContentItem { Type = "quiz", Title = "Getting Started Checkpoint" },
                new TeacherContentItem { Type = "subchapter", Title = "Your First C Program" },
                new TeacherContentItem { Type = "quiz", Title = "Chapter 1 Knowledge Check" }
            };
        }

        public const string SampleSubchapterDescription = "C is a general-purpose programming language created in the 1970s. It remains one of the most influential languages for systems and application development.";

        public static List<TeacherQuestion> GetQuizQuestions()
        {
            return new List<TeacherQuestion>
            {
                new TeacherQuestion
                {
                    Text = "Who developed the C programming language?",
                    Marks = 2,
                    Type = "MCQ",
                    Answers = new List<TeacherAnswer>
                    {
                        new TeacherAnswer { Text = "Dennis Ritchie", Correct = true },
                        new TeacherAnswer { Text = "James Gosling" },
                        new TeacherAnswer { Text = "Bjarne Stroustrup" },
                        new TeacherAnswer { Text = "Guido van Rossum" }
                    },
                    AcceptedAnswers = "", ModelAnswer = "", MarkingGuide = ""
                }
            };
        }

        /// <summary>Pending submissions per course (prototype values, by course index). TODO (backend): count ungraded Attempt rows.</summary>
        public static int PendingSubmissions(int courseIndex)
        {
            int[] pending = { 14, 8, 21, 6, 11, 4 };
            return courseIndex >= 0 && courseIndex < pending.Length ? pending[courseIndex] : 0;
        }

        /// <summary>TODO (backend): Exam and Quiz rows of the course with their ungraded submissions.</summary>
        public static List<TeacherAssessment> GetAssessments()
        {
            return new List<TeacherAssessment>
            {
                new TeacherAssessment { Type = "Exam", Title = "Final Course Examination", Pending = 8, Questions = 20 },
                new TeacherAssessment { Type = "Quiz", Title = "Chapter 2 · Variables Quiz", Pending = 3, Questions = 10 },
                new TeacherAssessment { Type = "Quiz", Title = "Chapter 5 · Functions Quiz", Pending = 4, Questions = 8 },
                new TeacherAssessment { Type = "Quiz", Title = "Chapter 8 · Pointers Quiz", Pending = 6, Questions = 12 }
            };
        }

        /// <summary>TODO (backend): learners who submitted the selected assessment (Attempt + GradingProgress).</summary>
        public static List<TeacherSubmission> GetSubmissions()
        {
            return new List<TeacherSubmission>
            {
                new TeacherSubmission { Initials = "TC", Name = "Tang Chee Kin", Email = "tang.cheekin@student.edu.my", Tone = "indigo", Status = "Not graded", Submitted = "28 May 2024, 10:24 AM" },
                new TeacherSubmission { Initials = "AL", Name = "Amanda Lee", Email = "amanda.lee@student.edu.my", Tone = "teal", Status = "In progress", Submitted = "28 May 2024, 9:46 AM" },
                new TeacherSubmission { Initials = "MK", Name = "Muhammad Khairul", Email = "khairul@student.edu.my", Tone = "blue", Status = "Graded", Submitted = "27 May 2024, 4:18 PM" }
            };
        }

        private const string ForumPostsKey = "TeacherForumPosts";

        /// <summary>
        /// Forum posts with their discussions. TODO (backend): Forum / Post_Reply tables. Until then the list lives in the
        /// session so replies, pins and new posts survive postbacks; mutate the returned objects directly.
        /// </summary>
        public static List<TeacherForumPost> GetForumPosts()
        {
            HttpContext ctx = HttpContext.Current;
            List<TeacherForumPost> posts = (ctx != null && ctx.Session != null) ? ctx.Session[ForumPostsKey] as List<TeacherForumPost> : null;
            if (posts != null) return posts;

            posts = new List<TeacherForumPost>
            {
                new TeacherForumPost
                {
                    Id = 1, Title = "What is String in Python?",
                    Excerpt = "I am currently going through the Python for Beginners module and I'm a bit confused about Strings...",
                    Tags = new List<string> { "Python", "Fundamental" },
                    Comments = new List<TeacherForumComment>
                    {
                        new TeacherForumComment { Id = 1, Name = "Kylan Shane", Initials = "K", Role = "LEARNER", Body = "String is just a sequence of characters. They are strictly immutable." },
                        new TeacherForumComment { Id = 2, Name = "Mr. Elaveenthan", Initials = "M", Role = "TEACHER", Pinned = true, Body = "Kylan is correct! Because they are immutable, if you want to 'modify' a string, you actually create a brand new string." }
                    }
                },
                new TeacherForumPost
                {
                    Id = 2, Title = "Error setting up Visual Studio for C++",
                    Excerpt = "Every time I try to compile my first Hello World program, it throws an error...",
                    Tags = new List<string> { "C++", "Environment", "Error" },
                    Comments = new List<TeacherForumComment>
                    {
                        new TeacherForumComment { Id = 3, Name = "Alicia Tan", Initials = "A", Role = "LEARNER", Body = "Check that the Desktop development with C++ workload is installed in Visual Studio Installer." }
                    }
                }
            };
            if (ctx != null && ctx.Session != null) ctx.Session[ForumPostsKey] = posts;
            return posts;
        }

        public static List<TeacherExamRule> GetExamRules()
        {
            return new List<TeacherExamRule>
            {
                new TeacherExamRule { Title = "Strict syntax, indentation and format checking", Description = "Answers must follow exact language syntax and formatting conventions.", Icon = "code", On = true },
                new TeacherExamRule { Title = "Use of libraries and modules", Description = "Allow learners to import standard libraries and approved modules.", Icon = "code", On = true },
                new TeacherExamRule { Title = "Rule 3", Description = "Apply the third exam restriction to all submitted answers.", Icon = "info", On = false },
                new TeacherExamRule { Title = "Rule 4", Description = "Apply the fourth exam restriction to all submitted answers.", Icon = "info", On = false }
            };
        }

        /// <summary>TODO (backend): Question + MCQ_Option rows of the course exam.</summary>
        public static List<TeacherQuestion> GetExamQuestions()
        {
            List<TeacherQuestion> list = new List<TeacherQuestion>();
            list.Add(new TeacherQuestion
            {
                Text = "Who developed the C programming language?",
                Marks = 10,
                Type = "MCQ",
                Answers = new List<TeacherAnswer>
                {
                    new TeacherAnswer { Text = "Dennis Ritchie", Correct = true },
                    new TeacherAnswer { Text = "James Gosling" },
                    new TeacherAnswer { Text = "Bjarne Stroustrup" },
                    new TeacherAnswer { Text = "Guido van Rossum" }
                },
                AcceptedAnswers = "Dennis Ritchie, D. Ritchie",
                ModelAnswer = "A strong answer should explain the origin of C, its purpose, and why it remains influential.",
                MarkingGuide = "Award marks for origin, purpose, influence, and a clear example."
            });
            list.Add(new TeacherQuestion
            {
                Text = "Which keyword makes a variable read-only in C?",
                Marks = 10,
                Type = "MCQ",
                Answers = new List<TeacherAnswer>
                {
                    new TeacherAnswer { Text = "final" },
                    new TeacherAnswer { Text = "const", Correct = true },
                    new TeacherAnswer { Text = "readonly" },
                    new TeacherAnswer { Text = "static" }
                },
                AcceptedAnswers = "const",
                ModelAnswer = "const marks a variable as read-only after initialisation.",
                MarkingGuide = "Award full marks for const."
            });
            return list;
        }

        public static List<TeacherReportScore> GetReportScores()
        {
            return new List<TeacherReportScore>
            {
                new TeacherReportScore { Item = "Quiz 1 · Fundamentals", Score = "18 / 20", Grade = "A" },
                new TeacherReportScore { Item = "Quiz 2 · Variables", Score = "16 / 20", Grade = "B" },
                new TeacherReportScore { Item = "Quiz 3 · Control Flow", Score = "19 / 20", Grade = "A" },
                new TeacherReportScore { Item = "Chapter Assessment", Score = "42 / 50", Grade = "A" },
                new TeacherReportScore { Item = "Final Examination", Score = "86 / 100", Grade = "A" }
            };
        }

        public static List<TeacherActivity> GetRecentActivities()
        {
            return new List<TeacherActivity>
            {
                new TeacherActivity { Time = "10:24 AM", Initials = "AL", Tone = "teal", Name = "Amanda Lee", Action = "submitted", Detail = "Python Basics — Chapter 4 Quiz", Type = "submitted", HasButton = true },
                new TeacherActivity { Time = "9:42 AM", Initials = "MK", Tone = "blue", Name = "Muhammad Khairul", Action = "started", Detail = "Introduction to Java — Final Exam", Type = "started" },
                new TeacherActivity { Time = "Yesterday", Initials = "JT", Tone = "amber", Name = "Jessica Tan", Action = "submitted", Detail = "Web Development Fundamentals — HTML Forms", Type = "submitted", HasButton = true },
                new TeacherActivity { Time = "Yesterday", Initials = "RK", Tone = "rose", Name = "Ravi Kumar", Action = "started", Detail = "C++ Programming — Pointers & Memory", Type = "started" }
            };
        }
    }

    public class TeacherCourse
    {
        public string Title { get; set; }
        public string Glyph { get; set; }
        public string Theme { get; set; }
        public string Date { get; set; }
        public string Learners { get; set; }
        public string Language { get; set; }
        public string Difficulty { get; set; }
        public int Duration { get; set; }
        public string Updated { get; set; }
        public string Description { get; set; }
    }

    public class TeacherDetailItem
    {
        public string Icon { get; set; }
        public string Label { get; set; }
        public string Value { get; set; }
    }

    public class TeacherGrade
    {
        public string Grade { get; set; }
        public int Count { get; set; }
        public int Value { get; set; }
    }

    public class TeacherLearner
    {
        public string Initials { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
        public string Tone { get; set; }
        public string Age { get; set; }
        public string Gender { get; set; }
        public string Level { get; set; }
        public string Chapter { get; set; }
        public int Progress { get; set; }
        public string Quizzes { get; set; }
        public string ExamDate { get; set; }
        public string Enrolled { get; set; }
        public string Accessed { get; set; }
        public string Completed { get; set; }
        public string Score { get; set; }
        public string Grade { get; set; }
        public string Average { get; set; }
    }

    public class TeacherChapter
    {
        public int Number { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Duration { get; set; }
        public string Created { get; set; }
        public string Updated { get; set; }
    }

    public class TeacherContentItem
    {
        /// <summary>subchapter | quiz</summary>
        public string Type { get; set; }
        public string Title { get; set; }
    }

    public class TeacherAssessment
    {
        /// <summary>Exam | Quiz</summary>
        public string Type { get; set; }
        public string Title { get; set; }
        public int Pending { get; set; }
        public int Questions { get; set; }
    }

    public class TeacherSubmission
    {
        public string Initials { get; set; }
        public string Name { get; set; }
        public string Email { get; set; }
        public string Tone { get; set; }
        /// <summary>Not graded | In progress | Graded</summary>
        public string Status { get; set; }
        public string Submitted { get; set; }
    }

    public class TeacherExamRule
    {
        public string Title { get; set; }
        public string Description { get; set; }
        public string Icon { get; set; }
        public bool On { get; set; }
    }

    public class TeacherAnswer
    {
        public string Text { get; set; }
        public bool Correct { get; set; }
    }

    public class TeacherQuestion
    {
        public string Text { get; set; }
        public int Marks { get; set; }
        /// <summary>MCQ | Fill-in-the-blank | Subjective</summary>
        public string Type { get; set; }
        public List<TeacherAnswer> Answers { get; set; }
        public string AcceptedAnswers { get; set; }
        public string ModelAnswer { get; set; }
        public string MarkingGuide { get; set; }

        /// <summary>A new, empty question (2 marks, 4 empty answers) - what "Add question" creates.</summary>
        public static TeacherQuestion Blank()
        {
            TeacherQuestion q = new TeacherQuestion { Text = "", Marks = 2, Type = "MCQ", Answers = new List<TeacherAnswer>(), AcceptedAnswers = "", ModelAnswer = "", MarkingGuide = "" };
            for (int i = 0; i < 4; i++) q.Answers.Add(new TeacherAnswer { Text = "", Correct = i == 0 });
            return q;
        }
    }

    public class TeacherForumComment
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Initials { get; set; }
        /// <summary>LEARNER | TEACHER</summary>
        public string Role { get; set; }
        public string Body { get; set; }
        public bool Pinned { get; set; }
        /// <summary>The Id of the reply this one answers (Post_Reply.ParentThreadId); null for a reply to the post itself.</summary>
        public int? ParentId { get; set; }
    }

    public class TeacherForumPost
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Excerpt { get; set; }
        public List<string> Tags { get; set; }
        public List<TeacherForumComment> Comments { get; set; }
    }

    public class TeacherReportScore
    {
        public string Item { get; set; }
        public string Score { get; set; }
        public string Grade { get; set; }
    }

    public class TeacherStat
    {
        public string Label { get; set; }
        public string Value { get; set; }
        public string Hint { get; set; }
        public string Icon { get; set; }
        public string Tone { get; set; }
        public string Badge { get; set; }
    }

    public class TeacherActivity
    {
        public string Time { get; set; }
        public string Initials { get; set; }
        public string Tone { get; set; }
        public string Name { get; set; }
        public string Action { get; set; }
        public string Detail { get; set; }
        public string Type { get; set; }
        public bool HasButton { get; set; }
    }
}
