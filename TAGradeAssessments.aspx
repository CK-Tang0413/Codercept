<%@ Page Title="Grade Course Assessments - Codercept" Language="C#" MasterPageFile="~/TASite.master" AutoEventWireup="true" CodeBehind="TAGradeAssessments.aspx.cs" Inherits="Codercept.TAGradeAssessments" %>
<%@ MasterType VirtualPath="~/TASite.master" %>
<%@ Import Namespace="System.Linq" %>
<%@ Register Src="~/TeacherStepHeading.ascx" TagPrefix="uc" TagName="StepHeading" %>
<%@ Register Src="~/TeacherConfirmModal.ascx" TagPrefix="uc" TagName="ConfirmModal" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <div class="exam-course-banner course-thumbnail--<%= Course.Theme %>">
        <span class="exam-banner-glyph"><%: Course.Glyph %></span>
        <div>
            <span>PROVISIONAL GRADING FOR</span>
            <h1><%: Course.Title %></h1>
            <p><%: Course.Language %> &bull; <%= Pending %> pending submissions</p>
        </div>
        <span class="badge badge--warning"><%= Pending %> pending</span>
        <i class="code-symbol code-symbol--one">{ }</i>
        <i class="code-symbol code-symbol--two">01</i>
    </div>

    <% if (Assessments.Count == 0) { %>
    <article class="chapter-detail-card">
        <p class="summary-empty">This course has no exam, quiz or assessment to grade yet.</p>
        <div class="chapter-detail-actions">
            <a class="button button--ghost" href="TAGrading.aspx"><span>Back to courses</span></a>
        </div>
    </article>
    <% } else { %>
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
                    <span data-tp-grade-qcount><%= Questions(SelectedAssessment.Questions) %></span>
                </div>
                <div class="marking-questions-scroll">
                    <% foreach (TeacherSubmission s in Submissions) { foreach (TeacherMarkingQuestion q in Sheets[s.Id]) { %>
                    <% if (q.IsAuto) { %>
                    <article class="marking-question" data-tp-marking="<%= s.Id %>" data-tp-auto-marks="<%= q.AutoScore %>"<%= s.Status == "Graded" ? " inert" : "" %> hidden>
                        <div class="marking-question-heading">
                            <span class="question-number">Q<%= q.Number %></span>
                            <div>
                                <span>MULTIPLE CHOICE &middot; <%= Marks(q.Marks) %></span>
                                <h3><%: q.Text %></h3>
                            </div>
                            <% if (!q.Options.Any(o => o.Chosen)) { %><span class="badge badge--danger">No answer</span>
                            <% } else if (q.McqCorrect) { %><span class="badge badge--success">Correct</span>
                            <% } else { %><span class="badge badge--danger">Incorrect</span><% } %>
                        </div>
                        <div class="grading-options">
                            <% for (int i = 0; i < q.Options.Count; i++) { TeacherMarkingOption o = q.Options[i]; %>
                            <div class="grading-option <%= o.Correct ? "is-correct" : o.Chosen ? "is-wrong" : "is-neutral" %>"><span><%= (char)('A' + i) %></span><strong><%: o.Text %></strong><% if (o.Correct) { %><span class="option-result"><%= TeacherIcons.Svg("check", 14) %>Correct answer<%= o.Chosen ? " &middot; Learner's choice" : "" %></span><% } else if (o.Chosen) { %><span class="option-result"><%= TeacherIcons.Svg("x", 14) %>Learner's choice</span><% } %></div>
                            <% } %>
                        </div>
                        <div class="auto-score"><%= TeacherIcons.Svg("info", 14) %>Automatically scored &middot; <%= q.AutoScore %> / <%= q.Marks %> marks</div>
                    </article>
                    <% } else { bool code = q.Type == "Coding"; %>
                    <article class="marking-question" data-tp-marking="<%= s.Id %>"<%= s.Status == "Graded" ? " inert" : "" %> hidden>
                        <div class="marking-question-heading">
                            <span class="question-number">Q<%= q.Number %></span>
                            <div>
                                <span><%= code ? "CODING" : "FILL IN THE BLANK" %> &middot; <%= Marks(q.Marks) %></span>
                                <h3><%: q.Text %></h3>
                            </div>
                            <span class="badge badge--warning">Manual grading</span>
                        </div>
                        <div class="learner-answer-block">
                            <span>LEARNER'S ANSWER</span>
                            <% if (q.Answered && q.Answer.Trim().Length > 0) { %><blockquote<%= code ? " class=\"is-code\"" : "" %>><%: q.Answer %></blockquote>
                            <% } else { %><blockquote>No answer given.</blockquote><% } %>
                        </div>
                        <% if (!code && q.AcceptedAnswers.Trim().Length > 0) { %>
                        <div class="learner-answer-block">
                            <span>ACCEPTED ANSWERS</span>
                            <blockquote><%: q.AcceptedAnswers %></blockquote>
                        </div>
                        <% } %>
                        <% if (code && q.ModelAnswer.Trim().Length > 0) { %>
                        <div class="learner-answer-block">
                            <span>MODEL ANSWER</span>
                            <blockquote class="is-code"><%: q.ModelAnswer %></blockquote>
                        </div>
                        <% } %>
                        <% if (code && q.MarkingGuide.Trim().Length > 0) { %>
                        <div class="learner-answer-block">
                            <span>MARKING GUIDE</span>
                            <blockquote><%: q.MarkingGuide %></blockquote>
                        </div>
                        <% } %>
                        <div class="manual-grading-fields">
                            <div class="marks-given-field">
                                <span>Marks given</span>
                                <div class="large-stepper" data-tp-stepper data-min="0" data-max="<%= q.Marks %>">
                                    <button type="button" aria-label="Decrease marks" data-tp-step="-1">&minus;</button>
                                    <strong contenteditable="true" role="spinbutton" inputmode="numeric" spellcheck="false" data-tp-step-value aria-label="Marks given"><%= q.Given %></strong>
                                    <span>/<%= q.Marks %></span>
                                    <button type="button" aria-label="Increase marks" data-tp-step="1">+</button>
                                    <input type="hidden" name="tpm_<%= s.Id %>_<%= q.Id %>" value="<%= q.Given %>" data-tp-step-input data-tp-grade-marks />
                                </div>
                            </div>
                            <label class="form-field">
                                <span>Comment</span>
                                <textarea name="tpc_<%= s.Id %>_<%= q.Id %>" rows="3" placeholder="Add feedback for the learner..."><%: q.Comment %></textarea>
                            </label>
                        </div>
                    </article>
                    <% } } } %>
                </div>
            </div>
        </section>

        <div class="grading-sticky-footer" data-tp-needs-submission>
            <div class="grading-total">
                <div>
                    <span>Total</span>
                    <strong data-tp-grade-total>0 / <%= SelectedAssessment.TotalMarks %></strong>
                </div>
                <div class="grading-progress-track"><span data-tp-grade-bar style="width: 0%"></span></div>
            </div>
            <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
                <span id="taGradingStatusNotice" style="display: none; padding: 6px 14px; border-radius: 9999px; font-size: 12px; font-weight: 700; align-items: center; gap: 6px;"></span>
                <a class="button button--ghost" href="TAGrading.aspx"><span>Back</span></a>
                <asp:LinkButton ID="btnTASaveGrading" runat="server" CssClass="button button--secondary" OnClick="btnTASaveGrading_Click"><svg aria-hidden="true" class="icon" fill="none" height="17" viewBox="0 0 24 24" width="17"><path d='M12 3v12m-5-5 5 5 5-5M5 21h14' /></svg><span>Save progress</span></asp:LinkButton>
                <button id="btnOpenTAConfirmModal" type="button" class="button button--primary" data-tp-open-modal="tpConfirmGradeModal"><%= TeacherIcons.Svg("check", 17) %><span>Submit Review</span></button>
            </div>
        </div>
    </div>
    <% } %>

    <script>
        (function () {
            function updateTAControls() {
                var learnerInput = document.querySelector('[data-tp-grade-learner]');
                if (!learnerInput) return;
                var subId = learnerInput.value;
                var opt = document.querySelector('[data-tp-submission="' + subId + '"]');
                var status = opt ? opt.getAttribute('data-status') : '';
                var notice = document.getElementById('taGradingStatusNotice');
                var btnSave = document.getElementById('<%= btnTASaveGrading.ClientID %>');
                var btnSubmit = document.getElementById('btnOpenTAConfirmModal');

                var isReviewed = (status === 'Reviewed');
                var isGraded = (status === 'Graded');
                var isLocked = isReviewed || isGraded;

                if (notice) {
                    if (isReviewed) {
                        notice.style.display = 'inline-flex';
                        notice.className = 'badge badge--indigo';
                        notice.textContent = 'Provisional Review Submitted — Awaiting Approval';
                    } else if (isGraded) {
                        notice.style.display = 'inline-flex';
                        notice.className = 'badge badge--success';
                        notice.textContent = 'Officially Graded by Teacher';
                    } else {
                        notice.style.display = 'none';
                    }
                }

                if (btnSave) btnSave.style.display = isLocked ? 'none' : '';
                if (btnSubmit) btnSubmit.style.display = isLocked ? 'none' : '';

                document.querySelectorAll('[data-tp-marking="' + subId + '"]').forEach(function (card) {
                    var inputs = card.querySelectorAll('input, textarea, button[data-tp-step]');
                    inputs.forEach(function (el) {
                        if (isLocked) {
                            el.setAttribute('disabled', 'disabled');
                        } else {
                            el.removeAttribute('disabled');
                        }
                    });
                });
            }

            document.addEventListener('DOMContentLoaded', updateTAControls);
            document.addEventListener('click', function (e) {
                if (e.target.closest('[data-tp-submission]') || e.target.closest('[data-tp-assessment]')) {
                    setTimeout(updateTAControls, 50);
                }
            });
            window.addEventListener('load', function () {
                setTimeout(updateTAControls, 100);
            });
        })();
    </script>
</asp:Content>

<asp:Content ID="ContentModals" ContentPlaceHolderID="cphModals" runat="server">
    <uc:ConfirmModal ID="mdlTAConfirmGrade" runat="server" ModalId="tpConfirmGradeModal" TitleText="Submit Provisional Review?"
        IconName="grade" IconCssClass="modal-success-icon" ExtraCssClass="confirm-grade-modal"
        CancelText="Continue marking" ConfirmText="Submit Review" ConfirmIcon="check" ConfirmVariant="primary"
        OnConfirmed="mdlTAConfirmGrade_Confirmed" />
</asp:Content>
