<%@ Page Title="TA Dashboard - Codercept" Language="C#" AutoEventWireup="true" CodeBehind="TADashboard.aspx.cs" Inherits="Codercept.TADashboard" MasterPageFile="~/TASite.master" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        :root {
            --stat-card-bg: var(--bg-surface);
            --greeting-bg: rgba(30, 22, 51, 0.6);
            --greeting-border: rgba(124, 58, 237, 0.2);
            --warn: #fbbf24;
            --danger: #ef4444;
        }

        /* Greeting */
        .greeting-section { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 1.25rem; background: var(--greeting-bg); border: 1px solid var(--greeting-border); padding: 2rem 2.25rem; border-radius: 16px; margin-bottom: 2rem; backdrop-filter: blur(10px); }
        .greeting-section h1 { font-size: 1.85rem; line-height: 1.25; margin-bottom: 0.4rem; color: var(--text-primary); }
        .greeting-section p { color: var(--text-secondary); font-size: 1rem; line-height: 1.5; }
        .greeting-actions { display: flex; flex-wrap: wrap; gap: 0.75rem; }
        .btn-quick { display: inline-block; padding: 0.65rem 1.25rem; border-radius: 8px; font-size: 0.9rem; font-weight: 600; text-decoration: none; color: var(--text-primary); border: 1px solid var(--border-light); background: rgba(255, 255, 255, 0.04); transition: background 0.2s, border-color 0.2s; }
        .btn-quick:hover { background: rgba(255, 255, 255, 0.09); border-color: var(--accent-primary); }
        .btn-quick.primary { background: var(--accent-primary); border-color: var(--accent-primary); }
        .btn-quick.primary:hover { background: var(--accent-hover); }

        /* Overview stats: cards share the row and only wrap when truly narrow */
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(190px, 1fr)); gap: 1.25rem; margin-bottom: 2rem; }
        .stat-card { background: var(--stat-card-bg); border: 1px solid var(--border-light); padding: 1.5rem 1.75rem; border-radius: 14px; display: flex; flex-direction: column; justify-content: center; gap: 0.35rem; }
        .stat-value { font-size: 2.25rem; line-height: 1; font-weight: 700; color: var(--text-primary); }
        .stat-label { font-size: 0.9rem; color: var(--text-secondary); }
        .stat-card.attention { border-color: rgba(251, 191, 36, 0.35); }
        .stat-card.attention .stat-value { color: var(--warn); }

        /* Section headers */
        .section-header { display: flex; justify-content: space-between; align-items: center; gap: 1rem; margin-bottom: 1.25rem; }
        .section-header h2 { font-size: 1.2rem; font-weight: 600; color: var(--text-primary); }
        .view-all { color: var(--accent-light); text-decoration: none; font-size: 0.9rem; font-weight: 500; white-space: nowrap; transition: color 0.2s; }
        .view-all:hover { color: var(--accent-hover); text-decoration: underline; }

        /* Queue and forum stack by default and sit side by side only on wide screens */
        .panel-grid { display: grid; grid-template-columns: minmax(0, 1fr); gap: 1.5rem; margin-bottom: 3rem; align-items: start; }
        .panel { background: var(--bg-surface); border: 1px solid var(--border-light); border-radius: 16px; padding: 1.75rem; min-width: 0; }

        /* Grading queue rows */
        .queue-list { display: flex; flex-direction: column; }
        .queue-row { display: grid; grid-template-columns: minmax(0, 1fr) auto auto; align-items: center; gap: 1rem 1.5rem; padding: 1rem 0; border-bottom: 1px solid var(--border-light); }
        .queue-row:first-child { padding-top: 0; }
        .queue-row:last-child { border-bottom: none; padding-bottom: 0; }
        .queue-main { min-width: 0; }
        .learner-name { color: var(--text-primary); font-weight: 600; font-size: 0.95rem; margin-bottom: 0.3rem; }
        .assessment-title { color: var(--text-secondary); font-size: 0.9rem; overflow-wrap: anywhere; }
        .queue-meta { font-size: 0.8rem; color: var(--text-muted); margin-top: 0.3rem; }

        .type-badge { font-size: 0.7rem; font-weight: 600; padding: 0.15rem 0.5rem; border-radius: 4px; background: var(--accent-transparent); color: var(--accent-light); border: 1px solid rgba(124, 58, 237, 0.3); margin-right: 0.5rem; }
        .status-badge { font-size: 0.75rem; font-weight: 600; padding: 0.25rem 0.7rem; border-radius: 999px; white-space: nowrap; }
        .status-pending { color: var(--warn); background: rgba(251, 191, 36, 0.12); }
        .status-inprogress { color: var(--accent-light); background: var(--accent-transparent); }

        .btn-grade { display: inline-block; padding: 0.5rem 1.1rem; border-radius: 8px; background: var(--accent-primary); color: var(--text-primary); font-size: 0.85rem; font-weight: 600; text-decoration: none; transition: background 0.2s; }
        .btn-grade:hover { background: var(--accent-hover); }

        /* Forum activity list */
        .forum-list { display: flex; flex-direction: column; }
        .forum-item { padding: 1rem 0; border-bottom: 1px solid var(--border-light); text-decoration: none; display: block; }
        .forum-item:last-child { border-bottom: none; padding-bottom: 0; }
        .forum-item:first-child { padding-top: 0; }
        .forum-title { font-size: 0.95rem; font-weight: 500; line-height: 1.4; color: var(--text-primary); margin-bottom: 0.45rem; overflow-wrap: anywhere; }
        .forum-item:hover .forum-title { color: var(--accent-light); }
        .forum-meta { display: flex; flex-wrap: wrap; align-items: center; gap: 0.35rem 0.6rem; font-size: 0.8rem; color: var(--text-muted); }
        .flag-badge { font-size: 0.7rem; font-weight: 600; padding: 0.15rem 0.55rem; border-radius: 999px; }
        .flag-unsolved { color: var(--warn); background: rgba(251, 191, 36, 0.12); }

        .empty-state { color: var(--text-muted); font-size: 0.9rem; padding: 1rem 0; text-align: center; }

        @media (min-width: 1280px) {
            .panel-grid { grid-template-columns: minmax(0, 1.7fr) minmax(300px, 1fr); }
        }
        @media (max-width: 640px) {
            .greeting-section { padding: 1.5rem; }
            .greeting-section h1 { font-size: 1.5rem; }
            .panel { padding: 1.25rem; }
            .queue-row { grid-template-columns: minmax(0, 1fr) auto; }
            .queue-row .status-cell { grid-column: 1; grid-row: 2; }
            .queue-row .btn-grade { grid-column: 2; grid-row: 1 / span 2; }
        }
    </style>
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">

        <!-- Greeting -->
        <div class="greeting-section">
            <div>
                <h1>Welcome back, <asp:Literal ID="litWelcomeName" runat="server"></asp:Literal> 👋</h1>
                <p><asp:Literal ID="litGreetingDesc" runat="server"></asp:Literal></p>
            </div>
            <div class="greeting-actions">
                <a href="TAGrading.aspx" class="btn-quick primary">Start grading</a>
                <a href="TAForumModeration.aspx" class="btn-quick">Open forum</a>
            </div>
        </div>

        <!-- Overview Stats -->
        <div class="stats-grid">
            <div class="stat-card attention">
                <div class="stat-value"><asp:Literal ID="litStatPending" runat="server"></asp:Literal></div>
                <div class="stat-label">Submissions to Mark</div>
            </div>
            <div class="stat-card">
                <div class="stat-value"><asp:Literal ID="litStatAwaiting" runat="server"></asp:Literal></div>
                <div class="stat-label">Awaiting Approval</div>
            </div>
            <div class="stat-card">
                <div class="stat-value"><asp:Literal ID="litStatUnsolved" runat="server"></asp:Literal></div>
                <div class="stat-label">Unsolved Questions</div>
            </div>
        </div>

        <div class="panel-grid">

            <!-- Grading Queue -->
            <section class="panel">
                <div class="section-header">
                    <h2>Provisional Grading</h2>
                    <a href="TAGrading.aspx" class="view-all">Open grading &rarr;</a>
                </div>

                <asp:PlaceHolder ID="phQueueEmpty" runat="server" Visible="false">
                    <p class="empty-state">All caught up — no submissions waiting for grading.</p>
                </asp:PlaceHolder>

                <asp:Repeater ID="rptGradingQueue" runat="server">
                    <HeaderTemplate><div class="queue-list"></HeaderTemplate>
                    <ItemTemplate>
                        <div class="queue-row">
                            <div class="queue-main">
                                <div class="learner-name"><%# Eval("LearnerName") %></div>
                                <div class="assessment-title"><span class="type-badge"><%# Eval("Type") %></span><%# Eval("Title") %></div>
                                <div class="queue-meta"><%# Eval("Course") %> &middot; <%# Eval("Submitted") %></div>
                            </div>
                            <div class="status-cell"><span class='status-badge <%# Eval("StatusCss") %>'><%# Eval("Status") %></span></div>
                            <a href='TAGrading.aspx?attempt=<%# Eval("AttemptId") %>' class="btn-grade">Grade</a>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate></div></FooterTemplate>
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
</asp:Content>
