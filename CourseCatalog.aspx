<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CourseCatalog.aspx.cs" Inherits="Codercept.CourseCatalog" %>
<%@ Register Src="~/LearnerSideBar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Course Catalog - Codercept</title>

    <!-- 1. Import Global Variables -->
    <link href="~/css/global.css" rel="stylesheet" type="text/css" />

    <!-- 2. Page-Specific Styles and Local Variables -->
    <style>
        :root {
            /* Local variables only used in the Catalog */
            --catalog-search-bg: var(--bg-surface);
            --catalog-badge-python: #60a5fa;
            --catalog-badge-java: #fb923c;
            --catalog-badge-c: #f87171;
            --catalog-badge-cpp: #c084fc;
        }

        /* Header & Search */
        .page-header { margin-bottom: 2rem; }
        .page-header h1 { font-size: 1.75rem; margin-bottom: 0.25rem; color: var(--text-primary); }
        .page-header p { color: var(--text-secondary); font-size: 1rem; }

        .search-container { position: relative; margin-bottom: 1.5rem; }
        .search-icon { position: absolute; left: 1rem; top: 50%; transform: translateY(-50%); color: var(--text-secondary); width: 20px; height: 20px; }
        .search-input { width: 100%; background: var(--catalog-search-bg); border: 1px solid var(--border-light); padding: 1rem 1rem 1rem 3rem; border-radius: 8px; color: var(--text-primary); font-size: 0.95rem; outline: none; transition: border-color 0.2s; }
        .search-input:focus { border-color: var(--accent-primary); }
        .search-input::placeholder { color: var(--text-muted); }

        /* Filters */
        .filter-section { display: flex; gap: 1rem; margin-bottom: 2rem; flex-wrap: wrap; }
        .filter-group { display: flex; gap: 0.5rem; align-items: center; }
        .filter-pill { background: transparent; border: 1px solid var(--border-light); color: var(--text-secondary); padding: 0.4rem 1rem; border-radius: 20px; font-size: 0.85rem; cursor: pointer; transition: all 0.2s; text-decoration: none; }
        .filter-pill:hover { border-color: var(--accent-primary); color: var(--text-primary); }
        .filter-pill.active { background: var(--accent-transparent); border-color: var(--accent-primary); color: var(--accent-light); }

        .results-count { font-size: 0.85rem; color: var(--text-muted); margin-bottom: 1.5rem; }

        /* Course Grid & Cards */
        .course-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 1.5rem; padding-bottom: 2rem; }
        .course-card { 
            background: var(--bg-surface); 
            border: 1px solid var(--border-light); 
            border-radius: 12px; 
            padding: 1.5rem; 
            display: flex; 
            flex-direction: column; 
            transition: transform 0.2s, border-color 0.2s; 
            cursor: pointer; 
            text-decoration: none; /* Prevents underline on the link */
            color: inherit; /* Keeps your text colors intact */
        }
        .course-card:hover { transform: translateY(-3px); border-color: rgba(124, 58, 237, 0.4); }
        
        .card-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem; }
        .course-title { font-size: 1.1rem; font-weight: 600; margin-bottom: 0.5rem; color: var(--text-primary); }
        .course-desc { font-size: 0.85rem; color: var(--text-secondary); line-height: 1.5; margin-bottom: 1.5rem; flex: 1; }
        
        /* Dynamic Badges */
        .lang-badge { background: rgba(255, 255, 255, 0.05); color: #60a5fa; padding: 0.25rem 0.75rem; border-radius: 4px; font-size: 0.75rem; font-weight: 600; border: 1px solid var(--border-light); }
        .lang-badge.python { color: var(--catalog-badge-python); border-color: rgba(96, 165, 250, 0.3); background: rgba(96, 165, 250, 0.1); }
        .lang-badge.java { color: var(--catalog-badge-java); border-color: rgba(251, 146, 60, 0.3); background: rgba(251, 146, 60, 0.1); }
        .lang-badge.c { color: var(--catalog-badge-c); border-color: rgba(248, 113, 113, 0.3); background: rgba(248, 113, 113, 0.1); }
        .lang-badge.cpp { color: var(--catalog-badge-cpp); border-color: rgba(192, 132, 252, 0.3); background: rgba(192, 132, 252, 0.1); }

        .level-badge { font-size: 0.75rem; padding: 0.25rem 0.5rem; border-radius: 4px; border: 1px solid transparent; }
        .level-badge.easy { color: #4ade80; background: rgba(74, 222, 128, 0.1); border-color: rgba(74, 222, 128, 0.2); }
        .level-badge.medium { color: #fbbf24; background: rgba(251, 191, 36, 0.1); border-color: rgba(251, 191, 36, 0.2); }
        .level-badge.hard { color: #f87171; background: rgba(248, 113, 113, 0.1); border-color: rgba(248, 113, 113, 0.2); }
        
        /* Course Meta & Footers */
        .course-meta { display: flex; gap: 1rem; font-size: 0.8rem; color: var(--text-muted); margin-bottom: 1.5rem; }
        .course-meta span { display: flex; align-items: center; gap: 0.25rem; }
        .card-footer { border-top: 1px solid var(--border-light); padding-top: 1rem; margin-top: auto; }
        
        /* Progress & Enrollment status inside footer */
        .progress-info { display: flex; justify-content: space-between; font-size: 0.8rem; color: var(--text-secondary); margin-bottom: 0.5rem; }
        .progress-bar-bg { width: 100%; height: 4px; background: rgba(255, 255, 255, 0.1); border-radius: 2px; overflow: hidden; }
        .progress-bar-fill { height: 100%; background: var(--accent-primary); border-radius: 2px; }
        .enrolled-info { font-size: 0.8rem; color: var(--text-muted); display: flex; align-items: center; gap: 0.5rem; }

        @media (max-width: 768px) {
            .course-grid { grid-template-columns: 1fr; }
        }
    </style>

</head>
<body>
    <form id="form1" runat="server">
        <div class="dashboard-layout">
            
            <uc:Sidebar runat="server" ID="LearnerSideBarCtrl" />

            <!-- Main Content -->
            <main class="main-content">
                
                <div class="page-header">
                    <h1>Course Catalog</h1>
                    <p>Browse all available programming courses</p>
                </div>

                <!-- Search -->
                <div class="search-container">
                    <svg class="search-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input" placeholder="Search courses... (Press Enter)" AutoPostBack="true" OnTextChanged="txtSearch_TextChanged"></asp:TextBox>
                </div>

                <!-- Filters -->
                <div class="filter-section">
                    <div class="filter-group">
                        <asp:LinkButton ID="btnLangAll" runat="server" CssClass="filter-pill active" CommandArgument="All" OnClick="FilterLang_Click">All Languages</asp:LinkButton>
                        <asp:LinkButton ID="btnLangPython" runat="server" CssClass="filter-pill" CommandArgument="Python" OnClick="FilterLang_Click">Python</asp:LinkButton>
                        <asp:LinkButton ID="btnLangJava" runat="server" CssClass="filter-pill" CommandArgument="Java" OnClick="FilterLang_Click">Java</asp:LinkButton>
                        <asp:LinkButton ID="btnLangC" runat="server" CssClass="filter-pill" CommandArgument="C" OnClick="FilterLang_Click">C</asp:LinkButton>
                        <asp:LinkButton ID="btnLangCpp" runat="server" CssClass="filter-pill" CommandArgument="C++" OnClick="FilterLang_Click">C++</asp:LinkButton>
                    </div>
                    <div class="filter-group">
                        <asp:LinkButton ID="btnLevelAll" runat="server" CssClass="filter-pill active" CommandArgument="All" OnClick="FilterLevel_Click">All Levels</asp:LinkButton>
                        <asp:LinkButton ID="btnLevelEasy" runat="server" CssClass="filter-pill" CommandArgument="Easy" OnClick="FilterLevel_Click">Easy</asp:LinkButton>
                        <asp:LinkButton ID="btnLevelMedium" runat="server" CssClass="filter-pill" CommandArgument="Medium" OnClick="FilterLevel_Click">Medium</asp:LinkButton>
                        <asp:LinkButton ID="btnLevelHard" runat="server" CssClass="filter-pill" CommandArgument="Hard" OnClick="FilterLevel_Click">Hard</asp:LinkButton>
                    </div>
                </div>

                <div class="results-count">
                    <asp:Literal ID="litResultsCount" runat="server" Text="6 courses found"></asp:Literal>
                </div>

                <!-- Course Grid using Repeater -->
                <div class="course-grid">
                    <asp:Repeater ID="rptCourses" runat="server">
                        <ItemTemplate>
                            <a href='CourseDetails.aspx?id=<%# Eval("CourseId") %>' class="course-card">
                                <div class="card-header">
                                    <!-- Dynamic CSS classes based on language and level -->
                                    <span class='lang-badge <%# Eval("LanguageCSS") %>'><%# Eval("Language") %></span>
                                    <span class='level-badge <%# Eval("DifficultyLevel").ToString().ToLower() %>'><%# Eval("DifficultyLevel") %></span>
                                </div>
                                <h3 class="course-title"><%# Eval("CourseTitle") %></h3>
                                <p class="course-desc"><%# Eval("CourseDescription") %></p>
                                <div class="course-meta">
                                    <span>📖 <%# Eval("Chapters") %> chapters</span>
                                    <span>⏱️ <%# Eval("CourseDuration") %></span>
                                    <span>⭐ <%# Eval("Rating") %></span>
                                </div>
                                <div class="card-footer">

                                    <!-- Show if Enrolled -->
                                    <asp:PlaceHolder runat="server" Visible='<%# Convert.ToBoolean(Eval("IsEnrolled")) %>'>
                                        <div class="progress-info">
                                            <span>Progress</span>
                                            <span><%# Eval("ProgressPercentage") %>%</span>
                                        </div>
                                        <div class="progress-bar-bg">
                                            <div class="progress-bar-fill" style='width: <%# Eval("ProgressPercentage") %>%;'></div>
                                        </div>
                                    </asp:PlaceHolder>

                                    <!-- Show if NOT Enrolled -->
                                    <asp:PlaceHolder runat="server" Visible='<%# !Convert.ToBoolean(Eval("IsEnrolled")) %>'>
                                        <div class="enrolled-info">
                                            👥 <%# Eval("EnrolledCount") %> enrolled
                                        </div>
                                    </asp:PlaceHolder>

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