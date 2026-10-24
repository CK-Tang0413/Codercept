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
            <span><%= ExamExists ? "EDITING EXAM FOR" : "CREATING EXAM FOR" %></span>
            <h1><%: Course.Title %></h1>
            <p><%: Course.Language %> &bull; <%: Course.Difficulty %> &bull; <%: Course.Duration %> hours</p>
        </div>
        <span class="badge badge--<%= ExamExists ? "success" : "warning" %>"><%= ExamExists ? "Exam configured" : "Not created yet" %></span>
        <i class="code-symbol code-symbol--one">{ }</i>
        <i class="code-symbol code-symbol--two">01</i>
    </div>

    <% if (!ExamExists) { %>
    <div class="exam-new-note">
        <%= TeacherIcons.Svg("info", 17) %>
        <p>This course has no exam yet. Set the pass mark, time limit and rules, add the questions, then press <strong>Create exam</strong>. Learners must pass the exam to earn the course certificate.</p>
    </div>
    <% } %>

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
                        <strong contenteditable="true" role="spinbutton" inputmode="numeric" spellcheck="false" data-tp-step-value aria-label="Minimum marks to pass"><%: hfTeacherMinMarks.Value %></strong>
                        <span>%</span>
                        <button type="button" aria-label="Increase minimum marks" data-tp-step="1">+</button>
                        <input type="hidden" id="hfTeacherMinMarks" runat="server" value="50" data-tp-step-input />
                    </div>
                </div>
                <div class="exam-stepper-field">
                    <div>
                        <span>Time limit</span>
                        <small>Minutes learners have to finish the exam</small>
                    </div>
                    <div class="large-stepper" data-tp-stepper data-min="5" data-max="300">
                        <button type="button" aria-label="Decrease time limit" data-tp-step="-5">&minus;</button>
                        <strong contenteditable="true" role="spinbutton" inputmode="numeric" spellcheck="false" data-tp-step-value aria-label="Time limit in minutes"><%: hfTeacherTimeLimit.Value %></strong>
                        <span>min</span>
                        <button type="button" aria-label="Increase time limit" data-tp-step="5">+</button>
                        <input type="hidden" id="hfTeacherTimeLimit" runat="server" value="60" data-tp-step-input />
                    </div>
                </div>
                <div class="exam-language-field">
                    <span>Programming language</span>
                    <small>Taken from the course, used for syntax and code validation</small>
                    <div class="language-select language-select--static">
                        <span class="language-dot language-dot--<%= Course.Theme %>"><%: Course.Glyph %></span>
                        <strong><%: Course.Language %></strong>
                    </div>
                </div>
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
                    <input type="hidden" name="tpRule<%= r.Id %>" value="<%= r.On ? "1" : "0" %>" data-tp-toggle-input />
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
            <asp:LinkButton ID="btnTeacherSaveExam" runat="server" CssClass="button button--primary" OnClick="btnTeacherSaveExam_Click"></asp:LinkButton>
        </div>
    </div>
</asp:Content>
