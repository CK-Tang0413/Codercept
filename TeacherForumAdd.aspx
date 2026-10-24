<%@ Page Title="Create New Post - Codercept" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="TeacherForumAdd.aspx.cs" Inherits="Codercept.TeacherForumAdd" %>
<%@ MasterType VirtualPath="~/TeacherSite.master" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <div class="forum-form-screen">
        <div class="forum-subpage-heading">
            <a href="TeacherForum.aspx" aria-label="Back to Forum"><%= TeacherIcons.Svg("arrow", 19) %></a>
            <div>
                <h1>Create New Post</h1>
                <p>Ask a question or share your knowledge with the community</p>
            </div>
        </div>

        <div class="forum-form-card">
            <div class="forum-form-fields">
                <label id="fldTeacherPostTitle" runat="server" class="portal-form-field">
                    <span>Title</span>
                    <asp:TextBox ID="txtTeacherPostTitle" runat="server" ValidateRequestMode="Disabled" MaxLength="150"></asp:TextBox>
                    <small id="hintTeacherPostTitle" runat="server"></small>
                </label>

                <label id="fldTeacherPostDescription" runat="server" class="portal-form-field post-description-field">
                    <span>Description</span>
                    <asp:TextBox ID="txtTeacherPostDescription" runat="server" ValidateRequestMode="Disabled" TextMode="MultiLine" Rows="8"></asp:TextBox>
                    <small id="hintTeacherPostDescription" runat="server"></small>
                </label>

                <label class="portal-form-field">
                    <span>Tags</span>
                    <asp:TextBox ID="txtTeacherPostTags" runat="server" ValidateRequestMode="Disabled" data-tp-tag-source></asp:TextBox>
                    <small>Separate tags with commas. Hashtags will be added automatically.</small>
                </label>
                <div class="tag-preview" aria-label="Tag preview" data-tp-tag-preview></div>
            </div>

            <div class="forum-form-actions">
                <a class="button button--ghost" href="TeacherForum.aspx"><span>Cancel</span></a>
                <asp:LinkButton ID="btnTeacherPublishPost" runat="server" CssClass="button button--primary" OnClick="btnTeacherPublishPost_Click"><span>Publish Post</span></asp:LinkButton>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="ContentModals" ContentPlaceHolderID="cphModals" runat="server">
</asp:Content>
