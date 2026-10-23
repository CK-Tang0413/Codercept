<%@ Page Title="Manage Chapters - Codercept" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="TeacherChapters.aspx.cs" Inherits="Codercept.TeacherChapters" MaintainScrollPositionOnPostBack="true" %>
<%@ MasterType VirtualPath="~/TeacherSite.master" %>
<%@ Register Src="~/TeacherCourseSelector.ascx" TagPrefix="uc" TagName="CourseSelector" %>
<%@ Register Src="~/TeacherStepHeading.ascx" TagPrefix="uc" TagName="StepHeading" %>
<%@ Register Src="~/TeacherConfirmModal.ascx" TagPrefix="uc" TagName="ConfirmModal" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <div class="page-heading course-page-heading">
        <div>
            <span class="eyebrow">COURSE CONTENT</span>
            <h1>Manage Course Chapters</h1>
            <p>Organise chapters, assessments, subchapters, and quizzes.</p>
        </div>
    </div>

    <section class="flow-section">
        <uc:StepHeading runat="server" Step="1" Title="Select a course" Subtitle="Choose the course whose chapter structure you want to edit." />
        <uc:CourseSelector ID="selTeacherChapterCourse" runat="server" />
    </section>

    <section class="flow-section" data-tp-region="details">
        <uc:StepHeading ID="shTeacherChapters" runat="server" Step="2" Title="Manage chapters" />
        <%-- Picking a chapter does not reload the page: TeacherPortal.js copies the chapter's data-* values into the details panel,
         sets hfTeacherChapterId, and the Update / Delete buttons post that id. selected ChapterId + display order of the chapters, as a comma-separated list of ChapterIds (changed by TeacherPortal.js) --%>
        <input type="hidden" id="hfTeacherChapterId" runat="server" value="1" data-tp-chapter-input />
        <input type="hidden" id="hfTeacherChapterOrder" runat="server" value="" data-tp-chapter-order />

        <div class="chapter-master-detail">
            <aside class="chapter-list-panel">
                <div class="chapter-list-actions">
                    <a class="button button--primary" href="TeacherChapterAdd.aspx?kind=chapter"><%= TeacherIcons.Svg("plus", 17) %><span>Add chapter</span></a>
                    <a class="button button--secondary" href="TeacherChapterAdd.aspx?kind=assessment&amp;chapter=<%= Active.Id %>&amp;n=<%= ActiveNumber %>" data-tp-ch-link="TeacherChapterAdd.aspx?kind=assessment&amp;chapter="><%= TeacherIcons.Svg("grade", 17) %><span>Add assessment</span></a>
                </div>
                <div class="chapter-list-heading">
                    <span>COURSE CONTENT</span>
                    <strong><%= Chapters.Count %> chapters</strong>
                </div>
                <div class="chapter-items" data-tp-chapter-list data-tp-sortable="[data-tp-chapter-pick]">
                    <% for (int i = 0; i < Chapters.Count; i++) { TeacherChapter c = Chapters[i]; %>
                    <div class="chapter-item<%= c.Id == Active.Id ? " is-active" : "" %>" role="button" tabindex="0" data-tp-chapter-pick="<%= c.Id %>"
                        data-number="<%= i + 1 %>" data-title="<%: c.Title %>" data-description="<%: c.Description %>" data-duration="<%: TeacherSampleData.HoursOf(c.Duration) %>" data-created="<%: c.Created %>" data-updated="<%: c.Updated %>">
                        <span class="drag-handle" title="Drag to reorder"><%= TeacherIcons.Svg("grip", 17) %></span>
                        <span class="chapter-number"><%= i + 1 %></span>
                        <span class="chapter-item-title"><%: c.Title %></span>
                        <span class="reorder-buttons">
                            <button type="button" aria-label="Move <%: c.Title %> up"<%= i == 0 ? " disabled" : "" %> data-tp-ch-up><%= TeacherIcons.Svg("up", 13) %></button>
                            <button type="button" aria-label="Move <%: c.Title %> down"<%= i == Chapters.Count - 1 ? " disabled" : "" %> data-tp-ch-down><%= TeacherIcons.Svg("down", 13) %></button>
                        </span>
                    </div>
                    <% } %>
                </div>
            </aside>

            <div class="chapter-detail-column">
                <article class="chapter-detail-card">
                    <div class="chapter-detail-title">
                        <span class="large-number-badge" data-tp-ch-number><%= ActiveNumber %></span>
                        <div>
                            <span>CHAPTER <span data-tp-ch-number><%= ActiveNumber %></span></span>
                            <div id="fldTeacherChapterTitle" runat="server" class="tp-inline-field">
                                <asp:TextBox ID="txtTeacherChapterTitle" runat="server" CssClass="tp-heading-input" autocomplete="off" aria-label="Chapter title" data-tp-ch-title></asp:TextBox>
                                <small id="hintTeacherChapterTitle" runat="server" data-err="Enter a title with at least 4 characters."></small>
                            </div>
                        </div>
                    </div>
                    <label class="form-field">
                        <span>Description</span>
                        <asp:TextBox ID="txtTeacherChapterDescription" runat="server" TextMode="MultiLine" Rows="5" autocomplete="off" data-tp-ch-description></asp:TextBox>
                        <small>Summarise this chapter's learning goals and key concepts.</small>
                    </label>
                    <div class="chapter-meta-grid">
                        <div class="detail-item">
                            <span class="detail-item-icon"><%= TeacherIcons.Svg("clock", 17) %></span>
                            <div id="fldTeacherChapterDuration" runat="server" class="tp-inline-field">
                                <span>Duration (hours)</span>
                                <asp:TextBox ID="txtTeacherChapterDuration" runat="server" TextMode="Number" min="0.5" step="0.5" autocomplete="off" aria-label="Duration in hours" data-tp-ch-duration></asp:TextBox>
                                <small id="hintTeacherChapterDuration" runat="server" data-err="Enter a duration greater than 0."></small>
                            </div>
                        </div>
                        <div class="detail-item">
                            <span class="detail-item-icon"><%= TeacherIcons.Svg("calendar", 17) %></span>
                            <div><span>Date Created</span><strong data-tp-ch-created><%: Active.Created %></strong></div>
                        </div>
                        <div class="detail-item">
                            <span class="detail-item-icon"><%= TeacherIcons.Svg("calendar", 17) %></span>
                            <div><span>Date Updated</span><strong data-tp-ch-updated><%: Active.Updated %></strong></div>
                        </div>
                    </div>
                    <div class="chapter-detail-actions">
                        <asp:LinkButton ID="btnTeacherUpdateChapter" runat="server" CssClass="button button--primary" OnClick="btnTeacherUpdateChapter_Click"><svg aria-hidden="true" class="icon" fill="none" height="17" viewBox="0 0 24 24" width="17"><path d='m5 12 4 4L19 6' /></svg><span>Update details</span></asp:LinkButton>
                        <button type="button" class="button button--danger" data-tp-open-modal="tpDeleteChapterModal"><%= TeacherIcons.Svg("trash", 17) %><span>Delete chapter</span></button>
                    </div>
                </article>

                <article class="chapter-detail-card content-summary-card">
                    <div class="chapter-card-header">
                        <div>
                            <span>CHAPTER CONTENT</span>
                            <h3>Subchapters and Quizzes</h3>
                        </div>
                        <span class="badge badge--indigo"><%= Contents.Count %> items</span>
                    </div>
                    <div class="content-summary-grid">
                        <div>
                            <span class="summary-column-title"><%= TeacherIcons.Svg("book", 15) %>Subchapters</span>
                            <% int s = 0; foreach (TeacherContentItem item in Contents) { if (item.Type != "subchapter") continue; s++; %>
                            <div class="summary-item">
                                <span class="summary-icon summary-icon--book"><%= TeacherIcons.Svg("book", 15) %></span>
                                <div><small>Subchapter <%= s %></small><strong><%: item.Title %></strong></div>
                            </div>
                            <% } %>
                        </div>
                        <div>
                            <span class="summary-column-title"><%= TeacherIcons.Svg("question", 15) %>Quizzes</span>
                            <% int q = 0; foreach (TeacherContentItem item in Contents) { if (item.Type != "quiz") continue; q++; %>
                            <div class="summary-item">
                                <span class="summary-icon summary-icon--quiz"><%= TeacherIcons.Svg("question", 15) %></span>
                                <div><small>Quiz <%= q %></small><strong><%: item.Title %></strong></div>
                            </div>
                            <% } %>
                        </div>
                    </div>
                    <a class="button button--secondary" href="TeacherChapterContent.aspx?chapter=<%= Active.Id %>&amp;n=<%= ActiveNumber %>" data-tp-ch-link="TeacherChapterContent.aspx?chapter="><%= TeacherIcons.Svg("layers", 17) %><span>Manage subchapters/quizzes</span></a>
                </article>
            </div>
        </div>
    </section>
</asp:Content>

<asp:Content ID="ContentModals" ContentPlaceHolderID="cphModals" runat="server">
    <uc:ConfirmModal ID="mdlTeacherDeleteChapter" runat="server" ModalId="tpDeleteChapterModal" TitleText="Delete chapter?" ConfirmText="Delete chapter" OnConfirmed="mdlTeacherDeleteChapter_Confirmed" />
</asp:Content>
