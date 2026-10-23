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
        protected List<TeacherSubmission> Submissions;

        protected TeacherAssessment SelectedAssessment
        {
            get
            {
                return Assessments.FirstOrDefault(a => a.Title == hfTeacherGradeAssessment.Value) ?? Assessments[0];
            }
        }

        protected TeacherSubmission SelectedSubmission
        {
            get
            {
                int i;
                if (int.TryParse(hfTeacherGradeLearner.Value, out i) && i >= 0 && i < Submissions.Count) return Submissions[i];
                return Submissions[0];
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            List<TeacherCourse> courses = TeacherSampleData.GetCourses();
            int courseId;
            int.TryParse(Request.QueryString["course"], out courseId);
            // TODO (backend): load the course WHERE CourseId = @CourseId AND TeacherId = @TeacherId; unknown or foreign id -> redirect
            Course = courses.FirstOrDefault(c => c.Id == courseId) ?? courses[0];
            Pending = TeacherSampleData.PendingSubmissions(Course.Id);

            // TODO (backend): this course's exams/quizzes and the learners who submitted them
            Assessments = TeacherSampleData.GetAssessments();
            Submissions = TeacherSampleData.GetSubmissions();
        }

        protected void Page_PreRender(object sender, EventArgs e)
        {
            // The learner name and total in the confirm dialog are filled in by TeacherPortal.js
            mdlTeacherConfirmGrade.BodyHtml = "You are about to confirm a total of <strong data-tp-confirm-total>0 / 100</strong> for "
                + "<strong data-tp-confirm-learner>" + Server.HtmlEncode(SelectedSubmission.Name) + "</strong>. "
                + "The learner will be able to see the grade and your feedback.";
            if (!IsPostBack) hfTeacherGradeAssessment.Value = SelectedAssessment.Title;
        }

        protected string StatusClass(string status)
        {
            if (status == "Graded") return "is-graded";
            if (status == "In progress") return "is-progress";
            return "is-ungraded";
        }

        protected void btnTeacherSaveGrading_Click(object sender, EventArgs e)
        {
            // TODO (backend): save the grading progress (GradingProgress) for hfTeacherGradeAssessment / learner index
            //   hfTeacherGradeLearner, marks hfTeacherMarksQ2 and comment txtTeacherCommentQ2
            Master.ShowToast("Grading progress saved");
        }

        protected void mdlTeacherConfirmGrade_Confirmed(object sender, EventArgs e)
        {
            // TODO (backend): confirm the grade (Result) so the learner can see the grade and feedback
            Master.ShowToast("Grade confirmed for " + SelectedSubmission.Name);
        }
    }
}
