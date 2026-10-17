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

        /* Sub-chapter styling */
        .nav-subchapter {
            padding: 0.75rem 1.5rem 0.75rem 3.5rem;
            font-size: 0.85rem;
            color: var(--text-secondary);
            border-left: 3px solid transparent;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            text-decoration: none;
        }
        .nav-subchapter:hover { color: var(--text-primary); }
        .nav-subchapter.active { color: var(--accent-light); }

        /* Main Content Area */
        .viewer-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden; /* Stops the whole panel from scrolling past the footer */
        }

        /* NEW: Scrollable wrapper to keep the scrollbar at the edge while keeping the footer fixed */
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
            flex-shrink: 0; /* Prevents the footer from squishing */
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
                    <a href="CourseDetails.aspx?id=1" class="back-link">
                        <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                        </svg>
                        Back to course
                    </a>
                    <div class="course-title-side">Python for Beginners</div>
                    <div class="course-meta-side">5 chapters</div>
                </div>

                <!-- Chapter 1 (Active) -->
                <a href="CourseViewer.aspx?ch=1" class="nav-chapter active">
                    <div class="nav-status completed">
                        <svg width="12" height="12" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"/></svg>
                    </div>
                    <div class="nav-details">
                        <div class="nav-title">Introduction to Python</div>
                        <div class="nav-time">45 min</div>
                    </div>
                </a>

                <!-- Chapter 2 -->
                <a href="CourseViewer.aspx?ch=2" class="nav-chapter">
                    <div class="nav-status completed">
                        <svg width="12" height="12" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7"/></svg>
                    </div>
                    <div class="nav-details">
                        <div class="nav-title">Variables & Data Types</div>
                        <div class="nav-time">60 min</div>
                    </div>
                </a>

                <!-- Chapter 3 (With Sub-chapters example) -->
                <a href="CourseViewer.aspx?ch=3" class="nav-chapter">
                    <div class="nav-status pending">3</div>
                    <div class="nav-details">
                        <div class="nav-title">Control Flow — if, elif, else & Loops</div>
                        <div class="nav-time">75 min</div>
                    </div>
                </a>
                <!-- Sub-chapters -->
                <a href="CourseViewer.aspx?ch=3&sub=1" class="nav-subchapter">
                    <svg width="14" height="14" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
                    If / Else Statements
                </a>
                <a href="CourseViewer.aspx?ch=3&sub=2" class="nav-subchapter">
                    <svg width="14" height="14" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"/></svg>
                    For Loops
                </a>

                <!-- Chapter 4 -->
                <div class="nav-chapter" style="cursor: not-allowed; opacity: 0.6;">
                    <div class="nav-status locked">4</div>
                    <div class="nav-details">
                        <div class="nav-title">Functions</div>
                        <div class="nav-time">70 min</div>
                    </div>
                </div>

                <!-- Final Assessment -->
                <div class="nav-chapter" style="cursor: not-allowed; opacity: 0.6;">
                    <div class="nav-status locked">5</div>
                    <div class="nav-details">
                        <div class="nav-title">Final Assessment — Build a Calculator</div>
                        <div class="nav-time">90 min</div>
                    </div>
                </div>
            </aside>

            <!-- Right Panel: Main Content Flow -->
            <main class="viewer-content">
                
                <!-- NEW: Scrollable Content Wrapper -->
                <div class="content-wrapper">
                    <div class="content-scrollable">
                        
                        <!-- Content Header -->
                        <div class="content-header">
                            <span class="ch-label">Ch. 1 • 45 min</span>
                            <h1 class="ch-main-title">
                                Introduction to Python
                                <svg class="icon-check" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                            </h1>
                        </div>

                        <!-- 1. Video Section -->
                        <div class="section-divider">Part 1: Video Lecture</div>
                        <div class="video-container">
                            <div class="play-btn">
                                <svg width="24" height="24" fill="currentColor" viewBox="0 0 16 16"><path d="M10.804 8 5 4.633v6.734L10.804 8zm.792-.696a.802.802 0 0 1 0 1.392l-6.363 3.692C4.713 12.69 4 12.345 4 11.692V4.308c0-.653.713-.998 1.233-.696l6.363 3.692z"/></svg>
                            </div>
                            <h3 style="color: white; margin-bottom: 0.5rem;">Python Tutorial for Beginners — Full Course</h3>
                            <p style="color: var(--text-muted); font-size: 0.85rem;">Video lecture — 45 min</p>
                        </div>

                        <!-- 2. Theory Section -->
                        <div class="section-divider">Part 2: Theory & Concepts</div>
                        <div class="theory-content">
                            <h2>What is Python?</h2>
                            <p>Python is a high-level, interpreted programming language created by Guido van Rossum in 1991. It is known for its clean, readable syntax that resembles plain English, making it an excellent choice for beginners and professionals alike.</p>
                            
                            <h2>Why Learn Python?</h2>
                            <ul>
                                <li>Simple and readable syntax — great for beginners</li>
                                <li>Versatile: web dev, data science, AI, automation</li>
                                <li>Massive community with thousands of libraries</li>
                                <li>High demand in the job market</li>
                            </ul>

                            <h2>Your First Python Program</h2>
                            <p>Every programmer starts with a "Hello, World!" program. In Python, this is beautifully simple:</p>

                            <div class="code-block">
                                <div class="code-header">
                                    python
                                    <div class="code-dots"><span class="dot-g"></span><span class="dot-y"></span><span class="dot-r"></span></div>
                                </div>
                                <div class="code-body">
<span class="code-comment"># This is a comment — Python ignores it</span>
print("Hello, World!")
                                </div>
                            </div>
                        </div>

                        <!-- 3. Assessment / Quiz Section -->
                        <div class="section-divider">Part 3: Knowledge Check</div>
                        
                        <div class="quiz-question">
                            <div class="q-title">Q1. What is the correct way to assign a string value to a variable in Python?</div>
                            
                            <div class="q-option">
                                <div class="q-radio"></div>
                                <span>str name = Alice</span>
                            </div>
                            <div class="q-option">
                                <div class="q-radio"></div>
                                <span>name = Alice</span>
                            </div>
                            <div class="q-option">
                                <div class="q-radio"></div>
                                <span>name = "Alice"</span>
                            </div>
                        </div>

                        <div class="quiz-question">
                            <div class="q-title">Q2. What does the len() function return when used on a string?</div>
                            
                            <div class="q-option">
                                <div class="q-radio"></div>
                                <span>The string in uppercase</span>
                            </div>
                            <div class="q-option">
                                <div class="q-radio"></div>
                                <span>The number of characters in the string</span>
                            </div>
                        </div>

                        <!-- 4. Coding Section -->
                        <div class="section-divider">Part 4: Coding Challenge</div>
                        <div class="challenge-box">
                            <h3 style="color: white; margin-bottom: 0.5rem;">FizzBuzz Challenge</h3>
                            <p>Write a Python program that prints numbers from 1 to 20. For multiples of 3, print "Fizz" instead of the number. For multiples of 5, print "Buzz". For multiples of both 3 and 5, print "FizzBuzz".</p>
                        </div>

                        <div class="ide-placeholder">
                            <div class="code-header">
                                editor.py
                                <div class="code-dots"><span class="dot-g"></span><span class="dot-y"></span><span class="dot-r"></span></div>
                            </div>
                            <div class="code-body">
<span class="code-comment"># Write your solution here...</span>


                            </div>
                        </div>

                    </div>
                </div>

                <!-- Footer Navigation (Now fixed at the bottom)[cite: 45] -->
                <div class="viewer-footer">
                    <button type="button" class="btn-nav">
                        <svg width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/></svg>
                        Previous
                    </button>
                    
                    <span class="step-indicator">1 / 5</span>
                    
                    <button type="button" class="btn-nav primary">
                        Next
                        <svg width="18" height="18" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/></svg>
                    </button>
                </div>

            </main>
        </div>
    </form>
</body>
</html>