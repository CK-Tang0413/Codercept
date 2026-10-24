<%@ Page Title="Courses - Codercept" Language="C#" AutoEventWireup="true" CodeBehind="TACourses.aspx.cs" Inherits="Codercept.TACourses" MasterPageFile="~/TASite.master" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        :root {
            --panel-bg: var(--bg-surface);
            --input-bg: var(--bg-main);
            --warn: #fbbf24;
            --success: #34d399;
        }

        .page-header { margin-bottom: 1.5rem; }
        .page-header h1 { font-size: 1.75rem; margin-bottom: 0.25rem; color: var(--text-primary); }
        .page-header p { color: var(--text-secondary); font-size: 1rem; }

        .toolbar { display: flex; flex-wrap: wrap; gap: 0.75rem; margin-bottom: 1.5rem; }
        .search-box { flex: 1 1 280px; max-width: 460px; min-width: 0; background: var(--input-bg); border: 1px solid var(--border-light); border-radius: 10px; padding: 0.65rem 0.9rem; color: var(--text-primary); font-size: 0.9rem; outline: none; transition: border-color 0.2s; }
        .search-box:focus { border-color: var(--accent-primary); }

        .filter-dropdown { position: relative; width: 220px; }
        .filter-button { width: 100%; height: 100%; display: flex; align-items: center; justify-content: space-between; gap: 0.5rem; padding: 0.65rem 0.9rem; border-radius: 10px; border: 1px solid var(--border-light); background: rgba(255, 255, 255, 0.04); color: var(--text-primary); font-size: 0.9rem; font-weight: 600; cursor: pointer; transition: border-color 0.2s; }
        .filter-button:hover, .filter-dropdown.open .filter-button { border-color: var(--accent-primary); }
        .filter-button .chev { transition: transform 0.2s; }
        .filter-dropdown.open .chev { transform: rotate(180deg); }
        .filter-menu { display: none; position: absolute; top: calc(100% + 0.35rem); left: 0; right: 0; z-index: 20; background: #1b1530; border: 1px solid var(--border-light); border-radius: 10px; padding: 0.35rem; box-shadow: 0 12px 32px rgba(0, 0, 0, 0.5); }
        .filter-dropdown.open .filter-menu { display: block; }
        .filter-option { display: flex; justify-content: space-between; align-items: center; padding: 0.6rem 0.75rem; border-radius: 8px; font-size: 0.9rem; font-weight: 500; color: var(--text-secondary); text-decoration: none; }
        .filter-option:hover { background: var(--accent-transparent); color: var(--accent-light); }
        .filter-option.active { background: var(--accent-primary); color: var(--text-primary); }
        .filter-count { font-weight: 700; opacity: 0.85; }

        .course-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 1.5rem; padding-bottom: 2rem; }
        .course-card { display: flex; flex-direction: column; background: var(--panel-bg); border: 1px solid var(--border-light); border-radius: 16px; padding: 1.75rem; text-decoration: none; transition: border-color 0.2s, transform 0.2s; }
        .course-card:hover { border-color: var(--accent-primary); transform: translateY(-2px); }
        .course-tags { display: flex; flex-wrap: wrap; align-items: center; gap: 0.5rem; }
        .course-card h3 { font-size: 1.15rem; color: var(--text-primary); margin: 1rem 0 0.5rem; line-height: 1.35; }
        .course-card p { color: var(--text-secondary); font-size: 0.9rem; line-height: 1.6; margin-bottom: 1.25rem; display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; }
        .course-meta { margin-top: auto; display: flex; flex-wrap: wrap; gap: 0.35rem 1.1rem; font-size: 0.8rem; color: var(--text-muted); padding-top: 1rem; border-top: 1px solid var(--border-light); }
        .course-meta strong { color: var(--text-secondary); font-weight: 600; }
        .tag { font-size: 0.72rem; font-weight: 600; padding: 0.2rem 0.65rem; border-radius: 999px; white-space: nowrap; }
        .tag-level { color: var(--warn); background: rgba(251, 191, 36, 0.12); }
        .tag-subject { color: var(--accent-light); background: var(--accent-transparent); }
        .tag-mine { color: var(--success); background: rgba(52, 211, 153, 0.12); }

        .empty-state { color: var(--text-muted); font-size: 0.95rem; padding: 2rem 0; }
        #noSearchResults { display: none; }
    </style>
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
        <div class="page-header">
            <h1>Courses</h1>
            <p>Browse the course material behind a submission or forum question. Everything here is view-only; content is managed by the course teacher.</p>
        </div>

        <div class="toolbar">
            <input type="search" id="courseSearch" class="search-box" placeholder="Search by title, subject, teacher or level" autocomplete="off" />
            <div class="filter-dropdown" id="filterDropdown">
                <button type="button" class="filter-button" id="filterButton" aria-haspopup="true" aria-expanded="false">
                    <span><asp:Literal ID="litFilterLabel" runat="server"></asp:Literal></span>
                    <svg class="chev" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><path d="M6 9l6 6 6-6" /></svg>
                </button>
                <div class="filter-menu">
                    <a href="TACourses.aspx?scope=mine" class="filter-option <%= GetOptionClass("mine") %>">My courses<span class="filter-count"><asp:Literal ID="litCountMine" runat="server"></asp:Literal></span></a>
                    <a href="TACourses.aspx?scope=all" class="filter-option <%= GetOptionClass("all") %>">All courses<span class="filter-count"><asp:Literal ID="litCountAll" runat="server"></asp:Literal></span></a>
                </div>
            </div>
        </div>

        <asp:PlaceHolder ID="phNoAssigned" runat="server" Visible="false">
            <p class="empty-state">No courses are linked to your subjects yet. Switch to All courses to browse everything.</p>
        </asp:PlaceHolder>
        <asp:PlaceHolder ID="phEmpty" runat="server" Visible="false">
            <p class="empty-state">No courses to show.</p>
        </asp:PlaceHolder>
        <p id="noSearchResults" class="empty-state">No courses match your search.</p>

        <div class="course-grid">
            <asp:Repeater ID="rptCourses" runat="server">
                <ItemTemplate>
                    <a class="course-card" href='TACourseView.aspx?id=<%# Eval("CourseId") %>'>
                        <div class="course-tags">
                            <span class="tag tag-level"><%# Eval("Level") %></span>
                            <%# Eval("Subjects").ToString().Length > 0 ? "<span class='tag tag-subject'>" + Eval("Subjects") + "</span>" : "" %>
                            <%# (bool)Eval("IsMine") ? "<span class='tag tag-mine'>My course</span>" : "" %>
                        </div>
                        <h3><%# Eval("Title") %></h3>
                        <p><%# Eval("Description") %></p>
                        <div class="course-meta">
                            <span>Teacher: <strong><%# Eval("Teacher") %></strong></span>
                            <span>Duration: <strong><%# Eval("Duration") %></strong></span>
                            <span>Chapters: <strong><%# Eval("ChapterCount") %></strong></span>
                        </div>
                    </a>
                </ItemTemplate>
            </asp:Repeater>
        </div>
</asp:Content>

<asp:Content ID="ContentScripts" ContentPlaceHolderID="cphScripts" runat="server">
    <script>
        (function () {
            var dd = document.getElementById('filterDropdown');
            var btn = document.getElementById('filterButton');
            btn.addEventListener('click', function (e) {
                e.stopPropagation();
                var open = dd.classList.toggle('open');
                btn.setAttribute('aria-expanded', open);
            });
            document.addEventListener('click', function () { dd.classList.remove('open'); btn.setAttribute('aria-expanded', false); });

            var search = document.getElementById('courseSearch');
            var cards = document.querySelectorAll('.course-card');
            var none = document.getElementById('noSearchResults');
            search.addEventListener('keydown', function (e) { if (e.key === 'Enter') e.preventDefault(); });
            search.addEventListener('input', function () {
                var q = search.value.trim().toLowerCase(), shown = 0;
                cards.forEach(function (c) {
                    var hit = !q || c.textContent.toLowerCase().indexOf(q) !== -1;
                    c.style.display = hit ? '' : 'none';
                    if (hit) shown++;
                });
                none.style.display = (q && cards.length && !shown) ? 'block' : 'none';
            });
        })();
    </script>
</asp:Content>
