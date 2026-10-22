using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class TAForumModeration : System.Web.UI.Page
    {
        // 1. Define Dummy Data Structures
        public class DummyPost
        {
            public int PostId { get; set; }
            public string Title { get; set; }
            public string Content { get; set; }
            public string Author { get; set; }
            public string Posted { get; set; }
            public string Flag { get; set; }
            public string FlagCss { get; set; }
            public string ReportReason { get; set; }
            public int ReplyCount { get; set; }
            public string EscalationNote { get; set; }
            public string CssClass { get; set; }
        }

        public class DummyReply
        {
            public int ThreadId { get; set; }
            public string Author { get; set; }
            public string Role { get; set; }
            public string RoleCss { get; set; }
            public string Content { get; set; }
            public string Posted { get; set; }
            public bool IsPinned { get; set; }
            public string CssClass { get; set; }
        }

        protected string CurrentFilter { get; private set; } = "all";

        protected void Page_Load(object sender, EventArgs e)
        {
            // Security Check
            if (Session["UserType"] == null || Session["UserType"].ToString() != "TA")
            {
                Response.Redirect("signIn.aspx");
                return;
            }

            string filter = (Request.QueryString["filter"] ?? "all").ToLower();
            CurrentFilter = (filter == "reported" || filter == "unanswered" || filter == "escalated") ? filter : "all";

            if (!IsPostBack)
            {
                LoadForumData();
            }
        }

        protected string GetTabClass(string tab)
        {
            return tab == CurrentFilter ? "active" : "";
        }

        private void LoadForumData()
        {
            // 2. Generate Dummy Data
            var all = new List<DummyPost>
            {
                new DummyPost { PostId = 11, Title = "Why does my for loop never terminate?", Author = "Alex Chen", Posted = "1 hour ago", Flag = "Unanswered", FlagCss = "flag-unanswered", ReplyCount = 0,
                    Content = "I wrote a while loop in Python but it runs forever.\n\ni = 0\nwhile i < 10:\n    print(i)\n\nWhat am I missing?" },
                new DummyPost { PostId = 12, Title = "Selling exam answers - DM me", Author = "Anonymous99", Posted = "3 hours ago", Flag = "Reported", FlagCss = "flag-reported", ReplyCount = 1,
                    ReportReason = "Academic dishonesty (reported by 3 learners)",
                    Content = "I have the answers for the Java final exam. Message me for a price." },
                new DummyPost { PostId = 13, Title = "Difference between == and equals()?", Author = "Mei Ling", Posted = "Yesterday", Flag = "Escalated", FlagCss = "flag-escalated", ReplyCount = 0,
                    EscalationNote = "Learner asks about string comparison internals (string pool). Needs the teacher to confirm what the course expects.",
                    Content = "In Java, when should I use == and when should I use equals() for comparing strings?" },
                new DummyPost { PostId = 14, Title = "This course is useless", Author = "Daniel Tan", Posted = "Yesterday", Flag = "Reported", FlagCss = "flag-reported", ReplyCount = 2,
                    ReportReason = "Abusive language (reported by 1 learner)",
                    Content = "Waste of time. The teacher can't even explain pointers properly." },
                new DummyPost { PostId = 15, Title = "Best resources for learning Flexbox?", Author = "Ravi Kumar", Posted = "2 days ago", Flag = "Answered", FlagCss = "flag-ok", ReplyCount = 3,
                    Content = "Can anyone recommend good practice sites for CSS Flexbox?" }
            };

            // 3. Tab counts (always computed over the full list)
            litCountAll.Text = $" ({all.Count})";
            litCountReported.Text = $" ({all.Count(p => p.Flag == "Reported")})";
            litCountUnanswered.Text = $" ({all.Count(p => p.Flag == "Unanswered")})";
            litCountEscalated.Text = $" ({all.Count(p => p.Flag == "Escalated")})";

            // 4. Apply the active filter
            List<DummyPost> filtered;
            if (CurrentFilter == "reported") filtered = all.Where(p => p.Flag == "Reported").ToList();
            else if (CurrentFilter == "unanswered") filtered = all.Where(p => p.Flag == "Unanswered").ToList();
            else if (CurrentFilter == "escalated") filtered = all.Where(p => p.Flag == "Escalated").ToList();
            else filtered = all;

            int.TryParse(Request.QueryString["post"], out int postId);
            var selected = filtered.FirstOrDefault(p => p.PostId == postId) ?? filtered.FirstOrDefault();
            if (selected != null) selected.CssClass = "selected";

            phListEmpty.Visible = filtered.Count == 0;
            rptPosts.DataSource = filtered;
            rptPosts.DataBind();

            // 5. Bind the thread panel for the selected post
            if (selected == null)
            {
                phThread.Visible = false;
                phNoSelection.Visible = true;
                return;
            }

            litPostTitle.Text = Server.HtmlEncode(selected.Title);
            litPostAuthor.Text = Server.HtmlEncode(selected.Author);
            litPostTime.Text = selected.Posted;
            litPostContent.Text = Server.HtmlEncode(selected.Content);

            bool isReported = selected.Flag == "Reported";
            pnlModeration.CssClass = isReported ? "mod-card reported" : "mod-card";
            pnlReportInfo.Visible = isReported;
            btnDismissReport.Visible = isReported;
            litReportReason.Text = Server.HtmlEncode(selected.ReportReason ?? "");

            bool isEscalated = selected.Flag == "Escalated";
            pnlAskTeacher.Visible = !isEscalated;
            pnlEscalated.Visible = isEscalated;
            litEscalationNote.Text = Server.HtmlEncode(selected.EscalationNote ?? "");

            var replies = BuildReplies(selected);
            litReplyCount.Text = $"{replies.Count} repl{(replies.Count == 1 ? "y" : "ies")}";
            rptReplies.DataSource = replies;
            rptReplies.DataBind();
        }

        private List<DummyReply> BuildReplies(DummyPost post)
        {
            var replies = new List<DummyReply>();

            if (post.ReplyCount >= 1)
                replies.Add(new DummyReply { ThreadId = 1, Author = "Dr. Lim", Role = "Teacher", RoleCss = "role-teacher", Posted = "2 hours ago", IsPinned = true, CssClass = "pinned",
                    Content = "Please keep discussions on topic and follow the community guidelines." });
            if (post.ReplyCount >= 2)
                replies.Add(new DummyReply { ThreadId = 2, Author = "Kylan Shane Sedrick", Role = "Learner", RoleCss = "role-learner", Posted = "1 hour ago", IsPinned = false, CssClass = "",
                    Content = "I agree, this shouldn't be allowed here." });
            if (post.ReplyCount >= 3)
                replies.Add(new DummyReply { ThreadId = 3, Author = "Wan Hon Kit", Role = "Learner", RoleCss = "role-learner", Posted = "45 minutes ago", IsPinned = false, CssClass = "",
                    Content = "freeCodeCamp and Flexbox Froggy are both great for practice." });

            return replies;
        }

        protected void btnDismissReport_Click(object sender, EventArgs e)
        {
            // We will implement this later
            ShowMessage("Report dismissed. (Preview only — saving will be implemented with the backend.)");
        }

        protected void btnRemovePost_Click(object sender, EventArgs e)
        {
            // We will implement this later
            if (string.IsNullOrWhiteSpace(txtModReason.Text))
            {
                ShowMessage("Please enter a moderation note before removing a post.");
                return;
            }
            ShowMessage("Post removed. (Preview only — saving will be implemented with the backend.)");
        }

        protected void btnAskTeacher_Click(object sender, EventArgs e)
        {
            // We will implement this later
            if (string.IsNullOrWhiteSpace(txtTeacherNote.Text))
            {
                ShowMessage("Please describe what you need the teacher to look at.");
                return;
            }
            txtTeacherNote.Text = "";
            ShowMessage("Escalated to the teacher. (Preview only — saving will be implemented with the backend.)");
        }

        protected void btnReply_Click(object sender, EventArgs e)
        {
            // We will implement this later
            if (string.IsNullOrWhiteSpace(txtReply.Text))
            {
                ShowMessage("Reply cannot be empty.");
                return;
            }
            txtReply.Text = "";
            ShowMessage("Reply posted. (Preview only — saving will be implemented with the backend.)");
        }

        protected void rptReplies_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            // We will implement this later
            if (e.CommandName == "Pin")
                ShowMessage("Pin toggled. (Preview only — saving will be implemented with the backend.)");
            else if (e.CommandName == "Delete")
                ShowMessage("Reply deleted. (Preview only — saving will be implemented with the backend.)");
        }

        private void ShowMessage(string message)
        {
            litMessage.Text = message;
            pnlMessage.Visible = true;
        }
    }
}
