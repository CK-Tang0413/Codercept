using System;
using System.Collections.Generic;
using System.Linq;

namespace Codercept
{
    public partial class TAGradeAssessments : System.Web.UI.Page
    {
        protected TeacherCourse Course;
        protected int Pending;
        protected List<TeacherAssessment> Assessments;
        protected List<TeacherSubmission> Submissions;
        protected Dictionary<int, List<TeacherMarkingQuestion>> Sheets;

        protected static readonly string[] Types = { "Exam", "Quiz", "Assessment" };

        protected static string TypeClass(string type)
        {
            return type == "Exam" ? "is-exam" : type == "Quiz" ? "is-quiz" : "is-assessment";
        }

        protected static string TypeIcon(string type)
        {
            return type == "Exam" ? "exams" : type == "Quiz" ? "question" : "grade";
        }

        protected TeacherAssessment SelectedAssessment
        {
            get
            {
                return Assessments.FirstOrDefault(a => a.Key == hfTeacherGradeAssessment.Value)
                    ?? Assessments.FirstOrDefault(a => a.Pending > 0) ?? Assessments.FirstOrDefault();
            }
        }

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

        private int TaId { get { return Convert.ToInt32(Session["UserId"]); } }

        protected void Page_Load(object sender, EventArgs e)
        {
            Course = TeacherCourseData.Pick(TAGradingData.GetCourses(TaId), Request.QueryString["course"]);
            if (Course == null) Response.Redirect("~/TAGrading.aspx");
            TAGradingData.GetPendingCounts(TaId).TryGetValue(Course.Id, out Pending);

            Assessments = TAGradingData.GetGradables(Course.Id);
            Submissions = TAGradingData.GetSubmissions(Course.Id);
            Sheets = TAGradingData.GetMarkingSheets(Course.Id, Submissions);
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (Assessments.Count == 0) return;

            TeacherSubmission chosen = SelectedSubmission;
            mdlTAConfirmGrade.BodyHtml = "You are about to submit provisional marks of <strong data-tp-confirm-total>0 / " + SelectedAssessment.TotalMarks + "</strong> for "
                + "<strong data-tp-confirm-learner>" + (chosen == null ? "" : Server.HtmlEncode(chosen.Name)) + "</strong>. "
                + "The supervising teacher will review and approve the final grade.";
            if (!IsPostBack)
            {
                hfTeacherGradeAssessment.Value = SelectedAssessment.Key;

                int linked;
                TeacherSubmission target = int.TryParse(Request.QueryString["submission"], out linked) ? Submissions.FirstOrDefault(s => s.Id == linked) : null;
                if (target != null)
                {
                    hfTeacherGradeAssessment.Value = target.TestKey;
                    hfTeacherGradeLearner.Value = target.Id.ToString();
                }
            }
        }

        protected static string Questions(int count)
        {
            return count + (count == 1 ? " question" : " questions");
        }

        protected static string Marks(int count)
        {
            return count + (count == 1 ? " MARK" : " MARKS");
        }

        protected string StatusClass(string status)
        {
            if (status == "Graded") return "is-graded";
            if (status == "Reviewed") return "is-graded";
            if (status == "In progress") return "is-progress";
            return "is-ungraded";
        }

        private TeacherSubmission ExactSubmission()
        {
            TeacherAssessment assessment = SelectedAssessment;
            int id;
            if (assessment == null || !int.TryParse(hfTeacherGradeLearner.Value, out id)) return null;
            return Submissions.FirstOrDefault(s => s.Id == id && s.TestKey == assessment.Key);
        }

        protected void btnTASaveGrading_Click(object sender, EventArgs e)
        {
            TeacherSubmission submission = Assessments.Count == 0 ? null : ExactSubmission();
            if (submission == null)
            {
                Master.ShowToast("Choose a submission first, so nothing was saved.");
                return;
            }

            GradingSaveResult result = TAGradingData.SaveProgress(Course.Id, submission.Id, TaId, Request.Unvalidated.Form);
            switch (result)
            {
                case GradingSaveResult.Saved:
                    Submissions = TAGradingData.GetSubmissions(Course.Id);
                    Sheets = TAGradingData.GetMarkingSheets(Course.Id, Submissions);
                    Master.ShowToast("Grading draft saved.");
                    break;
                case GradingSaveResult.AlreadyGraded:
                    Master.ShowToast("This submission has already been graded, so nothing was changed.");
                    break;
                case GradingSaveResult.InvalidMarks:
                    Master.ShowToast("Marks must be whole numbers from 0 up to each question's marks, so nothing was saved.");
                    break;
                case GradingSaveResult.CommentTooLong:
                    Master.ShowToast("A comment can be at most " + TAGradingData.MaxCommentLength + " characters, so nothing was saved.");
                    break;
                default:
                    Master.ShowToast("That submission could not be found, so nothing was saved.");
                    break;
            }
        }

        protected void mdlTAConfirmGrade_Confirmed(object sender, EventArgs e)
        {
            TeacherSubmission submission = Assessments.Count == 0 ? null : ExactSubmission();
            if (submission == null)
            {
                Master.ShowToast("Choose a submission first, so nothing was submitted.");
                return;
            }

            GradeOutcome outcome;
            GradingSaveResult result = TAGradingData.SubmitReview(Course.Id, submission.Id, TaId, Request.Unvalidated.Form, out outcome);
            switch (result)
            {
                case GradingSaveResult.Saved:
                    TAGradingData.GetPendingCounts().TryGetValue(Course.Id, out Pending);
                    Assessments = TAGradingData.GetGradables(Course.Id);
                    Submissions = TAGradingData.GetSubmissions(Course.Id);
                    Sheets = TAGradingData.GetMarkingSheets(Course.Id, Submissions);
                    Master.ShowToast("Provisional review submitted (" + outcome.Total + " / " + outcome.Max + "). Awaiting teacher approval.");
                    break;
                case GradingSaveResult.AlreadyGraded:
                    Master.ShowToast("This submission has already been graded, so nothing was changed.");
                    break;
                case GradingSaveResult.InvalidMarks:
                    Master.ShowToast("Marks must be whole numbers from 0 up to each question's marks, so nothing was submitted.");
                    break;
                case GradingSaveResult.CommentTooLong:
                    Master.ShowToast("A comment can be at most " + TAGradingData.MaxCommentLength + " characters, so nothing was submitted.");
                    break;
                default:
                    Master.ShowToast("That submission could not be found, so nothing was submitted.");
                    break;
            }
        }
    }
}
