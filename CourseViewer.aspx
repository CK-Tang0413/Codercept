<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CourseViewer.aspx.cs" Inherits="Codercept.CourseViewer" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Course Viewer - Codercept</title>

    <!-- 1. Import Global Variables & Shared Layout -->
    <link href="css/global.css" rel="stylesheet" type="text/css" />

    <!-- 2. Page-Specific Styles -->
    <style>
        :root {
            /* Local variables for Course Viewer */
            --viewer-sidebar-width: 320px;
            --item-active-bg: rgba(124, 58, 237, 0.1);
            --item-active-border: var(--accent-primary);
            --icon-success: #4ade80;
            --code-bg: #1e1e1e;
            --content-max-width: 900px;
        }

        /* Override Layout for Viewer (Custom Sidebar) */
        .viewer-layout { 
            display: flex; 
            height: 100vh; 
            width: 100%; 
            background: var(--bg-main);
        }

        /* Course Navigation Sidebar */
        .course-sidebar {
            width: var(--viewer-sidebar-width);
            background: var(--bg-surface);
            border-right: 1px solid var(--border-light);
            display: flex;
            flex-direction: column;
            flex-shrink: 0;
            overflow-y: auto;
        }

        .sidebar-header {
            padding: 1.5rem;
            border-bottom: 1px solid var(--border-light);
            position: sticky;
            top: 0;
            background: var(--bg-surface);
            z-index: 10;
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            color: var(--text-secondary);
            text-decoration: none;
            font-size: 0.9rem;
            margin-bottom: 1rem;
            transition: color 0.2s;
        }
        .back-link:hover { color: var(--text-primary); }
        .back-link svg { width: 16px; height: 16px; }

        .course-title-side { font-size: 1.15rem; font-weight: 600; color: var(--text-primary); margin-bottom: 0.25rem; }
        .course-meta-side { font-size: 0.85rem; color: var(--text-muted); }

        /* Chapter Navigation Items */
        .nav-chapter {
            display: flex;
            align-items: flex-start;
            padding: 1.25rem 1.5rem;
            border-left: 3px solid transparent;
            border-bottom: 1px solid var(--border-light);
            cursor: pointer;
            text-decoration: none;
            transition: all 0.2s;
        }
        .nav-chapter:hover { background: rgba(255, 255, 255, 0.02); }
        .nav-chapter.active {
            background: var(--item-active-bg);
            border-left-color: var(--item-active-border);
        }

        .nav-status {
            width: 20px;
            height: 20px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 1rem;
            margin-top: 0.1rem;
            flex-shrink: 0;
            font-size: 0.7rem;
            font-weight: 700;
        }
        .nav-status.completed { background: var(--icon-success); color: var(--bg-main); }
        .nav-status.pending { background: var(--border-light); color: var(--text-secondary); }
        .nav-status.locked { background: transparent; color: var(--text-muted); }

        .nav-details { flex: 1; }
        .nav-title { font-size: 0.95rem; font-weight: 600; color: var(--text-primary); margin-bottom: 0.25rem; line-height: 1.4; }
        .nav-time { font-size: 0.8rem; color: var(--text-muted); }

        /* Main Content Area */
        .viewer-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden; 
        }

        .content-wrapper {
            flex: 1;
            overflow-y: auto;
        }

        .content-scrollable {
            padding: 2.5rem 3rem 4rem 3rem;
            max-width: var(--content-max-width);
            margin: 0 auto;
            width: 100%;
        }

        /* Content Header */
        .content-header { margin-bottom: 2.5rem; }
        .ch-label { font-size: 0.9rem; color: var(--text-muted); margin-bottom: 0.5rem; display: block; }
        .ch-main-title { 
            font-size: 2rem; 
            color: var(--text-primary); 
            display: flex; 
            align-items: center; 
            gap: 1rem; 
        }
        .icon-check { color: var(--icon-success); width: 24px; height: 24px; }

        /* Section Dividers */
        .section-divider {
            border-top: 1px solid var(--border-light);
            margin: 3rem 0;
            padding-top: 1.5rem;
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: var(--accent-light);
            font-weight: 600;
        }

        /* Video Section */
        .video-container {
            background: var(--bg-surface);
            border-radius: 12px;
            aspect-ratio: 16/9;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            border: 1px solid var(--border-light);
            margin-bottom: 2rem;
            cursor: pointer;
            transition: border-color 0.2s;
        }
        .video-container:hover { border-color: var(--accent-primary); }
        .play-btn {
            width: 64px;
            height: 64px;
            background: rgba(124, 58, 237, 0.2);
            border: 2px solid var(--accent-primary);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--accent-light);
            margin-bottom: 1rem;
            transition: all 0.2s;
        }
        .video-container:hover .play-btn { transform: scale(1.1); background: var(--accent-primary); color: white; }

        /* Theory Content */
        .theory-content h2 { font-size: 1.5rem; color: var(--text-primary); margin: 2rem 0 1rem 0; }
        .theory-content p { font-size: 1rem; color: var(--text-secondary); line-height: 1.7; margin-bottom: 1rem; }
        .theory-content ul { padding-left: 1.5rem; margin-bottom: 1.5rem; }
        .theory-content li { font-size: 1rem; color: var(--text-secondary); line-height: 1.7; margin-bottom: 0.5rem; }
        
        .code-block {
            background: var(--code-bg);
            border-radius: 8px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            overflow: hidden;
            margin: 1.5rem 0;
        }
        .code-header {
            background: rgba(0, 0, 0, 0.3);
            padding: 0.5rem 1rem;
            font-size: 0.8rem;
            color: var(--text-muted);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .code-dots span { display: inline-block; width: 10px; height: 10px; border-radius: 50%; margin-left: 4px; }
        .dot-r { background: #ef4444; } .dot-y { background: #fbbf24; } .dot-g { background: #4ade80; }
        .code-body { padding: 1rem; font-family: monospace; font-size: 0.95rem; color: #e4e4e7; line-height: 1.5; white-space: pre-wrap; }
        .code-comment { color: #a1a1aa; }

        /* Quiz / Assessment Section */
        .quiz-question {
            background: var(--bg-surface);
            border: 1px solid var(--border-light);
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
        }
        .q-title { font-size: 1.05rem; font-weight: 600; color: var(--text-primary); margin-bottom: 1.25rem; }
        .q-option {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: 1rem;
            border: 1px solid var(--border-light);
            border-radius: 8px;
            margin-bottom: 0.75rem;
            cursor: pointer;
            transition: all 0.2s;
        }
        .q-option:hover { background: rgba(255, 255, 255, 0.02); border-color: rgba(255, 255, 255, 0.2); }
        .q-radio { width: 18px; height: 18px; border: 2px solid var(--text-muted); border-radius: 50%; }

        /* Coding Challenge Section */
        .challenge-box {
            background: rgba(124, 58, 237, 0.05);
            border: 1px solid var(--accent-border);
            border-radius: 12px;
            padding: 1.5rem;
            margin-bottom: 1.5rem;
        }
        .challenge-box p { color: var(--text-secondary); font-size: 0.95rem; margin-top: 0.5rem; line-height: 1.6; }
        .ide-placeholder {
            background: #000000;
            border-radius: 8px;
            min-height: 250px;
            border: 1px solid var(--border-light);
            margin-bottom: 1.5rem;
            display: flex;
            flex-direction: column;
        }

        /* Fixed Footer Navigation */
        .viewer-footer {
            flex-shrink: 0; 
            width: 100%;
            background: var(--bg-surface);
            border-top: 1px solid var(--border-light);
            padding: 1rem 3rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            z-index: 10;
        }
        .btn-nav {
            background: transparent;
            color: var(--text-secondary);
            border: none;
            font-size: 0.95rem;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            text-decoration: none;
            transition: color 0.2s;
        }
        .btn-nav:hover { color: var(--text-primary); }
        .btn-nav.primary { color: var(--accent-light); }
        .btn-nav.primary:hover { color: var(--accent-hover); }
        .step-indicator { font-size: 0.85rem; color: var(--text-muted); }

        @media (max-width: 992px) {
            .viewer-layout { flex-direction: column; }
            .course-sidebar { width: 100%; height: auto; max-height: 300px; border-right: none; border-bottom: 1px solid var(--border-light); }
            .content-scrollable { padding: 1.5rem; }
            .viewer-footer { padding: 1rem 1.5rem; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="viewer-layout">
            
            <!-- Left Panel: Custom Course Navigation Sidebar -->
            <aside class="course-sidebar">
                <div class="sidebar-header">
                    <a href="CourseCatalog.aspx" class="back-link">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                        </svg>
                        Back to course
                    </a>
                    <div class="course-title-side">Course Content</div>
                    <div class="course-meta-side"><asp:Literal ID="litTotalChapters" runat="server"></asp:Literal> chapters</div>
                </div>

                <!-- Dynamic Chapters List -->
                <asp:Repeater ID="rptSidebar" runat="server" OnItemDataBound="rptSidebar_ItemDataBound">
                    <ItemTemplate>
                        <a href='<%# Eval("Status").ToString() == "locked" ? "javascript:void(0);" : "CourseViewer.aspx?courseId=" + Request.QueryString["courseId"] + "&ch=" + Eval("Id") %>' 
                           class='nav-chapter <%# Convert.ToBoolean(Eval("IsActive")) ? "active" : "" %>' 
                           style='<%# Eval("Status").ToString() == "locked" ? "cursor: not-allowed; opacity: 0.6;" : "" %>'>
                
                            <div class='nav-status <%# Eval("Status") %>'>
                                <asp:Literal ID="litStatusIcon" runat="server"></asp:Literal>
                            </div>
                
                            <div class="nav-details">
                                <div class="nav-title"><%# Eval("Title") %></div>
                                <div class="nav-time"><%# Eval("Duration") %></div>
                            </div>
                        </a>
                    </ItemTemplate>
                </asp:Repeater>
            </aside>

            <!-- Right Panel: Main Content Flow -->
            <main class="viewer-content">

                <div class="content-wrapper">
                    <div class="content-scrollable">
                        
                        <!-- Content Header -->
                        <div class="content-header">
                            <span class="ch-label">Ch. <asp:Literal ID="litChNumber" runat="server"></asp:Literal> • <asp:Literal ID="litChDuration" runat="server"></asp:Literal></span>
                            <h1 class="ch-main-title">
                                <asp:Literal ID="litChTitle" runat="server"></asp:Literal>
                                <asp:PlaceHolder ID="phCheckmark" runat="server" Visible="false">
                                    <svg class="icon-check" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                                </asp:PlaceHolder>
                            </h1>
                        </div>

                        <!-- Dynamic Media Link (Video or Image) -->
                        <asp:Panel ID="pnlMedia" runat="server" Visible="false">
                            <div class="section-divider">Part 1: Media Resource</div>
                            <asp:Literal ID="litMediaHtml" runat="server"></asp:Literal>
                        </asp:Panel>

                        <!-- Dynamic Theory Content (Subchapters) -->
                        <asp:Panel ID="pnlTheory" runat="server" Visible="false">
                            <div class="section-divider">Part 2: Theory & Concepts</div>
                            <div class="theory-content">
                                <asp:Literal ID="litTheoryHtml" runat="server"></asp:Literal>
                            </div>
                        </asp:Panel>

                        <!-- Dynamic Quiz Section -->
                        <asp:Panel ID="pnlQuiz" runat="server" Visible="false">
                            <div class="section-divider">Part 3: Knowledge Check</div>
                            <asp:Repeater ID="rptQuizQuestions" runat="server">
                                <ItemTemplate>
                                    <div class="quiz-question">
                                        <div class="q-title"><%# Eval("Title") %></div>
                                        
                                        <!-- Dynamic Options based on Question Type -->
                                        <asp:Repeater ID="rptOptions" runat="server" DataSource='<%# Eval("Options") %>'>
                                            <ItemTemplate>
                                                <div class="q-option"><div class="q-radio"></div><span><%# Container.DataItem %></span></div>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </asp:Panel>

                        <!-- Dynamic Coding / Assessment Section -->
                        <asp:Panel ID="pnlCode" runat="server" Visible="false">
                            <div class="section-divider">Part 4: Coding Challenge</div>
                            <div class="challenge-box">
                                <h3 style="color: white; margin-bottom: 0.5rem;"><asp:Literal ID="litCodeTitle" runat="server"></asp:Literal></h3>
                                <p><asp:Literal ID="litCodeDesc" runat="server"></asp:Literal></p>
                            </div>

                            <div class="ide-placeholder">
                                <div class="code-header">
                                    editor
                                    <div class="code-dots"><span class="dot-g"></span><span class="dot-y"></span><span class="dot-r"></span></div>
                                </div>
                                <div class="code-body">
            <span class="code-comment"># Write your solution here...</span>
                                </div>
                            </div>
                        </asp:Panel>

                        <asp:Panel ID="pnlExam" runat="server" Visible="false">
                            <div class="section-divider">Final Exam</div>
                            <div class="challenge-box" style="border-color: #ef4444; background: rgba(239, 68, 68, 0.05);">
                                <h3 style="color: white; margin-bottom: 0.5rem;">Ready to take the exam?</h3>
                                <p>This exam will test your knowledge across all chapters. Please ensure you have enough time to complete it.</p>
                            </div>
                        </asp:Panel>

                    </div>
                </div>

                <!-- Footer Navigation -->
                <div class="viewer-footer">
                    <asp:HyperLink ID="lnkPrev" runat="server" CssClass="btn-nav">
                        <svg width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>
                        Previous
                    </asp:HyperLink>

                    <span class="step-indicator"><asp:Literal ID="litStepIndicator" runat="server"></asp:Literal></span>

                    <asp:HyperLink ID="lnkNext" runat="server" CssClass="btn-nav primary">
                        Next
                        <svg width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>
                    </asp:HyperLink>
                </div>

            </main>
        </div>
    </form>
</body>
</html>