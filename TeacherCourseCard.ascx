<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TeacherCourseCard.ascx.cs" Inherits="Codercept.TeacherCourseCard" %>
<article class="course-card">
    <div class="course-thumbnail course-thumbnail--<%= Course.Theme %>">
        <span><%: Course.Glyph %></span>
        <i class="code-symbol code-symbol--one">{ }</i>
        <i class="code-symbol code-symbol--two">01</i>
    </div>
    <div class="course-content">
        <h3><%: Course.Title %></h3>
        <div class="course-meta">
            <span><%= TeacherIcons.Svg("clock", 15) %>Created <%: Course.Date %></span>
            <span><%= TeacherIcons.Svg("users", 15) %><%: Course.Learners %></span>
        </div>
        <div class="course-actions">
            <a class="button button--secondary" href="TeacherCourses.aspx?course=<%: Course.Id %>"><%= TeacherIcons.Svg("edit", 17) %><span>Edit course</span></a>
            <a class="button button--ghost" href="TeacherLearners.aspx?course=<%: Course.Id %>"><%= TeacherIcons.Svg("users", 17) %><span>View learners</span></a>
        </div>
    </div>
</article>
