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

        <!-- Server-side Error / Alert within Modal -->
        <asp:Panel ID="pnlModalError" runat="server" Visible="false" style="background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.3); color: #f87171; padding: 10px 14px; border-radius: 6px; font-size: 13px; margin-bottom: 16px; display: flex; align-items: center; gap: 10px;">
            <i class="fa-solid fa-circle-exclamation"></i>
            <div><asp:Literal ID="litModalError" runat="server"></asp:Literal></div>
        </asp:Panel>

        <!-- Form Fields -->
        <div class="admin-form-group">
            <label class="form-label" for="<%= txtAdminFullName.ClientID %>">Full Name <span style="color: var(--danger-red);">*</span></label>
            <asp:TextBox ID="txtAdminFullName" runat="server" CssClass="form-control" placeholder="e.g. Sarah Jenkins" oninput="handleFullNameInput()"></asp:TextBox>
        </div>

        <div class="admin-form-group">
            <label class="form-label" for="<%= txtAdminEmail.ClientID %>">Email Address (Login Username) <span style="color: var(--danger-red);">*</span></label>
            <asp:TextBox ID="txtAdminEmail" runat="server" TextMode="Email" CssClass="form-control" placeholder="e.g. s.jenkins@codercept.edu"></asp:TextBox>
        </div>

        <div class="admin-form-group">
            <label class="form-label" for="<%= ddlAdminRole.ClientID %>">Role Privilege Level <span style="color: var(--danger-red);">*</span></label>
            <asp:DropDownList ID="ddlAdminRole" runat="server" CssClass="form-control form-select">
                <asp:ListItem Value="Admin" Text="Standard Admin (Platform &amp; User Management)" Selected="True"></asp:ListItem>
            </asp:DropDownList>
        </div>

        <div class="admin-form-group">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
                <label class="form-label" for="<%= txtAdminPassword.ClientID %>" style="margin-bottom: 0;">Temporary Password <span style="color: var(--danger-red);">*</span></label>
                <button type="button" class="btn-text-action" onclick="generatePredefinedAdminPassword()">
                    <i class="fa-solid fa-key"></i> Generate Predefined
                </button>
            </div>
            <div style="position: relative;">
                <asp:TextBox ID="txtAdminPassword" runat="server" CssClass="form-control" placeholder="&lt;userFirstName&gt;@1234" style="padding-right: 40px;" oninput="onPasswordInputChanged()"></asp:TextBox>
                <button type="button" class="btn-pwd-toggle" onclick="toggleAdminPasswordVisibility()" title="Toggle visibility">
                    <i class="fa-regular fa-eye" id="pwdToggleIcon"></i>
                </button>
            </div>
            <span style="font-size: 11px; color: var(--text-secondary); margin-top: 4px; display: block;">Format: &lt;userFirstName&gt;@1234 or custom temporary password. This temporary password will be emailed to the administrator.</span>
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
    let passwordCustomizedByUser = false;

    function openAddAdminModal() {
        const modal = document.getElementById('addAdminModal');
        if (modal) modal.classList.add('active');
        const txtName = document.getElementById('<%= txtAdminFullName.ClientID %>');
        if (txtName) txtName.focus();
    }

    function closeAddAdminModal() {
        const modal = document.getElementById('addAdminModal');
        if (modal) modal.classList.remove('active');
    }

    function onPasswordInputChanged() {
        passwordCustomizedByUser = true;
    }

    function toggleAdminPasswordVisibility() {
        const pwdInput = document.getElementById('<%= txtAdminPassword.ClientID %>');
        const icon = document.getElementById('pwdToggleIcon');
        if (!pwdInput) return;

        if (pwdInput.type === 'password' || pwdInput.type === '') {
            pwdInput.type = 'text';
            if (icon) {
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            }
        } else {
            pwdInput.type = 'password';
            if (icon) {
                icon.classList.remove('fa-eye-slash');
                icon.classList.add('fa-eye');
            }
        }
    }

    function getCalculatedPredefinedPassword() {
        const nameInput = document.getElementById('<%= txtAdminFullName.ClientID %>');
        const name = nameInput ? nameInput.value.trim() : '';
        let firstName = 'Admin';
        if (name) {
            const parts = name.split(/\s+/);
            if (parts.length > 0 && parts[0].length > 0) {
                firstName = parts[0];
            }
        }
        return firstName + '@1234';
    }

    function handleFullNameInput() {
        if (!passwordCustomizedByUser) {
            const pwdInput = document.getElementById('<%= txtAdminPassword.ClientID %>');
            if (pwdInput) {
                pwdInput.value = getCalculatedPredefinedPassword();
            }
        }
    }

    function generatePredefinedAdminPassword() {
        passwordCustomizedByUser = false;
        const predefined = getCalculatedPredefinedPassword();
        const pwdInput = document.getElementById('<%= txtAdminPassword.ClientID %>');
        if (pwdInput) {
            pwdInput.value = predefined;
            pwdInput.type = 'text';
            const icon = document.getElementById('pwdToggleIcon');
            if (icon) {
                icon.classList.remove('fa-eye');
                icon.classList.add('fa-eye-slash');
            }
        }
    }

    function validateNewAdminForm() {
        const nameInput = document.getElementById('<%= txtAdminFullName.ClientID %>');
        const emailInput = document.getElementById('<%= txtAdminEmail.ClientID %>');
        let pwdInput = document.getElementById('<%= txtAdminPassword.ClientID %>');

        const name = nameInput ? nameInput.value.trim() : '';
        const email = emailInput ? emailInput.value.trim() : '';
        let pwd = pwdInput ? pwdInput.value.trim() : '';

        if (!name) {
            alert('Please enter the administrator\'s full name.');
            if (nameInput) nameInput.focus();
            return false;
        }

        if (!email || !email.includes('@') || !email.includes('.')) {
            alert('Please enter a valid email address.');
            if (emailInput) emailInput.focus();
            return false;
        }

        if (!pwd) {
            pwd = getCalculatedPredefinedPassword();
            if (pwdInput) pwdInput.value = pwd;
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