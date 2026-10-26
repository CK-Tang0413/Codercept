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
        <input type="hidden" id="hfTeacherReplyingTo" runat="server" data-tp-forum-replying />

        <div class="forum-heading">
            <h1>Forum</h1>
            <a class="button button--primary" href="TeacherForumAdd.aspx"><span>Add new post</span></a>
        </div>

        <div class="forum-layout">
            <section class="post-list" aria-label="Forum posts">
                <% foreach (TeacherForumPost post in Posts) { bool sel = post.Id == SelectedPost.Id; %>
                <article class="forum-post-card<%= sel ? " is-selected" : "" %>" data-tp-forum-post="<%= post.Id %>" data-title="<%: post.Title %>">
                    <h2><%: post.Title %></h2>
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
                    <h2>Discussion: <span data-tp-forum-title><%: SelectedPost.Title %></span></h2>
                </div>
                <div class="comment-scroll">
                    <% foreach (TeacherForumPost post in Posts) { %>
                    <div style="display: contents" data-tp-forum-thread="<%= post.Id %>"<%= post.Id == SelectedPost.Id ? "" : " hidden" %>>
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
                                    <button type="button" data-tp-forum-reply="<%: c.Name %>">Reply</button>
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
                        <asp:TextBox ID="txtTeacherReply" runat="server" placeholder="Write a reply..." aria-label="Write a reply" autocomplete="off" data-tp-forum-reply-input></asp:TextBox>
                        <button type="submit" name="tpForumAction" value="reply" aria-label="Send reply" data-tp-forum-send><%= TeacherIcons.Svg("send", 21) %></button>
                    </div>
                </div>
            </section>
        </div>

        <a class="mobile-add-post" href="TeacherForumAdd.aspx" aria-label="Add new post"><%= TeacherIcons.Svg("plus", 23) %></a>
    </div>
</asp:Content>

<asp:Content ID="ContentModals" ContentPlaceHolderID="cphModals" runat="server">
    <%-- Opened by the "Action" button of a post. TODO (backend): post the reason and the chosen action (flag / hide) and store them in Moderate_Forum. --%>
    <div class="modal-backdrop" role="presentation" id="tpModerateModal" data-tp-modal data-tp-region="tpModerateModal" hidden>
        <div class="modal moderate-modal" role="dialog" aria-modal="true" aria-labelledby="tpModerateModalTitle">
            <h2 id="tpModerateModalTitle">Moderate this post</h2>
            <p>Post: <strong data-tp-moderate-title></strong></p>
            <label class="portal-form-field">
                <span>Reason</span>
                <textarea rows="4" maxlength="500" placeholder="Explain why you are flagging or hiding this post..." aria-label="Reason" data-tp-moderate-reason data-tp-clear-on-close data-tp-autofocus></textarea>
                <small></small>
            </label>
            <p class="moderate-note"><strong>Flag</strong> highlights the post in red. <strong>Hide</strong> removes it from the forum page.</p>
            <input type="hidden" data-tp-moderate-post />
            <div class="modal-actions">
                <button type="button" class="button button--ghost" data-tp-close-modal><span>Cancel</span></button>
                <button type="button" class="button button--secondary" data-tp-moderate="flag"><span>Flag</span></button>
                <button type="button" class="button button--danger" data-tp-moderate="hide"><span>Hide</span></button>
            </div>
        </div>
    </div>
</asp:Content>
