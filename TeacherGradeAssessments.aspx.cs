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
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            if (Assessments.Count == 0) return; // nothing to grade: the page shows a message instead

            // The learner name and total in the confirm dialog are filled in by TeacherPortal.js
            TeacherSubmission chosen = SelectedSubmission;
            mdlTeacherConfirmGrade.BodyHtml = "You are about to confirm a total of <strong data-tp-confirm-total>0 / 100</strong> for "
                + "<strong data-tp-confirm-learner>" + (chosen == null ? "" : Server.HtmlEncode(chosen.Name)) + "</strong>. "
                + "The learner will be able to see the grade and your feedback.";
            if (!IsPostBack) hfTeacherGradeAssessment.Value = SelectedAssessment.Key;
        }

        /// <summary>"1 question", "3 questions".</summary>
        protected static string Questions(int count)
        {
            return count + (count == 1 ? " question" : " questions");
        }

        protected string StatusClass(string status)
        {
            if (status == "Graded") return "is-graded";
            if (status == "In progress") return "is-progress";
            return "is-ungraded";
        }

        protected void btnTeacherSaveGrading_Click(object sender, EventArgs e)
        {
            // TODO (Phase 4): save the grading progress (GradingProgress) for the AttemptId in hfTeacherGradeLearner (checked against this
            //   teacher's course), marks hfTeacherMarksQ2 and comment txtTeacherCommentQ2
            Master.ShowToast("Saving grading progress is added in a later step, so nothing was saved.");
        }

        protected void mdlTeacherConfirmGrade_Confirmed(object sender, EventArgs e)
        {
            // TODO (Phase 4): confirm the grade (Result) so the learner can see the grade and feedback
            Master.ShowToast("Confirming grades is added in a later step, so nothing was saved.");
        }
    }
}
