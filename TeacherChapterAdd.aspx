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
    </div>

    <div class="stepped-form">
        <section>
            <uc:StepHeading ID="shTeacherDetails" runat="server" Step="1" Title="Fill in details" />
            <article class="form-card content-form-card">
                <div class="form-fields">
                    <label class="form-field">
                        <span>Title <b>*</b></span>
                        <asp:TextBox ID="txtTeacherContentTitle" runat="server" autocomplete="off"></asp:TextBox>
                        <small>Use a clear title that describes this content.</small>
                    </label>
                    <div class="form-field">
                        <span>Add file</span>
                        <uc:MediaDropzone ID="dzTeacherContentFile" runat="server" Compact="true" />
                    </div>
                    <div class="form-field">
                        <span>Description <b>*</b></span>
                        <uc:RichEditor ID="reTeacherContentDescription" runat="server" />
                        <small>Explain what learners will cover in this section.</small>
                    </div>
                    <asp:Panel ID="pnlTeacherDuration" runat="server" CssClass="form-field duration-field" Visible="false">
                        <span>Duration <b>*</b></span>
                        <div class="suffix-input">
                            <asp:TextBox ID="txtTeacherContentDuration" runat="server" TextMode="Number" min="1" placeholder="0"></asp:TextBox>
                            <span>minutes</span>
                        </div>
                    </asp:Panel>
                </div>
            </article>
        </section>

        <asp:PlaceHolder ID="phTeacherQuestions" runat="server" Visible="false">
            <section>
                <uc:StepHeading runat="server" Step="2" Title="Add questions &amp; answers" Subtitle="Set marks, add answer choices, and identify the correct answer." />
                <div class="form-question-stack" data-tp-questions>
                    <uc:QuestionCard ID="qcTeacherFirstQuestion" runat="server" Number="1" />
                    <button type="button" class="add-question-row" data-tp-q-add data-tp-q-anchor><%= TeacherIcons.Svg("plus", 16) %>Add question</button>
                    <template data-tp-q-template>
                        <uc:QuestionCard ID="qcTeacherNewQuestion" runat="server" Number="1" />
                    </template>
                </div>
            </section>
        </asp:PlaceHolder>
    </div>

    <div class="sticky-form-actions">
        <div>
            <a class="button button--ghost" href="<%= BackUrl %>"><span>Back</span></a>
            <asp:LinkButton ID="btnTeacherCreateContent" runat="server" CssClass="button button--primary" OnClick="btnTeacherCreateContent_Click"></asp:LinkButton>
        </div>
    </div>
</asp:Content>
