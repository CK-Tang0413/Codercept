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
    /// Serves the learner's course progress report as a real PDF.
    ///   TeacherLearnerReportPdf.ashx?learner=2            -> (LearnerId) opens in the browser's PDF viewer (inline)
    ///   TeacherLearnerReportPdf.ashx?learner=2&amp;download=1 -> downloads the file
    /// TODO (backend): pass the course id too and load the learner's real results.
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

            List<TeacherLearner> learners = TeacherSampleData.GetLearners();
            int id;
            int.TryParse(context.Request.QueryString["learner"], out id);
            // TODO (backend): unknown learner, or one not enrolled in this teacher's courses -> 404
            TeacherLearner learner = learners.Find(l => l.Id == id) ?? learners[0];

            string instructor = context.Session != null && context.Session["UserName"] != null
                ? context.Session["UserName"].ToString() : TeacherSampleData.FallbackName;

            byte[] pdf = TeacherReportPdf.Build(learner, TeacherSampleData.ReportCourseTitle, instructor,
                context.Server.MapPath("~/img/Codercept_Icon.png"));

            bool download = context.Request.QueryString["download"] == "1";
            string fileName = "Course_Report_" + learner.Name.Replace(" ", "_") + ".pdf";

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

        public static byte[] Build(TeacherLearner learner, string courseTitle, string instructor, string logoPath)
        {
            PdfSharp.PdfSharpLicense.SetAgplLicense();

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
            gfx.DrawString("Report ID · CR-2024-0528", fTiny, mutedB, new XRect(Right - 220, 52, 220, 12), XStringFormats.TopRight);
            gfx.DrawString("Generated · 28 May 2024", fTiny, mutedB, new XRect(Right - 220, 64, 220, 12), XStringFormats.TopRight);
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
            Cell(gfx, Left + half + 12, y, half, 38, "Student level", learner.Level, fTiny, fSmallBold, mutedB, inkB, linePen);
            y += 46;
            Cell(gfx, Left, y, half, 38, "Enrolled on", learner.Enrolled, fTiny, fSmallBold, mutedB, inkB, linePen);
            Cell(gfx, Left + half + 12, y, half, 38, "Last accessed", learner.Accessed, fTiny, fSmallBold, mutedB, inkB, linePen);

            // ---- progress summary
            y += 62;
            Section(gfx, "Progress summary", fH2, inkB, linePen, y);
            y += 26;
            double q = (Width - 30) / 4;
            string grade = learner.Grade == "-" ? "–" : learner.Grade;
            Cell(gfx, Left, y, q, 56, "Course progress", learner.Progress + "%", fTiny, fBig, mutedB, inkB, linePen);
            gfx.DrawRoundedRectangle(null, new XSolidBrush(XColor.FromArgb(229, 231, 235)), Left + 8, y + 45, q - 16, 4, 2, 2);
            gfx.DrawRoundedRectangle(null, indigoB, Left + 8, y + 45, (q - 16) * learner.Progress / 100.0, 4, 2, 2);
            Cell(gfx, Left + (q + 10), y, q, 56, "Quizzes completed", learner.Quizzes, fTiny, fBig, mutedB, inkB, linePen);
            Cell(gfx, Left + 2 * (q + 10), y, q, 56, "Overall average", learner.Average, fTiny, fBig, mutedB, inkB, linePen);
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
            foreach (TeacherReportScore row in TeacherSampleData.GetReportScores())
            {
                gfx.DrawString(row.Item, fTiny, bodyB, new XRect(Left + 4, ty + 8, 145, 12), XStringFormats.TopLeft);
                gfx.DrawString(row.Score, fTiny, bodyB, new XRect(Left + 150, ty + 8, 60, 12), XStringFormats.TopLeft);
                gfx.DrawString(row.Grade, fTinyBold, new XSolidBrush(XColor.FromArgb(22, 163, 74)), new XRect(Left + tableW - 50, ty + 8, 46, 12), XStringFormats.TopRight);
                ty += 28;
                gfx.DrawLine(linePen, Left, ty, Left + tableW, ty);
            }

            int[] bars = { 72, 80, 76, 88, 86 };
            double baseY = y + 28 + 110, maxH = 100;
            double slot = chartW / bars.Length, barW = 20;
            for (int i = 0; i < bars.Length; i++)
            {
                double h = maxH * bars[i] / 100.0;
                double bx = chartX + slot * i + (slot - barW) / 2;
                gfx.DrawString(bars[i].ToString(), fTiny, mutedB, new XRect(bx - 10, baseY - h - 12, barW + 20, 10), XStringFormats.TopCenter);
                gfx.DrawRectangle(indigoB, bx, baseY - h, barW, h);
                gfx.DrawString("Q" + (i + 1), fTiny, mutedB, new XRect(bx - 10, baseY + 4, barW + 20, 10), XStringFormats.TopCenter);
            }
            gfx.DrawLine(linePen, chartX, baseY, Right, baseY);
            gfx.DrawString("Scores show consistent improvement across course assessments.", fTiny, mutedB,
                new XRect(chartX, baseY + 20, chartW, 24), XStringFormats.TopLeft);

            // ---- footer (signatures)
            double fy = 760;
            gfx.DrawLine(linePen, Left, fy - 24, Right, fy - 24);
            XPen sig = new XPen(XColor.FromArgb(100, 116, 139), 0.8);
            gfx.DrawString(instructor, new XFont("Arial", 10, XFontStyleEx.Italic), inkB, new XRect(Left, fy - 10, 200, 14), XStringFormats.TopLeft);
            gfx.DrawLine(sig, Left, fy + 6, Left + 200, fy + 6);
            gfx.DrawString("Instructor signature", fTinyBold, inkB, new XRect(Left, fy + 10, 200, 12), XStringFormats.TopLeft);
            gfx.DrawString("Codercept Teacher Portal", fTiny, mutedB, new XRect(Left, fy + 23, 200, 12), XStringFormats.TopLeft);

            gfx.DrawString("28 May 2024", new XFont("Arial", 10, XFontStyleEx.Italic), inkB, new XRect(Left + 250, fy - 10, 180, 14), XStringFormats.TopLeft);
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
