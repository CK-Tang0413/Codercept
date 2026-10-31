using PdfSharp.Drawing;
using PdfSharp.Pdf;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.IO;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class Certificates : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["Codercept_db"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserType"] == null || Session["UserType"].ToString() != "Learner")
            {
                Response.Redirect("LandingPage.aspx");
                return;
            }

            if (!IsPostBack)
            {
                ProcessNewCertificates();
                LoadCertificates();
            }
        }

        // ==========================================
        // 1. BUSINESS LOGIC: GENERATE MISSING CERTS
        // ==========================================
        private void ProcessNewCertificates()
        {
            int learnerId = Convert.ToInt32(Session["UserId"]);

            using (SqlConnection con = new SqlConnection(connString))
            {
                // Find all courses where the user has a passed Exam Result, but no Certificate exists yet
                string query = @"
                    SELECT 
                        r.ResultId,
                        e.CourseId,
                        c.TeacherId,
                        t.Name as TeacherName
                    FROM Result r
                    JOIN Attempt a ON r.AttemptId = a.AttemptId
                    JOIN Exam e ON a.ExamId = e.ExamId
                    JOIN Course c ON e.CourseId = c.CourseId
                    JOIN Teacher t ON c.TeacherId = t.TeacherId
                    WHERE a.LearnerId = @LearnerId 
                      AND r.Grade IN ('A', 'B', 'C', 'D') -- Excluding 'F'
                      AND NOT EXISTS (
                          SELECT 1 FROM Certificate cert 
                          WHERE cert.LearnerId = @LearnerId AND cert.CourseId = e.CourseId
                      )";

                DataTable newCerts = new DataTable();
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    con.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        newCerts.Load(reader);
                    }
                    con.Close();
                }

                // Insert the new certificates
                if (newCerts.Rows.Count > 0)
                {
                    con.Open();
                    foreach (DataRow row in newCerts.Rows)
                    {
                        string insertQuery = "INSERT INTO Certificate (Issuer, IssueDate, LearnerId, CourseId) VALUES (@Issuer, GETDATE(), @LearnerId, @CourseId)";
                        using (SqlCommand insertCmd = new SqlCommand(insertQuery, con))
                        {
                            insertCmd.Parameters.AddWithValue("@Issuer", row["TeacherName"].ToString());
                            insertCmd.Parameters.AddWithValue("@LearnerId", learnerId);
                            insertCmd.Parameters.AddWithValue("@CourseId", row["CourseId"]);
                            insertCmd.ExecuteNonQuery();
                        }
                    }
                    con.Close();
                }
            }
        }

        // ==========================================
        // 2. FETCH EXISTING CERTS FROM DATABASE
        // ==========================================
        private void LoadCertificates()
        {
            int learnerId = Convert.ToInt32(Session["UserId"]);

            using (SqlConnection con = new SqlConnection(connString))
            {
                string query = @"
                    SELECT 
                        c.CertId, 
                        c.Issuer, 
                        c.IssueDate, 
                        crs.CourseTitle 
                    FROM [dbo].[Certificate] c
                    INNER JOIN [dbo].[Course] crs ON c.CourseId = crs.CourseId
                    WHERE c.LearnerId = @LearnerId
                    ORDER BY c.IssueDate DESC";

                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@LearnerId", learnerId);
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);

                        lblNoCerts.Visible = (dt.Rows.Count == 0);
                        rptCertificates.DataSource = dt;
                        rptCertificates.DataBind();
                    }
                }
            }
        }

        // ==========================================
        // 3. GENERATE UI IMAGE PREVIEW (Base64)
        // ==========================================
        protected string GetCertificateImageBase64(string courseName, string issueDate)
        {
            string userName = Session["UserName"].ToString();
            string imagePath = Server.MapPath("~/img/Codercept_Certificate.png");

            using (Bitmap bitmap = new Bitmap(imagePath))
            {
                using (Graphics g = Graphics.FromImage(bitmap))
                {
                    StringFormat format = new StringFormat();
                    format.Alignment = StringAlignment.Center;

                    using (Font fontName = new Font("Arial", 40, FontStyle.Bold))
                    using (Font fontCourse = new Font("Arial", 24, FontStyle.Regular))
                    using (Font fontDate = new Font("Arial", 18, FontStyle.Regular))
                    using (SolidBrush textBrush = new SolidBrush(Color.FromArgb(46, 16, 101)))
                    {
                        RectangleF rectName = new RectangleF(0, 680, bitmap.Width, 100);
                        RectangleF rectCourse = new RectangleF(0, 850, bitmap.Width, 100);
                        RectangleF rectDate = new RectangleF(0, 940, bitmap.Width, 100);

                        g.DrawString(userName, fontName, textBrush, rectName, format);
                        g.DrawString(courseName, fontCourse, textBrush, rectCourse, format);
                        g.DrawString(issueDate, fontDate, textBrush, rectDate, format);
                    }
                }

                using (MemoryStream ms = new MemoryStream())
                {
                    bitmap.Save(ms, System.Drawing.Imaging.ImageFormat.Png);
                    byte[] imageBytes = ms.ToArray();
                    return "data:image/png;base64," + Convert.ToBase64String(imageBytes);
                }
            }
        }

        // ==========================================
        // 4. GENERATE PDF DOWNLOAD (PDFsharp)
        // ==========================================
        protected void rptCertificates_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DownloadPDF")
            {
                string[] args = e.CommandArgument.ToString().Split('|');
                string courseName = args[0];
                string issueDate = args[1];
                string userName = Session["UserName"].ToString();

                PdfSharp.PdfSharpLicense.SetAgplLicense();

                PdfDocument document = new PdfDocument();
                document.Info.Title = courseName + " Certificate";
                PdfPage page = document.AddPage();
                page.Orientation = PdfSharp.PageOrientation.Landscape;

                XGraphics gfx = XGraphics.FromPdfPage(page);
                string imagePath = Server.MapPath("~/img/Codercept_Certificate.png");
                XImage image = XImage.FromFile(imagePath);
                gfx.DrawImage(image, 0, 0, page.Width, page.Height);

                XFont fontName = new XFont("Arial", 36, XFontStyleEx.Bold);
                XFont fontCourse = new XFont("Arial", 22, XFontStyleEx.Regular);
                XFont fontDate = new XFont("Arial", 16, XFontStyleEx.Regular);
                XSolidBrush textBrush = new XSolidBrush(XColor.FromArgb(46, 16, 101));

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