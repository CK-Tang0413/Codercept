<%@ Page Title="Manage Exams - Codercept" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="TeacherExams.aspx.cs" Inherits="Codercept.TeacherExams" %>
<%@ MasterType VirtualPath="~/TeacherSite.master" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <div class="exam-select-heading">
        <span class="exam-heading-icon"><%= TeacherIcons.Svg("exams", 23) %></span>
        <span class="eyebrow">MANAGE COURSE EXAMS</span>
        <h1>Select a course to manage an exam</h1>
        <p>Choose a course to configure exam rules, questions, and answer keys.</p>
    </div>

    <%-- Search / filter / grid-list / pagination: client-side (data-tp-cl-*) over the rendered cards --%>
    <section class="exam-selector-panel" data-tp-cardlist data-tp-page-size="3" data-tp-grid-class="exam-course-grid">
        <div class="selector-toolbar">
            <label class="input-wrap">
                <span class="sr-only">Search courses</span>
                <%= TeacherIcons.Svg("search", 18) %>
                <input aria-label="Search courses" placeholder="Search courses..." type="search" data-tp-cl-search />
            </label>
            <div class="selector-actions">
                <div class="filter-wrap">
                    <button type="button" class="button button--ghost" data-tp-cl-filter-toggle><%= TeacherIcons.Svg("filter", 17) %><span>Filter</span></button>
                    <div class="filter-popover exam-filter-popover" data-tp-cl-filter hidden>
                        <div class="filter-popover-heading">
                            <strong>Exam status</strong>
                            <button type="button" class="clear-filter" data-tp-cl-clear>Clear</button>
                        </div>
                        <button type="button" class="exam-filter-option is-active" data-tp-cl-opt="All"><span>All</span><span data-tp-cl-check><%= TeacherIcons.Svg("check", 14) %></span></button>
                        <button type="button" class="exam-filter-option" data-tp-cl-opt="Exam configured"><span>Exam configured</span><span data-tp-cl-check hidden><%= TeacherIcons.Svg("check", 14) %></span></button>
                        <button type="button" class="exam-filter-option" data-tp-cl-opt="No exam yet"><span>No exam yet</span><span data-tp-cl-check hidden><%= TeacherIcons.Svg("check", 14) %></span></button>
                    </div>
                </div>
                <div class="view-toggle" aria-label="Course view">
                    <button type="button" aria-label="Grid view" class="is-active" data-tp-cl-view="grid"><%= TeacherIcons.Svg("grid", 17) %></button>
                    <button type="button" aria-label="List view" data-tp-cl-view="list"><%= TeacherIcons.Svg("list", 18) %></button>
                </div>
            </div>
        </div>

        <div class="exam-course-grid exam-course-grid--grid" data-tp-cl-grid>
            <% for (int i = 0; i < Courses.Count; i++) { TeacherCourse c = Courses[i]; bool configured = TeacherSampleData.HasExam(c.Id); %>
            <article class="exam-course-card" data-tp-cl-item data-title="<%: c.Title %>" data-status="<%= configured ? "Exam configured" : "No exam yet" %>">
                <div class="course-thumbnail course-thumbnail--<%= c.Theme %> exam-course-thumbnail">
                    <span><%: c.Glyph %></span>
                    <i class="code-symbol code-symbol--one">{ }</i>
                    <div class="exam-card-overlay">
                        <a class="button button--white" href="TeacherExamEdit.aspx?course=<%= c.Id %>"><%= TeacherIcons.Svg("edit", 17) %><span>Edit exam</span></a>
                    </div>
                </div>
                <div class="exam-course-content">
                    <div class="exam-card-title">
                        <h3><%: c.Title %></h3>
                        <span class="exam-status <%= configured ? "is-configured" : "is-empty" %>"><i></i><%= configured ? "Exam configured" : "No exam yet" %></span>
                    </div>
                    <div class="select-course-footer">
                        <span><%= TeacherIcons.Svg("calendar", 14) %><%: c.Date %></span>
                        <span><%= TeacherIcons.Svg("clock", 14) %><%: c.Duration %> hours</span>
                    </div>
                </div>
            </article>
            <% } %>
        </div>

        <div class="empty-state" data-tp-cl-empty hidden>
            <span class="empty-icon"><%= TeacherIcons.Svg("search", 20) %></span>
            <h3>No courses found</h3>
            <p>Try a different search or exam status.</p>
        </div>

        <div class="selector-pagination exam-pagination">
            <button type="button" aria-label="Previous courses" data-tp-cl-prev><%= TeacherIcons.Svg("chevron", 17) %></button>
            <span data-tp-cl-count><strong>1</strong> of 1</span>
            <button type="button" aria-label="Next courses" data-tp-cl-next><%= TeacherIcons.Svg("chevron", 17) %></button>
        </div>
    </section>
</asp:Content>
