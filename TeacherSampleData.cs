using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Codercept
{
    /// <summary>
    /// What is left of the prototype's hard-coded data: the sidebar fallback name and email, the difficulty badge tone,
    /// and the exam rules (TODO (backend): replace GetExamRules() with the exam rule rows). The model classes below are shared with the database code.
    /// </summary>
    public static class TeacherSampleData
    {
        // Shown in the sidebar when no session user is available (prototype values).
        public const string FallbackName = "Bryan Yeong";
        public const string FallbackEmail = "bryanyeong@edu.com.my";

        /// <summary>Badge tone used for a course difficulty (Easy/Medium/Hard).</summary>
        public static string DifficultyTone(string difficulty)
        {
            if (difficulty == "Easy") return "success";
            if (difficulty == "Medium") return "warning";
            return "danger";
        }

        public static List<TeacherExamRule> GetExamRules()
        {
            return new List<TeacherExamRule>
            {
                new TeacherExamRule { Id = 1, Title = "Strict syntax, indentation and format checking", Description = "Answers must follow exact language syntax and formatting conventions.", Icon = "code", On = true },
                new TeacherExamRule { Id = 2, Title = "Use of libraries and modules", Description = "Allow learners to import standard libraries and approved modules.", Icon = "code", On = true }
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
        /// <summary>The course and attempt the activity is about (the "Mark answers" link opens that submission).</summary>
        public int CourseId { get; set; }
        public int AttemptId { get; set; }
    }
}
