<%@ Page Title="Grade Course Assessments - Codercept" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="TeacherGradeAssessments.aspx.cs" Inherits="Codercept.TeacherGradeAssessments" %>
<%@ MasterType VirtualPath="~/TeacherSite.master" %>
<%@ Import Namespace="System.Linq" %>
<%@ Register Src="~/TeacherStepHeading.ascx" TagPrefix="uc" TagName="StepHeading" %>
<%@ Register Src="~/TeacherConfirmModal.ascx" TagPrefix="uc" TagName="ConfirmModal" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <div class="exam-course-banner course-thumbnail--<%= Course.Theme %>">
        <span class="exam-banner-glyph"><%: Course.Glyph %></span>
        <div>
            <span>GRADING ASSESSMENTS FOR</span>
            <h1><%: Course.Title %></h1>
            <p><%: Course.Language %> &bull; <%= Pending %> pending submissions</p>
        </div>
        <span class="badge badge--warning"><%= Pending %> pending</span>
        <i class="code-symbol code-symbol--one">{ }</i>
        <i class="code-symbol code-symbol--two">01</i>
    </div>

    <% if (Assessments.Count == 0) { %>
    <article class="chapter-detail-card">
        <p class="summary-empty">This course has no exam, quiz or assessment to grade yet. Add a quiz or assessment in Manage Chapters, or create the exam in Exams.</p>
        <div class="chapter-detail-actions">
            <a class="button button--ghost" href="TeacherGrading.aspx"><span>Back to courses</span></a>
        </div>
    </article>
    <% } else { %>
    <%-- Choosing an assessment / learner and the live total run client-side (data-tp-grade-*);
         the choices are posted in hfTeacherGradeAssessment (the assessment's Key, e.g. "quiz:3") and
         hfTeacherGradeLearner (the submission's Id). Every submission of the course is rendered with data-test = the Key of what it
         submits, and TeacherPortal.js only lists the ones of the chosen exam / quiz / assessment. --%>
    <div data-tp-grading>
        <input type="hidden" id="hfTeacherGradeAssessment" runat="server" data-tp-grade-assessment />
        <input type="hidden" id="hfTeacherGradeLearner" runat="server" value="" data-tp-grade-learner />

        <section class="flow-section grading-flow-section">
            <uc:StepHeading runat="server" Step="1" Title="Select exam / quiz / assessment" Subtitle="Choose the exam, quiz or chapter assessment submission you want to mark." />
            <div class="assessment-select-layout">
                <div class="assessment-groups">
                    <% foreach (string type in Types) { if (!Assessments.Any(a => a.Type == type)) continue; %>
                    <div class="assessment-group">
                        <div class="assessment-group-heading">
                            <span class="assessment-type-icon <%= TypeClass(type) %>"><%= TeacherIcons.Svg(TypeIcon(type), 17) %></span>
                            <div>
                                <h3><%= type %></h3>
                                <span><%= Assessments.Count(a => a.Type == type) %> available</span>
                            </div>
                        </div>
                        <div class="assessment-tiles">
                            <% foreach (TeacherAssessment a in Assessments.Where(x => x.Type == type)) { bool sel = a.Key == SelectedAssessment.Key; %>
                            <button type="button" class="assessment-tile<%= sel ? " is-selected" : "" %>" data-tp-assessment
                                data-key="<%= a.Key %>" data-title="<%: a.Title %>" data-pending="<%= a.Pending %>" data-questions="<%= a.Questions %>" data-marks="<%= a.TotalMarks %>">
                                <span class="assessment-type-icon <%= TypeClass(type) %>"><%= TeacherIcons.Svg(TypeIcon(type), 18) %></span>
                                <span>
                                    <strong><%: a.Title %></strong>
                                    <small><%= Questions(a.Questions) %></small>
                                </span>
                                <span class="badge badge--<%= a.Pending > 0 ? "warning" : "success" %>"><%= a.Pending %> pending</span>
                                <span class="selected-check" data-tp-tile-check<%= sel ? "" : " hidden" %>><%= TeacherIcons.Svg("check", 13) %></span>
                            </button>
                            <% } %>
                        </div>
                    </div>
                    <% } %>
                </div>
                <aside class="selected-assessment-summary">
                    <span>SELECTED ASSESSMENT</span>
                    <span class="summary-assessment-icon" data-tp-sum-icon><%= TeacherIcons.Svg(TypeIcon(SelectedAssessment.Type), 21) %></span>
                    <h3 data-tp-sum-title><%: SelectedAssessment.Title %></h3>
                    <p data-tp-sum-text><%= Questions(SelectedAssessment.Questions) %> &middot; <%= SelectedAssessment.TotalMarks %> total marks</p>
                    <span class="badge badge--warning" data-tp-sum-badge><%= SelectedAssessment.Pending %> pending</span>
                </aside>
            </div>
        </section>

        <section class="flow-section grading-flow-section learner-step">
            <uc:StepHeading runat="server" Step="2" Title="Select learner" Subtitle="Select a submitted learner assessment to review." />
            <div class="submission-select" data-tp-submission-select>
                <button type="button" class="submission-select-trigger" aria-expanded="false" data-tp-submission-trigger></button>
                <span hidden data-tp-down-icon><%= TeacherIcons.Svg("down", 16) %></span>
                <div class="submission-menu" data-tp-submission-menu hidden>
                    <% for (int i = 0; i < Submissions.Count; i++) { TeacherSubmission s = Submissions[i]; bool first = SelectedSubmission != null && s.Id == SelectedSubmission.Id; %>
                    <button type="button" class="<%= first ? "is-selected" : "" %>" data-tp-submission="<%= s.Id %>" data-test="<%= s.TestKey %>"
                        data-initials="<%: s.Initials %>" data-tone="<%= s.Tone %>" data-name="<%: s.Name %>" data-email="<%: s.Email %>"
                        data-status="<%: s.Status %>" data-submitted="<%: s.Submitted %>">
                        <span class="avatar avatar--<%= s.Tone %> avatar--sm" aria-hidden="true"><%: s.Initials %></span>
                        <span>
                            <strong><%: s.Name %></strong>
                            <small><%: s.Email %></small>
                        </span>
                        <span class="submission-status <%= StatusClass(s.Status) %>"><%: s.Status %></span>
                        <span data-tp-submission-check<%= first ? "" : " hidden" %>><%= TeacherIcons.Svg("check", 15) %></span>
                    </button>
                    <% } %>
                </div>
            </div>
        </section>

        <section class="flow-section grading-flow-section" data-tp-needs-submission>
            <div class="step-heading">
                <span class="step-number">3</span>
                <div>
                    <h2>Mark assessment</h2>
                    <p data-tp-grade-subtitle></p>
                </div>
            </div>
            <div class="marking-panel">
                <div class="marking-panel-header">
                    <div>
                        <span class="avatar avatar--sm" aria-hidden="true" data-tp-panel-avatar></span>
                        <span>
                            <strong data-tp-panel-name></strong>
                            <small data-tp-panel-submitted></small>
                        </span>
                    </div>
                    <span>Showing 2 of <span data-tp-grade-qcount><%= SelectedAssessment.Questions %></span> questions</span>
                </div>
                <div class="marking-questions-scroll">
                    <%-- TODO (backend): the learner's real answers; these two questions are the prototype's sample --%>
                    <article class="marking-question">
                        <div class="marking-question-heading">
                            <span class="question-number">Q1</span>
                            <div>
                                <span>MULTIPLE CHOICE &middot; 5 MARKS</span>
                                <h3>Who developed the C programming language?</h3>
                            </div>
                            <span class="badge badge--danger">Incorrect</span>
                        </div>
                        <div class="grading-options">
                            <div class="grading-option is-neutral"><span>A</span><strong>James Gosling</strong></div>
                            <div class="grading-option is-correct"><span>B</span><strong>Dennis Ritchie</strong><span class="option-result"><%= TeacherIcons.Svg("check", 14) %>Correct answer</span></div>
                            <div class="grading-option is-wrong"><span>C</span><strong>Bjarne Stroustrup</strong><span class="option-result"><%= TeacherIcons.Svg("x", 14) %>Learner's choice</span></div>
                            <div class="grading-option is-neutral"><span>D</span><strong>Guido van Rossum</strong></div>
                        </div>
                        <div class="auto-score"><%= TeacherIcons.Svg("info", 14) %>Automatically scored &middot; 0 / 5 marks</div>
                    </article>

                    <article class="marking-question">
                        <div class="marking-question-heading">
                            <span class="question-number">Q2</span>
                            <div>
                                <span>SUBJECTIVE &middot; 5 MARKS</span>
                                <h3>Explain why pointers are useful when working with functions in C.</h3>
                            </div>
                            <span class="badge badge--warning">Manual grading</span>
                        </div>
                        <div class="learner-answer-block">
                            <span>LEARNER'S ANSWER</span>
                            <blockquote>Pointers let a function access and change the original value in memory instead of only receiving a copy. They are also useful for passing arrays and larger data structures efficiently.</blockquote>
                        </div>
                        <div class="manual-grading-fields">
                            <div class="marks-given-field">
                                <span>Marks given</span>
                                <div class="large-stepper" data-tp-stepper data-min="0" data-max="5">
                                    <button type="button" aria-label="Decrease marks" data-tp-step="-1">&minus;</button>
                                    <strong contenteditable="true" role="spinbutton" inputmode="numeric" spellcheck="false" data-tp-step-value aria-label="Marks given">0</strong>
                                    <span>/5</span>
                                    <button type="button" aria-label="Increase marks" data-tp-step="1">+</button>
                                    <input type="hidden" id="hfTeacherMarksQ2" runat="server" value="0" data-tp-step-input data-tp-grade-marks />
                                </div>
                            </div>
                            <label class="form-field">
                                <span>Comment</span>
                                <asp:TextBox ID="txtTeacherCommentQ2" runat="server" ValidateRequestMode="Disabled" TextMode="MultiLine" Rows="3" placeholder="Add feedback for the learner..."></asp:TextBox>
                            </label>
                        </div>
                    </article>
                </div>
            </div>
        </section>

        <div class="grading-sticky-footer" data-tp-needs-submission>
            <div class="grading-total">
                <div>
                    <span>Total</span>
                    <strong data-tp-grade-total>0 / 100</strong>
                </div>
                <div class="grading-progress-track"><span data-tp-grade-bar style="width: 0%"></span></div>
            </div>
            <div>
                <a class="button button--ghost" href="TeacherGrading.aspx"><span>Back</span></a>
                <asp:LinkButton ID="btnTeacherSaveGrading" runat="server" CssClass="button button--secondary" OnClick="btnTeacherSaveGrading_Click"><svg aria-hidden="true" class="icon" fill="none" height="17" viewBox="0 0 24 24" width="17"><path d='M12 3v12m-5-5 5 5 5-5M5 21h14' /></svg><span>Save progress</span></asp:LinkButton>
                <button type="button" class="button button--primary" data-tp-open-modal="tpConfirmGradeModal"><%= TeacherIcons.Svg("check", 17) %><span>Confirm grade</span></button>
            </div>
        </div>
    </div>
    <% } %>
</asp:Content>

<asp:Content ID="ContentModals" ContentPlaceHolderID="cphModals" runat="server">
    <uc:ConfirmModal ID="mdlTeacherConfirmGrade" runat="server" ModalId="tpConfirmGradeModal" TitleText="Confirm grade?"
        IconName="grade" IconCssClass="modal-success-icon" ExtraCssClass="confirm-grade-modal"
        CancelText="Continue marking" ConfirmText="Confirm grade" ConfirmIcon="check" ConfirmVariant="primary"
        OnConfirmed="mdlTeacherConfirmGrade_Confirmed" />
</asp:Content>
