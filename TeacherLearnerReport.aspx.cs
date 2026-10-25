using System;
using System.Collections.Generic;
using System.Linq;

namespace Codercept
{
    public partial class TeacherLearnerReport : System.Web.UI.Page
    {
        /// <summary>The most graded results the score chart shows (the newest ones).</summary>
        private const int MaxBars = 8;

        protected TeacherLearnerReportData Report;
        protected TeacherLearner Learner;
        protected int LearnerId;
        protected int CourseId;
        protected string CourseTitle;
        protected string ReportId;
        protected string Today;

        /// <summary>The percentages the chart draws, and which result (1, 2, ...) the first bar is.</summary>
        protected List<int> Bars;
        protected int FirstBar;

        protected void Page_Load(object sender, EventArgs e)
        {
            // learner and course must both be given, and the learner must be enrolled in one of this teacher's courses; otherwise back to the list
            int learnerId, courseId;
            if (!int.TryParse(Request.QueryString["learner"], out learnerId) || !int.TryParse(Request.QueryString["course"], out courseId))
            {
                Response.Redirect("~/TeacherLearners.aspx");
            }
            else
            {
                Report = TeacherLearnerData.GetReport(courseId, learnerId);
                if (Report == null) Response.Redirect("~/TeacherLearners.aspx");
            }

            Learner = Report.Learner;
            LearnerId = Learner.Id;
            CourseId = Report.CourseId;
            CourseTitle = Report.CourseTitle;
            DateTime now = DateTime.Today;
            Today = now.ToString("d MMMM yyyy", System.Globalization.CultureInfo.InvariantCulture);
            ReportId = "CR-" + now.ToString("yyyyMMdd") + "-" + CourseId + "-" + LearnerId;

            FirstBar = Math.Max(0, Report.Percents.Count - MaxBars);
            Bars = Report.Percents.Skip(FirstBar).ToList();

            rptTeacherReportScores.DataSource = Report.Scores;
            rptTeacherReportScores.DataBind();
        }

        /// <summary>A detail that is not known (yet) is written "-" in the data; the report says so in words.</summary>
        protected static string Show(string value)
        {
            return value == "-" ? "Not available yet" : value;
        }

        /// <summary>The same for the short figures of the summary boxes.</summary>
        protected static string Short(string value)
        {
            return value == "-" ? "\u2013" : value;
        }

        protected void btnTeacherSaveReportPdf_Click(object sender, EventArgs e)
        {
            // Same PDF as "Open in new window", sent as a download
            Response.Redirect("TeacherLearnerReportPdf.ashx?download=1&learner=" + LearnerId + "&course=" + CourseId);
        }
    }
}
