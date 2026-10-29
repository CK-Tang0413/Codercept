using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class MyProgress : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["Codercept_db"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserType"] == null || Session["UserType"].ToString() != "Learner")
            {
                Response.Redirect("signIn.aspx");
                return;
            }

            if (!IsPostBack)
            {
                int learnerId = Convert.ToInt32(Session["UserId"]);
                LoadProgressData(learnerId);
            }
        }

        private void LoadProgressData(int learnerId)
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                // Updated query: renamed the average columns to "Raw" so we can format them later
                string query = @"
                    SELECT 
                        c.CourseId,
                        c.CourseTitle as CourseName,
                        ISNULL((SELECT TOP 1 s.SubjectName FROM CourseSubject cs JOIN Subject s ON cs.SubjectId = s.SubjectId WHERE cs.CourseId = c.CourseId AND s.SubjectType = 'Language'), 'General') as Language,
                        lp.ChapNum,
                        (SELECT COUNT(*) FROM Chapter WHERE CourseId = c.CourseId) as TotalChapters,
                        
                        -- Quiz Average (MCQ and FillBlank) renamed to QuizAvgRaw
                        ISNULL((SELECT AVG(aa.ObtainedScore / q.QuestionScore * 100)
                         FROM AttemptAnswer aa
                         JOIN Question q ON aa.QuestionId = q.QuestionId
                         JOIN Attempt a ON aa.AttemptId = a.AttemptId
                         WHERE a.LearnerId = lp.LearnerId 
                           AND q.QuestionType IN ('MCQ', 'FillBlank')
                           AND a.QuizId IN (SELECT QuizId FROM Quiz WHERE ChapterId IN (SELECT ChapterId FROM Chapter WHERE CourseId = c.CourseId))
                        ), -1) as QuizAvgRaw,

                        -- Coding Average renamed to CodeAvgRaw
                        ISNULL((SELECT AVG(aa.ObtainedScore / q.QuestionScore * 100)
                         FROM AttemptAnswer aa
                         JOIN Question q ON aa.QuestionId = q.QuestionId
                         JOIN Attempt a ON aa.AttemptId = a.AttemptId
                         WHERE a.LearnerId = lp.LearnerId 
                           AND q.QuestionType = 'Coding'
                           AND a.AssessmentId IN (SELECT AssessmentId FROM Assessment WHERE ChapterId IN (SELECT ChapterId FROM Chapter WHERE CourseId = c.CourseId))
                        ), -1) as CodeAvgRaw,

                        -- Final Exam Grade
                        ISNULL((SELECT TOP 1 r.Grade
                         FROM Result r
                         JOIN Attempt a ON r.AttemptId = a.AttemptId
                         WHERE a.LearnerId = lp.LearnerId 
                           AND a.ExamId = (SELECT ExamId FROM Exam WHERE CourseId = c.CourseId)
                         ORDER BY a.AttemptDate DESC
                        ), '-') as FinalGrade

                    FROM LearnerProgress lp
                    JOIN Course c ON lp.CourseId = c.CourseId
                    WHERE lp.LearnerId = @LearnerId";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    // Create brand-new STRING columns so they can safely accept the "%" sign
                    dt.Columns.Add("QuizAvg", typeof(string));
                    dt.Columns.Add("CodeAvg", typeof(string));

                    // Add other UI Helper Columns
                    dt.Columns.Add("LangClass", typeof(string));
                    dt.Columns.Add("Progress", typeof(int));
                    dt.Columns.Add("GradeClass", typeof(string));
                    dt.Columns.Add("Grade", typeof(string));

                    // Variables for Overview Stats
                    int activeCount = 0;
                    int completedCount = 0;
                    double totalQuizScores = 0;
                    int quizCount = 0;
                    double totalCodeScores = 0;
                    int codeCount = 0;

                    foreach (DataRow row in dt.Rows)
                    {
                        // 1. Language CSS
                        string lang = row["Language"].ToString().ToLower();
                        if (lang.Contains("c++") || lang.Contains("cpp")) row["LangClass"] = "lang-cpp";
                        else if (lang == "c") row["LangClass"] = "lang-c";
                        else row["LangClass"] = "lang-" + lang.Replace(" ", "");

                        // 2. Progress Calculation
                        int currentChapter = Convert.ToInt32(row["ChapNum"]);
                        int totalChapters = Convert.ToInt32(row["TotalChapters"]);
                        int chaptersCompleted = currentChapter - 1;
                        if (currentChapter > totalChapters) chaptersCompleted = totalChapters;

                        int progress = totalChapters > 0 ? (chaptersCompleted * 100) / totalChapters : 0;
                        row["Progress"] = progress;

                        if (progress == 100) completedCount++;
                        else if (progress > 0) activeCount++;

                        // 3. Format Averages using the Raw number, injecting into the new string column
                        double quizScore = Convert.ToDouble(row["QuizAvgRaw"]);
                        if (quizScore >= 0)
                        {
                            row["QuizAvg"] = $"{quizScore:F0}%";
                            totalQuizScores += quizScore;
                            quizCount++;
                        }
                        else row["QuizAvg"] = "–";

                        double codeScore = Convert.ToDouble(row["CodeAvgRaw"]);
                        if (codeScore >= 0)
                        {
                            row["CodeAvg"] = $"{codeScore:F0}%";
                            totalCodeScores += codeScore;
                            codeCount++;
                        }
                        else row["CodeAvg"] = "–";

                        // 4. Grade Badge CSS
                        string grade = row["FinalGrade"].ToString();
                        row["Grade"] = grade;
                        if (grade == "A") row["GradeClass"] = "grade-a";
                        else if (grade == "B") row["GradeClass"] = "grade-b";
                        else if (grade == "C") row["GradeClass"] = "grade-c";
                        else if (grade == "D") row["GradeClass"] = "grade-d";
                        else if (grade == "F") row["GradeClass"] = "grade-f";
                        else row["GradeClass"] = "";
                    }

                    // Bind Repeater (the frontend is looking for the new string columns we just created)
                    rptGrades.DataSource = dt;
                    rptGrades.DataBind();

                    // Update Overview Stats
                    litActiveCourses.Text = activeCount.ToString();
                    litCompletedCourses.Text = completedCount.ToString();
                    litQuizAvg.Text = quizCount > 0 ? $"{(totalQuizScores / quizCount):F0}%" : "0%";
                    litCodeAvg.Text = codeCount > 0 ? $"{(totalCodeScores / codeCount):F0}%" : "0%";
                }
            }
        }
    }
}