<%@ Page Title="My Account - Codercept" Language="C#" AutoEventWireup="true" CodeBehind="TAProfile.aspx.cs" Inherits="Codercept.TAProfile" MasterPageFile="~/TASite.master" %>
<%@ MasterType VirtualPath="~/TASite.master" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        .qual-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 1rem 1.25rem;
            border-bottom: 1px solid var(--border);
            gap: 1rem;
        }
        .qual-row:last-child {
            border-bottom: none;
        }
        .qual-info strong {
            display: block;
            color: var(--heading);
            font-size: 0.95rem;
            margin-bottom: 0.2rem;
        }
        .qual-info span {
            font-size: 0.8rem;
            color: var(--muted);
        }
    </style>
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">
    <div class="account-screen">
        <div class="account-heading">
            <h1>My Account</h1>
            <p>View and update your personal information, teaching level, and contact details.</p>
        </div>

        <h2>Personal Details</h2>
        <div class="account-card">
            <div class="account-grid">
                <label id="fldName" runat="server" class="portal-form-field">
                    <span>Full Name</span>
                    <asp:TextBox ID="txtName" runat="server" ValidateRequestMode="Disabled" autocomplete="off"></asp:TextBox>
                    <small id="hintName" runat="server"></small>
                </label>
                <label id="fldAge" runat="server" class="portal-form-field">
                    <span>Age</span>
                    <asp:TextBox ID="txtAge" runat="server" autocomplete="off"></asp:TextBox>
                    <small id="hintAge" runat="server"></small>
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
                    <input type="text" value="Teaching Assistant" disabled="disabled" />
                </label>
                <label id="fldTeachingLevel" runat="server" class="portal-form-field">
                    <span>Teaching Level</span>
                    <asp:DropDownList ID="ddlTeachingLevel" runat="server" aria-label="Teaching level">
                        <asp:ListItem>Beginner</asp:ListItem>
                        <asp:ListItem>Intermediate</asp:ListItem>
                        <asp:ListItem>Advanced</asp:ListItem>
                    </asp:DropDownList>
                    <small id="hintTeachingLevel" runat="server"></small>
                </label>
                <label id="fldAddress" runat="server" class="portal-form-field address-field">
                    <span>Address / Region</span>
                    <asp:TextBox ID="txtRegion" runat="server" TextMode="MultiLine" Rows="4" ValidateRequestMode="Disabled" autocomplete="off"></asp:TextBox>
                    <small id="hintAddress" runat="server"></small>
                </label>
            </div>
        </div>

        <h2>Qualifications & Credentials</h2>
        <div class="account-card">
            <asp:PlaceHolder ID="phQualEmpty" runat="server" Visible="false">
                <div style="padding: 1.5rem; text-align: center; color: var(--muted); font-size: 0.9rem;">
                    No qualifications on record.
                </div>
            </asp:PlaceHolder>

            <asp:Repeater ID="rptQualifications" runat="server">
                <ItemTemplate>
                    <div class="qual-row">
                        <div class="qual-info">
                            <strong><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></strong>
                            <span>Verified on <%# Eval("Date") %></span>
                        </div>
                        <div>
                            <a href='<%# Eval("DocumentUrl") %>' target="_blank" class="button button--ghost" runat="server" visible='<%# Eval("HasDocument") %>' style="font-size: 0.85rem; padding: 0.4rem 0.85rem;">
                                <%= TeacherIcons.Svg("link", 14) %><span>View Document</span>
                            </a>
                            <span class="badge" runat="server" visible='<%# !(bool)Eval("HasDocument") %>'>No document</span>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <div class="account-actions">
            <asp:LinkButton ID="btnUpdateProfile" runat="server" CssClass="button button--primary" OnClick="btnUpdateProfile_Click">
                <span>Update Details</span>
            </asp:LinkButton>
        </div>
    </div>
</asp:Content>
