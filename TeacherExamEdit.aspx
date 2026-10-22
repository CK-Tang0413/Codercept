<%@ Page Title="Edit Exam - Codercept" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="TeacherExamEdit.aspx.cs" Inherits="Codercept.TeacherExamEdit" %>
<%@ MasterType VirtualPath="~/TeacherSite.master" %>
<%@ Register Src="~/TeacherStepHeading.ascx" TagPrefix="uc" TagName="StepHeading" %>
<%@ Register Src="~/TeacherQuestionCard.ascx" TagPrefix="uc" TagName="QuestionCard" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <div class="exam-course-banner course-thumbnail--<%= Course.Theme %>">
        <span class="exam-banner-glyph"><%: Course.Glyph %></span>
        <div>
            <span>EDITING EXAM FOR</span>
            <h1><%: Course.Title %></h1>
            <p><%: Course.Language %> &bull; <%: Course.Difficulty %> &bull; <%: Course.Duration %> hours</p>
        </div>
        <span class="badge badge--success">Exam configured</span>
        <i class="code-symbol code-symbol--one">{ }</i>
        <i class="code-symbol code-symbol--two">01</i>
    </div>

    <section class="flow-section exam-flow-section">
        <uc:StepHeading runat="server" Step="1" Title="Configure exam rules and restrictions" Subtitle="Define passing criteria, language, and the restrictions learners must follow." />
        <article class="exam-rules-card">
            <div class="exam-primary-rules">
                <div class="exam-stepper-field">
                    <div>
                        <span>Min marks to pass</span>
                        <small>Required score as a percentage</small>
                    </div>
                    <div class="large-stepper" data-tp-stepper data-min="1" data-max="100">
                        <button type="button" aria-label="Decrease minimum marks" data-tp-step="-1">&minus;</button>
                        <strong data-tp-step-value>50</strong>
                        <span>%</span>
                        <button type="button" aria-label="Increase minimum marks" data-tp-step="1">+</button>
                        <input type="hidden" id="hfTeacherMinMarks" runat="server" value="50" data-tp-step-input />
                    </div>
                </div>
                <label class="exam-language-field">
                    <span>Programming language</span>
                    <small>Used for syntax and code validation</small>
                    <div class="language-select">
                        <span class="language-dot language-dot--<%= Course.Theme %>" data-tp-langdot><%: Course.Glyph %></span>
                        <asp:DropDownList ID="ddlTeacherExamLanguage" runat="server" data-tp-langselect></asp:DropDownList>
                    </div>
                </label>
            </div>
            <div class="rule-grid">
                <% for (int i = 0; i < Rules.Count; i++) { TeacherExamRule r = Rules[i]; %>
                <div class="rule-option">
                    <span class="rule-icon"><%= TeacherIcons.Svg(r.Icon, 17) %></span>
                    <div>
                        <div class="rule-title">
                            <strong><%: r.Title %></strong>
                            <button type="button" class="info-tooltip" aria-label="Information about <%: r.Title %>" title="<%: r.Description %>"><%= TeacherIcons.Svg("info", 14) %></button>
                        </div>
                        <p><%: r.Description %></p>
                    </div>
                    <button type="button" class="toggle-switch<%= r.On ? " is-on" : "" %>" aria-label="Toggle <%: r.Title %>" aria-pressed="<%= r.On ? "true" : "false" %>" data-tp-toggle><span></span></button>
                    <input type="hidden" name="tpRule<%= i %>" value="<%= r.On ? "1" : "0" %>" data-tp-toggle-input />
                </div>
                <% } %>
            </div>
        </article>
    </section>

    <section class="flow-section exam-flow-section">
        <uc:StepHeading runat="server" Step="2" Title="Manage exam questions" Subtitle="Add, reorder, and configure the questions learners will answer." />
        <div class="exam-question-stack" data-tp-questions>
            <asp:Repeater ID="rptTeacherExamQuestions" runat="server">
                <ItemTemplate>
                    <uc:QuestionCard runat="server" Mode="exam" Number='<%# Container.ItemIndex + 1 %>' Question='<%# Container.DataItem %>' />
                </ItemTemplate>
            </asp:Repeater>
            <button type="button" class="add-question-row" data-tp-q-add><%= TeacherIcons.Svg("plus", 16) %>Add question</button>
            <template data-tp-q-template>
                <uc:QuestionCard ID="qcTeacherNewQuestion" runat="server" Mode="exam" Number="1" />
            </template>
        </div>
    </section>

    <div class="exam-sticky-bar">
        <div class="exam-marks-total">
            <span>Total marks</span>
            <strong data-tp-total-marks>0</strong>
            <small data-tp-total-count>Across 0 questions</small>
        </div>
        <div>
            <a class="button button--ghost" href="TeacherExams.aspx"><span>Back to previous page</span></a>
            <asp:LinkButton ID="btnTeacherSaveExam" runat="server" CssClass="button button--primary" OnClick="btnTeacherSaveExam_Click"><svg aria-hidden="true" class="icon" fill="none" height="17" viewBox="0 0 24 24" width="17"><path d='m5 12 4 4L19 6' /></svg><span>Save exam details</span></asp:LinkButton>
        </div>
    </div>
</asp:Content>
