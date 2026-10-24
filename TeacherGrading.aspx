<%@ Page Title="Grade Assessments - Codercept" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="TeacherGrading.aspx.cs" Inherits="Codercept.TeacherGrading" %>
<%@ MasterType VirtualPath="~/TeacherSite.master" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <div class="exam-select-heading">
        <span class="exam-heading-icon grading-heading-icon"><%= TeacherIcons.Svg("grade", 23) %></span>
        <span class="eyebrow">GRADE ASSESSMENTS</span>
        <h1>Select a course</h1>
        <p>Choose a course to review and grade pending learner submissions.</p>
    </div>

    <%-- Search / filter / grid-list / pagination: client-side (data-tp-cl-*) over the rendered cards --%>
    <section class="exam-selector-panel" data-tp-cardlist data-tp-cl-toggle data-tp-page-size="3" data-tp-grid-class="grading-course-grid">
        <div class="selector-toolbar">
            <label class="input-wrap">
                <span class="sr-only">Search courses</span>
                <%= TeacherIcons.Svg("search", 18) %>
                <input aria-label="Search courses" placeholder="Search courses..." type="search" data-tp-cl-search />
            </label>
            <div class="selector-actions">
                <div class="filter-wrap">
                    <button type="button" class="button button--ghost" data-tp-cl-filter-toggle><%= TeacherIcons.Svg("filter", 17) %><span>Filter</span></button>
                    <div class="filter-popover grading-filter-popover" data-tp-cl-filter hidden>
                        <div class="filter-popover-heading">
                            <strong>Submission status</strong>
                            <button type="button" class="clear-filter" data-tp-cl-clear>Clear</button>
                        </div>
                        <button type="button" class="exam-filter-option" data-tp-cl-opt="Pending"><span>Pending submissions only</span><span data-tp-cl-check hidden><%= TeacherIcons.Svg("check", 14) %></span></button>
                    </div>
                </div>
                <div class="view-toggle" aria-label="Course view">
                    <button type="button" aria-label="Grid view" class="is-active" data-tp-cl-view="grid"><%= TeacherIcons.Svg("grid", 17) %></button>
                    <button type="button" aria-label="List view" data-tp-cl-view="list"><%= TeacherIcons.Svg("list", 18) %></button>
                </div>
            </div>
        </div>

        <div class="grading-course-grid grading-course-grid--grid" data-tp-cl-grid>
            <% for (int i = 0; i < Courses.Count; i++) { TeacherCourse c = Courses[i]; int pending = PendingOf(c.Id); %>
            <a class="grading-course-card" href="TeacherGradeAssessments.aspx?course=<%= c.Id %>" data-tp-cl-item data-title="<%: c.Title %>" data-status="<%= pending > 0 ? "Pending" : "None" %>">
                <div class="course-thumbnail course-thumbnail--<%= c.Theme %> grading-course-thumbnail">
                    <span><%: c.Glyph %></span>
                    <i class="code-symbol code-symbol--one">{ }</i>
                    <span class="pending-floating-badge"><%= pending %> pending submissions</span>
                </div>
                <div class="grading-course-content">
                    <h3><%: c.Title %></h3>
                    <div class="select-course-footer">
                        <span class="badge badge--warning"><%= pending %> pending</span>
                        <span><%= TeacherIcons.Svg("arrow", 14) %>Start grading</span>
                    </div>
                </div>
            </a>
            <% } %>
        </div>

        <div class="empty-state" data-tp-cl-empty hidden>
            <span class="empty-icon"><%= TeacherIcons.Svg("search", 20) %></span>
            <h3>No courses found</h3>
            <p>Try a different search or clear the current filter.</p>
        </div>

        <div class="selector-pagination">
            <button type="button" aria-label="Previous courses" data-tp-cl-prev><%= TeacherIcons.Svg("chevron", 17) %></button>
            <span data-tp-cl-count><strong>1</strong> of 1</span>
            <button type="button" aria-label="Next courses" data-tp-cl-next><%= TeacherIcons.Svg("chevron", 17) %></button>
        </div>
    </section>
</asp:Content>
