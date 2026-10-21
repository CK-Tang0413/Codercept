<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MyProgress.aspx.cs" Inherits="Codercept.MyProgress" %>
<%@ Register Src="~/LearnerSideBar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>My Progress - Codercept</title>
    
    <!-- 1. Import Global Variables & Shared Layout -->
    <link href="~/css/global.css" rel="stylesheet" type="text/css" />
    
    <!-- 2. Page-Specific Styles -->
    <style>
        :root {
            /* Local variables for stats colors and table */
            --stat-active: #c084fc;
            --stat-completed: #4ade80;
            --stat-quiz: #fb923c;
            --stat-code: #a855f7;
            
            --table-border: var(--border-light);
            --table-header-bg: transparent;
            --table-row-hover: rgba(255, 255, 255, 0.02);
            
            --grade-a: #4ade80;
            --grade-b: #60a5fa;
            --grade-c: #fbbf24;
            --grade-d: #f87171;
            --grade-f: #ef4444;
        }

        /* Page Header */
        .page-header { margin-bottom: 2rem; }
        .page-header h1 { font-size: 1.75rem; margin-bottom: 0.25rem; color: var(--text-primary); }
        .page-header p { color: var(--text-secondary); font-size: 1rem; }

        /* Overview Stats Grid[cite: 14] */
        .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 1.5rem; margin-bottom: 3rem; }
        .stat-card { background: var(--bg-surface); border: 1px solid var(--border-light); padding: 1.5rem; border-radius: 12px; display: flex; flex-direction: column; align-items: center; justify-content: center; text-align: center; }
        .stat-value { font-size: 2.25rem; font-weight: 700; margin-bottom: 0.25rem; }
        .stat-label { font-size: 0.85rem; color: var(--text-secondary); }
        
        .val-active { color: var(--stat-active); }
        .val-completed { color: var(--stat-completed); }
        .val-quiz { color: var(--stat-quiz); }
        .val-code { color: var(--stat-code); }

        /* Section Header */
        .section-header { margin-bottom: 1.25rem; }
        .section-header h2 { font-size: 1.25rem; font-weight: 600; color: var(--text-primary); }

        /* Grades Table[cite: 14] */
        .table-container { background: var(--bg-surface); border: 1px solid var(--table-border); border-radius: 12px; overflow: hidden; }
        .grades-table { width: 100%; border-collapse: collapse; text-align: left; }
        .grades-table th { padding: 1.25rem 1.5rem; font-size: 0.85rem; font-weight: 600; color: var(--text-secondary); border-bottom: 1px solid var(--table-border); background: var(--table-header-bg); }
        .grades-table td { padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--table-border); vertical-align: middle; transition: background 0.2s; }
        .grades-table tr:last-child td { border-bottom: none; }
        .grades-table tbody tr:hover td { background: var(--table-row-hover); }

        /* Course Column Details */
        .course-info { display: flex; flex-direction: column; gap: 0.25rem; }
        .course-name { font-weight: 600; color: var(--text-primary); font-size: 0.95rem; }
        .course-lang { font-size: 0.8rem; }
        .lang-python { color: #60a5fa; }
        .lang-java { color: #fb923c; }

        /* Progress Bar in Table[cite: 14] */
        .progress-wrapper { display: flex; align-items: center; gap: 1rem; }
        .progress-bar-bg { flex: 1; max-width: 120px; height: 6px; background: rgba(255, 255, 255, 0.1); border-radius: 3px; overflow: hidden; }
        .progress-bar-fill { height: 100%; background: var(--accent-primary); border-radius: 3px; }
        .progress-text { font-size: 0.85rem; color: var(--text-secondary); width: 40px; text-align: right; }

        /* Averages and Grades[cite: 14] */
        .score-text { font-size: 0.95rem; font-weight: 600; color: var(--text-primary); }
        .grade-badge { font-size: 1rem; font-weight: 700; }
        .grade-b { color: var(--grade-b); }
        .grade-d { color: var(--grade-d); }

        @media (max-width: 1024px) {
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
            .grades-table th, .grades-table td { padding: 1rem; }
        }
        @media (max-width: 768px) {
            .stats-grid { grid-template-columns: repeat(2, 1fr); gap: 1rem; }
            .stat-value { font-size: 1.75rem; }
            .table-container { overflow-x: auto; }
            .grades-table { min-width: 700px; }
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
                
                <div class="page-header">
                    <h1>My Progress</h1>
                    <p>Track your learning journey and scores</p>
                </div>

            <!-- Overview Stats Grid -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-value val-active">
                        <asp:Literal ID="litActiveCourses" runat="server"></asp:Literal>
                    </div>
                    <div class="stat-label">Active Courses</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value val-completed">
                        <asp:Literal ID="litCompletedCourses" runat="server"></asp:Literal>
                    </div>
                    <div class="stat-label">Completed</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value val-quiz">
                        <asp:Literal ID="litQuizAvg" runat="server"></asp:Literal>
                    </div>
                    <div class="stat-label">Quiz Avg.</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value val-code">
                        <asp:Literal ID="litCodeAvg" runat="server"></asp:Literal>
                    </div>
                    <div class="stat-label">Code Avg.</div>
                </div>
            </div>

            <!-- Course Grades Section -->
            <div class="section-header">
                <h2>Course Grades</h2>
            </div>

            <div class="table-container">
                <table class="grades-table">
                    <thead>
                        <tr>
                            <th>Course</th>
                            <th>Progress</th>
                            <th>Quiz Avg</th>
                            <th>Coding Avg</th>
                            <th>Grade</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Dynamic Repeater for Rows -->
                        <asp:Repeater ID="rptGrades" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td>
                                        <div class="course-info">
                                            <span class="course-name"><%# Eval("CourseName") %></span>
                                            <span class="course-lang <%# Eval("LangClass") %>"><%# Eval("Language") %></span>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="progress-wrapper">
                                            <div class="progress-bar-bg">
                                                <div class="progress-bar-fill" style='width: <%# Eval("Progress") %>%;'></div>
                                            </div>
                                            <span class="progress-text"><%# Eval("Progress") %>%</span>
                                        </div>
                                    </td>
                                    <td><span class="score-text"><%# Eval("QuizAvg") %></span></td>
                                    <td><span class="score-text"><%# Eval("CodeAvg") %></span></td>
                                    <td><span class="grade-badge <%# Eval("GradeClass") %>"><%# Eval("Grade") %></span></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>

            </main>
        </div>
    </form>
</body>
</html>