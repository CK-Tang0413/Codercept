<%@ Page Title="Add Content - Codercept" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="TeacherChapterAdd.aspx.cs" Inherits="Codercept.TeacherChapterAdd" %>
<%@ MasterType VirtualPath="~/TeacherSite.master" %>
<%@ Register Src="~/TeacherStepHeading.ascx" TagPrefix="uc" TagName="StepHeading" %>
<%@ Register Src="~/TeacherBreadcrumb.ascx" TagPrefix="uc" TagName="Breadcrumb" %>
<%@ Register Src="~/TeacherRichEditor.ascx" TagPrefix="uc" TagName="RichEditor" %>
<%@ Register Src="~/TeacherMediaDropzone.ascx" TagPrefix="uc" TagName="MediaDropzone" %>
<%@ Register Src="~/TeacherQuestionCard.ascx" TagPrefix="uc" TagName="QuestionCard" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <a class="back-link" href="<%= BackUrl %>"><%= TeacherIcons.Svg("arrow", 16) %>Back to previous page</a>
    <uc:Breadcrumb ID="bcTeacherChapter" runat="server" />
    <div class="page-heading course-page-heading content-page-heading">
        <div>
            <span class="eyebrow">COURSE CONTENT</span>
            <h1><%: Labels.Title %></h1>
            <p><%: Labels.Hint %></p>
        </div>
        <% if (CanSuggest) { %>
        <button type="button" class="button button--secondary" data-tp-open-modal="tpAiChapterModal"><%= TeacherIcons.Svg("sparkle", 17) %><span>Suggest with AI</span></button>
        <% } %>
    </div>

    <%-- A chapter has one quiz or one assessment: when it already has one, the teacher is sent to edit it instead --%>
    <asp:Panel ID="pnlTeacherExists" runat="server" Visible="false">
        <article class="form-card content-form-card">
            <div class="form-card-heading">
                <span class="form-card-icon"><%= TeacherIcons.Svg("info", 20) %></span>
                <div>
                    <h2><%: ExistingTitle %></h2>
                    <p><%: ExistingText %></p>
                </div>
            </div>
            <div class="form-actions">
                <a class="button button--primary" href="<%= EditUrl %>"><%= TeacherIcons.Svg("edit", 17) %><span>Edit <%: ExistingType %></span></a>
                <a class="button button--ghost" href="<%= BackUrl %>"><span>Back</span></a>
            </div>
        </article>
    </asp:Panel>

    <asp:Panel ID="pnlTeacherForm" runat="server">
        <div class="stepped-form">
            <section>
                <uc:StepHeading ID="shTeacherDetails" runat="server" Step="1" Title="Fill in details" />
                <article class="form-card content-form-card">
                    <div class="form-fields">
                        <label id="fldTeacherContentTitle" runat="server" class="form-field">
                            <span>Title <b>*</b></span>
                            <asp:TextBox ID="txtTeacherContentTitle" runat="server" ValidateRequestMode="Disabled" MaxLength="50" autocomplete="off" data-tp-ai-title="1"></asp:TextBox>
                            <small id="hintTeacherContentTitle" runat="server" data-ok="Use a clear title that describes this content." data-err="Enter a title of 4 to 50 characters.">Use a clear title that describes this content.</small>
                        </label>
                        <div class="form-field">
                            <span>Add file</span>
                            <uc:MediaDropzone ID="dzTeacherContentFile" runat="server" Compact="true" />
                        </div>
                        <div class="form-field">
                            <span>Description<% if (!HasQuestions) { %> <b>*</b><% } %></span>
                            <uc:RichEditor ID="reTeacherContentDescription" runat="server" />
                            <small>Explain what learners will cover in this section.</small>
                        </div>
                        <asp:Panel ID="pnlTeacherDuration" runat="server" CssClass="form-field duration-field" Visible="false">
                            <span>Duration <b>*</b></span>
                            <div class="suffix-input">
                                <asp:TextBox ID="txtTeacherContentDuration" runat="server" TextMode="Number" min="1" placeholder="0" data-tp-ai-duration="1"></asp:TextBox>
                                <span><%= DurationUnit %></span>
                            </div>
                        </asp:Panel>
                    </div>
                </article>
            </section>

            <asp:PlaceHolder ID="phTeacherQuestions" runat="server" Visible="false">
                <section>
                    <uc:StepHeading runat="server" Step="2" Title="Add questions &amp; answers" Subtitle="Set marks, add answer choices, and identify the correct answer." />
                    <div class="form-question-stack" data-tp-questions>
                        <asp:Repeater ID="rptTeacherQuestions" runat="server">
                            <ItemTemplate>
                                <uc:QuestionCard runat="server" Mode='<%# QuestionMode %>' Number='<%# Container.ItemIndex + 1 %>' Question='<%# Container.DataItem %>' />
                            </ItemTemplate>
                        </asp:Repeater>
                        <button type="button" class="add-question-row" data-tp-q-add data-tp-q-anchor><%= TeacherIcons.Svg("plus", 16) %>Add question</button>
                        <template data-tp-q-template>
                            <uc:QuestionCard ID="qcTeacherNewQuestion" runat="server" Number="1" />
                        </template>
                    </div>
                </section>
            </asp:PlaceHolder>
        </div>

        <%-- A quiz or assessment shows the total marks of its questions on the left, like the exam page --%>
        <div class="<%= HasQuestions ? "exam-sticky-bar" : "sticky-form-actions" %>">
            <% if (HasQuestions) { %>
            <div class="exam-marks-total">
                <span>Total marks</span>
                <strong data-tp-total-marks>0</strong>
                <small data-tp-total-count>Across 0 questions</small>
            </div>
            <% } %>
            <div>
                <a class="button button--ghost" href="<%= BackUrl %>"><span>Back</span></a>
                <asp:LinkButton ID="btnTeacherCreateContent" runat="server" CssClass="button button--primary" OnClick="btnTeacherCreateContent_Click"></asp:LinkButton>
            </div>
        </div>
    </asp:Panel>
</asp:Content>

<asp:Content ID="ContentModals" ContentPlaceHolderID="cphModals" runat="server">
    <% if (CanSuggest) { %>
    <%-- "Suggest with AI": the course (and its chapters) is read on the server; the suggestion only fills this form, the teacher edits and creates the chapter as usual. --%>
    <div class="modal-backdrop" role="presentation" id="tpAiChapterModal" data-tp-modal data-tp-region="tpAiChapterModal" data-tp-ai-chapter="<%= CourseId %>" hidden>
        <div class="modal ai-modal" role="dialog" aria-modal="true" aria-labelledby="tpAiChapterModalTitle">
            <h2 id="tpAiChapterModalTitle">Suggest with AI</h2>
            <p>The assistant looks at this course and its existing chapters, then suggests the next chapter: a title, description and duration.</p>
            <label class="portal-form-field">
                <span>Your idea (optional)</span>
                <textarea rows="3" maxlength="1000" placeholder="e.g. Error handling, or leave empty to let the assistant choose" aria-label="Your chapter idea" data-tp-ai-idea data-tp-clear-on-close data-tp-autofocus></textarea>
                <small></small>
            </label>
            <p class="ai-note">This replaces the title, description and duration you have typed. Check the suggestion before you create the chapter.</p>
            <div class="modal-actions">
                <button type="button" class="button button--ghost" data-tp-close-modal><span>Cancel</span></button>
                <button type="button" class="button button--primary" data-tp-ai-run><%= TeacherIcons.Svg("sparkle", 17) %><span>Suggest</span></button>
            </div>
        </div>
    </div>
    <% } %>
</asp:Content>
