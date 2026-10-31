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
    </style>

</head>
<body>
    <form id="form1" runat="server">
        <!-- 1. Required for dynamic partial-page updates -->
        <asp:ScriptManager ID="ScriptManager1" runat="server" />

        <div class="dashboard-layout">
            
            <uc:Sidebar runat="server" ID="LearnerSideBarCtrl" />

            <!-- Main Content -->
            <main class="main-content">
                
                <div class="page-header">
                    <h1>Course Catalog</h1>
                    <p>Browse all available programming courses</p>
                </div>

                <!-- 2. Search Container (Kept OUTSIDE the UpdatePanel so you don't lose typing focus) -->
                <div class="search-container">
                    <svg class="search-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                    </svg>
                    <!-- Removed AutoPostBack, Added oninput to trigger JS -->
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="search-input" placeholder="Search courses..." oninput="debounceSearch()"></asp:TextBox>
                    <!-- Hidden button that executes the C# search method -->
                    <asp:Button ID="btnHiddenSearch" runat="server" OnClick="txtSearch_TextChanged" style="display:none;" />
                </div>

                <!-- Live Search Script (Waits 400ms after you stop typing to fetch results) -->
                <script>
                    let typingTimer;
                    function debounceSearch() {
                        clearTimeout(typingTimer);
                        typingTimer = setTimeout(function () {
                            document.getElementById('<%= btnHiddenSearch.ClientID %>').click();
                        }, 400);
                    }
                </script>

                <!-- 3. UpdatePanel wraps the results so only this section reloads dynamically -->
                <asp:UpdatePanel ID="upCatalog" runat="server">
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="btnHiddenSearch" EventName="Click" />
                    </Triggers>
                    <ContentTemplate>
                        
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
                                        <!-- Thumbnail with Floating Difficulty Badge -->
                                        <div class='course-thumbnail course-thumbnail--<%# Eval("LanguageCSS") %>'>
                                            <span class='card-floating-badge badge-<%# Eval("DifficultyLevel").ToString().ToLower() %>'><%# Eval("DifficultyLevel") %></span>
                                            <span><%# Eval("Language").ToString().Substring(0, 1) %></span>
                                        </div>
                                        
                                        <div class="course-content">
                                            <h3 class="course-title"><%# Eval("CourseTitle") %></h3>
                                            <p class="course-desc"><%# Eval("CourseDescription") %></p>
                                            
                                            <div class="course-meta-grid">
                                                <span class="course-meta-item">📖 <%# Eval("Chapters") %> chapters</span>
                                                <span class="course-meta-item">⏱️ <%# Eval("CourseDuration") %></span>
                                                <span class="course-meta-item">⭐ <%# Eval("Rating") %> Rating</span>
                                                <span class="course-meta-item">👥 <%# Eval("EnrolledCount") %> enrolled</span>
                                            </div>
                                            
                                            <!-- Static Enroll Button -->
                                            <span class="course-action-btn enroll">Enroll Now</span>
                                        </div>
                                    </a>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                        
                    </ContentTemplate>
                </asp:UpdatePanel>

            </main>
        </div>
    </form>
</body>
</html>