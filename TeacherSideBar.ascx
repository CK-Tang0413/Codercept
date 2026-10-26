<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TeacherSideBar.ascx.cs" Inherits="Codercept.TeacherSideBar" %>

<!-- Same classes as LearnerSideBar.ascx (global.css); only nav items/icons/active item differ per role -->
<aside class="sidebar" id="tpSidebar" data-tp-sidebar>
    <div class="tp-brand-row">
        <a href="TeacherDashboard.aspx" class="brand">
            <img id="imgTeacherBrandLogo" src="~/img/Codercept_Icon.png" alt="Codercept" runat="server" />
            <span class="tp-brand-text">Codercept</span>
        </a>
        <button type="button" class="icon-button sidebar-close" aria-label="Close menu" data-tp-close-menu>
            <%= TeacherIcons.Svg("close", 20) %>
        </button>
    </div>

    <nav class="nav-menu" aria-label="Teacher portal">
        <span class="tp-nav-label">TEACHER PORTAL</span>
        <a href="TeacherDashboard.aspx" class="nav-item <%= GetActiveCssClass("TeacherDashboard") %>" aria-label="Dashboard"><%= TeacherIcons.Svg("dashboard", 19) %><span>Dashboard</span></a>
        <a href="TeacherCourses.aspx" class="nav-item <%= GetActiveCssClass("TeacherCourses", "TeacherCourseCreate", "TeacherCourseStats") %>" aria-label="Manage Courses"><%= TeacherIcons.Svg("courses", 19) %><span>Manage Courses</span></a>
        <a href="TeacherChapters.aspx" class="nav-item <%= GetActiveCssClass("TeacherChapters", "TeacherChapterContent", "TeacherChapterAdd") %>" aria-label="Manage Chapters"><%= TeacherIcons.Svg("chapters", 19) %><span>Manage Chapters</span></a>
        <a href="TeacherExams.aspx" class="nav-item <%= GetActiveCssClass("TeacherExams", "TeacherExamEdit") %>" aria-label="Manage Exams"><%= TeacherIcons.Svg("exams", 19) %><span>Manage Exams</span></a>
        <a href="TeacherLearners.aspx" class="nav-item <%= GetActiveCssClass("TeacherLearners", "TeacherLearnerReport") %>" aria-label="Manage Learners"><%= TeacherIcons.Svg("learners", 19) %><span>Manage Learners</span></a>
        <a href="TeacherGrading.aspx" class="nav-item <%= GetActiveCssClass("TeacherGrading", "TeacherGradeAssessments") %>" aria-label="Grade Assessments"><%= TeacherIcons.Svg("grade", 19) %><span>Grade Assessments</span></a>
        <a href="TeacherForum.aspx" class="nav-item <%= GetActiveCssClass("TeacherForum", "TeacherForumAdd", "TeacherAccount") %>" aria-label="Forum"><%= TeacherIcons.Svg("forum", 19) %><span>Forum</span></a>
    </nav>

    <div class="user-profile-section">
        <a href="TeacherAccount.aspx" class="user-info">
            <div class="avatar"><asp:Literal ID="litTeacherInitial" runat="server" Text="B"></asp:Literal></div>
            <div class="user-details">
                <h4><asp:Literal ID="litTeacherNameNav" runat="server" Text="Bryan Yeong"></asp:Literal></h4>
                <p><asp:Literal ID="litTeacherEmailNav" runat="server" Text="bryanyeong@edu.com.my"></asp:Literal></p>
            </div>
        </a>
        <asp:LinkButton ID="lnkTeacherSignOut" runat="server" CssClass="sign-out" OnClick="lnkTeacherSignOut_Click">
            Sign out
        </asp:LinkButton>
    </div>
</aside>
