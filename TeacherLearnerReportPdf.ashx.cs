using PdfSharp.Drawing;
using PdfSharp.Pdf;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.SessionState;

namespace Codercept
{
    /// <summary>
    /// Serves the learner's course progress report as a real PDF.
    ///   TeacherLearnerReportPdf.ashx?learner=2&amp;course=1            -> (LearnerId, CourseId) opens in the browser's PDF viewer (inline)
    ///   TeacherLearnerReportPdf.ashx?learner=2&amp;course=1&amp;download=1 -> downloads the file
    /// The learner must be enrolled in one of the signed-in teacher's courses; anything else is a 404.
    /// </summary>
    public class TeacherLearnerReportPdf : IHttpHandler, IReadOnlySessionState
    {
        public bool IsReusable { get { return false; } }

        public void ProcessRequest(HttpContext context)
        {
            // Same rule as TeacherSite.master.cs: only a signed-in Teacher may download a report
            if (context.Session == null || context.Session["UserType"] == null || context.Session["UserType"].ToString() != "Teacher")
            {
                context.Response.Redirect("~/signIn.aspx", false);
                context.ApplicationInstance.CompleteRequest();
                return;
            }

            int learnerId, courseId;
            TeacherLearnerReportData report = int.TryParse(context.Request.QueryString["learner"], out learnerId)
                && int.TryParse(context.Request.QueryString["course"], out courseId)
                ? TeacherLearnerData.GetReport(courseId, learnerId) : null;
            if (report == null)
            {
                // unknown learner, or one not enrolled in this teacher's courses
                context.Response.StatusCode = 404;
                context.Response.ContentType = "text/plain";
                context.Response.Write("Report not found.");
                context.ApplicationInstance.CompleteRequest();
                return;
            }

            string instructor = context.Session != null && context.Session["UserName"] != null
                ? context.Session["UserName"].ToString() : TeacherSampleData.FallbackName;

            byte[] pdf = TeacherReportPdf.Build(report, instructor, context.Server.MapPath("~/img/Codercept_Icon.png"), DateTime.Today);

            bool download = context.Request.QueryString["download"] == "1";
            // only letters, digits and underscores in the file name, whatever the learner's name contains
            string fileName = "Course_Report_" + System.Text.RegularExpressions.Regex.Replace(report.Learner.Name, "[^A-Za-z0-9]+", "_").Trim('_') + ".pdf";

            context.Response.Clear();
            context.Response.ContentType = "application/pdf";
            context.Response.AddHeader("content-length", pdf.Length.ToString());
            context.Response.AddHeader("content-disposition", (download ? "attachment" : "inline") + "; filename=\"" + fileName + "\"");
            context.Response.BinaryWrite(pdf);
            context.Response.Flush();
            context.ApplicationInstance.CompleteRequest();
        }
    }

    /// <summary>Draws the course progress report (A4) with PDFsharp, mirroring the on-screen report.</summary>
    public static class TeacherReportPdf
    {
        private const double Left = 40, Right = 555, Width = Right - Left;

        /// <summary>The most assessment rows and chart bars that fit on the page.</summary>
        private const int MaxRows = 8;

        /// <summary>A detail that is not known is written "-" in the data; the report says so in words.</summary>
        private static string Show(string value)
        {
            return value == "-" ? "Not available yet" : value;
        }

        /// <summary>The same for the large summary figures, where a long phrase would not fit.</summary>
        private static string Short(string value)
        {
            return value == "-" ? "\u2013" : value;
        }

        /// <summary>Cuts text to the width of its column.</summary>
        private static string Fit(string text, int max)
        {
            return text.Length <= max ? text : text.Substring(0, max - 3).TrimEnd() + "...";
        }

        public static byte[] Build(TeacherLearnerReportData report, string instructor, string logoPath, DateTime today)
        {
            PdfSharp.PdfSharpLicense.SetAgplLicense();

            TeacherLearner learner = report.Learner;
            string courseTitle = report.CourseTitle;
            string todayText = today.ToString("d MMMM yyyy", System.Globalization.CultureInfo.InvariantCulture);
            string reportId = "CR-" + today.ToString("yyyyMMdd") + "-" + report.CourseId + "-" + learner.Id;

            PdfDocument document = new PdfDocument();
            document.Info.Title = "Course Progress Report - " + learner.Name;
            PdfPage page = document.AddPage();
            page.Size = PdfSharp.PageSize.A4;
            XGraphics gfx = XGraphics.FromPdfPage(page);

            XColor ink = XColor.FromArgb(17, 24, 39);
            XColor body = XColor.FromArgb(75, 85, 99);
            XColor muted = XColor.FromArgb(107, 114, 128);
            XColor line = XColor.FromArgb(229, 231, 235);
            XColor indigo = XColor.FromArgb(79, 70, 229);
            XSolidBrush inkB = new XSolidBrush(ink), bodyB = new XSolidBrush(body), mutedB = new XSolidBrush(muted), indigoB = new XSolidBrush(indigo);
            XPen linePen = new XPen(line, 0.8);

            XFont fBrand = new XFont("Arial", 16, XFontStyleEx.Bold);
            XFont fTiny = new XFont("Arial", 7.5, XFontStyleEx.Regular);
            XFont fTinyBold = new XFont("Arial", 8, XFontStyleEx.Bold);
            XFont fSmall = new XFont("Arial", 9, XFontStyleEx.Regular);
            XFont fSmallBold = new XFont("Arial", 9.5, XFontStyleEx.Bold);
            XFont fH2 = new XFont("Arial", 11, XFontStyleEx.Bold);
            XFont fName = new XFont("Arial", 28, XFontStyleEx.Bold);
            XFont fBig = new XFont("Arial", 15, XFontStyleEx.Bold);

            // ---- header
            if (File.Exists(logoPath))
            {
                gfx.DrawImage(XImage.FromFile(logoPath), Left, 36, 34, 34);
            }
            gfx.DrawString("Codercept", fBrand, inkB, new XRect(Left + 44, 38, 200, 20), XStringFormats.TopLeft);
            gfx.DrawString("Programming Education Platform", fTiny, mutedB, new XRect(Left + 44, 57, 220, 12), XStringFormats.TopLeft);
            gfx.DrawString("COURSE PROGRESS REPORT", fTinyBold, inkB, new XRect(Right - 220, 38, 220, 12), XStringFormats.TopRight);
            gfx.DrawString("Report ID · " + reportId, fTiny, mutedB, new XRect(Right - 220, 52, 220, 12), XStringFormats.TopRight);
            gfx.DrawString("Generated · " + todayText, fTiny, mutedB, new XRect(Right - 220, 64, 220, 12), XStringFormats.TopRight);
            gfx.DrawLine(new XPen(ink, 2), Left, 84, Right, 84);

            // ---- title block
            gfx.DrawString("LEARNER PERFORMANCE", fTinyBold, indigoB, new XRect(Left, 104, 300, 12), XStringFormats.TopLeft);
            gfx.DrawString(learner.Name, fName, inkB, new XRect(Left, 118, Width, 36), XStringFormats.TopLeft);
            gfx.DrawString(courseTitle, new XFont("Arial", 12, XFontStyleEx.Regular), mutedB, new XRect(Left, 156, Width, 16), XStringFormats.TopLeft);

            // ---- learner details
            double y = 192;
            Section(gfx, "Learner details", fH2, inkB, linePen, y);
            y += 26;
            double half = (Width - 12) / 2;
            Cell(gfx, Left, y, half, 38, "Email address", learner.Email, fTiny, fSmallBold, mutedB, inkB, linePen);
            Cell(gfx, Left + half + 12, y, half, 38, "Student level", Show(learner.Level), fTiny, fSmallBold, mutedB, inkB, linePen);
            y += 46;
            Cell(gfx, Left, y, half, 38, "Enrolled on", learner.Enrolled, fTiny, fSmallBold, mutedB, inkB, linePen);
            Cell(gfx, Left + half + 12, y, half, 38, "Last accessed", Show(learner.Accessed), fTiny, fSmallBold, mutedB, inkB, linePen);

            // ---- progress summary
            y += 62;
            Section(gfx, "Progress summary", fH2, inkB, linePen, y);
            y += 26;
            double q = (Width - 30) / 4;
            string grade = Short(learner.Grade);
            Cell(gfx, Left, y, q, 56, "Course progress", learner.Progress + "%", fTiny, fBig, mutedB, inkB, linePen);
            gfx.DrawRoundedRectangle(null, new XSolidBrush(XColor.FromArgb(229, 231, 235)), Left + 8, y + 45, q - 16, 4, 2, 2);
            gfx.DrawRoundedRectangle(null, indigoB, Left + 8, y + 45, (q - 16) * learner.Progress / 100.0, 4, 2, 2);
            Cell(gfx, Left + (q + 10), y, q, 56, "Quizzes completed", Short(learner.Quizzes), fTiny, fBig, mutedB, inkB, linePen);
            Cell(gfx, Left + 2 * (q + 10), y, q, 56, "Overall average", Short(learner.Average), fTiny, fBig, mutedB, inkB, linePen);
            Cell(gfx, Left + 3 * (q + 10), y, q, 56, "Current grade", grade, fTiny, fBig, mutedB, new XSolidBrush(XColor.FromArgb(22, 163, 74)), linePen);

            // ---- assessment results (table) + score overview (chart)
            y += 82;
            double tableW = 270;
            double chartX = Left + tableW + 30, chartW = Right - chartX;
            Section(gfx, "Assessment results", fH2, inkB, linePen, y, Left, Left + tableW);
            Section(gfx, "Score overview", fH2, inkB, linePen, y, chartX, Right);
            double ty = y + 28;
            gfx.DrawString("Assessment", fTinyBold, inkB, new XRect(Left + 4, ty, 130, 12), XStringFormats.TopLeft);
            gfx.DrawString("Score", fTinyBold, inkB, new XRect(Left + 150, ty, 60, 12), XStringFormats.TopLeft);
            gfx.DrawString("Grade", fTinyBold, inkB, new XRect(Left + tableW - 50, ty, 46, 12), XStringFormats.TopRight);
            ty += 16;
            gfx.DrawLine(linePen, Left, ty, Left + tableW, ty);
            if (report.Scores.Count == 0)
            {
                gfx.DrawString("No graded results yet.", fTiny, mutedB, new XRect(Left + 4, ty + 8, tableW - 8, 12), XStringFormats.TopLeft);
            }
            // the page holds MaxRows rows; the newest results are shown and a note says how many older ones are left out
            int firstRow = Math.Max(0, report.Scores.Count - MaxRows);
            if (firstRow > 0)
            {
                gfx.DrawString("+ " + firstRow + " earlier result" + (firstRow == 1 ? "" : "s") + " not shown", fTiny, mutedB, new XRect(Left + 4, ty + 8, tableW - 8, 12), XStringFormats.TopLeft);
                ty += 22;
                gfx.DrawLine(linePen, Left, ty, Left + tableW, ty);
            }
            for (int r = firstRow; r < report.Scores.Count; r++)
            {
                TeacherReportScore row = report.Scores[r];
                gfx.DrawString((r + 1) + ". " + Fit(row.Item, 30), fTiny, bodyB, new XRect(Left + 4, ty + 8, 150, 12), XStringFormats.TopLeft);
                gfx.DrawString(row.Score, fTiny, bodyB, new XRect(Left + 170, ty + 8, 60, 12), XStringFormats.TopLeft);
                gfx.DrawString(row.Grade, fTinyBold, new XSolidBrush(XColor.FromArgb(22, 163, 74)), new XRect(Left + tableW - 50, ty + 8, 46, 12), XStringFormats.TopRight);
                ty += 28;
                gfx.DrawLine(linePen, Left, ty, Left + tableW, ty);
            }

            List<int> bars = report.Percents.Skip(firstRow).ToList();
            double baseY = y + 28 + 110, maxH = 100;
            if (bars.Count == 0)
            {
                gfx.DrawString("No graded results yet.", fTiny, mutedB, new XRect(chartX, y + 28, chartW, 12), XStringFormats.TopLeft);
            }
            else
            {
                double slot = chartW / bars.Count, barW = Math.Min(20, slot - 4);
                for (int i = 0; i < bars.Count; i++)
                {
                    double h = maxH * bars[i] / 100.0;
                    double bx = chartX + slot * i + (slot - barW) / 2;
                    gfx.DrawString(bars[i].ToString(), fTiny, mutedB, new XRect(bx - 10, baseY - h - 12, barW + 20, 10), XStringFormats.TopCenter);
                    gfx.DrawRectangle(indigoB, bx, baseY - h, barW, h);
                    gfx.DrawString((firstRow + i + 1).ToString(), fTiny, mutedB, new XRect(bx - 10, baseY + 4, barW + 20, 10), XStringFormats.TopCenter);
                }
                gfx.DrawLine(linePen, chartX, baseY, Right, baseY);
                gfx.DrawString("Each bar is one graded result as a percentage, numbered as in the table.", fTiny, mutedB,
                    new XRect(chartX, baseY + 20, chartW, 24), XStringFormats.TopLeft);
            }

            // ---- footer (signatures)
            double fy = 760;
            gfx.DrawLine(linePen, Left, fy - 24, Right, fy - 24);
            XPen sig = new XPen(XColor.FromArgb(100, 116, 139), 0.8);
            gfx.DrawString(instructor, new XFont("Arial", 10, XFontStyleEx.Italic), inkB, new XRect(Left, fy - 10, 200, 14), XStringFormats.TopLeft);
            gfx.DrawLine(sig, Left, fy + 6, Left + 200, fy + 6);
            gfx.DrawString("Instructor signature", fTinyBold, inkB, new XRect(Left, fy + 10, 200, 12), XStringFormats.TopLeft);
            gfx.DrawString("Codercept Teacher Portal", fTiny, mutedB, new XRect(Left, fy + 23, 200, 12), XStringFormats.TopLeft);

            gfx.DrawString(todayText, new XFont("Arial", 10, XFontStyleEx.Italic), inkB, new XRect(Left + 250, fy - 10, 180, 14), XStringFormats.TopLeft);
            gfx.DrawLine(sig, Left + 250, fy + 6, Left + 430, fy + 6);
            gfx.DrawString("Date issued", fTinyBold, inkB, new XRect(Left + 250, fy + 10, 180, 12), XStringFormats.TopLeft);
            gfx.DrawString("Verified digital report", fTiny, mutedB, new XRect(Left + 250, fy + 23, 180, 12), XStringFormats.TopLeft);

            using (MemoryStream stream = new MemoryStream())
            {
                document.Save(stream, false);
                return stream.ToArray();
            }
        }

        private static void Section(XGraphics gfx, string title, XFont font, XBrush brush, XPen pen, double y)
        {
            Section(gfx, title, font, brush, pen, y, Left, Right);
        }

        private static void Section(XGraphics gfx, string title, XFont font, XBrush brush, XPen pen, double y, double x1, double x2)
        {
            gfx.DrawString(title.ToUpper(), font, brush, new XRect(x1, y, x2 - x1, 14), XStringFormats.TopLeft);
            gfx.DrawLine(pen, x1, y + 18, x2, y + 18);
        }

        private static void Cell(XGraphics gfx, double x, double y, double w, double h, string label, string value,
            XFont labelFont, XFont valueFont, XBrush labelBrush, XBrush valueBrush, XPen border)
        {
            gfx.DrawRoundedRectangle(border, null, x, y, w, h, 6, 6);
            gfx.DrawString(label, labelFont, labelBrush, new XRect(x + 8, y + 7, w - 16, 10), XStringFormats.TopLeft);
            gfx.DrawString(value, valueFont, valueBrush, new XRect(x + 8, y + 20, w - 16, 18), XStringFormats.TopLeft);
        }
    }
}
