<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TAProfile.aspx.cs" Inherits="Codercept.TAProfile" %>
<%@ Register Src="~/TASideBar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>My Profile - Codercept</title>

    <!-- 1. Import Global Variables & Shared Layout -->
    <link href="css/global.css" rel="stylesheet" type="text/css" />

    <!-- 2. Page-Specific Styles -->
    <style>
        :root {
            --profile-card-bg: var(--bg-surface);
            --profile-border: var(--border-light);
            --input-bg: var(--bg-main);
            --input-disabled-bg: rgba(255, 255, 255, 0.02);
            --input-disabled-text: var(--text-muted);
            --success: #34d399;
        }

        .page-header { margin-bottom: 2rem; }
        .page-header h1 { font-size: 1.75rem; margin-bottom: 0.25rem; color: var(--text-primary); }
        .page-header p { color: var(--text-secondary); font-size: 1rem; }

        .profile-container { max-width: 900px; }

        .section-title { font-size: 1.25rem; font-weight: 600; color: var(--text-primary); margin-bottom: 1rem; }

        .profile-card { background: var(--profile-card-bg); border: 1px solid var(--profile-border); border-radius: 12px; padding: 2.5rem; margin-bottom: 2rem; }

        /* Activity stats */
        .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.5rem; margin-bottom: 2rem; }
        .stat-card { background: var(--profile-card-bg); border: 1px solid var(--profile-border); padding: 1.5rem; border-radius: 12px; }
        .stat-value { font-size: 2rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.25rem; }
        .stat-label { font-size: 0.85rem; color: var(--text-secondary); }

        /* Form */
        .form-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem 2rem; }
        .form-group { display: flex; flex-direction: column; }
        .form-group label { font-size: 0.9rem; font-weight: 600; color: var(--text-primary); margin-bottom: 0.5rem; }

        .form-control { background: var(--input-bg); border: 1px solid var(--profile-border); padding: 0.875rem 1rem; border-radius: 8px; color: var(--text-primary); font-size: 0.95rem; outline: none; transition: border-color 0.2s; width: 100%; }
        .form-control:focus { border-color: var(--accent-primary); }
        .form-control.readonly { background: var(--input-disabled-bg); color: var(--input-disabled-text); cursor: not-allowed; }
        .form-control.readonly:focus { border-color: var(--profile-border); }
        select.form-control { appearance: auto; }

        .help-text { font-size: 0.8rem; color: var(--text-muted); margin-top: 0.4rem; }

        /* Qualifications */
        .qual-list { display: flex; flex-direction: column; gap: 0.75rem; }
        .qual-item { display: flex; justify-content: space-between; align-items: center; gap: 1rem; padding: 1rem 1.25rem; border: 1px solid var(--profile-border); border-radius: 10px; background: rgba(255, 255, 255, 0.02); }
        .qual-name { font-weight: 600; color: var(--text-primary); font-size: 0.95rem; margin-bottom: 0.2rem; }
        .qual-date { font-size: 0.8rem; color: var(--text-muted); }
        .qual-doc { font-size: 0.85rem; font-weight: 600; color: var(--accent-light); text-decoration: none; white-space: nowrap; }
        .qual-doc:hover { color: var(--accent-hover); text-decoration: underline; }
        .empty-state { color: var(--text-muted); font-size: 0.9rem; text-align: center; padding: 1rem 0; }

        /* Actions */
        .action-bar { display: flex; justify-content: flex-end; gap: 1rem; padding-top: 1rem; }
        .btn { padding: 0.75rem 1.5rem; border-radius: 8px; font-weight: 600; font-size: 0.95rem; cursor: pointer; transition: all 0.2s; border: none; }
        .btn-update { background: var(--accent-primary); color: #ffffff; }
        .btn-update:hover { background: var(--accent-hover); }

        .toast { margin-bottom: 1.5rem; padding: 0.75rem 1rem; border-radius: 8px; font-size: 0.9rem; color: var(--success); background: rgba(52, 211, 153, 0.1); border: 1px solid rgba(52, 211, 153, 0.3); }

        @media (max-width: 768px) {
            .form-grid { grid-template-columns: 1fr; }
            .stats-grid { grid-template-columns: 1fr; }
            .action-bar { flex-direction: column-reverse; }
            .btn { width: 100%; }
            .qual-item { flex-direction: column; align-items: flex-start; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="dashboard-layout">

            <!-- Sidebar Injected Here -->
            <uc:Sidebar runat="server" ID="TASideBarCtrl" />

            <!-- Main Content -->
            <main class="main-content">

                <div class="profile-container">
                    <div class="page-header">
                        <h1>My Profile</h1>
                        <p>View your teaching assistant activity and update your details.</p>
                    </div>

                    <asp:Panel ID="pnlMessage" runat="server" CssClass="toast" Visible="false">
                        <asp:Literal ID="litMessage" runat="server"></asp:Literal>
                    </asp:Panel>

                    <!-- Activity -->
                    <h2 class="section-title">My Activity</h2>
                    <div class="stats-grid">
                        <div class="stat-card">
                            <div class="stat-value"><asp:Literal ID="litStatGraded" runat="server"></asp:Literal></div>
                            <div class="stat-label">Submissions Marked</div>
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

                    <!-- Personal Details -->
                    <h2 class="section-title">Personal Details</h2>
                    <div class="profile-card">
                        <div class="form-grid">

                            <div class="form-group">
                                <label>Full Name</label>
                                <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="Enter your full name"></asp:TextBox>
                            </div>

                            <div class="form-group">
                                <label>Email Address</label>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control readonly" ReadOnly="true" ToolTip="Email cannot be changed."></asp:TextBox>
                                <span class="help-text">Your email is used for login and cannot be changed.</span>
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

                            <div class="form-group">
                                <label>Account Status</label>
                                <asp:TextBox ID="txtStatus" runat="server" CssClass="form-control readonly" ReadOnly="true"></asp:TextBox>
                            </div>

                        </div>
                    </div>

                    <!-- Qualifications -->
                    <h2 class="section-title">Qualifications</h2>
                    <div class="profile-card">
                        <asp:PlaceHolder ID="phQualEmpty" runat="server" Visible="false">
                            <p class="empty-state">No qualifications on record.</p>
                        </asp:PlaceHolder>

                        <div class="qual-list">
                            <asp:Repeater ID="rptQualifications" runat="server">
                                <ItemTemplate>
                                    <div class="qual-item">
                                        <div>
                                            <div class="qual-name"><%# Server.HtmlEncode(Convert.ToString(Eval("Name"))) %></div>
                                            <div class="qual-date">Awarded <%# Eval("Date") %></div>
                                        </div>
                                        <a href='<%# Eval("DocumentUrl") %>' class="qual-doc">View document &rarr;</a>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="action-bar">
                        <asp:Button ID="btnUpdateProfile" runat="server" Text="Update Details" CssClass="btn btn-update" OnClick="btnUpdateProfile_Click" />
                    </div>

                </div>
            </main>
        </div>
    </form>
</body>
</html>
