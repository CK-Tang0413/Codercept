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
                            <!-- Rejection directly triggers ASP.NET server-side click with JS validation -->
                            <asp:Button ID="btnRejectApplication" runat="server" Text="Reject Application" 
                                CssClass="btn-decision btn-reject-lg" OnClick="btnRejectApplication_Click" 
                                OnClientClick="return validateRejectReason();" />

                            <asp:Button ID="btnApproveApplication" runat="server" Text="Approve Application" 
                                CssClass="btn-decision btn-approve-lg" OnClick="btnApproveApplication_Click" />
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
            </main>
        </div>
    </form>

    <script>
        // @ts-nocheck
        function openDocModal(docTitle, fileUrl) {
            var titleEl = document.getElementById('docModalTitle');
            if (titleEl) titleEl.innerText = docTitle;s

            var btnExternal = document.getElementById('btnDocExternal');
            if (btnExternal) btnExternal.href = fileUrl;

            var container = document.getElementById('dynamicPreviewContainer');
            if (!container) return;
            container.innerHTML = '';

            var ext = fileUrl.split('.').pop().toLowerCase();

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
            var modal = document.getElementById('rejectModal');
            if (modal) modal.classList.add('active');
        }

        function closeRejectModal() {
            var modal = document.getElementById('rejectModal');
            if (modal) modal.classList.remove('active');
        }

        window.addEventListener('click', function (e) {
            var docM = document.getElementById('docModal');
            var rejM = document.getElementById('rejectModal');
            if (e.target === docM) closeDocModal();
            if (e.target === rejM) closeRejectModal();
        });

        function validateRejectReason() {
            var txt = document.getElementById('<%= txtAdminRemarks.ClientID %>');
            if (!txt || !txt.value.trim()) {
                alert('Please provide a reason for rejecting the application.');
                if (txt) {
                    txt.focus();
                    txt.style.borderColor = "var(--danger-red)";
                }
                return false;
            }
            return confirm("Are you sure you want to reject this applicant with the provided reason?");
        }
    </script>
</body>
</html>