<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="LearnerSideBar.ascx.cs" Inherits="Codercept.LearnerSideBar" %>

<style>
    /* Fixed Top-Right Notification Wrapper */
    .global-notif-wrapper {
        position: fixed;
        top: 1.5rem;
        right: 2.5rem;
        z-index: 9990;
    }

    .btn-notif-bell {
        position: relative;
        width: 42px;
        height: 42px;
        border-radius: 50%;
        background: var(--bg-surface);
        border: 1px solid var(--border-light);
        color: var(--text-secondary);
        display: flex;
        align-items: center;
        justify-content: center;
        cursor: pointer;
        transition: all 0.2s ease;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.25);
    }

    .btn-notif-bell:hover, .btn-notif-bell.active {
        color: var(--text-primary);
        border-color: var(--accent-primary);
        background: rgba(124, 58, 237, 0.12);
    }

    .notif-badge {
        position: absolute;
        top: -4px;
        right: -4px;
        background: #ef4444;
        color: #ffffff;
        font-size: 0.7rem;
        font-weight: 700;
        min-width: 18px;
        height: 18px;
        border-radius: 999px;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 0 5px;
        border: 2px solid var(--bg-main);
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
    }

    .notif-popover.open {
        display: flex;
    }

    .notif-header {
        padding: 1rem 1.25rem;
        border-bottom: 1px solid var(--border-light);
        display: flex;
        justify-content: space-between;
        align-items: center;
        background: rgba(255, 255, 255, 0.02);
    }

    .notif-header h4 {
        font-size: 0.95rem;
        font-weight: 600;
        color: var(--text-primary);
        margin: 0;
    }

    .notif-close {
        background: none;
        border: none;
        color: var(--text-muted);
        font-size: 1.2rem;
        cursor: pointer;
        line-height: 1;
        padding: 0;
    }
    .notif-close:hover { color: var(--text-primary); }

    .notif-body {
        overflow-y: auto;
        padding: 0.75rem;
        display: flex;
        flex-direction: column;
        gap: 0.6rem;
        max-height: 390px;
    }

    .notif-item {
        padding: 0.85rem 1rem;
        background: rgba(255, 255, 255, 0.02);
        border: 1px solid var(--border-light);
        border-radius: 8px;
        transition: border-color 0.2s;
    }

    .notif-item:hover {
        border-color: rgba(124, 58, 237, 0.4);
    }

    .notif-meta {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 0.4rem;
    }

    .notif-type-badge {
        font-size: 0.65rem;
        font-weight: 700;
        padding: 0.15rem 0.5rem;
        border-radius: 4px;
        text-transform: uppercase;
        background: rgba(124, 58, 237, 0.15);
        color: var(--accent-light);
        border: 1px solid rgba(124, 58, 237, 0.3);
    }

    .notif-type-badge.invitation {
        background: rgba(74, 222, 128, 0.12);
        color: #4ade80;
        border-color: rgba(74, 222, 128, 0.3);
    }

    .notif-date {
        font-size: 0.75rem;
        color: var(--text-muted);
    }

    .notif-title {
        font-size: 0.9rem;
        font-weight: 600;
        color: var(--text-primary);
        margin-bottom: 0.25rem;
    }

    .notif-content {
        font-size: 0.82rem;
        color: var(--text-secondary);
        line-height: 1.5;
    }

    .notif-empty {
        text-align: center;
        padding: 2rem 1rem;
        color: var(--text-muted);
        font-size: 0.85rem;
    }

    @media (max-width: 768px) {
        .global-notif-wrapper { top: 1rem; right: 1rem; }
        .notif-popover { width: 300px; right: 0; }
    }
</style>

<aside class="sidebar">
    <a href="LearnerDashboard.aspx" class="brand">
        <img id="imgBrandLogo" src="~/img/Codercept_Icon.png" alt="Codercept" runat="server" />
        Codercept
    </a>
    
    <nav class="nav-menu">
        <a href="LearnerDashboard.aspx" class="nav-item <%= GetActiveCssClass("LearnerDashboard") %>">Dashboard</a>
        <a href="CourseCatalog.aspx" class="nav-item <%= GetActiveCssClass("CourseCatalog") %>">Course Catalog</a>
        
        <!-- Hidden for Guests -->
        <asp:PlaceHolder ID="phRestrictedNav" runat="server">
            <a href="MyProgress.aspx" class="nav-item <%= GetActiveCssClass("MyProgress") %>">My Progress</a>
            <a href="Certificates.aspx" class="nav-item <%= GetActiveCssClass("Certificates") %>">Certificates</a>
            <a href="LearnerForum.aspx" class="nav-item <%= GetActiveCssClass("LearnerForum") %>">Forum</a>
        </asp:PlaceHolder>
    </nav>
    
    <div class="user-profile-section">
        <!-- Shown only for logged-in Learners -->
        <asp:PlaceHolder ID="phUserProfile" runat="server">
            <a href="profile.aspx" class="user-info">
                <div class="avatar"><asp:Literal ID="litUserInitial" runat="server" Text="A"></asp:Literal></div>
                <div class="user-details">
                    <h4><asp:Literal ID="litUserNameNav" runat="server" Text="Alex Chen"></asp:Literal></h4>
                    <p><asp:Literal ID="litUserEmailNav" runat="server" Text=""></asp:Literal></p>
                </div>
            </a>
            <asp:LinkButton ID="lnkSignOut" runat="server" CssClass="sign-out" OnClick="lnkSignOut_Click">
                Sign out
            </asp:LinkButton>
        </asp:PlaceHolder>

        <!-- Shown only for Guests -->
        <asp:PlaceHolder ID="phGuestAction" runat="server" Visible="false">
            <a href="signUp.aspx" class="btn-submit" style="text-align: center; text-decoration: none; display: block; font-size: 0.9rem;">
                Create Account
            </a>
            <a href="signIn.aspx" style="display: block; text-align: center; margin-top: 10px; color: var(--text-secondary); font-size: 0.85rem; text-decoration: none;">
                Or Sign In
            </a>
        </asp:PlaceHolder>
    </div>
</aside>

<!-- Global Top-Right Notification Bell & Popover -->
<asp:PlaceHolder ID="phNotificationBell" runat="server">
    <div class="global-notif-wrapper" id="globalNotifWrapper" 
         data-user-id="<%= Session["UserId"] ?? "0" %>" 
         data-latest-id="<asp:Literal ID='litLatestNotifId' runat='server' Text='0'></asp:Literal>">
        
        <button type="button" class="btn-notif-bell" id="btnNotifBell" onclick="toggleNotifPopover(event)" title="Notifications">
            <!-- Bell SVG Icon -->
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

    <script type="text/javascript">
        document.addEventListener("DOMContentLoaded", function () {
            syncNotificationBadge();
        });

        function getStorageKey() {
            var wrapper = document.getElementById('globalNotifWrapper');
            var userId = wrapper ? wrapper.getAttribute('data-user-id') : '0';
            return 'codercept_last_seen_notif_' + userId;
        }

        function syncNotificationBadge() {
            var wrapper = document.getElementById('globalNotifWrapper');
            var badge = document.getElementById('pnlNotifBadge');
            if (!wrapper || !badge) return;

            var lastSeenId = parseInt(localStorage.getItem(getStorageKey()) || '0', 10);
            var items = wrapper.querySelectorAll('.notif-item');
            var unreadCount = 0;

            items.forEach(function (item) {
                var id = parseInt(item.getAttribute('data-notif-id') || '0', 10);
                if (id > lastSeenId) {
                    unreadCount++;
                }
            });

            if (unreadCount > 0) {
                badge.textContent = unreadCount;
                badge.style.display = 'flex';
            } else {
                badge.style.display = 'none';
            }
        }

        function toggleNotifPopover(e) {
            e.stopPropagation();
            var popover = document.getElementById('notifPopover');
            var bell = document.getElementById('btnNotifBell');
            var wrapper = document.getElementById('globalNotifWrapper');
            var badge = document.getElementById('pnlNotifBadge');

            if (popover) {
                var isOpening = !popover.classList.contains('open');
                popover.classList.toggle('open');
                bell.classList.toggle('active');

                // When opened, mark the highest NotificationId as viewed and hide the red badge
                if (isOpening && wrapper) {
                    var latestId = wrapper.getAttribute('data-latest-id') || '0';
                    localStorage.setItem(getStorageKey(), latestId);
                    if (badge) {
                        badge.style.display = 'none';
                    }
                }
            }
        }

        function closeNotifPopover() {
            var popover = document.getElementById('notifPopover');
            var bell = document.getElementById('btnNotifBell');
            if (popover) {
                popover.classList.remove('open');
                bell.classList.remove('active');
            }
        }

        document.addEventListener('click', function (e) {
            var wrapper = document.getElementById('globalNotifWrapper');
            if (wrapper && !wrapper.contains(e.target)) {
                closeNotifPopover();
            }
        });
    </script>
</asp:PlaceHolder>