<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TADashboard.aspx.cs" Inherits="Codercept.TADashboard" %>
<%@ Register Src="~/TASideBar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>TA Dashboard - Codercept</title>

    <!-- 1. Import Global Variables & Shared Layout -->
    <link href="css/global.css" rel="stylesheet" type="text/css" />

    <!-- 2. Page-Specific Styles -->
    <style>
        :root {
            --stat-card-bg: var(--bg-surface);
            --greeting-bg: rgba(30, 22, 51, 0.6);
            --greeting-border: rgba(124, 58, 237, 0.2);
            --warn: #fbbf24;
            --danger: #ef4444;
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
        .stat-card.attention .stat-value { color: var(--warn); }

        /* Section Headers */
        .section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; }
        .section-header h2 { font-size: 1.25rem; font-weight: 600; color: var(--text-primary); }
        .view-all { color: var(--accent-light); text-decoration: none; font-size: 0.9rem; font-weight: 500; transition: color 0.2s; }
        .view-all:hover { color: var(--accent-hover); text-decoration: underline; }

        /* Two-column layout for queue + forum */
        .panel-grid { display: grid; grid-template-columns: 3fr 2fr; gap: 1.5rem; margin-bottom: 3rem; align-items: start; }
        .panel { background: var(--bg-surface); border: 1px solid var(--border-light); border-radius: 12px; padding: 1.5rem; }
        .panel .section-header { margin-bottom: 1rem; }

        /* Grading queue table */
        .queue-table { width: 100%; border-collapse: collapse; }
        .queue-table th { text-align: left; font-size: 0.75rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.04em; color: var(--text-muted); padding: 0 0.75rem 0.75rem; border-bottom: 1px solid var(--border-light); }
        .queue-table td { padding: 0.85rem 0.75rem; border-bottom: 1px solid var(--border-light); font-size: 0.9rem; color: var(--text-secondary); vertical-align: middle; }
        .queue-table tr:last-child td { border-bottom: none; }
        .queue-table .learner-name { color: var(--text-primary); font-weight: 500; }
        .queue-table .assessment-title { color: var(--text-primary); }
        .queue-table .course-name { font-size: 0.8rem; color: var(--text-muted); margin-top: 0.2rem; }

        .type-badge { font-size: 0.7rem; font-weight: 600; padding: 0.15rem 0.5rem; border-radius: 4px; background: var(--accent-transparent); color: var(--accent-light); border: 1px solid rgba(124, 58, 237, 0.3); margin-right: 0.35rem; }
        .status-badge { font-size: 0.75rem; font-weight: 600; padding: 0.2rem 0.6rem; border-radius: 4px; white-space: nowrap; }
        .status-pending { color: var(--warn); background: rgba(251, 191, 36, 0.1); }
        .status-inprogress { color: var(--accent-light); background: var(--accent-transparent); }
        .status-returned { color: var(--danger); background: rgba(239, 68, 68, 0.1); }

        .btn-grade { display: inline-block; padding: 0.4rem 0.9rem; border-radius: 6px; background: var(--accent-primary); color: var(--text-primary); font-size: 0.8rem; font-weight: 600; text-decoration: none; transition: background 0.2s; }
        .btn-grade:hover { background: var(--accent-hover); }

        /* Forum activity list */
        .forum-list { display: flex; flex-direction: column; }
        .forum-item { padding: 0.9rem 0; border-bottom: 1px solid var(--border-light); text-decoration: none; display: block; }
        .forum-item:last-child { border-bottom: none; padding-bottom: 0; }
        .forum-item:first-child { padding-top: 0; }
        .forum-title { font-size: 0.95rem; font-weight: 500; color: var(--text-primary); margin-bottom: 0.35rem; }
        .forum-item:hover .forum-title { color: var(--accent-light); }
        .forum-meta { display: flex; flex-wrap: wrap; align-items: center; gap: 0.5rem; font-size: 0.8rem; color: var(--text-muted); }
        .flag-badge { font-size: 0.7rem; font-weight: 600; padding: 0.15rem 0.5rem; border-radius: 4px; }
        .flag-reported { color: var(--danger); background: rgba(239, 68, 68, 0.1); }
        .flag-unanswered { color: var(--warn); background: rgba(251, 191, 36, 0.1); }

        .empty-state { color: var(--text-muted); font-size: 0.9rem; padding: 1rem 0; text-align: center; }

        @media (max-width: 1100px) {
            .panel-grid { grid-template-columns: 1fr; }
        }
        @media (max-width: 1024px) {
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="dashboard-layout">

            <!-- Sidebar Injected Here -->
            <uc:Sidebar runat="server" ID="TASideBarCtrl" />

            <!-- Main Content -->
            <main class="main-content">

                <!-- Greeting -->
                <div class="greeting-section">
                    <h1>Welcome back, <asp:Literal ID="litWelcomeName" runat="server"></asp:Literal> 👋</h1>
                    <p><asp:Literal ID="litGreetingDesc" runat="server"></asp:Literal></p>
                </div>

                <!-- Overview Stats -->
                <div class="stats-grid">
                    <div class="stat-card attention">
                        <div class="stat-value"><asp:Literal ID="litStatPending" runat="server"></asp:Literal></div>
                        <div class="stat-label">Submissions to Mark</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value"><asp:Literal ID="litStatGraded" runat="server"></asp:Literal></div>
                        <div class="stat-label">Sent for Approval This Week</div>
                    </div>
                    <div class="stat-card attention">
                        <div class="stat-value"><asp:Literal ID="litStatReported" runat="server"></asp:Literal></div>
                        <div class="stat-label">Reported Posts</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-value"><asp:Literal ID="litStatUnanswered" runat="server"></asp:Literal></div>
                        <div class="stat-label">Unanswered Questions</div>
                    </div>
                </div>

                <div class="panel-grid">

                    <!-- Grading Queue -->
                    <section class="panel">
                        <div class="section-header">
                            <h2>Grading Queue</h2>
                            <a href="TAGrading.aspx" class="view-all">View full queue &rarr;</a>
                        </div>

                        <asp:PlaceHolder ID="phQueueEmpty" runat="server" Visible="false">
                            <p class="empty-state">All caught up — no submissions waiting for grading.</p>
                        </asp:PlaceHolder>

                        <asp:Repeater ID="rptGradingQueue" runat="server">
                            <HeaderTemplate>
                                <table class="queue-table">
                                    <thead>
                                        <tr>
                                            <th>Learner</th>
                                            <th>Assessment</th>
                                            <th>Submitted</th>
                                            <th>Status</th>
                                            <th></th>
                                        </tr>
                                    </thead>
                                    <tbody>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr>
                                    <td class="learner-name"><%# Eval("LearnerName") %></td>
                                    <td>
                                        <div class="assessment-title"><span class="type-badge"><%# Eval("Type") %></span><%# Eval("Title") %></div>
                                        <div class="course-name"><%# Eval("Course") %></div>
                                    </td>
                                    <td><%# Eval("Submitted") %></td>
                                    <td><span class='status-badge <%# Eval("StatusCss") %>'><%# Eval("Status") %></span></td>
                                    <td><a href='TAGrading.aspx?attempt=<%# Eval("AttemptId") %>' class="btn-grade">Grade</a></td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                    </tbody>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>
                    </section>

                    <!-- Forum Activity -->
                    <section class="panel">
                        <div class="section-header">
                            <h2>Forum Needs Attention</h2>
                            <a href="TAForumModeration.aspx" class="view-all">Open forum &rarr;</a>
                        </div>

                        <asp:PlaceHolder ID="phForumEmpty" runat="server" Visible="false">
                            <p class="empty-state">Nothing needs your attention right now.</p>
                        </asp:PlaceHolder>

                        <div class="forum-list">
                            <asp:Repeater ID="rptForumActivity" runat="server">
                                <ItemTemplate>
                                    <a href='TAForumModeration.aspx?post=<%# Eval("PostId") %>' class="forum-item">
                                        <div class="forum-title"><%# Eval("Title") %></div>
                                        <div class="forum-meta">
                                            <span class='flag-badge <%# Eval("FlagCss") %>'><%# Eval("Flag") %></span>
                                            <span>by <%# Eval("Author") %></span>
                                            <span>&middot; <%# Eval("Posted") %></span>
                                        </div>
                                    </a>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </section>

                </div>

            </main>
        </div>
    </form>
</body>
</html>
