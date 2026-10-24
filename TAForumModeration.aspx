<%@ Page Title="Forum - Codercept" Language="C#" AutoEventWireup="true" CodeBehind="TAForumModeration.aspx.cs" Inherits="Codercept.TAForumModeration" MasterPageFile="~/TASite.master" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
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

        /* LEFT: post list */
        .posts-column { width: 330px; flex-shrink: 0; display: flex; flex-direction: column; background: var(--panel-bg); border: 1px solid var(--border-light); border-radius: 16px; overflow: hidden; }
        .posts-toolbar { display: flex; flex-direction: column; gap: 0.75rem; padding: 1rem 1.1rem; border-bottom: 1px solid var(--border-light); }
        .search-box { width: 100%; background: var(--input-bg); border: 1px solid var(--border-light); border-radius: 10px; padding: 0.65rem 0.9rem; color: var(--text-primary); font-size: 0.9rem; outline: none; transition: border-color 0.2s; }
        .search-box:focus { border-color: var(--accent-primary); }
        #noSearchResults { display: none; }
        .filter-dropdown { position: relative; }
        .filter-button { width: 100%; display: flex; align-items: center; justify-content: space-between; gap: 0.5rem; padding: 0.65rem 0.9rem; border-radius: 10px; border: 1px solid var(--border-light); background: rgba(255, 255, 255, 0.04); color: var(--text-primary); font-size: 0.9rem; font-weight: 600; cursor: pointer; transition: border-color 0.2s; }
        .filter-button:hover, .filter-dropdown.open .filter-button { border-color: var(--accent-primary); }
        .filter-button .chev { transition: transform 0.2s; }
        .filter-dropdown.open .chev { transform: rotate(180deg); }
        .filter-menu { display: none; position: absolute; top: calc(100% + 0.35rem); left: 0; right: 0; z-index: 20; background: #1b1530; border: 1px solid var(--border-light); border-radius: 10px; padding: 0.35rem; box-shadow: 0 12px 32px rgba(0, 0, 0, 0.5); }
        .filter-dropdown.open .filter-menu { display: block; }
        .filter-option { display: flex; justify-content: space-between; align-items: center; padding: 0.6rem 0.75rem; border-radius: 8px; font-size: 0.9rem; font-weight: 500; color: var(--text-secondary); text-decoration: none; }
        .filter-option:hover { background: var(--accent-transparent); color: var(--accent-light); }
        .filter-option.active { background: var(--accent-primary); color: var(--text-primary); }
        .filter-count { font-weight: 700; opacity: 0.85; }

        .post-list { flex: 1; overflow-y: auto; display: flex; flex-direction: column; gap: 0.6rem; padding: 1rem 0.9rem 1.25rem 1.1rem; }
        .post-item { display: block; flex-shrink: 0; padding: 1rem 1.1rem; border: 1px solid var(--border-light); border-radius: 12px; text-decoration: none; transition: background 0.2s, border-color 0.2s; }
        .post-item:hover { background: rgba(255, 255, 255, 0.03); border-color: rgba(124, 58, 237, 0.35); }
        .post-item.selected { background: var(--accent-transparent); border-color: var(--accent-primary); }
        .post-item-title { font-size: 0.95rem; font-weight: 600; color: var(--text-primary); margin-bottom: 0.55rem; line-height: 1.4; overflow-wrap: anywhere; }
        .post-item-meta { display: flex; flex-wrap: wrap; align-items: center; gap: 0.4rem 0.6rem; font-size: 0.8rem; color: var(--text-muted); }

        .flag-badge { font-size: 0.72rem; font-weight: 600; padding: 0.2rem 0.65rem; border-radius: 999px; }
        .flag-unsolved { color: var(--warn); background: rgba(251, 191, 36, 0.1); }
        .flag-verified { color: var(--success); background: rgba(52, 211, 153, 0.1); }
        .flag-reported { color: var(--danger); background: rgba(239, 68, 68, 0.1); }
        .flag-hidden { color: var(--text-muted); background: rgba(255, 255, 255, 0.06); }

        .empty-state { color: var(--text-muted); font-size: 0.9rem; padding: 2rem 1rem; text-align: center; }

        /* RIGHT: thread panel */
        .thread-column { flex: 1; min-width: 0; display: flex; flex-direction: column; background: var(--panel-bg); border: 1px solid var(--border-light); border-radius: 16px; overflow: hidden; }
        .thread-body { flex: 1; overflow-y: auto; padding: 1.75rem; display: flex; flex-direction: column; gap: 1.5rem; }

        .post-head { display: flex; justify-content: space-between; align-items: flex-start; gap: 1rem; }
        .btn-mod-toggle { flex-shrink: 0; display: inline-flex; align-items: center; gap: 0.45rem; padding: 0.5rem 0.95rem; border-radius: 8px; border: 1px solid var(--border-light); background: rgba(255, 255, 255, 0.04); color: var(--text-secondary); font-size: 0.85rem; font-weight: 600; cursor: pointer; transition: all 0.2s; }
        .btn-mod-toggle:hover, .btn-mod-toggle.active { color: var(--text-primary); border-color: var(--accent-primary); background: var(--accent-transparent); }
        .original-post h2 { font-size: 1.35rem; color: var(--text-primary); margin-bottom: 0.5rem; line-height: 1.4; }
        .post-byline { display: flex; flex-wrap: wrap; align-items: center; gap: 0.5rem; font-size: 0.85rem; color: var(--text-muted); margin-bottom: 1rem; }
        .post-content { font-size: 0.95rem; color: var(--text-secondary); line-height: 1.7; white-space: pre-wrap; }

        /* Moderation toolbar */
        .mod-card { display: none; }
        .mod-card.open { display: block; }
        .mod-card { border: 1px solid var(--border-light); background: rgba(255, 255, 255, 0.02); border-radius: 10px; padding: 1.25rem; }
        .mod-card h3 { font-size: 0.95rem; color: var(--text-primary); margin-bottom: 0.25rem; }
        .mod-card h3 { margin-bottom: 0.75rem; }
        .mod-card .report-reason { font-size: 0.85rem; color: var(--danger); margin-bottom: 0.9rem; }
        .mod-log { margin-top: 1rem; border-top: 1px solid var(--border-light); padding-top: 0.75rem; display: flex; flex-direction: column; gap: 0.5rem; }
        .mod-log-item { font-size: 0.8rem; color: var(--text-muted); line-height: 1.5; }
        .mod-log-item strong { color: var(--text-secondary); }
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
        .composer { padding: 1.25rem 1.75rem 1.5rem; border-top: 1px solid var(--border-light); background: rgba(255, 255, 255, 0.02); display: flex; flex-direction: column; gap: 0.75rem; }
        .composer .form-control { min-height: 96px; max-height: 45vh; line-height: 1.6; font-family: inherit; transition: min-height 0.2s ease, border-color 0.2s; }
        .composer.expanded .form-control { min-height: 210px; }
        .composer-actions { display: flex; justify-content: space-between; align-items: center; gap: 0.75rem; }
        .composer-hint { font-size: 0.8rem; color: var(--text-muted); }

        .toast.toast-error { color: var(--danger); background: rgba(239, 68, 68, 0.1); border-color: rgba(239, 68, 68, 0.3); }
        .toast { margin: 1rem 1.5rem 0; padding: 0.75rem 1rem; border-radius: 8px; font-size: 0.9rem; color: var(--success); background: rgba(52, 211, 153, 0.1); border: 1px solid rgba(52, 211, 153, 0.3); }

        @media (max-width: 1100px) {
            .main-content { overflow-y: auto; }
            .forum-container { flex-direction: column; overflow: visible; }
            .posts-column { width: 100%; max-height: 460px; }
        }
    </style>
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">

        <div class="page-header">
            <h1>Forum</h1>
            <p>Answer learner questions, verify the best answers and keep discussions within the community guidelines.</p>
        </div>

        <div class="forum-container">

            <!-- LEFT: Post list -->
            <section class="posts-column">
                <div class="posts-toolbar">
                    <input type="search" id="postSearch" class="search-box" placeholder="Search posts, authors or keywords" autocomplete="off" />
                    <div class="filter-dropdown" id="filterDropdown">
                        <button type="button" class="filter-button" id="filterButton" aria-haspopup="true" aria-expanded="false">
                            <span><asp:Literal ID="litFilterLabel" runat="server"></asp:Literal></span>
                            <svg class="chev" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9l6 6 6-6" /></svg>
                        </button>
                        <div class="filter-menu">
                            <a href="TAForumModeration.aspx?filter=all" class="filter-option <%= GetTabClass("all") %>">All posts<span class="filter-count"><asp:Literal ID="litCountAll" runat="server"></asp:Literal></span></a>
                            <a href="TAForumModeration.aspx?filter=unsolved" class="filter-option <%= GetTabClass("unsolved") %>">Unsolved<span class="filter-count"><asp:Literal ID="litCountUnsolved" runat="server"></asp:Literal></span></a>
                            <a href="TAForumModeration.aspx?filter=verified" class="filter-option <%= GetTabClass("verified") %>">Verified<span class="filter-count"><asp:Literal ID="litCountVerified" runat="server"></asp:Literal></span></a>
                            <a href="TAForumModeration.aspx?filter=reported" class="filter-option <%= GetTabClass("reported") %>">Reported<span class="filter-count"><asp:Literal ID="litCountReported" runat="server"></asp:Literal></span></a>
                        </div>
                    </div>
                </div>

                <div class="post-list">
                    <asp:PlaceHolder ID="phListEmpty" runat="server" Visible="false">
                        <p class="empty-state">No posts here yet.</p>
                    </asp:PlaceHolder>
                    <p id="noSearchResults" class="empty-state">No posts match your search.</p>

                    <asp:Repeater ID="rptPosts" runat="server">
                        <ItemTemplate>
                            <a href='TAForumModeration.aspx?filter=<%= CurrentFilter %>&post=<%# Eval("PostId") %>' class='post-item <%# Eval("CssClass") %>'>
                                <div class="post-item-title"><%# Server.HtmlEncode(Convert.ToString(Eval("Title"))) %></div>
                                <div class="post-item-meta">
                                    <span class='flag-badge <%# Eval("FlagCss") %>'><%# Eval("Flag") %></span>
                                    <%# (bool)Eval("ShowReported") ? "<span class='flag-badge flag-reported'>Reported</span>" : "" %>
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

                    <asp:HiddenField ID="hfPostId" runat="server" />

                    <asp:Panel ID="pnlMessage" runat="server" CssClass="toast" Visible="false">
                        <asp:Literal ID="litMessage" runat="server"></asp:Literal>
                    </asp:Panel>

                    <div class="thread-body">

                        <div class="original-post">
                            <div class="post-head">
                                <h2><asp:Literal ID="litPostTitle" runat="server"></asp:Literal></h2>
                                <button type="button" class="btn-mod-toggle" id="btnModToggle" aria-expanded="false">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2l8 3v6c0 5-3.5 9-8 11-4.5-2-8-6-8-11V5l8-3z" /></svg>
                                    Moderate
                                </button>
                            </div>
                            <div class="post-byline">
                                <asp:Literal ID="litPostBadges" runat="server"></asp:Literal>
                                <span>Posted by <strong><asp:Literal ID="litPostAuthor" runat="server"></asp:Literal></strong></span>
                                <span>&middot; <asp:Literal ID="litPostTime" runat="server"></asp:Literal></span>
                            </div>
                            <div class="post-content"><asp:Literal ID="litPostContent" runat="server"></asp:Literal></div>
                        </div>

                        <!-- Moderation tools: hidden until the Moderate button is clicked -->
                        <asp:Panel ID="pnlModeration" runat="server" CssClass="mod-card">
                            <h3>Moderation</h3>
                            <asp:Panel ID="pnlHiddenNotice" runat="server" CssClass="report-reason" Visible="false">This post is hidden from learners. Only staff can see it.</asp:Panel>
                            <asp:TextBox ID="txtModReason" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="Reason for your decision (required for every action)"></asp:TextBox>
                            <div class="mod-actions">
                                <asp:Button ID="btnFlagPost" runat="server" Text="Report (Flag)" CssClass="btn btn-secondary" OnClick="btnFlagPost_Click" />
                                <asp:Button ID="btnHidePost" runat="server" Text="Hide" CssClass="btn btn-secondary" OnClientClick="return confirm('Hide this post from learners?');" OnClick="btnHidePost_Click" />
                                <asp:Button ID="btnDeletePost" runat="server" Text="Delete" CssClass="btn btn-danger" OnClientClick="return confirm('Delete this post? This removes it for everyone.');" OnClick="btnDeletePost_Click" />
                            </div>
                            <asp:PlaceHolder ID="phModLog" runat="server" Visible="false">
                                <div class="mod-log">
                                    <asp:Repeater ID="rptModLog" runat="server">
                                        <ItemTemplate>
                                            <div class="mod-log-item"><strong><%# Eval("Action") %></strong> by <%# Server.HtmlEncode(Convert.ToString(Eval("Moderator"))) %> &middot; <%# Eval("When") %><br /><%# Server.HtmlEncode(Convert.ToString(Eval("Reason"))) %></div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </asp:PlaceHolder>
                        </asp:Panel>

                        <div class="replies-title"><asp:Literal ID="litReplyCount" runat="server"></asp:Literal></div>

                        <asp:Repeater ID="rptReplies" runat="server" OnItemCommand="rptReplies_ItemCommand">
                            <ItemTemplate>
                                <div class='reply-item <%# Eval("CssClass") %>'>
                                    <div class="reply-top">
                                        <div class="reply-author">
                                            <%# Server.HtmlEncode(Convert.ToString(Eval("Author"))) %>
                                            <span class='role-tag <%# Eval("RoleCss") %>'><%# Eval("Role") %></span>
                                            <span class="pin-tag" runat="server" visible='<%# Eval("IsPinned") %>'>✔ Verified Answer</span>
                                        </div>
                                        <span class="reply-time"><%# Eval("Posted") %></span>
                                    </div>
                                    <div class="reply-content"><%# Eval("ContentHtml") %></div>
                                    <div class="reply-actions">
                                        <asp:LinkButton ID="lnkPin" runat="server" CssClass="link-action" CommandName="Pin" CommandArgument='<%# Eval("ThreadId") %>' Text='<%# (bool)Eval("IsPinned") ? "Remove Verified" : "Mark as Verified Answer" %>'></asp:LinkButton>
                                        <asp:LinkButton ID="lnkDelete" runat="server" CssClass="link-action danger" CommandName="Delete" CommandArgument='<%# Eval("ThreadId") %>' OnClientClick="return confirm('Delete this reply?');" Text="Delete"></asp:LinkButton>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <div class="composer">
                        <asp:TextBox ID="txtReply" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="Write a reply as a Teaching Assistant. Wrap code in ``` fences or use the Code button."></asp:TextBox>
                        <div class="composer-actions">
                            <button type="button" class="btn btn-secondary" id="btnInsertCode" title="Insert a code block">&lt;/&gt; Code</button>
                            <asp:Button ID="btnReply" runat="server" Text="Post Reply" CssClass="btn btn-primary" OnClick="btnReply_Click" />
                        </div>
                    </div>

                </asp:PlaceHolder>
            </section>
        </div>
</asp:Content>

<asp:Content ID="ContentScripts" ContentPlaceHolderID="cphScripts" runat="server">
    <script>
        // Insert a ``` code fence at the cursor (or around the selected text) in the reply box
        (function () {
            var btn = document.getElementById('btnInsertCode');
            var box = document.querySelector('.composer textarea');
            if (!btn || !box) return;

            // The reply box grows while you write and shrinks back when it is empty and unused
            var composer = box.closest('.composer');
            function expand() { composer.classList.add('expanded'); }
            box.addEventListener('focus', expand);
            box.addEventListener('blur', function (e) {
                if (!box.value.trim() && !composer.contains(e.relatedTarget)) composer.classList.remove('expanded');
            });
            if (box.value.trim()) expand();

            btn.addEventListener('click', function () {
                expand();
                var start = box.selectionStart, end = box.selectionEnd;
                var selected = box.value.substring(start, end);
                var block = '```\n' + selected + '\n```\n';
                box.value = box.value.substring(0, start) + block + box.value.substring(end);
                box.focus();
                var caret = selected.length ? start + 4 + selected.length : start + 4;
                box.setSelectionRange(caret, caret);
            });
        })();

        // Filter dropdown
        (function () {
            var dd = document.getElementById('filterDropdown');
            var btn = document.getElementById('filterButton');
            if (!dd || !btn) return;
            btn.addEventListener('click', function (e) {
                e.stopPropagation();
                var open = dd.classList.toggle('open');
                btn.setAttribute('aria-expanded', open);
            });
            document.addEventListener('click', function () { dd.classList.remove('open'); btn.setAttribute('aria-expanded', false); });
        })();

        // Moderation tools open from the Moderate button (and stay open when an action needs a fix)
        (function () {
            var toggle = document.getElementById('btnModToggle');
            var card = document.getElementById('cphMain_pnlModeration');
            if (!toggle || !card) return;
            function set(open) {
                card.classList.toggle('open', open);
                toggle.classList.toggle('active', open);
                toggle.setAttribute('aria-expanded', open);
            }
            toggle.addEventListener('click', function () { set(!card.classList.contains('open')); });
            if (document.querySelector('.toast-error') && /reason|already/i.test(document.querySelector('.toast-error').textContent)) set(true);
        })();

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
</asp:Content>
