<%@ Page Title="Create Course - Codercept" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="TeacherCourseCreate.aspx.cs" Inherits="Codercept.TeacherCourseCreate" %>
<%@ MasterType VirtualPath="~/TeacherSite.master" %>
<%@ Register Src="~/TeacherDomainInput.ascx" TagPrefix="uc" TagName="DomainInput" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <a class="back-link" href="TeacherCourses.aspx"><%= TeacherIcons.Svg("arrow", 16) %>Back to previous page</a>
    <div class="page-heading create-heading">
        <div>
            <span class="eyebrow">COURSE MANAGEMENT</span>
            <h1>Create a Course</h1>
            <p>Build a clear course foundation before adding chapters and quizzes.</p>
        </div>
    </div>

    <div class="create-layout" data-tp-course-form>
        <article class="form-card">
            <div class="form-card-heading">
                <span class="form-card-icon"><%= TeacherIcons.Svg("plus", 20) %></span>
                <div>
                    <h2>Course details</h2>
                    <p>All fields marked with an asterisk are required.</p>
                </div>
            </div>

            <div class="form-fields">
                <label id="fldTeacherTitle" runat="server" class="form-field" data-tp-cf-field="title">
                    <span>Title <b>*</b></span>
                    <div class="validated-input">
                        <asp:TextBox ID="txtTeacherCourseTitle" runat="server" maxlength="255" placeholder="e.g. Python Programming Fundamentals" data-tp-cf="title"></asp:TextBox>
                        <span data-tp-cf-check style="display: contents" hidden><%= TeacherIcons.Svg("check", 17) %></span>
                    </div>
                    <small id="hintTeacherTitle" runat="server" data-tp-cf-hint data-ok="Use a clear, descriptive course title." data-err="Enter a title with at least 4 characters.">Use a clear, descriptive course title.</small>
                </label>

                <label id="fldTeacherDescription" runat="server" class="form-field" data-tp-cf-field="description">
                    <span>Description <b>*</b></span>
                    <asp:TextBox ID="txtTeacherCourseDescription" runat="server" TextMode="MultiLine" Rows="6" maxlength="300" placeholder="What will learners achieve in this course?" data-tp-cf="description"></asp:TextBox>
                    <div class="field-footer">
                        <small id="hintTeacherDescription" runat="server" data-tp-cf-hint data-ok="Include the main skills and expected outcomes." data-err="Write at least 20 characters.">Include the main skills and expected outcomes.</small>
                        <span data-tp-cf-counter>0/300</span>
                    </div>
                </label>

                <label class="form-field">
                    <span>Programming language <b>*</b></span>
                    <div class="language-select">
                        <span class="language-dot language-dot--python" data-tp-cf-langdot>py</span>
                        <asp:DropDownList ID="ddlTeacherCourseLanguage" runat="server" data-tp-cf="language"></asp:DropDownList>
                    </div>
                    <small>Select the primary language taught in this course.</small>
                </label>

                <div class="form-field">
                    <uc:DomainInput ID="ctlTeacherDomains" runat="server" />
                    <small>Optional topics such as Machine Learning. Pick an existing one or type a new one.</small>
                </div>

                <fieldset class="form-field">
                    <legend>Difficulty level <b>*</b></legend>
                    <input type="hidden" id="hfTeacherCourseDifficulty" runat="server" value="Easy" data-tp-cf="difficulty" />
                    <div class="segmented-control">
                        <button type="button" class="is-active" data-tp-cf-seg="Easy"><span class="level-dot level-dot--easy"></span>Easy</button>
                        <button type="button" data-tp-cf-seg="Medium"><span class="level-dot level-dot--medium"></span>Medium</button>
                        <button type="button" data-tp-cf-seg="Hard"><span class="level-dot level-dot--hard"></span>Hard</button>
                    </div>
                    <small>Choose the experience level expected from learners.</small>
                </fieldset>

                <label id="fldTeacherDuration" runat="server" class="form-field duration-field" data-tp-cf-field="duration">
                    <span>Duration <b>*</b></span>
                    <div class="suffix-input">
                        <asp:TextBox ID="txtTeacherCourseDuration" runat="server" TextMode="Number" min="1" placeholder="0" data-tp-cf="duration"></asp:TextBox>
                        <span>hours</span>
                    </div>
                    <small id="hintTeacherDuration" runat="server" data-tp-cf-hint data-ok="Estimated time to complete the whole course." data-err="Enter a duration greater than 0.">Estimated time to complete the whole course.</small>
                </label>
            </div>

            <div class="form-actions">
                <asp:LinkButton ID="btnTeacherCreateCourse" runat="server" CssClass="button button--primary" OnClientClick="return TeacherPortal.validateCourseForm();" OnClick="btnTeacherCreateCourse_Click"><svg aria-hidden="true" class="icon" fill="none" height="17" viewBox="0 0 24 24" width="17"><path d='M12 5v14M5 12h14' /></svg><span>Create course</span></asp:LinkButton>
                <button type="button" class="button button--ghost" data-tp-cf-clear><span>Clear all fields</span></button>
            </div>
        </article>

        <aside class="preview-column">
            <div class="preview-heading">
                <div>
                    <span>LIVE PREVIEW</span>
                    <h2>Course card</h2>
                </div>
                <span class="live-indicator">Live</span>
            </div>
            <button type="button" class="select-course-card" tabindex="-1">
                <div class="course-thumbnail course-thumbnail--python select-course-thumbnail" data-tp-pv="thumb">
                    <span data-tp-pv="glyph">py</span>
                    <i class="code-symbol code-symbol--one">{ }</i>
                    <i class="code-symbol code-symbol--two">01</i>
                </div>
                <div class="select-course-content">
                    <div class="select-course-title-row">
                        <h3 data-tp-pv="title" title="Your course title">Your course title</h3>
                    </div>
                    <div class="select-course-date"><%= TeacherIcons.Svg("calendar", 14) %>Created Today</div>
                    <div class="select-course-footer">
                        <span class="badge badge--success" data-tp-pv="difficulty">Easy</span>
                        <span><%= TeacherIcons.Svg("clock", 14) %><span data-tp-pv="duration">0</span> hours</span>
                    </div>
                </div>
            </button>
            <p class="preview-note"><%= TeacherIcons.Svg("info", 15) %>This preview updates as you complete the form.</p>
        </aside>
    </div>
</asp:Content>
