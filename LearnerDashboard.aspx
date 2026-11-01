<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LearnerDashboard.aspx.cs" Inherits="Codercept.LearnerDashboard" %>
<%@ Register Src="~/LearnerSideBar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dashboard - Codercept</title>
    
    <!-- 1. Import Global Variables & Shared Layout -->
    <link href="css/global.css" rel="stylesheet" type="text/css" />

    <!-- 2. Page-Specific Styles -->
    <style>
        :root {
            --stat-card-bg: var(--bg-surface);
            --greeting-bg: rgba(30, 22, 51, 0.6);
            --greeting-border: rgba(124, 58, 237, 0.2);
        }

        /* Greeting Section */
        .greeting-section {
            position: relative;
            display: flex;
            min-height: 180px;
            align-items: center;
            justify-content: space-between;
            gap: 32px;
            padding: 32px 38px;
            
            /* REMOVED: overflow: hidden; -> This was cutting off the popover */
            
            border-radius: 16px;
            color: #ffffff;
            background: radial-gradient(circle at 74% 0, rgba(255, 255, 255, 0.15), transparent 26%),
                        linear-gradient(120deg, #7c3aed 0%, #db2777 50%, #f97316 100%);
            box-shadow: 0 12px 30px rgba(124, 58, 237, 0.2);
            margin-bottom: 2rem;
        }

        /* ADDED: Use a pseudo-element wrapper to safely clip the background pattern */
        .greeting-section::before {
            content: "";
            position: absolute;
            inset: 0;
            border-radius: 16px;
            overflow: hidden;
            pointer-events: none;
            z-index: 0;
        }

        /* Ensure content and notification bell sit above the clipping wrapper */
        .greeting-content, .greeting-header {
            position: relative;
            z-index: 2;
        }

        /* Subtle dot pattern overlay inside the safe wrapper */
        .greeting-section::after {
            position: absolute;
            inset: 0;
            opacity: 0.2;
            background-image: radial-gradient(rgba(255, 255, 255, 0.9) 1px, transparent 1px);
            background-size: 18px 18px;
            mask-image: linear-gradient(90deg, transparent 20%, black);
            -webkit-mask-image: linear-gradient(90deg, transparent 20%, black);
            content: "";
            pointer-events: none;
            z-index: 0;
        }

        .greeting-content {
            position: relative;
            z-index: 1;
            max-width: 600px;
        }

        .greeting-section h1 {
            font-size: 1.8rem;
            margin-bottom: 0.5rem;
            font-weight: 800;
            color: #ffffff;
            letter-spacing: -0.02em;
        }

        .greeting-section p {
            color: rgba(255, 255, 255, 0.9);
            font-size: 0.95rem;
            line-height: 1.6;
        }

        /* Decorative background elements */
        .greeting-pattern {
            position: absolute;
            inset: 0;
            pointer-events: none;
        }
        
        .greeting-pattern span {
            position: absolute;
            color: rgba(255, 255, 255, 0.1);
            font-family: "JetBrains Mono", monospace;
            font-size: 45px;
            font-weight: 700;
            transform: rotate(-12deg);
        }
        
        .greeting-pattern span:nth-child(1) { right: 25%; top: 15px; }
        .greeting-pattern span:nth-child(2) { right: 15%; bottom: 10px; }
        .greeting-pattern span:nth-child(3) { left: 45%; bottom: -10px; font-size: 65px; }
        
        /* Overview Stats Grid */
        .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 1.5rem; margin-bottom: 3rem; }
        
        .stat-card { 
            background: var(--bg-surface); 
            border: 1px solid var(--border-light); 
            padding: 1.5rem; 
            border-radius: 12px; 
            display: flex; 
            flex-direction: column; 
            justify-content: center;
            box-shadow: var(--shadow);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .stat-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow-hover);
        }

        .stat-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 42px;
            height: 42px;
            border-radius: 10px;
            margin-bottom: 1.25rem;
        }
        
        .stat-icon svg { width: 22px; height: 22px; }

        /* Assign distinct colors to each stat card icon */
        .stat-card:nth-child(1) .stat-icon { color: #7c3aed; background: #f3e8ff; } /* Purple */
        .stat-card:nth-child(2) .stat-icon { color: #b45309; background: #fef3c7; } /* Amber */
        .stat-card:nth-child(3) .stat-icon { color: #2563eb; background: #eff6ff; } /* Blue */
        .stat-card:nth-child(4) .stat-icon { color: #16a34a; background: #dcfce7; } /* Green */

        .stat-value { font-size: 2.2rem; font-weight: 800; color: var(--text-primary); margin-bottom: 0.25rem; line-height: 1; }
        .stat-label { font-size: 0.85rem; color: var(--text-secondary); font-weight: 500; }
        
        /* Section Headers */
        .section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; }
        .section-header h2 { font-size: 1.25rem; font-weight: 600; color: var(--text-primary); }
        .view-all { color: var(--accent-light); text-decoration: none; font-size: 0.9rem; font-weight: 500; transition: color 0.2s; }
        .view-all:hover { color: var(--accent-hover); text-decoration: underline; }

        /* Embedded Notification Bell */
        .global-notif-wrapper { position: relative; }
        
        .btn-notif-bell {
            position: relative;
            width: 42px;
            height: 42px;
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.3);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s ease;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.25);
        }

        .btn-notif-bell:hover, .btn-notif-bell.active {
            background: rgba(255, 255, 255, 0.3);
            border-color: rgba(255, 255, 255, 0.5);
            color: #ffffff;
        }

        /* Notification Popover Window */
        .notif-popover {
            display: none;
            position: absolute;
            top: 52px;
            right: 0;
            width: 360px;
            max-height: 460px;
            background: var(--bg-surface);
            border: 1px solid var(--border-light);
            border-radius: 12px;
            box-shadow: 0 12px 32px rgba(0, 0, 0, 0.55);
            flex-direction: column;
            overflow: hidden;
            text-align: left;
        }

        .notif-popover.open { display: flex; }
        .notif-header { padding: 1rem 1.25rem; border-bottom: 1px solid var(--border-light); display: flex; justify-content: space-between; align-items: center; background: rgba(255, 255, 255, 0.02); }
        .notif-header h4 { font-size: 0.95rem; font-weight: 600; color: var(--text-primary); margin: 0; }
        .notif-close { background: none; border: none; color: var(--text-muted); font-size: 1.2rem; cursor: pointer; line-height: 1; padding: 0; }
        .notif-close:hover { color: var(--text-primary); }
        .notif-body { overflow-y: auto; padding: 0.75rem; display: flex; flex-direction: column; gap: 0.6rem; max-height: 390px; }
        .notif-item { padding: 0.85rem 1rem; background: rgba(255, 255, 255, 0.02); border: 1px solid var(--border-light); border-radius: 8px; transition: border-color 0.2s; color: var(--text-primary); }
        .notif-item:hover { border-color: rgba(124, 58, 237, 0.4); }
        .notif-meta { display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.4rem; }
        
        .notif-type-badge { font-size: 0.65rem; font-weight: 700; padding: 0.15rem 0.5rem; border-radius: 4px; text-transform: uppercase; background: rgba(124, 58, 237, 0.15); color: var(--accent-light); border: 1px solid rgba(124, 58, 237, 0.3); }
        .notif-type-badge.invitation { background: rgba(74, 222, 128, 0.12); color: #4ade80; border-color: rgba(74, 222, 128, 0.3); }
        .notif-date { font-size: 0.75rem; color: var(--text-muted); }
        .notif-title { font-size: 0.9rem; font-weight: 600; color: var(--text-primary); margin-bottom: 0.25rem; }
        .notif-content { font-size: 0.82rem; color: var(--text-secondary); line-height: 1.5; }
        .notif-empty { text-align: center; padding: 2rem 1rem; color: var(--text-muted); font-size: 0.85rem; }
        
        .notif-badge { position: absolute; top: -4px; right: -4px; background: #ef4444; color: #ffffff; font-size: 0.7rem; font-weight: 700; min-width: 18px; height: 18px; border-radius: 999px; display: flex; align-items: center; justify-content: center; padding: 0 5px; border: 2px solid #7c3aed; }

        @media (max-width: 1024px) {
            .stats-grid { grid-template-columns: repeat(2, 1fr); }
        }
    </style>    
</head>
<body>
    <form id="form1" runat="server">
        <div class="dashboard-layout">
            
            <!-- Sidebar Injected Here -->
            <uc:Sidebar runat="server" ID="LearnerSideBarCtrl" />

            <!-- Main Content -->
            <main class="main-content">
                
               <!-- Greeting -->
                <div class="greeting-section">
                    <div class="greeting-pattern" aria-hidden="true">
                        <span>&lt;/&gt;</span>
                        <span>{ }</span>
                        <span>01</span>
                    </div>
                    
                    <div class="greeting-content">
                        <h1>Welcome back, <asp:Literal ID="litWelcomeName" runat="server" Text="Alex"></asp:Literal> 👋</h1>
                        <p><asp:Literal ID="litGreetingDesc" runat="server" Text="You have 2 active courses. Keep up the momentum!"></asp:Literal></p>
                    </div>

                    <!-- NEW: Embedded Notification Bell Container -->
                    <div class="greeting-header" style="position: absolute; top: 1.5rem; right: 2rem; z-index: 10;">
                        <asp:PlaceHolder ID="phNotificationBell" runat="server">
                            <div class="global-notif-wrapper" id="globalNotifWrapper" data-user-id='<%= Session["UserId"] ?? "0" %>'>
                                
                                <!-- Replaced Literal inside attribute with a HiddenField to fix CS0103 -->
                                <asp:HiddenField ID="hfLatestNotifId" runat="server" Value="0" ClientIDMode="Static" />
                                
                                <button type="button" class="btn-notif-bell" id="btnNotifBell" onclick="toggleNotifPopover(event)" title="Notifications">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
                                    </svg>
                                    <asp:Panel ID="pnlNotifBadge" runat="server" CssClass="notif-badge" ClientIDMode="Static" Visible="false">
                                        <asp:Literal ID="litNotifCount" runat="server"></asp:Literal>
                                    </asp:Panel>
                                </button>

                                <div class="notif-popover" id="notifPopover">
                                    <div class="notif-header">
                                        <h4>Notifications</h4>
                                        <button type="button" class="notif-close" onclick="closeNotifPopover()">×</button>
                                    </div>
                                    <div class="notif-body">
                                        <asp:Repeater ID="rptNotifications" runat="server">
                                            <ItemTemplate>
                                                <div class="notif-item" data-notif-id='<%# Eval("NotificationId") %>'>
                                                    <div class="notif-meta">
                                                        <span class='notif-type-badge <%# Eval("Type").ToString().ToLower() %>'><%# Eval("Type") %></span>
                                                        <span class="notif-date"><%# Eval("DateTime", "{0:dd MMM yyyy, hh:mm tt}") %></span>
                                                    </div>
                                                    <div class="notif-title"><%# Eval("Title") %></div>
                                                    <div class="notif-content"><%# Eval("Content") %></div>
                                                </div>
                                            </ItemTemplate>
                                        </asp:Repeater>
                                        <asp:Panel ID="pnlNoNotifications" runat="server" CssClass="notif-empty" Visible="false">
                                            You have no notifications right now.
                                        </asp:Panel>
                                    </div>
                                </div>
                            </div>
                        </asp:PlaceHolder>
                    </div>
                </div>

                <!-- Updated JavaScript to pass strict TypeScript/VS checks -->
                <script type="text/javascript">
                    document.addEventListener("DOMContentLoaded", function () { 
                        syncNotificationBadge(); 
                    });
                    
                    function getStorageKey() {
                        var wrapper = document.getElementById('globalNotifWrapper');
                        if (!wrapper) return null;
                        var userId = wrapper.getAttribute('data-user-id') || '0';
                        return 'codercept_last_seen_notif_' + userId;
                    }
                    
                    function syncNotificationBadge() {
                        var wrapper = document.getElementById('globalNotifWrapper');
                        var badge = document.getElementById('pnlNotifBadge');
                        var storageKey = getStorageKey();
                        
                        if (!wrapper || !badge || !storageKey) return;
                        
                        var lastSeenStr = localStorage.getItem(storageKey);
                        var lastSeenId = lastSeenStr ? parseInt(lastSeenStr, 10) : 0;
                        var items = wrapper.querySelectorAll('.notif-item');
                        var unreadCount = 0;
                        
                        items.forEach(function (item) {
                            var attr = item.getAttribute('data-notif-id');
                            var id = attr ? parseInt(attr, 10) : 0;
                            if (id > lastSeenId) { unreadCount++; }
                        });
                        
                        if (unreadCount > 0) { 
                            badge.textContent = unreadCount.toString(); 
                            badge.style.display = 'flex'; 
                        } else { 
                            badge.style.display = 'none'; 
                        }
                    }
                    
                    function toggleNotifPopover(e) {
                        if (e) e.stopPropagation();
                        var popover = document.getElementById('notifPopover');
                        var bell = document.getElementById('btnNotifBell');
                        var hiddenField = document.getElementById('hfLatestNotifId');
                        var badge = document.getElementById('pnlNotifBadge');
                        var storageKey = getStorageKey();
                        
                        if (popover && bell) {
                            var isOpening = !popover.classList.contains('open');
                            popover.classList.toggle('open');
                            bell.classList.toggle('active');
                            
                            if (isOpening && hiddenField && storageKey) {
                                localStorage.setItem(storageKey, hiddenField.value);
                                if (badge) { badge.style.display = 'none'; }
                            }
                        }
                    }
                    
                    function closeNotifPopover() {
                        var popover = document.getElementById('notifPopover');
                        var bell = document.getElementById('btnNotifBell');
                        if (popover && bell) { 
                            popover.classList.remove('open'); 
                            bell.classList.remove('active'); 
                        }
                    }
                    
                    document.addEventListener('click', function (e) {
                        var wrapper = document.getElementById('globalNotifWrapper');
                        var target = e.target;
                        // Strict Node cast to satisfy TypeScript
                        if (wrapper && target instanceof Node && !wrapper.contains(target)) { 
                            closeNotifPopover(); 
                        }
                    });
                </script>

            
                
                <!-- Hidden for Guests -->
                <asp:PlaceHolder ID="phLearnerData" runat="server">
                    <!-- User Overview Blocks -->

                    <div class="stats-grid">
                        <div class="stat-card">
                            <div class="stat-icon">
                                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" /></svg>
                            </div>
                            <div class="stat-value"><asp:Literal ID="litStatEnrolled" runat="server"></asp:Literal></div>
                            <div class="stat-label">Enrolled Courses</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon">
                                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2m-6 9l2 2 4-4" /></svg>
                            </div>
                            <div class="stat-value"><asp:Literal ID="litStatChapters" runat="server"></asp:Literal></div>
                            <div class="stat-label">Chapters Done</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon">
                                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z" /></svg>
                            </div>
                            <div class="stat-value"><asp:Literal ID="litStatAvgScore" runat="server"></asp:Literal></div>
                            <div class="stat-label">Avg. Score</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon">
                                <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7h8m0 0v8m0-8l-8 8-4-4-6 6" /></svg>
                            </div>
                            <div class="stat-value"><asp:Literal ID="litStatProgress" runat="server"></asp:Literal></div>
                            <div class="stat-label">Total Progress</div>
                        </div>
                    </div>

                    <!-- Continue Learning Progress -->
                    <div class="section-header">
                        <h2>Continue Learning</h2>
                        <a href="MyProgress.aspx" class="view-all">View all active courses &rarr;</a>
                    </div>
                    
                    <div class="course-grid">
                        <asp:Repeater ID="rptActiveCourses" runat="server">
                            <ItemTemplate>
                                <a href='CourseDetails.aspx?id=<%# Eval("CourseId") %>' class="course-card">
                                    <!-- Teacher Dashboard Style Thumbnail -->
                                    <div class='course-thumbnail course-thumbnail--<%# Eval("LanguageCSS") %>'>
                                        <span class='card-floating-badge badge-<%# Eval("DifficultyLevel").ToString().ToLower() %>'><%# Eval("DifficultyLevel") %></span>
                                        <span><%# Eval("Language").ToString().Substring(0, 1) %></span>
                                    </div>
                                    
                                    <div class="course-content">
                                        <h3 class="course-title"><%# Eval("CourseTitle") %></h3>
                                        <p class="course-desc">Up next: <%# Eval("NextChapterTitle") %></p>
                                    </div>
                                    
                                    <!-- Dedicated Progress Footer Block -->
                                    <div class="course-progress-footer">
                                        <div class="progress-header">
                                            <span>Course Progress</span>
                                            <strong style="color: var(--accent-primary);"><%# Eval("ProgressPercentage") %>%</strong>
                                        </div>
                                        <div class="progress-track">
                                            <div class="progress-fill" style='width: <%# Eval("ProgressPercentage") %>%;'></div>
                                        </div>
                                    </div>
                                </a>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </asp:PlaceHolder>

                <!-- Recommended Courses (Visible to Everyone) -->
                <div class="section-header">
                    <h2 id="recommendationHeader" runat="server">Recommended for You</h2>
                    <a href="CourseCatalog.aspx" class="view-all">View all recommendations &rarr;</a>
                </div>

                <div class="course-grid">
                    <asp:Repeater ID="rptRecommended" runat="server" OnItemCommand="rptRecommended_ItemCommand">
                        <ItemTemplate>
                            <a href='CourseDetails.aspx?id=<%# Eval("CourseId") %>' class="course-card">
                                <!-- Teacher Dashboard Style Thumbnail with Difficulty Badge -->
                                <div class='course-thumbnail course-thumbnail--<%# Eval("LanguageCSS") %>'>
                                    <span class='card-floating-badge badge-<%# Eval("DifficultyLevel").ToString().ToLower() %>'><%# Eval("DifficultyLevel") %></span>
                                    <span><%# Eval("Language").ToString().Substring(0, 1) %></span>
                                </div>
                                
                                <div class="course-content">
                                    <h3 class="course-title"><%# Eval("CourseTitle") %></h3>
                                    <p class="course-desc"><%# Eval("CourseDescription") %></p>
                                    
                                    <div class="course-meta-grid">
                                        <span class="course-meta-item">📖 <%# Eval("Chapters") %> chapters</span>
                                        <span class="course-meta-item">⏱️ <%# Eval("CourseDuration") %></span>
                                        <span class="course-meta-item">⭐ <%# Eval("Rating") %> Rating</span>
                                        
                                        <!-- Show Enrolled Count if NOT Enrolled -->
                                        <asp:PlaceHolder runat="server" Visible='<%# !Convert.ToBoolean(Eval("IsEnrolled")) %>'>
                                            <span class="course-meta-item">👥 <%# Eval("EnrolledCount") %> enrolled</span>
                                        </asp:PlaceHolder>
                                    </div>
                                    
                                    <!-- Show Progress Block & Continue Button if Enrolled -->
                                    <asp:PlaceHolder runat="server" Visible='<%# Convert.ToBoolean(Eval("IsEnrolled")) %>'>
                                        <div class="course-progress-footer">
                                            <div class="progress-header">
                                                <span>Course Progress</span>
                                                <strong style="color: var(--accent-primary);"><%# Eval("ProgressPercentage") %>%</strong>
                                            </div>
                                            <div class="progress-track">
                                                <div class="progress-fill" style='width: <%# Eval("ProgressPercentage") %>%;'></div>
                                            </div>
                                        </div>
                                        <span class="course-action-btn active">Continue Learning &rarr;</span>
                                    </asp:PlaceHolder>
                            
                                    <!-- Show Enroll Button if NOT Enrolled -->
                                    <asp:PlaceHolder runat="server" Visible='<%# !Convert.ToBoolean(Eval("IsEnrolled")) %>'>
                                        <span class="course-action-btn enroll">Enroll Now</span>
                                    </asp:PlaceHolder>
                                </div>
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

            </main>
        </div>
    </form>
</body>
</html>