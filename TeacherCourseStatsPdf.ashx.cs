using PdfSharp.Drawing;
using PdfSharp.Pdf;
using System;
using System.Collections.Generic;
using System.IO;
using System.Web;
using System.Web.SessionState;

namespace Codercept
{
    /// <summary>
    /// Serves the course statistics and the performance statistics of one course as real PDFs.
    ///   TeacherCourseStatsPdf.ashx?course=1&amp;type=course                 -> the "Course Statistics" card (inline)
    ///   TeacherCourseStatsPdf.ashx?course=1&amp;type=performance&amp;download=1 -> the "Performance Statistics" card, as a download
    /// The course must be one of the signed-in teacher's; anything else is a 404.
    /// </summary>
    public class TeacherCourseStatsPdf : IHttpHandler, IReadOnlySessionState
    {
        public bool IsReusable { get { return false; } }

        public void ProcessRequest(HttpContext context)
        {
            // Same rule as TeacherSite.master.cs: only a signed-in Teacher may download statistics
            if (context.Session == null || context.Session["UserType"] == null || context.Session["UserType"].ToString() != "Teacher")
            {
                context.Response.Redirect("~/signIn.aspx", false);
                context.ApplicationInstance.CompleteRequest();
                return;
            }

            string type = context.Request.QueryString["type"];
            int courseId;
            TeacherCourseFigures figures = (type == "course" || type == "performance") && int.TryParse(context.Request.QueryString["course"], out courseId)
                ? TeacherStatsData.GetCourseFigures(courseId) : null;
            if (figures == null)
            {
                // unknown type, or a course that is not this teacher's
                context.Response.StatusCode = 404;
                context.Response.ContentType = "text/plain";
                context.Response.Write("Statistics not found.");
                context.ApplicationInstance.CompleteRequest();
                return;
            }

            string instructor = context.Session["UserName"] != null ? context.Session["UserName"].ToString() : TeacherSampleData.FallbackName;
            string logoPath = context.Server.MapPath("~/img/Codercept_Icon.png");

            byte[] pdf = type == "course"
                ? TeacherStatsPdf.BuildCourse(figures, instructor, logoPath, DateTime.Today)
                : TeacherStatsPdf.BuildPerformance(figures, TeacherStatsData.GetPerformance(figures.CourseId), instructor, logoPath, DateTime.Today);

            bool download = context.Request.QueryString["download"] == "1";
            // only letters, digits and underscores in the file name, whatever the course title contains
            string fileName = (type == "course" ? "Course_Statistics_" : "Performance_Statistics_")
                + System.Text.RegularExpressions.Regex.Replace(figures.CourseTitle, "[^A-Za-z0-9]+", "_").Trim('_') + ".pdf";

            context.Response.Clear();
            context.Response.ContentType = "application/pdf";
            context.Response.AddHeader("content-length", pdf.Length.ToString());
            context.Response.AddHeader("content-disposition", (download ? "attachment" : "inline") + "; filename=\"" + fileName + "\"");
            context.Response.BinaryWrite(pdf);
            context.Response.Flush();
            context.ApplicationInstance.CompleteRequest();
        }
    }

    /// <summary>Draws the two statistics PDFs (A4) with PDFsharp, in the same style as the learner report.</summary>
    public static class TeacherStatsPdf
    {
        private const double Left = 40, Right = 555, Width = Right - Left;

        private static readonly XColor Ink = XColor.FromArgb(17, 24, 39);
        private static readonly XColor Muted = XColor.FromArgb(107, 114, 128);
        private static readonly XColor Line = XColor.FromArgb(229, 231, 235);
        private static readonly XColor Indigo = XColor.FromArgb(79, 70, 229);

        private static string Fit(string text, int max)
        {
            return text.Length <= max ? text : text.Substring(0, max - 3).TrimEnd() + "...";
        }

        public static byte[] BuildCourse(TeacherCourseFigures figures, string instructor, string logoPath, DateTime today)
        {
            PdfSharp.PdfSharpLicense.SetAgplLicense();
            PdfDocument document;
            XGraphics gfx = Start(out document, "Course Statistics - " + figures.CourseTitle, "COURSE STATISTICS", "CS", figures, logoPath, today);
            XFont fTiny = new XFont("Arial", 7.5, XFontStyleEx.Regular);
            XFont fH2 = new XFont("Arial", 11, XFontStyleEx.Bold);
            XFont fValue = new XFont("Arial", 15, XFontStyleEx.Bold);
            XSolidBrush inkB = new XSolidBrush(Ink), mutedB = new XSolidBrush(Muted), indigoB = new XSolidBrush(Indigo);
            XPen linePen = new XPen(Line, 0.8);

            double y = 192;
            TeacherReportPdf.Section(gfx, "Engagement overview", fH2, inkB, linePen, y);
            y += 26;
            double half = (Width - 12) / 2;
            List<TeacherDetailItem> rows = TeacherStatsData.CourseRows(figures);
            for (int i = 0; i < rows.Count; i++)
            {
                double x = i % 2 == 0 ? Left : Left + half + 12;
                TeacherReportPdf.Cell(gfx, x, y, half, 50, rows[i].Label, rows[i].Value, fTiny, fValue, mutedB, inkB, linePen);
                if (i % 2 == 1) y += 60;
            }

            y += 14;
            TeacherReportPdf.Section(gfx, "Completion rate", fH2, inkB, linePen, y);
            y += 26;
            TeacherReportPdf.Cell(gfx, Left, y, Width, 56, "Completion rate", figures.CompletionRate + "%", fTiny, fValue, mutedB, inkB, linePen);
            gfx.DrawRoundedRectangle(null, new XSolidBrush(Line), Left + 8, y + 45, Width - 16, 4, 2, 2);
            gfx.DrawRoundedRectangle(null, indigoB, Left + 8, y + 45, (Width - 16) * figures.CompletionRate / 100.0, 4, 2, 2);
            gfx.DrawString(figures.Completed + " of " + figures.Attended + (figures.Attended == 1 ? " learner" : " learners") + " completed this course",
                fTiny, mutedB, new XRect(Left + 8, y + 62, Width - 16, 12), XStringFormats.TopLeft);

            return Finish(document, gfx, instructor, today);
        }

        public static byte[] BuildPerformance(TeacherCourseFigures figures, TeacherPerformance performance, string instructor, string logoPath, DateTime today)
        {
            PdfSharp.PdfSharpLicense.SetAgplLicense();
            PdfDocument document;
            XGraphics gfx = Start(out document, "Performance Statistics - " + figures.CourseTitle, "PERFORMANCE STATISTICS", "PS", figures, logoPath, today);
            XFont fTiny = new XFont("Arial", 7.5, XFontStyleEx.Regular);
            XFont fTinyBold = new XFont("Arial", 8, XFontStyleEx.Bold);
            XFont fH2 = new XFont("Arial", 11, XFontStyleEx.Bold);
            XFont fValue = new XFont("Arial", 15, XFontStyleEx.Bold);
            XSolidBrush inkB = new XSolidBrush(Ink), mutedB = new XSolidBrush(Muted), indigoB = new XSolidBrush(Indigo);
            XPen linePen = new XPen(Line, 0.8);

            double y = 192;
            TeacherReportPdf.Section(gfx, "Assessment results", fH2, inkB, linePen, y);
            y += 26;
            double half = (Width - 12) / 2;
            List<TeacherDetailItem> cells = new List<TeacherDetailItem> { new TeacherDetailItem { Label = "Graded results", Value = performance.Graded.ToString() } };
            cells.AddRange(performance.Metrics);
            for (int i = 0; i < cells.Count; i++)
            {
                double x = i % 2 == 0 ? Left : Left + half + 12;
                TeacherReportPdf.Cell(gfx, x, y, half, 50, cells[i].Label, cells[i].Value, fTiny, fValue, mutedB, inkB, linePen);
                if (i % 2 == 1) y += 60;
            }
            gfx.DrawString("Marks are percentages of the available marks. Std. deviation needs at least two graded results.", fTiny, mutedB,
                new XRect(Left, y - 4, Width, 12), XStringFormats.TopLeft);

            y += 24;
            TeacherReportPdf.Section(gfx, "Grade distribution", fH2, inkB, linePen, y);
            gfx.DrawString("Number of learners by final grade (their latest graded exam)", fTiny, mutedB, new XRect(Left, y + 26, Width, 12), XStringFormats.TopLeft);
            double baseY = y + 26 + 12 + 14 + 120, maxH = 110;
            int bars = performance.GradeCounts.Count;
            double slot = Width / bars, barW = Math.Min(40, slot - 20);
            for (int i = 0; i < bars; i++)
            {
                TeacherGrade bar = performance.GradeCounts[i];
                double h = maxH * bar.Value / 100.0;
                double bx = Left + slot * i + (slot - barW) / 2;
                gfx.DrawString(bar.Count.ToString(), fTinyBold, inkB, new XRect(bx - 10, baseY - h - 13, barW + 20, 10), XStringFormats.TopCenter);
                if (h > 0) gfx.DrawRectangle(indigoB, bx, baseY - h, barW, h);
                gfx.DrawString(bar.Grade, fTinyBold, inkB, new XRect(bx - 10, baseY + 5, barW + 20, 10), XStringFormats.TopCenter);
            }
            gfx.DrawLine(linePen, Left, baseY, Right, baseY);

            return Finish(document, gfx, instructor, today);
        }

        /// <summary>Creates the page and draws the header and the title block that both PDFs share.</summary>
        private static XGraphics Start(out PdfDocument document, string title, string heading, string idPrefix, TeacherCourseFigures figures, string logoPath, DateTime today)
        {
            string todayText = today.ToString("d MMMM yyyy", System.Globalization.CultureInfo.InvariantCulture);
            document = new PdfDocument();
            document.Info.Title = title;
            PdfPage page = document.AddPage();
            page.Size = PdfSharp.PageSize.A4;
            XGraphics gfx = XGraphics.FromPdfPage(page);

            XSolidBrush inkB = new XSolidBrush(Ink), mutedB = new XSolidBrush(Muted), indigoB = new XSolidBrush(Indigo);
            XFont fBrand = new XFont("Arial", 16, XFontStyleEx.Bold);
            XFont fTiny = new XFont("Arial", 7.5, XFontStyleEx.Regular);
            XFont fTinyBold = new XFont("Arial", 8, XFontStyleEx.Bold);

            if (File.Exists(logoPath))
            {
                gfx.DrawImage(XImage.FromFile(logoPath), Left, 36, 34, 34);
            }
            gfx.DrawString("Codercept", fBrand, inkB, new XRect(Left + 44, 38, 200, 20), XStringFormats.TopLeft);
            gfx.DrawString("Programming Education Platform", fTiny, mutedB, new XRect(Left + 44, 57, 220, 12), XStringFormats.TopLeft);
            gfx.DrawString(heading, fTinyBold, inkB, new XRect(Right - 220, 38, 220, 12), XStringFormats.TopRight);
            gfx.DrawString("Report ID · " + idPrefix + "-" + today.ToString("yyyyMMdd") + "-" + figures.CourseId, fTiny, mutedB, new XRect(Right - 220, 52, 220, 12), XStringFormats.TopRight);
            gfx.DrawString("Generated · " + todayText, fTiny, mutedB, new XRect(Right - 220, 64, 220, 12), XStringFormats.TopRight);
            gfx.DrawLine(new XPen(Ink, 2), Left, 84, Right, 84);

            gfx.DrawString("COURSE ANALYTICS", fTinyBold, indigoB, new XRect(Left, 104, 300, 12), XStringFormats.TopLeft);
            gfx.DrawString(Fit(figures.CourseTitle, 42), new XFont("Arial", 24, XFontStyleEx.Bold), inkB, new XRect(Left, 120, Width, 34), XStringFormats.TopLeft);
            gfx.DrawString(heading == "COURSE STATISTICS" ? "Course statistics" : "Performance statistics", new XFont("Arial", 12, XFontStyleEx.Regular), mutedB,
                new XRect(Left, 156, Width, 16), XStringFormats.TopLeft);
            return gfx;
        }

        /// <summary>Draws the signature footer and returns the finished file.</summary>
        private static byte[] Finish(PdfDocument document, XGraphics gfx, string instructor, DateTime today)
        {
            string todayText = today.ToString("d MMMM yyyy", System.Globalization.CultureInfo.InvariantCulture);
            XSolidBrush inkB = new XSolidBrush(Ink), mutedB = new XSolidBrush(Muted);
            XFont fTiny = new XFont("Arial", 7.5, XFontStyleEx.Regular);
            XFont fTinyBold = new XFont("Arial", 8, XFontStyleEx.Bold);
            XFont italic = new XFont("Arial", 10, XFontStyleEx.Italic);
            XPen linePen = new XPen(Line, 0.8);
            XPen sig = new XPen(XColor.FromArgb(100, 116, 139), 0.8);

            double fy = 760;
            gfx.DrawLine(linePen, Left, fy - 24, Right, fy - 24);
            gfx.DrawString(instructor, italic, inkB, new XRect(Left, fy - 10, 200, 14), XStringFormats.TopLeft);
            gfx.DrawLine(sig, Left, fy + 6, Left + 200, fy + 6);
            gfx.DrawString("Instructor signature", fTinyBold, inkB, new XRect(Left, fy + 10, 200, 12), XStringFormats.TopLeft);
            gfx.DrawString("Codercept Teacher Portal", fTiny, mutedB, new XRect(Left, fy + 23, 200, 12), XStringFormats.TopLeft);

            gfx.DrawString(todayText, italic, inkB, new XRect(Left + 250, fy - 10, 180, 14), XStringFormats.TopLeft);
            gfx.DrawLine(sig, Left + 250, fy + 6, Left + 430, fy + 6);
            gfx.DrawString("Date issued", fTinyBold, inkB, new XRect(Left + 250, fy + 10, 180, 12), XStringFormats.TopLeft);
            gfx.DrawString("Verified digital report", fTiny, mutedB, new XRect(Left + 250, fy + 23, 180, 12), XStringFormats.TopLeft);

            using (MemoryStream stream = new MemoryStream())
            {
                document.Save(stream, false);
                return stream.ToArray();
            }
        }
    }
}
