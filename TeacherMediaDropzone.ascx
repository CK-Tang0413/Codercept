<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TeacherMediaDropzone.ascx.cs" Inherits="Codercept.TeacherMediaDropzone" %>
<%-- Dropzone button; clicking it (or dropping a file on it) fills the hidden file input below. --%>
<div data-tp-dropzone>
    <button type="button" class="media-dropzone<%= Compact ? " is-compact" : "" %>" data-tp-dropzone-btn>
        <span class="upload-icon"><%= TeacherIcons.Svg("upload", 21) %></span>
        <span>
            <strong data-tp-dropzone-title><%= Compact ? "Add file" : "Drag &amp; drop or browse" %></strong>
            <small>Images, video, PDF or code files up to 25 MB</small>
        </span>
    </button>
    <asp:FileUpload ID="fuTeacherMedia" runat="server" style="display: none" data-tp-dropzone-input />
</div>
