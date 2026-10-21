<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LearnerDashboard.aspx.cs" Inherits="Codercept.LearnerDashboard" %>
<%@ Register Src="~/LearnerSideBar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dashboard - Codercept</title>
    
    <!-- 1. Import Global Variables & Shared Layout -->
    <link href="css/global.css" rel="stylesheet" type="text/css" />

    <!-- 2. Page-Specific Styles -->
    <style>
        :root {
            /* Local variables for dashboard stats and elements */
            --stat-card-bg: var(--bg-surface);
            --greeting-bg: rgba(30, 22, 51, 0.6);
            --greeting-border: rgba(124, 58, 237, 0.2);
        }

        /* Greeting Section */
        .greeting-section { background: var(--greeting-bg); border: 1px solid var(--greeting-border); padding: 2rem; border-radius: 12px; margin-bottom: 2rem; backdrop-filter: blur(10px); }
        .greeting-section h1 { font-size: 2rem; margin-bottom: 0.5rem; color: var(--text-primary); }
        .greeting-section p { color: var(--text-secondary); font-size: 1rem; }
        
        /* Overview Stats Grid */
        .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 1.5rem; margin-bottom: 3rem; }
        .stat-card { background: var(--stat-card-bg); border: 1px solid var(--border-light); padding: 1.5rem; border-radius: 12px; display: flex; flex-direction: column; justify-content: center; }
        .stat-value { font-size: 2rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.25rem; }
        .stat-label { font-size: 0.85rem; color: var(--text-secondary); }
        
        /* Section Headers */
        .section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; }
        .section-header h2 { font-size: 1.25rem; font-weight: 600; color: var(--text-primary); }
        .view-all { color: var(--accent-light); text-decoration: none; font-size: 0.9rem; font-weight: 500; transition: color 0.2s; }
        .view-all:hover { color: var(--accent-hover); text-decoration: underline; }

        /* Dashboard Course Grids */
        .course-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 1.5rem; margin-bottom: 3rem; }
        
        /* Updated Course Card to handle <a> tags correctly */
        .course-card { 
            background: var(--bg-surface); 
            border: 1px solid var(--border-light); 
            border-radius: 12px; 
            padding: 1.5rem; 
            display: flex; 
            flex-direction: column; 
            transition: transform 0.2s, border-color 0.2s; 
            cursor: pointer; 
            text-decoration: none; 
            color: inherit; 
        }
        .course-card:hover { transform: translateY(-3px); border-color: rgba(124, 58, 237, 0.4); }

        .card-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem; }
        .course-title { font-size: 1.1rem; font-weight: 600; margin-bottom: 0.5rem; color: var(--text-primary); }
        .course-desc { font-size: 0.85rem; color: var(--text-secondary); line-height: 1.5; margin-bottom: 1.5rem; flex: 1; }
        
        /* Badges */
        .lang-badge { background: var(--accent-transparent); color: var(--accent-light); padding: 0.25rem 0.75rem; border-radius: 4px; font-size: 0.75rem; font-weight: 600; border: 1px solid rgba(124, 58, 237, 0.3); }
        .level-badge { font-size: 0.75rem; color: #fbbf24; background: rgba(251, 191, 36, 0.1); padding: 0.25rem 0.5rem; border-radius: 4px; }
        
        /* Progress Bar */
        .progress-container { margin-top: auto; }
        .progress-info { display: flex; justify-content: space-between; font-size: 0.8rem; color: var(--text-secondary); margin-bottom: 0.5rem; }
        .progress-bar-bg { width: 100%; height: 6px; background: rgba(255, 255, 255, 0.1); border-radius: 3px; overflow: hidden; }
        .progress-bar-fill { height: 100%; background: var(--accent-primary); border-radius: 3px; }
        
        /* Removed .next-step link inside the card, as the whole card is now the link */
        .next-step-text { margin-top: 1rem; font-size: 0.85rem; color: var(--accent-light); display: inline-block; font-weight: 500; }
        
        /* Recommended Stats */
        .course-meta { display: flex; gap: 1rem; font-size: 0.8rem; color: var(--text-muted); margin-top: auto; padding-top: 1rem; border-top: 1px solid var(--border-light); }
        .course-meta span { display: flex; align-items: center; gap: 0.25rem; }

        @media (max-width: 1024px) {
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
        }
        @media (max-width: 768px) {
            .course-grid { grid-template-columns: 1fr; }
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
                
                <!-- Greeting -->
                <div class="greeting-section">
                    <h1>Welcome back, <asp:Literal ID="litWelcomeName" runat="server" Text="Alex"></asp:Literal> 👋</h1>
                    <p><asp:Literal ID="litGreetingDesc" runat="server" Text="You have 2 active courses. Keep up the momentum!"></asp:Literal></p>
                </div>
                
                <!-- Hidden for Guests -->
                <asp:PlaceHolder ID="phLearnerData" runat="server">
                    <!-- User Overview Blocks -->
                    <div class="stats-grid">
                        <div class="stat-card">
                            <div class="stat-value"><asp:Literal ID="litStatEnrolled" runat="server"></asp:Literal></div>
                            <div class="stat-label">Enrolled Courses</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value"><asp:Literal ID="litStatChapters" runat="server"></asp:Literal></div>
                            <div class="stat-label">Chapters Done</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value"><asp:Literal ID="litStatAvgScore" runat="server"></asp:Literal></div>
                            <div class="stat-label">Avg. Score</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-value"><asp:Literal ID="litStatProgress" runat="server"></asp:Literal></div>
                            <div class="stat-label">Total Progress</div>
                        </div>
                    </div>

                    <!-- Continue Learning Progress -->
                    <div class="section-header">
                        <h2>Continue Learning</h2>
                        <a href="MyProgress.aspx" class="view-all">View all active courses &rarr;</a>
                    </div>
    
                    <div class="course-grid">
                        <asp:Repeater ID="rptActiveCourses" runat="server">
                            <ItemTemplate>
                                <a href='CourseDetails.aspx?id=<%# Eval("Id") %>' class="course-card">
                                    <div class="card-header">
                                        <span class="lang-badge"><%# Eval("Language") %></span>
                                    </div>
                                    <h3 class="course-title"><%# Eval("Title") %></h3>
                                    <div class="progress-container">
                                        <div class="progress-info">
                                            <span>Progress</span>
                                            <span><%# Eval("Progress") %>%</span>
                                        </div>
                                        <div class="progress-bar-bg">
                                            <div class="progress-bar-fill" style='width: <%# Eval("Progress") %>%;'></div>
                                        </div>
                                        <span class="next-step-text">Next: <%# Eval("NextChapter") %> &rarr;</span>
                                    </div>
                                </a>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </asp:PlaceHolder>

                <!-- Recommended Courses (Visible to Everyone) -->
                <div class="section-header">
                    <h2 id="recommendationHeader" runat="server">Recommended for You</h2>
                    <a href="CourseCatalog.aspx" class="view-all">View all recommendations &rarr;</a>
                </div>

                <div class="course-grid">
                    <asp:Repeater ID="rptRecommended" runat="server">
                        <ItemTemplate>
                            <a href='CourseDetails.aspx?id=<%# Eval("Id") %>' class="course-card">
                                <div class="card-header">
                                    <span class="lang-badge"><%# Eval("Language") %></span>
                                    <span class="level-badge"><%# Eval("Level") %></span>
                                </div>
                                <h3 class="course-title"><%# Eval("Title") %></h3>
                                <p class="course-desc"><%# Eval("Description") %></p>
                                <div class="course-meta">
                                    <span>📖 <%# Eval("Chapters") %> chapters</span>
                                    <span>⭐ <%# Eval("Rating") %> Rating</span>
                                    <span>👥 <%# Eval("EnrolledCount") %> enrolled</span>
                                </div>
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

            </main>
        </div>
    </form>
</body>
</html>