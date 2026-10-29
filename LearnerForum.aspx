<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LearnerForum.aspx.cs" Inherits="Codercept.LearnerForum" %>
<%@ Register Src="~/LearnerSideBar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Forum - Codercept</title>

    <!-- 1. Import Global Variables & Shared Layout -->
    <link href="css/global.css" rel="stylesheet" type="text/css" />

    <!-- 2. Page-Specific Styles -->
    <style>
        :root {
            /* Local variables for Forum */
            --forum-panel-bg: var(--bg-surface);
            --forum-border: var(--border-light);
            --btn-action-bg: rgba(255, 255, 255, 0.05);
            --btn-action-hover: rgba(255, 255, 255, 0.1);
            
            /* Roles */
            --role-learner: #60a5fa;
            --role-ta: #fb923c;
            --role-teacher: #c084fc;
            
            /* Message States */
            --msg-flagged-bg: rgba(239, 68, 68, 0.1);
            --msg-flagged-border: rgba(239, 68, 68, 0.3);
            --msg-pinned-border: var(--accent-primary);
        }

        /* Override main-content for a fixed split-screen layout */
        .main-content {
            display: flex;
            flex-direction: column;
            overflow: hidden; /* Prevents whole page scroll, lets panels scroll */
            padding-bottom: 0; 
        }

        /* Forum Header */
        .forum-header { 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            margin-bottom: 1.5rem; 
        }
        .forum-header h1 { font-size: 2rem; color: var(--text-primary); }
        .btn-new-post { 
            background: var(--text-primary); 
            color: var(--bg-main); 
            padding: 0.6rem 1.25rem; 
            border-radius: 20px; 
            font-weight: 600; 
            text-decoration: none; 
            border: none; 
            cursor: pointer; 
            transition: background 0.2s; 
        }
        .btn-new-post:hover { background: #e4e4e7; }

        /* Split Layout Container */
        .forum-container {
            display: flex;
            flex: 1;
            gap: 1.5rem;
            overflow: hidden;
            padding-bottom: 2rem;
        }

        /* LEFT PANEL: Posts Column */
        .posts-column {
            flex: 1.5;
            display: flex;
            flex-direction: column;
            gap: 1rem;
            overflow-y: auto;
            padding-right: 0.5rem;
        }

        /* Post Card */
        .post-card {
            background: var(--forum-panel-bg);
            border: 1px solid var(--forum-border);
            border-radius: 12px;
            padding: 1.5rem;
            display: flex;
            flex-direction: column;
        }
        .post-title { font-size: 1.25rem; font-weight: 600; margin-bottom: 0.75rem; color: var(--text-primary); }
        .post-desc { font-size: 0.95rem; color: var(--text-secondary); line-height: 1.6; margin-bottom: 1.25rem; }
        .post-tags { font-size: 0.85rem; color: var(--accent-light); margin-bottom: 1.25rem; font-weight: 500; }
        
        .action-group { display: flex; gap: 0.75rem; }
        .btn-action { 
            background: var(--btn-action-bg); 
            color: var(--text-secondary); 
            border: 1px solid transparent; 
            padding: 0.4rem 1rem; 
            border-radius: 20px; 
            font-size: 0.85rem; 
            cursor: pointer; 
            transition: all 0.2s; 
        }
        .btn-action:hover { background: var(--btn-action-hover); color: var(--text-primary); }
        .btn-action.active-comment { background: var(--accent-transparent); color: var(--accent-light); border-color: var(--accent-border); }

        /* RIGHT PANEL: Comments Column */
        .comments-column {
            flex: 1;
            background: var(--forum-panel-bg);
            border: 1px solid var(--forum-border);
            border-radius: 12px;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }
        
        .comments-header {
            padding: 1rem 1.5rem;
            border-bottom: 1px solid var(--forum-border);
            font-weight: 600;
            color: var(--text-primary);
            background: rgba(255, 255, 255, 0.02);
        }

        .comments-list {
            flex: 1;
            overflow-y: auto;
            padding: 1rem;
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
        }

        /* Individual Comment */
        .comment-item {
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid var(--forum-border);
            border-radius: 8px;
            padding: 1rem;
            display: flex;
            flex-direction: column;
        }
        
        /* Message States */
        .comment-item.flagged { background: var(--msg-flagged-bg); border-color: var(--msg-flagged-border); }
        .comment-item.pinned { border-color: var(--msg-pinned-border); }

        .reply-context { font-size: 0.75rem; color: var(--accent-light); margin-bottom: 0.5rem; display: flex; align-items: center; gap: 0.25rem; }
        
        .comment-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem; }
        .comment-user { display: flex; align-items: center; gap: 0.5rem; }
        .c-avatar { width: 24px; height: 24px; background: #2e1065; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 0.75rem; font-weight: bold; color: var(--accent-light); }
        .c-name { font-size: 0.9rem; font-weight: 600; color: var(--text-primary); }
        
        .role-badge { font-size: 0.65rem; font-weight: 700; padding: 0.15rem 0.5rem; border-radius: 4px; text-transform: uppercase; }
        .role-badge.learner { background: rgba(96, 165, 250, 0.1); color: var(--role-learner); border: 1px solid rgba(96, 165, 250, 0.2); }
        .role-badge.ta { background: rgba(251, 146, 60, 0.1); color: var(--role-ta); border: 1px solid rgba(251, 146, 60, 0.2); }
        .role-badge.teacher { background: rgba(192, 132, 252, 0.1); color: var(--role-teacher); border: 1px solid rgba(192, 132, 252, 0.2); }

        .comment-text { font-size: 0.9rem; color: var(--text-secondary); line-height: 1.5; margin-bottom: 0.75rem; }
        
        /* Updated Comment Actions */
        .comment-actions { display: flex; gap: 0.75rem; }
        .action-btn { 
            background: none; 
            border: none; 
            color: var(--text-muted); 
            font-size: 0.75rem; 
            cursor: pointer; 
            font-weight: 600; 
            transition: color 0.2s; 
            padding: 0; 
            font-family: inherit;
        }
        .action-btn:hover { color: var(--text-primary); }
        .action-btn.action-flag:hover { color: #ef4444; }

        /* Comment Input Area */
        .comment-input-area {
            padding: 1rem;
            border-top: 1px solid var(--forum-border);
            display: flex;
            gap: 0.5rem;
            background: rgba(255, 255, 255, 0.02);
        }
        .input-chat {
            flex: 1;
            background: var(--bg-main);
            border: 1px solid var(--forum-border);
            padding: 0.75rem 1rem;
            border-radius: 20px;
            color: var(--text-primary);
            font-size: 0.9rem;
            outline: none;
            transition: border-color 0.2s;
        }
        .input-chat:focus { border-color: var(--accent-primary); }
        .btn-send {
            background: var(--accent-primary);
            color: white;
            border: none;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: background 0.2s;
        }
        .btn-send:hover { background: var(--accent-hover); }

        /* Custom Scrollbar for columns */
        ::-webkit-scrollbar { width: 6px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: rgba(255,255,255,0.1); border-radius: 3px; }
        ::-webkit-scrollbar-thumb:hover { background: rgba(255,255,255,0.2); }

        @media (max-width: 992px) {
            .forum-container { flex-direction: column; }
            .comments-column { flex: none; height: 500px; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="dashboard-layout">
            
            <!-- Sidebar Injected Here -->
            <uc:Sidebar runat="server" ID="LearnerSideBarCtrl" />

            <!-- Main Content -->
            <main class="main-content">
                
                <div class="forum-header">
                    <h1>Forum</h1>
                    <asp:Button ID="btnAddPost" runat="server" Text="Add new post" CssClass="btn-new-post" OnClick="btnAddPost_Click" />
                </div>

                <div class="forum-container">
                   <!-- LEFT PANEL: Posts List -->
                    <div class="posts-column">
                        <asp:Repeater ID="rptPosts" runat="server" OnItemCommand="rptPosts_ItemCommand">
                            <ItemTemplate>
                                <div class="post-card">
                                    <h2 class="post-title"><%# Eval("Title") %></h2>
                                    <p class="post-desc"><%# Eval("Content") %></p>
                                    <div class="post-tags">
                                        <%# GetFormattedTags(Eval("Tags")) %>
                                    </div>
                                    <div class="action-group">
                                        <asp:Button ID="btnComment" runat="server" CssClass='<%# Convert.ToBoolean(Eval("IsActive")) ? "btn-action active-comment" : "btn-action" %>' Text='<%# "Comment (" + Eval("ReplyCount") + ")" %>' CommandName="SelectPost" CommandArgument='<%# Eval("PostId") %>' />
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <!-- RIGHT PANEL: Comments Section -->
                    <asp:Panel ID="pnlComments" runat="server" CssClass="comments-column" Visible="false">

                        <div class="comments-header">
                            Discussion: <asp:Literal ID="litActivePostTitle" runat="server"></asp:Literal>
                        </div>

                        <div class="comments-list">
                            <asp:Repeater ID="rptComments" runat="server" OnItemCommand="rptComments_ItemCommand" OnItemDataBound="rptComments_ItemDataBound">
                                <ItemTemplate>

                                    <!-- Dynamic CSS classes for Pinning and Flagging -->
                                    <div class='comment-item <%# Eval("IsPinned").ToString() == "Yes" ? "pinned" : "" %>'>

                                        <!-- Only show if it's a reply -->
                                        <asp:PlaceHolder runat="server" Visible='<%# !string.IsNullOrEmpty(Eval("ParentThreadId").ToString()) %>'>
                                            <div class="reply-context">
                                                ↳ Replying to <%# GetReplyToName(Eval("ParentThreadId")) %>
                                            </div>
                                        </asp:PlaceHolder>

                                        <div class="comment-top">
                                            <div class="comment-user">
                                                <div class="c-avatar"><%# GetInitials(Eval("AuthorName").ToString()) %></div>
                                                <div class="c-name"><%# Eval("AuthorName") %></div>
                                            </div>
                                            <div class='role-badge <%# Eval("Role").ToString().ToLower().Replace(" ", "") %>'><%# Eval("Role") %></div>
                                        </div>

                                        <div class="comment-text">
                                            <asp:Literal runat="server" Visible='<%# Eval("IsPinned").ToString() == "Yes" %>' Text="📌 "></asp:Literal>
                                            <%# Eval("ReplyComment") %>
                                        </div>

                                        <div class="comment-actions">
                                            <asp:Button ID="btnReply" runat="server" Text="Reply" CssClass="action-btn" CommandName="Reply" CommandArgument='<%# Eval("ThreadId") %>' />
                        
                                            <!-- Teachers and TAs see moderation controls (Hidden for Learners) -->
                                            <asp:PlaceHolder ID="phModControls" runat="server" Visible="false">
                                                <asp:Button ID="btnPin" runat="server" Text='<%# Eval("IsPinned").ToString() == "Yes" ? "Unpin" : "Pin" %>' CssClass="action-btn" CommandName="TogglePin" CommandArgument='<%# Eval("ThreadId") %>' />
                                            </asp:PlaceHolder>
                                        </div>
                                    </div>

                                </ItemTemplate>
                            </asp:Repeater>
                        </div>

                        <!-- Chat Input -->
                        <div class="comment-input-area" style="flex-direction: column; gap: 0.5rem;">
    
                            <!-- Reply Preview Banner (Hidden by default) -->
                            <asp:Panel ID="pnlReplyPreview" runat="server" Visible="false" style="display: flex; justify-content: space-between; align-items: center; background: rgba(124, 58, 237, 0.1); border: 1px solid var(--accent-border); padding: 0.4rem 0.75rem; border-radius: 6px; font-size: 0.8rem; color: var(--accent-light);">
                                <span>Replying to <strong><asp:Literal ID="litReplyingToUser" runat="server"></asp:Literal></strong></span>
                                <asp:LinkButton ID="btnCancelReply" runat="server" OnClick="btnCancelReply_Click" style="background: none; border: none; color: var(--text-muted); cursor: pointer; font-weight: bold; font-size: 0.9rem;" title="Cancel reply">×</asp:LinkButton>
                            </asp:Panel>

                            <div style="display: flex; gap: 0.5rem; width: 100%;">
                                <asp:HiddenField ID="hfReplyToId" runat="server" />
                                <asp:TextBox ID="txtComment" runat="server" CssClass="input-chat" placeholder="Type comment here..."></asp:TextBox>
                                <asp:LinkButton ID="btnSendComment" runat="server" CssClass="btn-send" OnClick="btnSendComment_Click">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="currentColor" viewBox="0 0 16 16">
                                        <path d="M15.854.146a.5.5 0 0 1 .11.54l-5.819 14.547a.75.75 0 0 1-1.329.124l-3.178-4.995L.643 7.184a.75.75 0 0 1 .124-1.33L15.314.037a.5.5 0 0 1 .54.11ZM6.636 10.07l2.761 4.338L14.13 2.576 6.636 10.07Zm6.787-8.201L1.591 6.602l4.339 2.76 7.494-7.493Z"/>
                                    </svg>
                                </asp:LinkButton>
                            </div>
                        </div>

                    </asp:Panel>
                </div>
            </main>
        </div>
    </form>
</body>
</html>