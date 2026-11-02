<%@ Page Title="CODERCEPT" Language="C#" MasterPageFile="~/TeacherSite.master" AutoEventWireup="true" CodeBehind="TeacherAccount.aspx.cs" Inherits="Codercept.TeacherAccount" %>
<%@ MasterType VirtualPath="~/TeacherSite.master" %>
<%@ Register Src="~/TeacherConfirmModal.ascx" TagPrefix="uc" TagName="ConfirmModal" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <div class="account-screen">
        <div class="account-heading">
            <h1>My Account</h1>
            <p>View and update your personal information and contact details, and see your qualifications.</p>
        </div>

        <h2>Personal Details</h2>
        <div class="account-card">
            <div class="account-grid">
                <label id="fldTeacherAccountName" runat="server" class="portal-form-field">
                    <span>Full Name</span>
                    <asp:TextBox ID="txtTeacherAccountName" runat="server" ValidateRequestMode="Disabled" autocomplete="off"></asp:TextBox>
                    <small id="hintTeacherAccountName" runat="server"></small>
                </label>
                <label id="fldTeacherAccountAge" runat="server" class="portal-form-field">
                    <span>Age</span>
                    <asp:TextBox ID="txtTeacherAccountAge" runat="server" autocomplete="off"></asp:TextBox>
                    <small id="hintTeacherAccountAge" runat="server"></small>
                </label>
                <label class="portal-form-field">
                    <span>Email Address</span>
                    <input type="text" value="<%: Email %>" disabled="disabled" />
                    <small>Your email is used for login and cannot be changed.</small>
                </label>
                <label class="portal-form-field">
                    <span>Member Since</span>
                    <input type="text" value="<%: MemberSince %>" disabled="disabled" />
                </label>
                <label class="portal-form-field">
                    <span>Occupation / Role</span>
                    <input type="text" value="Teacher" disabled="disabled" />
                </label>
                <label id="fldTeacherAccountLevel" runat="server" class="portal-form-field">
                    <span>Teaching Level</span>
                    <asp:DropDownList ID="ddlTeacherAccountLevel" runat="server" aria-label="Teaching level">
                        <asp:ListItem>Beginner</asp:ListItem>
                        <asp:ListItem>Intermediate</asp:ListItem>
                        <asp:ListItem>Advanced</asp:ListItem>
                    </asp:DropDownList>
                    <small id="hintTeacherAccountLevel" runat="server"></small>
                </label>
                <label id="fldTeacherAccountAddress" runat="server" class="portal-form-field address-field">
                    <span>Address</span>
                    <asp:TextBox ID="txtTeacherAccountAddress" runat="server" TextMode="MultiLine" Rows="4" ValidateRequestMode="Disabled" autocomplete="off"></asp:TextBox>
                    <small id="hintTeacherAccountAddress" runat="server"></small>
                </label>
            </div>
        </div>

        <h2>Qualifications &amp; Credentials</h2>
        <div class="account-card">
            <asp:PlaceHolder ID="phTeacherQualEmpty" runat="server" Visible="false">
                <div class="qual-empty">No qualifications on record.</div>
            </asp:PlaceHolder>
            <asp:PlaceHolder ID="phTeacherQual" runat="server" Visible="false">
                <div class="qual-row">
                    <div class="qual-info">
                        <strong><asp:Literal ID="litQualName" runat="server"></asp:Literal></strong>
                        <span><asp:Literal ID="litQualDate" runat="server"></asp:Literal></span>
                    </div>
                    <div>
                        <a id="lnkQualDocument" runat="server" target="_blank" rel="noopener" class="button button--ghost" visible="false">
                            <%= TeacherIcons.Svg("link", 14) %><span>View Document</span>
                        </a>
                        <span id="spnQualNoDocument" runat="server" class="badge" visible="false">No document</span>
                    </div>
                </div>
            </asp:PlaceHolder>
        </div>

        <div class="account-actions">
            <button type="button" class="button button--danger" data-tp-open-modal="tpDeleteAccountModal"><span>Delete Account</span></button>
            <asp:LinkButton ID="btnTeacherUpdateAccount" runat="server" CssClass="button button--primary" OnClick="btnTeacherUpdateAccount_Click"><span>Update Details</span></asp:LinkButton>
        </div>
    </div>
</asp:Content>

<asp:Content ID="ContentModals" ContentPlaceHolderID="cphModals" runat="server">
    <uc:ConfirmModal ID="mdlTeacherDeleteAccount" runat="server" ModalId="tpDeleteAccountModal" TitleText="Delete your account?"
        ExtraCssClass="account-modal" ConfirmText="Delete Account" ConfirmIcon="trash" ConfirmVariant="danger"
        OnConfirmed="mdlTeacherDeleteAccount_Confirmed" />
</asp:Content>
