<%@ Page Title="Forum - Codercept" Language="C#" MasterPageFile="~/TASite.master" AutoEventWireup="true" CodeBehind="TAForumModeration.aspx.cs" Inherits="Codercept.TAForumModeration" %>
<%@ MasterType VirtualPath="~/TASite.master" %>
<%@ Import Namespace="System.Linq" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        .tp-app .badge--neutral,
        .tp-app .badge--hidden {
            color: #4b5563 !important;
            background: #f3f4f6 !important;
            border: 1px solid #d1d5db !important;
            padding: 2px 8px !important;
            font-size: 11px !important;
            font-weight: 700 !important;
            border-radius: 9999px !important;
            display: inline-flex !important;
            align-items: center !important;
            line-height: 1.4 !important;
        }

        .discussion-header {
            display: flex !important;
            flex-direction: column !important;
            min-height: auto !important;
            padding: 20px 24px 18px !important;
            border-bottom: 1px solid #e9e5f5 !important;
            gap: 14px !important;
        }

        .discussion-title-row {
            display: flex !important;
            align-items: center !important;
            gap: 12px !important;
        }

        .discussion-title-row h2 {
            margin: 0 !important;
            font-size: 1.15rem !important;
            font-weight: 700 !important;
            color: var(--heading) !important;
            line-height: 1.4 !important;
        }

        .discussion-status-bar {
            display: none;
            align-items: center;
            justify-content: space-between;
            padding: 10px 16px;
            border-radius: 10px;
            margin-top: 4px;
            margin-bottom: 4px;
        }

        .discussion-status-bar.is-visible {
            display: flex !important;
        }
    </style>
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <div class="forum-screen<%= MobileDiscussion ? " show-discussion" : "" %>" data-tp-forum>
        <input type="hidden" id="hfTeacherForumPost" runat="server" data-tp-forum-selected />
        <input type="hidden" id="hfTeacherForumMobile" runat="server" value="0" data-tp-forum-mobile />
        <input type="hidden" id="hfTeacherReplyingTo" runat="server" data-tp-forum-replying />

        <div class="forum-heading" style="display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; margin-bottom: 20px;">
            <h1>Forum</h1>
            <div style="display: inline-flex; background: #f3f4f6; padding: 4px; border-radius: 9999px; gap: 4px;">
                <a href="TAForumModeration.aspx" style="padding: 6px 14px; border-radius: 9999px; text-decoration: none; font-size: 13px; font-weight: 600; <%= CurrentFilter == "all" ? "background: #fff; color: #4338ca; box-shadow: 0 1px 2px rgba(0,0,0,0.06);" : "color: #6b7280;" %>">Active Discussions</a>
                <a href="TAForumModeration.aspx?filter=flagged" style="padding: 6px 14px; border-radius: 9999px; text-decoration: none; font-size: 13px; font-weight: 600; <%= CurrentFilter == "flagged" ? "background: #fff; color: #ef4444; box-shadow: 0 1px 2px rgba(0,0,0,0.06);" : "color: #6b7280;" %>">Flagged</a>
                <a href="TAForumModeration.aspx?filter=hidden" style="padding: 6px 14px; border-radius: 9999px; text-decoration: none; font-size: 13px; font-weight: 600; <%= CurrentFilter == "hidden" ? "background: #fff; color: #374151; box-shadow: 0 1px 2px rgba(0,0,0,0.06);" : "color: #6b7280;" %>">Hidden</a>
            </div>
        </div>

        <% if (Posts.Count == 0) { %>
        <article class="chapter-detail-card">
            <p class="summary-empty">No posts match the "<%= CurrentFilter %>" filter.</p>
        </article>
        <% } else { %>
        <div class="forum-layout">
            <section class="post-list" aria-label="Forum posts">
                <% foreach (TeacherForumPost post in Posts) { bool sel = post.Id == SelectedPost.Id; %>
                <article class="forum-post-card<%= sel ? " is-selected" : "" %><%= post.IsFlagged ? " is-flagged" : "" %>"
                         data-tp-forum-post="<%= post.Id %>"
                         data-title="<%: post.Title %>"
                         data-is-flagged="<%= post.IsFlagged ? "1" : "0" %>"
                         data-flag-reason="<%: post.FlagReason %>"
                         data-is-hidden="<%= post.IsHidden ? "1" : "0" %>"
                         data-hide-reason="<%: post.HideReason %>"
                         style="<%= post.IsFlagged ? "border-left: 3px solid #ef4444; background: #fffcfc;" : post.IsHidden ? "border-left: 3px solid #9ca3af; background: #f9fafb;" : "" %>">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 0.5rem; margin-bottom: 0.35rem;">
                        <h2 style="margin: 0;"><%: post.Title %></h2>
                        <div style="display: flex; gap: 4px; align-items: center; flex-shrink: 0;">
                            <% if (post.IsFlagged) { %>
                            <span class="badge badge--danger" title="Flagged: <%: post.FlagReason %>">Flagged</span>
                            <% } %>
                            <% if (post.IsHidden) { %>
                            <span class="badge badge--neutral" title="Hidden: <%: post.HideReason %>">Hidden</span>
                            <% } %>
                        </div>
                    </div>
                    <p><%: post.Excerpt %></p>
                    <div class="post-tags">
                        <% foreach (string tag in post.Tags) { %><span class="tag-chip">#<%: tag %></span><% } %>
                    </div>
                    <div class="post-card-footer">
                        <button type="button" class="comment-count" data-tp-forum-open="<%= post.Id %>">Comment (<%= post.Comments.Count %>)</button>
                        <% if (!post.IsFlagged && !post.IsHidden) { %>
                        <button type="button" class="post-action" data-tp-forum-action="<%= post.Id %>" aria-label="Actions for <%: post.Title %>">Action</button>
                        <% } %>
                    </div>
                </article>
                <% } %>
            </section>

            <section class="discussion-panel" aria-label="Discussion">
                <div class="discussion-header">
                    <!-- Row 1: Back button and Discussion Title -->
                    <div class="discussion-title-row">
                        <button type="button" class="discussion-back" aria-label="Back to forum posts" data-tp-forum-back><%= TeacherIcons.Svg("arrow", 18) %></button>
                        <h2>Discussion: <span data-tp-forum-title><%: SelectedPost != null ? SelectedPost.Title : "" %></span></h2>
                    </div>

                    <!-- Row 2: Status Badge and Moderation Actions -->
                    <div id="tpDiscussionStatusBar" class="discussion-status-bar<%= (SelectedPost != null && (SelectedPost.IsFlagged || SelectedPost.IsHidden)) ? " is-visible" : "" %>" style="<%= (SelectedPost != null && (SelectedPost.IsFlagged || SelectedPost.IsHidden)) ? "display: flex;" : "display: none;" %><%= (SelectedPost != null && SelectedPost.IsFlagged) ? "background: #fff5f5; border: 1px solid #fed7d7;" : (SelectedPost != null && SelectedPost.IsHidden) ? "background: #f9fafb; border: 1px solid #e5e7eb;" : "" %>">
                        <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
                            <span id="tpDiscussionStatusBadge" class="badge <%= (SelectedPost != null && SelectedPost.IsFlagged) ? "badge--danger" : "badge--neutral" %>"><%= (SelectedPost != null && SelectedPost.IsFlagged) ? "Flagged" : (SelectedPost != null && SelectedPost.IsHidden) ? "Hidden" : "" %></span>
                            <span id="tpDiscussionStatusReason" style="font-size: 0.85rem; color: #4b5563;"><%= (SelectedPost != null && SelectedPost.IsFlagged && !string.IsNullOrEmpty(SelectedPost.FlagReason)) ? SelectedPost.FlagReason : (SelectedPost != null && SelectedPost.IsHidden && !string.IsNullOrEmpty(SelectedPost.HideReason)) ? SelectedPost.HideReason : "" %></span>
                        </div>
                        <div>
                            <button type="submit" id="btnDynamicUnflag" name="tpForumAction" value="unflag:<%= SelectedPost != null ? SelectedPost.Id.ToString() : "" %>" class="button button--secondary" style="padding: 5px 14px; font-size: 12px; font-weight: 600; <%= (SelectedPost != null && SelectedPost.IsFlagged) ? "display: inline-block;" : "display: none;" %>">Dismiss Flag</button>
                            <button type="submit" id="btnDynamicUnhide" name="tpForumAction" value="unhide:<%= SelectedPost != null ? SelectedPost.Id.ToString() : "" %>" class="button button--secondary" style="padding: 5px 14px; font-size: 12px; font-weight: 600; <%= (SelectedPost != null && SelectedPost.IsHidden) ? "display: inline-block;" : "display: none;" %>">Unhide Post</button>
                        </div>
                    </div>
                </div>
                <div class="comment-scroll">
                    <% foreach (TeacherForumPost post in Posts) { %>
                    <div style="display: contents" data-tp-forum-thread="<%= post.Id %>"<%= post.Id == SelectedPost.Id ? "" : " hidden" %>>
                        <% if (post.Comments.Count == 0) { %>
                        <div class="empty-thread-message" style="display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 48px 20px; text-align: center; color: #6b7280;">
                            <p style="margin: 0; font-size: 14px; color: #6b7280;">No replies yet. Be the first to reply!</p>
                        </div>
                        <% } else { %>
                        <% foreach (TeacherForumComment c in post.Comments.OrderByDescending(x => x.Pinned)) { %>
                        <div class="comment-popover-wrap">
                            <article class="comment-card<%= c.Pinned ? " is-pinned" : "" %>">
                                <% if (c.ParentId.HasValue) { TeacherForumComment parent = post.Comments.FirstOrDefault(x => x.Id == c.ParentId.Value); %>
                                <span class="reply-reference">Replied to <%= c.ParentId.Value %><%= parent == null ? "" : " - " + Server.HtmlEncode(parent.Name) %></span>
                                <% } %>
                                <div class="comment-card-heading">
                                    <span class="avatar avatar--sm avatar--<%= c.Role == "TEACHER" ? "indigo" : c.Role == "TA" ? "amber" : "blue" %>" aria-hidden="true"><%: c.Initials %></span>
                                    <strong><%: c.Name %></strong>
                                    <span class="role-badge role-badge--<%= c.Role.ToLowerInvariant() %>"><%: c.Role %></span>
                                </div>
                                <p><% if (c.Pinned) { %><span class="pin-mark" aria-label="Pinned"></span><% } %><%: c.Body %></p>
                                <div class="comment-actions">
                                    <button type="button" data-tp-forum-reply="<%= c.Id %>" data-name="<%: c.Name %>">Reply</button>
                                    <button type="submit" name="tpForumAction" value="pin:<%= post.Id %>:<%= c.Id %>"><%= c.Pinned ? "Unpin" : "Pin" %></button>
                                    <span class="reply-id" title="Reply ID">ID <%= c.Id %></span>
                                </div>
                            </article>
                        </div>
                        <% } %>
                        <% } %>
                    </div>
                    <% } %>
                </div>
                <div class="reply-area">
                    <span class="replying-label" data-tp-forum-replying-label hidden>
                        <span data-tp-forum-replying-text></span>
                        <button type="button" class="replying-cancel" aria-label="Cancel reply" data-tp-forum-reply-cancel><%= TeacherIcons.Svg("close", 14) %></button>
                    </span>
                    <div class="reply-composer">
                        <asp:TextBox ID="txtTAReply" runat="server" ValidateRequestMode="Disabled" placeholder="Write a reply..." aria-label="Write a reply" autocomplete="off" data-tp-forum-reply-input></asp:TextBox>
                        <button type="submit" name="tpForumAction" value="reply" aria-label="Send reply" data-tp-forum-send><%= TeacherIcons.Svg("send", 21) %></button>
                    </div>
                </div>
            </section>
        </div>
        <% } %>
    </div>

    <script>
        (function () {
            function updateDiscussionStatus(postId) {
                if (!postId) {
                    var selInput = document.getElementById('<%= hfTeacherForumPost.ClientID %>');
                    if (selInput && selInput.value) {
                        postId = selInput.value;
                    }
                }
                if (!postId) {
                    var firstCard = document.querySelector('.forum-post-card[data-tp-forum-post]');
                    if (firstCard) {
                        postId = firstCard.getAttribute('data-tp-forum-post');
                    }
                }
                if (!postId) return;

                var card = document.querySelector('[data-tp-forum-post="' + postId + '"]');
                var bar = document.getElementById('tpDiscussionStatusBar');
                var badge = document.getElementById('tpDiscussionStatusBadge');
                var reason = document.getElementById('tpDiscussionStatusReason');
                var btnUnflag = document.getElementById('btnDynamicUnflag');
                var btnUnhide = document.getElementById('btnDynamicUnhide');

                if (!bar || !card) return;

                var isFlagged = card.getAttribute('data-is-flagged') === '1';
                var flagReason = card.getAttribute('data-flag-reason') || '';
                var isHidden = card.getAttribute('data-is-hidden') === '1';
                var hideReason = card.getAttribute('data-hide-reason') || '';

                if (isFlagged) {
                    bar.classList.add('is-visible');
                    bar.hidden = false;
                    bar.style.display = 'flex';
                    bar.style.background = '#fff5f5';
                    bar.style.border = '1px solid #fed7d7';
                    badge.className = 'badge badge--danger';
                    badge.textContent = 'Flagged';
                    reason.textContent = flagReason;
                    btnUnflag.style.display = 'inline-block';
                    btnUnflag.value = 'unflag:' + postId;
                    btnUnhide.style.display = 'none';
                } else if (isHidden) {
                    bar.classList.add('is-visible');
                    bar.hidden = false;
                    bar.style.display = 'flex';
                    bar.style.background = '#f9fafb';
                    bar.style.border = '1px solid #e5e7eb';
                    badge.className = 'badge badge--neutral';
                    badge.textContent = 'Hidden';
                    reason.textContent = hideReason;
                    btnUnflag.style.display = 'none';
                    btnUnhide.style.display = 'inline-block';
                    btnUnhide.value = 'unhide:' + postId;
                } else {
                    bar.classList.remove('is-visible');
                    bar.hidden = true;
                    bar.style.display = 'none';
                    badge.textContent = '';
                    reason.textContent = '';
                    btnUnflag.style.display = 'none';
                    btnUnhide.style.display = 'none';
                }
            }

            document.addEventListener('click', function (e) {
                var postCard = e.target.closest('[data-tp-forum-post]');
                if (postCard && !e.target.closest('[data-tp-forum-action]')) {
                    var pid = postCard.getAttribute('data-tp-forum-post');
                    updateDiscussionStatus(pid);
                }
                var commentBtn = e.target.closest('[data-tp-forum-open]');
                if (commentBtn) {
                    var pid2 = commentBtn.getAttribute('data-tp-forum-open');
                    updateDiscussionStatus(pid2);
                }
            });

            document.addEventListener('DOMContentLoaded', function () {
                updateDiscussionStatus();
            });
            window.addEventListener('load', function () {
                updateDiscussionStatus();
            });
        })();
    </script>
</asp:Content>

<asp:Content ID="ContentModals" ContentPlaceHolderID="cphModals" runat="server">
    <div class="modal-backdrop" role="presentation" id="tpModerateModal" data-tp-modal data-tp-region="tpModerateModal" hidden>
        <div class="modal moderate-modal" role="dialog" aria-modal="true" aria-labelledby="tpModerateModalTitle">
            <h2 id="tpModerateModalTitle">Moderate this post</h2>
            <p>Post: <strong data-tp-moderate-title></strong></p>
            <label class="portal-form-field">
                <span>Reason</span>
                <asp:TextBox ID="txtModerateReason" runat="server" TextMode="MultiLine" Rows="4" MaxLength="500" placeholder="Explain why you are flagging or hiding this post..." aria-label="Reason" data-tp-moderate-reason data-tp-clear-on-close data-tp-autofocus></asp:TextBox>
                <small></small>
            </label>
            <p class="moderate-note"><strong>Flag</strong> marks the post for review. <strong>Hide</strong> removes it from public view.</p>
            <input type="hidden" id="hfModeratePostId" runat="server" data-tp-moderate-post />
            <div class="modal-actions">
                <button type="button" class="button button--ghost" data-tp-close-modal><span>Cancel</span></button>
                <asp:Button ID="btnModerateFlag" runat="server" CssClass="button button--secondary" Text="Flag" OnClick="btnModerate_Click" CommandArgument="Flag" />
                <asp:Button ID="btnModerateHide" runat="server" CssClass="button button--danger" Text="Hide" OnClick="btnModerate_Click" CommandArgument="Hide" />
            </div>
        </div>
    </div>
</asp:Content>
