<%@ Page Title="Manage Courses - Codercept" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="TeacherCourses.aspx.cs" Inherits="Codercept.TeacherCourses" MaintainScrollPositionOnPostBack="true" %>
<%@ MasterType VirtualPath="~/TeacherSite.master" %>
<%@ Register Src="~/TeacherCourseSelector.ascx" TagPrefix="uc" TagName="CourseSelector" %>
<%@ Register Src="~/TeacherStepHeading.ascx" TagPrefix="uc" TagName="StepHeading" %>
<%@ Register Src="~/TeacherConfirmModal.ascx" TagPrefix="uc" TagName="ConfirmModal" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <div class="page-heading course-page-heading">
        <div>
            <span class="eyebrow">COURSE MANAGEMENT</span>
            <h1>Manage Courses</h1>
            <p>Create, update, and monitor all your programming courses.</p>
        </div>
        <a class="button button--primary" href="TeacherCourseCreate.aspx"><%= TeacherIcons.Svg("plus", 17) %><span>Create course</span></a>
    </div>

    <section class="flow-section" aria-labelledby="select-course-heading">
        <uc:StepHeading runat="server" Step="1" Title="Select a course" Subtitle="Choose a course to view or update its information." />
        <uc:CourseSelector ID="selTeacherCourse" runat="server" />
    </section>

    <section class="flow-section" aria-labelledby="edit-course-heading">
        <uc:StepHeading runat="server" Step="2" Title="View / Edit course details" Subtitle="Review course information, learning progress, and quick actions." />
        <div class="course-detail-layout">
            <article class="detail-card course-edit-card">
                <div class="card-heading">
                    <span class="mini-language mini-language--<%= Selected.Theme %>"><%: Selected.Glyph %></span>
                    <div>
                        <span>Selected course</span>
                        <div id="fldTeacherEditTitle" runat="server" class="tp-inline-field">
                            <asp:TextBox ID="txtTeacherCourseTitle" runat="server" CssClass="tp-heading-input" autocomplete="off" aria-label="Course title"></asp:TextBox>
                            <small id="hintTeacherEditTitle" runat="server" data-ok="" data-err="Enter a title with at least 4 characters."></small>
                        </div>
                    </div>
                </div>
                <label class="form-field">
                    <span>Description</span>
                    <asp:TextBox ID="txtTeacherCourseDescription" runat="server" TextMode="MultiLine" Rows="5" autocomplete="off"></asp:TextBox>
                    <small>Give learners a clear overview of what they will learn.</small>
                </label>
                <div class="details-grid">
                    <div class="detail-item">
                        <span class="detail-item-icon"><%= TeacherIcons.Svg("code", 17) %></span>
                        <div class="tp-inline-field">
                            <span>Language</span>
                            <asp:DropDownList ID="ddlTeacherCourseLanguage" runat="server" aria-label="Programming language" autocomplete="off"></asp:DropDownList>
                        </div>
                    </div>
                    <div class="detail-item">
                        <span class="detail-item-icon"><%= TeacherIcons.Svg("award", 17) %></span>
                        <div class="tp-inline-field">
                            <span>Difficulty</span>
                            <asp:DropDownList ID="ddlTeacherCourseDifficulty" runat="server" aria-label="Difficulty" autocomplete="off">
                                <asp:ListItem>Easy</asp:ListItem>
                                <asp:ListItem>Medium</asp:ListItem>
                                <asp:ListItem>Hard</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                    <div class="detail-item">
                        <span class="detail-item-icon"><%= TeacherIcons.Svg("clock", 17) %></span>
                        <div id="fldTeacherEditDuration" runat="server" class="tp-inline-field">
                            <span>Duration (hours)</span>
                            <asp:TextBox ID="txtTeacherCourseDuration" runat="server" TextMode="Number" min="1" aria-label="Duration in hours" autocomplete="off"></asp:TextBox>
                            <small id="hintTeacherEditDuration" runat="server" data-ok="" data-err="Enter a duration greater than 0."></small>
                        </div>
                    </div>
                    <div class="detail-item">
                        <span class="detail-item-icon"><%= TeacherIcons.Svg("calendar", 17) %></span>
                        <div><span>Date Created</span><strong><%: Selected.Date %></strong></div>
                    </div>
                    <div class="detail-item">
                        <span class="detail-item-icon"><%= TeacherIcons.Svg("calendar", 17) %></span>
                        <div><span>Date Updated</span><strong><%: Selected.Updated %></strong></div>
                    </div>
                </div>
                <asp:LinkButton ID="btnTeacherUpdateCourse" runat="server" CssClass="button button--primary" OnClick="btnTeacherUpdateCourse_Click"><svg aria-hidden="true" class="icon" fill="none" height="17" viewBox="0 0 24 24" width="17"><path d='m5 12 4 4L19 6' /></svg><span>Update details</span></asp:LinkButton>
            </article>

            <article class="detail-card course-stats-card">
                <%-- TODO (backend): statistics below are sample values for the selected course --%>
                <div class="card-heading simple">
                    <div>
                        <span>Course overview</span>
                        <h3>Statistics</h3>
                    </div>
                    <span class="card-heading-icon"><%= TeacherIcons.Svg("chart", 19) %></span>
                </div>
                <div class="compact-stat-list">
                    <div class="detail-item">
                        <span class="detail-item-icon"><%= TeacherIcons.Svg("layers", 17) %></span>
                        <div><span>Total chapters</span><strong>12</strong></div>
                    </div>
                    <div class="detail-item">
                        <span class="detail-item-icon"><%= TeacherIcons.Svg("chapters", 17) %></span>
                        <div><span>Subchapters/quizzes</span><strong>38</strong></div>
                    </div>
                    <div class="detail-item">
                        <span class="detail-item-icon"><%= TeacherIcons.Svg("users", 17) %></span>
                        <div><span>Learners attended</span><strong>84</strong></div>
                    </div>
                    <div class="detail-item">
                        <span class="detail-item-icon"><%= TeacherIcons.Svg("award", 17) %></span>
                        <div><span>Learners completed</span><strong>62</strong></div>
                    </div>
                </div>
                <div class="completion-block">
                    <div class="completion-copy">
                        <span>Completion rate</span>
                        <strong>74%</strong>
                    </div>
                    <div class="progress-track"><span></span></div>
                    <p>62 of 84 learners completed this course</p>
                </div>
                <div class="stacked-actions">
                    <a class="button button--secondary" href="TeacherCourseStats.aspx"><%= TeacherIcons.Svg("chart", 17) %><span>View more statistics</span></a>
                    <a class="button button--ghost" href="TeacherLearners.aspx"><%= TeacherIcons.Svg("users", 17) %><span>View learners</span></a>
                </div>
            </article>
        </div>

        <div class="bottom-action-bar">
            <div class="action-bar-group">
                <a class="button button--secondary" href="TeacherChapters.aspx"><%= TeacherIcons.Svg("layers", 17) %><span>Manage chapters/subchapters</span></a>
                <a class="button button--secondary" href="TeacherExams.aspx"><%= TeacherIcons.Svg("exams", 17) %><span>Manage exam</span></a>
                <a class="button button--secondary" href="TeacherGrading.aspx"><%= TeacherIcons.Svg("grade", 17) %><span>Grade assessments</span></a>
            </div>
            <div class="danger-action">
                <button type="button" class="button button--danger" data-tp-open-modal="tpDeleteCourseModal"><%= TeacherIcons.Svg("trash", 17) %><span>Delete course</span></button>
            </div>
        </div>
    </section>
</asp:Content>

<asp:Content ID="ContentModals" ContentPlaceHolderID="cphModals" runat="server">
    <uc:ConfirmModal ID="mdlTeacherDeleteCourse" runat="server" ModalId="tpDeleteCourseModal" TitleText="Delete course?" ConfirmText="Delete course" OnConfirmed="mdlTeacherDeleteCourse_Confirmed" />
</asp:Content>

<asp:Content ID="ContentScripts" ContentPlaceHolderID="cphScripts" runat="server">
</asp:Content>
