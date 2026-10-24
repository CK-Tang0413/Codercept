<%@ Page Title="Course Content - Codercept" Language="C#" AutoEventWireup="true" CodeBehind="TACourseView.aspx.cs" Inherits="Codercept.TACourseView" MasterPageFile="~/TASite.master" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        :root {
            --panel-bg: var(--bg-surface);
            --warn: #fbbf24;
            --success: #34d399;
            --item-active-bg: rgba(124, 58, 237, 0.1);
        }

        .back-link { display: inline-block; color: var(--accent-light); text-decoration: none; font-size: 0.9rem; font-weight: 500; margin-bottom: 1.25rem; transition: color 0.2s; }
        .back-link:hover { color: var(--accent-hover); text-decoration: underline; }

        /* Course header */
        .course-header { display: flex; flex-wrap: wrap; justify-content: space-between; align-items: flex-end; gap: 1rem 2rem; background: rgba(30, 22, 51, 0.6); border: 1px solid rgba(124, 58, 237, 0.2); padding: 1.75rem 2rem; border-radius: 16px; margin-bottom: 1.5rem; backdrop-filter: blur(10px); }
        .course-tags { display: flex; flex-wrap: wrap; gap: 0.5rem; align-items: center; margin-bottom: 0.75rem; }
        .course-header h1 { font-size: 1.75rem; margin-bottom: 0.4rem; color: var(--text-primary); }
        .course-header p { color: var(--text-secondary); font-size: 0.95rem; line-height: 1.6; max-width: 640px; }
        .course-meta { display: flex; flex-wrap: wrap; gap: 0.35rem 1.5rem; font-size: 0.85rem; color: var(--text-muted); }
        .course-meta strong { color: var(--text-secondary); font-weight: 600; }
        .view-only { font-size: 0.75rem; font-weight: 600; color: var(--text-muted); border: 1px solid var(--border-light); border-radius: 999px; padding: 0.25rem 0.75rem; white-space: nowrap; }

        .tag { font-size: 0.72rem; font-weight: 600; padding: 0.2rem 0.65rem; border-radius: 999px; white-space: nowrap; }
        .tag-level { color: var(--warn); background: rgba(251, 191, 36, 0.12); }
        .tag-subject { color: var(--accent-light); background: var(--accent-transparent); }
        .tag-mine { color: var(--success); background: rgba(52, 211, 153, 0.12); }

        /* Same shape as the learner course viewer: chapter outline + content */
        .viewer { display: grid; grid-template-columns: 300px minmax(0, 1fr); gap: 1.5rem; align-items: start; padding-bottom: 2rem; }
        .outline { position: sticky; top: 0; max-height: calc(100vh - 3rem); overflow-y: auto; background: var(--panel-bg); border: 1px solid var(--border-light); border-radius: 16px; padding: 0.5rem 0; scrollbar-width: thin; scrollbar-color: rgba(255, 255, 255, 0.18) transparent; }
        .outline-title { padding: 1rem 1.25rem 0.75rem; font-size: 0.75rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-muted); }
        .nav-chapter { display: flex; align-items: flex-start; gap: 0.9rem; padding: 0.9rem 1.25rem; border-left: 3px solid transparent; text-decoration: none; transition: background 0.2s; }
        .nav-chapter:hover { background: rgba(255, 255, 255, 0.03); }
        .nav-chapter.active { background: var(--item-active-bg); border-left-color: var(--accent-primary); }
        .nav-num { width: 24px; height: 24px; border-radius: 50%; background: var(--border-light); color: var(--text-secondary); display: flex; align-items: center; justify-content: center; font-size: 0.75rem; font-weight: 700; flex-shrink: 0; margin-top: 0.05rem; }
        .nav-chapter.active .nav-num { background: var(--accent-primary); color: #fff; }
        .nav-details { flex: 1; min-width: 0; }
        .nav-title { font-size: 0.92rem; font-weight: 600; color: var(--text-primary); line-height: 1.4; overflow-wrap: anywhere; }
        .nav-time { font-size: 0.78rem; color: var(--text-muted); margin-top: 0.15rem; }
        .nav-sub { display: flex; align-items: center; gap: 0.65rem; padding: 0.5rem 1.25rem 0.5rem 3.4rem; font-size: 0.85rem; color: var(--text-secondary); text-decoration: none; overflow-wrap: anywhere; }
        .nav-sub:hover { color: var(--accent-light); }
        .kind-dot { width: 8px; height: 8px; border-radius: 50%; flex-shrink: 0; background: var(--text-muted); }
        .kind-quiz { background: #60a5fa; }
        .kind-assessment { background: var(--accent-light); }
        .kind-exam { background: var(--warn); }

        .content-card { background: var(--panel-bg); border: 1px solid var(--border-light); border-radius: 16px; padding: 2rem 2.25rem; min-width: 0; }
        .content-header { margin-bottom: 1rem; }
        .ch-label { display: block; font-size: 0.8rem; font-weight: 600; color: var(--accent-light); margin-bottom: 0.4rem; }
        .ch-main-title { font-size: 1.6rem; color: var(--text-primary); line-height: 1.3; }
        .chapter-desc { color: var(--text-secondary); font-size: 0.98rem; line-height: 1.7; margin-bottom: 0.5rem; }

        .section-divider { margin: 2rem 0 1rem; padding-bottom: 0.6rem; border-bottom: 1px solid var(--border-light); font-size: 0.8rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: var(--accent-light); }
        .theory-content, .item-desc { color: var(--text-secondary); font-size: 0.98rem; line-height: 1.8; white-space: pre-wrap; overflow-wrap: anywhere; }
        .media-link { display: inline-block; margin-top: 0.75rem; color: var(--accent-light); font-size: 0.88rem; font-weight: 500; text-decoration: none; }
        .media-link:hover { text-decoration: underline; }
        .video-card { display: flex; align-items: center; gap: 1rem; padding: 1.25rem 1.5rem; border: 1px solid var(--border-light); border-radius: 12px; background: rgba(255, 255, 255, 0.02); color: var(--text-primary); text-decoration: none; font-weight: 600; }
        .video-card:hover { border-color: var(--accent-primary); }
        .play-btn { width: 40px; height: 40px; border-radius: 50%; background: var(--accent-primary); color: #fff; display: inline-flex; align-items: center; justify-content: center; font-size: 0.9rem; padding-left: 3px; }

        .quiz-question { border: 1px solid var(--border-light); border-radius: 12px; padding: 1rem 1.25rem; background: rgba(255, 255, 255, 0.02); margin-top: 0.85rem; }
        .q-top { display: flex; justify-content: space-between; gap: 1rem; font-size: 0.72rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.04em; color: var(--text-muted); margin-bottom: 0.5rem; }
        .q-title { color: var(--text-primary); font-size: 0.95rem; line-height: 1.6; font-weight: 500; white-space: pre-wrap; }
        .q-title span { color: var(--accent-light); font-weight: 700; margin-right: 0.4rem; }

        .viewer-footer { display: flex; justify-content: space-between; align-items: center; margin-top: 2.5rem; padding-top: 1.25rem; border-top: 1px solid var(--border-light); }
        .btn-nav { padding: 0.6rem 1.15rem; border-radius: 8px; border: 1px solid var(--border-light); color: var(--text-secondary); font-size: 0.9rem; font-weight: 600; text-decoration: none; transition: all 0.2s; }
        .btn-nav:hover { color: var(--text-primary); border-color: var(--accent-primary); }
        .btn-nav.primary { background: var(--accent-primary); border-color: var(--accent-primary); color: #fff; }
        .btn-nav.primary:hover { background: var(--accent-hover); }
        .step-indicator { font-size: 0.85rem; color: var(--text-muted); }

        .empty-state { color: var(--text-muted); font-size: 0.9rem; padding: 2rem 0; }

        @media (max-width: 1100px) {
            .viewer { grid-template-columns: minmax(0, 1fr); }
            .outline { position: static; max-height: 320px; }
        }
        @media (max-width: 640px) {
            .course-header { padding: 1.25rem; }
            .content-card { padding: 1.25rem; }
        }
    </style>
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">

        <a href="TACourses.aspx" class="back-link">&larr; Back to courses</a>

        <asp:PlaceHolder ID="phNotFound" runat="server" Visible="false">
            <p class="empty-state">This course could not be found.</p>
        </asp:PlaceHolder>

        <asp:PlaceHolder ID="phCourse" runat="server">
            <div class="course-header">
                <div>
                    <div class="course-tags">
                        <span class="tag tag-level"><asp:Literal ID="litLevel" runat="server"></asp:Literal></span>
                        <asp:Literal ID="litSubjects" runat="server"></asp:Literal>
                        <asp:Literal ID="litMine" runat="server"></asp:Literal>
                    </div>
                    <h1><asp:Literal ID="litTitle" runat="server"></asp:Literal></h1>
                    <p><asp:Literal ID="litDescription" runat="server"></asp:Literal></p>
                </div>
                <div>
                    <div class="course-meta">
                        <span>Teacher: <strong><asp:Literal ID="litTeacher" runat="server"></asp:Literal></strong></span>
                        <span>Duration: <strong><asp:Literal ID="litDuration" runat="server"></asp:Literal></strong></span>
                        <span>Chapters: <strong><asp:Literal ID="litChapterCount" runat="server"></asp:Literal></strong></span>
                    </div>
                    <div style="margin-top: 0.75rem; text-align: right;"><span class="view-only">View only</span></div>
                </div>
            </div>

            <div class="viewer">
                <nav class="outline">
                    <div class="outline-title">Course outline</div>
                    <asp:Literal ID="litOutline" runat="server"></asp:Literal>
                </nav>

                <article class="content-card">
                    <asp:Literal ID="litChapter" runat="server"></asp:Literal>
                </article>
            </div>
        </asp:PlaceHolder>
</asp:Content>
