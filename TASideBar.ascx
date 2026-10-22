<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TASideBar.ascx.cs" Inherits="Codercept.TASideBar" %>

<aside class="sidebar">
    <a href="TADashboard.aspx" class="brand">
        <img id="imgBrandLogo" src="~/img/Codercept_Icon.png" alt="Codercept" runat="server" />
        Codercept
    </a>

    <nav class="nav-menu">
        <a href="TADashboard.aspx" class="nav-item <%= GetActiveCssClass("TADashboard") %>">Dashboard</a>
        <a href="TAGrading.aspx" class="nav-item <%= GetActiveCssClass("TAGrading") %>">Grading Queue</a>
        <a href="TAForumModeration.aspx" class="nav-item <%= GetActiveCssClass("TAForumModeration") %>">Forum Moderation</a>
        <a href="TAProfile.aspx" class="nav-item <%= GetActiveCssClass("TAProfile") %>">My Profile</a>
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
