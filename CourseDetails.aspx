<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CourseDetails.aspx.cs" Inherits="Codercept.CourseDetails" %>
<%@ Register Src="~/LearnerSideBar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Course Details - Codercept</title>

    <!-- 1. Import Global Variables & Shared Layout -->
    <link href="css/global.css" rel="stylesheet" type="text/css" />

    <!-- 2. Page-Specific Styles -->
    <style>
        :root {
            /* Local variables for Course Details */
            --hero-bg: var(--bg-surface);
            --hero-border: var(--border-light);
            
            /* Chapter List Variables */
            --chapter-bg: var(--bg-surface);
            --chapter-border: var(--border-light);
            --chapter-hover: rgba(255, 255, 255, 0.02);
            --icon-completed-bg: rgba(74, 222, 128, 0.2);
            --icon-completed-color: #4ade80;
            --icon-locked-bg: rgba(255, 255, 255, 0.05);
            --icon-locked-color: var(--text-muted);
            
            /* Tag Colors */
            --tag-theory: rgba(96, 165, 250, 0.15);
            --tag-theory-text: #60a5fa;
            --tag-video: rgba(251, 146, 60, 0.15);
            --tag-video-text: #fb923c;
            --tag-quiz: rgba(74, 222, 128, 0.15);
            --tag-quiz-text: #4ade80;
            --tag-coding: rgba(192, 132, 252, 0.15);
            --tag-coding-text: #c084fc;
        }

        /* Top Navigation */
        .back-nav {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            color: var(--text-secondary);
            text-decoration: none;
            font-size: 0.95rem;
            margin-bottom: 1.5rem;
            transition: color 0.2s;
        }
        .back-nav:hover { color: var(--text-primary); }
        .back-nav svg { width: 18px; height: 18px; }

        /* Hero Section */
        .course-hero {
            background: var(--hero-bg);
            border: 1px solid var(--hero-border);
            border-radius: 12px;
            padding: 2.5rem;
            margin-bottom: 2.5rem;
        }

        .hero-tags { display: flex; gap: 0.75rem; margin-bottom: 1.25rem; }
        .badge { 
            padding: 0.3rem 0.8rem; 
            border-radius: 6px; 
            font-size: 0.8rem; 
            font-weight: 600; 
            border: 1px solid transparent; 
        }
        .badge-lang { background: rgba(96, 165, 250, 0.1); color: #60a5fa; border-color: rgba(96, 165, 250, 0.3); }
        .badge-level { background: rgba(74, 222, 128, 0.1); color: #4ade80; border-color: rgba(74, 222, 128, 0.3); }
        .badge-featured { background: rgba(251, 191, 36, 0.1); color: #fbbf24; border-color: rgba(251, 191, 36, 0.3); }

        .course-hero h1 { font-size: 2.25rem; color: var(--text-primary); margin-bottom: 0.75rem; }
        .course-hero p { font-size: 1.05rem; color: var(--text-secondary); line-height: 1.6; margin-bottom: 1.5rem; max-width: 900px; }

        .hero-meta { 
            display: flex; 
            flex-wrap: wrap;
            gap: 1.5rem; 
            font-size: 0.9rem; 
            color: var(--text-muted); 
            margin-bottom: 2rem; 
        }
        .hero-meta span { display: flex; align-items: center; gap: 0.4rem; }

        /* Progress Area (For Enrolled Users) */
        .progress-section { margin-bottom: 1.5rem; }
        .progress-header { display: flex; justify-content: space-between; font-size: 0.9rem; color: var(--text-secondary); margin-bottom: 0.5rem; }
        .progress-header strong { color: var(--text-primary); }
        .progress-bar-bg { width: 100%; height: 6px; background: rgba(255, 255, 255, 0.1); border-radius: 3px; overflow: hidden; }
        .progress-bar-fill { height: 100%; background: var(--accent-primary); border-radius: 3px; }

        .btn-action { 
            display: inline-block; 
            background: var(--accent-primary); 
            color: white; 
            padding: 0.875rem 2rem; 
            border-radius: 8px; 
            font-weight: 600; 
            font-size: 1rem; 
            text-decoration: none; 
            border: none; 
            cursor: pointer; 
            transition: background 0.2s; 
        }
        .btn-action:hover { background: var(--accent-hover); }

        /* Chapter Section */
        .section-title { font-size: 1.25rem; font-weight: 600; color: var(--text-primary); margin-bottom: 1.25rem; }

        .chapter-list { display: flex; flex-direction: column; gap: 0.75rem; }
        
        .chapter-item { 
            display: flex; 
            align-items: center; 
            background: var(--chapter-bg); 
            border: 1px solid var(--chapter-border); 
            border-radius: 12px; 
            padding: 1.25rem 1.5rem; 
            transition: background 0.2s; 
            text-decoration: none;
        }
        .chapter-item:hover { background: var(--chapter-hover); }

        /* Status Icon */
        .ch-status { 
            width: 32px; 
            height: 32px; 
            border-radius: 50%; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            font-size: 0.85rem; 
            font-weight: 600; 
            margin-right: 1.25rem; 
            flex-shrink: 0;
        }
        .ch-status.completed { background: var(--icon-completed-bg); color: var(--icon-completed-color); }
        .ch-status.locked { background: var(--icon-locked-bg); color: var(--icon-locked-color); }

        /* Chapter Details */
        .ch-content { flex: 1; }
        .ch-title { font-size: 1.05rem; font-weight: 600; color: var(--text-primary); margin-bottom: 0.4rem; }
        
        .ch-tags { display: flex; gap: 0.5rem; }
        .c-tag { display: flex; align-items: center; gap: 0.3rem; padding: 0.2rem 0.5rem; border-radius: 4px; font-size: 0.75rem; font-weight: 600; }
        .c-tag.theory { background: var(--tag-theory); color: var(--tag-theory-text); }
        .c-tag.video { background: var(--tag-video); color: var(--tag-video-text); }
        .c-tag.quiz { background: var(--tag-quiz); color: var(--tag-quiz-text); }
        .c-tag.coding { background: var(--tag-coding); color: var(--tag-coding-text); }

        /* Chapter Meta */
        .ch-meta { display: flex; align-items: center; gap: 1rem; color: var(--text-muted); font-size: 0.85rem; }
        .ch-icon { width: 16px; height: 16px; }

        @media (max-width: 768px) {
            .course-hero { padding: 1.5rem; }
            .chapter-item { flex-direction: column; align-items: flex-start; gap: 1rem; }
            .ch-meta { width: 100%; justify-content: space-between; margin-top: 0.5rem; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="dashboard-layout">
            
            <!-- Sidebar Injected Here -->
            <uc:Sidebar runat="server" ID="LearnerSideBarCtrl" />

            <!-- Main Content -->
            <main class="main-content">
    
                <a href="CourseCatalog.aspx" onclick="history.back(); return false;" class="back-nav">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                    </svg>
                    Back
                </a>

                <!-- Hero Section -->
                <div class="course-hero">
                    <div class="hero-tags">
                        <asp:Literal ID="litTags" runat="server"></asp:Literal>
                    </div>

                    <h1><asp:Literal ID="litTitle" runat="server"></asp:Literal></h1>
                    <p><asp:Literal ID="litDescription" runat="server"></asp:Literal></p>
        
                    <div class="hero-meta">
                        <span>👨‍🏫 <asp:Literal ID="litInstructor" runat="server"></asp:Literal></span>
                        <span>📖 <asp:Literal ID="litChapterCount" runat="server"></asp:Literal></span>
                        <span>⏱️ <asp:Literal ID="litDuration" runat="server"></asp:Literal></span>
                        <span>👥 <asp:Literal ID="litEnrolledCount" runat="server"></asp:Literal> enrolled</span>
                        <span>⭐ <asp:Literal ID="litRating" runat="server"></asp:Literal></span>
                    </div>

                    <!-- Progress Area (For Enrolled Users) -->
                    <asp:Panel ID="pnlEnrolledProgress" runat="server" CssClass="progress-section">
                        <div class="progress-header">
                            <span>Your progress</span>
                            <strong><asp:Literal ID="litProgressText" runat="server"></asp:Literal></strong>
                        </div>
                        <div class="progress-bar-bg">
                            <asp:Panel ID="pnlProgressBarFill" runat="server" CssClass="progress-bar-fill"></asp:Panel>
                        </div>
                    </asp:Panel>

                    <!-- Main Call to Action Button & Review Actions -->
                    <div style="display: flex; gap: 1rem; align-items: center;">
                        <asp:Button ID="btnCourseAction" runat="server" CssClass="btn-action" OnClick="btnCourseAction_Click" />
                        <asp:Button ID="btnShowReviewModal" runat="server" Text="Leave a Review" CssClass="btn-nav" style="padding: 0.875rem 1.5rem; border: 1px solid var(--border-light); border-radius: 8px; font-weight: 600; cursor: pointer;" OnClick="btnShowReviewModal_Click" Visible="false" />
                        <asp:Label ID="lblReviewSubmitted" runat="server" Visible="false" style="color: var(--icon-success); font-size: 0.9rem; font-weight: 600;">⭐ Review Submitted</asp:Label>
                    </div>

                    <!-- Review Modal -->
                    <asp:Panel ID="pnlReviewModal" runat="server" Visible="false" style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); z-index: 9999; backdrop-filter: blur(5px); display: flex; justify-content: center; align-items: center;">
                        <div style="background: var(--bg-surface); border: 1px solid var(--border-light); padding: 2.5rem; border-radius: 12px; max-width: 500px; width: 90%; box-shadow: 0 10px 25px rgba(0,0,0,0.5);">
                            <h3 style="margin-bottom: 0.5rem; color: var(--text-primary); font-size: 1.5rem;">Rate this course</h3>
                            <p style="margin-bottom: 1.5rem; color: var(--text-secondary); font-size: 0.95rem;">How was your experience learning <asp:Literal ID="litReviewCourseTitle" runat="server"></asp:Literal>?</p>
                            
                            <div style="margin-bottom: 1.5rem;">
                                <label style="display: block; margin-bottom: 0.5rem; font-size: 0.9rem; font-weight: 600; color: var(--text-primary);">Rating (Out of 5)</label>
                                <asp:DropDownList ID="ddlRating" runat="server" style="width: 100%; background: var(--bg-main); border: 1px solid var(--border-light); padding: 0.75rem; border-radius: 8px; color: var(--text-primary); font-size: 1rem; outline: none;">
                                    <asp:ListItem Value="5" Text="⭐⭐⭐⭐⭐ Excellent (5.0)"></asp:ListItem>
                                    <asp:ListItem Value="4" Text="⭐⭐⭐⭐ Good (4.0)"></asp:ListItem>
                                    <asp:ListItem Value="3" Text="⭐⭐⭐ Average (3.0)"></asp:ListItem>
                                    <asp:ListItem Value="2" Text="⭐⭐ Fair (2.0)"></asp:ListItem>
                                    <asp:ListItem Value="1" Text="⭐ Poor (1.0)"></asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div style="margin-bottom: 2rem;">
                                <label style="display: block; margin-bottom: 0.5rem; font-size: 0.9rem; font-weight: 600; color: var(--text-primary);">Feedback (Optional)</label>
                                <asp:TextBox ID="txtFeedback" runat="server" TextMode="MultiLine" placeholder="What did you like? What could be improved?" style="width: 100%; min-height: 100px; background: var(--bg-main); border: 1px solid var(--border-light); padding: 0.75rem; border-radius: 8px; color: var(--text-primary); font-family: inherit; font-size: 0.95rem; resize: vertical; outline: none;"></asp:TextBox>
                            </div>

                            <div style="display: flex; gap: 1rem; justify-content: flex-end;">
                                <asp:Button ID="btnCancelReview" runat="server" Text="Cancel" OnClick="btnCancelReview_Click" style="padding: 0.75rem 1.5rem; background: transparent; border: 1px solid var(--border-light); color: var(--text-secondary); border-radius: 8px; font-weight: 600; cursor: pointer; transition: all 0.2s;" />
                                <asp:Button ID="btnSubmitReview" runat="server" Text="Submit Review" OnClick="btnSubmitReview_Click" style="padding: 0.75rem 1.5rem; background: var(--accent-primary); color: white; border: none; border-radius: 8px; font-weight: 600; cursor: pointer; transition: background 0.2s;" />
                            </div>
                        </div>
                    </asp:Panel>
                </div>

                <h2 class="section-title">Course Chapters</h2>

                <!-- Chapters List using Repeater -->
                <div class="chapter-list">
                    <asp:Repeater ID="rptChapters" runat="server">
                        <ItemTemplate>

                            <a href='<%# GetChapterUrl((string)Eval("Status"), Convert.ToInt32(Eval("ChapterNum"))) %>' class="chapter-item" style='<%# GetChapterStyle((string)Eval("Status")) %>'>

                                <!-- Dynamic Status Icon (Checkmark, Play, Lock, or Number) -->
                                <div class='ch-status <%# Eval("Status").ToString().ToLower() %>' style='<%# Eval("Status").ToString() == "Active" ? "background: rgba(124, 58, 237, 0.2); color: #c084fc;" : "" %>'>
                                    <asp:Literal runat="server" Text='<%# GetStatusIcon((string)Eval("Status"), Convert.ToInt32(Eval("ChapterNum"))) %>'></asp:Literal>
                                </div>

                                <div class="ch-content">
                                    <div class="ch-title"><%# Eval("ChapterTitle") %></div>
                                    <div class="ch-tags">
                                        <!-- Inline conditional rendering for the badges -->
                                        <span class="c-tag theory" style="display: <%# Convert.ToInt32(Eval("SubChapterCount")) > 0 ? "inline-flex" : "none" %>;">📄 Theory</span>
                                        <span class="c-tag video" style="display: <%# Convert.ToBoolean(Eval("HasVideo")) ? "inline-flex" : "none" %>;">▶️ Video</span>
                                        <span class="c-tag quiz" style="display: <%# Convert.ToBoolean(Eval("HasQuiz")) ? "inline-flex" : "none" %>;">⚡ Quiz</span>
                                        <span class="c-tag coding" style="display: <%# Convert.ToBoolean(Eval("HasAssessment")) ? "inline-flex" : "none" %>;">💻 Coding</span>
                                        <span class="c-tag theory" style="display: <%# Convert.ToBoolean(Eval("HasExam")) ? "inline-flex" : "none" %>; background: rgba(239, 68, 68, 0.15); color: #ef4444;">🎓 Final Exam</span>
                                    </div>
                                </div>

                                <div class="ch-meta">
                                    <span><%# Eval("ChapterDuration") %></span>
                                    <asp:Literal runat="server" Text='<%# GetActionIcon((string)Eval("Status")) %>'></asp:Literal>
                                </div>

                            </a>

                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </main>
        </div>
    </form>

    <!-- Guest Registration Modal -->
    <div id="guestModalOverlay" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); z-index: 9999; backdrop-filter: blur(5px); justify-content: center; align-items: center;">
        <div style="background: white; padding: 2rem; border-radius: 12px; max-width: 400px; text-align: center; box-shadow: 0 10px 25px rgba(0,0,0,0.2); width: 90%;">
        
            <h3 style="margin-bottom: 1rem; color: #18181b; font-size: 1.5rem;">Registration Required</h3>
            <p style="margin-bottom: 2rem; color: #71717a; font-size: 0.95rem; line-height: 1.5;">
                You need a free account to view topic details and enroll in courses. Ready to start your learning journey?
            </p>
        
            <div style="display: flex; gap: 1rem; justify-content: center;">
                <button type="button" onclick="hideGuestModal()" style="padding: 0.75rem 1.5rem; border: 1px solid #e4e4e7; background: transparent; border-radius: 8px; cursor: pointer; color: #71717a; font-weight: 600; flex: 1; transition: background 0.2s;">
                    Cancel
                </button>
                <a href="signUp.aspx" style="padding: 0.75rem 1.5rem; background: #7c3aed; color: white; border-radius: 8px; text-decoration: none; font-weight: 600; flex: 1; transition: background 0.2s; display: inline-block;">
                    Register Now
                </a>
            </div>

        </div>
    </div>

    <script type="text/javascript">
        function showGuestModal() {
            var overlay = document.getElementById('guestModalOverlay');
            if (overlay) {
                overlay.style.display = 'flex';
            }
        }

        function hideGuestModal() {
            var overlay = document.getElementById('guestModalOverlay');
            if (overlay) {
                overlay.style.display = 'none';
            }
        }
    </script>

</body>
</html>