<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="TeacherConfirmModal.ascx.cs" Inherits="Codercept.TeacherConfirmModal" %>
<%-- Shared confirm dialog. Open with any element carrying data-tp-open-modal="<ModalId>". --%>
<div class="modal-backdrop" role="presentation" id="<%= ModalId %>" data-tp-modal hidden>
    <div class="modal <%= ExtraCssClass %>" role="dialog" aria-modal="true" aria-labelledby="<%= ModalId %>Title">
        <span class="<%= IconCssClass %>"><%= TeacherIcons.Svg(IconName, 22) %></span>
        <h2 id="<%= ModalId %>Title"><%: TitleText %></h2>
        <p><%= BodyHtml %></p>
        <div class="modal-actions">
            <button type="button" class="button button--ghost" data-tp-close-modal><span><%: CancelText %></span></button>
            <asp:LinkButton ID="btnTeacherConfirm" runat="server" OnClick="btnTeacherConfirm_Click" />
        </div>
    </div>
</div>
