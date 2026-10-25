using System;
using System.Collections.Generic;
using System.Linq;

namespace Codercept
{
    public partial class TeacherGradeAssessments : System.Web.UI.Page
    {
        protected TeacherCourse Course;
        protected int Pending;
        protected List<TeacherAssessment> Assessments;

        /// <summary>The submissions of every exam, quiz and assessment of the course (each knows which one by TestKey).</summary>
        protected List<TeacherSubmission> Submissions;

        /// <summary>The marking sheet (questions, the learner's answers, marks given so far) of each submission, by AttemptId.</summary>
        protected Dictionary<int, List<TeacherMarkingQuestion>> Sheets;

        /// <summary>The kinds a teacher can grade, in the order they are listed.</summary>
        protected static readonly string[] Types = { "Exam", "Quiz", "Assessment" };

        protected static string TypeClass(string type)
        {
            return type == "Exam" ? "is-exam" : type == "Quiz" ? "is-quiz" : "is-assessment";
        }

        protected static string TypeIcon(string type)
        {
            return type == "Exam" ? "exams" : type == "Quiz" ? "question" : "grade";
        }

        /// <summary>
        /// The chosen exam / quiz / assessment; when nothing valid was chosen, the first one with submissions waiting (otherwise the first one).
        /// Null when the course has none.
        /// </summary>
        protected TeacherAssessment SelectedAssessment
        {
            get
            {
                return Assessments.FirstOrDefault(a => a.Key == hfTeacherGradeAssessment.Value)
                    ?? Assessments.FirstOrDefault(a => a.Pending > 0) ?? Assessments.FirstOrDefault();
            }
        }

        /// <summary>
        /// The chosen submission: one of the chosen exam / quiz / assessment's own (an id of any other attempt is ignored, so a forged
        /// id cannot open another course's or teacher's submission); null when nobody has submitted it yet.
        /// </summary>
        protected TeacherSubmission SelectedSubmission
        {
            get
            {
                TeacherAssessment assessment = SelectedAssessment;
                if (assessment == null) return null;
                List<TeacherSubmission> mine = Submissions.Where(s => s.TestKey == assessment.Key).ToList();
                int id;
                int.TryParse(hfTeacherGradeLearner.Value, out id);
                return mine.FirstOrDefault(s => s.Id == id) ?? mine.FirstOrDefault();
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // No ?course= means the first course; an id that is not this teacher's course goes back to the grading list
            Course = TeacherCourseData.Pick(TeacherCourseData.GetCourses(), Request.QueryString["course"]);
            if (Course == null) Response.Redirect("~/TeacherGrading.aspx");
            TeacherCourseData.GetPendingCounts().TryGetValue(Course.Id, out Pending);

            Assessments = TeacherGradingData.GetGradables(Course.Id);
            Submissions = TeacherGradingData.GetSubmissions(Course.Id);
            Sheets = TeacherGradingData.GetMarkingSheets(Course.Id, Submissions);
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (Assessments.Count == 0) return; // nothing to grade: the page shows a message instead

            // The learner name and total in the confirm dialog are filled in by TeacherPortal.js
            TeacherSubmission chosen = SelectedSubmission;
            mdlTeacherConfirmGrade.BodyHtml = "You are about to confirm a total of <strong data-tp-confirm-total>0 / " + SelectedAssessment.TotalMarks + "</strong> for "
                + "<strong data-tp-confirm-learner>" + (chosen == null ? "" : Server.HtmlEncode(chosen.Name)) + "</strong>. "
                + "The learner will be able to see the grade and your feedback.";
            if (!IsPostBack)
            {
                hfTeacherGradeAssessment.Value = SelectedAssessment.Key;

                // ?submission= (the dashboard's "Mark answers") opens that submission, but only if it is one of this course's own
                int linked;
                TeacherSubmission target = int.TryParse(Request.QueryString["submission"], out linked) ? Submissions.FirstOrDefault(s => s.Id == linked) : null;
                if (target != null)
                {
                    hfTeacherGradeAssessment.Value = target.TestKey;
                    hfTeacherGradeLearner.Value = target.Id.ToString();
                }
            }
        }

        /// <summary>"1 question", "3 questions".</summary>
        protected static string Questions(int count)
        {
            return count + (count == 1 ? " question" : " questions");
        }

        /// <summary>"1 mark", "5 marks".</summary>
        protected static string Marks(int count)
        {
            return count + (count == 1 ? " MARK" : " MARKS");
        }

        protected string StatusClass(string status)
        {
            if (status == "Graded") return "is-graded";
            if (status == "In progress") return "is-progress";
            return "is-ungraded";
        }

        /// <summary>
        /// The submission named by the learner box, but only when it is one of the chosen exam / quiz / assessment's own. Unlike
        /// SelectedSubmission it never falls back to the first one, so a forged or missing id can never save marks onto another learner.
        /// </summary>
        private TeacherSubmission ExactSubmission()
        {
            TeacherAssessment assessment = SelectedAssessment;
            int id;
            if (assessment == null || !int.TryParse(hfTeacherGradeLearner.Value, out id)) return null;
            return Submissions.FirstOrDefault(s => s.Id == id && s.TestKey == assessment.Key);
        }

        protected void btnTeacherSaveGrading_Click(object sender, EventArgs e)
        {
            TeacherSubmission submission = Assessments.Count == 0 ? null : ExactSubmission();
            if (submission == null)
            {
                Master.ShowToast("Choose a submission first, so nothing was saved.");
                return;
            }

            GradingSaveResult result = TeacherGradingData.SaveProgress(Course.Id, submission.Id, Request.Unvalidated.Form);
            switch (result)
            {
                case GradingSaveResult.Saved:
                    // show the new status ("In progress") and the saved marks and comments
                    Submissions = TeacherGradingData.GetSubmissions(Course.Id);
                    Sheets = TeacherGradingData.GetMarkingSheets(Course.Id, Submissions);
                    Master.ShowToast("Grading progress saved.");
                    break;
                case GradingSaveResult.AlreadyGraded:
                    Master.ShowToast("This submission has already been graded, so nothing was changed.");
                    break;
                case GradingSaveResult.InvalidMarks:
                    Master.ShowToast("Marks must be whole numbers from 0 up to each question's marks, so nothing was saved.");
                    break;
                case GradingSaveResult.CommentTooLong:
                    Master.ShowToast("A comment can be at most " + TeacherGradingData.MaxCommentLength + " characters, so nothing was saved.");
                    break;
                default:
                    Master.ShowToast("That submission could not be found, so nothing was saved.");
                    break;
            }
        }

        protected void mdlTeacherConfirmGrade_Confirmed(object sender, EventArgs e)
        {
            TeacherSubmission submission = Assessments.Count == 0 ? null : ExactSubmission();
            if (submission == null)
            {
                Master.ShowToast("Choose a submission first, so nothing was confirmed.");
                return;
            }

            GradeOutcome outcome;
            GradingSaveResult result = TeacherGradingData.ConfirmGrade(Course.Id, submission.Id, Request.Unvalidated.Form, out outcome);
            switch (result)
            {
                case GradingSaveResult.Saved:
                    // the submission is now Graded, so the lists and the pending counts are read again
                    TeacherCourseData.GetPendingCounts().TryGetValue(Course.Id, out Pending);
                    Assessments = TeacherGradingData.GetGradables(Course.Id);
                    Submissions = TeacherGradingData.GetSubmissions(Course.Id);
                    Sheets = TeacherGradingData.GetMarkingSheets(Course.Id, Submissions);
                    string message = "Grade confirmed: " + outcome.Total + " / " + outcome.Max + " (grade " + outcome.Grade + ").";
                    if (outcome.IsExam)
                    {
                        if (!outcome.Passed) message += " The learner did not reach the pass mark of " + outcome.PassMark + "%, so no certificate was issued.";
                        else if (outcome.CertificateIssued) message += " The learner passed (pass mark " + outcome.PassMark + "%) and a certificate was issued.";
                        else message += " The learner passed (pass mark " + outcome.PassMark + "%) and already has a certificate for this course.";
                    }
                    Master.ShowToast(message);
                    break;
                case GradingSaveResult.AlreadyGraded:
                    Master.ShowToast("This submission has already been graded, so nothing was changed.");
                    break;
                case GradingSaveResult.InvalidMarks:
                    Master.ShowToast("Marks must be whole numbers from 0 up to each question's marks, so nothing was confirmed.");
                    break;
                case GradingSaveResult.CommentTooLong:
                    Master.ShowToast("A comment can be at most " + TeacherGradingData.MaxCommentLength + " characters, so nothing was confirmed.");
                    break;
                default:
                    Master.ShowToast("That submission could not be found, so nothing was confirmed.");
                    break;
            }
        }
    }
}
