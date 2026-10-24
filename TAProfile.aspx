<%@ Page Title="My Profile - Codercept" Language="C#" AutoEventWireup="true" CodeBehind="TAProfile.aspx.cs" Inherits="Codercept.TAProfile" MasterPageFile="~/TASite.master" %>

<asp:Content ID="ContentHead" ContentPlaceHolderID="cphHead" runat="server">
    <style>
        :root {
            --profile-card-bg: var(--bg-surface);
            --profile-border: var(--border-light);
            --input-bg: var(--bg-main);
            --input-disabled-bg: rgba(255, 255, 255, 0.02);
            --input-disabled-text: var(--text-muted);
            --success: #34d399;
        }

        .profile-container { max-width: 1100px; }

        /* Identity header */
        .identity-card { display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 1.5rem; background: rgba(30, 22, 51, 0.6); border: 1px solid rgba(124, 58, 237, 0.2); border-radius: 16px; padding: 2rem 2.25rem; margin-bottom: 1.5rem; backdrop-filter: blur(10px); }
        .identity { display: flex; align-items: center; gap: 1.5rem; min-width: 0; }
        .identity .avatar { width: 76px; height: 76px; flex-shrink: 0; border-radius: 50%; background: var(--accent-primary); color: #fff; display: flex; align-items: center; justify-content: center; font-size: 1.6rem; font-weight: 700; letter-spacing: 0.02em; }
        .identity-text { min-width: 0; }
        .identity-text h2 { font-size: 1.6rem; color: var(--text-primary); margin-bottom: 0.2rem; overflow-wrap: anywhere; }
        .identity-email { color: var(--text-secondary); font-size: 0.95rem; margin-bottom: 0.75rem; overflow-wrap: anywhere; }
        .identity-tags { display: flex; flex-wrap: wrap; gap: 0.5rem; }
        .tag { font-size: 0.75rem; font-weight: 600; padding: 0.25rem 0.75rem; border-radius: 999px; white-space: nowrap; }
        .tag-active { color: var(--success); background: rgba(52, 211, 153, 0.12); }
        .tag-inactive { color: #ef4444; background: rgba(239, 68, 68, 0.12); }
        .tag-role { color: var(--accent-light); background: var(--accent-transparent); }

        /* Activity stats */
        .stats-grid { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 1.25rem; margin-bottom: 1.5rem; }
        .stat-card { background: var(--profile-card-bg); border: 1px solid var(--profile-border); padding: 1.35rem 1.6rem; border-radius: 14px; display: flex; flex-direction: column; gap: 0.35rem; }
        .stat-value { font-size: 2rem; line-height: 1; font-weight: 700; color: var(--text-primary); }
        .stat-label { font-size: 0.85rem; color: var(--text-secondary); }

        /* Body: details beside qualifications on wide screens */
        .profile-grid { display: grid; grid-template-columns: minmax(0, 1.4fr) minmax(0, 1fr); gap: 1.5rem; align-items: start; padding-bottom: 2rem; }
        .profile-card { background: var(--profile-card-bg); border: 1px solid var(--profile-border); border-radius: 16px; padding: 1.75rem 2rem; }
        .card-title { font-size: 1.1rem; font-weight: 600; color: var(--text-primary); margin-bottom: 1.25rem; }

        /* Form */
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1.25rem 1.5rem; }
        .form-group { display: flex; flex-direction: column; min-width: 0; }
        .form-group.full { grid-column: 1 / -1; }
        .form-group label { font-size: 0.85rem; font-weight: 600; color: var(--text-primary); margin-bottom: 0.5rem; }

        .form-control { background: var(--input-bg); border: 1px solid var(--profile-border); padding: 0.8rem 1rem; border-radius: 10px; color: var(--text-primary); font-size: 0.95rem; outline: none; transition: border-color 0.2s; width: 100%; }
        .form-control:focus { border-color: var(--accent-primary); }
        .form-control.readonly { background: var(--input-disabled-bg); color: var(--input-disabled-text); cursor: not-allowed; }
        .form-control.readonly:focus { border-color: var(--profile-border); }
        select.form-control { appearance: auto; }

        .help-text { font-size: 0.8rem; color: var(--text-muted); margin-top: 0.4rem; }

        .action-bar { display: flex; justify-content: flex-end; margin-top: 1.5rem; padding-top: 1.25rem; border-top: 1px solid var(--profile-border); }
        .btn { padding: 0.7rem 1.5rem; border-radius: 10px; font-weight: 600; font-size: 0.95rem; cursor: pointer; transition: all 0.2s; border: none; }
        .btn-update { background: var(--accent-primary); color: #ffffff; }
        .btn-update:hover { background: var(--accent-hover); }

        /* Qualifications */
        .qual-list { display: flex; flex-direction: column; gap: 0.75rem; }
        .qual-item { display: flex; justify-content: space-between; align-items: center; gap: 1rem; padding: 1rem 1.15rem; border: 1px solid var(--profile-border); border-radius: 12px; background: rgba(255, 255, 255, 0.02); }
        .qual-main { min-width: 0; }
        .qual-name { font-weight: 600; color: var(--text-primary); font-size: 0.92rem; line-height: 1.4; margin-bottom: 0.2rem; overflow-wrap: anywhere; }
        .qual-date { font-size: 0.8rem; color: var(--text-muted); }
        .qual-item > .qual-date { white-space: nowrap; flex-shrink: 0; }
        .qual-doc { font-size: 0.82rem; font-weight: 600; color: var(--accent-light); text-decoration: none; white-space: nowrap; }
        .qual-doc:hover { color: var(--accent-hover); text-decoration: underline; }
        .empty-state { color: var(--text-muted); font-size: 0.9rem; text-align: center; padding: 1rem 0; }

        .toast.toast-error { color: #ef4444; background: rgba(239, 68, 68, 0.1); border-color: rgba(239, 68, 68, 0.3); }
        .toast { margin-bottom: 1.5rem; padding: 0.75rem 1rem; border-radius: 10px; font-size: 0.9rem; color: var(--success); background: rgba(52, 211, 153, 0.1); border: 1px solid rgba(52, 211, 153, 0.3); }

        @media (max-width: 1100px) {
            .profile-grid { grid-template-columns: minmax(0, 1fr); }
        }
        @media (max-width: 640px) {
            .identity-card { padding: 1.5rem; }
            .identity { gap: 1rem; }
            .identity .avatar { width: 60px; height: 60px; font-size: 1.25rem; }
            .stats-grid { gap: 0.75rem; }
            .stat-card { padding: 1rem; }
            .stat-value { font-size: 1.5rem; }
            .profile-card { padding: 1.25rem; }
            .form-grid { grid-template-columns: 1fr; }
            .btn { width: 100%; }
        }
    </style>
</asp:Content>

<asp:Content ID="ContentMain" ContentPlaceHolderID="cphMain" runat="server">

        <div class="profile-container">

            <asp:Panel ID="pnlMessage" runat="server" CssClass="toast" Visible="false">
                <asp:Literal ID="litMessage" runat="server"></asp:Literal>
            </asp:Panel>

            <!-- Identity -->
            <div class="identity-card">
                <div class="identity">
                    <asp:Literal ID="litIdentity" runat="server"></asp:Literal>
                </div>
            </div>

            <!-- Activity -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-value"><asp:Literal ID="litStatGraded" runat="server"></asp:Literal></div>
                    <div class="stat-label">Gradings Submitted</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value"><asp:Literal ID="litStatModerated" runat="server"></asp:Literal></div>
                    <div class="stat-label">Posts Moderated</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value"><asp:Literal ID="litStatReplies" runat="server"></asp:Literal></div>
                    <div class="stat-label">Forum Replies</div>
                </div>
            </div>

            <div class="profile-grid">

                <!-- Personal Details -->
                <section class="profile-card">
                    <h2 class="card-title">Personal Details</h2>
                    <div class="form-grid">

                        <div class="form-group">
                            <label>Full Name</label>
                            <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="Enter your full name"></asp:TextBox>
                        </div>

                        <div class="form-group">
                            <label>Email Address</label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control readonly" ReadOnly="true" ToolTip="Email cannot be changed."></asp:TextBox>
                        </div>

                        <div class="form-group">
                            <label>Region</label>
                            <asp:TextBox ID="txtRegion" runat="server" CssClass="form-control" placeholder="e.g., Kuala Lumpur, Malaysia"></asp:TextBox>
                        </div>

                        <div class="form-group">
                            <label>Teaching Level</label>
                            <asp:DropDownList ID="ddlTeachingLevel" runat="server" CssClass="form-control">
                                <asp:ListItem Text="Beginner" Value="Beginner"></asp:ListItem>
                                <asp:ListItem Text="Intermediate" Value="Intermediate"></asp:ListItem>
                                <asp:ListItem Text="Advanced" Value="Advanced"></asp:ListItem>
                            </asp:DropDownList>
                        </div>

                        <div class="form-group full">
                            <label>Account Status</label>
                            <asp:TextBox ID="txtStatus" runat="server" CssClass="form-control readonly" ReadOnly="true"></asp:TextBox>
                            <span class="help-text">Your email is used for login, and your email and account status cannot be changed here.</span>
                        </div>

                    </div>

                    <div class="action-bar">
                        <asp:Button ID="btnUpdateProfile" runat="server" Text="Update Details" CssClass="btn btn-update" OnClick="btnUpdateProfile_Click" />
                    </div>
                </section>

                <!-- Qualifications -->
                <section class="profile-card">
                    <h2 class="card-title">Qualifications</h2>

                    <asp:PlaceHolder ID="phQualEmpty" runat="server" Visible="false">
                        <p class="empty-state">No qualifications on record.</p>
                    </asp:PlaceHolder>

                    <div class="qual-list">
                        <asp:Repeater ID="rptQualifications" runat="server">
                            <ItemTemplate>
                                <div class="qual-item">
                                    <div class="qual-main">
                                        <div class="qual-name"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></div>
                                        <div class="qual-date">Awarded <%# Eval("Date") %></div>
                                    </div>
                                    <a href='<%# Eval("DocumentUrl") %>' class="qual-doc" runat="server" visible='<%# Eval("HasDocument") %>'>View document &rarr;</a>
                                    <span class="qual-date" runat="server" visible='<%# !(bool)Eval("HasDocument") %>'>No document</span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </section>

            </div>

        </div>
</asp:Content>
