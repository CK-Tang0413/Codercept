<%@ Page Title="Provisional Grading - Codercept" Language="C#" AutoEventWireup="true" CodeBehind="TAGrading.aspx.cs" Inherits="Codercept.TAGrading" MasterPageFile="~/TASite.master" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        :root {
            --panel-bg: var(--bg-surface);
            --warn: #fbbf24;
            --danger: #ef4444;
            --success: #34d399;
            --input-bg: var(--bg-main);
        }

        /* Override main-content for a fixed split-screen layout */
        .main-content { display: flex; flex-direction: column; overflow: hidden; padding-bottom: 0; }

        .page-header { margin-bottom: 1.25rem; }
        .page-header h1 { font-size: 1.75rem; margin-bottom: 0.25rem; color: var(--text-primary); }
        .page-header p { color: var(--text-secondary); font-size: 1rem; }

        .grading-container { display: flex; flex: 1; gap: 1.5rem; overflow: hidden; padding-bottom: 2rem; }

        /* LEFT: submissions list */
        .queue-column { width: 330px; flex-shrink: 0; display: flex; flex-direction: column; background: var(--panel-bg); border: 1px solid var(--border-light); border-radius: 16px; overflow: hidden; }
        .queue-toolbar { display: flex; flex-direction: column; gap: 0.75rem; padding: 1rem 1.1rem; border-bottom: 1px solid var(--border-light); }
        .search-input { width: 100%; background: var(--input-bg); border: 1px solid var(--border-light); border-radius: 10px; padding: 0.65rem 0.9rem; color: var(--text-primary); font-size: 0.9rem; outline: none; transition: border-color 0.2s; }
        .search-input:focus { border-color: var(--accent-primary); }
        .filter-dropdown { position: relative; }
        .filter-button { width: 100%; display: flex; align-items: center; justify-content: space-between; gap: 0.5rem; padding: 0.65rem 0.9rem; border-radius: 10px; border: 1px solid var(--border-light); background: rgba(255, 255, 255, 0.04); color: var(--text-primary); font-size: 0.9rem; font-weight: 600; cursor: pointer; transition: border-color 0.2s; }
        .filter-button:hover, .filter-dropdown.open .filter-button { border-color: var(--accent-primary); }
        .filter-button .chev { transition: transform 0.2s; }
        .filter-dropdown.open .chev { transform: rotate(180deg); }
        .filter-menu { display: none; position: absolute; top: calc(100% + 0.35rem); left: 0; right: 0; z-index: 20; background: #1b1530; border: 1px solid var(--border-light); border-radius: 10px; padding: 0.35rem; box-shadow: 0 12px 32px rgba(0, 0, 0, 0.5); }
        .filter-dropdown.open .filter-menu { display: block; }
        .filter-option { display: flex; justify-content: space-between; align-items: center; padding: 0.6rem 0.75rem; border-radius: 8px; font-size: 0.9rem; font-weight: 500; color: var(--text-secondary); text-decoration: none; }
        .filter-option:hover { background: var(--accent-transparent); color: var(--accent-light); }
        .filter-option.active { background: var(--accent-primary); color: var(--text-primary); }
        .filter-count { font-weight: 700; opacity: 0.85; }

        .queue-list { flex: 1; overflow-y: auto; display: flex; flex-direction: column; gap: 0.6rem; padding: 1rem 0.9rem 1.25rem 1.1rem; }
        .queue-item { display: block; flex-shrink: 0; padding: 1rem 1.1rem; border: 1px solid var(--border-light); border-radius: 12px; text-decoration: none; transition: background 0.2s, border-color 0.2s; }
        .queue-item:hover { background: rgba(255, 255, 255, 0.03); border-color: rgba(124, 58, 237, 0.35); }
        .queue-item.selected { background: var(--accent-transparent); border-color: var(--accent-primary); }
        .queue-item-top { display: flex; justify-content: space-between; align-items: center; gap: 0.75rem; margin-bottom: 0.6rem; }
        .queue-learner { font-weight: 600; color: var(--text-primary); font-size: 1rem; }
        .queue-title { font-size: 0.9rem; line-height: 1.4; color: var(--text-secondary); margin-bottom: 0.45rem; overflow-wrap: anywhere; }
        .queue-meta { font-size: 0.8rem; color: var(--text-muted); }

        .type-badge { font-size: 0.7rem; font-weight: 600; padding: 0.15rem 0.5rem; border-radius: 4px; background: var(--accent-transparent); color: var(--accent-light); border: 1px solid rgba(124, 58, 237, 0.3); margin-right: 0.5rem; }
        .status-badge { font-size: 0.75rem; font-weight: 600; padding: 0.2rem 0.65rem; border-radius: 999px; white-space: nowrap; }
        .status-pending { color: var(--warn); background: rgba(251, 191, 36, 0.1); }
        .status-inprogress { color: var(--accent-light); background: var(--accent-transparent); }
        .status-reviewed { color: #60a5fa; background: rgba(96, 165, 250, 0.1); }
        .status-approved { color: var(--success); background: rgba(52, 211, 153, 0.1); }

        .empty-state { color: var(--text-muted); font-size: 0.9rem; padding: 2rem 1rem; text-align: center; }

        /* RIGHT: grading panel */
        .grading-column { flex: 1; display: flex; flex-direction: column; background: var(--panel-bg); border: 1px solid var(--border-light); border-radius: 12px; overflow: hidden; min-width: 0; }
        .grading-header { padding: 1.5rem 1.75rem; border-bottom: 1px solid var(--border-light); background: rgba(255, 255, 255, 0.02); }
        .grading-header-row { display: flex; justify-content: space-between; align-items: flex-start; gap: 1.5rem; }
        .course-ref { flex-shrink: 0; text-align: right; font-size: 0.8rem; color: var(--text-muted); }
        .course-ref strong { display: block; color: var(--text-primary); font-size: 0.9rem; margin: 0.15rem 0 0.5rem; }
        .btn-course { display: inline-block; padding: 0.4rem 0.9rem; border-radius: 6px; border: 1px solid rgba(124, 58, 237, 0.4); color: var(--accent-light); font-size: 0.8rem; font-weight: 600; text-decoration: none; transition: all 0.2s; }
        .btn-course:hover { background: var(--accent-transparent); color: var(--accent-hover); }
        .grading-header h2 { font-size: 1.25rem; color: var(--text-primary); margin-bottom: 0.35rem; }
        .grading-header-meta { display: flex; flex-wrap: wrap; gap: 0.5rem 1.25rem; font-size: 0.85rem; color: var(--text-secondary); }
        .grading-header-meta strong { color: var(--text-primary); font-weight: 600; }

        .grading-body { flex: 1; overflow-y: auto; padding: 1.75rem; display: flex; flex-direction: column; gap: 1.5rem; }

        .question-card { border: 1px solid var(--border-light); border-radius: 12px; padding: 1.5rem; background: rgba(255, 255, 255, 0.02); }
        .question-top { display: flex; justify-content: space-between; align-items: flex-start; gap: 1rem; margin-bottom: 0.75rem; }
        .question-text { font-weight: 600; color: var(--text-primary); font-size: 0.95rem; line-height: 1.5; }
        .question-text span { color: var(--accent-light); margin-right: 0.35rem; }
        .q-type { font-size: 0.7rem; font-weight: 600; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.04em; white-space: nowrap; }

        .answer-label { font-size: 0.75rem; font-weight: 600; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.04em; margin-bottom: 0.4rem; }
        .answer-text { background: var(--input-bg); border: 1px solid var(--border-light); border-radius: 8px; padding: 0.875rem 1rem; color: var(--text-secondary); font-size: 0.9rem; line-height: 1.6; margin-bottom: 1rem; white-space: pre-wrap; }

        .score-row.is-auto { display: none; }
        .auto-result { color: var(--success); }
        .score-row { display: flex; gap: 1rem; align-items: flex-start; }
        .score-box { display: flex; align-items: center; gap: 0.5rem; flex-shrink: 0; }
        .score-box label { font-size: 0.8rem; font-weight: 600; color: var(--text-secondary); }
        .score-input { width: 72px; background: var(--input-bg); border: 1px solid var(--border-light); border-radius: 8px; padding: 0.6rem 0.5rem; color: var(--text-primary); font-size: 0.95rem; text-align: center; outline: none; transition: border-color 0.2s; }
        .score-input:focus { border-color: var(--accent-primary); }
        .score-input[readonly] { background: rgba(255, 255, 255, 0.02); color: var(--text-muted); cursor: not-allowed; }
        .score-max { font-size: 0.9rem; color: var(--text-muted); }
        .auto-note { font-size: 0.75rem; color: var(--text-muted); margin-top: 0.35rem; }

        .form-control { width: 100%; background: var(--input-bg); border: 1px solid var(--border-light); border-radius: 8px; padding: 0.7rem 0.9rem; color: var(--text-primary); font-size: 0.9rem; outline: none; transition: border-color 0.2s; resize: vertical; }
        .form-control:focus { border-color: var(--accent-primary); }
        .comment-box { flex: 1; }

        .overall-card { border: 1px solid var(--greeting-border, rgba(124, 58, 237, 0.2)); border-radius: 10px; padding: 1.25rem; background: rgba(30, 22, 51, 0.6); }
        .overall-card h3 { font-size: 1rem; color: var(--text-primary); margin-bottom: 0.75rem; }

        /* Sticky footer bar */
        .grading-footer { display: flex; justify-content: space-between; align-items: center; gap: 1rem; padding: 1rem 1.5rem; border-top: 1px solid var(--border-light); background: rgba(255, 255, 255, 0.02); }
        .total-score { font-size: 0.95rem; color: var(--text-secondary); }
        .total-score strong { font-size: 1.35rem; color: var(--text-primary); }
        .footer-actions { display: flex; gap: 0.75rem; }
        .btn { padding: 0.65rem 1.25rem; border-radius: 8px; font-weight: 600; font-size: 0.9rem; cursor: pointer; transition: all 0.2s; border: none; }
        .btn-secondary { background: rgba(255, 255, 255, 0.05); color: var(--text-secondary); }
        .btn-secondary:hover { background: rgba(255, 255, 255, 0.1); color: var(--text-primary); }
        .btn-primary { background: var(--accent-primary); color: #ffffff; }
        .btn-primary:hover { background: var(--accent-hover); }

        .review-state { display: inline-flex; align-items: center; gap: 0.5rem; padding: 0.6rem 1.1rem; border-radius: 999px; font-size: 0.9rem; font-weight: 600; }
        .review-state::before { content: ""; width: 8px; height: 8px; border-radius: 50%; background: currentColor; }
        .state-reviewed { color: #60a5fa; background: rgba(96, 165, 250, 0.12); border: 1px solid rgba(96, 165, 250, 0.35); }
        .state-approved { color: var(--success); background: rgba(52, 211, 153, 0.12); border: 1px solid rgba(52, 211, 153, 0.35); }

        .toast.toast-error { color: var(--danger); background: rgba(239, 68, 68, 0.1); border-color: rgba(239, 68, 68, 0.3); }
        .toast { margin: 1rem 1.5rem 0; padding: 0.75rem 1rem; border-radius: 8px; font-size: 0.9rem; color: var(--success); background: rgba(52, 211, 153, 0.1); border: 1px solid rgba(52, 211, 153, 0.3); }

        @media (max-width: 1100px) {
            .main-content { overflow-y: auto; }
            .grading-container { flex-direction: column; overflow: visible; }
            .queue-column { width: 100%; max-height: 460px; }
        }
    </style>
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">

        <div class="page-header">
            <h1>Provisional Grading</h1>
            <p>Mark learner submissions and give each answer a score. The teacher reviews your marks and approves the final grade.</p>
        </div>

        <div class="grading-container">

            <!-- LEFT: Submission list -->
            <section class="queue-column">
                <div class="queue-toolbar">
                    <input type="search" id="queueSearch" class="search-input" placeholder="Search learner, title or course" autocomplete="off" />
                    <div class="filter-dropdown" id="filterDropdown">
                        <button type="button" class="filter-button" id="filterButton" aria-haspopup="true" aria-expanded="false">
                            <span><asp:Literal ID="litFilterLabel" runat="server"></asp:Literal></span>
                            <svg class="chev" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9l6 6 6-6" /></svg>
                        </button>
                        <div class="filter-menu">
                            <a href="TAGrading.aspx?filter=all" class="filter-option <%= GetTabClass("all") %>">All submissions<span class="filter-count"><asp:Literal ID="litCountAll" runat="server"></asp:Literal></span></a>
                            <a href="TAGrading.aspx?filter=pending" class="filter-option <%= GetTabClass("pending") %>">Pending<span class="filter-count"><asp:Literal ID="litCountPending" runat="server"></asp:Literal></span></a>
                            <a href="TAGrading.aspx?filter=reviewed" class="filter-option <%= GetTabClass("reviewed") %>">Reviewed<span class="filter-count"><asp:Literal ID="litCountReviewed" runat="server"></asp:Literal></span></a>
                            <a href="TAGrading.aspx?filter=approved" class="filter-option <%= GetTabClass("approved") %>">Approved<span class="filter-count"><asp:Literal ID="litCountApproved" runat="server"></asp:Literal></span></a>
                        </div>
                    </div>
                </div>

                <div class="queue-list">
                    <asp:PlaceHolder ID="phListEmpty" runat="server" Visible="false">
                        <p class="empty-state">No submissions here yet.</p>
                    </asp:PlaceHolder>
                    <p class="empty-state" id="searchEmpty" style="display:none">No submissions match your search.</p>

                    <asp:Repeater ID="rptSubmissions" runat="server">
                        <ItemTemplate>
                            <a href='TAGrading.aspx?filter=<%= CurrentFilter %>&attempt=<%# Eval("AttemptId") %>' class='queue-item <%# Eval("CssClass") %>'>
                                <div class="queue-item-top">
                                    <span class="queue-learner"><%# Server.HtmlEncode(Convert.ToString(Eval("LearnerName"))) %></span>
                                    <span class='status-badge <%# Eval("StatusCss") %>'><%# Eval("Status") %></span>
                                </div>
                                <div class="queue-title"><span class="type-badge"><%# Eval("Type") %></span><%# Server.HtmlEncode(Convert.ToString(Eval("Title"))) %></div>
                                <div class="queue-meta"><%# Server.HtmlEncode(Convert.ToString(Eval("Course"))) %> &middot; <%# Eval("Submitted") %></div>
                            </a>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </section>

            <!-- RIGHT: Grading panel -->
            <section class="grading-column">

                <asp:PlaceHolder ID="phNoSelection" runat="server" Visible="false">
                    <p class="empty-state">Select a submission from the list to start grading.</p>
                </asp:PlaceHolder>

                <asp:PlaceHolder ID="phGradingPanel" runat="server">
                    <div class="grading-header">
                      <div class="grading-header-row">
                        <div>
                        <h2><asp:Literal ID="litAssessmentTitle" runat="server"></asp:Literal></h2>
                        <div class="grading-header-meta">
                            <span>Learner: <strong><asp:Literal ID="litLearnerName" runat="server"></asp:Literal></strong></span>
                            <span>Course: <strong><asp:Literal ID="litCourseName" runat="server"></asp:Literal></strong></span>
                            <span>Submitted: <strong><asp:Literal ID="litSubmitted" runat="server"></asp:Literal></strong></span>
                            <span>Status: <strong><asp:Literal ID="litStatus" runat="server"></asp:Literal></strong></span>
                        </div>
                        </div>
                        <div class="course-ref">
                            Course reference
                            <strong><asp:Literal ID="litChapterRef" runat="server"></asp:Literal></strong>
                            <asp:HyperLink ID="hlCourse" runat="server" CssClass="btn-course" Text="Open course &rarr;"></asp:HyperLink>
                        </div>
                      </div>
                    </div>

                    <asp:Panel ID="pnlMessage" runat="server" CssClass="toast" Visible="false">
                        <asp:Literal ID="litMessage" runat="server"></asp:Literal>
                    </asp:Panel>

                    <asp:HiddenField ID="hfAttemptId" runat="server" />

                    <div class="grading-body">
                        <asp:Repeater ID="rptQuestions" runat="server" OnItemDataBound="rptQuestions_ItemDataBound">
                            <ItemTemplate>
                                <div class="question-card">
                                    <div class="question-top">
                                        <div class="question-text"><span>Q<%# Eval("Number") %>.</span><%# Server.HtmlEncode(Convert.ToString(Eval("Content"))) %></div>
                                        <div class="q-type"><%# Eval("TypeLabel") %><%# (bool)Eval("AutoGraded") ? " &middot; <span class=\"auto-result\">Auto-graded " + Eval("Score") + " / " + Eval("MaxScore") + "</span>" : "" %></div>
                                    </div>

                                    <asp:HiddenField ID="hfQuestionId" runat="server" Value='<%# Eval("QuestionId") %>' />
                                    <asp:HiddenField ID="hfMaxScore" runat="server" Value='<%# Convert.ToDouble(Eval("MaxScore")).ToString(System.Globalization.CultureInfo.InvariantCulture) %>' />
                                    <div class="answer-label">Learner's Answer</div>
                                    <div class="answer-text"><%# Eval("AnswerHtml") %></div>

                                    <div class='score-row <%# (bool)Eval("AutoGraded") ? "is-auto" : "" %>'>
                                        <div class="score-box">
                                            <label>Marks</label>
                                            <asp:TextBox ID="txtScore" runat="server" CssClass="score-input" TextMode="Number" Text='<%# Eval("Score") %>' ReadOnly='<%# Eval("ScoreLocked") %>'></asp:TextBox>
                                            <span class="score-max">/ <%# Eval("MaxScore") %></span>
                                        </div>
                                        <div class="comment-box">
                                            <asp:TextBox ID="txtComment" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="Comment for this answer (optional)" Text='<%# Eval("Comment") %>' ReadOnly='<%# Eval("Locked") %>'></asp:TextBox>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>

                        <div class="overall-card">
                            <h3>Overall Feedback for Teacher</h3>
                            <asp:TextBox ID="txtOverallFeedback" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="Summarise the learner's strengths and areas to improve. The teacher will see this when reviewing."></asp:TextBox>
                        </div>
                    </div>

                    <div class="grading-footer">
                        <div class="total-score">Total marks: <strong id="totalScore"><asp:Literal ID="litTotalScore" runat="server"></asp:Literal></strong> / <asp:Literal ID="litTotalMax" runat="server"></asp:Literal></div>
                        <div class="footer-actions">
                            <asp:Panel ID="pnlReviewState" runat="server" Visible="false"><asp:Literal ID="litReviewState" runat="server"></asp:Literal></asp:Panel>
                            <asp:Button ID="btnSaveDraft" runat="server" Text="Save Draft" CssClass="btn btn-secondary" OnClick="btnSaveDraft_Click" />
                            <asp:Button ID="btnSubmitGrades" runat="server" Text="Submit Review" CssClass="btn btn-primary" OnClientClick="return confirm('Send this review to the teacher for approval? You will not be able to edit them afterwards.');" OnClick="btnSubmitGrades_Click" />
                        </div>
                    </div>
                </asp:PlaceHolder>

            </section>
        </div>
</asp:Content>

<asp:Content ID="ContentScripts" ContentPlaceHolderID="cphScripts" runat="server">
    <script>
        // Filter dropdown and list search
        (function () {
            var dd = document.getElementById('filterDropdown');
            var btn = document.getElementById('filterButton');
            btn.addEventListener('click', function (e) {
                e.stopPropagation();
                var open = dd.classList.toggle('open');
                btn.setAttribute('aria-expanded', open);
            });
            document.addEventListener('click', function () { dd.classList.remove('open'); btn.setAttribute('aria-expanded', false); });

            var search = document.getElementById('queueSearch');
            var items = document.querySelectorAll('.queue-item');
            var none = document.getElementById('searchEmpty');
            search.addEventListener('input', function () {
                var q = search.value.trim().toLowerCase(), shown = 0;
                items.forEach(function (it) {
                    var hit = it.textContent.toLowerCase().indexOf(q) !== -1;
                    it.style.display = hit ? '' : 'none';
                    if (hit) shown++;
                });
                none.style.display = (q && items.length && !shown) ? '' : 'none';
            });
        })();

        // Live total of all question scores
        (function () {
            var inputs = document.querySelectorAll('.score-input');
            var total = document.getElementById('totalScore');
            if (!total) return;
            function recalc() {
                var sum = 0;
                inputs.forEach(function (i) { sum += parseFloat(i.value) || 0; });
                total.textContent = sum;
            }
            inputs.forEach(function (i) { i.addEventListener('input', recalc); });
            recalc();
        })();
    </script>
</asp:Content>
