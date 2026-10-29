using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;

namespace Codercept
{
    public class TACourseGradingStats
    {
        public int ToMark { get; set; }
        public int Draft { get; set; }
        public int Reviewed { get; set; }
        public int Graded { get; set; }
    }

    public static class TAGradingData
    {
        private static readonly string[] Tones = { "indigo", "teal", "blue", "amber", "rose" };
        public const int MaxCommentLength = 2000;

        public static List<TeacherCourse> GetCourses(int? taId = null)
        {
            var list = new List<TeacherCourse>();
            string sql = @"
                SELECT c.CourseId, c.CourseTitle, c.CourseDescription, c.DifficultyLevel, c.CourseDuration,
                       c.DateCreation, c.DateUpdate,
                       ISNULL((SELECT TOP 1 s.SubjectName FROM CourseSubject cs
                               INNER JOIN Subject s ON s.SubjectId = cs.SubjectId
                               WHERE cs.CourseId = c.CourseId AND s.SubjectType = 'Language'
                               ORDER BY s.SubjectId), 'Other') AS Language,
                       (SELECT COUNT(*) FROM LearnerProgress lp WHERE lp.CourseId = c.CourseId) AS LearnerCount,
                       t.Name AS TeacherName
                FROM Course c
                INNER JOIN Teacher t ON t.TeacherId = c.TeacherId";

            if (taId.HasValue && taId.Value > 0)
            {
                sql += @"
                WHERE EXISTS (
                    SELECT 1 FROM CourseSubject cs
                    INNER JOIN EducatorSubject es ON es.SubjectId = cs.SubjectId
                    WHERE cs.CourseId = c.CourseId AND es.TA_Id = @TA_Id
                )";
            }

            sql += " ORDER BY c.CourseTitle";

            using (SqlConnection con = new SqlConnection(TAHelpers.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                if (taId.HasValue && taId.Value > 0)
                {
                    cmd.Parameters.AddWithValue("@TA_Id", taId.Value);
                }

                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string language = reader.GetString(reader.GetOrdinal("Language"));
                        string duration = reader.GetString(reader.GetOrdinal("CourseDuration"));
                        int learners = reader.GetInt32(reader.GetOrdinal("LearnerCount"));
                        DateTime created = reader.GetDateTime(reader.GetOrdinal("DateCreation"));
                        int updatedOrd = reader.GetOrdinal("DateUpdate");
                        DateTime updated = reader.IsDBNull(updatedOrd) ? created : reader.GetDateTime(updatedOrd);

                        list.Add(new TeacherCourse
                        {
                            Id = reader.GetInt32(reader.GetOrdinal("CourseId")),
                            Title = reader.GetString(reader.GetOrdinal("CourseTitle")),
                            Description = reader.GetString(reader.GetOrdinal("CourseDescription")),
                            Difficulty = reader.GetString(reader.GetOrdinal("DifficultyLevel")),
                            Duration = HoursOf(duration),
                            Language = language,
                            Glyph = GlyphOf(language),
                            Theme = ThemeOf(language),
                            Date = created.ToString("d MMMM yyyy", CultureInfo.InvariantCulture),
                            Updated = updated.ToString("d MMMM yyyy", CultureInfo.InvariantCulture),
                            Learners = learners + (learners == 1 ? " learner" : " learners")
                        });
                    }
                }
            }
            return list;
        }

        public static Dictionary<int, TACourseGradingStats> GetGradingStats(int? taId = null)
        {
            var stats = new Dictionary<int, TACourseGradingStats>();
            string sql = @"
                SELECT c.CourseId,
                       SUM(CASE WHEN r.ResultId IS NULL AND gp.ProgressStatus = 'Reviewed' THEN 1 ELSE 0 END) AS ReviewedCount,
                       SUM(CASE WHEN r.ResultId IS NULL AND gp.ProgressStatus IN ('In Progress', 'in_progress', 'Draft') THEN 1 ELSE 0 END) AS DraftCount,
                       SUM(CASE WHEN r.ResultId IS NULL AND (gp.ProgressStatus IS NULL OR gp.ProgressStatus NOT IN ('Reviewed', 'In Progress', 'in_progress', 'Draft')) THEN 1 ELSE 0 END) AS ToMarkCount,
                       SUM(CASE WHEN r.ResultId IS NOT NULL THEN 1 ELSE 0 END) AS GradedCount
                FROM Attempt a
                LEFT JOIN Result r ON r.AttemptId = a.AttemptId
                LEFT JOIN GradingProgress gp ON gp.AttemptId = a.AttemptId
                LEFT JOIN Exam e ON e.ExamId = a.ExamId
                LEFT JOIN Quiz z ON z.QuizId = a.QuizId
                LEFT JOIN Chapter cz ON cz.ChapterId = z.ChapterId
                LEFT JOIN Assessment s ON s.AssessmentId = a.AssessmentId
                LEFT JOIN Chapter cs ON cs.ChapterId = s.ChapterId
                INNER JOIN Course c ON c.CourseId = COALESCE(e.CourseId, cz.CourseId, cs.CourseId)
                WHERE a.AttemptStatus = 'completed'";

            if (taId.HasValue && taId.Value > 0)
            {
                sql += @"
                  AND EXISTS (
                      SELECT 1 FROM CourseSubject csSub
                      INNER JOIN EducatorSubject es ON es.SubjectId = csSub.SubjectId
                      WHERE csSub.CourseId = c.CourseId AND es.TA_Id = @TA_Id
                  )";
            }

            sql += " GROUP BY c.CourseId";

            using (SqlConnection con = new SqlConnection(TAHelpers.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                if (taId.HasValue && taId.Value > 0)
                {
                    cmd.Parameters.AddWithValue("@TA_Id", taId.Value);
                }

                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        stats[reader.GetInt32(0)] = new TACourseGradingStats
                        {
                            Reviewed = reader.GetInt32(1),
                            Draft = reader.GetInt32(2),
                            ToMark = reader.GetInt32(3),
                            Graded = reader.GetInt32(4)
                        };
                    }
                }
            }
            return stats;
        }

        public static Dictionary<int, int> GetPendingCounts(int? taId = null)
        {
            var dict = new Dictionary<int, int>();
            var allStats = GetGradingStats(taId);
            foreach (var kvp in allStats)
            {
                dict[kvp.Key] = kvp.Value.ToMark + kvp.Value.Draft;
            }
            return dict;
        }

        public static List<TeacherAssessment> GetGradables(int courseId)
        {
            var list = new List<TeacherAssessment>();

            const string pendingOf = "(SELECT COUNT(*) FROM Attempt a WHERE a.{0} = t.{0} AND a.AttemptStatus = 'completed' " +
                                     "AND NOT EXISTS (SELECT 1 FROM Result r WHERE r.AttemptId = a.AttemptId) " +
                                     "AND NOT EXISTS (SELECT 1 FROM GradingProgress gp WHERE gp.AttemptId = a.AttemptId AND gp.ProgressStatus = 'Reviewed'))";
            const string questionsOf = "(SELECT COUNT(*) FROM Question q WHERE q.{0} = t.{0})";
            const string marksOf = "ISNULL((SELECT SUM(q.QuestionScore) FROM Question q WHERE q.{0} = t.{0}), 0)";

            string sql =
                "WITH Pos AS (SELECT ChapterId, ROW_NUMBER() OVER (ORDER BY ChapterNum, ChapterId) AS N FROM Chapter WHERE CourseId = @CourseId) " +
                "SELECT 'Exam' AS Type, t.ExamId AS Id, t.ExamTitle AS Title, 0 AS ChapterPos, " +
                    string.Format(questionsOf, "ExamId") + " AS Questions, " + string.Format(marksOf, "ExamId") + " AS Marks, " + string.Format(pendingOf, "ExamId") + " AS Pending " +
                "FROM Exam t WHERE t.CourseId = @CourseId " +
                "UNION ALL " +
                "SELECT 'Quiz', t.QuizId, t.QuizTitle, CAST(p.N AS INT), " +
                    string.Format(questionsOf, "QuizId") + ", " + string.Format(marksOf, "QuizId") + ", " + string.Format(pendingOf, "QuizId") + " " +
                "FROM Quiz t INNER JOIN Pos p ON p.ChapterId = t.ChapterId INNER JOIN Chapter ch ON ch.ChapterId = t.ChapterId " +
                "WHERE ch.CourseId = @CourseId " +
                "UNION ALL " +
                "SELECT 'Assessment', t.AssessmentId, t.AssessmentTitle, CAST(p.N AS INT), " +
                    string.Format(questionsOf, "AssessmentId") + ", " + string.Format(marksOf, "AssessmentId") + ", " + string.Format(pendingOf, "AssessmentId") + " " +
                "FROM Assessment t INNER JOIN Pos p ON p.ChapterId = t.ChapterId INNER JOIN Chapter ch ON ch.ChapterId = t.ChapterId " +
                "WHERE ch.CourseId = @CourseId " +
                "ORDER BY ChapterPos, Id";

            using (SqlConnection con = new SqlConnection(TAHelpers.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@CourseId", courseId);
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

        public static List<TeacherSubmission> GetSubmissions(int courseId)
        {
            var list = new List<TeacherSubmission>();

            const string status =
                "CASE WHEN EXISTS (SELECT 1 FROM Result r WHERE r.AttemptId = a.AttemptId) THEN 'Graded' " +
                "WHEN EXISTS (SELECT 1 FROM GradingProgress g WHERE g.AttemptId = a.AttemptId AND g.ProgressStatus = 'Reviewed') THEN 'Reviewed' " +
                "WHEN EXISTS (SELECT 1 FROM GradingProgress g WHERE g.AttemptId = a.AttemptId) THEN 'In progress' ELSE 'Not graded' END";

            string sql =
                "SELECT a.AttemptId, a.LearnerId, l.Name, l.Email, a.AttemptDate, " + status + ", 'exam', a.ExamId " +
                "FROM Attempt a INNER JOIN Learner l ON l.LearnerId = a.LearnerId INNER JOIN Exam t ON t.ExamId = a.ExamId " +
                "WHERE t.CourseId = @CourseId AND a.AttemptStatus = 'completed' " +
                "UNION ALL " +
                "SELECT a.AttemptId, a.LearnerId, l.Name, l.Email, a.AttemptDate, " + status + ", 'quiz', a.QuizId " +
                "FROM Attempt a INNER JOIN Learner l ON l.LearnerId = a.LearnerId INNER JOIN Quiz t ON t.QuizId = a.QuizId " +
                "INNER JOIN Chapter ch ON ch.ChapterId = t.ChapterId " +
                "WHERE ch.CourseId = @CourseId AND a.AttemptStatus = 'completed' " +
                "UNION ALL " +
                "SELECT a.AttemptId, a.LearnerId, l.Name, l.Email, a.AttemptDate, " + status + ", 'assessment', a.AssessmentId " +
                "FROM Attempt a INNER JOIN Learner l ON l.LearnerId = a.LearnerId INNER JOIN Assessment t ON t.AssessmentId = a.AssessmentId " +
                "INNER JOIN Chapter ch ON ch.ChapterId = t.ChapterId " +
                "WHERE ch.CourseId = @CourseId AND a.AttemptStatus = 'completed'";

            List<DateTime> dates = new List<DateTime>();
            using (SqlConnection con = new SqlConnection(TAHelpers.ConnectionString))
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@CourseId", courseId);
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

            return list.Select((s, i) => new { s, when = dates[i] })
                .OrderBy(x => x.s.Status == "Not graded" ? 0 : x.s.Status == "In progress" ? 1 : x.s.Status == "Reviewed" ? 2 : 3)
                .ThenByDescending(x => x.when)
                .Select(x => x.s)
                .ToList();
        }

        private const string QuestionsOfCourse =
            "WITH CQ AS (" +
            "SELECT q.QuestionId, 'exam' AS K, q.ExamId AS TestId FROM Question q " +
            "INNER JOIN Exam e ON e.ExamId = q.ExamId WHERE e.CourseId = @CourseId " +
            "UNION ALL " +
            "SELECT q.QuestionId, 'quiz', q.QuizId FROM Question q " +
            "INNER JOIN Quiz z ON z.QuizId = q.QuizId INNER JOIN Chapter ch ON ch.ChapterId = z.ChapterId " +
            "WHERE ch.CourseId = @CourseId " +
            "UNION ALL " +
            "SELECT q.QuestionId, 'assessment', q.AssessmentId FROM Question q " +
            "INNER JOIN Assessment s ON s.AssessmentId = q.AssessmentId INNER JOIN Chapter ch ON ch.ChapterId = s.ChapterId " +
            "WHERE ch.CourseId = @CourseId) ";

        public static Dictionary<int, List<TeacherMarkingQuestion>> GetMarkingSheets(int courseId, List<TeacherSubmission> submissions)
        {
            var byTest = new Dictionary<string, List<TeacherMarkingQuestion>>();
            var optionsOf = new Dictionary<int, List<TeacherMarkingOption>>();
            var answersOf = new Dictionary<int, Dictionary<int, TeacherMarkingQuestion>>();

            using (SqlConnection con = new SqlConnection(TAHelpers.ConnectionString))
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand(QuestionsOfCourse +
                    "SELECT q.QuestionId, CQ.K, CQ.TestId, q.QuestionContent, q.QuestionType, q.QuestionScore, q.AcceptedAnswers, q.ModelAnswer, q.MarkingGuide " +
                    "FROM CQ INNER JOIN Question q ON q.QuestionId = CQ.QuestionId ORDER BY CQ.K, CQ.TestId, q.QuestionOrder, q.QuestionId", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        int lastTest = -1;
                        string lastKind = "";
                        int num = 0;
                        while (reader.Read())
                        {
                            string kind = reader.GetString(1);
                            int testId = reader.GetInt32(2);
                            if (kind != lastKind || testId != lastTest)
                            {
                                lastKind = kind;
                                lastTest = testId;
                                num = 0;
                            }
                            string key = kind + ":" + testId;
                            List<TeacherMarkingQuestion> list;
                            if (!byTest.TryGetValue(key, out list)) byTest[key] = list = new List<TeacherMarkingQuestion>();

                            list.Add(new TeacherMarkingQuestion
                            {
                                Id = reader.GetInt32(0),
                                Number = ++num,
                                Text = reader.GetString(3),
                                Type = reader.GetString(4),
                                Marks = (int)Math.Round(reader.GetDouble(5)),
                                AcceptedAnswers = reader.IsDBNull(6) ? "" : reader.GetString(6),
                                ModelAnswer = reader.IsDBNull(7) ? "" : reader.GetString(7),
                                MarkingGuide = reader.IsDBNull(8) ? "" : reader.GetString(8),
                                Options = new List<TeacherMarkingOption>()
                            });
                        }
                    }
                }

                using (SqlCommand cmd = new SqlCommand(QuestionsOfCourse +
                    "SELECT o.QuestionId, o.MCQ_OptionId, o.OptionContent, o.IsCorrect " +
                    "FROM CQ INNER JOIN MCQ_Option o ON o.QuestionId = CQ.QuestionId ORDER BY o.QuestionId, o.OptionOrder, o.MCQ_OptionId", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int questionId = reader.GetInt32(0);
                            List<TeacherMarkingOption> list;
                            if (!optionsOf.TryGetValue(questionId, out list)) { list = new List<TeacherMarkingOption>(); optionsOf[questionId] = list; }
                            list.Add(new TeacherMarkingOption
                            {
                                Id = reader.GetInt32(1),
                                Text = reader.GetString(2),
                                Correct = reader.GetBoolean(3)
                            });
                        }
                    }
                }

                using (SqlCommand cmd = new SqlCommand(QuestionsOfCourse +
                    "SELECT aa.AttemptId, aa.QuestionId, aa.AnswerContent, aa.ObtainedScore, aa.TeacherComment FROM AttemptAnswer aa " +
                    "INNER JOIN Attempt a ON a.AttemptId = aa.AttemptId " +
                    "INNER JOIN CQ ON CQ.QuestionId = aa.QuestionId AND ((CQ.K = 'exam' AND a.ExamId = CQ.TestId) " +
                    "OR (CQ.K = 'quiz' AND a.QuizId = CQ.TestId) OR (CQ.K = 'assessment' AND a.AssessmentId = CQ.TestId))", con))
                {
                    cmd.Parameters.AddWithValue("@CourseId", courseId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            int aid = reader.GetInt32(0);
                            Dictionary<int, TeacherMarkingQuestion> perAttempt;
                            if (!answersOf.TryGetValue(aid, out perAttempt)) { perAttempt = new Dictionary<int, TeacherMarkingQuestion>(); answersOf[aid] = perAttempt; }
                            perAttempt[reader.GetInt32(1)] = new TeacherMarkingQuestion
                            {
                                Answered = true,
                                Answer = reader.IsDBNull(2) ? "" : reader.GetString(2),
                                Given = (int)Math.Round(reader.GetDouble(3)),
                                Comment = reader.IsDBNull(4) ? "" : reader.GetString(4)
                            };
                        }
                    }
                }
            }

            var sheets = new Dictionary<int, List<TeacherMarkingQuestion>>();
            foreach (TeacherSubmission s in submissions)
            {
                List<TeacherMarkingQuestion> template;
                if (!byTest.TryGetValue(s.TestKey, out template)) template = new List<TeacherMarkingQuestion>();
                Dictionary<int, TeacherMarkingQuestion> learnerAnswers;
                answersOf.TryGetValue(s.Id, out learnerAnswers);

                var list = new List<TeacherMarkingQuestion>();
                foreach (TeacherMarkingQuestion t in template)
                {
                    TeacherMarkingQuestion answered = learnerAnswers != null && learnerAnswers.ContainsKey(t.Id) ? learnerAnswers[t.Id] : null;
                    List<TeacherMarkingOption> opts;
                    if (!optionsOf.TryGetValue(t.Id, out opts)) opts = new List<TeacherMarkingOption>();

                    string answer = answered != null ? answered.Answer : "";
                    var copiedOpts = opts.Select(o => new TeacherMarkingOption
                    {
                        Id = o.Id,
                        Text = o.Text,
                        Correct = o.Correct,
                        Chosen = string.Equals(o.Text, answer, StringComparison.OrdinalIgnoreCase) || o.Id.ToString() == answer
                    }).ToList();

                    list.Add(new TeacherMarkingQuestion
                    {
                        Id = t.Id,
                        Number = t.Number,
                        Type = t.Type,
                        Text = t.Text,
                        Marks = t.Marks,
                        AcceptedAnswers = t.AcceptedAnswers,
                        ModelAnswer = t.ModelAnswer,
                        MarkingGuide = t.MarkingGuide,
                        Options = copiedOpts,
                        Answered = answered != null,
                        Answer = answer,
                        Given = answered != null ? answered.Given : 0,
                        Comment = answered != null ? answered.Comment : ""
                    });
                }
                sheets[s.Id] = list;
            }

            return sheets;
        }

        public static GradingSaveResult SaveProgress(int courseId, int attemptId, int taId, System.Collections.Specialized.NameValueCollection form)
        {
            return ApplyMarks(courseId, attemptId, taId, form, "in_progress", "Draft saved by TA");
        }

        public static GradingSaveResult SubmitReview(int courseId, int attemptId, int taId, System.Collections.Specialized.NameValueCollection form, out GradeOutcome outcome)
        {
            outcome = new GradeOutcome();
            GradingSaveResult res = ApplyMarks(courseId, attemptId, taId, form, "Reviewed", "Provisional marks submitted by TA");
            if (res != GradingSaveResult.Saved) return res;

            // Calculate current total
            using (SqlConnection con = new SqlConnection(TAHelpers.ConnectionString))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT ISNULL(SUM(a.ObtainedScore), 0) AS TotalScore,
                           ISNULL(SUM(q.QuestionScore), 0) AS MaxScore
                    FROM Question q
                    INNER JOIN Attempt att ON (q.ExamId = att.ExamId OR q.QuizId = att.QuizId OR q.AssessmentId = att.AssessmentId)
                    LEFT JOIN AttemptAnswer a ON a.QuestionId = q.QuestionId AND a.AttemptId = att.AttemptId
                    WHERE att.AttemptId = @AttemptId", con))
                {
                    cmd.Parameters.AddWithValue("@AttemptId", attemptId);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            outcome.Total = (int)Math.Round(r.GetDouble(0));
                            outcome.Max = (int)Math.Round(r.GetDouble(1));
                        }
                    }
                }
            }
            return GradingSaveResult.Saved;
        }

        private static GradingSaveResult ApplyMarks(int courseId, int attemptId, int taId, System.Collections.Specialized.NameValueCollection form, string progressStatus, string notes)
        {
            using (SqlConnection con = new SqlConnection(TAHelpers.ConnectionString))
            {
                con.Open();
                using (SqlTransaction tx = con.BeginTransaction())
                {
                    // Check if already officially graded
                    using (SqlCommand cmd = new SqlCommand(
                        "SELECT CASE WHEN EXISTS (SELECT 1 FROM Result r WHERE r.AttemptId = a.AttemptId) THEN 1 ELSE 0 END " +
                        "FROM Attempt a WITH (UPDLOCK, HOLDLOCK) WHERE a.AttemptId = @AttemptId", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@AttemptId", attemptId);
                        object val = cmd.ExecuteScalar();
                        if (val == null) return GradingSaveResult.NotFound;
                        if ((int)val == 1) return GradingSaveResult.AlreadyGraded;
                    }

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

                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE GradingProgress SET ProgressStatus = @Status, ProgressNotes = @Notes, TA_Id = @TA_Id WHERE AttemptId = @AttemptId; " +
                        "IF @@ROWCOUNT = 0 INSERT INTO GradingProgress (ProgressStatus, ProgressNotes, TeacherId, TA_Id, AttemptId) " +
                        "VALUES (@Status, @Notes, NULL, @TA_Id, @AttemptId)", con, tx))
                    {
                        cmd.Parameters.AddWithValue("@AttemptId", attemptId);
                        cmd.Parameters.AddWithValue("@TA_Id", taId);
                        cmd.Parameters.AddWithValue("@Status", progressStatus);
                        cmd.Parameters.AddWithValue("@Notes", notes);
                        cmd.ExecuteNonQuery();
                    }

                    tx.Commit();
                    return GradingSaveResult.Saved;
                }
            }
        }

        private static int HoursOf(string duration)
        {
            string digits = new string((duration ?? "").TrimStart().TakeWhile(ch => char.IsDigit(ch) || ch == '.').ToArray());
            decimal hours;
            return decimal.TryParse(digits, NumberStyles.Number, CultureInfo.InvariantCulture, out hours) ? (int)Math.Round(hours) : 0;
        }

        private static string GlyphOf(string language)
        {
            switch (language)
            {
                case "Python": return "py";
                case "Java": return "Java";
                case "C++": return "C++";
                case "C": return "C";
                default: return "?";
            }
        }

        private static string ThemeOf(string language)
        {
            switch (language)
            {
                case "Python": return "python";
                case "Java": return "java";
                case "C++": return "cpp";
                case "C": return "c";
                default: return "other";
            }
        }

        private static string InitialsOf(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "L";
            string[] parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length == 1) return parts[0].Substring(0, Math.Min(2, parts[0].Length)).ToUpperInvariant();
            return (parts[0].Substring(0, 1) + parts[parts.Length - 1].Substring(0, 1)).ToUpperInvariant();
        }
    }
}
