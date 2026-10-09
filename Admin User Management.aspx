<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin User Management.aspx.cs" Inherits="Codercept.Admin_User_Management" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>User Management</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
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
        }
        .btn-approve { border: 1px solid var(--success-green-border); color: var(--success-green); }
        .btn-approve:hover { background-color: var(--success-green-bg); }
        
        .btn-reject { border: 1px solid var(--danger-red-border); color: var(--danger-red); }
        .btn-reject:hover { background-color: var(--danger-red-bg); }
        
        .btn-deactivate { border: 1px solid var(--border-color); color: var(--text-secondary); }
        .btn-deactivate:hover { background-color: rgba(255, 255, 255, 0.05); }
        .btn-deactivate:disabled { opacity: 0.5; cursor: not-allowed; }

        .btn-icon {
            background: none;
            border: none;
            color: var(--text-secondary);
            cursor: pointer;
            padding: 6px;
            font-size: 14px;
            transition: color 0.2s;
        }
        .btn-icon:hover { color: var(--text-primary); }
        .btn-icon:disabled { opacity: 0.5; cursor: not-allowed; }

        /* No results message */
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
    <div class="main-content">
        
        <!-- Header -->
        <div class="page-header">
            <h1>User Management</h1>
            <p>12 registered users</p>
        </div>

        <!-- Search -->
        <div class="search-container">
            <i class="fa-solid fa-magnifying-glass"></i>
            <input type="text" id="searchInput" placeholder="Search by name or email..." onkeyup="handleSearch()" />
        </div>

        <!-- Filter Tabs -->
        <div class="tabs-container">
            <div class="tab active" onclick="filterUsers('all', this)">All (12)</div>
            <div class="tab" onclick="filterUsers('pending', this)">Pending (3) <span class="dot"></span></div>
            <div class="tab" onclick="filterUsers('admin', this)">Admins (2)</div>
            <div class="tab" onclick="filterUsers('learner', this)">Learners (5)</div>
            <div class="tab" onclick="filterUsers('teacher', this)">Teachers (3)</div>
            <div class="tab" onclick="filterUsers('assistant', this)">Assistants (2)</div>
        </div>

        <!-- User Table -->
        <div class="user-table">
            <div class="list-header">
                <div>User</div>
                <div>Role</div>
                <div>Status</div>
                <div>Joined</div>
                <div style="text-align: right;">Actions</div>
            </div>

            <div id="userListContainer">
                
                <!-- NEW: User (Admin) -->
                <div class="list-row user-row" data-role="admin" data-status="active">
                    <div class="col-user">
                        <div class="avatar" style="background-color: var(--accent-rose-bg); color: var(--accent-rose);">SA</div>
                        <div class="user-meta">
                            <h5 class="user-name">System Admin</h5>
                            <p class="user-email">admin@codelearn.edu</p>
                        </div>
                    </div>
                    <div><span class="badge badge-admin">Admin</span></div>
                    <div><span class="badge badge-active">Active</span></div>
                    <div class="col-joined">2023-01-05</div>
                    <div class="col-actions">
                        <button class="btn-action btn-deactivate" disabled title="Primary admin cannot be deactivated">Deactivate</button>
                        <button class="btn-icon" disabled><i class="fa-regular fa-trash-can"></i></button>
                    </div>
                </div>

                <!-- NEW: User (Admin) -->
                <div class="list-row user-row" data-role="admin" data-status="active">
                    <div class="col-user">
                        <div class="avatar">KW</div>
                        <div class="user-meta">
                            <h5 class="user-name">Kevin Wong</h5>
                            <p class="user-email">kevin.wong@codelearn.edu</p>
                        </div>
                    </div>
                    <div><span class="badge badge-admin">Admin</span></div>
                    <div><span class="badge badge-active">Active</span></div>
                    <div class="col-joined">2023-06-22</div>
                    <div class="col-actions">
                        <button class="btn-action btn-deactivate">Deactivate</button>
                        <button class="btn-icon"><i class="fa-regular fa-trash-can"></i></button>
                    </div>
                </div>

                <!-- User (Teacher) -->
                <div class="list-row user-row" data-role="teacher" data-status="active">
                    <div class="col-user">
                        <div class="avatar">SP</div>
                        <div class="user-meta">
                            <h5 class="user-name">Dr. Sarah Park</h5>
                            <p class="user-email">sarah.park@codelearn.edu</p>
                        </div>
                    </div>
                    <div><span class="badge badge-teacher">Teacher</span></div>
                    <div><span class="badge badge-active">Active</span></div>
                    <div class="col-joined">2024-01-10</div>
                    <div class="col-actions">
                        <button class="btn-action btn-deactivate">Deactivate</button>
                        <button class="btn-icon"><i class="fa-regular fa-trash-can"></i></button>
                    </div>
                </div>

                <!-- User (Teacher) -->
                <div class="list-row user-row" data-role="teacher" data-status="active">
                    <div class="col-user">
                        <div class="avatar">MT</div>
                        <div class="user-meta">
                            <h5 class="user-name">Prof. Michael Torres</h5>
                            <p class="user-email">michael.torres@codelearn.edu</p>
                        </div>
                    </div>
                    <div><span class="badge badge-teacher">Teacher</span></div>
                    <div><span class="badge badge-active">Active</span></div>
                    <div class="col-joined">2024-01-15</div>
                    <div class="col-actions">
                        <button class="btn-action btn-deactivate">Deactivate</button>
                        <button class="btn-icon"><i class="fa-regular fa-trash-can"></i></button>
                    </div>
                </div>

                <!-- User (Teacher) -->
                <div class="list-row user-row" data-role="teacher" data-status="pending">
                    <div class="col-user">
                        <div class="avatar">EW</div>
                        <div class="user-meta">
                            <h5 class="user-name">Emma Wilson</h5>
                            <p class="user-email">emma.wilson@codelearn.edu</p>
                        </div>
                    </div>
                    <div><span class="badge badge-teacher">Teacher</span></div>
                    <div><span class="badge badge-pending">Pending</span></div>
                    <div class="col-joined">2024-08-20</div>
                    <div class="col-actions">
                        <button class="btn-action btn-approve"><i class="fa-solid fa-user-check"></i> Approve</button>
                        <button class="btn-action btn-reject"><i class="fa-solid fa-user-xmark"></i> Reject</button>
                        <button class="btn-icon"><i class="fa-regular fa-trash-can"></i></button>
                    </div>
                </div>
                
                <!-- User (Teaching Assistant) -->
                <div class="list-row user-row" data-role="assistant" data-status="active">
                    <div class="col-user">
                        <div class="avatar">JL</div>
                        <div class="user-meta">
                            <h5 class="user-name">Jessica Lee</h5>
                            <p class="user-email">jessica.lee@student.edu</p>
                        </div>
                    </div>
                    <div><span class="badge badge-ta">Teaching Assistant</span></div>
                    <div><span class="badge badge-active">Active</span></div>
                    <div class="col-joined">2024-02-15</div>
                    <div class="col-actions">
                        <button class="btn-action btn-deactivate">Deactivate</button>
                        <button class="btn-icon"><i class="fa-regular fa-trash-can"></i></button>
                    </div>
                </div>

                <!-- User (Teaching Assistant) -->
                <div class="list-row user-row" data-role="assistant" data-status="active">
                    <div class="col-user">
                        <div class="avatar">RN</div>
                        <div class="user-meta">
                            <h5 class="user-name">Robert Ng</h5>
                            <p class="user-email">robert.ng@codelearn.edu</p>
                        </div>
                    </div>
                    <div><span class="badge badge-ta">Teaching Assistant</span></div>
                    <div><span class="badge badge-active">Active</span></div>
                    <div class="col-joined">2024-05-10</div>
                    <div class="col-actions">
                        <button class="btn-action btn-deactivate">Deactivate</button>
                        <button class="btn-icon"><i class="fa-regular fa-trash-can"></i></button>
                    </div>
                </div>

                <!-- User (Learner) -->
                <div class="list-row user-row" data-role="learner" data-status="active">
                    <div class="col-user">
                        <div class="avatar">AC</div>
                        <div class="user-meta">
                            <h5 class="user-name">Alex Chen</h5>
                            <p class="user-email">alex.chen@student.edu</p>
                        </div>
                    </div>
                    <div><span class="badge badge-learner">Learner</span></div>
                    <div><span class="badge badge-active">Active</span></div>
                    <div class="col-joined">2024-03-01</div>
                    <div class="col-actions">
                        <button class="btn-action btn-deactivate">Deactivate</button>
                        <button class="btn-icon"><i class="fa-regular fa-trash-can"></i></button>
                    </div>
                </div>

                <!-- User (Learner) -->
                <div class="list-row user-row" data-role="learner" data-status="active">
                    <div class="col-user">
                        <div class="avatar">MR</div>
                        <div class="user-meta">
                            <h5 class="user-name">Maya Rodriguez</h5>
                            <p class="user-email">maya.r@student.edu</p>
                        </div>
                    </div>
                    <div><span class="badge badge-learner">Learner</span></div>
                    <div><span class="badge badge-active">Active</span></div>
                    <div class="col-joined">2024-03-15</div>
                    <div class="col-actions">
                        <button class="btn-action btn-deactivate">Deactivate</button>
                        <button class="btn-icon"><i class="fa-regular fa-trash-can"></i></button>
                    </div>
                </div>

                <!-- User (Learner) -->
                <div class="list-row user-row" data-role="learner" data-status="pending">
                    <div class="col-user">
                        <div class="avatar">JW</div>
                        <div class="user-meta">
                            <h5 class="user-name">James Wilson</h5>
                            <p class="user-email">james.w@student.edu</p>
                        </div>
                    </div>
                    <div><span class="badge badge-learner">Learner</span></div>
                    <div><span class="badge badge-pending">Pending</span></div>
                    <div class="col-joined">2024-08-28</div>
                    <div class="col-actions">
                        <button class="btn-action btn-approve"><i class="fa-solid fa-user-check"></i> Approve</button>
                        <button class="btn-action btn-reject"><i class="fa-solid fa-user-xmark"></i> Reject</button>
                        <button class="btn-icon"><i class="fa-regular fa-trash-can"></i></button>
                    </div>
                </div>

                <!-- User (Learner) -->
                <div class="list-row user-row" data-role="learner" data-status="active">
                    <div class="col-user">
                        <div class="avatar">LK</div>
                        <div class="user-meta">
                            <h5 class="user-name">Lisa Kim</h5>
                            <p class="user-email">lisa.kim@student.edu</p>
                        </div>
                    </div>
                    <div><span class="badge badge-learner">Learner</span></div>
                    <div><span class="badge badge-active">Active</span></div>
                    <div class="col-joined">2024-04-10</div>
                    <div class="col-actions">
                        <button class="btn-action btn-deactivate">Deactivate</button>
                        <button class="btn-icon"><i class="fa-regular fa-trash-can"></i></button>
                    </div>
                </div>

                <!-- User (Learner) -->
                <div class="list-row user-row" data-role="learner" data-status="pending">
                    <div class="col-user">
                        <div class="avatar">DB</div>
                        <div class="user-meta">
                            <h5 class="user-name">David Brown</h5>
                            <p class="user-email">david.b@student.edu</p>
                        </div>
                    </div>
                    <div><span class="badge badge-learner">Learner</span></div>
                    <div><span class="badge badge-pending">Pending</span></div>
                    <div class="col-joined">2024-08-25</div>
                    <div class="col-actions">
                        <button class="btn-action btn-approve"><i class="fa-solid fa-user-check"></i> Approve</button>
                        <button class="btn-action btn-reject"><i class="fa-solid fa-user-xmark"></i> Reject</button>
                        <button class="btn-icon"><i class="fa-regular fa-trash-can"></i></button>
                    </div>
                </div>
            </div>
            
            <div id="noResults" class="no-results">
                No users found matching this filter.
            </div>
        </div>
    </div>

    <!-- JavaScript logic -->
    <script>
        let currentFilter = 'all';

        function filterUsers(filterType, clickedTab) {
            currentFilter = filterType;
            
            // 1. Update visual tab state
            document.querySelectorAll('.tab').forEach(tab => tab.classList.remove('active'));
            clickedTab.classList.add('active');

            // 2. Trigger the filter (incorporating any active search terms)
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
                
                // Determine if row matches the Tab Filter
                let matchesFilter = false;
                if (currentFilter === 'all') matchesFilter = true;
                else if (currentFilter === 'pending' && status === 'pending') matchesFilter = true;
                else if (currentFilter === 'learner' && role === 'learner') matchesFilter = true;
                else if (currentFilter === 'teacher' && role === 'teacher') matchesFilter = true;
                else if (currentFilter === 'assistant' && role === 'assistant') matchesFilter = true;
                else if (currentFilter === 'admin' && role === 'admin') matchesFilter = true;

                // Determine if row matches the Search Filter
                const matchesSearch = name.includes(searchTerm) || email.includes(searchTerm);

                // Apply combined logic
                if (matchesFilter && matchesSearch) {
                    row.style.display = 'grid';
                    visibleCount++;
                } else {
                    row.style.display = 'none';
                }
            });

            // Show 'No Results' placeholder if needed
            const noResultsElement = document.getElementById('noResults');
            if (visibleCount === 0) {
                noResultsElement.style.display = 'block';
            } else {
                noResultsElement.style.display = 'none';
            }
        }
    </script>
</body>
</html>
