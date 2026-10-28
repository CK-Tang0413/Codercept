<%@ Page Title="Forum - Codercept" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="TeacherForum.aspx.cs" Inherits="Codercept.TeacherForum" %>
<%@ MasterType VirtualPath="~/TeacherSite.master" %>
<%@ Import Namespace="System.Linq" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <%-- Choosing a post and the mobile discussion view run client-side (data-tp-forum-*); pin / reply post back
         as tpForumAction ("pin:post:comment", "reply") and are handled in Page_Load. The Action dialog at the bottom (flag or hide a post,
         with a reason) is the front end only for now: nothing is posted or saved yet. --%>
    <div class="forum-screen<%= MobileDiscussion ? " show-discussion" : "" %>" data-tp-forum>
        <input type="hidden" id="hfTeacherForumPost" runat="server" data-tp-forum-selected />
        <input type="hidden" id="hfTeacherForumMobile" runat="server" value="0" data-tp-forum-mobile />
        <%-- the Id of the comment being replied to (empty = a reply to the post itself) --%>
        <input type="hidden" id="hfTeacherReplyingTo" runat="server" data-tp-forum-replying />

        <div class="forum-heading">
            <h1>Forum</h1>
            <a class="button button--primary" href="TeacherForumAdd.aspx"><span>Add new post</span></a>
        </div>

        <% if (Posts.Count == 0) { %>
        <article class="chapter-detail-card">
            <p class="summary-empty">There are no forum posts yet. Posts by learners in your courses appear here, and you can start a discussion with "Add new post".</p>
        </article>
        <% } else { %>
        <div class="forum-layout">
            <section class="post-list" aria-label="Forum posts">
                <% foreach (TeacherForumPost post in Posts) { bool sel = post.Id == SelectedPost.Id; %>
                <article class="forum-post-card<%= sel ? " is-selected" : "" %><%= (post.IsFlagged || post.Flagged) ? " is-flagged" : "" %>" data-tp-forum-post="<%= post.Id %>" data-title="<%: post.Title %>" style="<%= (post.IsFlagged || post.Flagged) ? "border-left: 3px solid #ef4444; background: #fffcfc;" : "" %>">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 0.5rem; margin-bottom: 0.35rem;">
                        <h2 style="margin: 0;"><%: post.Title %></h2>
                        <% if (post.IsFlagged || post.Flagged) { %>
                        <span class="badge badge--danger" title="Flagged: <%: post.FlagReason %>" style="flex-shrink: 0;">Flagged</span>
                        <% } %>
                    </div>
                    <p><%: post.Excerpt %></p>
                    <div class="post-tags">
                        <% foreach (string tag in post.Tags) { %><span class="tag-chip">#<%: tag %></span><% } %>
                    </div>
                    <div class="post-card-footer">
                        <button type="button" class="comment-count" data-tp-forum-open="<%= post.Id %>">Comment (<%= post.Comments.Count %>)</button>
                        <button type="button" class="post-action" data-tp-forum-action="<%= post.Id %>" data-flagged="<%= post.Flagged ? "1" : "0" %>" aria-label="Actions for <%: post.Title %>">Action</button>
                    </div>
                </article>
                <% } %>
            </section>

            <section class="discussion-panel" aria-label="Discussion">
                <div class="discussion-header">
                    <button type="button" class="discussion-back" aria-label="Back to forum posts" data-tp-forum-back><%= TeacherIcons.Svg("arrow", 18) %></button>
                    <div style="display: flex; align-items: center; justify-content: space-between; width: 100%; gap: 0.75rem; flex-wrap: wrap;">
                        <div style="display: flex; align-items: center; gap: 0.75rem; flex-wrap: wrap;">
                            <h2 style="margin: 0;">Discussion: <span data-tp-forum-title><%: SelectedPost.Title %></span></h2>
                            <% if (SelectedPost.IsFlagged) { %>
                            <span class="badge badge--danger" title="Flagged: <%: SelectedPost.FlagReason %>">Flagged</span>
                            <% } %>
                        </div>
                        <% if (SelectedPost.IsFlagged) { %>
                        <div>
                            <asp:Button ID="btnTeacherDismissFlag" runat="server" CssClass="button button--secondary" style="padding: 4px 12px; font-size: 12px;" Text="Dismiss Flag" OnClick="btnTeacherDismissFlag_Click" />
                        </div>
                        <% } %>
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
                        <%-- pinned replies first; the rest keep their order (OrderByDescending is stable) --%>
                        <% foreach (TeacherForumComment c in post.Comments.OrderByDescending(x => x.Pinned)) { %>
                        <div class="comment-popover-wrap">
                            <article class="comment-card<%= c.Pinned ? " is-pinned" : "" %>">
                                <% if (c.ParentId.HasValue) { TeacherForumComment parent = post.Comments.FirstOrDefault(x => x.Id == c.ParentId.Value); %>
                                <span class="reply-reference">Replied to <%= c.ParentId.Value %><%= parent == null ? "" : " - " + Server.HtmlEncode(parent.Name) %></span>
                                <% } %>
                                <div class="comment-card-heading">
                                    <span class="avatar avatar--sm avatar--<%= c.Role == "TEACHER" ? "indigo" : "blue" %>" aria-hidden="true"><%: c.Initials %></span>
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
                        <asp:TextBox ID="txtTeacherReply" runat="server" ValidateRequestMode="Disabled" placeholder="Write a reply..." aria-label="Write a reply" autocomplete="off" data-tp-forum-reply-input></asp:TextBox>
                        <button type="submit" name="tpForumAction" value="reply" aria-label="Send reply" data-tp-forum-send><%= TeacherIcons.Svg("send", 21) %></button>
                    </div>
                </div>
            </section>
        </div>
        <% } %>

        <a class="mobile-add-post" href="TeacherForumAdd.aspx" aria-label="Add new post"><%= TeacherIcons.Svg("plus", 23) %></a>
    </div>
</asp:Content>

<asp:Content ID="ContentModals" ContentPlaceHolderID="cphModals" runat="server">
    <%-- Opened by the "Action" button of a post. Flag and Hide post tpForumAction "moderate:flag" / "moderate:hide" with the post (tpModeratePost) and
         the reason (tpModerateReason); the page saves them (Forum.IsFlagged / IsHidden) and the reason in Moderate_Forum. --%>
    <div class="modal-backdrop" role="presentation" id="tpModerateModal" data-tp-modal data-tp-region="tpModerateModal" hidden>
        <div class="modal moderate-modal" role="dialog" aria-modal="true" aria-labelledby="tpModerateModalTitle">
            <h2 id="tpModerateModalTitle">Moderate this post</h2>
            <p>Post: <strong data-tp-moderate-title></strong></p>
            <label class="portal-form-field">
                <span>Reason</span>
                <textarea name="tpModerateReason" rows="4" maxlength="500" placeholder="Explain why you are flagging or hiding this post..." aria-label="Reason" data-tp-moderate-reason data-tp-clear-on-close data-tp-autofocus></textarea>
                <small></small>
            </label>
            <p class="moderate-note"><strong>Flag</strong> highlights the post in red. <strong>Hide</strong> removes it from the forum page.</p>
            <input type="hidden" name="tpModeratePost" data-tp-moderate-post />
            <div class="modal-actions">
                <button type="button" class="button button--ghost" data-tp-close-modal><span>Cancel</span></button>
                <button type="submit" name="tpForumAction" value="moderate:flag" class="button button--secondary" data-tp-moderate="flag"><span>Flag</span></button>
                <button type="submit" name="tpForumAction" value="moderate:hide" class="button button--danger" data-tp-moderate="hide"><span>Hide</span></button>
            </div>
        </div>
    </div>
</asp:Content>
