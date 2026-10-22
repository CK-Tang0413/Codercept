<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TACourseView.aspx.cs" Inherits="Codercept.TACourseView" %>
<%@ Register Src="~/TASideBar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Course Reference - Codercept</title>

    <!-- 1. Import Global Variables & Shared Layout -->
    <link href="css/global.css" rel="stylesheet" type="text/css" />

    <!-- 2. Page-Specific Styles -->
    <style>
        :root {
            --panel-bg: var(--bg-surface);
            --warn: #fbbf24;
            --success: #34d399;
        }

        .back-link { display: inline-block; color: var(--accent-light); text-decoration: none; font-size: 0.9rem; font-weight: 500; margin-bottom: 1.25rem; transition: color 0.2s; }
        .back-link:hover { color: var(--accent-hover); text-decoration: underline; }

        .course-header { background: rgba(30, 22, 51, 0.6); border: 1px solid rgba(124, 58, 237, 0.2); padding: 2rem; border-radius: 12px; margin-bottom: 2rem; backdrop-filter: blur(10px); }
        .course-header-top { display: flex; gap: 0.75rem; align-items: center; margin-bottom: 0.75rem; }
        .course-header h1 { font-size: 2rem; margin-bottom: 0.5rem; color: var(--text-primary); }
        .course-header p { color: var(--text-secondary); font-size: 1rem; line-height: 1.6; margin-bottom: 1rem; }
        .course-meta { display: flex; flex-wrap: wrap; gap: 0.5rem 1.5rem; font-size: 0.85rem; color: var(--text-muted); }
        .course-meta strong { color: var(--text-secondary); font-weight: 600; }

        .lang-badge { background: var(--accent-transparent); color: var(--accent-light); padding: 0.25rem 0.75rem; border-radius: 4px; font-size: 0.75rem; font-weight: 600; border: 1px solid rgba(124, 58, 237, 0.3); }
        .level-badge { font-size: 0.75rem; color: var(--warn); background: rgba(251, 191, 36, 0.1); padding: 0.25rem 0.5rem; border-radius: 4px; }
        .readonly-note { font-size: 0.8rem; color: var(--text-muted); margin-bottom: 1.25rem; }

        .section-title { font-size: 1.25rem; font-weight: 600; color: var(--text-primary); margin-bottom: 1rem; }

        .chapter-list { display: flex; flex-direction: column; gap: 1rem; max-width: 900px; margin-bottom: 3rem; }
        .chapter-card { background: var(--panel-bg); border: 1px solid var(--border-light); border-radius: 12px; padding: 1.25rem 1.5rem; }
        .chapter-card.focus { border-color: var(--accent-primary); background: var(--accent-transparent); }
        .chapter-top { display: flex; justify-content: space-between; align-items: center; gap: 1rem; margin-bottom: 0.75rem; }
        .chapter-title { font-size: 1.05rem; font-weight: 600; color: var(--text-primary); }
        .chapter-title span { color: var(--accent-light); margin-right: 0.4rem; }
        .review-tag { font-size: 0.7rem; font-weight: 600; color: var(--warn); background: rgba(251, 191, 36, 0.1); padding: 0.2rem 0.55rem; border-radius: 4px; white-space: nowrap; }

        .item-list { display: flex; flex-direction: column; }
        .item-row { display: flex; align-items: center; gap: 0.75rem; padding: 0.6rem 0; border-top: 1px solid var(--border-light); font-size: 0.9rem; color: var(--text-secondary); }
        .kind-badge { font-size: 0.7rem; font-weight: 600; padding: 0.15rem 0.5rem; border-radius: 4px; min-width: 78px; text-align: center; }
        .kind-lesson { color: var(--text-secondary); background: rgba(255, 255, 255, 0.06); }
        .kind-quiz { color: #60a5fa; background: rgba(96, 165, 250, 0.1); }
        .kind-assessment { color: var(--accent-light); background: var(--accent-transparent); }
        .kind-exam { color: var(--warn); background: rgba(251, 191, 36, 0.1); }

        .empty-state { color: var(--text-muted); font-size: 0.9rem; padding: 2rem 0; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="dashboard-layout">

            <!-- Sidebar Injected Here -->
            <uc:Sidebar runat="server" ID="TASideBarCtrl" />

            <!-- Main Content -->
            <main class="main-content">

                <a href="javascript:history.back()" class="back-link">&larr; Back</a>

                <asp:PlaceHolder ID="phNotFound" runat="server" Visible="false">
                    <p class="empty-state">This course could not be found.</p>
                </asp:PlaceHolder>

                <asp:PlaceHolder ID="phCourse" runat="server">
                    <div class="course-header">
                        <div class="course-header-top">
                            <span class="lang-badge"><asp:Literal ID="litLanguage" runat="server"></asp:Literal></span>
                            <span class="level-badge"><asp:Literal ID="litLevel" runat="server"></asp:Literal></span>
                        </div>
                        <h1><asp:Literal ID="litTitle" runat="server"></asp:Literal></h1>
                        <p><asp:Literal ID="litDescription" runat="server"></asp:Literal></p>
                        <div class="course-meta">
                            <span>Teacher: <strong><asp:Literal ID="litTeacher" runat="server"></asp:Literal></strong></span>
                            <span>Duration: <strong><asp:Literal ID="litDuration" runat="server"></asp:Literal></strong></span>
                            <span>Chapters: <strong><asp:Literal ID="litChapterCount" runat="server"></asp:Literal></strong></span>
                        </div>
                    </div>

                    <h2 class="section-title">Course Outline</h2>
                    <p class="readonly-note">Read-only reference. Content is managed by the course teacher.</p>

                    <div class="chapter-list">
                        <asp:Repeater ID="rptChapters" runat="server">
                            <ItemTemplate>
                                <div class='chapter-card <%# Eval("CssClass") %>'>
                                    <div class="chapter-top">
                                        <div class="chapter-title"><span>Chapter <%# Eval("Number") %></span><%# Eval("Title") %></div>
                                        <span class="review-tag" runat="server" visible='<%# Eval("IsFocus") %>'>Submission under review</span>
                                    </div>
                                    <div class="item-list">
                                        <asp:Repeater ID="rptItems" runat="server" DataSource='<%# Eval("Items") %>'>
                                            <ItemTemplate>
                                                <div class="item-row">
                                                    <span class='kind-badge <%# Eval("KindCss") %>'><%# Eval("Kind") %></span>
                                                    <%# Eval("Title") %>
                                                </div>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </asp:PlaceHolder>

            </main>
        </div>
    </form>
</body>
</html>
