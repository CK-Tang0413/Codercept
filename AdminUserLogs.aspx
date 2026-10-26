<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminUserLogs.aspx.cs" Inherits="Codercept.AdminUserLogs" %>
<%@ Register Src="~/AdminSidebar.ascx" TagPrefix="uc" TagName="AdminSidebar" %>
<%@ Register Src="~/UserProfileDetails.ascx" TagPrefix="uc" TagName="UserProfileDetails" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>User Activities Log - Codercept</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="css/admin-portal.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
        <style>
        /* Activity Logs Table Grid Columns */
        .list-header,
        .list-row {
            grid-template-columns: 0.8fr 2.5fr 1.2fr 2.2fr 1.2fr 1fr 1fr;
        }

        .col-logid {
            font-size: 12px;
            font-family: monospace;
            color: var(--text-secondary);
        }

        .session-window {
            font-size: 13px;
            color: var(--text-primary);
            line-height: 1.4;
        }
        .session-window span {
            display: block;
            font-size: 11px;
            color: var(--text-secondary);
        }

        .session-duration {
            font-size: 13px;
            font-weight: 500;
            color: #d1d5db;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div style="display: flex; height: 100vh; overflow: hidden;">
            <uc:AdminSidebar runat="server" ID="SidebarCtrl" />

            <main class="main-content" style="flex: 1; overflow-y: auto;">
                
                <div class="page-header-row">
                    <div class="page-header">
                        <h1>User Activities Log</h1>
                        <p>Track session durations, authentication events, and system access history.</p>
                    </div>

                    <div class="header-actions">
                        <button type="button" class="btn-refresh" onclick="window.location.reload();">
                            <i class="fa-solid fa-rotate"></i> Refresh
                        </button>
                    </div>
                </div>

                <!-- KPI Cards -->
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-icon"><i class="fa-solid fa-list-check"></i></div>
                        <div class="stat-value"><asp:Literal ID="litTotalSessions" runat="server">0</asp:Literal></div>
                        <div class="stat-label">Total Sessions Recorded</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon"><i class="fa-solid fa-circle-play"></i></div>
                        <div class="stat-value"><asp:Literal ID="litActiveSessions" runat="server">0</asp:Literal></div>
                        <div class="stat-label">Active / Live Sessions</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon"><i class="fa-solid fa-clock-rotate-left"></i></div>
                        <div class="stat-value"><asp:Literal ID="litAvgDuration" runat="server">0m</asp:Literal></div>
                        <div class="stat-label">Average Session Length</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-icon"><i class="fa-solid fa-user-group"></i></div>
                        <div class="stat-value"><asp:Literal ID="litUniqueUsers" runat="server">0</asp:Literal></div>
                        <div class="stat-label">Unique Users Logged</div>
                    </div>
                </div>

                <!-- Filters -->
                <div class="filter-toolbar">
                    <div class="search-container">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" id="searchInput" placeholder="Search by name, email, or log ID..." onkeyup="handleFilter()" />
                    </div>

                    <select id="dateFilter" class="select-date-filter" onchange="handleFilter()">
                        <option value="all">All Time History</option>
                        <option value="today">Today's Sessions</option>
                        <option value="7days">Past 7 Days</option>
                        <option value="30days">Past 30 Days</option>
                    </select>
                </div>

                <!-- Tabs: All Activities, Learners, Teachers, Teaching Assistant, Admin (SuperAdmin only) -->
                <div class="tabs-container">
                    <div class="tab active" onclick="filterRole('all', this)">All Activities</div>
                    <div class="tab" onclick="filterRole('learner', this)">Learners</div>
                    <div class="tab" onclick="filterRole('teacher', this)">Teachers</div>
                    <div class="tab" onclick="filterRole('assistant', this)">Teaching Assistant</div>
                    
                    <!-- Admin Tab: Rendered only if user is SuperAdmin -->
                    <asp:PlaceHolder ID="phAdminTab" runat="server">
                        <div class="tab" onclick="filterRole('admin', this)">
                            Admin <span class="badge" style="background: rgba(244, 63, 94, 0.15); color: var(--accent-rose); font-size: 10px; margin-left: 4px;">SUPER</span>
                        </div>
                    </asp:PlaceHolder>
                </div>

                <!-- Log Table -->
                <div class="log-table">
                    <div class="list-header">
                        <div>Log ID</div>
                        <div>User / Actor</div>
                        <div>Role</div>
                        <div>Session Window</div>
                        <div>Duration</div>
                        <div>Status</div>
                        <div style="text-align: right;">Action</div>
                    </div>

                    <div id="logRowsContainer">
                        <asp:Repeater ID="rptUserLogs" runat="server">
                            <ItemTemplate>
                                <div class="list-row log-row user-row" 
                                     data-id='<%# Eval("UserId") %>'
                                     data-role='<%# Eval("RoleCategory").ToString().ToLower() %>'
                                     data-name='<%# Eval("UserName") %>'
                                     data-email='<%# Eval("Email") %>'
                                     data-joined='<%# Eval("DateJoined", "{0:yyyy-MM-dd}") %>'
                                     data-start='<%# Eval("StartDateTime", "{0:yyyy-MM-dd HH:mm:ss}") %>'
                                     data-status='active'>
                                    
                                    <!-- Log ID -->
                                    <div class="col-logid">#LOG-<%# Eval("LogId") %></div>

                                    <!-- User Meta -->
                                    <div class="col-user">
                                        <div class="avatar" style='<%# Eval("RoleCategory").ToString().ToLower() == "admin" ? "background-color: var(--accent-rose-bg); color: var(--accent-rose);" : "" %>'>
                                            <%# GetInitials(Eval("UserName").ToString()) %>
                                        </div>
                                        <div class="user-meta">
                                            <h5 class="user-name"><%# Eval("UserName") %></h5>
                                            <p class="user-email"><%# Eval("Email") %></p>
                                        </div>
                                    </div>

                                    <!-- Role Badge -->
                                    <div>
                                        <span class="badge <%# GetRoleBadgeClass(Eval("Role").ToString()) %>">
                                            <%# Eval("Role") %>
                                        </span>
                                    </div>

                                    <!-- Session Window -->
                                    <div class="session-window">
                                        <%# Eval("StartDateTime", "{0:MMM dd, yyyy HH:mm}") %>
                                        <span>to <%# Eval("EndDateTime", "{0:HH:mm}") %></span>
                                    </div>

                                    <!-- Duration -->
                                    <div class="session-duration">
                                        <%# CalculateDuration(Convert.ToDateTime(Eval("StartDateTime")), Convert.ToDateTime(Eval("EndDateTime"))) %>
                                    </div>

                                    <!-- Status -->
                                    <div>
                                        <span class="status-badge <%# IsSessionActive(Convert.ToDateTime(Eval("EndDateTime"))) ? "status-active" : "status-completed" %>">
                                            <i class="<%# IsSessionActive(Convert.ToDateTime(Eval("EndDateTime"))) ? "fa-solid fa-spinner fa-spin" : "fa-solid fa-circle-check" %>"></i>
                                            <%# IsSessionActive(Convert.ToDateTime(Eval("EndDateTime"))) ? "In Progress" : "Completed" %>
                                        </span>
                                    </div>

                                    <!-- Action -->
                                    <div style="text-align: right;">
                                        <button type="button" class="btn-view-profile" onclick="openUserProfileModal(this)" title="View Details">
                                            <i class="fa-regular fa-eye"></i> Profile
                                        </button>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>

                        <asp:Panel ID="pnlNoLogs" runat="server" Visible="false" CssClass="empty-placeholder">
                            <i class="fa-regular fa-clock" style="font-size: 28px; margin-bottom: 8px; display: block;"></i>
                            No activity logs found.
                        </asp:Panel>
                    </div>

                    <div id="noClientResults" class="empty-placeholder" style="display: none;">
                        No activity records found matching this filter.
                    </div>
                </div>

                <uc:UserProfileDetails runat="server" ID="UserProfileDetailsCtrl" />

            </main>
        </div>

        <script>
            let activeRole = 'all';

            function filterRole(role, clickedTab) {
                activeRole = role;
                document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
                clickedTab.classList.add('active');
                handleFilter();
            }

            function handleFilter() {
                const search = document.getElementById('searchInput').value.toLowerCase().trim();
                const dateFilter = document.getElementById('dateFilter').value;
                const rows = document.querySelectorAll('.log-row');
                let visibleCount = 0;

                const now = new Date();

                rows.forEach(row => {
                    const role = row.getAttribute('data-role');
                    const name = row.querySelector('.user-name').innerText.toLowerCase();
                    const email = row.querySelector('.user-email').innerText.toLowerCase();
                    const logId = row.querySelector('.col-logid').innerText.toLowerCase();
                    const startDateStr = row.getAttribute('data-start');
                    const startDate = new Date(startDateStr);

                    // 1. Role tab match
                    let matchesRole = (activeRole === 'all') || (role === activeRole);

                    // 2. Search query match
                    let matchesSearch = !search || name.includes(search) || email.includes(search) || logId.includes(search);

                    // 3. Date range match
                    let matchesDate = true;
                    if (dateFilter === 'today') {
                        matchesDate = (now - startDate) < (24 * 60 * 60 * 1000);
                    } else if (dateFilter === '7days') {
                        matchesDate = (now - startDate) < (7 * 24 * 60 * 60 * 1000);
                    } else if (dateFilter === '30days') {
                        matchesDate = (now - startDate) < (30 * 24 * 60 * 60 * 1000);
                    }

                    if (matchesRole && matchesSearch && matchesDate) {
                        row.style.display = 'grid';
                        visibleCount++;
                    } else {
                        row.style.display = 'none';
                    }
                });

                const noRes = document.getElementById('noClientResults');
                noRes.style.display = (visibleCount === 0) ? 'block' : 'none';
            }
        </script>
    </form>
</body>
</html>