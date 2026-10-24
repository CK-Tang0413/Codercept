<%@ Page Title="Forum - Codercept" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="TeacherForum.aspx.cs" Inherits="Codercept.TeacherForum" %>
<%@ MasterType VirtualPath="~/TeacherSite.master" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <%-- Choosing a post and the mobile discussion view run client-side (data-tp-forum-*); pin / flag / reply post back
         as tpForumAction ("pin:post:comment", "flag:post:comment", "reply") and are handled in Page_Load. --%>
    <div class="forum-screen<%= MobileDiscussion ? " show-discussion" : "" %>" data-tp-forum>
        <input type="hidden" id="hfTeacherForumPost" runat="server" data-tp-forum-selected />
        <input type="hidden" id="hfTeacherForumMobile" runat="server" value="0" data-tp-forum-mobile />
        <%-- the Id of the comment being replied to (empty = a reply to the post itself) --%>
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
                    <button type="button" class="comment-count" data-tp-forum-open="<%= post.Id %>">Comment (<%= post.Comments.Count %>)</button>
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
                        <% foreach (TeacherForumComment c in post.Comments) { %>
                        <div class="comment-popover-wrap">
                            <article class="comment-card<%= c.Pinned ? " is-pinned" : "" %>">
                                <div class="comment-card-heading">
                                    <span class="avatar avatar--sm avatar--<%= c.Role == "TEACHER" ? "indigo" : "blue" %>" aria-hidden="true"><%: c.Initials %></span>
                                    <strong><%: c.Name %></strong>
                                    <span class="role-badge role-badge--<%= c.Role.ToLowerInvariant() %>"><%: c.Role %></span>
                                </div>
                                <p><% if (c.Pinned) { %><span class="pin-mark" aria-label="Pinned"></span><% } %><%: c.Body %></p>
                                <div class="comment-actions">
                                    <button type="button" data-tp-forum-reply="<%= c.Id %>" data-name="<%: c.Name %>">Reply</button>
                                    <button type="submit" name="tpForumAction" value="pin:<%= post.Id %>:<%= c.Id %>"><%= c.Pinned ? "Unpin" : "Pin" %></button>
                                    <button type="button" data-tp-forum-flag>Flag</button>
                                </div>
                            </article>
                            <div class="flag-popover" role="dialog" aria-label="Flag comment" data-tp-forum-flag-pop hidden>
                                <strong>Flag this comment?</strong>
                                <p>A moderator will review it.</p>
                                <div>
                                    <button type="button" data-tp-forum-flag-cancel>Cancel</button>
                                    <button type="submit" name="tpForumAction" value="flag:<%= post.Id %>:<%= c.Id %>">Flag</button>
                                </div>
                            </div>
                        </div>
                        <% } %>
                    </div>
                    <% } %>
                </div>
                <div class="reply-area">
                    <span class="replying-label" data-tp-forum-replying-label hidden></span>
                    <div class="reply-composer">
                        <asp:TextBox ID="txtTeacherReply" runat="server" ValidateRequestMode="Disabled" placeholder="Write a reply..." aria-label="Write a reply" autocomplete="off" data-tp-forum-reply-input></asp:TextBox>
                        <button type="submit" name="tpForumAction" value="reply" aria-label="Send reply" data-tp-forum-send><%= TeacherIcons.Svg("send", 21) %></button>
                    </div>
                </div>
            </section>
        </div>

        <a class="mobile-add-post" href="TeacherForumAdd.aspx" aria-label="Add new post"><%= TeacherIcons.Svg("plus", 23) %></a>
    </div>
</asp:Content>

<asp:Content ID="ContentModals" ContentPlaceHolderID="cphModals" runat="server">
</asp:Content>
