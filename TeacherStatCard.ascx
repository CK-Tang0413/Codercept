<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TeacherStatCard.ascx.cs" Inherits="Codercept.TeacherStatCard" %>
<article class="stat-card">
    <div class="stat-icon stat-icon--<%= Tone %>"><%= TeacherIcons.Svg(Icon, 20) %></div>
    <div class="stat-topline">
        <span class="stat-label"><%: Label %></span>
        <% if (!string.IsNullOrEmpty(Badge)) { %><span class="badge badge--warning"><%: Badge %></span><% } %>
    </div>
    <strong class="stat-value"><%: Value %></strong>
    <span class="stat-hint <%= Tone == "teal" ? "is-positive" : "" %>"><% if (Tone == "teal") { %><%= TeacherIcons.Svg("trend", 14) %><% } %><%: Hint %></span>
</article>
