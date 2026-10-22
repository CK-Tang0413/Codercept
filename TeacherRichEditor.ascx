<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TeacherRichEditor.ascx.cs" Inherits="Codercept.TeacherRichEditor" %>
<%-- Prototype editor: the toolbar is decorative (plain textarea underneath), as in the Figma prototype. --%>
<div class="rich-editor">
    <div class="editor-toolbar" aria-label="Text formatting">
        <button type="button" aria-label="bold"><%= TeacherIcons.Svg("bold", 15) %></button>
        <button type="button" aria-label="italic"><%= TeacherIcons.Svg("italic", 15) %></button>
        <button type="button" aria-label="code"><%= TeacherIcons.Svg("code", 15) %></button>
        <button type="button" aria-label="link"><%= TeacherIcons.Svg("link", 15) %></button>
        <button type="button" aria-label="list"><%= TeacherIcons.Svg("list", 15) %></button>
    </div>
    <asp:TextBox ID="txtTeacherRichText" runat="server" TextMode="MultiLine" Rows="7" aria-label="Description"></asp:TextBox>
</div>
