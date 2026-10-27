<%@ Page Title="TA Dashboard - Codercept" Language="C#" AutoEventWireup="true" CodeBehind="TADashboard.aspx.cs" Inherits="Codercept.TADashboard" MasterPageFile="~/TASite.master" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        .tp-app .stat-topline .badge {
            position: static !important;
            margin-left: auto !important;
            padding: 2px 8px !important;
            font-size: 11px !important;
            font-weight: 700 !important;
            transform: none !important;
        }

        .dashboard-panels-grid {
            display: grid;
            grid-template-columns: minmax(0, 1.45fr) minmax(0, 1fr);
            gap: 24px;
            margin-top: 28px;
            align-items: start;
        }

        .dashboard-section {
            margin-top: 0;
        }

        .section-heading {
            margin-bottom: 14px;
        }

        .section-heading h2 {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--heading);
            margin: 0;
        }

        .section-heading p {
            margin-top: 4px;
            color: var(--muted);
            font-size: 0.88rem;
        }

        .tp-app .panel {
            background: #ffffff;
            border: 1px solid #e9e5f5;
            border-radius: 16px;
            box-shadow: 0 1px 3px rgba(76, 29, 149, 0.04);
            overflow: hidden;
        }

        .queue-list,
        .forum-list {
            padding: 8px 24px 16px;
        }

        .queue-row {
            display: grid;
            grid-template-columns: minmax(0, 1fr) auto auto;
            align-items: center;
            gap: 16px 20px;
            padding: 18px 0;
            border-bottom: 1px solid #f3f4f6;
        }
        .queue-row:first-child {
            padding-top: 14px;
        }
        .queue-row:last-child {
            border-bottom: none;
            padding-bottom: 8px;
        }

        .queue-main {
            min-width: 0;
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .learner-name {
            color: var(--heading);
            font-weight: 700;
            font-size: 0.98rem;
            line-height: 1.3;
        }
        .assessment-title {
            color: #4b5563;
            font-size: 0.92rem;
            display: flex;
            align-items: center;
            gap: 6px;
            flex-wrap: wrap;
        }
        .queue-meta {
            font-size: 0.82rem;
            color: var(--muted);
        }

        .type-badge {
            font-size: 0.72rem;
            font-weight: 700;
            padding: 0.18rem 0.55rem;
            border-radius: 5px;
            background: var(--indigo-tint);
            color: var(--indigo);
            border: 1px solid #c7d2fe;
            display: inline-block;
        }

        .forum-item {
            display: block;
            padding: 18px 0;
            border-bottom: 1px solid #f3f4f6;
            text-decoration: none;
            transition: color 0.15s ease;
        }
        .forum-item:first-child {
            padding-top: 14px;
        }
        .forum-item:last-child {
            border-bottom: none;
            padding-bottom: 8px;
        }
        .forum-title {
            font-size: 0.98rem;
            font-weight: 700;
            line-height: 1.45;
            color: var(--heading);
            margin-bottom: 6px;
        }
        .forum-item:hover .forum-title {
            color: var(--indigo);
        }
        .forum-meta {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 0.82rem;
            color: var(--muted);
        }

        .summary-empty {
            padding: 2.5rem 1.5rem;
            text-align: center;
            color: var(--muted);
            font-size: 0.92rem;
        }

        @media (max-width: 900px) {
            .dashboard-panels-grid {
                grid-template-columns: 1fr;
            }
            .queue-list,
            .forum-list {
                padding: 4px 16px 12px;
            }
        }
    </style>
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <div class="page-heading">
        <div>
            <span class="eyebrow">OVERVIEW</span>
            <h1>Dashboard</h1>
        </div>
    </div>

    <!-- Welcome Banner matching Teacher Dashboard -->
    <section class="welcome-banner">
        <div class="welcome-pattern" aria-hidden="true">
            <span>&lt;/&gt;</span>
            <span>{ }</span>
            <span>01</span>
        </div>
        <div class="welcome-copy">
            <span class="badge badge--indigo">Teaching assistant workspace</span>
            <h2>Welcome back, <asp:Literal ID="litWelcomeName" runat="server"></asp:Literal>!</h2>
            <p><asp:Literal ID="litGreetingDesc" runat="server"></asp:Literal></p>
        </div>
        <div class="welcome-actions">
            <a class="button button--white" href="TAGrading.aspx"><%= TeacherIcons.Svg("grade", 17) %><span>Start grading</span></a>
            <a class="button button--secondary" href="TAForumModeration.aspx"><%= TeacherIcons.Svg("chat", 17) %><span>Open forum</span></a>
        </div>
    </section>

    <!-- Overview Stats matching Teacher Stat Cards -->
    <section aria-labelledby="statistics-heading">
        <h2 class="sr-only" id="statistics-heading">Dashboard statistics</h2>
        <div class="stats-grid" style="grid-template-columns: repeat(3, minmax(0, 1fr));">
            <article class="stat-card" style="position: relative; overflow: hidden;">
                <div class="stat-icon stat-icon--amber"><%= TeacherIcons.Svg("grade", 20) %></div>
                <div class="stat-topline" style="display: flex; align-items: center; justify-content: space-between; gap: 8px;">
                    <span class="stat-label">Submissions to Mark</span>
                    <span class="badge badge--warning" style="position: static !important; transform: none !important; margin-left: auto; padding: 2px 8px; font-size: 11px; font-weight: 700;">Action</span>
                </div>
                <strong class="stat-value"><asp:Literal ID="litStatPending" runat="server"></asp:Literal></strong>
                <span class="stat-hint">Pending provisional grading</span>
            </article>
            <article class="stat-card">
                <div class="stat-icon stat-icon--indigo"><%= TeacherIcons.Svg("clock", 20) %></div>
                <div class="stat-topline">
                    <span class="stat-label">Awaiting Approval</span>
                </div>
                <strong class="stat-value"><asp:Literal ID="litStatAwaiting" runat="server"></asp:Literal></strong>
                <span class="stat-hint">Teacher verification</span>
            </article>
            <article class="stat-card">
                <div class="stat-icon stat-icon--teal"><%= TeacherIcons.Svg("question", 20) %></div>
                <div class="stat-topline">
                    <span class="stat-label">Unsolved Questions</span>
                </div>
                <strong class="stat-value"><asp:Literal ID="litStatUnsolved" runat="server"></asp:Literal></strong>
                <span class="stat-hint">Learner forum inquiries</span>
            </article>
        </div>
    </section>

    <div class="dashboard-panels-grid">
        <!-- Grading Queue Section -->
        <section class="dashboard-section">
            <div class="section-heading section-heading--row">
                <div>
                    <h2>Provisional Grading Queue</h2>
                    <p>Recent learner submissions waiting for review.</p>
                </div>
                <a class="text-link" href="TAGrading.aspx">View all <%= TeacherIcons.Svg("arrow", 14) %></a>
            </div>

            <div class="panel">
                <asp:PlaceHolder ID="phQueueEmpty" runat="server" Visible="false">
                    <p class="summary-empty">All caught up — no submissions waiting for grading.</p>
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
                            <div>
                                <span class='badge badge--<%# Eval("Status").ToString() == "Pending" ? "warning" : "secondary" %>'><%# Eval("Status") %></span>
                            </div>
                            <a href='TAGradeAssessments.aspx?course=<%# Eval("CourseId") %>&submission=<%# Eval("AttemptId") %>' class="button button--primary" style="font-size: 0.82rem; padding: 0.45rem 0.9rem;">
                                <%= TeacherIcons.Svg("check", 14) %><span>Grade</span>
                            </a>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate></div></FooterTemplate>
                </asp:Repeater>
            </div>
        </section>

        <!-- Forum Activity Section -->
        <section class="dashboard-section">
            <div class="section-heading section-heading--row">
                <div>
                    <h2>Forum Inquiries</h2>
                    <p>Learner questions awaiting response.</p>
                </div>
                <a class="text-link" href="TAForumModeration.aspx">Open forum <%= TeacherIcons.Svg("arrow", 14) %></a>
            </div>

            <div class="panel">
                <asp:PlaceHolder ID="phForumEmpty" runat="server" Visible="false">
                    <p class="summary-empty">Nothing needs attention right now.</p>
                </asp:PlaceHolder>

                <div class="forum-list">
                    <asp:Repeater ID="rptForumActivity" runat="server">
                        <ItemTemplate>
                            <a href='TAForumModeration.aspx?post=<%# Eval("PostId") %>' class="forum-item">
                                <div class="forum-title"><%# Eval("Title") %></div>
                                <div class="forum-meta">
                                    <span class="badge badge--warning"><%# Eval("Flag") %></span>
                                    <span>by <%# Eval("Author") %></span>
                                    <span>&middot; <%# Eval("Posted") %></span>
                                </div>
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </section>
    </div>
</asp:Content>
