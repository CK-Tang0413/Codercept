<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TASideBar.ascx.cs" Inherits="Codercept.TASideBar" %>

<aside class="sidebar" id="tpSidebar" data-tp-sidebar>
    <div class="tp-brand-row">
        <a href="TADashboard.aspx" class="brand">
            <img id="imgBrandLogo" src="~/img/Codercept_Icon.png" alt="Codercept" runat="server" />
            <span class="tp-brand-text">Codercept</span>
        </a>
        <button type="button" class="icon-button sidebar-close" aria-label="Close menu" data-tp-close-menu>
            <%= TeacherIcons.Svg("close", 20) %>
        </button>
    </div>

    <nav class="nav-menu" aria-label="Teaching Assistant portal">
        <span class="tp-nav-label">TEACHING ASSISTANT</span>
        <a href="TADashboard.aspx" class="nav-item <%= GetActiveCssClass("TADashboard") %>" aria-label="Dashboard">
            <%= TeacherIcons.Svg("dashboard", 19) %><span>Dashboard</span>
        </a>
        <a href="TAGrading.aspx" class="nav-item <%= GetActiveCssClass("TAGrading") %>" aria-label="Provisional Grading">
            <%= TeacherIcons.Svg("grade", 19) %><span>Provisional Grading</span>
        </a>
        <a href="TAForumModeration.aspx" class="nav-item <%= GetActiveCssClass("TAForumModeration") %>" aria-label="Forum">
            <%= TeacherIcons.Svg("forum", 19) %><span>Forum</span>
        </a>
        <a href="TACourses.aspx" class="nav-item <%= GetActiveCssClass("TACourses") %><%= GetActiveCssClass("TACourseView") %>" aria-label="Courses">
            <%= TeacherIcons.Svg("courses", 19) %><span>Courses</span>
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
        <asp:LinkButton ID="lnkSignOut" runat="server" CssClass="sign-out" OnClick="lnkSignOut_Click">
            Sign out
        </asp:LinkButton>
    </div>
</aside>
