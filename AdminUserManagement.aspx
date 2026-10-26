<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminUserManagement.aspx.cs" Inherits="Codercept.Admin_User_Management" %>
<%@ Register Src="~/AdminSidebar.ascx" TagPrefix="uc" TagName="AdminSidebar" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>User Management</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link href="css/admin-portal.css" rel="stylesheet" type="text/css" />
    <style>
        :root {
            --bg-body: #0a0a0f;
            --bg-panel: #14151a;
            --text-primary: #f3f4f6;
            --text-secondary: #9ca3af;
            --border-color: #2b2d3a;
            
            --accent-purple: #6366f1;
            --accent-purple-bg: rgba(99, 102, 241, 0.1);
            
            --accent-blue: #3b82f6;
            --accent-blue-bg: rgba(59, 130, 246, 0.1);
            
            --accent-rose: #f43f5e;
            --accent-rose-bg: rgba(244, 63, 94, 0.1);
            
            --success-green: #10b981;
            --success-green-bg: rgba(16, 185, 129, 0.1);
            --success-green-border: rgba(16, 185, 129, 0.2);
            
            --danger-red: #ef4444;
            --danger-red-bg: rgba(239, 68, 68, 0.1);
            --danger-red-border: rgba(239, 68, 68, 0.2);
            
            --warning-orange: #f59e0b;
            --warning-orange-bg: rgba(245, 158, 11, 0.1);
            
            --gray-badge: #9ca3af;
            --gray-badge-bg: rgba(156, 163, 175, 0.1);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }

        body {
            background-color: var(--bg-body);
            color: var(--text-primary);
        }

        .main-content {
            padding: 32px 40px;
        }

        /* Header */
        .page-header {
            margin-bottom: 24px;
        }
        .page-header h1 {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 4px;
        }
        .page-header p {
            color: var(--text-secondary);
            font-size: 14px;
        }

        /* Search Bar */
        .search-container {
            background-color: var(--bg-panel);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 12px 16px;
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 24px;
        }
        .search-container i {
            color: var(--text-secondary);
        }
        .search-container input {
            background: none;
            border: none;
            color: var(--text-primary);
            font-size: 14px;
            width: 100%;
            outline: none;
        }
        .search-container input::placeholder {
            color: var(--text-secondary);
        }

        /* Tabs Filter */
        .tabs-container {
            display: flex;
            gap: 32px;
            border-bottom: 1px solid var(--border-color);
            margin-bottom: 24px;
        }
        .tab {
            padding: 0 0 12px 0;
            color: var(--text-secondary);
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            position: relative;
            display: flex;
            align-items: center;
            gap: 6px;
            transition: color 0.2s;
        }
        .tab:hover {
            color: var(--text-primary);
        }
        .tab.active {
            color: var(--accent-purple);
        }
        .tab.active::after {
            content: '';
            position: absolute;
            bottom: -1px;
            left: 0;
            right: 0;
            height: 2px;
            background-color: var(--accent-purple);
        }
        .dot {
            display: inline-block;
            width: 6px;
            height: 6px;
            background-color: var(--warning-orange);
            border-radius: 50%;
        }

        /* Deleted Tab Alert Banner */
        .deleted-notice-banner {
            display: none;
            background: rgba(239, 68, 68, 0.08);
            border: 1px solid var(--danger-red-border);
            border-radius: 8px;
            padding: 12px 16px;
            margin-bottom: 20px;
            font-size: 13px;
            color: #fca5a5;
            align-items: center;
            gap: 10px;
        }
        .deleted-notice-banner i {
            font-size: 16px;
            color: var(--danger-red);
        }

        /* User List Table */
        .user-table {
            background-color: var(--bg-panel);
            border: 1px solid var(--border-color);
            border-radius: 10px;
            overflow: hidden;
        }
        
        .list-header {
            display: grid;
            grid-template-columns: 2.5fr 1.5fr 1fr 1fr 1.5fr;
            padding: 16px 24px;
            border-bottom: 1px solid var(--border-color);
            color: var(--text-secondary);
            font-size: 13px;
            font-weight: 500;
        }
        
        .list-row {
            display: grid;
            grid-template-columns: 2.5fr 1.5fr 1fr 1fr 1.5fr;
            padding: 16px 24px;
            border-bottom: 1px solid var(--border-color);
            align-items: center;
            transition: opacity 0.25s ease, transform 0.25s ease;
        }
        .list-row:last-child {
            border-bottom: none;
        }

        /* Column contents */
        .col-user {
            display: flex;
            align-items: center;
            gap: 16px;
        }
        .avatar {
            width: 36px;
            height: 36px;
            background-color: #21232c;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 13px;
        }
        .user-meta h5 {
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 2px;
        }
        .user-meta p {
            font-size: 12px;
            color: var(--text-secondary);
        }

        .col-joined {
            font-size: 13px;
            color: var(--text-secondary);
        }

        /* Badges */
        .badge {
            display: inline-flex;
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 500;
        }
        .badge-teacher { background-color: var(--accent-blue-bg); color: var(--accent-blue); }
        .badge-ta { background-color: var(--accent-purple-bg); color: var(--accent-purple); }
        .badge-admin { background-color: var(--accent-rose-bg); color: var(--accent-rose); }
        .badge-learner { background-color: var(--gray-badge-bg); color: var(--gray-badge); }
        
        .badge-active { background-color: var(--success-green-bg); color: var(--success-green); }
        .badge-pending { background-color: var(--warning-orange-bg); color: var(--warning-orange); }
        .badge-inactive { background-color: rgba(255, 255, 255, 0.05); color: var(--text-secondary); border: 1px solid var(--border-color); }
        .badge-deleted { background-color: var(--danger-red-bg); color: var(--danger-red); border: 1px solid var(--danger-red-border); }

        /* Actions */
        .col-actions {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 8px;
        }
        .btn-action {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 500;
            cursor: pointer;
            background: none;
            transition: background 0.2s;
            border: 1px solid var(--border-color);
            color: var(--text-secondary);
            text-decoration: none;
        }
        .btn-action:hover { background-color: rgba(255, 255, 255, 0.05); color: var(--text-primary); }
        .btn-action:disabled { opacity: 0.5; cursor: not-allowed; }

        .btn-action.btn-reactivate {
            border-color: var(--success-green-border);
            color: var(--success-green);
        }
        .btn-action.btn-reactivate:hover {
            background-color: var(--success-green-bg);
        }

        .btn-action.btn-restore {
            border-color: rgba(99, 102, 241, 0.3);
            color: #a5b4fc;
            background: var(--accent-purple-bg);
        }
        .btn-action.btn-restore:hover {
            background: rgba(99, 102, 241, 0.2);
        }

        .btn-icon {
            background: none;
            border: none;
            color: var(--text-secondary);
            cursor: pointer;
            padding: 6px;
            font-size: 14px;
            transition: color 0.2s;
        }
        .btn-icon:hover { color: var(--danger-red); }
        .btn-icon:disabled { opacity: 0.5; cursor: not-allowed; }

        .retention-text {
            font-size: 11px;
            color: var(--danger-red);
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .no-results {
            display: none;
            text-align: center;
            padding: 40px;
            color: var(--text-secondary);
            font-size: 14px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div style="display: flex; height: 100vh; overflow: hidden;">
            <uc:AdminSidebar runat="server" ID="SidebarCtrl" />
            
            <main class="main-content" style="flex: 1; overflow-y: auto;">
                <div class="page-header">
                    <h1>User Management</h1>
                    <p id="userCountText">12 registered users</p>
                </div>

                <div class="search-container">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" id="searchInput" placeholder="Search by name or email..." onkeyup="handleSearch()" />
                </div>

                <!-- Tabs Filter (Includes new 'Deleted' tab) -->
                <div class="tabs-container">
                    <div class="tab active" onclick="filterUsers('all', this)">All</div>
                    <div class="tab" onclick="filterUsers('pending', this)">Pending <span class="dot"></span></div>
                    <div class="tab" onclick="filterUsers('admin', this)">Admins</div>
                    <div class="tab" onclick="filterUsers('learner', this)">Learners</div>
                    <div class="tab" onclick="filterUsers('teacher', this)">Teachers</div>
                    <div class="tab" onclick="filterUsers('assistant', this)">Assistants</div>
                    <div class="tab" onclick="filterUsers('deleted', this)">
                         Deleted (<span id="deletedCount">0</span>)
                    </div>
                </div>

                <!-- Scheduled Purge Alert Banner (Only shows on 'deleted' tab) -->
                <div id="deletedNoticeBanner" class="deleted-notice-banner">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                    <div>
                        <strong>Weekly Data Purge Policy:</strong> Accounts in this section are retained for 7 days before being permanently purged from the database every Sunday at 09:00 GMT.
                    </div>
                </div>

                <div class="user-table">
                    <div class="list-header">
                        <div>User</div>
                        <div>Role</div>
                        <div>Status</div>
                        <div>Joined</div>
                        <div style="text-align: right;">Actions</div>
                    </div>

                    <div id="userListContainer">
            
                        <!-- User (Admin) -->
                        <div class="list-row user-row" data-id="USR_001" data-role="admin" data-status="active">
                            <div class="col-user">
                                <div class="avatar" style="background-color: var(--accent-rose-bg); color: var(--accent-rose);">SA</div>
                                <div class="user-meta">
                                    <h5 class="user-name">System Admin</h5>
                                    <p class="user-email">admin@codelearn.edu</p>
                                </div>
                            </div>
                            <div><span class="badge badge-admin">Admin</span></div>
                            <div class="status-cell"><span class="badge badge-active">Active</span></div>
                            <div class="col-joined">2023-01-05</div>
                            <div class="col-actions">
                                <button type="button" class="btn-action" disabled title="Primary admin cannot be deactivated">Deactivate</button>
                                <button type="button" class="btn-icon" disabled><i class="fa-regular fa-trash-can"></i></button>
                            </div>
                        </div>

                        <!-- User (Admin) -->
                        <div class="list-row user-row" data-id="USR_002" data-role="admin" data-status="active">
                            <div class="col-user">
                                <div class="avatar">KW</div>
                                <div class="user-meta">
                                    <h5 class="user-name">Kevin Wong</h5>
                                    <p class="user-email">kevin.wong@codelearn.edu</p>
                                </div>
                            </div>
                            <div><span class="badge badge-admin">Admin</span></div>
                            <div class="status-cell"><span class="badge badge-active">Active</span></div>
                            <div class="col-joined">2023-06-22</div>
                            <div class="col-actions">
                                <button type="button" class="btn-action" onclick="toggleUserStatus(this)">Deactivate</button>
                                <button type="button" class="btn-icon" onclick="softDeleteUser(this)"><i class="fa-regular fa-trash-can"></i></button>
                            </div>
                        </div>

                        <!-- User (Teacher Pending) -->
                        <div class="list-row user-row" data-id="USR_003" data-role="teacher" data-status="pending">
                            <div class="col-user">
                                <div class="avatar">EW</div>
                                <div class="user-meta">
                                    <h5 class="user-name">Emma Wilson</h5>
                                    <p class="user-email">emma.wilson@codelearn.edu</p>
                                </div>
                            </div>
                            <div><span class="badge badge-teacher">Teacher</span></div>
                            <div class="status-cell"><span class="badge badge-pending">Pending</span></div>
                            <div class="col-joined">2024-08-20</div>
                            <div class="col-actions">
                                <a href="AdminReviewApplication.aspx?userId=USR_003" class="btn-action" style="border-color: var(--accent-purple); color: #a5b4fc; background: var(--accent-purple-bg);">
                                    <i class="fa-solid fa-file-signature"></i> Review Application
                                </a>
                            </div>
                        </div>

                        <!-- User (Teacher) -->
                        <div class="list-row user-row" data-id="USR_004" data-role="teacher" data-status="active">
                            <div class="col-user">
                                <div class="avatar">MT</div>
                                <div class="user-meta">
                                    <h5 class="user-name">Prof. Michael Torres</h5>
                                    <p class="user-email">michael.torres@codelearn.edu</p>
                                </div>
                            </div>
                            <div><span class="badge badge-teacher">Teacher</span></div>
                            <div class="status-cell"><span class="badge badge-active">Active</span></div>
                            <div class="col-joined">2024-01-15</div>
                            <div class="col-actions">
                                <button type="button" class="btn-action" onclick="toggleUserStatus(this)">Deactivate</button>
                                <button type="button" class="btn-icon" onclick="softDeleteUser(this)"><i class="fa-regular fa-trash-can"></i></button>
                            </div>
                        </div>

                        <!-- User (Teaching Assistant) -->
                        <div class="list-row user-row" data-id="USR_005" data-role="assistant" data-status="active">
                            <div class="col-user">
                                <div class="avatar">JL</div>
                                <div class="user-meta">
                                    <h5 class="user-name">Jessica Lee</h5>
                                    <p class="user-email">jessica.lee@student.edu</p>
                                </div>
                            </div>
                            <div><span class="badge badge-ta">Teaching Assistant</span></div>
                            <div class="status-cell"><span class="badge badge-active">Active</span></div>
                            <div class="col-joined">2024-02-15</div>
                            <div class="col-actions">
                                <button type="button" class="btn-action" onclick="toggleUserStatus(this)">Deactivate</button>
                                <button type="button" class="btn-icon" onclick="softDeleteUser(this)"><i class="fa-regular fa-trash-can"></i></button>
                            </div>
                        </div>

                        <!-- User (Teaching Assistant) -->
                        <div class="list-row user-row" data-id="USR_006" data-role="assistant" data-status="active">
                            <div class="col-user">
                                <div class="avatar">RN</div>
                                <div class="user-meta">
                                    <h5 class="user-name">Robert Ng</h5>
                                    <p class="user-email">robert.ng@codelearn.edu</p>
                                </div>
                            </div>
                            <div><span class="badge badge-ta">Teaching Assistant</span></div>
                            <div class="status-cell"><span class="badge badge-active">Active</span></div>
                            <div class="col-joined">2024-05-10</div>
                            <div class="col-actions">
                                <button type="button" class="btn-action" onclick="toggleUserStatus(this)">Deactivate</button>
                                <button type="button" class="btn-icon" onclick="softDeleteUser(this)"><i class="fa-regular fa-trash-can"></i></button>
                            </div>
                        </div>

                        <!-- User (Learner) -->
                        <div class="list-row user-row" data-id="USR_007" data-role="learner" data-status="active">
                            <div class="col-user">
                                <div class="avatar">AC</div>
                                <div class="user-meta">
                                    <h5 class="user-name">Alex Chen</h5>
                                    <p class="user-email">alex.chen@student.edu</p>
                                </div>
                            </div>
                            <div><span class="badge badge-learner">Learner</span></div>
                            <div class="status-cell"><span class="badge badge-active">Active</span></div>
                            <div class="col-joined">2024-03-01</div>
                            <div class="col-actions">
                                <button type="button" class="btn-action" onclick="toggleUserStatus(this)">Deactivate</button>
                                <button type="button" class="btn-icon" onclick="softDeleteUser(this)"><i class="fa-regular fa-trash-can"></i></button>
                            </div>
                        </div>

                        <!-- User (Learner) -->
                        <div class="list-row user-row" data-id="USR_008" data-role="learner" data-status="active">
                            <div class="col-user">
                                <div class="avatar">MR</div>
                                <div class="user-meta">
                                    <h5 class="user-name">Maya Rodriguez</h5>
                                    <p class="user-email">maya.r@student.edu</p>
                                </div>
                            </div>
                            <div><span class="badge badge-learner">Learner</span></div>
                            <div class="status-cell"><span class="badge badge-active">Active</span></div>
                            <div class="col-joined">2024-03-15</div>
                            <div class="col-actions">
                                <button type="button" class="btn-action" onclick="toggleUserStatus(this)">Deactivate</button>
                                <button type="button" class="btn-icon" onclick="softDeleteUser(this)"><i class="fa-regular fa-trash-can"></i></button>
                            </div>
                        </div>

                        <!-- User (Learner Pending) -->
                        <div class="list-row user-row" data-id="USR_009" data-role="learner" data-status="pending">
                            <div class="col-user">
                                <div class="avatar">JW</div>
                                <div class="user-meta">
                                    <h5 class="user-name">James Wilson</h5>
                                    <p class="user-email">james.w@student.edu</p>
                                </div>
                            </div>
                            <div><span class="badge badge-learner">Learner</span></div>
                            <div class="status-cell"><span class="badge badge-pending">Pending</span></div>
                            <div class="col-joined">2024-08-28</div>
                            <div class="col-actions">
                                <a href="AdminReviewApplication.aspx?userId=USR_009" class="btn-action" style="border-color: var(--accent-purple); color: #a5b4fc; background: var(--accent-purple-bg);">
                                    <i class="fa-solid fa-file-signature"></i> Review Application
                                </a>
                            </div>
                        </div>

                        <!-- User (Learner) -->
                        <div class="list-row user-row" data-id="USR_010" data-role="learner" data-status="active">
                            <div class="col-user">
                                <div class="avatar">LK</div>
                                <div class="user-meta">
                                    <h5 class="user-name">Lisa Kim</h5>
                                    <p class="user-email">lisa.kim@student.edu</p>
                                </div>
                            </div>
                            <div><span class="badge badge-learner">Learner</span></div>
                            <div class="status-cell"><span class="badge badge-active">Active</span></div>
                            <div class="col-joined">2024-04-10</div>
                            <div class="col-actions">
                                <button type="button" class="btn-action" onclick="toggleUserStatus(this)">Deactivate</button>
                                <button type="button" class="btn-icon" onclick="softDeleteUser(this)"><i class="fa-regular fa-trash-can"></i></button>
                            </div>
                        </div>

                        <!-- User (Learner Pending) -->
                        <div class="list-row user-row" data-id="USR_011" data-role="learner" data-status="pending">
                            <div class="col-user">
                                <div class="avatar">DB</div>
                                <div class="user-meta">
                                    <h5 class="user-name">David Brown</h5>
                                    <p class="user-email">david.b@student.edu</p>
                                </div>
                            </div>
                            <div><span class="badge badge-learner">Learner</span></div>
                            <div class="status-cell"><span class="badge badge-pending">Pending</span></div>
                            <div class="col-joined">2024-08-25</div>
                            <div class="col-actions">
                                <a href="AdminReviewApplication.aspx?userId=USR_011" class="btn-action" style="border-color: var(--accent-purple); color: #a5b4fc; background: var(--accent-purple-bg);">
                                    <i class="fa-solid fa-file-signature"></i> Review Application
                                </a>
                            </div>
                        </div>

                    </div>
        
                    <div id="noResults" class="no-results">
                        No users found matching this filter.
                    </div>
                </div>

                <script>
                    let currentFilter = 'all';

                    window.addEventListener('DOMContentLoaded', () => {
                        const urlParams = new URLSearchParams(window.location.search);
                        const approvedId = urlParams.get('approvedUserId');
                        if (approvedId) {
                            applyClientSideApproval(approvedId);
                        }
                        updateCounts();
                    });

                    // 1. Approval flow
                    function applyClientSideApproval(userId) {
                        const row = document.querySelector(`.user-row[data-id="${userId}"]`);
                        if (row) {
                            row.setAttribute('data-status', 'active');
                            const statusCell = row.querySelector('.status-cell');
                            if (statusCell) {
                                statusCell.innerHTML = '<span class="badge badge-active">Active</span>';
                            }
                            const actionCell = row.querySelector('.col-actions');
                            if (actionCell) {
                                actionCell.innerHTML = `
                                    <button type="button" class="btn-action" onclick="toggleUserStatus(this)">Deactivate</button>
                                    <button type="button" class="btn-icon" onclick="softDeleteUser(this)"><i class="fa-regular fa-trash-can"></i></button>
                                `;
                            }
                        }
                    }

                    // 2. Deactivate / Activate Toggle
                    function toggleUserStatus(button) {
                        const row = button.closest('.user-row');
                        const userId = row.getAttribute('data-id');
                        const statusCell = row.querySelector('.status-cell');
                        const currentStatus = row.getAttribute('data-status');

                        if (currentStatus === 'active') {
                            row.setAttribute('data-status', 'inactive');
                            statusCell.innerHTML = '<span class="badge badge-inactive">Unactive</span>';
                            button.innerText = 'Activate';
                            button.classList.add('btn-reactivate');

                            /* 
                             * TODO: Backend Integration - Deactivate
                             * UPDATE Users SET Status = 'Inactive', UpdatedAt = GETUTCDATE() WHERE UserId = @userId
                             */
                            console.log(`[Backend Hook] User ${userId} status set to Inactive`);
                        } else {
                            row.setAttribute('data-status', 'active');
                            statusCell.innerHTML = '<span class="badge badge-active">Active</span>';
                            button.innerText = 'Deactivate';
                            button.classList.remove('btn-reactivate');

                            /* 
                             * TODO: Backend Integration - Reactivate
                             * UPDATE Users SET Status = 'Active', UpdatedAt = GETUTCDATE() WHERE UserId = @userId
                             */
                            console.log(`[Backend Hook] User ${userId} status set to Active`);
                        }
                    }

                    // 3. Soft Delete Flow (Move to "Deleted Account" section with weekly auto-purge)
                    function softDeleteUser(button) {
                        const row = button.closest('.user-row');
                        const userId = row.getAttribute('data-id');
                        const userName = row.querySelector('.user-name').innerText;

                        if (confirm(`Move user "${userName}" to Deleted Accounts? This account will be scheduled for permanent removal during the weekly purge.`)) {
                            // Fade out transition
                            row.style.opacity = '0';
                            row.style.transform = 'scale(0.98)';

                            setTimeout(() => {
                                // Update internal data-status
                                row.setAttribute('data-status', 'deleted');
                                row.setAttribute('data-deleted-at', new Date().toISOString());

                                // Update Status badge to "Deleted"
                                const statusCell = row.querySelector('.status-cell');
                                if (statusCell) {
                                    statusCell.innerHTML = '<span class="badge badge-deleted">Deleted</span>';
                                }

                                // Update Actions column with Restore button and retention notice
                                const actionCell = row.querySelector('.col-actions');
                                if (actionCell) {
                                    actionCell.innerHTML = `
                                        <span class="retention-text"><i class="fa-solid fa-hourglass-half"></i> Auto-purge in 7d</span>
                                    `;
                                }

                                row.style.opacity = '1';
                                row.style.transform = 'scale(1)';

                                updateCounts();
                                applyFilters(); // Re-filter to immediately remove from current view

                                /* 
                                 * TODO: Backend Integration - Soft Delete
                                 * UPDATE Users 
                                 * SET Status = 'Deleted', 
                                 *     DeletedAt = GETUTCDATE(),
                                 *     ScheduledPurgeDate = DATEADD(day, 7, GETUTCDATE())
                                 * WHERE UserId = @userId
                                 */
                                console.log(`[Backend Hook] User ${userId} soft-deleted. Scheduled for weekly purge.`);
                            }, 250);
                        }
                    }

                    function updateCounts() {
                        const allRows = document.querySelectorAll('.user-row');
                        const activeOrPendingRows = Array.from(allRows).filter(r => r.getAttribute('data-status') !== 'deleted');
                        const deletedRows = Array.from(allRows).filter(r => r.getAttribute('data-status') === 'deleted');

                        const countText = document.getElementById('userCountText');
                        if (countText) {
                            countText.innerText = `${activeOrPendingRows.length} registered users`;
                        }

                        const deletedCounter = document.getElementById('deletedCount');
                        if (deletedCounter) {
                            deletedCounter.innerText = deletedRows.length;
                        }
                    }

                    // Filter logic
                    function filterUsers(filterType, clickedTab) {
                        currentFilter = filterType;
                        document.querySelectorAll('.tab').forEach(tab => tab.classList.remove('active'));
                        clickedTab.classList.add('active');

                        // Show/Hide weekly purge policy banner
                        const banner = document.getElementById('deletedNoticeBanner');
                        if (banner) {
                            banner.style.display = (filterType === 'deleted') ? 'flex' : 'none';
                        }

                        applyFilters();
                    }

                    function handleSearch() {
                        applyFilters();
                    }

                    function applyFilters() {
                        const searchTerm = document.getElementById('searchInput').value.toLowerCase();
                        const rows = document.querySelectorAll('.user-row');
                        let visibleCount = 0;

                        rows.forEach(row => {
                            const role = row.getAttribute('data-role');
                            const status = row.getAttribute('data-status');
                            const name = row.querySelector('.user-name').innerText.toLowerCase();
                            const email = row.querySelector('.user-email').innerText.toLowerCase();
            
                            let matchesFilter = false;

                            // Standard tabs only show non-deleted users
                            if (currentFilter === 'all') {
                                matchesFilter = (status !== 'deleted');
                            } else if (currentFilter === 'pending') {
                                matchesFilter = (status === 'pending');
                            } else if (currentFilter === 'learner') {
                                matchesFilter = (role === 'learner' && status !== 'deleted');
                            } else if (currentFilter === 'teacher') {
                                matchesFilter = (role === 'teacher' && status !== 'deleted');
                            } else if (currentFilter === 'assistant') {
                                matchesFilter = (role === 'assistant' && status !== 'deleted');
                            } else if (currentFilter === 'admin') {
                                matchesFilter = (role === 'admin' && status !== 'deleted');
                            } else if (currentFilter === 'deleted') {
                                // Dedicated 'deleted' tab shows ONLY soft-deleted records
                                matchesFilter = (status === 'deleted');
                            }

                            const matchesSearch = name.includes(searchTerm) || email.includes(searchTerm);

                            if (matchesFilter && matchesSearch) {
                                row.style.display = 'grid';
                                visibleCount++;
                            } else {
                                row.style.display = 'none';
                            }
                        });

                        const noResultsElement = document.getElementById('noResults');
                        if (visibleCount === 0) {
                            noResultsElement.style.display = 'block';
                            noResultsElement.innerText = (currentFilter === 'deleted') 
                                ? 'No deleted accounts found.' 
                                : 'No users found matching this filter.';
                        } else {
                            noResultsElement.style.display = 'none';
                        }
                    }
                </script>
            </main>
        </div>
    </form>
</body>
</html>