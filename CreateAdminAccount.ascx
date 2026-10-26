<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="CreateAdminAccount.ascx.cs" Inherits="Codercept.CreateAdminAccount" %>

<!-- Add New Admin Modal Overlay -->
<div class="modal-overlay" id="addAdminModal">
    <div class="modal-box" style="max-width: 540px;">
        <div class="modal-header-row" style="margin-bottom: 16px; padding-bottom: 16px;">
            <div class="modal-header-left">
                <div class="modal-avatar" style="background: linear-gradient(135deg, #f43f5e, #be123c);">
                    <i class="fa-solid fa-user-shield" style="font-size: 20px;"></i>
                </div>
                <div class="modal-meta">
                    <h3 style="font-size: 18px; font-weight: 600;">Create Administrator</h3>
                    <p style="font-size: 13px; color: var(--text-secondary);">Provision new administrative access to the Codercept platform.</p>
                </div>
            </div>
            <button type="button" class="btn-modal-close" onclick="closeAddAdminModal()"><i class="fa-solid fa-xmark"></i></button>
        </div>

        <!-- Form Fields -->
        <div class="admin-form-group">
            <label class="form-label" for="<%= txtAdminFullName.ClientID %>">Full Name <span style="color: var(--danger-red);">*</span></label>
            <asp:TextBox ID="txtAdminFullName" runat="server" CssClass="form-control" placeholder="e.g. Sarah Jenkins"></asp:TextBox>
        </div>

        <div class="admin-form-group">
            <label class="form-label" for="<%= txtAdminEmail.ClientID %>">Email Address (Login Username) <span style="color: var(--danger-red);">*</span></label>
            <asp:TextBox ID="txtAdminEmail" runat="server" TextMode="Email" CssClass="form-control" placeholder="e.g. s.jenkins@codercept.edu"></asp:TextBox>
        </div>

        <div class="admin-form-group">
            <label class="form-label" for="<%= ddlAdminRole.ClientID %>">Role Privilege Level <span style="color: var(--danger-red);">*</span></label>
            <asp:DropDownList ID="ddlAdminRole" runat="server" CssClass="form-control form-select">
                <asp:ListItem Value="Admin" Text="Standard Admin (Platform & User Management)" Selected="True"></asp:ListItem>
            </asp:DropDownList>
        </div>

        <div class="admin-form-group">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                <label class="form-label" for="<%= txtAdminPassword.ClientID %>" style="margin-bottom: 0;">Temporary Password <span style="color: var(--danger-red);">*</span></label>
                <button type="button" class="btn-text-action" onclick="generateRandomAdminPassword()">
                    <i class="fa-solid fa-dice"></i> Generate Random
                </button>
            </div>
            <div style="position: relative;">
                <asp:TextBox ID="txtAdminPassword" runat="server" CssClass="form-control" placeholder="Minimum 8 characters..." style="padding-right: 40px;"></asp:TextBox>
                <button type="button" class="btn-pwd-toggle" onclick="toggleAdminPasswordVisibility()" title="Toggle visibility">
                    <i class="fa-regular fa-eye" id="pwdToggleIcon"></i>
                </button>
            </div>
        </div>

        <!-- Modal Actions Footer -->
        <div class="modal-footer" style="margin-top: 20px; padding-top: 16px;">
            <button type="button" class="btn-action" onclick="closeAddAdminModal()">Cancel</button>
            <asp:Button ID="btnSubmitAdmin" runat="server" Text="Create Account" CssClass="btn-action btn-submit-admin" 
                OnClick="btnSubmitAdmin_Click" OnClientClick="return validateNewAdminForm();" />
        </div>
    </div>
</div>

<script>
function openAddAdminModal() {
    document.getElementById('addAdminModal').classList.add('active');
    const txtName = document.getElementById('<%= txtAdminFullName.ClientID %>');
        if (txtName) txtName.focus();
    }

    function closeAddAdminModal() {
        const modal = document.getElementById('addAdminModal');
        if (modal) modal.classList.remove('active');
    }

    function toggleAdminPasswordVisibility() {
        const pwdInput = document.getElementById('<%= txtAdminPassword.ClientID %>');
        const icon = document.getElementById('pwdToggleIcon');
        if (!pwdInput) return;

        if (pwdInput.type === 'password' || pwdInput.type === '') {
            pwdInput.type = 'text';
            icon.classList.remove('fa-eye');
            icon.classList.add('fa-eye-slash');
        } else {
            pwdInput.type = 'password';
            icon.classList.remove('fa-eye-slash');
            icon.classList.add('fa-eye');
        }
    }

    function generateRandomAdminPassword() {
        const chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789!@#$%&*';
        let generated = '';
        for (let i = 0; i < 12; i++) {
            generated += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        const pwdInput = document.getElementById('<%= txtAdminPassword.ClientID %>');
        if (pwdInput) {
            pwdInput.type = 'text';
            pwdInput.value = generated;
            const icon = document.getElementById('pwdToggleIcon');
            if (icon) {
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            }
        }
    }

    function validateNewAdminForm() {
        const name = document.getElementById('<%= txtAdminFullName.ClientID %>').value.trim();
        const email = document.getElementById('<%= txtAdminEmail.ClientID %>').value.trim();
        const pwd = document.getElementById('<%= txtAdminPassword.ClientID %>').value.trim();

        if (!name) {
            alert('Please enter the administrator\'s full name.');
            document.getElementById('<%= txtAdminFullName.ClientID %>').focus();
            return false;
        }

        if (!email || !email.includes('@') || !email.includes('.')) {
            alert('Please enter a valid email address.');
            document.getElementById('<%= txtAdminEmail.ClientID %>').focus();
            return false;
        }

        if (!pwd || pwd.length < 8) {
            alert('Password must be at least 8 characters in length.');
            document.getElementById('<%= txtAdminPassword.ClientID %>').focus();
            return false;
        }

        return true;
    }

    // Close on outside backdrop click
    window.addEventListener('click', function (e) {
        const modal = document.getElementById('addAdminModal');
        if (e.target === modal) {
            closeAddAdminModal();
        }
    });
</script>