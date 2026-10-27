<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminCommunity.aspx.cs" Inherits="Codercept.Admin_Community" %>
<%@ Register Src="~/AdminSidebar.ascx" TagPrefix="uc" TagName="AdminSidebar" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Community Management</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="css/admin-portal.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
        <style>
        /* Community Announcements List & Cards */
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
            box-shadow: var(--shadow);
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .announcement-card:hover {
            border-color: #cbd5e1;
            box-shadow: var(--shadow-hover);
        }

        .announcement-card.announcement-type {
            border-left: 4px solid var(--accent-purple);
        }
        .announcement-card.invitation-type {
            border-left: 4px solid var(--info-blue);
        }

        .announcement-icon { 
            margin-top: 2px;
            font-size: 18px;
        }
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

        .pin-status {
            font-size: 12px;
            color: var(--warning-orange-text);
            display: inline-flex;
            align-items: center;
            gap: 4px;
            margin-bottom: 10px;
            font-weight: 600;
        }

        .announcement-body {
            font-size: 14px;
            color: var(--text-secondary);
            line-height: 1.5;
            margin-bottom: 14px;
        }

        .announcement-meta {
            font-size: 12px;
            color: var(--text-muted);
        }

        .announcement-actions {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .icon-btn.active-pin { 
            background-color: var(--warning-orange-bg); 
            color: var(--warning-orange-text); 
            border-color: var(--warning-orange-border);
        }
        .icon-btn.btn-delete:hover {
            color: var(--danger-red);
            border-color: var(--danger-red-border);
            background-color: var(--danger-red-bg);
        }

        .type-select-wrapper { width: 60%; }

        /* Full View Modal Body */
        .view-content-box {
            background-color: var(--bg-surface-nested);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 16px 20px;
            max-height: 320px;
            overflow-y: auto;
            color: var(--text-primary);
            font-size: 14px;
            line-height: 1.6;
            white-space: pre-wrap;
            scrollbar-width: thin;
            scrollbar-color: var(--border-color) transparent;
        }
        .view-content-box::-webkit-scrollbar { width: 6px; }
        .view-content-box::-webkit-scrollbar-thumb {
            background-color: var(--border-color);
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div style="display: flex; height: 100vh; overflow: hidden;">
            <uc:AdminSidebar runat="server" ID="SidebarCtrl" />
            
            <main class="main-content" style="flex: 1; overflow-y: auto;">
                <div class="page-header-container">
                    <div class="page-header">
                        <h1>Community</h1>
                        <p>Manage announcements and platform invitations</p>
                    </div>
                    <button type="button" class="btn-primary" onclick="openNewModal()">
                        <i class="fa-solid fa-plus"></i> New Announcement
                    </button>
                </div>

                <div class="section-header">
                    <i class="fa-regular fa-bell"></i> Announcements (<asp:Literal ID="litAnnouncementCount" runat="server">0</asp:Literal>)
                </div>

                <div class="announcements-list">
                    <asp:Repeater ID="rptAnnouncements" runat="server" OnItemCommand="rptAnnouncements_ItemCommand">
                        <ItemTemplate>
                            <div class="announcement-card <%# Eval("Type").ToString().ToLower() == "invitation" ? "invitation-type" : "announcement-type" %>">
                                <div class="announcement-icon">
                                    <i class="<%# Eval("Type").ToString().ToLower() == "invitation" ? "fa-solid fa-paper-plane" : "fa-solid fa-bullhorn" %>"></i>
                                </div>
                                
                                <div class="announcement-content">
                                    <div class="announcement-title-row">
                                        <h4><%# Eval("Title") %></h4>
                                        <div class="announcement-actions">
                                            <!-- Type Badge -->
                                            <span class="type-badge <%# Eval("Type").ToString().ToLower() == "invitation" ? "badge-invitation" : "badge-announcement" %>">
                                                <%# Eval("Type") %>
                                            </span>

                                            <!-- 1. View Button (Truncated text viewer) -->
                                            <button type="button" class="icon-btn" title="View Full Content"
                                                onclick="openViewModal('<%# AntiXssEncode(Eval("Title").ToString()) %>', '<%# AntiXssEncode(Eval("Content").ToString()) %>', '<%# Eval("Type") %>', '<%# Eval("DateTime", "{0:yyyy-MM-dd HH:mm}") %>')">
                                                <i class="fa-regular fa-eye"></i>
                                            </button>

                                            <!-- 2. Pin / Unpin Button -->
                                            <asp:LinkButton ID="btnPinToggle" runat="server" CssClass='<%# Convert.ToBoolean(Eval("IsPinned")) ? "icon-btn active-pin" : "icon-btn" %>'
                                                CommandName="TogglePin" CommandArgument='<%# Eval("NotificationId") %>' 
                                                ToolTip='<%# Convert.ToBoolean(Eval("IsPinned")) ? "Unpin Announcement" : "Pin to Top" %>'>
                                                <i class="fa-solid fa-thumbtack"></i>
                                            </asp:LinkButton>

                                            <!-- 3. Delete Button -->
                                            <asp:LinkButton ID="btnDelete" runat="server" CssClass="icon-btn btn-delete" 
                                                CommandName="DeleteAnnouncement" CommandArgument='<%# Eval("NotificationId") %>'
                                                OnClientClick="return confirm('Are you sure you want to permanently delete this announcement?');"
                                                ToolTip="Delete Announcement">
                                                <i class="fa-regular fa-trash-can"></i>
                                            </asp:LinkButton>
                                        </div>
                                    </div>

                                    <%# Convert.ToBoolean(Eval("IsPinned")) ? "<div class='pin-status'><i class='fa-solid fa-thumbtack'></i> Pinned to top</div>" : "" %>

                                    <!-- Content truncated with ellipsis if exceeding 140 chars -->
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
                        No announcements or invitations found. Click "New Announcement" to create one.
                    </asp:Panel>
                </div>
            </main>
        </div>

        <!-- 1. Create Announcement Modal -->
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

                <div class="form-row">
                    <div class="type-select-wrapper">
                        <label class="form-label" for="<%= ddlType.ClientID %>">Type</label>
                        <asp:DropDownList ID="ddlType" runat="server" CssClass="form-control form-select">
                            <asp:ListItem Value="Announcement" Text="Announcement" Selected="True"></asp:ListItem>
                            <asp:ListItem Value="Invitation" Text="Invitation"></asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div class="toggle-container">
                        <label class="switch">
                            <asp:CheckBox ID="chkPinToggle" runat="server" />
                            <span class="slider"></span>
                        </label>
                        <span>Pin to top</span>
                    </div>
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn-cancel" onclick="closeNewModal()">Cancel</button>
                    <asp:Button ID="btnPostAnnouncement" runat="server" Text="Post Announcement" CssClass="btn-submit" 
                        OnClick="btnPostAnnouncement_Click" OnClientClick="return validateAnnouncement();" />
                </div>
            </div>
        </div>

        <!-- 2. View Full Announcement Modal -->
        <div class="modal-overlay" id="viewModal">
            <div class="modal-container" style="max-width: 600px;">
                <div class="modal-header-row">
                    <div>
                        <span id="viewTypeBadge" class="type-badge badge-announcement">Announcement</span>
                        <h3 id="viewTitle" style="margin-top: 6px;">Announcement Title</h3>
                    </div>
                    <button type="button" class="icon-btn" onclick="closeViewModal()"><i class="fa-solid fa-xmark"></i></button>
                </div>

                <div class="view-content-box" id="viewFullContent">
                    Full text goes here...
                </div>

                <div style="font-size: 12px; color: var(--text-muted); margin-top: 14px;" id="viewDateMeta">
                    Posted on 2026-10-26
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn-cancel" onclick="closeViewModal()">Close</button>
                </div>
            </div>
        </div>

        <script>
            // Create Modal handlers
            function openNewModal() {
                document.getElementById('announcementModal').classList.add('active');
                const titleField = document.getElementById('<%= txtTitle.ClientID %>');
                if (titleField) titleField.focus();
            }

            function closeNewModal() {
                document.getElementById('announcementModal').classList.remove('active');
            }

            function validateAnnouncement() {
                const title = document.getElementById('<%= txtTitle.ClientID %>').value.trim();
                const content = document.getElementById('<%= txtContent.ClientID %>').value.trim();

                if (!title || !content) {
                    alert("Please provide both a title and content for the announcement.");
                    return false;
                }
                return true;
            }

            // View Modal handlers
            function openViewModal(title, content, type, dateStr) {
                document.getElementById('viewTitle').innerText = title;
                document.getElementById('viewFullContent').innerText = content;
                document.getElementById('viewDateMeta').innerText = "Posted on " + dateStr + " • Published by System Admin";
                
                const typeBadge = document.getElementById('viewTypeBadge');
                typeBadge.innerText = type;
                if (type.toLowerCase() === 'invitation') {
                    typeBadge.className = 'type-badge badge-invitation';
                } else {
                    typeBadge.className = 'type-badge badge-announcement';
                }

                document.getElementById('viewModal').classList.add('active');
            }

            function closeViewModal() {
                document.getElementById('viewModal').classList.remove('active');
            }

            // Backdrop click closing
            window.addEventListener('click', function (e) {
                const createModal = document.getElementById('announcementModal');
                const viewModal = document.getElementById('viewModal');
                if (e.target === createModal) closeNewModal();
                if (e.target === viewModal) closeViewModal();
            });
        </script>
    </form>
</body>
</html>