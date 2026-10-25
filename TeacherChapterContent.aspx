<%@ Page Title="Manage Subchapters - Codercept" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="TeacherChapterContent.aspx.cs" Inherits="Codercept.TeacherChapterContent" %>
<%@ MasterType VirtualPath="~/TeacherSite.master" %>
<%@ Register Src="~/TeacherBreadcrumb.ascx" TagPrefix="uc" TagName="Breadcrumb" %>
<%@ Register Src="~/TeacherRichEditor.ascx" TagPrefix="uc" TagName="RichEditor" %>
<%@ Register Src="~/TeacherMediaDropzone.ascx" TagPrefix="uc" TagName="MediaDropzone" %>
<%@ Register Src="~/TeacherConfirmModal.ascx" TagPrefix="uc" TagName="ConfirmModal" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <a class="back-link" href="TeacherChapters.aspx?chapter=<%= ChapterId %>"><%= TeacherIcons.Svg("arrow", 16) %>Back to Manage Course Chapters</a>
    <uc:Breadcrumb ID="bcTeacherChapter" runat="server" />
    <div class="page-heading course-page-heading content-page-heading">
        <div>
            <span class="eyebrow">CHAPTER CONTENT</span>
            <h1>Manage Subchapters</h1>
            <p>Reorder the lessons of this chapter and edit their learning material.</p>
        </div>
    </div>

    <div class="subcontent-layout">
        <aside class="content-list-panel">
            <div class="chapter-list-actions">
                <a class="button button--primary" href="TeacherChapterAdd.aspx?kind=subchapter&amp;chapter=<%= ChapterId %>&amp;n=<%= ChapterNumber %>"><%= TeacherIcons.Svg("plus", 17) %><span>Add subchapter</span></a>
            </div>
            <div class="chapter-list-heading">
                <span>CHAPTER CONTENT</span>
                <strong><%= Contents.Count %> subchapter<%= Contents.Count == 1 ? "" : "s" %></strong>
            </div>
            <%-- Picking a subchapter does not reload the page: TeacherPortal.js copies the item's data-* values into the editor and sets
                 hfTeacherSubchapterId, which Update / Delete post. Dragging only changes hfTeacherContentOrder (SubChapterIds in order),
                 saved together with Update details. --%>
            <input type="hidden" id="hfTeacherSubchapterId" runat="server" value="" data-tp-content-input />
            <input type="hidden" id="hfTeacherContentOrder" runat="server" value="" data-tp-content-order />
            <div class="content-reorder-items" data-tp-content-list data-tp-sortable="[data-tp-content-item]">
                <% for (int i = 0; i < Contents.Count; i++) { TeacherContentItem item = Contents[i]; %>
                <button type="button" class="content-reorder-item<%= item.Id == Active.Id ? " is-active" : "" %>" data-tp-content-item data-id="<%= item.Id %>"
                    data-title="<%: item.Title %>" data-description="<%: item.Description %>" data-minutes="<%= item.Minutes %>" data-media="<%: item.MediaLink %>">
                    <span class="drag-handle"><%= TeacherIcons.Svg("grip", 17) %></span>
                    <span class="content-type-icon content-type-icon--subchapter"><%= TeacherIcons.Svg("book", 16) %></span>
                    <span>
                        <small>SUBCHAPTER <%= i + 1 %></small>
                        <strong><%: item.Title %></strong>
                    </span>
                </button>
                <% } %>
            </div>
        </aside>

        <div class="subcontent-editors">
            <% if (Contents.Count == 0) { %>
            <article class="chapter-detail-card">
                <p class="summary-empty">This chapter has no subchapters yet. Use "Add subchapter" to create the first one.</p>
            </article>
            <% } else { %>
                <article class="chapter-detail-card">
                    <div class="chapter-card-header">
                        <div>
                            <span>SUBCHAPTER <span data-tp-sub-number><%= ActiveNumber %></span></span>
                            <h3 data-tp-sub-heading><%: Active.Title %></h3>
                        </div>
                        <span class="card-heading-icon"><%= TeacherIcons.Svg("book", 18) %></span>
                    </div>
                    <div class="editor-fields">
                        <label id="fldTeacherSubchapterTitle" runat="server" class="form-field" data-tp-sub-title-field>
                            <span>Title <b>*</b></span>
                            <asp:TextBox ID="txtTeacherSubchapterTitle" runat="server" ValidateRequestMode="Disabled" MaxLength="50" autocomplete="off" data-tp-sub-title></asp:TextBox>
                            <small id="hintTeacherSubchapterTitle" runat="server" data-ok="Use a clear title that describes this lesson." data-err="Enter a title of 4 to 50 characters.">Use a clear title that describes this lesson.</small>
                        </label>
                        <div class="form-field">
                            <span>Media</span>
                            <div class="current-media" data-tp-media-row hidden>
                                <a href="#" target="_blank" rel="noopener" data-tp-media-link></a>
                                <button type="button" class="button button--ghost" data-tp-media-toggle>Remove file</button>
                                <small data-tp-media-note hidden>The file will be removed when you click Update details.</small>
                            </div>
                            <uc:MediaDropzone ID="dzTeacherSubchapterMedia" runat="server" />
                            <small>Choosing a new file replaces the current one.</small>
                            <input type="hidden" id="hfTeacherSubchapterMediaRemove" runat="server" value="" data-tp-media-remove-input />
                        </div>
                        <div class="form-field" data-tp-sub-description>
                            <span>Description <b>*</b></span>
                            <uc:RichEditor ID="reTeacherSubchapterDescription" runat="server" />
                        </div>
                        <div class="form-field duration-field">
                            <span>Duration <b>*</b></span>
                            <div class="suffix-input">
                                <asp:TextBox ID="txtTeacherSubchapterDuration" runat="server" TextMode="Number" min="1" max="600" placeholder="0" data-tp-sub-duration></asp:TextBox>
                                <span>minutes</span>
                            </div>
                        </div>
                    </div>
                    <div class="chapter-detail-actions">
                        <asp:LinkButton ID="btnTeacherUpdateSubchapter" runat="server" CssClass="button button--primary" OnClick="btnTeacherUpdateSubchapter_Click"><svg aria-hidden="true" class="icon" fill="none" height="17" viewBox="0 0 24 24" width="17"><path d='m5 12 4 4L19 6' /></svg><span>Update details</span></asp:LinkButton>
                        <button type="button" class="button button--danger" data-tp-open-modal="tpDeleteSubchapterModal"><%= TeacherIcons.Svg("trash", 17) %><span>Delete subchapter</span></button>
                    </div>
                </article>

            <% } %>
        </div>
    </div>
</asp:Content>

<asp:Content ID="ContentModals" ContentPlaceHolderID="cphModals" runat="server">
    <uc:ConfirmModal ID="mdlTeacherDeleteSubchapter" runat="server" ModalId="tpDeleteSubchapterModal" TitleText="Delete subchapter?" ConfirmText="Delete subchapter" OnConfirmed="mdlTeacherDeleteSubchapter_Confirmed" />
</asp:Content>
