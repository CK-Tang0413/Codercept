<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AdminSidebar.ascx.cs" Inherits="Codercept.Admin_Sidebar" %>

<aside class="sidebar">
    <div class="sidebar-top">
        <div class="logo-area">
            <img class="logo-icon" src="~/img/Codercept_Icon.png" alt="Codercept" runat="server" />
            <div class="logo-text">
                <h1>Codercept</h1>
                <p>Admin Portal</p>
            </div>
        </div>
            
        <ul class="nav-menu">
            <li>
                <a class="nav-item <%= GetActiveCssClass("AdminDashboard") %>" href="AdminDashboard.aspx">
                    <i class="fa-solid fa-house"></i> Dashboard
                </a>
            </li>
            <li>
                <a class="nav-item <%= GetActiveCssClass("UserManagement") %>" href="AdminUserManagement.aspx">
                    <i class="fa-solid fa-users-gear"></i> User Management
                </a>
            </li>
            <li>
                <a class="nav-item <%= GetActiveCssClass("Community") %>" href="AdminCommunity.aspx">
                    <i class="fa-solid fa-globe"></i> Community
                </a>
            </li>
            <li>
                <a class="nav-item <%= GetActiveCssClass("Courses") %>" href="AdminCourses.aspx">
                    <i class="fa-solid fa-book-open"></i> Courses
                </a>
            </li>
            <asp:PlaceHolder ID="phLogsNav" runat="server">
                <li>
                    <a href="AdminUserLogs.aspx" class="nav-item <%= Request.Path.Contains("AdminUserLogs") ? "active" : "" %>">
                        <i class="fa-solid fa-clock-rotate-left"></i>
                        <span>Activity Logs</span>
                    </a>
                </li>
            </asp:PlaceHolder>
        </ul>
    </div>

    <div class="sidebar-bottom">
        <a href="#profile-page-placeholder" class="user-profile">
            <div class="avatar"><asp:Literal ID="litAvatarInitials" runat="server">SA</asp:Literal></div>
            <div class="user-info">
                <h4><asp:Literal ID="litSidebarUserName" runat="server">System Admin</asp:Literal></h4>
                <p><asp:Literal ID="litSidebarUserEmail" runat="server">admin@codercept.edu</asp:Literal></p>
            </div>
        </a>
            
        <asp:LinkButton ID="btnSignOut" runat="server" CssClass="sign-out-btn" style="text-decoration: none;" CausesValidation="false" OnClick="btnSignOut_Click">
            <i class="fa-solid fa-arrow-right-from-bracket"></i>
            Sign out
        </asp:LinkButton>
    </div>
</aside>

<script type="text/javascript">
    function handleSignOut() {
        var btn = document.getElementById('<%= btnSignOut.ClientID %>');
        if (btn) {
            btn.click();
        } else {
            window.location.href = 'signIn.aspx';
        }
    }
</script>
