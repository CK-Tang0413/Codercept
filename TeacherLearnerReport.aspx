<%@ Page Title="Course Report - Codercept" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="TeacherLearnerReport.aspx.cs" Inherits="Codercept.TeacherLearnerReport" %>
<%@ MasterType VirtualPath="~/TeacherSite.master" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <div class="report-workspace">
        <div class="report-page-heading">
            <div>
                <span class="eyebrow">COURSE REPORT</span>
                <h1><%: Learner.Name %> - <%: CourseTitle %></h1>
                <p>Preview, print, or save the learner's course progress report.</p>
            </div>
            <div class="report-toolbar">
                <asp:LinkButton ID="btnTeacherSaveReportPdf" runat="server" CssClass="button button--primary" OnClick="btnTeacherSaveReportPdf_Click"><svg aria-hidden="true" class="icon" fill="none" height="17" viewBox="0 0 24 24" width="17"><path d='M12 3v12m-5-5 5 5 5-5M5 21h14' /></svg><span>Save as PDF</span></asp:LinkButton>
                <button type="button" class="button button--secondary" data-tp-print><%= TeacherIcons.Svg("print", 17) %><span>Print report</span></button>
                <a class="button button--ghost" href="TeacherLearnerReportPdf.ashx?learner=<%= LearnerId %>" target="_blank" rel="noopener"><%= TeacherIcons.Svg("external", 17) %><span>Open in new window</span></a>
                <a class="button button--ghost" href="TeacherLearners.aspx"><span>Go back</span></a>
            </div>
        </div>

        <div class="report-preview-canvas" data-tp-zoom>
            <div class="zoom-control">
                <button type="button" aria-label="Zoom out" data-tp-zoom-out>&minus;</button>
                <strong data-tp-zoom-label>100%</strong>
                <button type="button" aria-label="Zoom in" data-tp-zoom-in>+</button>
            </div>
            <div class="report-paper-wrap zoom-100" data-tp-zoom-wrap>
                <article class="report-paper">
                    <header class="report-header">
                        <div class="report-brand">
                            <img class="report-logo" src="img/Codercept_Icon.png" alt="Codercept" />
                            <div>
                                <strong>Codercept</strong>
                                <small>Programming Education Platform</small>
                            </div>
                        </div>
                        <div class="report-meta">
                            <strong>COURSE PROGRESS REPORT</strong>
                            <span>Report ID &middot; CR-2024-0528</span>
                            <span>Generated &middot; 28 May 2024</span>
                        </div>
                    </header>

                    <section class="report-title-block">
                        <span>LEARNER PERFORMANCE</span>
                        <h1><%: Learner.Name %></h1>
                        <p><%: CourseTitle %></p>
                    </section>

                    <section class="report-section">
                        <h2>Learner details</h2>
                        <div class="report-details-grid">
                            <div><span>Email address</span><strong><%: Learner.Email %></strong></div>
                            <div><span>Student level</span><strong><%: Learner.Level %></strong></div>
                            <div><span>Enrolled on</span><strong><%: Learner.Enrolled %></strong></div>
                            <div><span>Last accessed</span><strong><%: Learner.Accessed %></strong></div>
                        </div>
                    </section>

                    <section class="report-section">
                        <h2>Progress summary</h2>
                        <div class="report-summary-grid">
                            <div>
                                <span>Course progress</span>
                                <strong><%= Learner.Progress %>%</strong>
                                <div class="report-progress"><i style="width: <%= Learner.Progress %>%"></i></div>
                            </div>
                            <div><span>Quizzes completed</span><strong><%: Learner.Quizzes %></strong></div>
                            <div><span>Overall average</span><strong><%: Learner.Average %></strong></div>
                            <div><span>Current grade</span><strong class="report-grade"><%: Learner.Grade %></strong></div>
                        </div>
                    </section>

                    <section class="report-section report-results">
                        <div>
                            <h2>Assessment results</h2>
                            <table>
                                <thead>
                                    <tr><th>Assessment</th><th>Score</th><th>Grade</th></tr>
                                </thead>
                                <tbody>
                                    <asp:Repeater ID="rptTeacherReportScores" runat="server">
                                        <ItemTemplate>
                                            <tr>
                                                <td><%# Eval("Item") %></td>
                                                <td><%# Eval("Score") %></td>
                                                <td><span><%# Eval("Grade") %></span></td>
                                            </tr>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </tbody>
                            </table>
                        </div>
                        <div>
                            <h2>Score overview</h2>
                            <div class="report-chart">
                                <% int[] bars = { 72, 80, 76, 88, 86 }; for (int i = 0; i < bars.Length; i++) { %>
                                <div><span><%= bars[i] %></span><i style="height: <%= bars[i] %>%"></i><small>Q<%= i + 1 %></small></div>
                                <% } %>
                            </div>
                            <p>Scores show consistent improvement across course assessments.</p>
                        </div>
                    </section>

                    <footer class="report-footer">
                        <div>
                            <span class="signature-line"><%: Master.UserName %></span>
                            <strong>Instructor signature</strong>
                            <small>Codercept Teacher Portal</small>
                        </div>
                        <div>
                            <span class="signature-line">28 May 2024</span>
                            <strong>Date issued</strong>
                            <small>Verified digital report</small>
                        </div>
                        <span class="report-footer-mark">&lt;/&gt;</span>
                    </footer>
                </article>
            </div>
        </div>
    </div>
</asp:Content>
