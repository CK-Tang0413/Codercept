<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Administrator Nav Bar.aspx.cs" Inherits="Codercept.Administrator_Dashboard" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CodeLearn - Admin Portal</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        /* --- Colors & Variables --- */
        :root {
            --bg-body: #0d0e12;
            --bg-sidebar: #13141a;
            --bg-panel: #1a1b23;
            --text-primary: #f3f4f6;
            --text-secondary: #9ca3af;
            --border-color: #2b2d3a;
            --accent-purple: #6366f1;
            --accent-purple-bg: rgba(99, 102, 241, 0.15);
            --success-green: #10b981;
            --danger-red: #ef4444;
            --warning-orange: #f59e0b;
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
            display: flex;
            height: 100vh;
            overflow: hidden;
        }

        /* --- Sidebar --- */
        .sidebar {
            width: 260px;
            background-color: var(--bg-sidebar);
            border-right: 1px solid var(--border-color);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            z-index: 10;
        }

        .sidebar-top { padding: 24px 16px; }
        .logo-area { display: flex; align-items: center; gap: 12px; margin-bottom: 32px; padding-left: 8px; }
        .logo-icon { background-color: var(--success-green); color: #fff; font-weight: 700; font-size: 12px; width: 28px; height: 28px; display: flex; align-items: center; justify-content: center; border-radius: 6px; }
        .logo-text h1 { font-size: 15px; font-weight: 600; }
        .logo-text p { font-size: 12px; color: var(--text-secondary); }

        .nav-menu { list-style: none; }
        .nav-item {
            display: flex; align-items: center; gap: 12px; padding: 10px 12px; margin-bottom: 4px;
            border-radius: 6px; color: var(--text-secondary); text-decoration: none;
            font-size: 14px; font-weight: 500; transition: all 0.2s; cursor: pointer;
        }
        .nav-item:hover { background-color: var(--bg-panel); color: var(--text-primary); }
        .nav-item.active { background-color: var(--accent-purple-bg); color: var(--accent-purple); }

        /* --- Sidebar Bottom (User Profile & Sign Out) --- */
        .sidebar-bottom { 
            padding: 20px 16px; 
            border-top: 1px solid var(--border-color); 
        }
        
        .user-profile { 
            display: flex; 
            align-items: center; 
            gap: 12px; 
            margin-bottom: 16px; 
            padding: 8px;
            border-radius: 6px;
            text-decoration: none;
            color: inherit;
            transition: background-color 0.2s;
            cursor: pointer;
        }
        
        .user-profile:hover {
            background-color: var(--bg-panel);
        }

        .avatar { width: 36px; height: 36px; background-color: var(--bg-panel); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 600; font-size: 13px; }
        .user-info h4 { font-size: 14px; font-weight: 500; }
        .user-info p { font-size: 12px; color: var(--text-secondary); }

        .sign-out-btn {
            background: none;
            border: none;
            color: var(--text-secondary);
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            cursor: pointer;
            padding: 8px;
            width: 100%;
            text-align: left;
            transition: color 0.2s;
        }

        .sign-out-btn:hover {
            color: var(--text-primary);
        }

        /* --- Main Content Area --- */
        .main-container {
            flex: 1;
            position: relative;
            overflow-y: auto;
        }

        .content-view {
            display: none; 
            padding: 32px 40px;
            animation: fadeIn 0.3s ease;
        }

        .content-view.active { display: block; }

        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(5px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .placeholder-content {
            height: 60vh;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
            color: var(--text-secondary);
            border: 2px dashed var(--border-color);
            border-radius: 12px;
            margin-top: 20px;
        }
        .placeholder-content i { font-size: 48px; margin-bottom: 16px; opacity: 0.5; }
    </style>
</head>
<body>

    <aside class="sidebar">
        <div class="sidebar-top">
            <div class="logo-area">
                <div class="logo-icon">CL</div>
                <div class="logo-text">
                    <h1>CodeLearn</h1>
                    <p>Admin Portal</p>
                </div>
            </div>
            
            <ul class="nav-menu">
                <li>
                    <a class="nav-item active" href="Admin Dashboard.aspx" target="contentFrame" onclick="switchView(this)">
                        <i class="fa-solid fa-house"></i> Dashboard
                    </a>
                </li>
                <li>
                    <a class="nav-item" href="Admin User Management.aspx" target="contentFrame" onclick="switchView(this)">
                        <i class="fa-solid fa-users-gear"></i> User Management
                    </a>
                </li>
                <li>
                    <a class="nav-item" href="Admin Community.aspx" target="contentFrame" onclick="switchView(this)">
                        <i class="fa-solid fa-globe"></i> Community
                    </a>
                </li>
                <li>
                    <a class="nav-item" href="Admin Courses.aspx" target="contentFrame" onclick="switchView(this)">
                        <i class="fa-solid fa-book-open"></i> Courses
                    </a>
                </li>
            </ul>
        </div>

        <div class="sidebar-bottom">
            <!-- 
                TODO: Replace "#profile-page-placeholder" with the actual routing path 
                for your user profile interface in ASP.NET (e.g., href="/Admin/Profile") 
            -->
            <a href="#profile-page-placeholder" class="user-profile">
                <div class="avatar">SA</div>
                <div class="user-info">
                    <h4>System Admin</h4>
                    <p>admin@codelearn.edu</p>
                </div>
            </a>
            
            <button class="sign-out-btn" onclick="handleSignOut()">
                <i class="fa-solid fa-arrow-right-from-bracket"></i>
                Sign out
            </button>
        </div>
    </aside>

    <main class="main-container">
        <iframe name="contentFrame" src="Admin Dashboard.aspx" style="width: 100%; height: 100%; border: none;"></iframe>
    </main>

    <script>
        function switchView(clickedElement) {
            // Remove active class from all nav items
            const navItems = document.querySelectorAll('.nav-item');
            navItems.forEach(item => item.classList.remove('active'));

            // Add active class to the clicked item
            clickedElement.classList.add('active');
        }

        function handleSignOut() {
            alert('Signing out of admin portal...');
        }
    </script>
</body>
</html>
