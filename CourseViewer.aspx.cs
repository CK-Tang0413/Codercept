using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class CourseViewer : System.Web.UI.Page
    {
        // 1. Data Models
        public class NavSubChapter
        {
            public int Id { get; set; }
            public int ChapterId { get; set; }
            public string Title { get; set; }
            public bool IsActive { get; set; }
        }

        public class NavChapter
        {
            public int Id { get; set; }
            public string Title { get; set; }
            public string Duration { get; set; }
            public string Status { get; set; } // "completed", "pending", "locked"
            public bool IsActive { get; set; }
            public List<NavSubChapter> SubChapters { get; set; }

            // Content Configuration Flags
            public bool ShowVideo { get; set; }
            public string VideoTitle { get; set; }
            public bool ShowTheory { get; set; }
            public string TheoryHtml { get; set; }
            public bool ShowQuiz { get; set; }
            public bool ShowCode { get; set; }
            public string CodeTitle { get; set; }
            public string CodeDesc { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserType"] == null || Session["UserType"].ToString() != "Learner")
            {
                Response.Redirect("signIn.aspx");
                return;
            }

            if (!IsPostBack)
            {
                // Get Chapter ID from URL, default to 1
                int currentChapterId = 1;
                if (Request.QueryString["ch"] != null)
                {
                    int.TryParse(Request.QueryString["ch"], out currentChapterId);
                }

                LoadCourseContent(currentChapterId);
            }
        }

        private void LoadCourseContent(int activeChapterId)
        {
            var chapters = GetDummyChapters(activeChapterId);
            litTotalChapters.Text = chapters.Count.ToString();

            // Bind Sidebar
            rptSidebar.DataSource = chapters;
            rptSidebar.DataBind();

            // Find current chapter
            var currentChapter = chapters.FirstOrDefault(c => c.Id == activeChapterId);
            if (currentChapter != null)
            {
                // Bind Header
                litChNumber.Text = currentChapter.Id.ToString();
                litChDuration.Text = currentChapter.Duration;
                litChTitle.Text = currentChapter.Title;
                phCheckmark.Visible = currentChapter.Status == "completed";

                // Setup Footer Nav
                litStepIndicator.Text = $"{currentChapter.Id} / {chapters.Count}";

                if (currentChapter.Id > 1)
                {
                    lnkPrev.NavigateUrl = $"CourseViewer.aspx?ch={currentChapter.Id - 1}";
                    lnkPrev.Visible = true;
                }
                else
                {
                    lnkPrev.Visible = false;
                }

                if (currentChapter.Id < chapters.Count && chapters[currentChapter.Id].Status != "locked")
                {
                    lnkNext.NavigateUrl = $"CourseViewer.aspx?ch={currentChapter.Id + 1}";
                    lnkNext.Visible = true;
                }
                else
                {
                    lnkNext.Visible = false;
                }

                // Bind Panels
                pnlVideo.Visible = currentChapter.ShowVideo;
                if (currentChapter.ShowVideo) litVideoTitle.Text = currentChapter.VideoTitle;

                pnlTheory.Visible = currentChapter.ShowTheory;
                if (currentChapter.ShowTheory) litTheoryHtml.Text = currentChapter.TheoryHtml;

                pnlQuiz.Visible = currentChapter.ShowQuiz;

                pnlCode.Visible = currentChapter.ShowCode;
                if (currentChapter.ShowCode)
                {
                    litCodeTitle.Text = currentChapter.CodeTitle;
                    litCodeDesc.Text = currentChapter.CodeDesc;
                }
            }
        }

        // Handles placing the correct SVG icon in the sidebar based on Status
        protected void rptSidebar_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                var chapter = (NavChapter)e.Item.DataItem;
                var litStatusIcon = (Literal)e.Item.FindControl("litStatusIcon");

                if (chapter.Status == "completed")
                {
                    litStatusIcon.Text = "<svg width='12' height='12' fill='none' stroke='currentColor' viewBox='0 0 24 24'><path stroke-linecap='round' stroke-linejoin='round' stroke-width='3' d='M5 13l4 4L19 7'/></svg>";
                }
                else
                {
                    litStatusIcon.Text = chapter.Id.ToString(); // Shows number for pending/locked
                }
            }
        }

        // 3. Generate Dummy Data Configuration
        private List<NavChapter> GetDummyChapters(int activeChapterId)
        {
            return new List<NavChapter>
            {
                new NavChapter {
                    Id = 1, Title = "Introduction to Python", Duration = "45 min", Status = "completed", IsActive = (activeChapterId == 1),
                    ShowVideo = true, VideoTitle = "Python Tutorial for Beginners",
                    ShowTheory = true, TheoryHtml = "<h2>What is Python?</h2><p>Python is a high-level, interpreted programming language...</p><h2>Your First Program</h2><div class='code-block'><div class='code-header'>python<div class='code-dots'><span class='dot-g'></span><span class='dot-y'></span><span class='dot-r'></span></div></div><div class='code-body'>print(\"Hello, World!\")</div></div>",
                    ShowQuiz = false, ShowCode = false
                },
                new NavChapter {
                    Id = 2, Title = "Variables & Data Types", Duration = "60 min", Status = "completed", IsActive = (activeChapterId == 2),
                    ShowVideo = false,
                    ShowTheory = true, TheoryHtml = "<h2>Variables</h2><p>Variables are containers for storing data values. Python has no command for declaring a variable.</p>",
                    ShowQuiz = true, ShowCode = false
                },
                new NavChapter {
                    Id = 3, Title = "Control Flow — if, elif, else", Duration = "75 min", Status = "pending", IsActive = (activeChapterId == 3),
                    ShowVideo = false,
                    ShowTheory = true, TheoryHtml = "<h2>Conditions</h2><p>Python supports the usual logical conditions from mathematics...</p>",
                    ShowQuiz = false, ShowCode = true, CodeTitle = "FizzBuzz Challenge", CodeDesc = "Write a Python program that prints numbers from 1 to 20. For multiples of 3, print 'Fizz'..."
                },
                new NavChapter {
                    Id = 4, Title = "Functions", Duration = "70 min", Status = "locked", IsActive = (activeChapterId == 4)
                },
                new NavChapter {
                    Id = 5, Title = "Final Assessment", Duration = "90 min", Status = "locked", IsActive = (activeChapterId == 5)
                }
            };
        }
    }
}