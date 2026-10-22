<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TAForumModeration.aspx.cs" Inherits="Codercept.TAForumModeration" %>
<%@ Register Src="~/TASideBar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Forum Moderation - Codercept</title>

    <!-- 1. Import Global Variables & Shared Layout -->
    <link href="css/global.css" rel="stylesheet" type="text/css" />

    <!-- 2. Page-Specific Styles -->
    <style>
        :root {
            --panel-bg: var(--bg-surface);
            --warn: #fbbf24;
            --danger: #ef4444;
            --success: #34d399;
            --input-bg: var(--bg-main);

            /* Roles (same palette as the learner forum) */
            --role-learner: #60a5fa;
            --role-ta: #fb923c;
            --role-teacher: #c084fc;
        }

        /* Override main-content for a fixed split-screen layout */
        .main-content { display: flex; flex-direction: column; overflow: hidden; padding-bottom: 0; }

        .page-header { margin-bottom: 1.25rem; }
        .page-header h1 { font-size: 1.75rem; margin-bottom: 0.25rem; color: var(--text-primary); }
        .page-header p { color: var(--text-secondary); font-size: 1rem; }

        .forum-container { display: flex; flex: 1; gap: 1.5rem; overflow: hidden; padding-bottom: 2rem; }

        /* Search */
        .search-wrap { padding: 0.75rem 0.75rem 0; background: rgba(255, 255, 255, 0.02); }
        .search-box { width: 100%; background: var(--input-bg); border: 1px solid var(--border-light); border-radius: 8px; padding: 0.6rem 0.85rem; color: var(--text-primary); font-size: 0.85rem; outline: none; transition: border-color 0.2s; }
        .search-box:focus { border-color: var(--accent-primary); }
        #noSearchResults { display: none; }

        /* LEFT: post list */
        .posts-column { width: 380px; flex-shrink: 0; display: flex; flex-direction: column; background: var(--panel-bg); border: 1px solid var(--border-light); border-radius: 12px; overflow: hidden; }
        .filter-tabs { display: flex; gap: 0.25rem; padding: 0.75rem; border-bottom: 1px solid var(--border-light); background: rgba(255, 255, 255, 0.02); }
        .filter-tab { flex: 1; text-align: center; padding: 0.5rem 0.15rem; border-radius: 6px; font-size: 0.75rem; white-space: nowrap; font-weight: 600; color: var(--text-secondary); text-decoration: none; transition: all 0.2s; }
        .filter-tab:hover { background: var(--accent-transparent); color: var(--accent-light); }
        .filter-tab.active { background: var(--accent-primary); color: var(--text-primary); }
        .filter-count { opacity: 0.7; font-weight: 500; margin-left: 0.2rem; }

        .post-list { flex: 1; overflow-y: auto; display: flex; flex-direction: column; }
        .post-item { display: block; padding: 1rem 1.25rem; border-bottom: 1px solid var(--border-light); text-decoration: none; border-left: 3px solid transparent; transition: background 0.2s; }
        .post-item:hover { background: rgba(255, 255, 255, 0.03); }
        .post-item.selected { background: var(--accent-transparent); border-left-color: var(--accent-primary); }
        .post-item-title { font-size: 0.95rem; font-weight: 600; color: var(--text-primary); margin-bottom: 0.4rem; line-height: 1.4; }
        .post-item-meta { display: flex; flex-wrap: wrap; align-items: center; gap: 0.5rem; font-size: 0.75rem; color: var(--text-muted); }

        .flag-badge { font-size: 0.7rem; font-weight: 600; padding: 0.15rem 0.5rem; border-radius: 4px; }
        .flag-reported { color: var(--danger); background: rgba(239, 68, 68, 0.1); }
        .flag-unanswered { color: var(--warn); background: rgba(251, 191, 36, 0.1); }
        .flag-escalated { color: #60a5fa; background: rgba(96, 165, 250, 0.1); }
        .flag-ok { color: var(--success); background: rgba(52, 211, 153, 0.1); }

        .empty-state { color: var(--text-muted); font-size: 0.9rem; padding: 2rem 1rem; text-align: center; }

        /* RIGHT: thread panel */
        .thread-column { flex: 1; min-width: 0; display: flex; flex-direction: column; background: var(--panel-bg); border: 1px solid var(--border-light); border-radius: 12px; overflow: hidden; }
        .thread-body { flex: 1; overflow-y: auto; padding: 1.5rem; display: flex; flex-direction: column; gap: 1.25rem; }

        .original-post h2 { font-size: 1.35rem; color: var(--text-primary); margin-bottom: 0.5rem; line-height: 1.4; }
        .post-byline { display: flex; flex-wrap: wrap; align-items: center; gap: 0.5rem; font-size: 0.85rem; color: var(--text-muted); margin-bottom: 1rem; }
        .post-content { font-size: 0.95rem; color: var(--text-secondary); line-height: 1.7; white-space: pre-wrap; }

        /* Moderation toolbar */
        .mod-card { border: 1px solid var(--border-light); background: rgba(255, 255, 255, 0.02); border-radius: 10px; padding: 1.25rem; }
        .mod-card.reported { border-color: rgba(239, 68, 68, 0.3); background: rgba(239, 68, 68, 0.05); }
        .mod-card h3 { font-size: 0.95rem; color: var(--text-primary); margin-bottom: 0.25rem; }
        .mod-card h3 { margin-bottom: 0.75rem; }
        .mod-card .report-reason { font-size: 0.85rem; color: var(--danger); margin-bottom: 0.9rem; }
        .mod-actions { display: flex; flex-wrap: wrap; gap: 0.75rem; margin-top: 0.75rem; }

        .form-control { width: 100%; background: var(--input-bg); border: 1px solid var(--border-light); border-radius: 8px; padding: 0.7rem 0.9rem; color: var(--text-primary); font-size: 0.9rem; outline: none; transition: border-color 0.2s; resize: vertical; }
        .form-control:focus { border-color: var(--accent-primary); }

        .btn { padding: 0.55rem 1.1rem; border-radius: 8px; font-weight: 600; font-size: 0.85rem; cursor: pointer; transition: all 0.2s; border: none; }
        .btn-primary { background: var(--accent-primary); color: #ffffff; }
        .btn-primary:hover { background: var(--accent-hover); }
        .btn-secondary { background: rgba(255, 255, 255, 0.05); color: var(--text-secondary); }
        .btn-secondary:hover { background: rgba(255, 255, 255, 0.1); color: var(--text-primary); }
        .btn-danger { background: rgba(239, 68, 68, 0.1); color: var(--danger); }
        .btn-danger:hover { background: var(--danger); color: #ffffff; }

        /* Ask Teacher / escalation */
        .ask-card { border: 1px solid rgba(96, 165, 250, 0.3); background: rgba(96, 165, 250, 0.05); border-radius: 10px; padding: 1.25rem; }
        .ask-card h3 { font-size: 0.95rem; color: var(--text-primary); margin-bottom: 0.25rem; }
        .ask-card p { font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 0.75rem; }
        .escalated-banner { border: 1px solid rgba(96, 165, 250, 0.3); background: rgba(96, 165, 250, 0.08); border-radius: 10px; padding: 1rem 1.25rem; font-size: 0.9rem; color: var(--text-secondary); line-height: 1.5; }
        .escalated-banner strong { color: #60a5fa; }

        /* Replies */
        .replies-title { font-size: 0.9rem; font-weight: 600; color: var(--text-primary); padding-top: 0.5rem; border-top: 1px solid var(--border-light); }
        .reply-item { border: 1px solid var(--border-light); border-radius: 10px; padding: 1rem 1.25rem; background: rgba(255, 255, 255, 0.02); }
        .reply-item.pinned { border-color: var(--accent-primary); background: var(--accent-transparent); }
        .reply-item.flagged { border-color: rgba(239, 68, 68, 0.3); background: rgba(239, 68, 68, 0.05); }
        .reply-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem; gap: 1rem; }
        .reply-author { display: flex; align-items: center; gap: 0.5rem; font-size: 0.9rem; font-weight: 600; color: var(--text-primary); }
        .role-tag { font-size: 0.7rem; font-weight: 700; padding: 0.1rem 0.45rem; border-radius: 4px; background: rgba(255, 255, 255, 0.06); }
        .role-learner { color: var(--role-learner); }
        .role-ta { color: var(--role-ta); }
        .role-teacher { color: var(--role-teacher); }
        .pin-tag { font-size: 0.7rem; font-weight: 600; color: var(--accent-light); }
        .reply-time { font-size: 0.75rem; color: var(--text-muted); }
        .reply-content { font-size: 0.9rem; color: var(--text-secondary); line-height: 1.6; white-space: pre-wrap; }
        .reply-actions { display: flex; gap: 0.5rem; margin-top: 0.75rem; }
        .link-action { background: none; border: none; font-size: 0.8rem; font-weight: 600; color: var(--text-muted); cursor: pointer; padding: 0.2rem 0.5rem; border-radius: 4px; text-decoration: none; transition: all 0.2s; }
        .link-action:hover { background: rgba(255, 255, 255, 0.06); color: var(--accent-light); }
        .link-action.danger:hover { color: var(--danger); }

        /* Reply composer */
        .composer { padding: 1rem 1.5rem; border-top: 1px solid var(--border-light); background: rgba(255, 255, 255, 0.02); display: flex; gap: 0.75rem; align-items: flex-end; }
        .composer .form-control { flex: 1; }

        .toast { margin: 1rem 1.5rem 0; padding: 0.75rem 1rem; border-radius: 8px; font-size: 0.9rem; color: var(--success); background: rgba(52, 211, 153, 0.1); border: 1px solid rgba(52, 211, 153, 0.3); }

        @media (max-width: 1100px) {
            .main-content { overflow-y: auto; }
            .forum-container { flex-direction: column; overflow: visible; }
            .posts-column { width: 100%; max-height: 360px; }
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

                <div class="page-header">
                    <h1>Forum Moderation</h1>
                    <p>Review any post, answer learner questions and remove content that breaks the community guidelines.</p>
                </div>

                <div class="forum-container">

                    <!-- LEFT: Post list -->
                    <section class="posts-column">
                        <div class="search-wrap">
                            <input type="search" id="postSearch" class="search-box" placeholder="Search posts by title, author or keyword..." autocomplete="off" />
                        </div>

                        <div class="filter-tabs">
                            <a href="TAForumModeration.aspx?filter=all" class="filter-tab <%= GetTabClass("all") %>">All<span class="filter-count"><asp:Literal ID="litCountAll" runat="server"></asp:Literal></span></a>
                            <a href="TAForumModeration.aspx?filter=reported" class="filter-tab <%= GetTabClass("reported") %>">Reported<span class="filter-count"><asp:Literal ID="litCountReported" runat="server"></asp:Literal></span></a>
                            <a href="TAForumModeration.aspx?filter=unanswered" class="filter-tab <%= GetTabClass("unanswered") %>">Unanswered<span class="filter-count"><asp:Literal ID="litCountUnanswered" runat="server"></asp:Literal></span></a>
                            <a href="TAForumModeration.aspx?filter=escalated" class="filter-tab <%= GetTabClass("escalated") %>">Escalated<span class="filter-count"><asp:Literal ID="litCountEscalated" runat="server"></asp:Literal></span></a>
                        </div>

                        <div class="post-list">
                            <asp:PlaceHolder ID="phListEmpty" runat="server" Visible="false">
                                <p class="empty-state">No posts in this category.</p>
                            </asp:PlaceHolder>
                            <p id="noSearchResults" class="empty-state">No posts match your search.</p>

                            <asp:Repeater ID="rptPosts" runat="server">
                                <ItemTemplate>
                                    <a href='TAForumModeration.aspx?filter=<%= CurrentFilter %>&post=<%# Eval("PostId") %>' class='post-item <%# Eval("CssClass") %>'>
                                        <div class="post-item-title"><%# Server.HtmlEncode(Convert.ToString(Eval("Title"))) %></div>
                                        <div class="post-item-meta">
                                            <span class='flag-badge <%# Eval("FlagCss") %>'><%# Eval("Flag") %></span>
                                            <span>by <%# Server.HtmlEncode(Convert.ToString(Eval("Author"))) %></span>
                                            <span>&middot; <%# Eval("Posted") %></span>
                                            <span>&middot; <%# Eval("ReplyCount") %> replies</span>
                                        </div>
                                    </a>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </section>

                    <!-- RIGHT: Thread -->
                    <section class="thread-column">

                        <asp:PlaceHolder ID="phNoSelection" runat="server" Visible="false">
                            <p class="empty-state">Select a post from the list to review it.</p>
                        </asp:PlaceHolder>

                        <asp:PlaceHolder ID="phThread" runat="server">

                            <asp:Panel ID="pnlMessage" runat="server" CssClass="toast" Visible="false">
                                <asp:Literal ID="litMessage" runat="server"></asp:Literal>
                            </asp:Panel>

                            <div class="thread-body">

                                <div class="original-post">
                                    <h2><asp:Literal ID="litPostTitle" runat="server"></asp:Literal></h2>
                                    <div class="post-byline">
                                        <span>Posted by <strong><asp:Literal ID="litPostAuthor" runat="server"></asp:Literal></strong></span>
                                        <span>&middot; <asp:Literal ID="litPostTime" runat="server"></asp:Literal></span>
                                    </div>
                                    <div class="post-content"><asp:Literal ID="litPostContent" runat="server"></asp:Literal></div>
                                </div>

                                <!-- Moderation tools (available on every post; report info only shows if the post was reported) -->
                                <asp:Panel ID="pnlModeration" runat="server" CssClass="mod-card">
                                    <h3>🛡 Moderation</h3>
                                    <asp:Panel ID="pnlReportInfo" runat="server" CssClass="report-reason" Visible="false">
                                        ⚠ Reported: <asp:Literal ID="litReportReason" runat="server"></asp:Literal>
                                    </asp:Panel>
                                    <asp:TextBox ID="txtModReason" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="Reason for your decision (required to remove this post)"></asp:TextBox>
                                    <div class="mod-actions">
                                        <asp:Button ID="btnDismissReport" runat="server" Text="Dismiss Report" CssClass="btn btn-secondary" OnClick="btnDismissReport_Click" />
                                        <asp:Button ID="btnRemovePost" runat="server" Text="Remove Post" CssClass="btn btn-danger" OnClientClick="return confirm('Remove this post? It will be hidden from all learners.');" OnClick="btnRemovePost_Click" />
                                    </div>
                                </asp:Panel>

                                <!-- Ask Teacher: escalate questions the TA cannot answer -->
                                <asp:Panel ID="pnlAskTeacher" runat="server" CssClass="ask-card">
                                    <h3>Need the teacher's help?</h3>
                                    <p>Escalate this post if it needs a teacher's answer or decision. The teacher will be notified.</p>
                                    <asp:TextBox ID="txtTeacherNote" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="What do you need the teacher to look at? (required)"></asp:TextBox>
                                    <div class="mod-actions">
                                        <asp:Button ID="btnAskTeacher" runat="server" Text="Ask Teacher" CssClass="btn btn-primary" OnClick="btnAskTeacher_Click" />
                                    </div>
                                </asp:Panel>

                                <asp:Panel ID="pnlEscalated" runat="server" CssClass="escalated-banner" Visible="false">
                                    <strong>Escalated to teacher.</strong> <asp:Literal ID="litEscalationNote" runat="server"></asp:Literal>
                                </asp:Panel>

                                <div class="replies-title"><asp:Literal ID="litReplyCount" runat="server"></asp:Literal></div>

                                <asp:Repeater ID="rptReplies" runat="server" OnItemCommand="rptReplies_ItemCommand">
                                    <ItemTemplate>
                                        <div class='reply-item <%# Eval("CssClass") %>'>
                                            <div class="reply-top">
                                                <div class="reply-author">
                                                    <%# Server.HtmlEncode(Convert.ToString(Eval("Author"))) %>
                                                    <span class='role-tag <%# Eval("RoleCss") %>'><%# Eval("Role") %></span>
                                                    <span class="pin-tag" runat="server" visible='<%# Eval("IsPinned") %>'>📌 Pinned</span>
                                                </div>
                                                <span class="reply-time"><%# Eval("Posted") %></span>
                                            </div>
                                            <div class="reply-content"><%# Server.HtmlEncode(Convert.ToString(Eval("Content"))) %></div>
                                            <div class="reply-actions">
                                                <asp:LinkButton ID="lnkPin" runat="server" CssClass="link-action" CommandName="Pin" CommandArgument='<%# Eval("ThreadId") %>' Text='<%# (bool)Eval("IsPinned") ? "Unpin" : "Pin" %>'></asp:LinkButton>
                                                <asp:LinkButton ID="lnkDelete" runat="server" CssClass="link-action danger" CommandName="Delete" CommandArgument='<%# Eval("ThreadId") %>' OnClientClick="return confirm('Delete this reply?');" Text="Delete"></asp:LinkButton>
                                            </div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>

                            <div class="composer">
                                <asp:TextBox ID="txtReply" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="Write a reply as a Teaching Assistant..."></asp:TextBox>
                                <asp:Button ID="btnReply" runat="server" Text="Reply" CssClass="btn btn-primary" OnClick="btnReply_Click" />
                            </div>

                        </asp:PlaceHolder>
                    </section>
                </div>

            </main>
        </div>
    </form>

    <script>
        // Instant client-side search over the posts already on the page
        (function () {
            var box = document.getElementById('postSearch');
            var empty = document.getElementById('noSearchResults');
            if (!box) return;
            box.addEventListener('keydown', function (e) { if (e.key === 'Enter') e.preventDefault(); });
            box.addEventListener('input', function () {
                var q = box.value.trim().toLowerCase();
                var items = document.querySelectorAll('.post-item');
                var shown = 0;
                items.forEach(function (item) {
                    var match = !q || item.textContent.toLowerCase().indexOf(q) !== -1;
                    item.style.display = match ? '' : 'none';
                    if (match) shown++;
                });
                if (empty) empty.style.display = (q && items.length > 0 && shown === 0) ? 'block' : 'none';
            });
        })();
    </script>
</body>
</html>
