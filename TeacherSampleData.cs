using System;
using System.Collections.Generic;
using System.Linq;
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
                new TeacherDetailItem { Icon = "chapters", Label = "Subchapters", Value = "26" },
                new TeacherDetailItem { Icon = "question", Label = "Quizzes & assessments", Value = "12" },
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

        /// <summary>The learner with this LearnerId, or null. TODO (backend): SELECT ... FROM Learner JOIN LearnerProgress JOIN Course WHERE LearnerId = @LearnerId AND Course.TeacherId = @TeacherId.</summary>
        public static TeacherLearner GetLearner(int learnerId)
        {
            return GetLearners().FirstOrDefault(l => l.Id == learnerId);
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
                new TeacherLearner { Id = 1, Initials = "TC", Name = "Tang Chee Kin", Email = "tang.cheekin@student.edu.my", Tone = "indigo", Age = "21", Gender = "Male", Level = "Intermediate", Chapter = "Chapter 8 of 12", Progress = 67, Quizzes = "18 of 24", ExamDate = "24 May 2024", Enrolled = "12 February 2024", Accessed = "28 May 2024", Completed = "-", Score = "86%", Grade = "A", Average = "81%" },
                new TeacherLearner { Id = 2, Initials = "AL", Name = "Amanda Lee", Email = "amanda.lee@student.edu.my", Tone = "teal", Age = "20", Gender = "Female", Level = "Beginner", Chapter = "Chapter 10 of 12", Progress = 83, Quizzes = "21 of 24", ExamDate = "-", Enrolled = "18 February 2024", Accessed = "29 May 2024", Completed = "-", Score = "-", Grade = "-", Average = "88%" },
                new TeacherLearner { Id = 3, Initials = "MK", Name = "Muhammad Khairul", Email = "khairul@student.edu.my", Tone = "blue", Age = "22", Gender = "Male", Level = "Advanced", Chapter = "Chapter 12 of 12", Progress = 100, Quizzes = "24 of 24", ExamDate = "18 May 2024", Enrolled = "4 January 2024", Accessed = "26 May 2024", Completed = "18 May 2024", Score = "92%", Grade = "A", Average = "90%" },
                new TeacherLearner { Id = 4, Initials = "JT", Name = "Jessica Tan", Email = "jessica.tan@student.edu.my", Tone = "amber", Age = "19", Gender = "Female", Level = "Beginner", Chapter = "Chapter 5 of 12", Progress = 42, Quizzes = "10 of 24", ExamDate = "-", Enrolled = "2 March 2024", Accessed = "27 May 2024", Completed = "-", Score = "-", Grade = "-", Average = "74%" },
                new TeacherLearner { Id = 5, Initials = "RK", Name = "Ravi Kumar", Email = "ravi.kumar@student.edu.my", Tone = "rose", Age = "23", Gender = "Male", Level = "Intermediate", Chapter = "Chapter 7 of 12", Progress = 58, Quizzes = "15 of 24", ExamDate = "-", Enrolled = "22 February 2024", Accessed = "25 May 2024", Completed = "-", Score = "-", Grade = "-", Average = "79%" }
            };
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
                    if (edits.TryGetValue(list[i].Id, out edited)) list[i] = edited;
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
            edits[edited.Id] = edited;
            ctx.Session[ChapterEditsKey] = edits;
        }

        /// <summary>The chapter with this ChapterId, or null. TODO (backend): SELECT ... FROM Chapter c JOIN Course ... WHERE ChapterId = @ChapterId AND c.TeacherId = @TeacherId.</summary>
        public static TeacherChapter GetChapter(int chapterId)
        {
            return GetChapters().FirstOrDefault(c => c.Id == chapterId);
        }

        /// <summary>"2.5 hours" -> "2.5" (for the duration text box).
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
                new TeacherChapter { Id = 1, Number = 1, Title = "Introduction to C", Description = "Get familiar with the C programming language, its history, development environment, and the structure of a first program.", Duration = "2 hours", Created = "12 May 2024", Updated = "18 May 2024",
                    Test = new TeacherChapterTestInfo { Id = 1, Type = "quiz", Title = "Chapter 1 Knowledge Check", Questions = 1, TotalMarks = 2 } },
                new TeacherChapter { Id = 2, Number = 2, Title = "Variables and Data Types", Description = "Understand variables, constants, primitive data types, and common type conversions in C.", Duration = "3 hours", Created = "14 May 2024", Updated = "20 May 2024",
                    Test = new TeacherChapterTestInfo { Id = 1, Type = "assessment", Title = "Chapter 2 Assessment", Questions = 3, TotalMarks = 12 } },
                new TeacherChapter { Id = 3, Number = 3, Title = "Operators and Expressions", Description = "Use arithmetic, logical, relational, and assignment operators to build useful expressions.", Duration = "2.5 hours", Created = "16 May 2024", Updated = "22 May 2024" },
                new TeacherChapter { Id = 4, Number = 4, Title = "Control Flow", Description = "Control program execution with conditional statements, switch cases, loops, and branching.", Duration = "4 hours", Created = "18 May 2024", Updated = "24 May 2024",
                    Test = new TeacherChapterTestInfo { Id = 2, Type = "quiz", Title = "Control Flow Quiz", Questions = 1, TotalMarks = 2 } },
                new TeacherChapter { Id = 5, Number = 5, Title = "Functions and Scope", Description = "Break programs into reusable functions and understand parameters, return values, and scope.", Duration = "3.5 hours", Created = "20 May 2024", Updated = "26 May 2024" }
            };
        }

        /// <summary>TODO (backend): SubChapter rows of the selected chapter, in display order.</summary>
        public static List<TeacherContentItem> GetChapterContents()
        {
            return new List<TeacherContentItem>
            {
                new TeacherContentItem { Id = 1, Type = "subchapter", Title = "What is C Programming?" },
                new TeacherContentItem { Id = 2, Type = "subchapter", Title = "Setting Up Your Environment" },
                new TeacherContentItem { Id = 3, Type = "subchapter", Title = "Your First C Program" }
            };
        }

        public const string SampleSubchapterDescription = "C is a general-purpose programming language created in the 1970s. It remains one of the most influential languages for systems and application development.";

        public const string SampleTestDescription = "Check what you have learned in this chapter before moving on to the next one.";

        private const string TestQuestionsKey = "TeacherChapterTestQuestions";

        /// <summary>
        /// The questions of a chapter's quiz or assessment: the ones saved this session, otherwise sample questions.
        /// TODO (backend): remove the session store and read Question + MCQ_Option instead.
        /// </summary>
        public static List<TeacherQuestion> GetTestQuestions(TeacherChapter chapter)
        {
            HttpContext ctx = HttpContext.Current;
            Dictionary<int, List<TeacherQuestion>> saved = (ctx != null && ctx.Session != null)
                ? ctx.Session[TestQuestionsKey] as Dictionary<int, List<TeacherQuestion>> : null;
            List<TeacherQuestion> questions;
            if (saved != null && saved.TryGetValue(chapter.Id, out questions)) return questions;
            return chapter.Test != null && chapter.Test.Type == "assessment" ? BuildAssessmentQuestions() : GetQuizQuestions();
        }

        /// <summary>
        /// Keeps a chapter's quiz / assessment (title and questions, in the arranged order) for this session only; null questions
        /// remove it. TODO (backend): INSERT / UPDATE / DELETE on Quiz or Assessment, Question and MCQ_Option.
        /// </summary>
        public static void SaveChapterTest(int chapterId, string title, List<TeacherQuestion> questions)
        {
            TeacherChapter chapter = GetChapter(chapterId);
            HttpContext ctx = HttpContext.Current;
            if (chapter == null || ctx == null || ctx.Session == null) return;

            Dictionary<int, List<TeacherQuestion>> saved = ctx.Session[TestQuestionsKey] as Dictionary<int, List<TeacherQuestion>>;
            if (saved == null) saved = new Dictionary<int, List<TeacherQuestion>>();

            TeacherChapterTestInfo test = null;
            if (questions != null && chapter.Test != null)
            {
                test = new TeacherChapterTestInfo
                {
                    Id = chapter.Test.Id,
                    Type = chapter.Test.Type,
                    Title = title,
                    Questions = questions.Count,
                    TotalMarks = questions.Sum(q => q.Marks)
                };
                saved[chapterId] = questions;
            }
            else
            {
                saved.Remove(chapterId);
            }
            ctx.Session[TestQuestionsKey] = saved;

            SaveChapterEdit(new TeacherChapter
            {
                Id = chapter.Id, Number = chapter.Number, Title = chapter.Title, Description = chapter.Description,
                Duration = chapter.Duration, Created = chapter.Created, Updated = DateTime.Today.ToString("d MMMM yyyy"),
                Test = test
            });
        }

        private static List<TeacherQuestion> BuildAssessmentQuestions()
        {
            return new List<TeacherQuestion>
            {
                new TeacherQuestion
                {
                    Id = 1, Text = "Which header file declares printf?", Marks = 2, Type = "MCQ",
                    Answers = new List<TeacherAnswer>
                    {
                        new TeacherAnswer { Text = "stdio.h", Correct = true },
                        new TeacherAnswer { Text = "stdlib.h" },
                        new TeacherAnswer { Text = "string.h" }
                    },
                    AcceptedAnswers = "", ModelAnswer = "", MarkingGuide = ""
                },
                new TeacherQuestion
                {
                    Id = 2, Text = "The ____ function is where every C program starts running.", Marks = 4, Type = "Fill-in-the-blank",
                    Answers = new List<TeacherAnswer>(),
                    AcceptedAnswers = "main, main()", ModelAnswer = "", MarkingGuide = ""
                },
                new TeacherQuestion
                {
                    Id = 3, Text = "Write a program that prints Hello, World! and returns 0.", Marks = 6, Type = "Coding",
                    Answers = new List<TeacherAnswer>(),
                    AcceptedAnswers = "",
                    ModelAnswer = "#include <stdio.h>\n\nint main(void) {\n    printf(\"Hello, World!\\n\");\n    return 0;\n}",
                    MarkingGuide = "2 marks for the include and main, 2 for the correct printf call, 2 for returning 0."
                }
            };
        }

        public static List<TeacherQuestion> GetQuizQuestions()
        {
            return new List<TeacherQuestion>
            {
                new TeacherQuestion
                {
Id = 1,
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

        /// <summary>TODO (backend): the course's exam, and the quizzes and assessments of its chapters, with their ungraded submissions.</summary>
        public static List<TeacherAssessment> GetAssessments()
        {
            return new List<TeacherAssessment>
            {
                new TeacherAssessment { Id = 1, Type = "Exam", Title = "Final Course Examination", Pending = 8, Questions = 20 },
                new TeacherAssessment { Id = 1, Type = "Quiz", Title = "Chapter 1 · Knowledge Check", Pending = 3, Questions = 10 },
                new TeacherAssessment { Id = 2, Type = "Quiz", Title = "Chapter 4 · Control Flow Quiz", Pending = 4, Questions = 8 },
                new TeacherAssessment { Id = 1, Type = "Assessment", Title = "Chapter 2 · Variables Assessment", Pending = 6, Questions = 12 }
            };
        }

        /// <summary>TODO (backend): learners who submitted the selected assessment (Attempt + GradingProgress).</summary>
        public static List<TeacherSubmission> GetSubmissions()
        {
            return new List<TeacherSubmission>
            {
                new TeacherSubmission { Id = 1, Initials = "TC", Name = "Tang Chee Kin", Email = "tang.cheekin@student.edu.my", Tone = "indigo", Status = "Not graded", Submitted = "28 May 2024, 10:24 AM" },
                new TeacherSubmission { Id = 2, Initials = "AL", Name = "Amanda Lee", Email = "amanda.lee@student.edu.my", Tone = "teal", Status = "In progress", Submitted = "28 May 2024, 9:46 AM" },
                new TeacherSubmission { Id = 3, Initials = "MK", Name = "Muhammad Khairul", Email = "khairul@student.edu.my", Tone = "blue", Status = "Graded", Submitted = "27 May 2024, 4:18 PM" }
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
                new TeacherExamRule { Id = 1, Title = "Strict syntax, indentation and format checking", Description = "Answers must follow exact language syntax and formatting conventions.", Icon = "code", On = true },
                new TeacherExamRule { Id = 2, Title = "Use of libraries and modules", Description = "Allow learners to import standard libraries and approved modules.", Icon = "code", On = true }
            };
        }

        /// <summary>TODO (backend): Question + MCQ_Option rows of the course exam.</summary>
        private const string ExamQuestionsKey = "TeacherExamQuestions";
        private const string ExamsCreatedKey = "TeacherExamsCreated";

        /// <summary>CourseIds whose exam was created this session. TODO (backend): remove, the Exam table says which courses have one.</summary>
        public static HashSet<int> GetCreatedExamCourseIds()
        {
            HttpContext ctx = HttpContext.Current;
            HashSet<int> ids = (ctx != null && ctx.Session != null) ? ctx.Session[ExamsCreatedKey] as HashSet<int> : null;
            return ids ?? new HashSet<int>();
        }

        public static void MarkExamCreated(int courseId)
        {
            HttpContext ctx = HttpContext.Current;
            if (ctx == null || ctx.Session == null) return;
            HashSet<int> ids = GetCreatedExamCourseIds();
            ids.Add(courseId);
            ctx.Session[ExamsCreatedKey] = ids;
        }

        /// <summary>
        /// The questions of a course's exam: the ones saved this session, otherwise the sample questions.
        /// TODO (backend): remove the session store and read Question + MCQ_Option instead.
        /// </summary>
        public static List<TeacherQuestion> GetExamQuestions(int courseId)
        {
            HttpContext ctx = HttpContext.Current;
            Dictionary<int, List<TeacherQuestion>> saved = (ctx != null && ctx.Session != null)
                ? ctx.Session[ExamQuestionsKey] as Dictionary<int, List<TeacherQuestion>> : null;
            List<TeacherQuestion> questions;
            if (saved != null && saved.TryGetValue(courseId, out questions)) return questions;
            return BuildExamQuestions();
        }

        /// <summary>Keeps the questions (in the order the teacher arranged them) for this session only. TODO (backend): INSERT / UPDATE / DELETE on Question and MCQ_Option.</summary>
        public static void SaveExamQuestions(int courseId, List<TeacherQuestion> questions)
        {
            HttpContext ctx = HttpContext.Current;
            if (ctx == null || ctx.Session == null) return;
            Dictionary<int, List<TeacherQuestion>> saved = ctx.Session[ExamQuestionsKey] as Dictionary<int, List<TeacherQuestion>>;
            if (saved == null) saved = new Dictionary<int, List<TeacherQuestion>>();
            saved[courseId] = questions;
            ctx.Session[ExamQuestionsKey] = saved;
        }

        private static List<TeacherQuestion> BuildExamQuestions()
        {
            List<TeacherQuestion> list = new List<TeacherQuestion>();
            list.Add(new TeacherQuestion
            {
Id = 2,
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
Id = 3,
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
    }

    public class TeacherCourse
    {
        public int Id { get; set; }
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
        public List<string> Domains { get; set; } = new List<string>();
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
        public int Id { get; set; }
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
        public int Id { get; set; }
        /// <summary>The chapter's position/label in the course (Chapter.ChapterNum). Not an identifier: use Id for that.</summary>
        public int Number { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        public string Duration { get; set; }
        public string Created { get; set; }
        public string Updated { get; set; }
        /// <summary>The quiz or assessment at the end of the chapter (a chapter has either one, or none: null).</summary>
        public TeacherChapterTestInfo Test { get; set; }
    }

    /// <summary>The single quiz or assessment of a chapter.</summary>
    public class TeacherChapterTestInfo
    {
        public int Id { get; set; }
        /// <summary>quiz | assessment</summary>
        public string Type { get; set; }
        public string Title { get; set; }
        public int Questions { get; set; }
        public int TotalMarks { get; set; }
    }

    /// <summary>A subchapter of a chapter (quizzes and assessments are no longer listed with subchapters).</summary>
    public class TeacherContentItem
    {
        public int Id { get; set; }
        /// <summary>always "subchapter"</summary>
        public string Type { get; set; }
        public string Title { get; set; }
    }

    public class TeacherAssessment
    {
        /// <summary>
        /// Exam, Quiz and Assessment are separate tables, so their ids can overlap (Exam 1 and Quiz 1). Pages therefore identify
        /// one by Key ("exam:1", "quiz:3", "assessment:2"), never by Id alone. TODO (backend): ExamId, QuizId or AssessmentId.
        /// </summary>
        public int Id { get; set; }
        public string Key { get { return (Type ?? "").ToLowerInvariant() + ":" + Id; } }
        /// <summary>Exam | Quiz | Assessment</summary>
        public string Type { get; set; }
        public string Title { get; set; }
        public int Pending { get; set; }
        public int Questions { get; set; }
    }

    public class TeacherSubmission
    {
        /// <summary>One learner's submission of the assessment. TODO (backend): AttemptId.</summary>
        public int Id { get; set; }
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
        /// <summary>Stable id of the rule; the page posts its toggle as tpRule&lt;Id&gt;. TODO (backend): the exam rule column / row it maps to.</summary>
        public int Id { get; set; }
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
        /// <summary>QuestionId; 0 for a question that has not been saved yet (what "Add question" creates).</summary>
        public int Id { get; set; }
        public string Text { get; set; }
        public int Marks { get; set; }
        /// <summary>MCQ | Fill-in-the-blank | Coding (fill-in-the-blank and coding are marked by the teacher)</summary>
        public string Type { get; set; }
        public List<TeacherAnswer> Answers { get; set; }
        public string AcceptedAnswers { get; set; }
        public string ModelAnswer { get; set; }
        public string MarkingGuide { get; set; }

        /// <summary>A new, empty question (2 marks, 4 empty answers) - what "Add question" creates.</summary>
        /// <summary>
        /// Rebuilds the questions from the posted tpq{n}_* fields, in the order they were posted (page order).
        /// A question without an id (0) gets the next free one, starting at nextId.
        /// Pass Request.Unvalidated.Form: a coding question's text legitimately contains characters such as < and >, which
        /// ASP.NET request validation would reject. Everything shown is HTML-encoded on output.
        /// </summary>
        public static List<TeacherQuestion> ReadPosted(System.Collections.Specialized.NameValueCollection form, int nextId)
        {
            List<TeacherQuestion> posted = new List<TeacherQuestion>();
            for (int n = 1; form["tpq" + n + "_text"] != null; n++)
            {
                string prefix = "tpq" + n + "_";
                int id, marks, correct;
                int.TryParse(form[prefix + "id"], out id);
                if (!int.TryParse(form[prefix + "marks"], out marks) || marks < 1) marks = 1;
                if (!int.TryParse(form[prefix + "correct"], out correct)) correct = -1;

                TeacherQuestion question = new TeacherQuestion
                {
                    Id = id > 0 ? id : nextId++,
                    Text = form[prefix + "text"].Trim(),
                    Marks = marks,
                    Type = form[prefix + "type"] ?? "MCQ",
                    AcceptedAnswers = form[prefix + "accepted"] ?? "",
                    ModelAnswer = form[prefix + "model"] ?? "",
                    MarkingGuide = form[prefix + "guide"] ?? "",
                    Answers = new List<TeacherAnswer>()
                };
                for (int m = 0; form[prefix + "a" + m] != null; m++)
                {
                    question.Answers.Add(new TeacherAnswer { Text = form[prefix + "a" + m], Correct = m == correct });
                }
                posted.Add(question);
            }
            return posted;
        }

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
