<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="profile.aspx.cs" Inherits="Codercept.profile" %>
<%@ Register Src="~/LearnerSideBar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>My Account - Codercept</title>

    <!-- 1. Import Global Variables & Shared Layout -->
    <link href="css/global.css" rel="stylesheet" type="text/css" />

    <!-- 2. Page-Specific Styles -->
    <style>
        :root {
            /* Local variables for Profile */
            --profile-card-bg: var(--bg-surface);
            --profile-border: var(--border-light);
            --input-bg: var(--bg-main);
            --input-disabled-bg: rgba(255, 255, 255, 0.02);
            --input-disabled-text: var(--text-muted);
            
            /* Button Colors */
            --btn-danger-bg: rgba(239, 68, 68, 0.1);
            --btn-danger-text: #ef4444;
            --btn-danger-hover: #ef4444;
            --btn-danger-hover-text: #ffffff;
        }

        /* Header */
        .page-header { margin-bottom: 2rem; }
        .page-header h1 { font-size: 1.75rem; margin-bottom: 0.25rem; color: var(--text-primary); }
        .page-header p { color: var(--text-secondary); font-size: 1rem; }

        /* Profile Card */
        .profile-container {
            max-width: 900px;
        }

        .section-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 1rem;
        }

        .profile-card {
            background: var(--profile-card-bg);
            border: 1px solid var(--profile-border);
            border-radius: 12px;
            padding: 2.5rem;
            margin-bottom: 2rem;
        }

        /* Form Grid Layout */
        .form-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1.5rem 2rem;
        }

        .form-group {
            display: flex;
            flex-direction: column;
        }

        .form-group.full-width {
            grid-column: 1 / -1;
        }

        .form-group label {
            font-size: 0.9rem;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 0.5rem;
        }

        .form-control {
            background: var(--input-bg);
            border: 1px solid var(--profile-border);
            padding: 0.875rem 1rem;
            border-radius: 8px;
            color: var(--text-primary);
            font-size: 0.95rem;
            outline: none;
            transition: border-color 0.2s;
            width: 100%;
        }

        .form-control:focus {
            border-color: var(--accent-primary);
        }

        /* Read-only fields styling */
        .form-control.readonly {
            background: var(--input-disabled-bg);
            color: var(--input-disabled-text);
            cursor: not-allowed;
        }
        .form-control.readonly:focus {
            border-color: var(--profile-border);
        }

        .help-text {
            font-size: 0.8rem;
            color: var(--text-muted);
            margin-top: 0.4rem;
        }

        /* Action Buttons */
        .action-bar {
            display: flex;
            justify-content: flex-end;
            gap: 1rem;
            padding-top: 1rem;
        }

        .btn {
            padding: 0.75rem 1.5rem;
            border-radius: 8px;
            font-weight: 600;
            font-size: 0.95rem;
            cursor: pointer;
            transition: all 0.2s;
            border: none;
        }

        .btn-update {
            background: var(--accent-primary);
            color: #ffffff;
        }
        .btn-update:hover {
            background: var(--accent-hover);
        }

        .btn-delete {
            background: var(--btn-danger-bg);
            color: var(--btn-danger-text);
            border: 1px solid transparent;
        }
        .btn-delete:hover {
            background: var(--btn-danger-hover);
            color: var(--btn-danger-hover-text);
        }

        @media (max-width: 768px) {
            .form-grid {
                grid-template-columns: 1fr;
            }
            .action-bar {
                flex-direction: column-reverse;
            }
            .btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="dashboard-layout">
            
            <!-- Sidebar Injected Here -->
            <uc:Sidebar runat="server" ID="LearnerSideBarCtrl" />

            <!-- Main Content -->
            <main class="main-content">
                
                <div class="profile-container">
                    <div class="page-header">
                        <h1>My Account</h1>
                        <p>View and update your personal information and contact details.</p>
                    </div>

                    <h2 class="section-title">Personal Details</h2>
                    
                    <div class="profile-card">
                        <div class="form-grid">
                            
                            <!-- Name Field -->
                            <div class="form-group">
                                <label>Full Name</label>
                                <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="Enter your full name"></asp:TextBox>
                            </div>

                            <!-- Age Field -->
                            <div class="form-group">
                                <label>Age</label>
                                <asp:TextBox ID="txtAge" runat="server" CssClass="form-control" TextMode="Number" placeholder="Enter your age"></asp:TextBox>
                            </div>

                            <!-- Email Field (Read-only) -->
                            <div class="form-group">
                                <label>Email Address</label>
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control readonly" ReadOnly="true" ToolTip="Email cannot be changed."></asp:TextBox>
                                <span class="help-text">Your email is used for login and cannot be changed.</span>
                            </div>

                            <!-- Role/Occupation Field -->
                            <div class="form-group">
                                <label>Occupation / Role</label>
                                <asp:TextBox ID="txtOccupation" runat="server" CssClass="form-control" placeholder="e.g., Student"></asp:TextBox>
                            </div>

                            <!-- Date Joined Field (Read-only) -->
                            <div class="form-group">
                                <label>Member Since</label>
                                <asp:TextBox ID="txtDateJoined" runat="server" CssClass="form-control readonly" ReadOnly="true"></asp:TextBox>
                            </div>

                            <!-- Address Field (Full Width) -->
                            <div class="form-group full-width">
                                <label>Address</label>
                                <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="Enter your full address"></asp:TextBox>
                            </div>

                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="action-bar">
                        <asp:Button ID="btnDeleteAccount" runat="server" Text="Delete Account" CssClass="btn btn-delete" OnClientClick="return confirm('Are you sure you want to delete your account? This action cannot be undone and all progress will be lost.');" OnClick="btnDeleteAccount_Click" />
                        <asp:Button ID="btnUpdateProfile" runat="server" Text="Update Details" CssClass="btn btn-update" OnClick="btnUpdateProfile_Click" />
                    </div>

                </div>
            </main>
        </div>
    </form>
</body>
</html>