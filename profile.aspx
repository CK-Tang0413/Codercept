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
            --profile-card-bg: var(--bg-surface);
            --profile-border: var(--border-light);
            --input-bg: var(--bg-main);
            --input-disabled-bg: rgba(255, 255, 255, 0.02);
            --input-disabled-text: var(--text-muted);
            
            --btn-danger-bg: rgba(239, 68, 68, 0.1);
            --btn-danger-text: #ef4444;
            --btn-danger-hover: #ef4444;
            --btn-danger-hover-text: #ffffff;
        }

        /* Header */
        .page-header { margin-bottom: 2rem; }
        .page-header h1 { font-size: 1.75rem; margin-bottom: 0.25rem; color: var(--text-primary); }
        .page-header p { color: var(--text-secondary); font-size: 1rem; }

        /* Profile Container - Expanded screen-wide */
        .profile-container {
            width: 100%;
            max-width: 100%;
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
            box-shadow: var(--shadow);
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

        /* Custom Delete Modal Overlay */
        .modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(15, 23, 42, 0.6);
            backdrop-filter: blur(4px);
            z-index: 9999;
            align-items: center;
            justify-content: center;
        }
        .modal-overlay.open {
            display: flex;
        }

        .modal-card {
            background: var(--profile-card-bg);
            border: 1px solid var(--profile-border);
            width: 100%;
            max-width: 480px;
            border-radius: 16px;
            padding: 2rem;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
            display: flex;
            flex-direction: column;
            gap: 1.25rem;
            animation: modalPop 0.25s ease-out;
        }

        @keyframes modalPop {
            0% { transform: scale(0.95); opacity: 0; }
            100% { transform: scale(1); opacity: 1; }
        }

        .modal-icon-wrapper {
            width: 48px;
            height: 48px;
            border-radius: 50%;
            background: rgba(239, 68, 68, 0.1);
            color: #ef4444;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .modal-title {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--text-primary);
        }

        .modal-desc {
            font-size: 0.9rem;
            color: var(--text-secondary);
            line-height: 1.5;
        }

        .modal-desc strong {
            color: var(--text-primary);
        }

        .modal-actions {
            display: flex;
            gap: 1rem;
            margin-top: 0.5rem;
        }

        .modal-actions .btn {
            flex: 1;
            text-align: center;
        }

        .btn-modal-cancel {
            background: var(--input-bg);
            border: 1px solid var(--profile-border);
            color: var(--text-primary);
        }
        .btn-modal-cancel:hover {
            background: var(--profile-border);
        }

        .btn-modal-danger {
            background: #ef4444;
            color: #ffffff;
        }
        .btn-modal-danger:hover {
            background: #dc2626;
        }
        .btn-modal-danger:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        /* Success Toast Notification */
        .toast-notification {
            position: fixed;
            bottom: 2.5rem;
            right: 2.5rem;
            background: #10b981; /* Emerald green */
            color: #ffffff;
            padding: 1rem 1.5rem;
            border-radius: 10px;
            font-weight: 600;
            font-size: 0.95rem;
            box-shadow: 0 10px 25px rgba(16, 185, 129, 0.4);
            display: flex;
            align-items: center;
            gap: 0.75rem;
            z-index: 10000;
            pointer-events: none;
            /* Slides in, stays for 3 seconds, then fades out */
            animation: slideInUp 0.4s ease-out forwards, fadeOut 0.4s ease-in 3.5s forwards;
            opacity: 0;
            transform: translateY(20px);
        }

        @keyframes slideInUp {
            to { opacity: 1; transform: translateY(0); }
        }
        @keyframes fadeOut {
            to { opacity: 0; transform: translateY(20px); visibility: hidden; }
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
            .modal-card {
                margin: 1rem;
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
                        <!-- Changed to trigger JavaScript Modal instead of built-in confirm() -->
                        <button type="button" class="btn btn-delete" onclick="openDeleteModal()">Delete Account</button>
                        <asp:Button ID="btnUpdateProfile" runat="server" Text="Update Details" CssClass="btn btn-update" OnClick="btnUpdateProfile_Click" />
                    </div>

                </div>
            </main>
        </div>

        <!-- Delete Account Confirmation Modal -->
        <div class="modal-overlay" id="deleteModal">
            <div class="modal-card">
                <div class="modal-icon-wrapper">
                    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                </div>
                <div>
                    <h3 class="modal-title">Delete your account?</h3>
                    <p class="modal-desc" style="margin-top: 0.5rem;">
                        This deactivates your account and signs you out; you will not be able to sign in again. Your course progress and results will be removed. Type <strong id="lblUserEmail"></strong> to confirm.
                    </p>
                </div>

                <div class="form-group" style="margin-bottom: 0;">
                    <label style="font-size: 0.85rem; margin-bottom: 0.3rem;">Email address</label>
                    <input type="text" id="txtConfirmEmail" class="form-control" placeholder="Enter your email address" oninput="validateDeleteInput()" autocomplete="off" />
                </div>

                <div class="modal-actions">
                    <button type="button" class="btn btn-modal-cancel" onclick="closeDeleteModal()">Cancel</button>
                    <asp:Button ID="btnConfirmDelete" runat="server" Text="Delete Account" CssClass="btn btn-modal-danger" ClientIDMode="Static" Enabled="false" OnClick="btnDeleteAccount_Click" />
                </div>
            </div>
        </div>

        <!-- Success Toast (Hidden by default) -->
        <asp:Panel ID="pnlToast" runat="server" CssClass="toast-notification" Visible="false">
            <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
            </svg>
            <span>Profile details updated successfully!</span>
        </asp:Panel>
    </form>

    <!-- Modal Client Script -->
    <script type="text/javascript">
function openDeleteModal() {
    var modal = document.getElementById('deleteModal');
    var userEmail = document.getElementById('<%= txtEmail.ClientID %>').value;
            document.getElementById('lblUserEmail').innerText = userEmail;
            document.getElementById('txtConfirmEmail').value = '';
            document.getElementById('btnConfirmDelete').disabled = true;
            if (modal) modal.classList.add('open');
        }

        function closeDeleteModal() {
            var modal = document.getElementById('deleteModal');
            if (modal) modal.classList.remove('open');
        }

        function validateDeleteInput() {
            var userEmail = document.getElementById('<%= txtEmail.ClientID %>').value.trim().toLowerCase();
            var typedEmail = document.getElementById('txtConfirmEmail').value.trim().toLowerCase();
            var deleteBtn = document.getElementById('btnConfirmDelete');

            if (typedEmail === userEmail) {
                deleteBtn.removeAttribute('disabled');
            } else {
                deleteBtn.setAttribute('disabled', 'disabled');
            }
        }

        // Close modal if clicking outside the card
        window.onclick = function(event) {
            var modal = document.getElementById('deleteModal');
            if (event.target == modal) {
                closeDeleteModal();
            }
        }
    </script>
</body>
</html>