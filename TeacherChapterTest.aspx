<%@ Page Title="Edit Quiz or Assessment - Codercept" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="TeacherChapterTest.aspx.cs" Inherits="Codercept.TeacherChapterTest" %>
<%@ MasterType VirtualPath="~/TeacherSite.master" %>
<%@ Register Src="~/TeacherStepHeading.ascx" TagPrefix="uc" TagName="StepHeading" %>
<%@ Register Src="~/TeacherBreadcrumb.ascx" TagPrefix="uc" TagName="Breadcrumb" %>
<%@ Register Src="~/TeacherRichEditor.ascx" TagPrefix="uc" TagName="RichEditor" %>
<%@ Register Src="~/TeacherMediaDropzone.ascx" TagPrefix="uc" TagName="MediaDropzone" %>
<%@ Register Src="~/TeacherQuestionCard.ascx" TagPrefix="uc" TagName="QuestionCard" %>
<%@ Register Src="~/TeacherConfirmModal.ascx" TagPrefix="uc" TagName="ConfirmModal" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <a class="back-link" href="<%= BackUrl %>"><%= TeacherIcons.Svg("arrow", 16) %>Back to Manage Course Chapters</a>
    <uc:Breadcrumb ID="bcTeacherChapter" runat="server" />
    <div class="page-heading course-page-heading content-page-heading">
        <div>
            <span class="eyebrow">END OF CHAPTER</span>
            <h1>Edit <%: Noun %></h1>
            <p>Update the details and the questions of this chapter's <%: Noun.ToLowerInvariant() %>.</p>
        </div>
    </div>

    <%-- Learners have attempted it: the questions are shown but cannot be changed, and it cannot be deleted --%>
    <asp:Panel ID="pnlTeacherLocked" runat="server" Visible="false">
        <article class="form-card content-form-card">
            <div class="form-card-heading">
                <span class="form-card-icon"><%= TeacherIcons.Svg("info", 20) %></span>
                <div>
                    <h2>Learners have attempted this <%: Noun.ToLowerInvariant() %></h2>
                    <p>Its questions can no longer be changed, so learners' answers and marks stay correct. You can still edit the title, description and file.</p>
                </div>
            </div>
        </article>
    </asp:Panel>

    <div class="stepped-form">
        <section>
            <uc:StepHeading ID="shTeacherDetails" runat="server" Step="1" Title="Fill in details" />
            <article class="form-card content-form-card">
                <div class="form-fields">
                    <label id="fldTeacherTestTitle" runat="server" class="form-field">
                        <span>Title <b>*</b></span>
                        <asp:TextBox ID="txtTeacherTestTitle" runat="server" ValidateRequestMode="Disabled" MaxLength="50" autocomplete="off"></asp:TextBox>
                        <small id="hintTeacherTestTitle" runat="server" data-ok="Use a clear title that describes this content." data-err="Enter a title of 4 to 50 characters.">Use a clear title that describes this content.</small>
                    </label>
                    <div class="form-field">
                        <span>File</span>
                        <div class="current-media" data-tp-media-row data-media="<%: MediaLink %>" hidden>
                            <a href="#" target="_blank" rel="noopener" data-tp-media-link></a>
                            <button type="button" class="button button--ghost" data-tp-media-toggle>Remove file</button>
                            <small data-tp-media-note hidden>The file will be removed when you click Save changes.</small>
                        </div>
                        <uc:MediaDropzone ID="dzTeacherTestFile" runat="server" Compact="true" />
                        <small>Choosing a new file replaces the current one.</small>
                        <input type="hidden" id="hfTeacherTestMediaRemove" runat="server" value="" data-tp-media-remove-input />
                    </div>
                    <div class="form-field">
                        <span>Description</span>
                        <uc:RichEditor ID="reTeacherTestDescription" runat="server" />
                        <small>Explain what learners will be asked in this section.</small>
                    </div>
                </div>
            </article>
        </section>

        <section>
            <uc:StepHeading runat="server" Step="2" Title="Questions &amp; answers" Subtitle="Set marks, add answer choices, and identify the correct answer." />
            <div id="divTeacherQuestions" runat="server" class="form-question-stack" data-tp-questions>
                <asp:Repeater ID="rptTeacherTestQuestions" runat="server">
                    <ItemTemplate>
                        <uc:QuestionCard runat="server" Mode='<%# Mode %>' Number='<%# Container.ItemIndex + 1 %>' Question='<%# Container.DataItem %>' />
                    </ItemTemplate>
                </asp:Repeater>
                <button type="button" class="add-question-row" data-tp-q-add data-tp-q-anchor><%= TeacherIcons.Svg("plus", 16) %>Add question</button>
                <template data-tp-q-template>
                    <uc:QuestionCard ID="qcTeacherNewQuestion" runat="server" Number="1" />
                </template>
            </div>
        </section>
    </div>

    <div class="exam-sticky-bar">
        <div class="exam-marks-total">
            <span>Total marks</span>
            <strong data-tp-total-marks>0</strong>
            <small data-tp-total-count>Across 0 questions</small>
        </div>
        <div>
            <a class="button button--ghost" href="<%= BackUrl %>"><span>Back</span></a>
            <button type="button" class="button button--danger" data-tp-open-modal="tpDeleteTestModal"><%= TeacherIcons.Svg("trash", 17) %><span>Delete <%: Noun.ToLowerInvariant() %></span></button>
            <asp:LinkButton ID="btnTeacherSaveTest" runat="server" CssClass="button button--primary" OnClick="btnTeacherSaveTest_Click"><svg aria-hidden="true" class="icon" fill="none" height="17" viewBox="0 0 24 24" width="17"><path d='m5 12 4 4L19 6' /></svg><span>Save changes</span></asp:LinkButton>
        </div>
    </div>
</asp:Content>

<asp:Content ID="ContentModals" ContentPlaceHolderID="cphModals" runat="server">
    <uc:ConfirmModal ID="mdlTeacherDeleteTest" runat="server" ModalId="tpDeleteTestModal" OnConfirmed="mdlTeacherDeleteTest_Confirmed" />
</asp:Content>
