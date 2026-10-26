<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TeacherDomainInput.ascx.cs" Inherits="Codercept.TeacherDomainInput" %>
<%-- Tag input for a course's domains (e.g. Machine Learning). TeacherPortal.js (initDomainInputs) turns the hidden JSON list into tags. --%>
<div id="fldTeacherDomains" runat="server" class="tp-inline-field" data-tp-domains data-max="5">
    <span>Domains (optional, up to 5)</span>
    <input type="hidden" id="hfTeacherDomains" runat="server" value="[]" data-tp-domains-value />
    <div class="tp-domain-box" data-tp-domains-box>
        <span class="tp-domain-tags" data-tp-domains-tags></span>
        <input type="text" maxlength="50" autocomplete="off" list="<%= ClientID %>_suggestions" placeholder="Type a domain and press Enter" aria-label="Add a domain" data-tp-domains-text />
    </div>
    <datalist id="<%= ClientID %>_suggestions">
        <% foreach (string suggestion in Suggestions) { %><option value="<%: suggestion %>"></option>
        <% } %>
    </datalist>
    <small id="hintTeacherDomains" runat="server"></small>
</div>
