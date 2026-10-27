<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="Codercept.Admin_Dashboard" %>
<%@ Register Src="~/AdminSidebar.ascx" TagPrefix="uc" TagName="AdminSidebar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dashboard</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="css/admin-portal.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
        <style>
        /* Alert Banner (Matching Teacher Portal Welcome Banner) */
        .alert-banner {
            background: var(--banner-bg);
            border: 1px solid rgba(255, 255, 255, 0.15);
            border-radius: 14px;
            padding: 24px 28px;
            margin-bottom: 32px;
            box-shadow: 0 12px 30px rgba(67, 56, 202, 0.18);
            color: var(--banner-text);
        }

        .alert-banner h2 { font-size: 22px; font-weight: 700; margin-bottom: 8px; color: #ffffff; letter-spacing: -0.01em; }
        .alert-banner p { color: #e0e7ff; font-size: 14px; margin-bottom: 20px; line-height: 1.6; }

        .btn-review {
            background-color: rgba(255, 255, 255, 0.15);
            color: #ffffff;
            border: 1px solid rgba(255, 255, 255, 0.25);
            padding: 10px 16px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
        }
        .btn-review:hover { 
            background-color: rgba(255, 255, 255, 0.25);
            transform: translateY(-1px);
        }

        /* Pending Approvals */
        .approvals-list { display: flex; flex-direction: column; gap: 8px; margin-bottom: 40px; }
        .approval-item { 
            background-color: var(--bg-panel); 
            border: 1px solid var(--border-color); 
            border-radius: 10px; 
            padding: 16px 20px; 
            display: flex; 
            justify-content: space-between; 
            align-items: center; 
            box-shadow: var(--shadow);
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .approval-item:hover {
            border-color: #cbd5e1;
            box-shadow: var(--shadow-hover);
        }
        .user-details { display: flex; align-items: center; gap: 16px; }

        .btn-action-review { 
            display: inline-flex; 
            align-items: center; 
            gap: 6px; 
            padding: 8px 14px; 
            border-radius: 6px; 
            font-size: 12px; 
            font-weight: 600; 
            cursor: pointer; 
            text-decoration: none;
            border: 1px solid #ddd6fe; 
            color: var(--accent-purple); 
            background: var(--accent-purple-bg);
            transition: all 0.2s;
        }
        .btn-action-review:hover {
            background-color: var(--accent-purple);
            border-color: var(--accent-purple);
            color: #fff;
        }

        /* User Breakdown */
        .breakdown-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 40px; }
        .breakdown-card { 
            background-color: var(--bg-panel); 
            border: 1px solid var(--border-color); 
            border-radius: 10px; 
            padding: 24px; 
            box-shadow: var(--shadow);
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .breakdown-card:hover {
            border-color: #cbd5e1;
            box-shadow: var(--shadow-hover);
        }
        .breakdown-card h3 { font-size: 24px; font-weight: 700; margin-bottom: 4px; color: var(--text-primary); }
        .breakdown-card p { font-size: 13px; color: var(--text-secondary); margin-bottom: 12px; }
        .status-text { font-size: 12px; color: var(--success-green); font-weight: 600; }

        /* Pinned Announcements */
        .announcements-list { display: flex; flex-direction: column; gap: 12px; padding-bottom: 40px; }
        .announcement-card { 
            background-color: var(--bg-panel); 
            border: 1px solid var(--border-color); 
            border-radius: 10px; 
            padding: 20px; 
            display: flex; 
            gap: 16px; 
            box-shadow: var(--shadow);
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .announcement-card:hover {
            border-color: #cbd5e1;
            box-shadow: var(--shadow-hover);
        }
        .announcement-card.success { border-color: var(--success-green-border); background-color: var(--success-green-bg); }
        .announcement-card.warning { border-color: var(--warning-orange-border); background-color: var(--warning-orange-bg); }
        .announcement-card.info { border-color: var(--info-blue-border); background-color: var(--info-blue-bg); }

        .announcement-icon { margin-top: 2px; }
        .announcement-card.success .announcement-icon { color: var(--success-green); }
        .announcement-card.warning .announcement-icon { color: var(--warning-orange-text); }
        .announcement-card.info .announcement-icon { color: var(--info-blue); }

        .announcement-content h5 { font-size: 14px; font-weight: 600; margin-bottom: 6px; color: var(--text-primary); }
        .announcement-content p { font-size: 13px; color: var(--text-secondary); line-height: 1.5; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div style="display: flex; height: 100vh; overflow: hidden;">
            <uc:AdminSidebar runat="server" ID="SidebarCtrl" />
            
            <main class="main-content" style="flex: 1; overflow-y: auto;">
                <!-- Banner -->
                <div class="alert-banner">
                    <h2>Admin Dashboard</h2>
                    <p><asp:Literal ID="litBannerPendingCount" runat="server">0</asp:Literal> accounts pending approval. Review them in User Management.</p>
                    <a href="AdminUserManagement.aspx?filter=pending" class="btn-review">
                        Review pending accounts &rarr;
                    </a>
                </div>

                <!-- High-level Stats -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon"><i class="fa-solid fa-user-group"></i></div>
                        <div class="stat-value"><asp:Literal ID="litTotalUsers" runat="server">0</asp:Literal></div>
                        <div class="stat-label">Total Users</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
                        <div class="stat-value"><asp:Literal ID="litPendingApprovals" runat="server">0</asp:Literal></div>
                        <div class="stat-label">Pending Approvals</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon"><i class="fa-solid fa-book-open"></i></div>
                        <div class="stat-value"><asp:Literal ID="litPublishedCourses" runat="server">0</asp:Literal></div>
                        <div class="stat-label">Published Courses</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-icon"><i class="fa-solid fa-chart-simple"></i></div>
                        <div class="stat-value"><asp:Literal ID="litTotalEnrollments" runat="server">0</asp:Literal></div>
                        <div class="stat-label">Total Enrollments</div>
                    </div>
                </div>

                <!-- Pending Approvals Section -->
                <div class="section-header">
                    <div class="section-header-left">
                        <div class="section-title title-with-dot">Pending Approvals</div>
                        <span class="section-subtitle">
                            (Showing <asp:Literal ID="litShowingPendingCount" runat="server">0</asp:Literal> of 
                            <span class="count-highlight"><asp:Literal ID="litTotalPendingCount" runat="server">0</asp:Literal></span>)
                        </span>
                    </div>
                    <a href="AdminUserManagement.aspx?filter=pending" class="section-link">
                        View all (<asp:Literal ID="litViewAllPendingCount" runat="server">0</asp:Literal>) &rsaquo;
                    </a>
                </div>
    
                <div class="approvals-list">
                    <asp:Repeater ID="rptPendingApprovals" runat="server">
                        <ItemTemplate>
                            <div class="approval-item">
                                <div class="user-details">
                                    <div class="avatar"><%# GetInitials(Eval("FullName").ToString()) %></div>
                                    <div class="user-meta">
                                        <h5><%# Eval("FullName") %></h5>
                                        <p><%# Eval("Email") %><br /><%# Eval("Role") %> &bull; Applied <%# Eval("AppliedDate", "{0:yyyy-MM-dd}") %></p>
                                    </div>
                                </div>
                                <div class="action-btns">
                                    <a href="AdminReviewApplication.aspx?userId=<%# Eval("UserId") %>" class="btn-action-review">
                                        <i class="fa-solid fa-file-signature"></i> Review Application
                                    </a>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    
                    <asp:Panel ID="pnlNoPending" runat="server" Visible="false" CssClass="empty-placeholder">
                        <i class="fa-solid fa-check-circle" style="color: var(--success-green); margin-right: 6px;"></i> All applications have been reviewed.
                    </asp:Panel>
                </div>

                <!-- User Breakdown Section -->
                <div class="section-header">
                    <div class="section-title">User Breakdown</div>
                </div>
    
                <div class="breakdown-grid">
                    <div class="breakdown-card">
                        <h3><asp:Literal ID="litLearnersCount" runat="server">0</asp:Literal></h3>
                        <p>Learners</p>
                        <div class="status-text"><asp:Literal ID="litActiveLearnersCount" runat="server">0</asp:Literal> active</div>
                    </div>
                    <div class="breakdown-card">
                        <h3><asp:Literal ID="litTeachersCount" runat="server">0</asp:Literal></h3>
                        <p>Teachers</p>
                        <div class="status-text"><asp:Literal ID="litActiveTeachersCount" runat="server">0</asp:Literal> active</div>
                    </div>
                    <div class="breakdown-card">
                        <h3><asp:Literal ID="litActiveTotalCount" runat="server">0</asp:Literal></h3>
                        <p>Active Total</p>
                        <div class="status-text"><asp:Literal ID="litActiveSubTotal" runat="server">0</asp:Literal> active</div>
                    </div>
                </div>

                <!-- Pinned Announcements Section -->
                <div class="section-header">
                    <div class="section-header-left">
                        <div class="section-title">Pinned Announcements</div>
                        <span class="section-subtitle">
                            (Showing <asp:Literal ID="litShowingPinnedCount" runat="server">0</asp:Literal> of 
                            <span style="color: var(--accent-purple); font-weight: 500;"><asp:Literal ID="litTotalPinnedCount" runat="server">0</asp:Literal></span>)
                        </span>
                    </div>
                    <a href="AdminCommunity.aspx" class="section-link">Manage &rarr;</a>
                </div>
    
                <div class="announcements-list">
                    <asp:Repeater ID="rptPinnedAnnouncements" runat="server">
                        <ItemTemplate>
                            <div class="announcement-card <%# Eval("CardType") %>">
                                <div class="announcement-icon"><i class="<%# GetAnnouncementIcon(Eval("CardType").ToString()) %>"></i></div>
                                <div class="announcement-content">
                                    <h5><%# Eval("Title") %></h5>
                                    <p><%# Eval("Content") %></p>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                    <asp:Panel ID="pnlNoPinned" runat="server" Visible="false" CssClass="empty-placeholder">
                        <i class="fa-solid fa-thumbtack" style="margin-right: 6px;"></i> No pinned announcements currently.
                    </asp:Panel>
                </div>
            </main>
        </div>
    </form>
</body>
</html>