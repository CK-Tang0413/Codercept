<%@ Page Title="Dashboard - Codercept" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="TeacherDashboard.aspx.cs" Inherits="Codercept.TeacherDashboard" %>
<%@ MasterType VirtualPath="~/TeacherSite.master" %>
<%@ Register Src="~/TeacherStatCard.ascx" TagPrefix="uc" TagName="StatCard" %>
<%@ Register Src="~/TeacherCourseCard.ascx" TagPrefix="uc" TagName="CourseCard" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <div class="page-heading">
        <div>
            <span class="eyebrow">OVERVIEW</span>
            <h1>Dashboard</h1>
        </div>
        <label class="input-wrap">
            <span class="sr-only">Search dashboard</span>
            <%= TeacherIcons.Svg("search", 18) %>
            <input aria-label="Search dashboard" placeholder="Search..." type="search" />
        </label>
    </div>

    <section class="welcome-banner">
        <div class="welcome-pattern" aria-hidden="true">
            <span>&lt;/&gt;</span>
            <span>{ }</span>
            <span>01</span>
        </div>
        <div class="welcome-copy">
            <span class="badge badge--indigo">Teacher workspace</span>
            <h2>Let's get education started, <asp:Literal ID="litTeacherFirstName" runat="server" Text="Bryan"></asp:Literal>!</h2>
            <p>Your learners are making progress. Keep the momentum going with your next lesson.</p>
        </div>
        <div class="welcome-actions">
            <a class="button button--white" href="TeacherCourseCreate.aspx"><%= TeacherIcons.Svg("plus", 17) %><span>Create course</span></a>
            <a class="button button--secondary" href="TeacherGrading.aspx"><%= TeacherIcons.Svg("grade", 17) %><span>Grade assessments</span></a>
        </div>
    </section>

    <section aria-labelledby="statistics-heading">
        <h2 class="sr-only" id="statistics-heading">Dashboard statistics</h2>
        <div class="stats-grid">
            <asp:Repeater ID="rptTeacherStats" runat="server">
                <ItemTemplate>
                    <uc:StatCard runat="server" Label='<%# Eval("Label") %>' Value='<%# Eval("Value") %>' Hint='<%# Eval("Hint") %>' Icon='<%# Eval("Icon") %>' Tone='<%# Eval("Tone") %>' Badge='<%# Eval("Badge") %>' />
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </section>

    <section class="dashboard-section" aria-labelledby="activities-heading">
        <div class="section-heading">
            <div>
                <h2 id="activities-heading">Recent Activities by Learners</h2>
                <p>Latest course and assessment updates from your learners.</p>
            </div>
        </div>
        <div class="panel">
            <div class="activity-list">
                <asp:Repeater ID="rptTeacherActivities" runat="server">
                    <ItemTemplate>
                        <article class="activity-row">
                            <time class="activity-time"><%# Eval("Time") %></time>
                            <div class="timeline-dot timeline-dot--<%# Eval("Type") %>"></div>
                            <span class="avatar avatar--<%# Eval("Tone") %> avatar--sm" aria-hidden="true"><%# Eval("Initials") %></span>
                            <div class="activity-copy">
                                <p><strong><%# Server.HtmlEncode((string)Eval("Name")) %></strong> <%# Eval("Action") %> answers for</p>
                                <span><%# Server.HtmlEncode((string)Eval("Detail")) %></span>
                            </div>
                            <%-- TODO (backend): link to the specific submission --%>
                            <a id="lnkTeacherMarkAnswers" runat="server" class="button button--primary" href="~/TeacherGradeAssessments.aspx" visible='<%# (bool)Eval("HasButton") %>'><%= TeacherIcons.Svg("check", 17) %><span>Mark answers</span></a>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>

    <section class="dashboard-section" aria-labelledby="courses-heading">
        <div class="section-heading section-heading--row">
            <div>
                <h2 id="courses-heading">Recently Created Courses</h2>
                <p>Jump back into your latest course content.</p>
            </div>
            <a class="text-link" href="TeacherCourses.aspx">View more <%= TeacherIcons.Svg("arrow", 16) %></a>
        </div>
        <div class="course-grid">
            <asp:Repeater ID="rptTeacherRecentCourses" runat="server">
                <ItemTemplate>
                    <uc:CourseCard runat="server" Course='<%# Container.DataItem %>' />
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </section>
</asp:Content>
