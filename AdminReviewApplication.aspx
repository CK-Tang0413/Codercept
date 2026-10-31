<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminReviewApplication.aspx.cs" Inherits="Codercept.AdminReviewApplication" %>
<%@ Register Src="~/AdminSidebar.ascx" TagPrefix="uc" TagName="AdminSidebar" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Review Application - CodeLearn</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="css/admin-portal.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
        <style>
        /* Applicant Overview Banner */
        .breadcrumb-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 24px;
        }

        .applicant-header-card {
            background-color: var(--bg-panel);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 24px 28px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 24px;
            box-shadow: var(--shadow);
        }

        .applicant-identity {
            display: flex;
            align-items: center;
            gap: 20px;
        }

        .applicant-avatar {
            width: 56px;
            height: 56px;
            border-radius: 50%;
            background: linear-gradient(135deg, #4338ca, #6366f1);
            color: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            font-weight: 700;
        }

        .applicant-meta h2 {
            font-size: 20px;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 4px;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .applicant-meta p {
            color: var(--text-secondary);
            font-size: 14px;
        }

        .role-badge {
            display: inline-flex;
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 600;
        }

        /* Grid of Details */
        .details-grid {
            display: grid;
            grid-template-columns: 1.6fr 1fr;
            gap: 24px;
            margin-bottom: 32px;
        }

        @media (max-width: 900px) {
            .details-grid { grid-template-columns: 1fr; }
        }

        /* Decision Action Footer */
        .decision-bar {
            background-color: var(--bg-panel);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 20px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: var(--shadow);
        }

        .decision-text h4 {
            font-size: 15px;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 2px;
        }

        .decision-text p {
            color: var(--text-secondary);
            font-size: 13px;
        }

        .decision-buttons {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .btn-decision {
            padding: 10px 20px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
            border: none;
        }

        .btn-approve-lg {
            background-color: var(--success-green);
            color: white;
        }
        .btn-approve-lg:hover { background-color: var(--success-green-hover); }

        .btn-reject-lg {
            background-color: transparent;
            color: var(--danger-red);
            border: 1px solid var(--danger-red-border);
        }
        .btn-reject-lg:hover {
            background-color: var(--danger-red-bg);
        }

        /* Document Viewer Mockup inside Modal */
        .doc-preview-body {
            flex: 1;
            background-color: var(--bg-surface-nested);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            margin: 12px 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            color: var(--text-secondary);
            text-align: center;
            padding: 40px;
        }
        .doc-preview-body i {
            font-size: 48px;
            color: var(--accent-purple);
            margin-bottom: 16px;
        }

        /* Feedback / Notes Area */
        .feedback-card {
            background-color: var(--bg-panel);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: var(--shadow);
        }

        .feedback-hint {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-top: 10px;
            font-size: 12px;
            color: var(--text-secondary);
        }
        .feedback-hint i {
            color: var(--warning-orange-text);
        }
        /* Custom Rejection & Confirmation Modal Styles */
        .confirm-icon-badge {
            width: 44px;
            height: 44px;
            border-radius: 10px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            flex-shrink: 0;
        }

        .confirm-icon-badge.danger {
            background: var(--danger-red-bg);
            color: var(--danger-red);
            border: 1px solid var(--danger-red-border);
        }

        .confirm-icon-badge.success {
            background: var(--success-green-bg);
            color: var(--success-green);
            border: 1px solid var(--success-green-border);
        }

        .modal-warning-banner {
            background-color: #fff1f2;
            border: 1px solid #fecdd3;
            border-radius: 8px;
            padding: 12px 14px;
            margin-bottom: 16px;
            display: flex;
            align-items: flex-start;
            gap: 12px;
            color: #9f1239;
            font-size: 13px;
            line-height: 1.45;
        }

        .modal-warning-banner i {
            font-size: 16px;
            color: var(--danger-red);
            margin-top: 2px;
            flex-shrink: 0;
        }

        .modal-info-banner {
            background-color: #f0fdf4;
            border: 1px solid #bbf7d0;
            border-radius: 8px;
            padding: 12px 14px;
            margin-bottom: 16px;
            display: flex;
            align-items: flex-start;
            gap: 12px;
            color: #166534;
            font-size: 13px;
            line-height: 1.45;
        }

        .modal-info-banner i {
            font-size: 16px;
            color: var(--success-green);
            margin-top: 2px;
            flex-shrink: 0;
        }

        .quick-reasons-wrapper {
            margin-bottom: 10px;
        }

        .quick-reasons-label {
            font-size: 11px;
            color: var(--text-secondary);
            margin-bottom: 6px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .quick-reasons-group {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
        }

        .quick-reason-pill {
            background: var(--bg-surface-nested);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            padding: 4px 10px;
            font-size: 11px;
            color: var(--text-secondary);
            cursor: pointer;
            transition: all 0.15s ease;
        }

        .quick-reason-pill:hover {
            background: var(--danger-red-bg);
            border-color: var(--danger-red-border);
            color: var(--danger-red);
        }

        .modal-reason-textarea {
            width: 100%;
            min-height: 105px;
            box-sizing: border-box;
            font-size: 13px;
            font-family: inherit;
            padding: 10px 12px;
            border-radius: 8px;
            border: 1px solid var(--border-color);
            background-color: #ffffff;
            color: var(--text-primary);
            resize: vertical;
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        .modal-reason-textarea:focus {
            outline: none;
            border-color: var(--danger-red);
            box-shadow: 0 0 0 3px rgba(220, 38, 38, 0.12);
        }

        .modal-error-alert {
            margin-top: 8px;
            padding: 8px 12px;
            background-color: var(--danger-red-bg);
            border: 1px solid var(--danger-red-border);
            border-radius: 6px;
            color: var(--danger-red);
            font-size: 12px;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
            animation: modalFadeIn 0.2s ease;
        }

        @keyframes modalFadeIn {
            from { opacity: 0; transform: translateY(-4px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .btn-danger-confirm {
            background-color: var(--danger-red);
            color: #ffffff;
            border: none;
            padding: 9px 18px;
            border-radius: 8px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: background 0.2s, transform 0.1s;
        }

        .btn-danger-confirm:hover {
            background-color: #dc2626;
        }

        .btn-danger-confirm:active {
            transform: scale(0.98);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div style="display: flex; height: 100vh; width: 100%; overflow: hidden;">
            <!-- Shared Admin Sidebar -->
            <uc:AdminSidebar runat="server" ID="SidebarCtrl" />

            <!-- Main Content Pane -->
            <main class="main-content" style="flex: 1; overflow-y: auto;">
                <div class="review-wrapper">
                    
                    <!-- Navigation / Back row -->
                    <div class="breadcrumb-row">
                        <asp:HiddenField ID="hfApplicantUserId" runat="server" />
                    <asp:HiddenField ID="hfApplicantRole" runat="server" />
                    <asp:HiddenField ID="hfApplicationId" runat="server" />
                    <asp:HiddenField ID="hfApplicantName" runat="server" />
                    <asp:HiddenField ID="hfApplicantEmail" runat="server" />
                    <a href="AdminUserManagement.aspx?tab=pending" class="btn-back">
                            <i class="fa-solid fa-arrow-left"></i> Back to User Management
                        </a>
                        <span class="status-pill">
                            <i class="fa-solid fa-clock"></i> Application Pending Review
                        </span>
                    </div>

                    <!-- Applicant Header Card -->
                    <div class="applicant-header-card">
                        <div class="applicant-identity">
                            <div class="applicant-avatar"><asp:Literal ID="litAvatarInitials" runat="server">EW</asp:Literal></div>
                            <div class="applicant-meta">
                                <h2>
                                    <asp:Literal ID="litFullName" runat="server" Text="Emma Wilson"></asp:Literal>
                                    <asp:Literal ID="litRoleBadge" runat="server"><span class="role-badge badge-teacher">Teacher Applicant</span></asp:Literal>
                                </h2>
                                <p><asp:Literal ID="litEmail" runat="server" Text="emma.wilson@codelearn.edu"></asp:Literal> &bull; <asp:Literal ID="litAppliedDate" runat="server">Applied on 2024-08-20</asp:Literal></p>
                            </div>
                        </div>
                    </div>

                    <!-- Details Grid -->
                    <div class="details-grid">
                        
                        <!-- Left Panel: Academic & Technical Profile -->
                        <div class="info-card">
                            <div class="info-card-title">
                                <i class="fa-solid fa-graduation-cap"></i> Academic & Technical Profile
                            </div>

                            <div class="info-row">
                                <span class="info-label">Applied Role</span>
                                <span class="info-value"><asp:Literal ID="litAppliedRole" runat="server">Teacher</asp:Literal></span>
                            </div>

                            <div class="info-row">
                                <span class="info-label">Highest Qualification Level</span>
                                <span class="info-value"><asp:Literal ID="litQualificationName" runat="server">Master of Science in Computer Science</asp:Literal></span>
                            </div>

                            <div class="info-row">
                                <span class="info-label">Subject Area / Specialization</span>
                                <span class="info-value"><asp:Literal ID="litSpecialization" runat="server">Software Engineering &amp; Distributed Systems</asp:Literal></span>
                            </div>

                            <div class="info-row" style="align-items: flex-start;">
                                <span class="info-label">Proficient Programming Languages</span>
                                <div class="chip-group">
                                    <asp:Literal ID="litLanguages" runat="server"></asp:Literal>
                                </div>
                            </div>
                        </div>

                        <!-- Right Panel: Attached Documents -->
                        <div class="info-card">
                            <div class="info-card-title">
                                <i class="fa-solid fa-file-lines"></i> Verification Documents
                            </div>

                            <div class="docs-list">
                                <asp:Literal ID="litDocuments" runat="server"></asp:Literal>
                            </div>
                        </div>
                    </div>

                    <!-- Admin Remarks & Reason Area -->
                    <div class="feedback-card">
                        <div class="info-card-title">
                            <i class="fa-solid fa-comment-dots"></i> Admin Review Remarks & Feedback
                        </div>
    
                        <label class="form-label" for="txtAdminRemarks" style="margin-bottom: 8px;">
                            Comments / Reason for Rejection 
                            <span style="font-weight: 400; color: var(--text-secondary); font-size: 12px;">(Mandatory if rejecting; optional for approval notes)</span>
                        </label>

                        <asp:TextBox ID="txtAdminRemarks" runat="server" TextMode="MultiLine" CssClass="form-textarea" 
                            placeholder="Enter internal review notes or specify the exact reason for rejection (e.g., Attached certificate is unverified or blurred)..."></asp:TextBox>

                        <div class="feedback-hint">
                            <i class="fa-solid fa-circle-info"></i>
                            If rejected, this message will be recorded in the audit log and emailed directly to the applicant.
                        </div>
                    </div>

                    <!-- Decision Action Footer -->
                    <div class="decision-bar">
                        <div class="decision-text">
                            <h4>Application Decision</h4>
                            <p>Approving will grant teacher privileges. Rejecting will notify the candidate with the stated reason.</p>
                        </div>
                        <div class="decision-buttons">
                            <!-- Pop-out modal triggers replacing browser interface -->
                            <button type="button" class="btn-decision btn-reject-lg" onclick="openRejectModal()">
                                <i class="fa-solid fa-xmark"></i> Reject Application
                            </button>

                            <button type="button" class="btn-decision btn-approve-lg" onclick="openApproveModal()">
                                <i class="fa-solid fa-check"></i> Approve Application
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Document Viewer Modal -->
                <div class="modal-overlay" id="docModal">
                    <div class="modal-box large">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
                            <h3 id="docModalTitle" style="color: var(--text-primary); font-size: 18px; font-weight: 600;">Document Viewer</h3>
                            <button type="button" class="btn-view-doc" onclick="closeDocModal()"><i class="fa-solid fa-xmark"></i> Close</button>
                        </div>

                        <!-- Dynamic Container that switches based on file extension -->
                        <div id="dynamicPreviewContainer" style="flex: 1; min-height: 480px; display: flex; align-items: center; justify-content: center; background: #0b0c10; border-radius: 8px; border: 1px solid var(--border-color); overflow: hidden;">
                            <!-- Content injected via JavaScript -->
                        </div>

                        <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 14px;">
                            <a id="btnDocExternal" href="#" class="btn-view-doc" target="_blank">
                                <i class="fa-solid fa-arrow-up-right-from-square"></i> Open in New Tab
                            </a>
                            <button type="button" class="btn-modal-cancel" onclick="closeDocModal()">Done Reading</button>
                        </div>
                    </div>
                </div>

                <!-- Pop-out Rejection Confirmation Modal -->
                <div class="modal-overlay" id="rejectModal" role="dialog" aria-modal="true" aria-labelledby="rejectModalTitle">
                    <div class="modal-container" style="max-width: 540px;">
                        <div class="modal-header-row">
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div class="confirm-icon-badge danger">
                                    <i class="fa-solid fa-triangle-exclamation"></i>
                                </div>
                                <div>
                                    <h3 id="rejectModalTitle" style="font-size: 18px; font-weight: 600; color: var(--text-primary); margin: 0;">Reject Application</h3>
                                    <p style="font-size: 12px; color: var(--text-secondary); margin-top: 2px;">
                                        Applicant: <strong id="modalApplicantNameReject" style="color: var(--text-primary);"></strong>
                                    </p>
                                </div>
                            </div>
                            <button type="button" class="btn-modal-close" onclick="closeRejectModal()" aria-label="Close modal">
                                <i class="fa-solid fa-xmark"></i>
                            </button>
                        </div>

                        <div>
                            <div class="modal-warning-banner">
                                <i class="fa-solid fa-circle-exclamation"></i>
                                <div>
                                    This action will decline this application and mark the account status as <strong>Rejected</strong>. An official notification email containing your specified reason will be dispatched to the applicant.
                                </div>
                            </div>

                            <div style="margin-bottom: 14px;">
                                <label for="modalRejectReason" class="form-label" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                                    <span>Reason for Rejection <span style="color: var(--danger-red);">*</span></span>
                                    <span style="font-size: 11px; font-weight: 400; color: var(--text-muted);">Required for email & audit record</span>
                                </label>

                                <div class="quick-reasons-wrapper">
                                    <div class="quick-reasons-label">
                                        <i class="fa-solid fa-bolt" style="color: var(--warning-orange);"></i> Quick presets:
                                    </div>
                                    <div class="quick-reasons-group">
                                        <button type="button" class="quick-reason-pill" onclick="selectQuickReason('Attached credential document is unverified or blurred.')">Blurred / Unverified Doc</button>
                                        <button type="button" class="quick-reason-pill" onclick="selectQuickReason('Qualifications provided do not meet the minimum criteria for this role.')">Criteria Not Met</button>
                                        <button type="button" class="quick-reason-pill" onclick="selectQuickReason('Subject area specialization does not align with current course offerings.')">Subject Mismatch</button>
                                        <button type="button" class="quick-reason-pill" onclick="selectQuickReason('Incomplete application profile or missing required verification details.')">Incomplete Info</button>
                                    </div>
                                </div>

                                <textarea id="modalRejectReason" class="modal-reason-textarea" rows="4"
                                    placeholder="Enter specific feedback or reason for rejection..."></textarea>

                                <div id="rejectModalError" class="modal-error-alert" style="display: none;">
                                    <i class="fa-solid fa-circle-exclamation"></i>
                                    <span>Please provide a rejection reason before confirming.</span>
                                </div>
                            </div>
                        </div>

                        <div class="modal-actions" style="margin-top: 18px; padding-top: 16px; border-top: 1px solid var(--border-color); display: flex; justify-content: flex-end; gap: 12px;">
                            <button type="button" class="btn-cancel" onclick="closeRejectModal()">Cancel</button>
                            <asp:Button ID="btnRejectApplication" runat="server" Text="Confirm & Reject Application" 
                                CssClass="btn-danger-confirm" OnClick="btnRejectApplication_Click" 
                                OnClientClick="return confirmRejectModal();" />
                        </div>
                    </div>
                </div>

                <!-- Pop-out Approval Confirmation Modal -->
                <div class="modal-overlay" id="approveModal" role="dialog" aria-modal="true" aria-labelledby="approveModalTitle">
                    <div class="modal-container" style="max-width: 500px;">
                        <div class="modal-header-row">
                            <div style="display: flex; align-items: center; gap: 12px;">
                                <div class="confirm-icon-badge success">
                                    <i class="fa-solid fa-check"></i>
                                </div>
                                <div>
                                    <h3 id="approveModalTitle" style="font-size: 18px; font-weight: 600; color: var(--text-primary); margin: 0;">Approve Application</h3>
                                    <p style="font-size: 12px; color: var(--text-secondary); margin-top: 2px;">
                                        Applicant: <strong id="modalApplicantNameApprove" style="color: var(--text-primary);"></strong>
                                    </p>
                                </div>
                            </div>
                            <button type="button" class="btn-modal-close" onclick="closeApproveModal()" aria-label="Close modal">
                                <i class="fa-solid fa-xmark"></i>
                            </button>
                        </div>

                        <div>
                            <div class="modal-info-banner">
                                <i class="fa-solid fa-circle-check"></i>
                                <div>
                                    Approving this application will activate the educator's account, grant teaching privileges, and send a welcome email with their login confirmation.
                                </div>
                            </div>
                            <p style="font-size: 13px; color: var(--text-secondary); line-height: 1.5;">
                                Are you sure you want to approve this educator? Any notes entered in the review remarks will also be included in the email.
                            </p>
                        </div>

                        <div class="modal-actions" style="margin-top: 20px; padding-top: 16px; border-top: 1px solid var(--border-color); display: flex; justify-content: flex-end; gap: 12px;">
                            <button type="button" class="btn-cancel" onclick="closeApproveModal()">Cancel</button>
                            <asp:Button ID="btnApproveApplication" runat="server" Text="Confirm & Approve Application" 
                                CssClass="btn-decision btn-approve-lg" OnClick="btnApproveApplication_Click" />
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </form>

    <script>
        // @ts-nocheck
        function openDocModal(docTitle, fileUrl) {
            var titleEl = document.getElementById('docModalTitle');
            if (titleEl) titleEl.innerText = docTitle;

            var btnExternal = document.getElementById('btnDocExternal');
            if (btnExternal) btnExternal.href = fileUrl;

            var container = document.getElementById('dynamicPreviewContainer');
            if (!container) return;
            container.innerHTML = '';

            var cleanUrl = (fileUrl || '').split('?')[0].split('#')[0];
            var ext = cleanUrl.split('.').pop().toLowerCase();

            if (ext === 'pdf') {
                container.innerHTML = '<iframe src="' + fileUrl + '" style="width: 100%; height: 100%; min-height: 500px; border: none;"></iframe>';
            }
            else if (['png', 'jpg', 'jpeg', 'webp', 'gif'].includes(ext)) {
                container.innerHTML = '<img src="' + fileUrl + '" alt="' + docTitle + '" style="max-width: 100%; max-height: 500px; object-fit: contain; padding: 10px;" />';
            }
            else if (['doc', 'docx'].includes(ext)) {
                container.innerHTML = 
                    '<div style="text-align: center; padding: 40px; color: var(--text-secondary);">' +
                        '<i class="fa-regular fa-file-word" style="font-size: 54px; color: #3b82f6; margin-bottom: 16px;"></i>' +
                        '<h4 style="color: var(--text-primary); margin-bottom: 8px;">Word Document (.' + ext + ')</h4>' +
                        '<p style="font-size: 13px; max-width: 380px; margin-bottom: 18px;">Word documents cannot be previewed natively in the browser without an external viewer plugin.</p>' +
                        '<a href="' + fileUrl + '" download class="btn-decision btn-approve-lg" style="text-decoration: none;">' +
                            '<i class="fa-solid fa-download"></i> Download & View File' +
                        '</a>' +
                    '</div>';
            }
            else {
                container.innerHTML = 
                    '<div style="text-align: center; padding: 40px; color: var(--text-secondary);">' +
                        '<i class="fa-regular fa-file" style="font-size: 54px; color: var(--accent-purple); margin-bottom: 16px;"></i>' +
                        '<h4 style="color: var(--text-primary); margin-bottom: 8px;">Document (.' + ext + ')</h4>' +
                        '<a href="' + fileUrl + '" download class="btn-view-doc" style="margin-top: 10px;">' +
                            '<i class="fa-solid fa-download"></i> Download File' +
                        '</a>' +
                    '</div>';
            }

            var modal = document.getElementById('docModal');
            if (modal) modal.classList.add('active');
        }

        function closeDocModal() {
            var modal = document.getElementById('docModal');
            if (modal) modal.classList.remove('active');
        }

        function openRejectModal() {
            var txtMain = document.getElementById('<%= txtAdminRemarks.ClientID %>');
            var txtModal = document.getElementById('modalRejectReason');
            var errBox = document.getElementById('rejectModalError');
            var applicantName = document.getElementById('<%= hfApplicantName.ClientID %>');
            var modalNameEl = document.getElementById('modalApplicantNameReject');

            if (applicantName && modalNameEl) {
                modalNameEl.innerText = applicantName.value || 'Applicant';
            }

            if (errBox) errBox.style.display = 'none';

            // Pre-populate modal textarea from main remark input if text already entered
            if (txtMain && txtModal) {
                txtModal.value = txtMain.value.trim();
                txtModal.style.borderColor = '';
            }

            var modal = document.getElementById('rejectModal');
            if (modal) {
                modal.classList.add('active');
                setTimeout(function () {
                    if (txtModal) txtModal.focus();
                }, 100);
            }
        }

        function closeRejectModal() {
            var modal = document.getElementById('rejectModal');
            if (modal) modal.classList.remove('active');
        }

        function openApproveModal() {
            var applicantName = document.getElementById('<%= hfApplicantName.ClientID %>');
            var modalNameEl = document.getElementById('modalApplicantNameApprove');
            if (applicantName && modalNameEl) {
                modalNameEl.innerText = applicantName.value || 'Applicant';
            }
            var modal = document.getElementById('approveModal');
            if (modal) modal.classList.add('active');
        }

        function closeApproveModal() {
            var modal = document.getElementById('approveModal');
            if (modal) modal.classList.remove('active');
        }

        function selectQuickReason(reason) {
            var txtModal = document.getElementById('modalRejectReason');
            if (!txtModal) return;
            if (txtModal.value.trim().length > 0) {
                txtModal.value = txtModal.value.trim() + " " + reason;
            } else {
                txtModal.value = reason;
            }
            // Also sync to main remarks
            var txtMain = document.getElementById('<%= txtAdminRemarks.ClientID %>');
            if (txtMain) txtMain.value = txtModal.value;

            var errBox = document.getElementById('rejectModalError');
            if (errBox) errBox.style.display = 'none';
            txtModal.style.borderColor = '';
            txtModal.focus();
        }

        function confirmRejectModal() {
            var txtModal = document.getElementById('modalRejectReason');
            var txtMain = document.getElementById('<%= txtAdminRemarks.ClientID %>');
            var errBox = document.getElementById('rejectModalError');

            var reason = (txtModal ? txtModal.value : (txtMain ? txtMain.value : '')).trim();

            if (!reason) {
                if (errBox) {
                    errBox.style.display = 'flex';
                }
                if (txtModal) {
                    txtModal.style.borderColor = 'var(--danger-red)';
                    txtModal.focus();
                }
                return false;
            }

            // Sync reason back to main server-side control
            if (txtMain) {
                txtMain.value = reason;
            }

            // Hide any error
            if (errBox) errBox.style.display = 'none';

            return true; // Allow form submission
        }

        window.addEventListener('click', function (e) {
            var docM = document.getElementById('docModal');
            var rejM = document.getElementById('rejectModal');
            var appM = document.getElementById('approveModal');
            if (e.target === docM) closeDocModal();
            if (e.target === rejM) closeRejectModal();
            if (e.target === appM) closeApproveModal();
        });

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') {
                closeDocModal();
                closeRejectModal();
                closeApproveModal();
            }
        });

        document.addEventListener('DOMContentLoaded', function () {
            var txtModal = document.getElementById('modalRejectReason');
            var txtMain = document.getElementById('<%= txtAdminRemarks.ClientID %>');
            var errBox = document.getElementById('rejectModalError');

            if (txtModal) {
                txtModal.addEventListener('input', function () {
                    if (txtModal.value.trim().length > 0) {
                        if (errBox) errBox.style.display = 'none';
                        txtModal.style.borderColor = '';
                    }
                    if (txtMain) txtMain.value = txtModal.value;
                });
            }

            if (txtMain) {
                txtMain.addEventListener('input', function () {
                    var rejModal = document.getElementById('rejectModal');
                    if (txtModal && rejModal && !rejModal.classList.contains('active')) {
                        txtModal.value = txtMain.value;
                    }
                });
            }
        });
    </script>
</body>
</html>