<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TAGrading.aspx.cs" Inherits="Codercept.TAGrading" %>
<%@ Register Src="~/TASideBar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Grading Queue - Codercept</title>

    <!-- 1. Import Global Variables & Shared Layout -->
    <link href="css/global.css" rel="stylesheet" type="text/css" />

    <!-- 2. Page-Specific Styles -->
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
        .queue-column { width: 360px; flex-shrink: 0; display: flex; flex-direction: column; background: var(--panel-bg); border: 1px solid var(--border-light); border-radius: 12px; overflow: hidden; }
        .filter-tabs { display: flex; gap: 0.25rem; padding: 0.75rem; border-bottom: 1px solid var(--border-light); background: rgba(255, 255, 255, 0.02); }
        .filter-tab { flex: 1; text-align: center; padding: 0.5rem 0.25rem; border-radius: 6px; font-size: 0.8rem; font-weight: 600; color: var(--text-secondary); text-decoration: none; transition: all 0.2s; }
        .filter-tab:hover { background: var(--accent-transparent); color: var(--accent-light); }
        .filter-tab.active { background: var(--accent-primary); color: var(--text-primary); }
        .filter-count { opacity: 0.7; font-weight: 500; margin-left: 0.2rem; }

        .queue-list { flex: 1; overflow-y: auto; display: flex; flex-direction: column; }
        .queue-item { display: block; padding: 1rem 1.25rem; border-bottom: 1px solid var(--border-light); text-decoration: none; border-left: 3px solid transparent; transition: background 0.2s; }
        .queue-item:hover { background: rgba(255, 255, 255, 0.03); }
        .queue-item.selected { background: var(--accent-transparent); border-left-color: var(--accent-primary); }
        .queue-item-top { display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.35rem; }
        .queue-learner { font-weight: 600; color: var(--text-primary); font-size: 0.95rem; }
        .queue-title { font-size: 0.85rem; color: var(--text-secondary); margin-bottom: 0.2rem; }
        .queue-meta { font-size: 0.75rem; color: var(--text-muted); }

        .type-badge { font-size: 0.7rem; font-weight: 600; padding: 0.15rem 0.5rem; border-radius: 4px; background: var(--accent-transparent); color: var(--accent-light); border: 1px solid rgba(124, 58, 237, 0.3); margin-right: 0.35rem; }
        .status-badge { font-size: 0.7rem; font-weight: 600; padding: 0.15rem 0.5rem; border-radius: 4px; white-space: nowrap; }
        .status-pending { color: var(--warn); background: rgba(251, 191, 36, 0.1); }
        .status-inprogress { color: var(--accent-light); background: var(--accent-transparent); }
        .status-submitted { color: #60a5fa; background: rgba(96, 165, 250, 0.1); }
        .status-approved { color: var(--success); background: rgba(52, 211, 153, 0.1); }
        .status-returned { color: var(--danger); background: rgba(239, 68, 68, 0.1); }

        .empty-state { color: var(--text-muted); font-size: 0.9rem; padding: 2rem 1rem; text-align: center; }

        /* RIGHT: grading panel */
        .grading-column { flex: 1; display: flex; flex-direction: column; background: var(--panel-bg); border: 1px solid var(--border-light); border-radius: 12px; overflow: hidden; min-width: 0; }
        .grading-header { padding: 1.25rem 1.5rem; border-bottom: 1px solid var(--border-light); background: rgba(255, 255, 255, 0.02); }
        .grading-header-row { display: flex; justify-content: space-between; align-items: flex-start; gap: 1.5rem; }
        .course-ref { flex-shrink: 0; text-align: right; font-size: 0.8rem; color: var(--text-muted); }
        .course-ref strong { display: block; color: var(--text-primary); font-size: 0.9rem; margin: 0.15rem 0 0.5rem; }
        .btn-course { display: inline-block; padding: 0.4rem 0.9rem; border-radius: 6px; border: 1px solid rgba(124, 58, 237, 0.4); color: var(--accent-light); font-size: 0.8rem; font-weight: 600; text-decoration: none; transition: all 0.2s; }
        .btn-course:hover { background: var(--accent-transparent); color: var(--accent-hover); }
        .grading-header h2 { font-size: 1.25rem; color: var(--text-primary); margin-bottom: 0.35rem; }
        .grading-header-meta { display: flex; flex-wrap: wrap; gap: 0.5rem 1.25rem; font-size: 0.85rem; color: var(--text-secondary); }
        .grading-header-meta strong { color: var(--text-primary); font-weight: 600; }

        .grading-body { flex: 1; overflow-y: auto; padding: 1.5rem; display: flex; flex-direction: column; gap: 1.25rem; }

        .question-card { border: 1px solid var(--border-light); border-radius: 10px; padding: 1.25rem; background: rgba(255, 255, 255, 0.02); }
        .question-top { display: flex; justify-content: space-between; align-items: flex-start; gap: 1rem; margin-bottom: 0.75rem; }
        .question-text { font-weight: 600; color: var(--text-primary); font-size: 0.95rem; line-height: 1.5; }
        .question-text span { color: var(--accent-light); margin-right: 0.35rem; }
        .q-type { font-size: 0.7rem; font-weight: 600; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.04em; white-space: nowrap; }

        .answer-label { font-size: 0.75rem; font-weight: 600; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.04em; margin-bottom: 0.4rem; }
        .answer-text { background: var(--input-bg); border: 1px solid var(--border-light); border-radius: 8px; padding: 0.875rem 1rem; color: var(--text-secondary); font-size: 0.9rem; line-height: 1.6; margin-bottom: 1rem; }
        pre.answer-text { font-family: Consolas, 'Courier New', monospace; font-size: 0.85rem; color: #e4e4e7; overflow-x: auto; white-space: pre; }

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

        .note-banner { margin: 1rem 1.5rem 0; padding: 0.85rem 1rem; border-radius: 8px; font-size: 0.9rem; line-height: 1.5; }
        .note-returned { color: var(--text-primary); background: rgba(239, 68, 68, 0.08); border: 1px solid rgba(239, 68, 68, 0.3); }
        .note-returned strong { color: var(--danger); }
        .note-locked { color: var(--text-secondary); background: rgba(96, 165, 250, 0.08); border: 1px solid rgba(96, 165, 250, 0.3); }

        .toast { margin: 1rem 1.5rem 0; padding: 0.75rem 1rem; border-radius: 8px; font-size: 0.9rem; color: var(--success); background: rgba(52, 211, 153, 0.1); border: 1px solid rgba(52, 211, 153, 0.3); }

        @media (max-width: 1100px) {
            .main-content { overflow-y: auto; }
            .grading-container { flex-direction: column; overflow: visible; }
            .queue-column { width: 100%; max-height: 360px; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="dashboard-layout">

            <!-- Sidebar Injected Here -->
            <uc:Sidebar runat="server" ID="TASideBarCtrl" />

            <!-- Main Content -->
            <main class="main-content">

                <div class="page-header">
                    <h1>Grading Queue</h1>
                    <p>Mark learner submissions and suggest scores. The teacher reviews and approves the final grade.</p>
                </div>

                <div class="grading-container">

                    <!-- LEFT: Submission list -->
                    <section class="queue-column">
                        <div class="filter-tabs">
                            <a href="TAGrading.aspx?filter=all" class="filter-tab <%= GetTabClass("all") %>">All<span class="filter-count"><asp:Literal ID="litCountAll" runat="server"></asp:Literal></span></a>
                            <a href="TAGrading.aspx?filter=todo" class="filter-tab <%= GetTabClass("todo") %>">To Do<span class="filter-count"><asp:Literal ID="litCountTodo" runat="server"></asp:Literal></span></a>
                            <a href="TAGrading.aspx?filter=submitted" class="filter-tab <%= GetTabClass("submitted") %>">Submitted<span class="filter-count"><asp:Literal ID="litCountSubmitted" runat="server"></asp:Literal></span></a>
                            <a href="TAGrading.aspx?filter=approved" class="filter-tab <%= GetTabClass("approved") %>">Approved<span class="filter-count"><asp:Literal ID="litCountApproved" runat="server"></asp:Literal></span></a>
                        </div>

                        <div class="queue-list">
                            <asp:PlaceHolder ID="phListEmpty" runat="server" Visible="false">
                                <p class="empty-state">No submissions in this category.</p>
                            </asp:PlaceHolder>

                            <asp:Repeater ID="rptSubmissions" runat="server">
                                <ItemTemplate>
                                    <a href='TAGrading.aspx?filter=<%= CurrentFilter %>&attempt=<%# Eval("AttemptId") %>' class='queue-item <%# Eval("CssClass") %>'>
                                        <div class="queue-item-top">
                                            <span class="queue-learner"><%# Eval("LearnerName") %></span>
                                            <span class='status-badge <%# Eval("StatusCss") %>'><%# Eval("Status") %></span>
                                        </div>
                                        <div class="queue-title"><span class="type-badge"><%# Eval("Type") %></span><%# Eval("Title") %></div>
                                        <div class="queue-meta"><%# Eval("Course") %> &middot; <%# Eval("Submitted") %></div>
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

                            <asp:Panel ID="pnlTeacherNote" runat="server" CssClass="note-banner note-returned" Visible="false">
                                <strong>Returned by teacher:</strong> <asp:Literal ID="litTeacherNote" runat="server"></asp:Literal>
                            </asp:Panel>

                            <asp:Panel ID="pnlLocked" runat="server" CssClass="note-banner note-locked" Visible="false">
                                <asp:Literal ID="litLockedText" runat="server"></asp:Literal>
                            </asp:Panel>

                            <asp:Panel ID="pnlMessage" runat="server" CssClass="toast" Visible="false">
                                <asp:Literal ID="litMessage" runat="server"></asp:Literal>
                            </asp:Panel>

                            <div class="grading-body">
                                <asp:Repeater ID="rptQuestions" runat="server">
                                    <ItemTemplate>
                                        <div class="question-card">
                                            <div class="question-top">
                                                <div class="question-text"><span>Q<%# Eval("Number") %>.</span><%# Eval("Content") %></div>
                                                <div class="q-type"><%# Eval("TypeLabel") %></div>
                                            </div>

                                            <div class="answer-label">Learner's Answer</div>
                                            <pre class="answer-text" runat="server" visible='<%# Eval("IsCode") %>'><%# Server.HtmlEncode(Convert.ToString(Eval("Answer"))) %></pre>
                                            <div class="answer-text" runat="server" visible='<%# !(bool)Eval("IsCode") %>'><%# Server.HtmlEncode(Convert.ToString(Eval("Answer"))) %></div>

                                            <div class="score-row">
                                                <div class="score-box">
                                                    <label>Suggested</label>
                                                    <asp:TextBox ID="txtScore" runat="server" CssClass="score-input" TextMode="Number" Text='<%# Eval("Score") %>' ReadOnly='<%# Eval("ScoreLocked") %>'></asp:TextBox>
                                                    <span class="score-max">/ <%# Eval("MaxScore") %></span>
                                                </div>
                                                <div class="comment-box">
                                                    <asp:TextBox ID="txtComment" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="Comment for this answer (optional)" Text='<%# Eval("Comment") %>' ReadOnly='<%# Eval("Locked") %>'></asp:TextBox>
                                                </div>
                                            </div>
                                            <div class="auto-note" runat="server" visible='<%# Eval("AutoGraded") %>'>Multiple-choice answers are scored automatically.</div>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>

                                <div class="overall-card">
                                    <h3>Overall Feedback for Teacher</h3>
                                    <asp:TextBox ID="txtOverallFeedback" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="Summarise the learner's strengths and areas to improve. The teacher will see this when reviewing."></asp:TextBox>
                                </div>
                            </div>

                            <div class="grading-footer">
                                <div class="total-score">Suggested total: <strong id="totalScore"><asp:Literal ID="litTotalScore" runat="server"></asp:Literal></strong> / <asp:Literal ID="litTotalMax" runat="server"></asp:Literal></div>
                                <div class="footer-actions">
                                    <asp:Button ID="btnSaveDraft" runat="server" Text="Save Draft" CssClass="btn btn-secondary" OnClick="btnSaveDraft_Click" />
                                    <asp:Button ID="btnSubmitGrades" runat="server" Text="Submit for Approval" CssClass="btn btn-primary" OnClientClick="return confirm('Submit these scores to the teacher for approval? You will not be able to edit them afterwards.');" OnClick="btnSubmitGrades_Click" />
                                </div>
                            </div>
                        </asp:PlaceHolder>

                    </section>
                </div>

            </main>
        </div>
    </form>

    <script>
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
</body>
</html>
