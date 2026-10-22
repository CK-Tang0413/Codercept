<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TeacherCourseSelector.ascx.cs" Inherits="Codercept.TeacherCourseSelector" %>
<%-- Search / filter / grid-list / pagination run client-side (TeacherPortal.js, data-tp-sel-*).
     Choosing a course is a form post: the tile <button> submits "<UniqueID>$sel" = course index. --%>
<div class="course-selector<%= Compact ? " is-compact" : "" %>" data-tp-selector data-tp-page-size="3">
    <input type="hidden" runat="server" id="hfTeacherSelIndex" value="0" />
    <input type="hidden" runat="server" id="hfTeacherSelState" data-tp-sel-state />

    <div class="selector-toolbar">
        <label class="input-wrap">
            <span class="sr-only">Search courses</span>
            <%= TeacherIcons.Svg("search", 18) %>
            <input aria-label="Search courses" placeholder="Search courses..." type="search" data-tp-sel-search />
        </label>
        <div class="selector-actions">
            <div class="filter-wrap">
                <button type="button" class="button button--ghost" data-tp-sel-filter-toggle><%= TeacherIcons.Svg("filter", 17) %><span>Filter</span></button>
                <div class="filter-popover" data-tp-sel-filter hidden>
                    <div class="filter-popover-heading">
                        <strong>Filter courses</strong>
                        <button type="button" class="clear-filter" data-tp-sel-clear>Clear</button>
                    </div>
                    <label>
                        <span>Language</span>
                        <select data-tp-sel-lang>
                            <option>All</option>
                            <% foreach (string lang in Languages) { %><option><%: lang %></option><% } %>
                        </select>
                    </label>
                    <label>
                        <span>Difficulty</span>
                        <select data-tp-sel-diff>
                            <option>All</option>
                            <option>Easy</option>
                            <option>Medium</option>
                            <option>Hard</option>
                        </select>
                    </label>
                    <label>
                        <span>Date</span>
                        <select data-tp-sel-date>
                            <option>All</option>
                            <option>Newest</option>
                            <option>Oldest</option>
                        </select>
                    </label>
                </div>
            </div>
            <div class="view-toggle" aria-label="Course view">
                <button type="button" aria-label="Grid view" class="is-active" data-tp-sel-view="grid"><%= TeacherIcons.Svg("grid", 17) %></button>
                <button type="button" aria-label="List view" data-tp-sel-view="list"><%= TeacherIcons.Svg("list", 18) %></button>
            </div>
        </div>
    </div>

    <div class="select-course-grid select-course-grid--grid" data-tp-sel-grid>
        <% for (int i = 0; i < Courses.Count; i++) { TeacherCourse c = Courses[i]; bool selected = (i == SelectedIndex); %>
        <button type="submit" name="<%= UniqueID %>$sel" value="<%= i %>" aria-pressed="<%= selected ? "true" : "false" %>"
            class="select-course-card<%= selected ? " is-selected" : "" %>"
            data-tp-course-tile data-index="<%= i %>" data-title="<%: c.Title %>" data-language="<%: c.Language %>" data-difficulty="<%: c.Difficulty %>">
            <div class="course-thumbnail course-thumbnail--<%= c.Theme %> select-course-thumbnail">
                <span><%: c.Glyph %></span>
                <i class="code-symbol code-symbol--one">{ }</i>
                <i class="code-symbol code-symbol--two">01</i>
            </div>
            <div class="select-course-content">
                <div class="select-course-title-row">
                    <h3 title="<%: c.Title %>"><%: c.Title %></h3>
                    <% if (selected) { %><span class="selected-check"><%= TeacherIcons.Svg("check", 13) %></span><% } %>
                </div>
                <div class="select-course-date"><%= TeacherIcons.Svg("calendar", 14) %>Created <%: c.Date %></div>
                <div class="select-course-footer">
                    <span class="badge badge--<%= TeacherSampleData.DifficultyTone(c.Difficulty) %>"><%: c.Difficulty %></span>
                    <span><%= TeacherIcons.Svg("clock", 14) %><%: c.Duration %> hours</span>
                </div>
            </div>
        </button>
        <% } %>
    </div>

    <div class="empty-state" data-tp-sel-empty hidden>
        <span class="empty-icon"><%= TeacherIcons.Svg("search", 20) %></span>
        <h3>No courses found</h3>
        <p>Try a different search or clear the current filters.</p>
    </div>

    <div class="selector-pagination">
        <button type="button" aria-label="Previous courses" data-tp-sel-prev><%= TeacherIcons.Svg("chevron", 17) %></button>
        <span data-tp-sel-count><strong>1</strong> of 1</span>
        <button type="button" aria-label="Next courses" data-tp-sel-next><%= TeacherIcons.Svg("chevron", 17) %></button>
    </div>
</div>
