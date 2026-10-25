using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;

namespace Codercept
{
    /// <summary>A chapter's quiz or assessment with its questions.</summary>
    public class TeacherTest
    {
        public int Id { get; set; }
        /// <summary>quiz | assessment</summary>
        public string Type { get; set; }
        public string Title { get; set; }
        public string Description { get; set; }
        /// <summary>Relative path of the uploaded file, or null.</summary>
        public string MediaLink { get; set; }
        public int ChapterId { get; set; }
        public int CourseId { get; set; }
        /// <summary>Learners have attempted it, so its questions can no longer change and it cannot be deleted.</summary>
        public bool HasAttempts { get; set; }
        public List<TeacherQuestion> Questions { get; set; }
    }

    /// <summary>
    /// Database queries for the quiz or assessment at the end of a chapter (a chapter has one or the other, never both) and their
    /// questions and answer options. Every query joins to Chapter -> Course and filters on Course.TeacherId = @TeacherId, so a forged
    /// id of another teacher's chapter or question finds nothing. Table and column names come from the fixed set in Names, never from input.
    /// </summary>
    public static class TeacherTestData
    {
        public const int MaxMarks = 100;
        public const int MinAnswers = 2;
        public const int MaxAnswers = 6;

        private class Names
        {
            public string Table, Id, Title, Description, Media;
        }

        private static Names NamesOf(string type)
        {
            if (type == "quiz") return new Names { Table = "Quiz", Id = "QuizId", Title = "QuizTitle", Description = "QuizDescription", Media = "QuizMediaLink" };
            if (type == "assessment") return new Names { Table = "Assessment", Id = "AssessmentId", Title = "AssessmentTitle", Description = "AssessmentDescription", Media = "AssessmentMediaLink" };
            throw new ArgumentException("Unknown test type: " + type);
        }

        public enum CreateResult { Created, NotFound, AlreadyHasTest }

        public enum SaveResult { Saved, NotFound, QuestionsLocked }

        public enum DeleteResult { Deleted, NotFound, HasAttempts }

        /// <summary>The quiz or assessment of one of the signed-in teacher's chapters with its questions, or null when there is none.</summary>
        public static TeacherTest GetTest(int chapterId)
        {
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                foreach (string type in new[] { "quiz", "assessment" })
                {
                    Names n = NamesOf(type);
                    TeacherTest test = null;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT t." + n.Id + ", t." + n.Title + ", t." + n.Description + ", t." + n.Media + ", ch.CourseId " +
                        "FROM " + n.Table + " t INNER JOIN Chapter ch ON ch.ChapterId = t.ChapterId INNER JOIN Course c ON c.CourseId = ch.CourseId " +
                        "WHERE t.ChapterId = @ChapterId AND c.TeacherId = @TeacherId", con))
                    {
                        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                test = new TeacherTest
                                {
                                    Id = reader.GetInt32(0),
                                    Type = type,
                                    Title = reader.GetString(1),
                                    Description = reader.GetString(2),
                                    MediaLink = reader.IsDBNull(3) ? null : reader.GetString(3),
                                    ChapterId = chapterId,
                                    CourseId = reader.GetInt32(4)
                                };
                            }
                        }
                    }
                    if (test == null) continue;

                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Attempt WHERE " + n.Id + " = @TestId", con))
                    {
                        cmd.Parameters.AddWithValue("@TestId", test.Id);
                        test.HasAttempts = (int)cmd.ExecuteScalar() > 0;
                    }
                    test.Questions = ReadQuestions(con, n, test.Id);
                    return test;
                }
            }
            return null;
        }

        private static List<TeacherQuestion> ReadQuestions(SqlConnection con, Names n, int testId)
        {
            List<TeacherQuestion> list = new List<TeacherQuestion>();
            using (SqlCommand cmd = new SqlCommand(
                "SELECT QuestionId, QuestionContent, QuestionType, QuestionScore, AcceptedAnswers, ModelAnswer, MarkingGuide " +
                "FROM Question WHERE " + n.Id + " = @TestId ORDER BY QuestionOrder, QuestionId", con))
            {
                cmd.Parameters.AddWithValue("@TestId", testId);
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        list.Add(new TeacherQuestion
                        {
                            Id = reader.GetInt32(0),
                            Text = reader.GetString(1),
                            Type = UiType(reader.GetString(2)),
                            Marks = (int)Math.Round(reader.GetDouble(3)),
                            AcceptedAnswers = reader.IsDBNull(4) ? "" : reader.GetString(4),
                            ModelAnswer = reader.IsDBNull(5) ? "" : reader.GetString(5),
                            MarkingGuide = reader.IsDBNull(6) ? "" : reader.GetString(6),
                            Answers = new List<TeacherAnswer>()
                        });
                    }
                }
            }

            using (SqlCommand cmd = new SqlCommand(
                "SELECT o.QuestionId, o.OptionContent, o.IsCorrect FROM MCQ_Option o INNER JOIN Question q ON q.QuestionId = o.QuestionId " +
                "WHERE q." + n.Id + " = @TestId ORDER BY o.QuestionId, o.OptionOrder, o.MCQ_OptionId", con))
            {
                cmd.Parameters.AddWithValue("@TestId", testId);
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        int questionId = reader.GetInt32(0);
                        TeacherQuestion q = list.FirstOrDefault(x => x.Id == questionId);
                        if (q != null) q.Answers.Add(new TeacherAnswer { Text = reader.GetString(1), Correct = reader.GetBoolean(2) });
                    }
                }
            }
            return list;
        }

        /// <summary>
        /// Checks the posted questions and tidies them (blank answers are dropped, quiz questions are always multiple choice).
        /// Returns a message for the teacher, or null when everything is fine.
        /// </summary>
        public static string Validate(string type, List<TeacherQuestion> questions)
        {
            if (questions.Count == 0) return "Add at least one question before saving.";

            for (int i = 0; i < questions.Count; i++)
            {
                TeacherQuestion q = questions[i];
                string label = "Question " + (i + 1);
                if (type == "quiz") q.Type = "MCQ";

                if ((q.Text ?? "").Trim().Length == 0) return label + " needs some text.";
                if (q.Marks < 1 || q.Marks > MaxMarks) return label + ": marks must be between 1 and " + MaxMarks + ".";

                switch (q.Type)
                {
                    case "MCQ":
                        q.Answers = q.Answers.Where(a => (a.Text ?? "").Trim().Length > 0).ToList();
                        foreach (TeacherAnswer a in q.Answers) a.Text = a.Text.Trim();
                        if (q.Answers.Count < MinAnswers) return label + " needs at least " + MinAnswers + " answers.";
                        if (q.Answers.Count > MaxAnswers) return label + " can have at most " + MaxAnswers + " answers.";
                        if (q.Answers.Count(a => a.Correct) != 1) return label + " needs one correct answer.";
                        break;
                    case "Fill-in-the-blank":
                        if (q.AcceptedAnswers.Split(',').All(a => a.Trim().Length == 0)) return label + " needs at least one accepted answer.";
                        break;
                    case "Coding":
                        if ((q.ModelAnswer ?? "").Trim().Length == 0) return label + " needs a model answer.";
                        break;
                    default:
                        return label + " has an unknown type.";
                }
            }
            return null;
        }

        /// <summary>
        /// Adds a quiz or assessment (with its questions) to one of the signed-in teacher's chapters in one transaction.
        /// Refused when the chapter is not the teacher's, or already has a quiz or an assessment.
        /// </summary>
        public static CreateResult CreateTest(int chapterId, string type, string title, string description, string mediaLink,
            List<TeacherQuestion> questions, out int testId)
        {
            testId = 0;
            Names n = NamesOf(type);
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    int owned;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT COUNT(*) FROM Chapter ch INNER JOIN Course c ON c.CourseId = ch.CourseId WHERE ch.ChapterId = @ChapterId AND c.TeacherId = @TeacherId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        owned = (int)cmd.ExecuteScalar();
                    }
                    if (owned == 0) return CreateResult.NotFound;

                    // a chapter has a quiz OR an assessment: the locks keep two requests from adding one each
                    int existing;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT (SELECT COUNT(*) FROM Quiz WITH (UPDLOCK, HOLDLOCK) WHERE ChapterId = @ChapterId) " +
                        "     + (SELECT COUNT(*) FROM Assessment WITH (UPDLOCK, HOLDLOCK) WHERE ChapterId = @ChapterId)", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
                        existing = (int)cmd.ExecuteScalar();
                    }
                    if (existing > 0) return CreateResult.AlreadyHasTest;

                    using (SqlCommand cmd = new SqlCommand(
                        "INSERT INTO " + n.Table + " (DateCreation, DateUpdate, " + n.Title + ", " + n.Description + ", " + n.Media + ", ChapterId, TeacherId) " +
                        "VALUES (GETDATE(), GETDATE(), @Title, @Description, @Media, @ChapterId, @TeacherId); SELECT CAST(SCOPE_IDENTITY() AS INT)", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@Title", title);
                        cmd.Parameters.AddWithValue("@Description", description);
                        cmd.Parameters.AddWithValue("@Media", (object)mediaLink ?? DBNull.Value);
                        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        testId = (int)cmd.ExecuteScalar();
                    }

                    SaveQuestions(con, tx, n, testId, teacherId, questions);
                    tx.Commit();
                    return CreateResult.Created;
                }
            }
        }

        /// <summary>
        /// Saves the title, description and (when changeMedia) the file link of a chapter's quiz or assessment and, when questions is not
        /// null, its questions, in one transaction. A question that is already stored is updated in place (so its id stays), a new one is
        /// added and one that is no longer posted is deleted. Questions cannot change once learners have attempted the test: then
        /// QuestionsLocked is returned and nothing is saved. oldMedia returns the file link the test had.
        /// </summary>
        public static SaveResult UpdateTest(int chapterId, string type, string title, string description, bool changeMedia, string newMedia,
            List<TeacherQuestion> questions, out string oldMedia)
        {
            oldMedia = null;
            Names n = NamesOf(type);
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    int testId;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT t." + n.Id + ", t." + n.Media + " FROM " + n.Table + " t INNER JOIN Chapter ch ON ch.ChapterId = t.ChapterId " +
                        "INNER JOIN Course c ON c.CourseId = ch.CourseId WHERE t.ChapterId = @ChapterId AND c.TeacherId = @TeacherId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (!reader.Read()) return SaveResult.NotFound;
                            testId = reader.GetInt32(0);
                            oldMedia = reader.IsDBNull(1) ? null : reader.GetString(1);
                        }
                    }

                    if (questions != null)
                    {
                        using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Attempt WHERE " + n.Id + " = @TestId", con, tx))
                        {
                            cmd.Parameters.AddWithValue("@TestId", testId);
                            if ((int)cmd.ExecuteScalar() > 0) return SaveResult.QuestionsLocked;
                        }
                    }

                    Run(con, tx,
                        "UPDATE " + n.Table + " SET " + n.Title + " = @Title, " + n.Description + " = @Description, DateUpdate = GETDATE(), " +
                        n.Media + " = CASE WHEN @ChangeMedia = 1 THEN @Media ELSE " + n.Media + " END WHERE " + n.Id + " = @TestId",
                        new SqlParameter("@Title", title), new SqlParameter("@Description", description),
                        new SqlParameter("@ChangeMedia", changeMedia ? 1 : 0), new SqlParameter("@Media", (object)newMedia ?? DBNull.Value),
                        new SqlParameter("@TestId", testId));

                    if (questions != null) SaveQuestions(con, tx, n, testId, teacherId, questions);
                    tx.Commit();
                    return SaveResult.Saved;
                }
            }
        }

        /// <summary>
        /// Deletes a chapter's quiz or assessment with its questions and options. Refused when learners have attempted it (their
        /// results are kept). mediaFile is the stored file that belonged to it (or null); the caller removes it from disk afterwards.
        /// </summary>
        public static DeleteResult DeleteTest(int chapterId, string type, out string mediaFile)
        {
            mediaFile = null;
            Names n = NamesOf(type);
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    int testId;
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT t." + n.Id + ", t." + n.Media + " FROM " + n.Table + " t INNER JOIN Chapter ch ON ch.ChapterId = t.ChapterId " +
                        "INNER JOIN Course c ON c.CourseId = ch.CourseId WHERE t.ChapterId = @ChapterId AND c.TeacherId = @TeacherId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@ChapterId", chapterId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (!reader.Read()) return DeleteResult.NotFound;
                            testId = reader.GetInt32(0);
                            mediaFile = reader.IsDBNull(1) ? null : reader.GetString(1);
                        }
                    }

                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Attempt WHERE " + n.Id + " = @TestId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@TestId", testId);
                        if ((int)cmd.ExecuteScalar() > 0)
                        {
                            mediaFile = null;
                            return DeleteResult.HasAttempts;
                        }
                    }

                    SqlParameter id() { return new SqlParameter("@TestId", testId); }
                    Run(con, tx, "DELETE FROM MCQ_Option WHERE QuestionId IN (SELECT QuestionId FROM Question WHERE " + n.Id + " = @TestId)", id());
                    Run(con, tx, "DELETE FROM Question WHERE " + n.Id + " = @TestId", id());
                    Run(con, tx, "DELETE FROM " + n.Table + " WHERE " + n.Id + " = @TestId", id());
                    tx.Commit();
                    return DeleteResult.Deleted;
                }
            }
        }

        /// <summary>
        /// Makes the stored questions of a test match the posted list (already validated), in order: a posted question whose id is one
        /// of this test's stored questions is updated, any other is added, and stored questions that were not posted are deleted.
        /// A posted id that belongs to some other test is just a new question here, so it can never change another test.
        /// </summary>
        private static void SaveQuestions(SqlConnection con, SqlTransaction tx, Names n, int testId, int teacherId, List<TeacherQuestion> questions)
        {
            HashSet<int> stored = new HashSet<int>();
            using (SqlCommand cmd = new SqlCommand("SELECT QuestionId FROM Question WHERE " + n.Id + " = @TestId", con, tx))
            {
                cmd.Parameters.AddWithValue("@TestId", testId);
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read()) stored.Add(reader.GetInt32(0));
                }
            }

            HashSet<int> kept = new HashSet<int>();
            for (int i = 0; i < questions.Count; i++)
            {
                TeacherQuestion q = questions[i];
                bool mcq = q.Type == "MCQ";
                SqlParameter[] fields =
                {
                    new SqlParameter("@Content", q.Text.Trim()),
                    new SqlParameter("@Type", DbType(q.Type)),
                    new SqlParameter("@Score", (double)q.Marks),
                    new SqlParameter("@Order", i + 1),
                    new SqlParameter("@Accepted", q.Type == "Fill-in-the-blank" ? (object)q.AcceptedAnswers.Trim() : DBNull.Value),
                    new SqlParameter("@Model", q.Type == "Coding" ? (object)q.ModelAnswer : DBNull.Value),
                    new SqlParameter("@Guide", q.Type == "Coding" && (q.MarkingGuide ?? "").Trim().Length > 0 ? (object)q.MarkingGuide.Trim() : DBNull.Value)
                };

                int questionId;
                if (stored.Contains(q.Id) && kept.Add(q.Id))
                {
                    questionId = q.Id;
                    List<SqlParameter> parameters = new List<SqlParameter>(fields) { new SqlParameter("@QuestionId", questionId), new SqlParameter("@TestId", testId) };
                    Run(con, tx,
                        "UPDATE Question SET QuestionContent = @Content, QuestionType = @Type, QuestionScore = @Score, QuestionOrder = @Order, " +
                        "AcceptedAnswers = @Accepted, ModelAnswer = @Model, MarkingGuide = @Guide WHERE QuestionId = @QuestionId AND " + n.Id + " = @TestId",
                        parameters.ToArray());
                    Run(con, tx, "DELETE FROM MCQ_Option WHERE QuestionId = @QuestionId", new SqlParameter("@QuestionId", questionId));
                }
                else
                {
                    using (SqlCommand cmd = new SqlCommand(
                        "INSERT INTO Question (QuestionContent, QuestionType, QuestionScore, QuestionOrder, AcceptedAnswers, ModelAnswer, MarkingGuide, TeacherId, " + n.Id + ") " +
                        "VALUES (@Content, @Type, @Score, @Order, @Accepted, @Model, @Guide, @TeacherId, @TestId); SELECT CAST(SCOPE_IDENTITY() AS INT)", con, tx))
                    {
                        cmd.Parameters.AddRange(fields);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        cmd.Parameters.AddWithValue("@TestId", testId);
                        questionId = (int)cmd.ExecuteScalar();
                    }
                }

                if (mcq)
                {
                    for (int a = 0; a < q.Answers.Count; a++)
                    {
                        Run(con, tx, "INSERT INTO MCQ_Option (OptionContent, IsCorrect, OptionOrder, QuestionId) VALUES (@Text, @Correct, @Order, @QuestionId)",
                            new SqlParameter("@Text", q.Answers[a].Text), new SqlParameter("@Correct", q.Answers[a].Correct),
                            new SqlParameter("@Order", a + 1), new SqlParameter("@QuestionId", questionId));
                    }
                }
            }

            // questions the teacher removed
            foreach (int gone in stored.Where(id => !kept.Contains(id)))
            {
                Run(con, tx, "DELETE FROM MCQ_Option WHERE QuestionId = @QuestionId", new SqlParameter("@QuestionId", gone));
                Run(con, tx, "DELETE FROM Question WHERE QuestionId = @QuestionId AND " + n.Id + " = @TestId", new SqlParameter("@QuestionId", gone), new SqlParameter("@TestId", testId));
            }
        }

        /// <summary>The page's question types as the Question.QuestionType column stores them.</summary>
        private static string DbType(string uiType)
        {
            if (uiType == "Fill-in-the-blank") return "FillBlank";
            return uiType == "Coding" ? "Coding" : "MCQ";
        }

        private static string UiType(string dbType)
        {
            if (dbType == "FillBlank") return "Fill-in-the-blank";
            return dbType == "Coding" ? "Coding" : "MCQ";
        }

        private static int Run(SqlConnection con, SqlTransaction tx, string sql, params SqlParameter[] parameters)
        {
            using (SqlCommand cmd = new SqlCommand(sql, con, tx))
            {
                cmd.Parameters.AddRange(parameters);
                return cmd.ExecuteNonQuery();
            }
        }
    }
}
