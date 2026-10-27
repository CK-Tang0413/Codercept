<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminUserManagement.aspx.cs" Inherits="Codercept.Admin_User_Management" %>
<%@ Register Src="~/AdminSidebar.ascx" TagPrefix="uc" TagName="AdminSidebar" %>
<%@ Register Src="~/UserProfileDetails.ascx" TagPrefix="uc" TagName="UserProfileDetails" %>
<%@ Register Src="~/CreateAdminAccount.ascx" TagPrefix="uc" TagName="CreateAdminAccount" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>User Management</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link href="css/admin-portal.css" rel="stylesheet" type="text/css" />
        <style>
        /* User Table Grid Columns */
        .list-header,
        .list-row {
            grid-template-columns: 2.5fr 1.5fr 1fr 1fr 1.5fr;
        }

        .col-joined {
            font-size: 13px;
            color: var(--text-secondary);
        }

        /* Deleted Tab Notice */
        .deleted-notice-banner {
            display: none;
            background: var(--danger-red-bg);
            border: 1px solid var(--danger-red-border);
            border-radius: 8px;
            padding: 12px 16px;
            margin-bottom: 20px;
            font-size: 13px;
            color: #b91c1c;
            align-items: center;
            gap: 10px;
        }
        .deleted-notice-banner i {
            font-size: 16px;
            color: var(--danger-red);
        }

        .retention-text {
            font-size: 11px;
            color: var(--danger-red);
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div style="display: flex; height: 100vh; overflow: hidden;">
            <uc:AdminSidebar runat="server" ID="SidebarCtrl" />
            
            <main class="main-content" style="flex: 1; overflow-y: auto;">
                
                <!-- Page Header with SuperAdmin Add Button -->
                <div class="page-header-row">
                    <div class="page-header">
                        <h1>User Management</h1>
                        <p id="userCountText">12 registered users</p>
                    </div>

                    <!-- Only visible to SuperAdmin role -->
                    <asp:Panel ID="pnlSuperAdminAction" runat="server">
                        <button type="button" class="btn-add-admin" onclick="openAddAdminModal()">
                            <i class="fa-solid fa-user-plus"></i> Add New Admin
                        </button>
                    </asp:Panel>
                </div>

                <!-- Search Bar -->
                <div class="search-container">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" id="searchInput" placeholder="Search by name or email..." onkeyup="handleSearch()" />
                </div>

                <!-- Tabs Filter -->
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

                <!-- Purge Banner -->
                <div id="deletedNoticeBanner" class="deleted-notice-banner">
                    <i class="fa-solid fa-triangle-exclamation"></i>
                    <div>
                        <strong>Weekly Data Purge Policy:</strong> Accounts in this section are retained for 7 days before being permanently purged from the database every Sunday.
                    </div>
                </div>

                <!-- Users Grid Table -->
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
                        <div class="list-row user-row" data-id="1" data-role="admin" data-status="active"
                             data-name="Tang Chee Kin" data-email="tterry616@gmail.com" data-joined="2023-01-05">
                            <div class="col-user">
                                <div class="avatar" style="background-color: var(--accent-rose-bg); color: var(--accent-rose);">TK</div>
                                <div class="user-meta">
                                    <h5 class="user-name">Tang Chee Kin</h5>
                                    <p class="user-email">tterry616@gmail.com</p>
                                </div>
                            </div>
                            <div><span class="badge badge-admin">SuperAdmin</span></div>
                            <div class="status-cell"><span class="badge badge-active">Active</span></div>
                            <div class="col-joined">2023-01-05</div>
                            <div class="col-actions">
                                <button type="button" class="btn-action btn-view" onclick="openUserProfileModal(this)" title="View Details"><i class="fa-regular fa-eye"></i></button>
                                <button type="button" class="btn-action" disabled title="SuperAdmin cannot be deactivated">Deactivate</button>
                                <button type="button" class="btn-icon" disabled><i class="fa-regular fa-trash-can"></i></button>
                            </div>
                        </div>

                        <!-- User (Admin) -->
                        <div class="list-row user-row" data-id="2" data-role="admin" data-status="active"
                             data-name="Kevin Wong" data-email="kevin.wong@codelearn.edu" data-joined="2023-06-22">
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
                                <button type="button" class="btn-action btn-view" onclick="openUserProfileModal(this)" title="View Details"><i class="fa-regular fa-eye"></i></button>
                                <button type="button" class="btn-action" onclick="toggleUserStatus(this)">Deactivate</button>
                                <button type="button" class="btn-icon" onclick="softDeleteUser(this)"><i class="fa-regular fa-trash-can"></i></button>
                            </div>
                        </div>

                        <!-- User (Teacher Pending) -->
                        <div class="list-row user-row" data-id="USR_003" data-role="teacher" data-status="pending"
                             data-name="Emma Wilson" data-email="emma.wilson@codelearn.edu" data-joined="2024-08-20">
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
                                <a href="AdminReviewApplication.aspx?userId=USR_003" class="btn-action" style="border-color: #ddd6fe; color: var(--accent-purple); background: var(--accent-purple-bg);">
                                    <i class="fa-solid fa-file-signature"></i> Review Application
                                </a>
                            </div>
                        </div>

                        <!-- User (Teacher) -->
                        <div class="list-row user-row" data-id="1" data-role="teacher" data-status="active"
                             data-name="Dr. Sarah Park" data-email="sarah.park@codelearn.edu" data-joined="2024-01-10"
                             data-age="36" data-region="Selangor" data-teachinglevel="Advanced" data-subject="Python Programming"
                             data-assistant="Jessica Lee" data-qualification="PhD in Computer Science" data-specialization="Distributed Computing"
                             data-languages="Python, Java, C++" data-credential="sarah_park_credentials.pdf">
                            <div class="col-user">
                                <div class="avatar">SP</div>
                                <div class="user-meta">
                                    <h5 class="user-name">Dr. Sarah Park</h5>
                                    <p class="user-email">sarah.park@codelearn.edu</p>
                                </div>
                            </div>
                            <div><span class="badge badge-teacher">Teacher</span></div>
                            <div class="status-cell"><span class="badge badge-active">Active</span></div>
                            <div class="col-joined">2024-01-10</div>
                            <div class="col-actions">
                                <button type="button" class="btn-action btn-view" onclick="openUserProfileModal(this)" title="View Details"><i class="fa-regular fa-eye"></i></button>
                                <button type="button" class="btn-action" onclick="toggleUserStatus(this)">Deactivate</button>
                                <button type="button" class="btn-icon" onclick="softDeleteUser(this)"><i class="fa-regular fa-trash-can"></i></button>
                            </div>
                        </div>

                        <!-- User (Teaching Assistant) -->
                        <div class="list-row user-row" data-id="1" data-role="assistant" data-status="active"
                             data-name="Jessica Lee" data-email="jessica.lee@student.edu" data-joined="2024-02-15"
                             data-age="24" data-region="Selangor" data-teachinglevel="Intermediate" data-subject="Python for Beginners"
                             data-assistant="N/A" data-qualification="Bachelor of Computer Science" data-specialization="AI & Programming"
                             data-languages="Python, JavaScript" data-credential="jessica_transcript.pdf">
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
                                <button type="button" class="btn-action btn-view" onclick="openUserProfileModal(this)" title="View Details"><i class="fa-regular fa-eye"></i></button>
                                <button type="button" class="btn-action" onclick="toggleUserStatus(this)">Deactivate</button>
                                <button type="button" class="btn-icon" onclick="softDeleteUser(this)"><i class="fa-regular fa-trash-can"></i></button>
                            </div>
                        </div>

                        <!-- User (Learner) -->
                        <div class="list-row user-row" data-id="1" data-role="learner" data-status="active"
                             data-name="Kylan Shane Sedrick" data-email="kylan1234@gmail.com" data-joined="2026-02-10"
                             data-age="21" data-address="Negeri Sembilan, Malaysia" data-occupation="Student"
                             data-progress="Python for Beginners (Chapter 4), Java Fundamentals (Chapter 2)"
                             data-completed="C++ Object-Oriented Programming (Cert Issued)">
                            <div class="col-user">
                                <div class="avatar">KS</div>
                                <div class="user-meta">
                                    <h5 class="user-name">Kylan Shane Sedrick</h5>
                                    <p class="user-email">kylan1234@gmail.com</p>
                                </div>
                            </div>
                            <div><span class="badge badge-learner">Learner</span></div>
                            <div class="status-cell"><span class="badge badge-active">Active</span></div>
                            <div class="col-joined">2026-02-10</div>
                            <div class="col-actions">
                                <button type="button" class="btn-action btn-view" onclick="openUserProfileModal(this)" title="View Details"><i class="fa-regular fa-eye"></i></button>
                                <button type="button" class="btn-action" onclick="toggleUserStatus(this)">Deactivate</button>
                                <button type="button" class="btn-icon" onclick="softDeleteUser(this)"><i class="fa-regular fa-trash-can"></i></button>
                            </div>
                        </div>

                        <!-- User (Learner) -->
                        <div class="list-row user-row" data-id="2" data-role="learner" data-status="active"
                             data-name="Wan Hon Kit" data-email="wan1234@gmail.com" data-joined="2026-03-15"
                             data-age="21" data-address="Penang, Malaysia" data-occupation="Student"
                             data-progress="Java Fundamentals (Chapter 3)"
                             data-completed="None">
                            <div class="col-user">
                                <div class="avatar">WH</div>
                                <div class="user-meta">
                                    <h5 class="user-name">Wan Hon Kit</h5>
                                    <p class="user-email">wan1234@gmail.com</p>
                                </div>
                            </div>
                            <div><span class="badge badge-learner">Learner</span></div>
                            <div class="status-cell"><span class="badge badge-active">Active</span></div>
                            <div class="col-joined">2026-03-15</div>
                            <div class="col-actions">
                                <button type="button" class="btn-action btn-view" onclick="openUserProfileModal(this)" title="View Details"><i class="fa-regular fa-eye"></i></button>
                                <button type="button" class="btn-action" onclick="toggleUserStatus(this)">Deactivate</button>
                                <button type="button" class="btn-icon" onclick="softDeleteUser(this)"><i class="fa-regular fa-trash-can"></i></button>
                            </div>
                        </div>

                    </div>
        
                    <div id="noResults" class="no-results">
                        No users found matching this filter.
                    </div>
                </div>

                <!-- 1. View User Details Modal Control -->
                <uc:UserProfileDetails runat="server" ID="UserProfileDetailsCtrl" />

                <!-- 2. Create Admin Account Modal Control -->
                <uc:CreateAdminAccount runat="server" ID="CreateAdminAccountCtrl" />

                <script>
                    let currentFilter = 'all';

                    window.addEventListener('DOMContentLoaded', () => {
                        const urlParams = new URLSearchParams(window.location.search);
                        const approvedId = urlParams.get('approvedUserId');
                        if (approvedId) {
                            applyClientSideApproval(approvedId);
                        }
                        const activeTab = urlParams.get('tab');
                        if (activeTab === 'admin') {
                            const adminTab = Array.from(document.querySelectorAll('.tab')).find(t => t.innerText.toLowerCase().includes('admins'));
                            if (adminTab) filterUsers('admin', adminTab);
                        }
                        updateCounts();
                    });

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
                                    <button type="button" class="btn-action btn-view" onclick="openUserProfileModal(this)" title="View Details"><i class="fa-regular fa-eye"></i></button>
                                    <button type="button" class="btn-action" onclick="toggleUserStatus(this)">Deactivate</button>
                                    <button type="button" class="btn-icon" onclick="softDeleteUser(this)"><i class="fa-regular fa-trash-can"></i></button>
                                `;
                            }
                        }
                    }

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
                        } else {
                            row.setAttribute('data-status', 'active');
                            statusCell.innerHTML = '<span class="badge badge-active">Active</span>';
                            button.innerText = 'Deactivate';
                            button.classList.remove('btn-reactivate');
                        }
                    }

                    function softDeleteUser(button) {
                        const row = button.closest('.user-row');
                        const userId = row.getAttribute('data-id');
                        const userName = row.querySelector('.user-name').innerText;

                        if (confirm(`Move user "${userName}" to Deleted Accounts? This account will be scheduled for permanent removal during the weekly purge.`)) {
                            row.style.opacity = '0';
                            row.style.transform = 'scale(0.98)';

                            setTimeout(() => {
                                row.setAttribute('data-status', 'deleted');
                                row.setAttribute('data-deleted-at', new Date().toISOString());

                                const statusCell = row.querySelector('.status-cell');
                                if (statusCell) {
                                    statusCell.innerHTML = '<span class="badge badge-deleted">Deleted</span>';
                                }

                                const actionCell = row.querySelector('.col-actions');
                                if (actionCell) {
                                    actionCell.innerHTML = `<span class="retention-text"><i class="fa-solid fa-hourglass-half"></i> Auto-purge in 7d</span>`;
                                }

                                row.style.opacity = '1';
                                row.style.transform = 'scale(1)';

                                updateCounts();
                                applyFilters();
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

                    function filterUsers(filterType, clickedTab) {
                        currentFilter = filterType;
                        document.querySelectorAll('.tab').forEach(tab => tab.classList.remove('active'));
                        clickedTab.classList.add('active');

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