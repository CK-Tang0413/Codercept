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

        public static List<TeacherExamRule> GetExamRules()
        {
            return new List<TeacherExamRule>
            {
                new TeacherExamRule { Id = 1, Title = "Strict syntax, indentation and format checking", Description = "Answers must follow exact language syntax and formatting conventions.", Icon = "code", On = true },
                new TeacherExamRule { Id = 2, Title = "Use of libraries and modules", Description = "Allow learners to import standard libraries and approved modules.", Icon = "code", On = true }
            };
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
        /// <summary>Learner.AccStatus, for example Active.</summary>
        public string Status { get; set; }
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
        /// <summary>The course the chapter belongs to and its title (filled by TeacherChapterData.GetChapter only).</summary>
        public int CourseId { get; set; }
        public string CourseTitle { get; set; }
        /// <summary>Relative path of the chapter's uploaded file (Chapter.ChapterMediaLink), or null.</summary>
        public string MediaLink { get; set; }
        /// <summary>The chapter's subchapters in order (filled by TeacherChapterData; the sample chapters leave it empty).</summary>
        public List<TeacherContentItem> Contents { get; set; } = new List<TeacherContentItem>();
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
        public string Description { get; set; }
        /// <summary>SubChapter.SubChapterDuration, in minutes</summary>
        public int Minutes { get; set; }
        /// <summary>Relative path of the uploaded file (SubChapter.SubChapterMediaLink), or null.</summary>
        public string MediaLink { get; set; }
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
        /// <summary>The sum of the marks of its questions.</summary>
        public int TotalMarks { get; set; }
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
        /// <summary>Which exam, quiz or assessment it is a submission of: the Key of its TeacherAssessment.</summary>
        public string TestKey { get; set; }
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
                if (!int.TryParse(form[prefix + "marks"], out marks)) marks = 0; // refused by TeacherTestData.Validate (1 to 100)
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
