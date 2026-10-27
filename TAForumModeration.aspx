<%@ Page Title="Forum - Codercept" Language="C#" MasterPageFile="~/TASite.master" AutoEventWireup="true" CodeBehind="TAForumModeration.aspx.cs" Inherits="Codercept.TAForumModeration" %>
<%@ MasterType VirtualPath="~/TASite.master" %>
<%@ Import Namespace="System.Linq" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
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
                <article class="forum-post-card<%= sel ? " is-selected" : "" %><%= post.IsFlagged ? " is-flagged" : "" %>" data-tp-forum-post="<%= post.Id %>" data-title="<%: post.Title %>" style="<%= post.IsFlagged ? "border-left: 3px solid #ef4444; background: #fffcfc;" : post.IsHidden ? "border-left: 3px solid #9ca3af; background: #f9fafb;" : "" %>">
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
                        <button type="button" class="post-action" data-tp-forum-action="<%= post.Id %>" aria-label="Actions for <%: post.Title %>">Action</button>
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
                            <% if (SelectedPost.IsHidden) { %>
                            <span class="badge badge--neutral" title="Hidden: <%: SelectedPost.HideReason %>">Hidden</span>
                            <% } %>
                        </div>
                        <div>
                            <% if (SelectedPost.IsFlagged) { %>
                            <asp:Button ID="btnUnflagPost" runat="server" CssClass="button button--secondary" style="padding: 4px 12px; font-size: 12px;" Text="Dismiss Flag" OnClick="btnUnflag_Click" />
                            <% } %>
                            <% if (SelectedPost.IsHidden) { %>
                            <asp:Button ID="btnUnhidePost" runat="server" CssClass="button button--secondary" style="padding: 4px 12px; font-size: 12px;" Text="Unhide Post" OnClick="btnUnhide_Click" />
                            <% } %>
                        </div>
                    </div>
                </div>
                <div class="comment-scroll">
                    <% foreach (TeacherForumPost post in Posts) { %>
                    <div style="display: contents" data-tp-forum-thread="<%= post.Id %>"<%= post.Id == SelectedPost.Id ? "" : " hidden" %>>
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
