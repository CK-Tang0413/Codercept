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
                
                <a href="CourseCatalog.aspx" class="back-nav">
                    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                    </svg>
                    Back to catalog
                </a>

                <!-- Hero Section -->
                <div class="course-hero">
                    <div class="hero-tags">
                        <span class="badge badge-lang">Python</span>
                        <span class="badge badge-level">Beginner</span>
                        <span class="badge badge-featured">Featured</span>
                    </div>

                    <h1>Python for Beginners</h1>
                    <p>Start your programming journey with Python. Learn syntax, data types, control flow, and functions through hands-on exercises and real projects.</p>
                    
                    <div class="hero-meta">
                        <span>👨‍🏫 Dr. Sarah Park</span>
                        <span>📖 5 chapters</span>
                        <span>⏱️ 6h total</span>
                        <span>👥 128 enrolled</span>
                        <span>⭐ 4.8/5.0</span>
                    </div>

                    <!-- Enrolled State Panel: Progress Bar -->
                    <!-- Wrap this in an ASP:Panel to hide if the user hasn't enrolled yet -->
                    <asp:Panel ID="pnlEnrolledProgress" runat="server" CssClass="progress-section">
                        <div class="progress-header">
                            <span>Your progress</span>
                            <strong>60%</strong>
                        </div>
                        <div class="progress-bar-bg">
                            <div class="progress-bar-fill" style="width: 60%;"></div>
                        </div>
                    </asp:Panel>

                    <!-- Main Call to Action Button[cite: 37, 38] -->
                    <!-- Text can be swapped between "Enroll for Free &rarr;" and "Continue Learning &rarr;" -->
                    <asp:Button ID="btnCourseAction" runat="server" Text="Continue Learning &rarr;" CssClass="btn-action" OnClick="btnCourseAction_Click" />
                </div>

                <h2 class="section-title">Course Chapters</h2>

                <!-- Chapters List -->
                <div class="chapter-list">
                    
                    <!-- Chapter 1: Completed -->
                    <a href="CourseViewer.aspx?chapter=1" class="chapter-item">
                        <div class="ch-status completed">
                            <!-- Checkmark SVG -->
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                            </svg>
                        </div>
                        <div class="ch-content">
                            <div class="ch-title">Introduction to Python</div>
                            <div class="ch-tags">
                                <span class="c-tag theory">📄 Theory</span>
                                <span class="c-tag video">▶️ Video</span>
                            </div>
                        </div>
                        <div class="ch-meta">
                            <span>45 min</span>
                            <svg class="ch-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                            </svg>
                        </div>
                    </a>

                    <!-- Chapter 2: Completed -->
                    <a href="CourseViewer.aspx?chapter=2" class="chapter-item">
                        <div class="ch-status completed">
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                            </svg>
                        </div>
                        <div class="ch-content">
                            <div class="ch-title">Variables & Data Types</div>
                            <div class="ch-tags">
                                <span class="c-tag theory">📄 Theory</span>
                                <span class="c-tag quiz">⚡ Quiz</span>
                            </div>
                        </div>
                        <div class="ch-meta">
                            <span>60 min</span>
                            <svg class="ch-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                            </svg>
                        </div>
                    </a>

                    <!-- Chapter 3: Active / Next up -->
                    <a href="CourseViewer.aspx?chapter=3" class="chapter-item" style="border-color: rgba(124, 58, 237, 0.4);">
                        <div class="ch-status completed" style="background: rgba(124, 58, 237, 0.2); color: #c084fc;">
                            <!-- Play SVG indicating active chapter -->
                            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="currentColor" viewBox="0 0 16 16">
                                <path d="M10.804 8 5 4.633v6.734L10.804 8zm.792-.696a.802.802 0 0 1 0 1.392l-6.363 3.692C4.713 12.69 4 12.345 4 11.692V4.308c0-.653.713-.998 1.233-.696l6.363 3.692z"/>
                            </svg>
                        </div>
                        <div class="ch-content">
                            <div class="ch-title">Control Flow — if, elif, else & Loops</div>
                            <div class="ch-tags">
                                <span class="c-tag theory">📄 Theory</span>
                                <span class="c-tag coding">💻 Coding</span>
                            </div>
                        </div>
                        <div class="ch-meta">
                            <span>75 min</span>
                            <svg class="ch-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                            </svg>
                        </div>
                    </a>

                    <!-- Chapter 4: Locked (Unenrolled or Not Reached) -->
                    <div class="chapter-item" style="opacity: 0.6; cursor: not-allowed;">
                        <div class="ch-status locked">04</div>
                        <div class="ch-content">
                            <div class="ch-title">Functions & Modules</div>
                            <div class="ch-tags">
                                <span class="c-tag theory">📄 Theory</span>
                                <span class="c-tag coding">💻 Coding</span>
                            </div>
                        </div>
                        <div class="ch-meta">
                            <span>90 min</span>
                            <!-- Lock SVG -->
                            <svg class="ch-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                            </svg>
                        </div>
                    </div>

                    <!-- Final Exam: Locked -->
                    <div class="chapter-item" style="opacity: 0.6; cursor: not-allowed;">
                        <div class="ch-status locked">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                                <path d="M2.5 1A1.5 1.5 0 0 0 1 2.5v11A1.5 1.5 0 0 0 2.5 15h6.086a1.5 1.5 0 0 0 1.06-.44l4.915-4.914A1.5 1.5 0 0 0 15 8.586V2.5A1.5 1.5 0 0 0 13.5 1h-11zM2 2.5a.5.5 0 0 1 .5-.5h11a.5.5 0 0 1 .5.5V8H9.5A1.5 1.5 0 0 0 8 9.5V14H2.5a.5.5 0 0 1-.5-.5v-11zm7 11.293V9.5a.5.5 0 0 1 .5-.5h4.293L9 13.793z"/>
                            </svg>
                        </div>
                        <div class="ch-content">
                            <div class="ch-title">Module Final Exam</div>
                            <div class="ch-tags">
                                <span class="c-tag quiz" style="background: rgba(239, 68, 68, 0.15); color: #ef4444;">🎯 Assessment</span>
                            </div>
                        </div>
                        <div class="ch-meta">
                            <span>45 min</span>
                            <svg class="ch-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                            </svg>
                        </div>
                    </div>

                </div>
            </main>
        </div>
    </form>
</body>
</html>