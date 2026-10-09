<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin Dashboard.aspx.cs" Inherits="Codercept.Admin_Dashboard" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dashboard</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        /* --- MUST include variables here for the iframe to render them --- */
        :root {
            --bg-body: #0a0a0f;
            --bg-panel: #14151a;
            --text-primary: #f3f4f6;
            --text-secondary: #9ca3af;
            --border-color: #2b2d3a;
            
            --accent-purple: #6366f1;
            
            --success-green: #10b981;
            --success-green-bg: rgba(16, 185, 129, 0.1);
            --success-green-border: rgba(16, 185, 129, 0.2);
            
            --danger-red: #ef4444;
            --danger-red-bg: rgba(239, 68, 68, 0.1);
            --danger-red-border: rgba(239, 68, 68, 0.2);
            
            --warning-orange: #f59e0b;
            --warning-orange-bg: rgba(245, 158, 11, 0.1);
            --warning-orange-border: rgba(245, 158, 11, 0.2);
            
            --banner-bg: linear-gradient(90deg, #091e15 0%, #0d1418 100%);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }

        /* Base body styles required for the iframe */
        body {
            background-color: var(--bg-body);
            color: var(--text-primary);
        }

        .main-content {
            padding: 32px 40px;
        }

        /* Banner */
        .alert-banner {
            background: var(--banner-bg);
            border: 1px solid var(--success-green-border);
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 32px;
        }

        .alert-banner h2 { font-size: 22px; font-weight: 600; margin-bottom: 8px; }
        .alert-banner p { color: var(--text-secondary); font-size: 14px; margin-bottom: 20px; }

        .btn-review {
            background-color: rgba(217, 119, 6, 0.1);
            color: #d97706;
            border: 1px solid rgba(217, 119, 6, 0.2);
            padding: 10px 16px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 500;
            cursor: pointer;
            transition: background 0.2s;
        }
        .btn-review:hover { background-color: rgba(217, 119, 6, 0.15); }

        /* Stats Grid */
        .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 32px; }
        .stat-card { background-color: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 10px; padding: 20px; }
        .stat-icon { color: var(--accent-purple); margin-bottom: 12px; font-size: 18px; }
        .stat-card:nth-child(2) .stat-icon { color: var(--warning-orange); }
        .stat-card:nth-child(3) .stat-icon { color: #3b82f6; }
        .stat-card:nth-child(4) .stat-icon { color: var(--success-green); }
        .stat-value { font-size: 24px; font-weight: 600; margin-bottom: 4px; }
        .stat-label { font-size: 12px; color: var(--text-secondary); }

        /* Sections common */
        .section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
        .section-title { font-size: 15px; font-weight: 600; display: flex; align-items: center; gap: 8px; }
        .title-with-dot::before { content: ''; display: block; width: 6px; height: 6px; background-color: var(--warning-orange); border-radius: 50%; }
        .section-link { color: var(--accent-purple); font-size: 13px; text-decoration: none; }
        .section-link:hover { text-decoration: underline; }

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
        }
        .user-details { display: flex; align-items: center; gap: 16px; }
        .avatar { width: 36px; height: 36px; background-color: #21232c; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 600; font-size: 13px; }
        .user-meta h5 { font-size: 14px; font-weight: 500; margin-bottom: 4px; }
        .user-meta p { font-size: 12px; color: var(--text-secondary); line-height: 1.4; }

        .action-btns { display: flex; gap: 12px; }
        .btn-action { 
            display: flex; align-items: center; gap: 6px; padding: 6px 16px; 
            border-radius: 6px; font-size: 13px; font-weight: 500; cursor: pointer; 
            border: 1px solid transparent; background: none;
        }
        .btn-approve { border-color: var(--success-green-border); color: var(--success-green); background-color: var(--success-green-bg); }
        .btn-approve:hover { background-color: rgba(16, 185, 129, 0.15); }
        
        .btn-reject { border-color: var(--danger-red-border); color: var(--danger-red); background-color: var(--danger-red-bg); }
        .btn-reject:hover { background-color: rgba(239, 68, 68, 0.15); }

        /* User Breakdown */
        .breakdown-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-bottom: 40px; }
        .breakdown-card { background-color: var(--bg-panel); border: 1px solid var(--border-color); border-radius: 10px; padding: 24px; }
        .breakdown-card h3 { font-size: 24px; margin-bottom: 4px; }
        .breakdown-card p { font-size: 13px; color: var(--text-secondary); margin-bottom: 12px; }
        .status-text { font-size: 12px; color: var(--success-green); font-weight: 500;}

        /* Pinned Announcements */
        .announcements-list { display: flex; flex-direction: column; gap: 12px; padding-bottom: 40px; }
        .announcement-card { 
            background-color: var(--bg-panel); 
            border: 1px solid var(--border-color); 
            border-radius: 10px; 
            padding: 20px; 
            display: flex; 
            gap: 16px; 
        }
        .announcement-card.success { border-color: var(--success-green-border); background-color: var(--success-green-bg); }
        .announcement-card.warning { border-color: var(--warning-orange-border); background-color: var(--warning-orange-bg); }

        .announcement-icon { margin-top: 2px; }
        .announcement-card.success .announcement-icon { color: var(--success-green); }
        .announcement-card.warning .announcement-icon { color: var(--warning-orange); }

        .announcement-content h5 { font-size: 14px; font-weight: 600; margin-bottom: 6px; }
        .announcement-content p { font-size: 13px; color: var(--text-secondary); line-height: 1.5; }
    </style>
</head>
<body>
    <div class="main-content">
        <!-- Banner -->
        <div class="alert-banner">
            <h2>Admin Dashboard</h2>
            <p>3 accounts pending approval. Review them in User Management.</p>
            <button class="btn-review">Review pending accounts &rarr;</button>
        </div>

        <!-- High-level Stats -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon"><i class="fa-solid fa-user-group"></i></div>
                <div class="stat-value">9</div>
                <div class="stat-label">Total Users</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
                <div class="stat-value">3</div>
                <div class="stat-label">Pending Approvals</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon"><i class="fa-solid fa-book-open"></i></div>
                <div class="stat-value">6</div>
                <div class="stat-label">Published Courses</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon"><i class="fa-solid fa-chart-simple"></i></div>
                <div class="stat-value">454</div>
                <div class="stat-label">Total Enrollments</div>
            </div>
        </div>

        <!-- Pending Approvals Section -->
        <div class="section-header">
            <div class="section-title title-with-dot">Pending Approvals (3)</div>
            <a href="#" class="section-link">View all &rsaquo;</a>
        </div>
        
        <div class="approvals-list">
            <div class="approval-item" id="approval-1">
                <div class="user-details">
                    <div class="avatar">EW</div>
                    <div class="user-meta">
                        <h5>Emma Wilson</h5>
                        <p>emma.wilson@codelearn.edu<br />Teacher &bull; Applied 2024-08-20</p>
                    </div>
                </div>
                <div class="action-btns">
                    <button class="btn-action btn-approve" onclick="processApproval('approval-1', true)"><i class="fa-solid fa-check"></i> Approve</button>
                    <button class="btn-action btn-reject" onclick="processApproval('approval-1', false)"><i class="fa-solid fa-xmark"></i> Reject</button>
                </div>
            </div>

            <div class="approval-item" id="approval-2">
                <div class="user-details">
                    <div class="avatar">JW</div>
                    <div class="user-meta">
                        <h5>James Wilson</h5>
                        <p>james.w@student.edu<br />Learner &bull; Applied 2024-08-28</p>
                    </div>
                </div>
                <div class="action-btns">
                    <button class="btn-action btn-approve" onclick="processApproval('approval-2', true)"><i class="fa-solid fa-check"></i> Approve</button>
                    <button class="btn-action btn-reject" onclick="processApproval('approval-2', false)"><i class="fa-solid fa-xmark"></i> Reject</button>
                </div>
            </div>

            <div class="approval-item" id="approval-3">
                <div class="user-details">
                    <div class="avatar">DB</div>
                    <div class="user-meta">
                        <h5>David Brown</h5>
                        <p>david.b@student.edu<br />Learner &bull; Applied 2024-08-25</p>
                    </div>
                </div>
                <div class="action-btns">
                    <button class="btn-action btn-approve" onclick="processApproval('approval-3', true)"><i class="fa-solid fa-check"></i> Approve</button>
                    <button class="btn-action btn-reject" onclick="processApproval('approval-3', false)"><i class="fa-solid fa-xmark"></i> Reject</button>
                </div>
            </div>
        </div>

        <!-- User Breakdown Section -->
        <div class="section-header">
            <div class="section-title">User Breakdown</div>
        </div>
        
        <div class="breakdown-grid">
            <div class="breakdown-card">
                <h3>5</h3>
                <p>Learners</p>
                <div class="status-text">3 active</div>
            </div>
            <div class="breakdown-card">
                <h3>3</h3>
                <p>Teachers</p>
                <div class="status-text">2 active</div>
            </div>
            <div class="breakdown-card">
                <h3>5</h3>
                <p>Active Total</p>
                <div class="status-text">5 active</div>
            </div>
        </div>

        <!-- Pinned Announcements Section -->
        <div class="section-header">
            <div class="section-title">Pinned Announcements</div>
            <a href="#" class="section-link">Manage &rarr;</a>
        </div>
        
        <div class="announcements-list">
            <div class="announcement-card success">
                <div class="announcement-icon"><i class="fa-solid fa-check"></i></div>
                <div class="announcement-content">
                    <h5>New C++ Module Now Available!</h5>
                    <p>We are excited to announce the launch of "Data Structures with C++" by Prof. Michael Torres. Enroll today to master linked lists, trees, and hash tables from scratch.</p>
                </div>
            </div>

            <div class="announcement-card warning">
                <div class="announcement-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
                <div class="announcement-content">
                    <h5>Scheduled Maintenance — Sept 5, 2024</h5>
                    <p>The platform will undergo scheduled maintenance on September 5th from 2:00 AM to 4:00 AM UTC. Some features may be temporarily unavailable during this period.</p>
                </div>
            </div>
        </div>
    </div>

    <!-- JavaScript logic -->
    <script>
        function processApproval(elementId, isApprove) {
            const item = document.getElementById(elementId);
            if (item) {
                item.style.opacity = '0.5';
                item.style.pointerEvents = 'none';

                setTimeout(() => {
                    item.style.display = 'none';
                    // In a real app, do not use alerts. Using console.log for silent tracking.
                    console.log(isApprove ? 'User Approved' : 'User Rejected'); 
                }, 300);
            }
        }
    </script>
</body>
</html>