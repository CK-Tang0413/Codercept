using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;

namespace Codercept
{
    /// <summary>What happened when a teacher saved grading progress.</summary>
    public enum GradingSaveResult
    {
        Saved,
        /// <summary>No such submitted attempt in one of this teacher's courses (it is not revealed whether it belongs to someone else).</summary>
        NotFound,
        /// <summary>The attempt already has a Result, so it can no longer be changed.</summary>
        AlreadyGraded,
        /// <summary>A mark was not a whole number from 0 up to the question's marks.</summary>
        InvalidMarks,
        CommentTooLong
    }

    /// <summary>What a confirmed grade came to (set by ConfirmGrade).</summary>
    public class GradeOutcome
    {
        public int Total { get; set; }
        public int Max { get; set; }
        public string Grade { get; set; }
        /// <summary>The attempt was of the course's exam (quizzes and assessments never earn a certificate).</summary>
        public bool IsExam { get; set; }
        /// <summary>Exam.PassMark, a percentage; only meaningful for an exam.</summary>
        public int PassMark { get; set; }
        public bool Passed { get; set; }
        /// <summary>A Certificate row was added now (false when the learner already had one for the course).</summary>
        public bool CertificateIssued { get; set; }
    }

    /// <summary>One answer choice of a multiple-choice question, as the learner saw it.</summary>
    public class TeacherMarkingOption
    {
        public int Id { get; set; }
        public string Text { get; set; }
        /// <summary>The right answer (MCQ_Option.IsCorrect).</summary>
        public bool Correct { get; set; }
        /// <summary>The learner picked this one.</summary>
        public bool Chosen { get; set; }
    }

    /// <summary>One question of a submission, with what the learner answered and the marks given so far.</summary>
    public class TeacherMarkingQuestion
    {
        public int Id { get; set; }
        /// <summary>Position in the exam / quiz / assessment, from 1.</summary>
        public int Number { get; set; }
        /// <summary>MCQ | FillBlank | Coding. Only MCQ is scored automatically.</summary>
        public string Type { get; set; }
        public string Text { get; set; }
        public int Marks { get; set; }
        public List<TeacherMarkingOption> Options { get; set; }
        /// <summary>False when the learner left the question unanswered (no AttemptAnswer row).</summary>
        public bool Answered { get; set; }
        /// <summary>Fill-in-the-blank and coding: the learner's text.</summary>
        public string Answer { get; set; }
        public string AcceptedAnswers { get; set; }
        public string ModelAnswer { get; set; }
        public string MarkingGuide { get; set; }
        /// <summary>Marks the teacher has given so far (AttemptAnswer.ObtainedScore); only used for fill-in-the-blank and coding.</summary>
        public int Given { get; set; }
        public string Comment { get; set; }

        public bool IsAuto { get { return Type == "MCQ"; } }
        public bool McqCorrect { get { return Options.Any(o => o.Chosen && o.Correct); } }
        /// <summary>Full marks for a right multiple-choice answer, otherwise 0.</summary>
        public int AutoScore { get { return McqCorrect ? Marks : 0; } }
    }

    /// <summary>
    /// Database queries for the "Grade assessments" page: what can be graded in one of the signed-in teacher's courses, and who has
    /// submitted it. Every query joins to Course and filters on Course.TeacherId = @TeacherId, so a forged CourseId of another teacher
    /// finds nothing. A submission is an Attempt the learner has completed; it waits for the teacher while it has no Result row.
    /// </summary>
    public static class TeacherGradingData
    {
        // Avatar colours (css .avatar--<tone>), picked by learner so a learner always keeps the same one
        private static readonly string[] Tones = { "indigo", "teal", "blue", "amber", "rose" };

        /// <summary>
        /// The course's exam, then the quizzes and assessments of its chapters (in chapter order), each with its number of questions,
        /// total marks and how many submissions wait for grading. Empty when the course has none of them.
        /// </summary>
        public static List<TeacherAssessment> GetGradables(int courseId)
        {
            List<TeacherAssessment> list = new List<TeacherAssessment>();
            int teacherId = TeacherDb.GetTeacherId();

            const string pendingOf = "(SELECT COUNT(*) FROM Attempt a WHERE a.{0} = t.{0} AND a.AttemptStatus = 'completed' " +
                                     "AND NOT EXISTS (SELECT 1 FROM Result r WHERE r.AttemptId = a.AttemptId))";
            const string questionsOf = "(SELECT COUNT(*) FROM Question q WHERE q.{0} = t.{0})";
            const string marksOf = "ISNULL((SELECT SUM(q.QuestionScore) FROM Question q WHERE q.{0} = t.{0}), 0)";

            string sql =
                "WITH Pos AS (SELECT ChapterId, ROW_NUMBER() OVER (ORDER BY ChapterNum, ChapterId) AS N FROM Chapter WHERE CourseId = @CourseId) " +
                "SELECT 'Exam' AS Type, t.ExamId AS Id, t.ExamTitle AS Title, 0 AS ChapterPos, " +
                    string.Format(questionsOf, "ExamId") + " AS Questions, " + string.Format(marksOf, "ExamId") + " AS Marks, " + string.Format(pendingOf, "ExamId") + " AS Pending " +
                "FROM Exam t INNER JOIN Course c ON c.CourseId = t.CourseId WHERE t.CourseId = @CourseId AND c.TeacherId = @TeacherId " +
                "UNION ALL " +
                "SELECT 'Quiz', t.QuizId, t.QuizTitle, CAST(p.N AS INT), " +
                    string.Format(questionsOf, "QuizId") + ", " + string.Format(marksOf, "QuizId") + ", " + string.Format(pendingOf, "QuizId") + " " +
                "FROM Quiz t INNER JOIN Pos p ON p.ChapterId = t.ChapterId INNER JOIN Chapter ch ON ch.ChapterId = t.ChapterId " +
                "INNER JOIN Course c ON c.CourseId = ch.CourseId WHERE c.TeacherId = @TeacherId " +
                "UNION ALL " +
                "SELECT 'Assessment', t.AssessmentId, t.AssessmentTitle, CAST(p.N AS INT), " +
                    string.Format(questionsOf, "AssessmentId") + ", " + string.Format(marksOf, "AssessmentId") + ", " + string.Format(pendingOf, "AssessmentId") + " " +
                "FROM Assessment t INNER JOIN Pos p ON p.ChapterId = t.ChapterId INNER JOIN Chapter ch ON ch.ChapterId = t.ChapterId " +
                "INNER JOIN Course c ON c.CourseId = ch.CourseId WHERE c.TeacherId = @TeacherId " +
                "ORDER BY ChapterPos, Id";

            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@CourseId", courseId);
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string type = reader.GetString(0);
                        int chapterPos = reader.GetInt32(3);
                        list.Add(new TeacherAssessment
                        {
                            Type = type,
                            Id = reader.GetInt32(1),
                            Title = type == "Exam" ? reader.GetString(2) : "Chapter " + chapterPos + " · " + reader.GetString(2),
                            Questions = reader.GetInt32(4),
                            TotalMarks = (int)Math.Round(reader.GetDouble(5)),
                            Pending = reader.GetInt32(6)
                        });
                    }
                }
            }
            return list;
        }

        /// <summary>
        /// Every learner who has submitted (completed) an attempt on one of the course's exam, quizzes or assessments. TestKey says which
        /// one ("exam:1", "quiz:3", "assessment:2", the same keys as TeacherAssessment.Key). Status is "Graded" once the attempt has a Result,
        /// "In progress" while the teacher has started grading it (a GradingProgress row), otherwise "Not graded".
        /// Waiting submissions come first, newest first.
        /// </summary>
        public static List<TeacherSubmission> GetSubmissions(int courseId)
        {
            List<TeacherSubmission> list = new List<TeacherSubmission>();
            int teacherId = TeacherDb.GetTeacherId();

            const string status =
                "CASE WHEN EXISTS (SELECT 1 FROM Result r WHERE r.AttemptId = a.AttemptId) THEN 'Graded' " +
                "WHEN EXISTS (SELECT 1 FROM GradingProgress g WHERE g.AttemptId = a.AttemptId) THEN 'In progress' ELSE 'Not graded' END";

            string sql =
                "SELECT a.AttemptId, a.LearnerId, l.Name, l.Email, a.AttemptDate, " + status + ", 'exam', a.ExamId " +
                "FROM Attempt a INNER JOIN Learner l ON l.LearnerId = a.LearnerId INNER JOIN Exam t ON t.ExamId = a.ExamId " +
                "INNER JOIN Course c ON c.CourseId = t.CourseId " +
                "WHERE t.CourseId = @CourseId AND c.TeacherId = @TeacherId AND a.AttemptStatus = 'completed' " +
                "UNION ALL " +
                "SELECT a.AttemptId, a.LearnerId, l.Name, l.Email, a.AttemptDate, " + status + ", 'quiz', a.QuizId " +
                "FROM Attempt a INNER JOIN Learner l ON l.LearnerId = a.LearnerId INNER JOIN Quiz t ON t.QuizId = a.QuizId " +
                "INNER JOIN Chapter ch ON ch.ChapterId = t.ChapterId INNER JOIN Course c ON c.CourseId = ch.CourseId " +
                "WHERE ch.CourseId = @CourseId AND c.TeacherId = @TeacherId AND a.AttemptStatus = 'completed' " +
                "UNION ALL " +
                "SELECT a.AttemptId, a.LearnerId, l.Name, l.Email, a.AttemptDate, " + status + ", 'assessment', a.AssessmentId " +
                "FROM Attempt a INNER JOIN Learner l ON l.LearnerId = a.LearnerId INNER JOIN Assessment t ON t.AssessmentId = a.AssessmentId " +
                "INNER JOIN Chapter ch ON ch.ChapterId = t.ChapterId INNER JOIN Course c ON c.CourseId = ch.CourseId " +
                "WHERE ch.CourseId = @CourseId AND c.TeacherId = @TeacherId AND a.AttemptStatus = 'completed'";

            List<DateTime> dates = new List<DateTime>();
            using (SqlConnection con = TeacherDb.GetConnection())
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@CourseId", courseId);
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string name = reader.GetString(2);
                        DateTime when = reader.GetDateTime(4);
                        dates.Add(when);
                        list.Add(new TeacherSubmission
                        {
                            Id = reader.GetInt32(0),
                            Initials = InitialsOf(name),
                            Name = name,
                            Email = reader.GetString(3),
                            Tone = Tones[reader.GetInt32(1) % Tones.Length],
                            Status = reader.GetString(5),
                            Submitted = when.ToString("d MMM yyyy, h:mm tt", CultureInfo.InvariantCulture),
                            TestKey = reader.GetString(6) + ":" + reader.GetInt32(7)
                        });
                    }
                }
            }

            // waiting submissions first (not graded, then in progress, then graded), newest first within each
            return list.Select((s, i) => new { s, when = dates[i] })
                .OrderBy(x => x.s.Status == "Not graded" ? 0 : x.s.Status == "In progress" ? 1 : 2)
                .ThenByDescending(x => x.when)
                .Select(x => x.s)
                .ToList();
        }

        // The questions of one course's exam, quizzes and assessments, limited to the signed-in teacher's own course. Every query
        // below starts with this, so the options and answers are filtered by teacher too.
        private const string QuestionsOfCourse =
            "WITH CQ AS (" +
            "SELECT q.QuestionId, 'exam' AS K, q.ExamId AS TestId FROM Question q " +
            "INNER JOIN Exam e ON e.ExamId = q.ExamId INNER JOIN Course c ON c.CourseId = e.CourseId " +
            "WHERE e.CourseId = @CourseId AND c.TeacherId = @TeacherId " +
            "UNION ALL " +
            "SELECT q.QuestionId, 'quiz', q.QuizId FROM Question q " +
            "INNER JOIN Quiz z ON z.QuizId = q.QuizId INNER JOIN Chapter ch ON ch.ChapterId = z.ChapterId INNER JOIN Course c ON c.CourseId = ch.CourseId " +
            "WHERE ch.CourseId = @CourseId AND c.TeacherId = @TeacherId " +
            "UNION ALL " +
            "SELECT q.QuestionId, 'assessment', q.AssessmentId FROM Question q " +
            "INNER JOIN Assessment s ON s.AssessmentId = q.AssessmentId INNER JOIN Chapter ch ON ch.ChapterId = s.ChapterId INNER JOIN Course c ON c.CourseId = ch.CourseId " +
            "WHERE ch.CourseId = @CourseId AND c.TeacherId = @TeacherId) ";

        /// <summary>
        /// The marking sheet of each submission (keyed by AttemptId): the questions of the exam, quiz or assessment it belongs to, in order,
        /// with the learner's answers and any marks and comments already saved. Questions, options and answers are all read through
        /// Course.TeacherId, so another teacher's course gives nothing. An answer only counts when its attempt is of the same exam / quiz /
        /// assessment as the question.
        /// </summary>
        public static Dictionary<int, List<TeacherMarkingQuestion>> GetMarkingSheets(int courseId, List<TeacherSubmission> submissions)
        {
            int teacherId = TeacherDb.GetTeacherId();
            Dictionary<string, List<TeacherMarkingQuestion>> byTest = new Dictionary<string, List<TeacherMarkingQuestion>>();
            Dictionary<int, List<TeacherMarkingOption>> optionsOf = new Dictionary<int, List<TeacherMarkingOption>>();
            Dictionary<int, Dictionary<int, TeacherMarkingQuestion>> answersOf = new Dictionary<int, Dictionary<int, TeacherMarkingQuestion>>();

            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand(QuestionsOfCourse +
                    "SELECT q.QuestionId, CQ.K, CQ.TestId, q.QuestionContent, q.QuestionType, q.QuestionScore, q.AcceptedAnswers, q.ModelAnswer, q.MarkingGuide " +
                    "FROM CQ INNER JOIN Question q ON q.QuestionId = CQ.QuestionId ORDER BY CQ.K, CQ.TestId, q.QuestionOrder, q.QuestionId", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            string key = reader.GetString(1) + ":" + reader.GetInt32(2);
                            List<TeacherMarkingQuestion> list;
                            if (!byTest.TryGetValue(key, out list)) { list = new List<TeacherMarkingQuestion>(); byTest[key] = list; }
                            list.Add(new TeacherMarkingQuestion
                            {
                                Id = reader.GetInt32(0),
                                Number = list.Count + 1,
                                Text = reader.GetString(3),
                                Type = reader.GetString(4),
                                Marks = (int)Math.Round(reader.GetDouble(5)),
                                AcceptedAnswers = reader.IsDBNull(6) ? "" : reader.GetString(6),
                                ModelAnswer = reader.IsDBNull(7) ? "" : reader.GetString(7),
                                MarkingGuide = reader.IsDBNull(8) ? "" : reader.GetString(8)
                            });
                        }
                    }
                }

                using (SqlCommand cmd = new SqlCommand(QuestionsOfCourse +
                    "SELECT o.QuestionId, o.MCQ_OptionId, o.OptionContent, o.IsCorrect FROM MCQ_Option o " +
                    "INNER JOIN CQ ON CQ.QuestionId = o.QuestionId ORDER BY o.QuestionId, o.OptionOrder, o.MCQ_OptionId", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int questionId = reader.GetInt32(0);
                            List<TeacherMarkingOption> list;
                            if (!optionsOf.TryGetValue(questionId, out list)) { list = new List<TeacherMarkingOption>(); optionsOf[questionId] = list; }
                            list.Add(new TeacherMarkingOption { Id = reader.GetInt32(1), Text = reader.GetString(2), Correct = reader.GetBoolean(3) });
                        }
                    }
                }

                // the stored answer, marks and comment of each (attempt, question), carried on a plain TeacherMarkingQuestion
                using (SqlCommand cmd = new SqlCommand(QuestionsOfCourse +
                    "SELECT aa.AttemptId, aa.QuestionId, aa.AnswerContent, aa.ObtainedScore, aa.TeacherComment FROM AttemptAnswer aa " +
                    "INNER JOIN Attempt a ON a.AttemptId = aa.AttemptId " +
                    "INNER JOIN CQ ON CQ.QuestionId = aa.QuestionId AND ((CQ.K = 'exam' AND a.ExamId = CQ.TestId) " +
                    "OR (CQ.K = 'quiz' AND a.QuizId = CQ.TestId) OR (CQ.K = 'assessment' AND a.AssessmentId = CQ.TestId))", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int attemptId = reader.GetInt32(0);
                            Dictionary<int, TeacherMarkingQuestion> forAttempt;
                            if (!answersOf.TryGetValue(attemptId, out forAttempt)) { forAttempt = new Dictionary<int, TeacherMarkingQuestion>(); answersOf[attemptId] = forAttempt; }
                            forAttempt[reader.GetInt32(1)] = new TeacherMarkingQuestion
                            {
                                Answer = reader.GetString(2),
                                Given = (int)Math.Round(reader.GetDouble(3)),
                                Comment = reader.GetString(4)
                            };
                        }
                    }
                }
            }

            Dictionary<int, List<TeacherMarkingQuestion>> sheets = new Dictionary<int, List<TeacherMarkingQuestion>>();
            foreach (TeacherSubmission submission in submissions)
            {
                List<TeacherMarkingQuestion> template;
                if (!byTest.TryGetValue(submission.TestKey, out template)) template = new List<TeacherMarkingQuestion>();
                Dictionary<int, TeacherMarkingQuestion> answers;
                answersOf.TryGetValue(submission.Id, out answers);

                List<TeacherMarkingQuestion> sheet = new List<TeacherMarkingQuestion>();
                foreach (TeacherMarkingQuestion question in template)
                {
                    TeacherMarkingQuestion given = null;
                    bool answered = answers != null && answers.TryGetValue(question.Id, out given);
                    TeacherMarkingQuestion copy = new TeacherMarkingQuestion
                    {
                        Id = question.Id, Number = question.Number, Type = question.Type, Text = question.Text, Marks = question.Marks,
                        AcceptedAnswers = question.AcceptedAnswers, ModelAnswer = question.ModelAnswer, MarkingGuide = question.MarkingGuide,
                        Answered = answered,
                        Answer = answered ? given.Answer : "",
                        Given = answered ? Math.Max(0, Math.Min(question.Marks, given.Given)) : 0,
                        Comment = answered ? given.Comment : "",
                        Options = new List<TeacherMarkingOption>()
                    };
                    List<TeacherMarkingOption> options;
                    if (question.Type == "MCQ" && optionsOf.TryGetValue(question.Id, out options))
                    {
                        // a multiple-choice answer is the id of the option the learner picked
                        int chosen;
                        if (!answered || !int.TryParse(given.Answer, out chosen)) chosen = -1;
                        foreach (TeacherMarkingOption o in options)
                        {
                            copy.Options.Add(new TeacherMarkingOption { Id = o.Id, Text = o.Text, Correct = o.Correct, Chosen = o.Id == chosen });
                        }
                    }
                    sheet.Add(copy);
                }
                sheets[submission.Id] = sheet;
            }
            return sheets;
        }

        /// <summary>The longest comment a teacher can leave on one answer.</summary>
        public const int MaxCommentLength = 2000;

        /// <summary>
        /// Saves the marks and comments typed for one submission's fill-in-the-blank and coding answers, and records that the teacher has
        /// started grading it (a GradingProgress row, kept once per attempt). The form holds tpm_&lt;AttemptId&gt;_&lt;QuestionId&gt; (marks) and
        /// tpc_&lt;AttemptId&gt;_&lt;QuestionId&gt; (comment). Only the manual questions the database says belong to this attempt's exam, quiz or
        /// assessment are read from the form; a field for any other question is ignored, and a question with no field is left as it is.
        /// Everything is checked first and written in one transaction, so a refused save changes nothing. The attempt must be a completed
        /// one of this teacher's course (checked through Course.TeacherId) and must not have a Result yet.
        /// </summary>
        public static GradingSaveResult SaveProgress(int courseId, int attemptId, System.Collections.Specialized.NameValueCollection form)
        {
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    GradingSaveResult? refused = CheckGradable(con, tx, courseId, attemptId, teacherId);
                    if (refused != null) return refused.Value;

                    // the manual questions of the attempt's own exam / quiz / assessment, and what each is worth
                    List<int> questionIds = new List<int>();
                    List<int> maxMarks = new List<int>();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT q.QuestionId, q.QuestionScore FROM Question q INNER JOIN Attempt a ON " +
                        "(q.ExamId = a.ExamId OR q.QuizId = a.QuizId OR q.AssessmentId = a.AssessmentId) " +
                        "WHERE a.AttemptId = @AttemptId AND q.QuestionType IN ('FillBlank', 'Coding') ORDER BY q.QuestionOrder, q.QuestionId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@AttemptId", attemptId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                questionIds.Add(reader.GetInt32(0));
                                maxMarks.Add((int)Math.Round(reader.GetDouble(1)));
                            }
                        }
                    }

                    // check every posted value before writing any
                    List<int> toSave = new List<int>();
                    List<int> marks = new List<int>();
                    List<string> comments = new List<string>();
                    for (int i = 0; i < questionIds.Count; i++)
                    {
                        string markField = form["tpm_" + attemptId + "_" + questionIds[i]];
                        if (markField == null) continue;
                        int mark;
                        if (!int.TryParse(markField, NumberStyles.None, CultureInfo.InvariantCulture, out mark) || mark < 0 || mark > maxMarks[i])
                        {
                            return GradingSaveResult.InvalidMarks;
                        }
                        string comment = (form["tpc_" + attemptId + "_" + questionIds[i]] ?? "").Trim();
                        if (comment.Length > MaxCommentLength) return GradingSaveResult.CommentTooLong;
                        toSave.Add(questionIds[i]);
                        marks.Add(mark);
                        comments.Add(comment);
                    }

                    for (int i = 0; i < toSave.Count; i++)
                    {
                        // a question the learner left blank has no AttemptAnswer row yet: add one with an empty answer
                        using (SqlCommand cmd = new SqlCommand(
                            "UPDATE AttemptAnswer SET ObtainedScore = @Marks, TeacherComment = @Comment WHERE AttemptId = @AttemptId AND QuestionId = @QuestionId; " +
                            "IF @@ROWCOUNT = 0 INSERT INTO AttemptAnswer (AttemptId, QuestionId, AnswerContent, IsCorrect, ObtainedScore, TeacherComment) " +
                            "VALUES (@AttemptId, @QuestionId, '', 'pending', @Marks, @Comment)", con, tx))
                        {
                            cmd.Parameters.AddWithValue("@AttemptId", attemptId);
                            cmd.Parameters.AddWithValue("@QuestionId", toSave[i]);
                            cmd.Parameters.AddWithValue("@Marks", (double)marks[i]);
                            cmd.Parameters.AddWithValue("@Comment", comments[i]);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    // one GradingProgress row per attempt: "the teacher has started grading it"
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE GradingProgress SET ProgressStatus = 'in_progress', TeacherId = @TeacherId WHERE AttemptId = @AttemptId; " +
                        "IF @@ROWCOUNT = 0 INSERT INTO GradingProgress (ProgressStatus, ProgressNotes, TeacherId, TA_Id, AttemptId) " +
                        "VALUES ('in_progress', '', @TeacherId, NULL, @AttemptId)", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@AttemptId", attemptId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        cmd.ExecuteNonQuery();
                    }

                    tx.Commit();
                    return GradingSaveResult.Saved;
                }
            }
        }

        /// <summary>
        /// Null when the attempt can be graded: a completed attempt of an exam, quiz or assessment of this teacher's course (checked through
        /// Course.TeacherId) that has no Result yet. Otherwise NotFound or AlreadyGraded. It locks the attempt for the rest of the
        /// transaction, so a second request cannot grade it at the same time.
        /// </summary>
        private static GradingSaveResult? CheckGradable(SqlConnection con, SqlTransaction tx, int courseId, int attemptId, int teacherId)
        {
            using (SqlCommand cmd = new SqlCommand(
                "SELECT CASE WHEN EXISTS (SELECT 1 FROM Result r WHERE r.AttemptId = a.AttemptId) THEN 1 ELSE 0 END " +
                "FROM Attempt a WITH (UPDLOCK, HOLDLOCK) " +
                "LEFT JOIN Exam e ON e.ExamId = a.ExamId " +
                "LEFT JOIN Quiz z ON z.QuizId = a.QuizId LEFT JOIN Chapter cz ON cz.ChapterId = z.ChapterId " +
                "LEFT JOIN Assessment s ON s.AssessmentId = a.AssessmentId LEFT JOIN Chapter cs ON cs.ChapterId = s.ChapterId " +
                "INNER JOIN Course c ON c.CourseId = COALESCE(e.CourseId, cz.CourseId, cs.CourseId) " +
                "WHERE a.AttemptId = @AttemptId AND a.AttemptStatus = 'completed' AND c.CourseId = @CourseId AND c.TeacherId = @TeacherId", con, tx))
            {
                cmd.Parameters.AddWithValue("@AttemptId", attemptId);
                cmd.Parameters.AddWithValue("@CourseId", courseId);
                cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                object found = cmd.ExecuteScalar();
                if (found == null) return GradingSaveResult.NotFound;
                return (int)found == 1 ? GradingSaveResult.AlreadyGraded : (GradingSaveResult?)null;
            }
        }

        /// <summary>The grade letter for a percentage: A from 80, B from 70, C from 60, D from 50, otherwise F.</summary>
        public static string GradeOf(double percent)
        {
            return percent >= 80 ? "A" : percent >= 70 ? "B" : percent >= 60 ? "C" : percent >= 50 ? "D" : "F";
        }

        /// <summary>
        /// Confirms the grade of a submission: scores the multiple-choice answers automatically, takes the marks and comments of the
        /// fill-in-the-blank and coding answers from the form (tpm_ / tpc_ fields, validated like SaveProgress; a question with no field
        /// keeps its saved marks, or 0), then in one transaction writes every answer's marks, the Result row (total, grade letter, percentage as
        /// Average, and the comments as feedback) and marks the GradingProgress row 'completed'. For an exam that the learner passed
        /// (total * 100 >= PassMark * max) it also adds a Certificate for the course, issued in the teacher's name, unless the learner already has
        /// one. Refused changes nothing. Same ownership and "no Result yet" rules as SaveProgress. On Saved, outcome says what was confirmed.
        /// </summary>
        public static GradingSaveResult ConfirmGrade(int courseId, int attemptId, System.Collections.Specialized.NameValueCollection form,
            out GradeOutcome outcome)
        {
            outcome = new GradeOutcome { Grade = "" };
            int total = 0, max = 0;
            string grade = "";
            int teacherId = TeacherDb.GetTeacherId();
            using (SqlConnection con = TeacherDb.GetConnection())
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    GradingSaveResult? refused = CheckGradable(con, tx, courseId, attemptId, teacherId);
                    if (refused != null) return refused.Value;

                    // every question of the attempt's own exam / quiz / assessment, with whether the chosen option was right and any saved marks
                    List<int> ids = new List<int>();
                    List<string> types = new List<string>();
                    List<int> marksOf = new List<int>();
                    List<bool> mcqRight = new List<bool>();
                    List<int> savedMarks = new List<int>();
                    List<string> savedComments = new List<string>();
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT q.QuestionId, q.QuestionType, q.QuestionScore, " +
                        "CASE WHEN q.QuestionType = 'MCQ' AND EXISTS (SELECT 1 FROM MCQ_Option o WHERE o.QuestionId = q.QuestionId AND o.IsCorrect = 1 " +
                        "AND CAST(o.MCQ_OptionId AS NVARCHAR(20)) = s.AnswerContent) THEN 1 ELSE 0 END, " +
                        "ISNULL(s.ObtainedScore, 0), ISNULL(s.TeacherComment, '') " +
                        "FROM Question q INNER JOIN Attempt a ON (q.ExamId = a.ExamId OR q.QuizId = a.QuizId OR q.AssessmentId = a.AssessmentId) " +
                        "LEFT JOIN AttemptAnswer s ON s.AttemptId = a.AttemptId AND s.QuestionId = q.QuestionId " +
                        "WHERE a.AttemptId = @AttemptId ORDER BY q.QuestionOrder, q.QuestionId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@AttemptId", attemptId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                ids.Add(reader.GetInt32(0));
                                types.Add(reader.GetString(1));
                                marksOf.Add((int)Math.Round(reader.GetDouble(2)));
                                mcqRight.Add(reader.GetInt32(3) == 1);
                                savedMarks.Add((int)Math.Round(reader.GetDouble(4)));
                                savedComments.Add(reader.GetString(5));
                            }
                        }
                    }

                    // work out every mark first, so that one bad value changes nothing
                    int count = ids.Count;
                    int[] given = new int[count];
                    string[] comments = new string[count];
                    string[] verdict = new string[count];
                    List<string> feedback = new List<string>();
                    for (int i = 0; i < count; i++)
                    {
                        max += marksOf[i];
                        if (types[i] == "MCQ")
                        {
                            given[i] = mcqRight[i] ? marksOf[i] : 0;
                            comments[i] = savedComments[i];
                            verdict[i] = mcqRight[i] ? "correct" : "incorrect";
                        }
                        else
                        {
                            string markField = form["tpm_" + attemptId + "_" + ids[i]];
                            int mark = savedMarks[i];
                            if (markField != null && (!int.TryParse(markField, NumberStyles.None, CultureInfo.InvariantCulture, out mark) || mark < 0 || mark > marksOf[i]))
                            {
                                return GradingSaveResult.InvalidMarks;
                            }
                            if (mark > marksOf[i]) mark = marksOf[i];
                            string commentField = form["tpc_" + attemptId + "_" + ids[i]];
                            string comment = (commentField ?? savedComments[i]).Trim();
                            if (comment.Length > MaxCommentLength) return GradingSaveResult.CommentTooLong;
                            given[i] = mark;
                            comments[i] = comment;
                            verdict[i] = mark == marksOf[i] ? "correct" : mark == 0 ? "incorrect" : "partial";
                            if (comment.Length > 0) feedback.Add("Q" + (i + 1) + ": " + comment);
                        }
                        total += given[i];
                    }

                    double percent = max > 0 ? Math.Round(total * 100.0 / max, 1) : 0;
                    grade = GradeOf(percent);

                    for (int i = 0; i < count; i++)
                    {
                        using (SqlCommand cmd = new SqlCommand(
                            "UPDATE AttemptAnswer SET ObtainedScore = @Marks, IsCorrect = @Verdict, TeacherComment = @Comment WHERE AttemptId = @AttemptId AND QuestionId = @QuestionId; " +
                            "IF @@ROWCOUNT = 0 INSERT INTO AttemptAnswer (AttemptId, QuestionId, AnswerContent, IsCorrect, ObtainedScore, TeacherComment) " +
                            "VALUES (@AttemptId, @QuestionId, '', @Verdict, @Marks, @Comment)", con, tx))
                        {
                            cmd.Parameters.AddWithValue("@AttemptId", attemptId);
                            cmd.Parameters.AddWithValue("@QuestionId", ids[i]);
                            cmd.Parameters.AddWithValue("@Marks", (double)given[i]);
                            cmd.Parameters.AddWithValue("@Verdict", verdict[i]);
                            cmd.Parameters.AddWithValue("@Comment", comments[i]);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        "INSERT INTO Result (TotalScore, Grade, Average, ResultFeedback, AttemptId) VALUES (@Total, @Grade, @Average, @Feedback, @AttemptId)", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@Total", (double)total);
                        cmd.Parameters.AddWithValue("@Grade", grade);
                        cmd.Parameters.AddWithValue("@Average", percent);
                        cmd.Parameters.AddWithValue("@Feedback", string.Join("\n", feedback));
                        cmd.Parameters.AddWithValue("@AttemptId", attemptId);
                        cmd.ExecuteNonQuery();
                    }

                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE GradingProgress SET ProgressStatus = 'completed', TeacherId = @TeacherId WHERE AttemptId = @AttemptId; " +
                        "IF @@ROWCOUNT = 0 INSERT INTO GradingProgress (ProgressStatus, ProgressNotes, TeacherId, TA_Id, AttemptId) " +
                        "VALUES ('completed', '', @TeacherId, NULL, @AttemptId)", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@AttemptId", attemptId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        cmd.ExecuteNonQuery();
                    }

                    // a passed exam earns a certificate for the course: one per learner and course, issued in the teacher's name
                    int passMark = 0, learnerId = 0, examCourseId = 0;
                    string issuer = "";
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT e.PassMark, a.LearnerId, e.CourseId, t.Name FROM Attempt a INNER JOIN Exam e ON e.ExamId = a.ExamId " +
                        "INNER JOIN Teacher t ON t.TeacherId = @TeacherId WHERE a.AttemptId = @AttemptId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@AttemptId", attemptId);
                        cmd.Parameters.AddWithValue("@TeacherId", teacherId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                outcome.IsExam = true;
                                passMark = reader.GetInt32(0);
                                learnerId = reader.GetInt32(1);
                                examCourseId = reader.GetInt32(2);
                                issuer = reader.GetString(3);
                            }
                        }
                    }
                    if (outcome.IsExam)
                    {
                        outcome.PassMark = passMark;
                        outcome.Passed = max > 0 && total * 100 >= passMark * max;
                        if (outcome.Passed)
                        {
                            using (SqlCommand cmd = new SqlCommand(
                                "IF NOT EXISTS (SELECT 1 FROM Certificate WITH (UPDLOCK, HOLDLOCK) WHERE LearnerId = @LearnerId AND CourseId = @CourseId) " +
                                "INSERT INTO Certificate (Issuer, IssueDate, LearnerId, CourseId) VALUES (@Issuer, GETDATE(), @LearnerId, @CourseId)", con, tx))
                            {
                                cmd.Parameters.AddWithValue("@Issuer", issuer);
                                cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                                cmd.Parameters.AddWithValue("@CourseId", examCourseId);
                                outcome.CertificateIssued = cmd.ExecuteNonQuery() > 0;
                            }
                        }
                    }

                    outcome.Total = total;
                    outcome.Max = max;
                    outcome.Grade = grade;
                    tx.Commit();
                    return GradingSaveResult.Saved;
                }
            }
        }

        /// <summary>"Tang Chee Kin" -> "TK" (first letters of the first and last word).</summary>
        private static string InitialsOf(string name)
        {
            string[] words = (name ?? "").Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (words.Length == 0) return "?";
            string initials = words[0].Substring(0, 1) + (words.Length > 1 ? words[words.Length - 1].Substring(0, 1) : "");
            return initials.ToUpperInvariant();
        }
    }
}
