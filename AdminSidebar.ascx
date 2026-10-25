<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AdminSidebar.ascx.cs" Inherits="Codercept.Admin_Sidebar" %>

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
                <a class="nav-item active" href="AdminDashboard.aspx">
                    <i class="fa-solid fa-house"></i> Dashboard
                </a>
            </li>
            <li>
                <a class="nav-item" href="AdminUserManagement.aspx">
                    <i class="fa-solid fa-users-gear"></i> User Management
                </a>
            </li>
            <li>
                <a class="nav-item" href="AdminCommunity.aspx">
                    <i class="fa-solid fa-globe"></i> Community
                </a>
            </li>
            <li>
                <a class="nav-item" href="AdminCourses.aspx">
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
