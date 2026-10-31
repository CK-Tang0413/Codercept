<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="LearnerSideBar.ascx.cs" Inherits="Codercept.LearnerSideBar" %>

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
    </div>
</aside>