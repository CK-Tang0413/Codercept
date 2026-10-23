<%@ Page Title="Manage Learners - Codercept" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="TeacherLearners.aspx.cs" Inherits="Codercept.TeacherLearners" MaintainScrollPositionOnPostBack="true" %>
<%@ MasterType VirtualPath="~/TeacherSite.master" %>
<%@ Register Src="~/TeacherCourseSelector.ascx" TagPrefix="uc" TagName="CourseSelector" %>
<%@ Register Src="~/TeacherStepHeading.ascx" TagPrefix="uc" TagName="StepHeading" %>
<%@ Register Src="~/TeacherConfirmModal.ascx" TagPrefix="uc" TagName="ConfirmModal" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <div class="page-heading course-page-heading">
        <div>
            <span class="eyebrow">LEARNER MANAGEMENT</span>
            <h1>Manage Enrolled Learners</h1>
            <p>Review enrolments, progress, dates, and learner performance.</p>
        </div>
    </div>

    <section class="flow-section">
        <uc:StepHeading runat="server" Step="1" Title="Select a course" Subtitle="Choose the course whose enrolled learners you want to review." />
        <uc:CourseSelector ID="selTeacherCourse" runat="server" />
    </section>

    <section class="flow-section" data-tp-region="details">
        <uc:StepHeading ID="shTeacherLearners" runat="server" Step="2" Title="Manage enrolled learners" />
        <input type="hidden" id="hfTeacherLearnerId" runat="server" value="" />
        <div class="learner-master-detail">
            <aside class="learner-list-panel">
                <div class="learner-list-top">
                    <div>
                        <span>ENROLLED LEARNERS</span>
                        <strong><%= Learners.Count %> learners</strong>
                    </div>
                    <asp:LinkButton ID="btnTeacherAddLearner" runat="server" CssClass="button button--primary" OnClick="btnTeacherAddLearner_Click"><svg aria-hidden="true" class="icon" fill="none" height="17" viewBox="0 0 24 24" width="17"><path d='M12 5v14M5 12h14' /></svg><span>Add learner</span></asp:LinkButton>
                </div>
                <div class="learner-search">
                    <label class="input-wrap">
                        <span class="sr-only">Search learners</span>
                        <%= TeacherIcons.Svg("search", 18) %>
                        <input aria-label="Search learners" placeholder="Search learners..." type="search" data-tp-learner-search />
                    </label>
                </div>
                <div class="learner-items">
                    <% for (int i = 0; i < Learners.Count; i++) { TeacherLearner l = Learners[i]; %>
                    <button type="submit" data-tp-partial name="tpLearnerPick" value="<%= l.Id %>" class="learner-item<%= l.Id == Learner.Id ? " is-selected" : "" %>"
                        data-tp-learner-item data-search="<%: (l.Name + " " + l.Email).ToLower() %>">
                        <span class="avatar avatar--<%= l.Tone %> avatar--sm" aria-hidden="true"><%: l.Initials %></span>
                        <span>
                            <strong><%: l.Name %></strong>
                            <small><%: l.Email %></small>
                        </span>
                        <%= TeacherIcons.Svg("chevron", 15) %>
                    </button>
                    <% } %>
                </div>
            </aside>

            <div class="learner-profile-layout">
                <article class="learner-profile-card">
                    <div class="learner-profile-heading">
                        <span class="avatar avatar--<%= Learner.Tone %> avatar--lg" aria-hidden="true"><%: Learner.Initials %></span>
                        <div>
                            <span>LEARNER PROFILE</span>
                            <h2><%: Learner.Name %></h2>
                            <p><%: Learner.Email %></p>
                        </div>
                        <span class="badge badge--success">Active</span>
                    </div>

                    <section class="profile-section">
                        <div class="profile-section-title">
                            <span class="profile-section-icon"><%= TeacherIcons.Svg("users", 16) %></span>
                            <h3>Demographic info</h3>
                        </div>
                        <div class="demographic-grid">
                            <div><span>Age</span><strong><%: Learner.Age %></strong></div>
                            <div><span>Gender</span><strong><%: Learner.Gender %></strong></div>
                            <div><span>Level</span><strong><%: Learner.Level %></strong></div>
                        </div>
                    </section>

                    <section class="profile-section">
                        <div class="profile-section-title">
                            <span class="profile-section-icon is-teal"><%= TeacherIcons.Svg("trend", 16) %></span>
                            <h3>Course progress</h3>
                        </div>
                        <div class="learner-progress-block">
                            <div class="completion-copy">
                                <span>Current chapter &middot; <%: Learner.Chapter %></span>
                                <strong><%= Learner.Progress %>%</strong>
                            </div>
                            <div class="learner-progress-track"><span style="width: <%= Learner.Progress %>%"></span></div>
                        </div>
                        <div class="learner-info-list">
                            <%= InfoRow("question", "Quizzes completed", Learner.Quizzes, false) %>
                            <%= InfoRow("exams", "Exam completed on", Learner.ExamDate, false) %>
                        </div>
                    </section>

                    <section class="profile-section profile-split">
                        <div>
                            <div class="profile-section-title">
                                <span class="profile-section-icon is-amber"><%= TeacherIcons.Svg("calendar", 16) %></span>
                                <h3>Progress dates</h3>
                            </div>
                            <div class="learner-info-list">
                                <%= InfoRow("plus", "Enrolled", Learner.Enrolled, false) %>
                                <%= InfoRow("clock", "Last accessed", Learner.Accessed, false) %>
                                <%= InfoRow("check", "Completed", Learner.Completed, false) %>
                            </div>
                        </div>
                        <div>
                            <div class="profile-section-title">
                                <span class="profile-section-icon is-rose"><%= TeacherIcons.Svg("award", 16) %></span>
                                <h3>Performance</h3>
                            </div>
                            <div class="learner-info-list">
                                <%= InfoRow("exams", "Exam score", Learner.Score, false) %>
                                <%= InfoRow("award", "Grade", Learner.Grade, true) %>
                                <%= InfoRow("chart", "Average", Learner.Average, false) %>
                            </div>
                        </div>
                    </section>
                </article>

                <aside class="learner-actions">
                    <span>ACTIONS</span>
                    <%-- TODO (backend): pass course and learner ids to the grading page --%>
                    <a class="button button--primary" href="TeacherGradeAssessments.aspx"><%= TeacherIcons.Svg("grade", 17) %><span>Grade quiz/exam</span></a>
                    <a class="button button--secondary" href="TeacherLearnerReport.aspx?learner=<%= Learner.Id %>"><%= TeacherIcons.Svg("download", 17) %><span>Download report</span></a>
                    <div></div>
                    <button type="button" class="button button--danger" data-tp-open-modal="tpRemoveLearnerModal"><%= TeacherIcons.Svg("trash", 17) %><span>Remove learner</span></button>
                </aside>
            </div>
        </div>
    </section>
</asp:Content>

<asp:Content ID="ContentModals" ContentPlaceHolderID="cphModals" runat="server">
    <uc:ConfirmModal ID="mdlTeacherRemoveLearner" runat="server" ModalId="tpRemoveLearnerModal" TitleText="Remove learner?" IconName="users" ConfirmText="Remove learner" OnConfirmed="mdlTeacherRemoveLearner_Confirmed" />
</asp:Content>
