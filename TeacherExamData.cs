using System;
using System.Collections.Generic;
using System.Data.SqlClient;

namespace Codercept
{
    /// <summary>A course's final exam with its settings and questions.</summary>
    public class TeacherExam
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        /// <summary>The score a learner needs to pass, as a percentage (1 to 100).</summary>
        public int PassMark { get; set; }
        public int TimeLimitMinutes { get; set; }
        /// <summary>Rule 1: the learner's code must follow the language syntax and formatting strictly.</summary>
        public bool StrictSyntax { get; set; }
        /// <summary>Rule 2: the learner may use libraries and modules.</summary>
        public bool AllowLibraries { get; set; }
        public int CourseId { get; set; }
        /// <summary>Learners have attempted it, so its pass mark and questions can no longer change.</summary>
        public bool HasAttempts { get; set; }
        public List<TeacherQuestion> Questions { get; set; }
    }

    /// <summary>
    /// Database queries for a course's final exam (one per course) and its questions. Every query joins to Course and filters on
    /// Course.TeacherId = @TeacherId, so a forged CourseId of another teacher finds nothing. The questions are saved by the same code as
    /// a quiz's or assessment's (TeacherTestData), so the rules for their answers, marks and types are the same.
    /// </summary>
    public static class TeacherExamData
    {
        public const int MinPassMark = 1;
        public const int MaxPassMark = 100;
        public const int MinTimeLimit = 5;
        public const int MaxTimeLimit = 300;

        public enum CreateResult { Created, NotFound, AlreadyExists }

        public enum SaveResult { Saved, NotFound, Locked }

        /// <summary>The exam of one of the signed-in teacher's courses with its questions, or null when the course has none (or is not the teacher's).</summary>
        public static TeacherExam GetExam(int courseId)
        {
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                TeacherExam exam = null;
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT e.ExamId, e.ExamTitle, e.ExamDescription, e.PassMark, e.TimeLimitMinutes, e.StrictSyntax, e.AllowLibraries " +
                    "FROM Exam e INNER JOIN Course c ON c.CourseId = e.CourseId WHERE e.CourseId = @CourseId AND c.TeacherId = @TeacherId", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            exam = new TeacherExam
                            {
                                Id = reader.GetInt32(0),
                                Title = reader.GetString(1),
                                Description = reader.GetString(2),
                                PassMark = reader.GetInt32(3),
                                TimeLimitMinutes = reader.GetInt32(4),
                                StrictSyntax = reader.GetBoolean(5),
                                AllowLibraries = reader.GetBoolean(6),
                                CourseId = courseId
                            };
                        }
                    }
                }
                if (exam == null) return null;

                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Attempt WHERE ExamId = @ExamId", con))
                {
                    cmd.Parameters.AddWithValue("@ExamId", exam.Id);
                    exam.HasAttempts = (int)cmd.ExecuteScalar() > 0;
                }
                exam.Questions = TeacherTestData.ReadExamQuestions(con, exam.Id);
                return exam;
            }
        }

        /// <summary>
        /// Adds the exam (with its questions) to one of the signed-in teacher's courses in one transaction.
        /// Refused when the course is not the teacher's or already has an exam.
        /// </summary>
        public static CreateResult CreateExam(int courseId, string title, string description, int passMark, int timeLimit, bool strictSyntax, bool allowLibraries,
            List<TeacherQuestion> questions, out int examId)
        {
            examId = 0;
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Course WHERE CourseId = @CourseId AND TeacherId = @TeacherId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@CourseId", courseId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        if ((int)cmd.ExecuteScalar() == 0) return CreateResult.NotFound;
                    }

                    // one exam per course: the lock keeps two requests from adding one each (the table also has UNIQUE on CourseId)
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Exam WITH (UPDLOCK, HOLDLOCK) WHERE CourseId = @CourseId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@CourseId", courseId);
                        if ((int)cmd.ExecuteScalar() > 0) return CreateResult.AlreadyExists;
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        "INSERT INTO Exam (DateCreation, DateUpdate, ExamTitle, ExamDescription, PassMark, TimeLimitMinutes, StrictSyntax, AllowLibraries, CourseId, TeacherId) " +
                        "VALUES (GETDATE(), NULL, @Title, @Description, @PassMark, @TimeLimit, @Strict, @Libraries, @CourseId, @TeacherId); SELECT CAST(SCOPE_IDENTITY() AS INT)", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@Title", title);
                        cmd.Parameters.AddWithValue("@Description", description);
                        cmd.Parameters.AddWithValue("@PassMark", passMark);
                        cmd.Parameters.AddWithValue("@TimeLimit", timeLimit);
                        cmd.Parameters.AddWithValue("@Strict", strictSyntax);
                        cmd.Parameters.AddWithValue("@Libraries", allowLibraries);
                        cmd.Parameters.AddWithValue("@CourseId", courseId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        examId = (int)cmd.ExecuteScalar();
                    }

                    TeacherTestData.SaveExamQuestions(con, tx, examId, teacherId, questions);
                    tx.Commit();
                    return CreateResult.Created;
                }
            }
        }

        /// <summary>
        /// Saves a course's exam in one transaction: title, description, time limit, rules and, when questions is not null, the pass mark
        /// and the questions (a stored question is updated in place so its id stays, a new one is added, one no longer posted is deleted).
        /// Once learners have attempted the exam the pass mark and the questions are fixed, so that every learner is judged the same way:
        /// then questions must be null and passMark must be the stored one, otherwise Locked is returned and nothing is saved.
        /// The title, description, time limit and rules can always change.
        /// </summary>
        public static SaveResult UpdateExam(int courseId, string title, string description, int passMark, int timeLimit, bool strictSyntax, bool allowLibraries,
            List<TeacherQuestion> questions)
        {
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    int examId, storedPassMark;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT e.ExamId, e.PassMark FROM Exam e INNER JOIN Course c ON c.CourseId = e.CourseId WHERE e.CourseId = @CourseId AND c.TeacherId = @TeacherId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@CourseId", courseId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (!reader.Read()) return SaveResult.NotFound;
                            examId = reader.GetInt32(0);
                            storedPassMark = reader.GetInt32(1);
                        }
                    }

                    bool attempted;
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Attempt WHERE ExamId = @ExamId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@ExamId", examId);
                        attempted = (int)cmd.ExecuteScalar() > 0;
                    }
                    if (attempted && (questions != null || passMark != storedPassMark)) return SaveResult.Locked;

                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE Exam SET ExamTitle = @Title, ExamDescription = @Description, PassMark = @PassMark, TimeLimitMinutes = @TimeLimit, " +
                        "StrictSyntax = @Strict, AllowLibraries = @Libraries, DateUpdate = GETDATE() WHERE ExamId = @ExamId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@Title", title);
                        cmd.Parameters.AddWithValue("@Description", description);
                        cmd.Parameters.AddWithValue("@PassMark", passMark);
                        cmd.Parameters.AddWithValue("@TimeLimit", timeLimit);
                        cmd.Parameters.AddWithValue("@Strict", strictSyntax);
                        cmd.Parameters.AddWithValue("@Libraries", allowLibraries);
                        cmd.Parameters.AddWithValue("@ExamId", examId);
                        cmd.ExecuteNonQuery();
                    }

                    if (questions != null) TeacherTestData.SaveExamQuestions(con, tx, examId, teacherId, questions);
                    tx.Commit();
                    return SaveResult.Saved;
                }
            }
        }
    }
}
