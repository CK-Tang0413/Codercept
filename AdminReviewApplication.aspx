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
            background-color: #0b0c10;
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
            color: var(--warning-orange);
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
                        <a href="AdminUserManagement.aspx" class="btn-back">
                            <i class="fa-solid fa-arrow-left"></i> Back to User Management
                        </a>
                        <span class="status-pill">
                            <i class="fa-solid fa-clock"></i> Application Pending Review
                        </span>
                    </div>

                    <!-- Applicant Header Card -->
                    <div class="applicant-header-card">
                        <div class="applicant-identity">
                            <div class="applicant-avatar">EW</div>
                            <div class="applicant-meta">
                                <h2>
                                    <asp:Literal ID="litFullName" runat="server" Text="Emma Wilson"></asp:Literal>
                                    <span class="role-badge badge-teacher">Teacher Applicant</span>
                                </h2>
                                <p><asp:Literal ID="litEmail" runat="server" Text="emma.wilson@codelearn.edu"></asp:Literal> &bull; Applied on 2024-08-20</p>
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
                                <span class="info-value">Teacher</span>
                            </div>

                            <div class="info-row">
                                <span class="info-label">Highest Qualification Level</span>
                                <span class="info-value">Master of Science in Computer Science</span>
                            </div>

                            <div class="info-row">
                                <span class="info-label">Subject Area / Specialization</span>
                                <span class="info-value">Software Engineering & Distributed Systems</span>
                            </div>

                            <div class="info-row" style="align-items: flex-start;">
                                <span class="info-label">Proficient Programming Languages</span>
                                <div class="chip-group">
                                    <span class="lang-chip highlight">Java</span>
                                    <span class="lang-chip highlight">Python</span>
                                    <span class="lang-chip highlight">C++</span>
                                    <span class="lang-chip">Kotlin</span>
                                    <span class="lang-chip">SQL</span>
                                </div>
                            </div>
                        </div>

                        <!-- Right Panel: Attached Documents -->
                        <div class="info-card">
                            <div class="info-card-title">
                                <i class="fa-solid fa-file-lines"></i> Verification Documents
                            </div>

                            <div class="docs-list">
                                <!-- Degree Certificate -->
                                <div class="doc-item">
                                    <div class="doc-left">
                                        <div class="doc-icon"><i class="fa-solid fa-file-pdf"></i></div>
                                        <div class="doc-meta">
                                            <h5>Degree Certificate</h5>
                                            <p>PDF &bull; 2.4 MB</p>
                                        </div>
                                    </div>
                                    <button type="button" class="btn-view-doc" onclick="openDocModal('Master of Science Degree Certificate', 'cert-sample.pdf')">
                                        <i class="fa-solid fa-eye"></i> View
                                    </button>
                                </div>

                                <!-- Academic Transcript -->
                                <div class="doc-item">
                                    <div class="doc-left">
                                        <div class="doc-icon"><i class="fa-solid fa-file-pdf"></i></div>
                                        <div class="doc-meta">
                                            <h5>Official Transcript</h5>
                                            <p>PDF &bull; 1.8 MB</p>
                                        </div>
                                    </div>
                                    <button type="button" class="btn-view-doc" onclick="openDocModal('Official Academic Transcript', 'transcript-sample.pdf')">
                                        <i class="fa-solid fa-eye"></i> View
                                    </button>
                                </div>
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

                <!-- 1. Document Viewer Modal -->
                <div class="modal-overlay" id="docModal">
                    <div class="modal-box large">
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <h3 id="docModalTitle">Document Viewer</h3>
                            <button type="button" class="btn-view-doc" onclick="closeDocModal()"><i class="fa-solid fa-xmark"></i> Close</button>
                        </div>
                        <div class="doc-preview-body">
                            <i class="fa-regular fa-file-pdf"></i>
                            <h4 style="color: var(--text-primary); margin-bottom: 6px;" id="docModalFileName">certificate.pdf</h4>
                            <p style="font-size: 13px; max-width: 400px; margin-bottom: 20px;">In production, link this iframe to your Azure Blob / Amazon S3 / local uploads handler: <code>/Uploads/Documents/...</code></p>
                            <a href="#" class="btn-view-doc" target="_blank"><i class="fa-solid fa-arrow-up-right-from-square"></i> Open in New Tab</a>
                        </div>
                        <div style="text-align: right;">
                            <button type="button" class="btn-modal-cancel" onclick="closeDocModal()">Done Reading</button>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </form>

    <script>
        // Document Modal Handlers
        function openDocModal(docTitle, fileName) {
            document.getElementById('docModalTitle').innerText = docTitle;
            document.getElementById('docModalFileName').innerText = fileName;
            document.getElementById('docModal').classList.add('active');
        }
        function closeDocModal() {
            document.getElementById('docModal').classList.remove('active');
        }

        // Rejection Modal Handlers
        function openRejectModal() {
            document.getElementById('rejectModal').classList.add('active');
        }
        function closeRejectModal() {
            document.getElementById('rejectModal').classList.remove('active');
        }

        // Close on background backdrop click
        window.addEventListener('click', function (e) {
            const docM = document.getElementById('docModal');
            const rejM = document.getElementById('rejectModal');
            if (e.target === docM) closeDocModal();
            if (e.target === rejM) closeRejectModal();
        });

           function validateRejectReason() {
            const txt = document.getElementById('<%= txtAdminRemarks.ClientID %>');
            if (!txt || !txt.value.trim()) {
                alert('Please provide a reason for rejecting the application.');
                txt.focus();
                txt.style.borderColor = "var(--danger-red)";
                return false;
            }
            return confirm("Are you sure you want to reject this applicant with the provided reason?");
        }
        function validateRejectionReason() {
            const txtField = document.getElementById('<%= txtAdminRemarks.ClientID %>');

            if (!txtField || !txtField.value.trim()) {
                alert("Please provide a rejection reason in the remarks field before rejecting this application.");
                txtField.focus();
                txtField.style.borderColor = "var(--danger-red)";
                return false;
            }

            return confirm("Are you sure you want to reject this applicant with the provided reason?");
        }
    </script>
</body>
</html>