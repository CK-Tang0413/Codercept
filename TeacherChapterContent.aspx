<%@ Page Title="Manage Subchapters and Quizzes - Codercept" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="TeacherChapterContent.aspx.cs" Inherits="Codercept.TeacherChapterContent" %>
<%@ MasterType VirtualPath="~/TeacherSite.master" %>
<%@ Register Src="~/TeacherBreadcrumb.ascx" TagPrefix="uc" TagName="Breadcrumb" %>
<%@ Register Src="~/TeacherRichEditor.ascx" TagPrefix="uc" TagName="RichEditor" %>
<%@ Register Src="~/TeacherMediaDropzone.ascx" TagPrefix="uc" TagName="MediaDropzone" %>
<%@ Register Src="~/TeacherQuestionCard.ascx" TagPrefix="uc" TagName="QuestionCard" %>
<%@ Register Src="~/TeacherConfirmModal.ascx" TagPrefix="uc" TagName="ConfirmModal" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <a class="back-link" href="TeacherChapters.aspx"><%= TeacherIcons.Svg("arrow", 16) %>Back to Manage Course Chapters</a>
    <uc:Breadcrumb ID="bcTeacherChapter" runat="server" />
    <div class="page-heading course-page-heading content-page-heading">
        <div>
            <span class="eyebrow">CHAPTER CONTENT</span>
            <h1>Manage Subchapters / Quizzes</h1>
            <p>Reorder lesson content and edit learning material or quiz questions.</p>
        </div>
    </div>

    <div class="subcontent-layout">
        <aside class="content-list-panel">
            <div class="chapter-list-actions">
                <a class="button button--primary" href="TeacherChapterAdd.aspx?kind=subchapter&amp;chapter=<%= ChapterId %>&amp;n=<%= ChapterNumber %>"><%= TeacherIcons.Svg("plus", 17) %><span>Add subchapter</span></a>
                <a class="button button--secondary" href="TeacherChapterAdd.aspx?kind=quiz&amp;chapter=<%= ChapterId %>&amp;n=<%= ChapterNumber %>"><%= TeacherIcons.Svg("question", 17) %><span>Add quiz</span></a>
            </div>
            <div class="chapter-list-heading">
                <span>CHAPTER CONTENT</span>
                <strong><%= Contents.Count %> items</strong>
            </div>
            <input type="hidden" id="hfTeacherContentOrder" runat="server" value="" data-tp-content-order />
            <div class="content-reorder-items" data-tp-content-list data-tp-sortable="[data-tp-content-item]">
                <% int sub = 0, quiz = 0; for (int i = 0; i < Contents.Count; i++) { TeacherContentItem item = Contents[i]; %>
                <button type="button" class="content-reorder-item<%= i == 0 ? " is-active" : "" %>" data-tp-content-item data-id="<%= item.Id %>" data-type="<%= item.Type %>">
                    <span class="drag-handle"><%= TeacherIcons.Svg("grip", 17) %></span>
                    <span class="content-type-icon content-type-icon--<%= item.Type %>"><%= TeacherIcons.Svg(item.Type == "quiz" ? "question" : "book", 16) %></span>
                    <span>
                        <small><%= item.Type == "quiz" ? "QUIZ" : "SUBCHAPTER" %> <%= i + 1 %></small>
                        <strong><%: item.Title %></strong>
                    </span>
                </button>
                <% } %>
            </div>
        </aside>

        <div class="subcontent-editors">
            <article class="chapter-detail-card">
                <div class="chapter-card-header">
                    <div>
                        <span>SUBCHAPTER 1</span>
                        <h3><%: Contents[0].Title %></h3>
                    </div>
                    <span class="card-heading-icon"><%= TeacherIcons.Svg("book", 18) %></span>
                </div>
                <div class="editor-fields">
                    <label class="form-field">
                        <span>Title <b>*</b></span>
                        <asp:TextBox ID="txtTeacherSubchapterTitle" runat="server" autocomplete="off"></asp:TextBox>
                    </label>
                    <div class="form-field">
                        <span>Media</span>
                        <uc:MediaDropzone ID="dzTeacherSubchapterMedia" runat="server" />
                    </div>
                    <div class="form-field">
                        <span>Description <b>*</b></span>
                        <uc:RichEditor ID="reTeacherSubchapterDescription" runat="server" />
                    </div>
                </div>
                <div class="chapter-detail-actions">
                    <asp:LinkButton ID="btnTeacherUpdateSubchapter" runat="server" CssClass="button button--primary" OnClick="btnTeacherUpdateSubchapter_Click"><svg aria-hidden="true" class="icon" fill="none" height="17" viewBox="0 0 24 24" width="17"><path d='m5 12 4 4L19 6' /></svg><span>Update details</span></asp:LinkButton>
                    <button type="button" class="button button--danger" data-tp-open-modal="tpDeleteSubchapterModal"><%= TeacherIcons.Svg("trash", 17) %><span>Delete subchapter</span></button>
                </div>
            </article>

            <article class="quiz-editor-card" data-tp-questions>
                <div class="quiz-editor-heading">
                    <div>
                        <span>QUIZ EDITOR</span>
                        <h2>Getting Started Checkpoint</h2>
                    </div>
                    <button type="button" class="button button--primary" data-tp-q-add><%= TeacherIcons.Svg("plus", 17) %><span>Add question</span></button>
                </div>
                <asp:Repeater ID="rptTeacherQuizQuestions" runat="server">
                    <ItemTemplate>
                        <uc:QuestionCard runat="server" Mode="quiz" Number='<%# Container.ItemIndex + 1 %>' Question='<%# Container.DataItem %>' />
                    </ItemTemplate>
                </asp:Repeater>
                <button type="button" class="add-question-row" data-tp-q-add data-tp-q-anchor><%= TeacherIcons.Svg("plus", 16) %>Add question</button>
                <template data-tp-q-template>
                    <uc:QuestionCard ID="qcTeacherNewQuizQuestion" runat="server" Mode="quiz" Number="1" />
                </template>
            </article>
        </div>
    </div>
</asp:Content>

<asp:Content ID="ContentModals" ContentPlaceHolderID="cphModals" runat="server">
    <uc:ConfirmModal ID="mdlTeacherDeleteSubchapter" runat="server" ModalId="tpDeleteSubchapterModal" TitleText="Delete subchapter?" ConfirmText="Delete subchapter" OnConfirmed="mdlTeacherDeleteSubchapter_Confirmed" />
</asp:Content>
