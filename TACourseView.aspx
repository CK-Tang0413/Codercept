<%@ Page Title="Course Content - Codercept" Language="C#" AutoEventWireup="true" CodeBehind="TACourseView.aspx.cs" Inherits="Codercept.TACourseView" MasterPageFile="~/TASite.master" %>
<%@ MasterType VirtualPath="~/TASite.master" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        .chapter-nav-item {
            display: flex;
            align-items: center;
            gap: 12px;
            min-height: 50px;
            padding: 9px 12px;
            border-left: 3px solid transparent;
            border-radius: 8px;
            text-decoration: none;
            color: var(--heading);
            transition: all 160ms ease;
            margin-bottom: 4px;
        }
        .chapter-nav-item:hover {
            background: #f8fafc;
        }
        .chapter-nav-item.is-active {
            border-left-color: var(--indigo);
            background: var(--indigo-tint);
        }
        .chapter-nav-item .chapter-number {
            width: 30px;
            height: 30px;
            border-radius: 8px;
            display: grid;
            place-items: center;
            flex-shrink: 0;
            font-family: "Plus Jakarta Sans", sans-serif;
            font-size: 13px;
            font-weight: 800;
            background: #f1f5f9;
            color: var(--body);
        }
        .chapter-nav-item.is-active .chapter-number {
            background: var(--indigo);
            color: #ffffff;
        }
        .chapter-nav-item .chapter-item-title {
            font-size: 13px;
            font-weight: 650;
            color: var(--heading);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
            flex: 1;
            min-width: 0;
        }
        .curriculum-item-card {
            background: #ffffff;
            border: 1px solid #e9e5f5;
            border-radius: 12px;
            padding: 1.25rem;
            box-shadow: 0 1px 3px rgba(76, 29, 149, 0.04);
        }
        .curriculum-item-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 0.75rem;
            padding-bottom: 0.75rem;
            border-bottom: 1px solid #f1f5f9;
        }
    </style>
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <asp:PlaceHolder ID="phNotFound" runat="server" Visible="false">
        <article class="chapter-detail-card">
            <p class="summary-empty">The requested course could not be found.</p>
            <div class="chapter-detail-actions">
                <a class="button button--primary" href="TACourses.aspx"><span>Back to courses</span></a>
            </div>
        </article>
    </asp:PlaceHolder>

    <asp:PlaceHolder ID="phCourse" runat="server">
        <div class="exam-course-banner course-thumbnail--<%= CourseTheme %>">
            <span class="exam-banner-glyph"><%= CourseGlyph %></span>
            <div>
                <span>COURSE CURRICULUM</span>
                <h1><asp:Literal ID="litTitle" runat="server"></asp:Literal></h1>
                <p><asp:Literal ID="litSubtitle" runat="server"></asp:Literal></p>
            </div>
            <a class="button button--ghost" href="TACourses.aspx" style="margin-left: auto; z-index: 2;">
                <%= TeacherIcons.Svg("arrow", 14) %><span>Back to courses</span>
            </a>
            <i class="code-symbol code-symbol--one">{ }</i>
            <i class="code-symbol code-symbol--two">01</i>
        </div>

        <div class="chapter-master-detail" style="margin-top: 1.5rem;">
            <aside class="chapter-list-panel" aria-label="Course chapters">
                <div class="chapter-list-heading">
                    <span>COURSE STRUCTURE</span>
                    <strong><%= Chapters.Count %> chapters</strong>
                </div>
                <div class="chapter-items">
                    <% for (int i = 0; i < Chapters.Count; i++) { ChapterItem c = Chapters[i]; bool active = c.ChapterId == SelectedChapterId; %>
                    <a href="TACourseView.aspx?id=<%= CourseId %>&ch=<%= c.ChapterId %>" class="chapter-nav-item<%= active ? " is-active" : "" %>">
                        <span class="chapter-number"><%= c.Number %></span>
                        <span class="chapter-item-title"><%: c.Title %></span>
                    </a>
                    <% } %>
                </div>
            </aside>

            <div class="chapter-detail-column">
                <% if (ActiveChapter != null) { %>
                <article class="chapter-detail-card">
                    <div class="chapter-detail-title">
                        <span class="large-number-badge"><%= ActiveChapter.Number %></span>
                        <div>
                            <span>CHAPTER <%= ActiveChapter.Number %></span>
                            <h2><%: ActiveChapter.Title %></h2>
                        </div>
                    </div>
                    <p style="color: #4b5563; font-size: 0.95rem; line-height: 1.6; margin: 1rem 0 1.5rem;"><%: ActiveChapter.Description %></p>

                    <div class="chapter-meta-grid" style="margin-bottom: 2rem;">
                        <div class="detail-item">
                            <span class="detail-item-icon"><%= TeacherIcons.Svg("clock", 17) %></span>
                            <div>
                                <span>Duration</span>
                                <strong><%: ActiveChapter.Duration %></strong>
                            </div>
                        </div>
                        <div class="detail-item">
                            <span class="detail-item-icon"><%= TeacherIcons.Svg("layers", 17) %></span>
                            <div>
                                <span>Lessons & Activities</span>
                                <strong><%= ActiveChapter.Items.Count %> items</strong>
                            </div>
                        </div>
                    </div>

                    <% if (ActiveChapter.Items.Count == 0) { %>
                    <p class="summary-empty">No subchapters or assessments added to this chapter yet.</p>
                    <% } else { %>
                    <div style="display: flex; flex-direction: column; gap: 1.5rem;">
                        <% foreach (CurriculumItem item in ActiveChapter.Items) { %>
                        <div class="curriculum-item-card">
                            <div class="curriculum-item-header">
                                <span class="badge badge--<%= item.Kind == "Lesson" ? "secondary" : item.Kind == "Quiz" ? "warning" : "success" %>"><%: item.Kind %></span>
                                <h3 style="font-size: 1.05rem; font-weight: 700; color: #111827; margin: 0;"><%: item.Title %></h3>
                            </div>
                            <% if (!string.IsNullOrWhiteSpace(item.Body)) { %>
                            <div style="color: #374151; font-size: 0.92rem; line-height: 1.6; white-space: pre-wrap; margin-bottom: 0.75rem;"><%: item.Body %></div>
                            <% } %>
                            <% if (!string.IsNullOrWhiteSpace(item.MediaLink)) { %>
                            <div style="margin-top: 0.5rem;">
                                <a href="<%: item.MediaLink %>" target="_blank" rel="noopener noreferrer" class="button button--ghost" style="display: inline-flex; align-items: center; gap: 0.4rem; font-size: 0.85rem;">
                                    <%= TeacherIcons.Svg("link", 15) %><span>Open Media Attachment</span>
                                </a>
                            </div>
                            <% } %>
                            <% if (item.Questions.Count > 0) { %>
                            <div style="margin-top: 1rem; border-top: 1px solid #f3f4f6; padding-top: 0.75rem;">
                                <span style="font-size: 0.75rem; font-weight: 700; color: #6b7280; text-transform: uppercase; letter-spacing: 0.05em; display: block; margin-bottom: 0.5rem;"><%= item.Questions.Count %> Question(s)</span>
                                <% for (int qIdx = 0; qIdx < item.Questions.Count; qIdx++) { QuestionDetail q = item.Questions[qIdx]; %>
                                <div style="background: #f9fafb; border: 1px solid #e5e7eb; border-radius: 8px; padding: 0.75rem 1rem; margin-bottom: 0.5rem;">
                                    <div style="display: flex; justify-content: space-between; font-size: 0.8rem; font-weight: 600; color: #6b7280; margin-bottom: 0.25rem;">
                                        <span>Q<%= qIdx + 1 %> &middot; <%: q.Type %></span>
                                        <span><%: q.Score %> marks</span>
                                    </div>
                                    <div style="font-size: 0.9rem; color: #111827; font-weight: 500;"><%: q.Content %></div>
                                </div>
                                <% } %>
                            </div>
                            <% } %>
                        </div>
                        <% } %>
                    </div>
                    <% } %>
                </article>
                <% } %>
            </div>
        </div>
    </asp:PlaceHolder>
</asp:Content>
