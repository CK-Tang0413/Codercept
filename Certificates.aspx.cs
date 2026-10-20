using PdfSharp.Drawing;
using PdfSharp.Pdf;         // Required for the PDF download
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;       // Required for generating the UI image preview
using System.IO;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class Certificates : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserType"] == null || Session["UserType"].ToString() != "Learner")
            {
                Response.Redirect("signIn.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadCertificates();
            }
        }
        private void LoadCertificates()
        {
            // ==========================================
            // TEMPORARY MOCK DATA FOR TESTING
            // ==========================================
            DataTable dt = new DataTable();
            dt.Columns.Add("CertId", typeof(string));
            dt.Columns.Add("Issuer", typeof(string));
            dt.Columns.Add("IssueDate", typeof(DateTime));
            dt.Columns.Add("CourseTitle", typeof(string));

            // Add a hardcoded row (You can add more dt.Rows.Add(...) if you want to see multiple cards!)
            dt.Rows.Add("CC-TEST-1234", "Codercept", DateTime.Now, "Python for Beginners");

            // Hide the empty state label since we are forcing data
            if (lblNoCerts != null)
            {
                lblNoCerts.Visible = (dt.Rows.Count == 0);
            }

            rptCertificates.DataSource = dt;
            rptCertificates.DataBind();
        }

        //private void LoadCertificates()
        //{
        //    int learnerId = Convert.ToInt32(Session["UserId"]);
        //    string connString = ConfigurationManager.ConnectionStrings["Codercept_db"].ConnectionString;

        //    using (SqlConnection con = new SqlConnection(connString))
        //    {
        //        // Join the Certificate table with the Course table to get the actual Course Name
        //        string query = @"
        //            SELECT c.CertId, c.Issuer, c.IssueDate, crs.CourseTitle 
        //            FROM [dbo].[Certificate] c
        //            INNER JOIN [dbo].[Course] crs ON c.CourseId = crs.CourseId
        //            WHERE c.LearnerId = @LearnerId";

        //        using (SqlCommand cmd = new SqlCommand(query, con))
        //        {
        //            cmd.Parameters.AddWithValue("@LearnerId", learnerId);
        //            using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
        //            {
        //                DataTable dt = new DataTable();
        //                sda.Fill(dt);
        //                rptCertificates.DataSource = dt;
        //                rptCertificates.DataBind();
        //            }
        //        }
        //    }
        //}

        // ==========================================
        // 1. GENERATE UI IMAGE PREVIEW (Base64)
        // ==========================================
        protected string GetCertificateImageBase64(string courseName, string issueDate)
        {
            string userName = Session["UserName"].ToString();

            string imagePath = Server.MapPath("~/img/Codercept_Certificate.png");

            using (Bitmap bitmap = new Bitmap(imagePath))
            {
                using (Graphics g = Graphics.FromImage(bitmap))
                {
                    // Define formatting to center the text
                    StringFormat format = new StringFormat();
                    format.Alignment = StringAlignment.Center;

                    // Note: This uses standard System.Drawing.FontStyle
                    using (Font fontName = new Font("Arial", 40, FontStyle.Bold))
                    using (Font fontCourse = new Font("Arial", 24, FontStyle.Regular))
                    using (Font fontDate = new Font("Arial", 18, FontStyle.Regular))
                    using (SolidBrush textBrush = new SolidBrush(Color.FromArgb(46, 16, 101)))
                    {
                        // Draw the text (Adjust the Y coordinates: 350, 520, 650 based on your image dimensions)
                        RectangleF rectName = new RectangleF(0, 680, bitmap.Width, 100);
                        RectangleF rectCourse = new RectangleF(0, 850, bitmap.Width, 100);
                        RectangleF rectDate = new RectangleF(0, 940, bitmap.Width, 100);

                        g.DrawString(userName, fontName, textBrush, rectName, format);
                        g.DrawString(courseName, fontCourse, textBrush, rectCourse, format);
                        g.DrawString(issueDate, fontDate, textBrush, rectDate, format);
                    }
                }

                // Convert the modified image into a Base64 string for the HTML <img> tag
                using (MemoryStream ms = new MemoryStream())
                {
                    bitmap.Save(ms, System.Drawing.Imaging.ImageFormat.Png);
                    byte[] imageBytes = ms.ToArray();
                    return "data:image/png;base64," + Convert.ToBase64String(imageBytes);
                }
            }
        }

        // ==========================================
        // 2. GENERATE PDF DOWNLOAD (PDFsharp)
        // ==========================================
        protected void rptCertificates_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DownloadPDF")
            {
                // Retrieve the specific course data passed from the clicked button
                string[] args = e.CommandArgument.ToString().Split('|');
                string courseName = args[0];
                string issueDate = args[1];
                string userName = Session["UserName"].ToString();

                // Declare the free open-source license to unlock PDFsharp
                PdfSharp.PdfSharpLicense.SetAgplLicense();

                PdfDocument document = new PdfDocument();
                document.Info.Title = courseName + " Certificate";
                PdfPage page = document.AddPage();
                page.Orientation = PdfSharp.PageOrientation.Landscape;

                XGraphics gfx = XGraphics.FromPdfPage(page);
                string imagePath = Server.MapPath("~/img/Codercept_Certificate.png");
                XImage image = XImage.FromFile(imagePath);
                gfx.DrawImage(image, 0, 0, page.Width, page.Height);

                // Note: This correctly uses the new XFontStyleEx for PDFsharp v6
                XFont fontName = new XFont("Arial", 36, XFontStyleEx.Bold);
                XFont fontCourse = new XFont("Arial", 22, XFontStyleEx.Regular);
                XFont fontDate = new XFont("Arial", 16, XFontStyleEx.Regular);
                XSolidBrush textBrush = new XSolidBrush(XColor.FromArgb(46, 16, 101));

                // Adjust these Y values (230, 340, 420) to match your template
                XRect rectName = new XRect(0, 275, page.Width, 50);
                XRect rectCourse = new XRect(0, 350, page.Width, 50);
                XRect rectDate = new XRect(0, 390, page.Width, 50);

                gfx.DrawString(userName, fontName, textBrush, rectName, XStringFormats.Center);
                gfx.DrawString(courseName, fontCourse, textBrush, rectCourse, XStringFormats.Center);
                gfx.DrawString(issueDate, fontDate, textBrush, rectDate, XStringFormats.Center);

                using (MemoryStream stream = new MemoryStream())
                {
                    document.Save(stream, false);
                    Response.Clear();
                    Response.ContentType = "application/pdf";
                    Response.AddHeader("content-length", stream.Length.ToString());
                    Response.AddHeader("content-disposition", $"attachment; filename=\"{courseName.Replace(" ", "_")}_Certificate.pdf\"");
                    Response.BinaryWrite(stream.ToArray());
                    Response.Flush();
                    Response.End();
                }
            }
        }
    }
}