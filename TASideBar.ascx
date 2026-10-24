<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TASideBar.ascx.cs" Inherits="Codercept.TASideBar" %>

<%-- Top bar (phone only): hamburger + brand --%>
<div class="ta-topbar">
    <button type="button" class="ta-menu-toggle" aria-label="Open menu" aria-expanded="false" aria-controls="taSidebar">
        <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M4 6h16M4 12h16M4 18h16" /></svg>
    </button>
    <a href="TADashboard.aspx" class="ta-topbar-brand">
        <img src="<%= ResolveUrl("~/img/Codercept_Icon.png") %>" alt="" />
        Codercept
    </a>
</div>

<div class="ta-sidebar-slot" id="taSidebarSlot">
    <aside class="sidebar" id="taSidebar">
        <div class="ta-sidebar-head">
            <a href="TADashboard.aspx" class="brand">
                <img id="imgBrandLogo" src="~/img/Codercept_Icon.png" alt="Codercept" runat="server" />
                <span class="nav-label">Codercept</span>
            </a>
            <%-- Tablet: pin the rail open (overlay) --%>
            <button type="button" class="ta-menu-toggle ta-rail-toggle" aria-label="Expand menu" aria-expanded="false" aria-controls="taSidebar">
                <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M4 6h16M4 12h16M4 18h16" /></svg>
            </button>
        </div>

        <nav class="nav-menu">
            <a href="TADashboard.aspx" class="nav-item <%= GetActiveCssClass("TADashboard") %>" title="Dashboard">
                <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="9" rx="1" /><rect x="14" y="3" width="7" height="5" rx="1" /><rect x="14" y="12" width="7" height="9" rx="1" /><rect x="3" y="16" width="7" height="5" rx="1" /></svg>
                <span class="nav-label">Dashboard</span>
            </a>
            <a href="TAGrading.aspx" class="nav-item <%= GetActiveCssClass("TAGrading") %>" title="Provisional Grading">
                <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="5" y="4" width="14" height="17" rx="2" /><path d="M9 4V3h6v1M9 13l2 2 4-4" /></svg>
                <span class="nav-label">Provisional Grading</span>
            </a>
            <a href="TAForumModeration.aspx" class="nav-item <%= GetActiveCssClass("TAForumModeration") %>" title="Forum">
                <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12a8 8 0 0 1-11.5 7.2L4 20l1-4.5A8 8 0 1 1 21 12z" /></svg>
                <span class="nav-label">Forum</span>
            </a>
            <a href="TACourses.aspx" class="nav-item <%= GetActiveCssClass("TACourses") %><%= GetActiveCssClass("TACourseView") %>" title="Courses">
                <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20V3H6.5A2.5 2.5 0 0 0 4 5.5v14zM4 19.5A2.5 2.5 0 0 0 6.5 22H20v-5" /></svg>
                <span class="nav-label">Courses</span>
            </a>
        </nav>

        <div class="user-profile-section">
            <a href="TAProfile.aspx" class="user-info">
                <div class="avatar"><asp:Literal ID="litUserInitial" runat="server" Text="T"></asp:Literal></div>
                <div class="user-details">
                    <h4><asp:Literal ID="litUserNameNav" runat="server" Text="Teaching Assistant"></asp:Literal></h4>
                    <p><asp:Literal ID="litUserEmailNav" runat="server" Text=""></asp:Literal></p>
                </div>
            </a>
            <asp:LinkButton ID="lnkSignOut" runat="server" CssClass="sign-out" ToolTip="Sign out" OnClick="lnkSignOut_Click">
                <svg class="nav-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9" /></svg>
                <span class="nav-label">Sign out</span>
            </asp:LinkButton>
        </div>
    </aside>
</div>

<div class="ta-backdrop" id="taBackdrop"></div>

<script>
    (function () {
        var slot = document.getElementById('taSidebarSlot');
        var backdrop = document.getElementById('taBackdrop');
        var toggles = document.querySelectorAll('.ta-menu-toggle');
        if (!slot) return;

        function setOpen(open) {
            slot.classList.toggle('ta-open', open);
            backdrop.classList.toggle('ta-open', open);
            for (var i = 0; i < toggles.length; i++) toggles[i].setAttribute('aria-expanded', open ? 'true' : 'false');
        }

        for (var i = 0; i < toggles.length; i++) {
            toggles[i].addEventListener('click', function () { setOpen(!slot.classList.contains('ta-open')); });
        }
        backdrop.addEventListener('click', function () { setOpen(false); });
        document.addEventListener('keydown', function (e) { if (e.key === 'Escape') setOpen(false); });
    })();
</script>
