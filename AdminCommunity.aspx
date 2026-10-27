<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminCommunity.aspx.cs" Inherits="Codercept.Admin_Community" %>
<%@ Register Src="~/AdminSidebar.ascx" TagPrefix="uc" TagName="AdminSidebar" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Community Management - Codercept</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="css/admin-portal.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        .announcements-list {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .announcement-card {
            background-color: var(--bg-panel);
            border: 1px solid var(--border-color);
            border-radius: 10px;
            padding: 20px 24px;
            display: flex;
            gap: 16px;
            position: relative;
            transition: border-color 0.2s;
        }
        .announcement-card:hover { border-color: rgba(124, 58, 237, 0.4); }

        .announcement-card.announcement-type { border-left: 4px solid var(--accent-purple); }
        .announcement-card.invitation-type { border-left: 4px solid var(--info-blue); }

        .announcement-icon { margin-top: 2px; font-size: 18px; }
        .announcement-card.announcement-type .announcement-icon { color: var(--accent-purple); }
        .announcement-card.invitation-type .announcement-icon { color: var(--info-blue); }

        .announcement-content { flex: 1; }
        
        .announcement-title-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 6px;
        }

        .announcement-content h4 {
            font-size: 16px;
            font-weight: 600;
            color: var(--text-primary);
        }

        .announcement-body {
            font-size: 14px;
            color: var(--text-secondary);
            line-height: 1.5;
            margin-bottom: 14px;
        }

        .announcement-meta {
            font-size: 12px;
            color: #6b7280;
        }

        .announcement-actions {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        /* Custom Delete Modal Elements */
        .confirm-delete-box {
            text-align: center;
            padding: 10px 0;
        }
        .confirm-icon-circle {
            width: 56px;
            height: 56px;
            border-radius: 50%;
            background: rgba(239, 68, 68, 0.12);
            color: var(--danger-red);
            font-size: 24px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 18px;
            border: 1px solid var(--danger-red-border);
        }
        .confirm-delete-box h3 {
            font-size: 18px;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 8px;
        }
        .confirm-delete-box p {
            font-size: 13px;
            color: var(--text-secondary);
            line-height: 1.5;
            margin-bottom: 24px;
        }
        .btn-danger-confirm {
            background-color: var(--danger-red);
            color: #fff;
            border: none;
            padding: 9px 20px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s;
        }
        .btn-danger-confirm:hover { background-color: #dc2626; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hfDeleteAnnouncementId" runat="server" />

        <div style="display: flex; height: 100vh; overflow: hidden;">
            <uc:AdminSidebar runat="server" ID="SidebarCtrl" />
            
            <main class="main-content" style="flex: 1; overflow-y: auto;">
                <div class="page-header-container">
                    <div class="page-header">
                        <h1>Community</h1>
                        <p>Manage announcements and invitations across the platform</p>
                    </div>
                    <button type="button" class="btn-primary" onclick="openNewModal()">
                        <i class="fa-solid fa-plus"></i> New Announcement
                    </button>
                </div>

                <div class="section-header">
                    <i class="fa-regular fa-bell"></i> Announcements (<asp:Literal ID="litAnnouncementCount" runat="server">0</asp:Literal>)
                </div>

                <div class="announcements-list">
                    <asp:Repeater ID="rptAnnouncements" runat="server">
                        <ItemTemplate>
                            <div class="announcement-card <%# Eval("Type").ToString().ToLower() == "invitation" ? "invitation-type" : "announcement-type" %>">
                                <div class="announcement-icon">
                                    <i class="<%# Eval("Type").ToString().ToLower() == "invitation" ? "fa-solid fa-paper-plane" : "fa-solid fa-bullhorn" %>"></i>
                                </div>
                                
                                <div class="announcement-content">
                                    <div class="announcement-title-row">
                                        <h4><%# Eval("Title") %></h4>
                                        <div class="announcement-actions">
                                            <span class="type-badge <%# Eval("Type").ToString().ToLower() == "invitation" ? "badge-invitation" : "badge-announcement" %>">
                                                <%# Eval("Type") %>
                                            </span>

                                            <!-- View Details Modal Trigger -->
                                            <button type="button" class="icon-btn" title="View Full Content"
                                                onclick="openViewModal('<%# HttpUtility.JavaScriptStringEncode(Eval("Title").ToString()) %>', '<%# HttpUtility.JavaScriptStringEncode(Eval("Content").ToString()) %>', '<%# Eval("Type") %>', '<%# Eval("DateTime", "{0:yyyy-MM-dd HH:mm}") %>')">
                                                <i class="fa-regular fa-eye"></i>
                                            </button>

                                            <!-- Custom Modal Delete Trigger -->
                                            <button type="button" class="icon-btn btn-delete" title="Delete Announcement"
                                                onclick="openCustomDeleteAnnouncementModal('<%# Eval("NotificationId") %>', '<%# HttpUtility.JavaScriptStringEncode(Eval("Title").ToString()) %>')">
                                                <i class="fa-regular fa-trash-can"></i>
                                            </button>
                                        </div>
                                    </div>

                                    <div class="announcement-body">
                                        <%# TruncateContent(Eval("Content").ToString(), 140) %>
                                    </div>

                                    <div class="announcement-meta">
                                        <%# Eval("DateTime", "{0:yyyy-MM-dd HH:mm}") %> &bull; Published by System Admin
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                    <asp:Panel ID="pnlNoAnnouncements" runat="server" Visible="false" CssClass="empty-placeholder">
                        <i class="fa-regular fa-bell-slash" style="font-size: 28px; margin-bottom: 10px; display: block;"></i>
                        No announcements or invitations found.
                    </asp:Panel>
                </div>
            </main>
        </div>

        <!-- 1. Create Modal (Pin switch removed) -->
        <div class="modal-overlay" id="announcementModal">
            <div class="modal-container">
                <div class="modal-header-row">
                    <h3>New Community Post</h3>
                    <button type="button" class="icon-btn" onclick="closeNewModal()"><i class="fa-solid fa-xmark"></i></button>
                </div>
            
                <div class="form-group">
                    <label class="form-label" for="<%= txtTitle.ClientID %>">Title <span style="color: var(--danger-red);">*</span></label>
                    <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control" placeholder="Announcement title..."></asp:TextBox>
                </div>

                <div class="form-group">
                    <label class="form-label" for="<%= txtContent.ClientID %>">Content <span style="color: var(--danger-red);">*</span></label>
                    <asp:TextBox ID="txtContent" runat="server" TextMode="MultiLine" CssClass="form-control" placeholder="Write full details..."></asp:TextBox>
                </div>

                <div class="form-group">
                    <label class="form-label" for="<%= ddlType.ClientID %>">Type</label>
                    <asp:DropDownList ID="ddlType" runat="server" CssClass="form-control form-select">
                        <asp:ListItem Value="Announcement" Text="Announcement" Selected="True"></asp:ListItem>
                        <asp:ListItem Value="Invitation" Text="Invitation"></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn-cancel" onclick="closeNewModal()">Cancel</button>
                    <asp:Button ID="btnPostAnnouncement" runat="server" Text="Post Announcement" CssClass="btn-submit" 
                        OnClick="btnPostAnnouncement_Click" OnClientClick="return validateAnnouncement();" />
                </div>
            </div>
        </div>

        <!-- 2. View Modal -->
        <div class="modal-overlay" id="viewModal">
            <div class="modal-container" style="max-width: 600px;">
                <div class="modal-header-row">
                    <div>
                        <span id="viewTypeBadge" class="type-badge badge-announcement">Announcement</span>
                        <h3 id="viewTitle" style="margin-top: 6px;">Announcement Title</h3>
                    </div>
                    <button type="button" class="icon-btn" onclick="closeViewModal()"><i class="fa-solid fa-xmark"></i></button>
                </div>
                <div class="view-content-box" id="viewFullContent"></div>
                <div style="font-size: 12px; color: var(--text-secondary); margin-top: 14px;" id="viewDateMeta"></div>
                <div class="modal-actions">
                    <button type="button" class="btn-cancel" onclick="closeViewModal()">Close</button>
                </div>
            </div>
        </div>

        <!-- 3. Custom Delete Confirmation Modal -->
        <div class="modal-overlay" id="customDeleteModal">
            <div class="modal-container" style="max-width: 440px;">
                <div class="confirm-delete-box">
                    <div class="confirm-icon-circle">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                    </div>
                    <h3>Delete Announcement</h3>
                    <p>Are you sure you want to delete <strong id="deleteTargetTitle" style="color:var(--text-primary);">this announcement</strong>? It will be removed immediately from the community board.</p>
                    <div class="modal-actions" style="justify-content: center; gap: 14px;">
                        <button type="button" class="btn-cancel" onclick="closeCustomDeleteModal()">Cancel</button>
                        <asp:Button ID="btnConfirmDeleteAnnouncement" runat="server" Text="Confirm & Delete" 
                            CssClass="btn-danger-confirm" OnClick="btnConfirmDeleteAnnouncement_Click" />
                    </div>
                </div>
            </div>
        </div>

        <script>
            // @ts-nocheck
            function openNewModal() {
                var modal = document.getElementById('announcementModal');
                if (modal) modal.classList.add('active');
            }

            function closeNewModal() {
                var modal = document.getElementById('announcementModal');
                if (modal) modal.classList.remove('active');
            }

            function openViewModal(title, content, type, dateStr) {
                var viewTitle = document.getElementById('viewTitle');
                var viewFullContent = document.getElementById('viewFullContent');
                var viewDateMeta = document.getElementById('viewDateMeta');
                var typeBadge = document.getElementById('viewTypeBadge');
                var viewModal = document.getElementById('viewModal');

                if (viewTitle) viewTitle.innerText = title;
                if (viewFullContent) viewFullContent.innerText = content;
                if (viewDateMeta) viewDateMeta.innerText = "Posted on " + dateStr + " • System Admin";
        
                if (typeBadge) {
                    typeBadge.innerText = type;
                    typeBadge.className = type.toLowerCase() === 'invitation' ? 'type-badge badge-invitation' : 'type-badge badge-announcement';
                }
                if (viewModal) viewModal.classList.add('active');
            }

            function closeViewModal() {
                var modal = document.getElementById('viewModal');
                if (modal) modal.classList.remove('active');
            }

            function openCustomDeleteAnnouncementModal(id, title) {
                var hiddenField = document.getElementById('<%= hfDeleteAnnouncementId.ClientID %>');
                var targetTitle = document.getElementById('deleteTargetTitle');
                var modal = document.getElementById('customDeleteModal');

                if (hiddenField) hiddenField.value = id;
                if (targetTitle) targetTitle.innerText = '"' + title + '"';
                if (modal) modal.classList.add('active');
            }

            function closeCustomDeleteModal() {
                var modal = document.getElementById('customDeleteModal');
                if (modal) modal.classList.remove('active');
            }

            function validateAnnouncement() {
                var txtTitle = document.getElementById('<%= txtTitle.ClientID %>');
                var txtContent = document.getElementById('<%= txtContent.ClientID %>');

                var title = txtTitle ? txtTitle.value.trim() : '';
                var content = txtContent ? txtContent.value.trim() : '';

                if (!title || !content) {
                    alert("Please provide both a title and content.");
                    return false;
                }
                return true;
            }

            window.addEventListener('click', function (e) {
                var newModal = document.getElementById('announcementModal');
                var viewModal = document.getElementById('viewModal');
                var delModal = document.getElementById('customDeleteModal');

                if (e.target === newModal) closeNewModal();
                if (e.target === viewModal) closeViewModal();
                if (e.target === delModal) closeCustomDeleteModal();
            });
        </script>
    </form>
</body>
</html>