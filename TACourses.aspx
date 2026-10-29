<%@ Page Title="Courses - Codercept" Language="C#" AutoEventWireup="true" CodeBehind="TACourses.aspx.cs" Inherits="Codercept.TACourses" MasterPageFile="~/TASite.master" %>
<%@ MasterType VirtualPath="~/TASite.master" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <div class="exam-select-heading">
        <span class="exam-heading-icon grading-heading-icon"><%= TeacherIcons.Svg("courses", 23) %></span>
        <span class="eyebrow">COURSE DIRECTORY</span>
        <h1>Courses</h1>
        <p>Browse course materials, syllabus structure, and assessments to support learners.</p>
    </div>

    <section class="exam-selector-panel" data-tp-cardlist data-tp-cl-toggle data-tp-page-size="6" data-tp-grid-class="grading-course-grid">
        <div class="selector-toolbar">
            <label class="input-wrap">
                <span class="sr-only">Search courses</span>
                <%= TeacherIcons.Svg("search", 18) %>
                <input aria-label="Search courses" placeholder="Search courses by title or instructor..." type="search" data-tp-cl-search />
            </label>
            <div class="selector-actions">
                <div class="view-toggle" aria-label="Course view">
                    <button type="button" aria-label="Grid view" class="is-active" data-tp-cl-view="grid"><%= TeacherIcons.Svg("grid", 17) %></button>
                    <button type="button" aria-label="List view" data-tp-cl-view="list"><%= TeacherIcons.Svg("list", 18) %></button>
                </div>
            </div>
        </div>

        <asp:PlaceHolder ID="phNoAssigned" runat="server" Visible="false">
            <article class="chapter-detail-card" style="margin-bottom: 1.5rem;">
                <p class="summary-empty">No courses are linked to your assigned programming languages yet. Please contact the administrator or supervising teacher.</p>
            </article>
        </asp:PlaceHolder>

        <div class="grading-course-grid grading-course-grid--grid" data-tp-cl-grid>
            <asp:Repeater ID="rptCourses" runat="server">
                <ItemTemplate>
                    <a class="grading-course-card" href='TACourseView.aspx?id=<%# Eval("CourseId") %>' data-tp-cl-item data-title='<%# Eval("Title") %>'>
                        <div class="course-thumbnail course-thumbnail--<%# Eval("Theme") %> grading-course-thumbnail">
                            <span><%# Eval("Glyph") %></span>
                            <i class="code-symbol code-symbol--one">{ }</i>
                            <span class="pending-floating-badge"><%# Eval("ChapterCount") %> chapters</span>
                        </div>
                        <div class="grading-course-content">
                            <div style="display: flex; gap: 0.5rem; align-items: center; margin-bottom: 0.35rem;">
                                <span class="badge badge--secondary"><%# Eval("Level") %></span>
                                <%# (bool)Eval("IsMine") ? "<span class=\"badge badge--success\">Assigned to you</span>" : "" %>
                            </div>
                            <h3><%# Eval("Title") %></h3>
                            <p style="color: #6b7280; font-size: 0.875rem; margin-bottom: 0.75rem; line-height: 1.5;"><%# Eval("Description") %></p>
                            <div class="select-course-footer">
                                <span class="badge badge--warning">Instructor: <%# Eval("Teacher") %></span>
                                <span><%= TeacherIcons.Svg("arrow", 14) %>View syllabus</span>
                            </div>
                        </div>
                    </a>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <div class="empty-state" data-tp-cl-empty hidden>
            <span class="empty-icon"><%= TeacherIcons.Svg("search", 20) %></span>
            <h3>No courses found</h3>
            <p>Try a different search query or change scope.</p>
        </div>

        <div class="selector-pagination">
            <button type="button" aria-label="Previous courses" data-tp-cl-prev><%= TeacherIcons.Svg("chevron", 17) %></button>
            <span data-tp-cl-count><strong>1</strong> of 1</span>
            <button type="button" aria-label="Next courses" data-tp-cl-next><%= TeacherIcons.Svg("chevron", 17) %></button>
        </div>
    </section>
</asp:Content>
