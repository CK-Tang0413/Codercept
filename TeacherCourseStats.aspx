<%@ Page Title="Course Statistics - Codercept" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="TeacherCourseStats.aspx.cs" Inherits="Codercept.TeacherCourseStats" MaintainScrollPositionOnPostBack="true" %>
<%@ MasterType VirtualPath="~/TeacherSite.master" %>
<%@ Register Src="~/TeacherCourseSelector.ascx" TagPrefix="uc" TagName="CourseSelector" %>
<%@ Register Src="~/TeacherStepHeading.ascx" TagPrefix="uc" TagName="StepHeading" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <a class="back-link" href="TeacherCourses.aspx"><%= TeacherIcons.Svg("arrow", 16) %>Back to Manage Courses</a>
    <div class="page-heading course-page-heading">
        <div>
            <span class="eyebrow">COURSE ANALYTICS</span>
            <h1>View Course &amp; Performance Statistics</h1>
            <p>Review course engagement and learner grade performance.</p>
        </div>
    </div>

    <section class="flow-section">
        <uc:StepHeading runat="server" Step="1" Title="Select a course" Subtitle="Choose the course you want to analyse." />
        <uc:CourseSelector ID="selTeacherCourse" runat="server" Compact="true" />
    </section>

    <section class="flow-section" data-tp-region="details">
        <uc:StepHeading ID="shTeacherResults" runat="server" Step="2" Title="View / Download statistics" />
        <div class="statistics-layout">
            <article class="detail-card statistics-card">
                <div class="card-heading simple">
                    <div>
                        <span>Engagement overview</span>
                        <h3>Course Statistics</h3>
                    </div>
                    <span class="card-heading-icon"><%= TeacherIcons.Svg("chart", 19) %></span>
                </div>
                <div class="statistics-row-list">
                    <asp:Repeater ID="rptTeacherCourseStats" runat="server">
                        <ItemTemplate>
                            <div class="detail-item">
                                <span class="detail-item-icon"><%# TeacherIcons.Svg((string)Eval("Icon"), 17) %></span>
                                <div><span><%# Eval("Label") %></span><strong><%# Eval("Value") %></strong></div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <div class="completion-block">
                    <div class="completion-copy">
                        <span>Completion rate</span>
                        <strong>74%</strong>
                    </div>
                    <div class="progress-track"><span></span></div>
                </div>
                <asp:LinkButton ID="btnTeacherSaveCourseStatsPdf" runat="server" CssClass="button button--secondary download-button" OnClick="btnTeacherSaveCourseStatsPdf_Click"><svg aria-hidden="true" class="icon" fill="none" height="17" viewBox="0 0 24 24" width="17"><path d='M12 3v12m-5-5 5 5 5-5M5 21h14' /></svg><span>Save course statistics as PDF</span></asp:LinkButton>
            </article>

            <article class="detail-card statistics-card performance-card">
                <div class="card-heading simple">
                    <div>
                        <span>Assessment results</span>
                        <h3>Performance Statistics</h3>
                    </div>
                    <span class="badge badge--success">84 graded</span>
                </div>
                <div class="metric-grid">
                    <asp:Repeater ID="rptTeacherMetrics" runat="server">
                        <ItemTemplate>
                            <div class="metric-tile"><span><%# Eval("Label") %></span><strong><%# Eval("Value") %></strong></div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <div class="chart-heading">
                    <div>
                        <h3>Grade distribution</h3>
                        <p>Number of learners by final grade</p>
                    </div>
                </div>
                <div class="grade-chart">
                    <asp:Repeater ID="rptTeacherGradeBars" runat="server">
                        <ItemTemplate>
                            <div class="grade-column">
                                <span><%# Eval("Count") %></span>
                                <div class="bar-track"><i class="bar bar--<%# ((string)Eval("Grade")).ToLower() %>" style="height: <%# Eval("Value") %>%"></i></div>
                                <strong><%# Eval("Grade") %></strong>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <div class="grade-legend">
                    <asp:Repeater ID="rptTeacherGradeLegend" runat="server">
                        <ItemTemplate>
                            <span><i class="legend-dot legend-dot--<%# ((string)Eval("Grade")).ToLower() %>"></i>Total grade <%# Eval("Grade") %><strong><%# Eval("Count") %></strong></span>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <asp:LinkButton ID="btnTeacherSavePerformanceStatsPdf" runat="server" CssClass="button button--secondary download-button" OnClick="btnTeacherSavePerformanceStatsPdf_Click"><svg aria-hidden="true" class="icon" fill="none" height="17" viewBox="0 0 24 24" width="17"><path d='M12 3v12m-5-5 5 5 5-5M5 21h14' /></svg><span>Save performance statistics as PDF</span></asp:LinkButton>
            </article>
        </div>
    </section>
</asp:Content>
