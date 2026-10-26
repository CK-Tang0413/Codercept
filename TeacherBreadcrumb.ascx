<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TeacherBreadcrumb.ascx.cs" Inherits="Codercept.TeacherBreadcrumb" %>
<div class="breadcrumb-banner">
    <span class="breadcrumb-home"><%= TeacherIcons.Svg("courses", 17) %></span>
    <div>
        <span><%: CourseTitle %></span>
        <%= TeacherIcons.Svg("chevron", 13) %>
        <strong><%: ChapterTitle %></strong>
    </div>
</div>
