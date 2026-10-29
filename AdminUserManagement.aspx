<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminUserManagement.aspx.cs" Inherits="Codercept.Admin_User_Management" %>
<%@ Register Src="~/AdminSidebar.ascx" TagPrefix="uc" TagName="AdminSidebar" %>
<%@ Register Src="~/UserProfileDetails.ascx" TagPrefix="uc" TagName="UserProfileDetails" %>
<%@ Register Src="~/CreateAdminAccount.ascx" TagPrefix="uc" TagName="CreateAdminAccount" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>User Management - Codercept</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link href="css/admin-portal.css" rel="stylesheet" type="text/css" />
    <style>
        .list-header, .list-row {
            grid-template-columns: 2.5fr 1.5fr 1fr 1fr 1.5fr;
        }

        .deleted-notice-banner {
            display: none;
            background: rgba(239, 68, 68, 0.08);
            border: 1px solid var(--danger-red-border);
            border-radius: 8px;
            padding: 12px 16px;
            margin-bottom: 20px;
            font-size: 13px;
            color: #fca5a5;
            align-items: center;
            gap: 10px;
        }
        .deleted-notice-banner i { font-size: 16px; color: var(--danger-red); }

        .retention-text {
            font-size: 11px;
            color: var(--danger-red);
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        /* Custom Modal Elements */
        .confirm-delete-box {
            text-align: center;
            padding: 10px 0;
        }
        .confirm-icon-circle {
            width: 56px;
            height: 56px;
            border-radius: 50%;
            background: rgba(239, 68, 68, 0.12);
            color: var(--danger-red);
            font-size: 24px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-bottom: 18px;
            border: 1px solid var(--danger-red-border);
        }
        .confirm-delete-box h3 {
            font-size: 18px;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 8px;
        }
        .confirm-delete-box p {
            font-size: 13px;
            color: var(--text-secondary);
            line-height: 1.5;
            margin-bottom: 24px;
        }
        .btn-danger-confirm {
            background-color: var(--danger-red);
            color: #fff;
            border: none;
            padding: 9px 20px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.2s;
        }
        .btn-danger-confirm:hover { background-color: #dc2626; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hfDeleteTargetUserId" runat="server" />
        <asp:HiddenField ID="hfDeleteTargetRole" runat="server" />
        <asp:HiddenField ID="hfCurrentFilter" runat="server" Value="all" />

        <div style="display: flex; height: 100vh; overflow: hidden;">
            <uc:AdminSidebar runat="server" ID="SidebarCtrl" />
            
            <main class="main-content" style="flex: 1; overflow-y: auto;">
                <div class="page-header-row">
                    <div class="page-header">
                        <h1>User Management</h1>
                        <p id="userCountText"><asp:Literal ID="litUserCount" runat="server">0</asp:Literal> registered users</p>
                    </div>

                    <asp:Panel ID="pnlSuperAdminAction" runat="server">
                        <button type="button" class="btn-add-admin" onclick="openAddAdminModal()">
                            <i class="fa-solid fa-user-plus"></i> Add New Admin
                        </button>
                    </asp:Panel>
                </div>

                <!-- Search -->
                <div class="search-container">
                    <i class="fa-solid fa-magnifying-glass"></i>
                    <input type="text" id="searchInput" placeholder="Search by name or email..." onkeyup="handleSearch()" />
                </div>

                <!-- Tabs: Includes Deleted tab -->
                <div class="tabs-container">
                    <div class="tab active" onclick="filterUsers('all', this)">All</div>
                    <div class="tab" onclick="filterUsers('pending', this)">Pending <span class="dot"></span></div>
                    <div class="tab" onclick="filterUsers('admin', this)">Admins</div>
                    <div class="tab" onclick="filterUsers('teacher', this)">Teachers</div>
                    <div class="tab" onclick="filterUsers('assistant', this)">Teaching Assistants</div>
                    <div class="tab" onclick="filterUsers('learner', this)">Learners</div>
                    <div class="tab" onclick="filterUsers('deleted', this)">
                         Deleted (<span id="deletedCount"><asp:Literal ID="litDeletedCount" runat="server">0</asp:Literal></span>)
                    </div>
                </div>

                <!-- Automated Weekly Purge Notice -->
                <div id="deletedNoticeBanner" class="deleted-notice-banner" style="justify-content: space-between; align-items: center;">
                    <div style="display: flex; align-items: center; gap: 12px;">
                        <i class="fa-solid fa-clock-rotate-left" style="font-size: 20px; color: #f87171;"></i>
                        <div>
                            <div style="font-weight: 600; color: #FF0000; margin-bottom: 2px;">Automated Weekly Purge Active</div>
                            <div style="font-size: 12px; color: #FF0000; line-height: 1.4;">
                                Accounts marked as "Deleted" are automatically and permanently removed from database table records every week.
                                <asp:Literal ID="litPurgeScheduleInfo" runat="server" />
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Grid Table -->
                <div class="user-table">
                    <div class="list-header">
                        <div>User</div>
                        <div>Role</div>
                        <div>Status</div>
                        <div>Joined</div>
                        <div style="text-align: right;">Actions</div>
                    </div>

                    <div id="userListContainer">
                        <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                            <ItemTemplate>
                                <div class="list-row user-row" 
                                     data-id='<%# Eval("UserId") %>'
                                     data-role='<%# Eval("RoleCategory").ToString().ToLower() %>'
                                     data-status='<%# Eval("AccStatus").ToString().ToLower() %>'
                                     data-name='<%# HttpUtility.HtmlAttributeEncode(Eval("Name")?.ToString() ?? "") %>'
                                     data-email='<%# HttpUtility.HtmlAttributeEncode(Eval("Email")?.ToString() ?? "") %>'
                                     data-joined='<%# Eval("DateJoined") != DBNull.Value && Eval("DateJoined") != null ? Eval("DateJoined", "{0:yyyy-MM-dd}") : "N/A" %>'
                                     data-age='<%# Eval("Age") != DBNull.Value && Eval("Age") != null ? Eval("Age") : "N/A" %>'
                                     data-region='<%# HttpUtility.HtmlAttributeEncode(Eval("Region")?.ToString() ?? "N/A") %>'
                                     data-teachinglevel='<%# HttpUtility.HtmlAttributeEncode(Eval("TeachingLevel")?.ToString() ?? "N/A") %>'
                                     data-qualification='<%# HttpUtility.HtmlAttributeEncode(Eval("QualificationName")?.ToString() ?? "N/A") %>'
                                     data-credential='<%# HttpUtility.HtmlAttributeEncode(Eval("QualificationDocument")?.ToString() ?? "") %>'
                                     data-subject='<%# HttpUtility.HtmlAttributeEncode(Eval("SubjectTeaching")?.ToString() ?? "N/A") %>'
                                     data-address='<%# HttpUtility.HtmlAttributeEncode(Eval("Address")?.ToString() ?? "N/A") %>'
                                     data-occupation='<%# HttpUtility.HtmlAttributeEncode(Eval("Occupation")?.ToString() ?? "N/A") %>'
                                     data-progress='<%# HttpUtility.HtmlAttributeEncode(Eval("ProgressCourses")?.ToString() ?? "None in progress") %>'
                                     data-completed='<%# HttpUtility.HtmlAttributeEncode(Eval("CompletedCourses")?.ToString() ?? "None completed") %>'>
                                    
                                    <div class="col-user">
                                        <div class="avatar" style='<%# Eval("RoleCategory").ToString().ToLower() == "admin" ? "background-color: var(--accent-rose-bg); color: var(--accent-rose);" : "" %>'>
                                            <%# GetInitials(Eval("Name").ToString()) %>
                                        </div>
                                        <div class="user-meta">
                                            <h5 class="user-name"><%# Eval("Name") %></h5>
                                            <p class="user-email"><%# Eval("Email") %></p>
                                        </div>
                                    </div>

                                    <div>
                                        <span class="badge <%# GetRoleBadgeClass(Eval("Role").ToString()) %>">
                                            <%# Eval("Role") %>
                                        </span>
                                    </div>

                                    <div class="status-cell">
                                        <span class="badge <%# GetStatusBadgeClass(Eval("AccStatus").ToString()) %>">
                                            <%# Eval("AccStatus") %>
                                        </span>
                                    </div>

                                    <div class="col-joined"><%# Eval("DateJoined") != DBNull.Value && Eval("DateJoined") != null ? Eval("DateJoined", "{0:yyyy-MM-dd}") : "-" %></div>

                                    <div class="col-actions">
                                        <%# Eval("AccStatus").ToString().ToLower() == "pending" 
                                            ? "<a href='AdminReviewApplication.aspx?userId=" + Eval("UserId") + "&role=" + Eval("RoleCategory") + "' class='btn-action' style='border-color: #ddd6fe; color: var(--accent-purple); background: var(--accent-purple-bg);'><i class='fa-solid fa-file-signature'></i> Review Application</a>"
                                            : "" 
                                        %>

                                        <%# (Eval("AccStatus").ToString().ToLower() != "pending" && Eval("AccStatus").ToString().ToLower() != "deleted") ? @"
                                            <button type='button' class='btn-action btn-view' onclick='openUserProfileModal(this)' title='View Details'>
                                                <i class='fa-regular fa-eye'></i>
                                            </button>" : "" %>

                                        <asp:LinkButton ID="btnToggleStatus" runat="server" 
                                            CommandName="ToggleStatus" 
                                            CommandArgument='<%# Eval("UserId") + "|" + Eval("RoleCategory") + "|" + Eval("AccStatus") %>'
                                            Visible='<%# Eval("Role").ToString() != "SuperAdmin" && Eval("AccStatus").ToString().ToLower() != "pending" && Eval("AccStatus").ToString().ToLower() != "deleted" %>'
                                            CssClass='<%# Eval("AccStatus").ToString().ToLower() == "active" ? "btn-action" : "btn-action btn-reactivate" %>'>
                                            <%# Eval("AccStatus").ToString().ToLower() == "active" ? "Deactivate" : "Activate" %>
                                        </asp:LinkButton>

                                        <!-- Custom Delete Modal Trigger -->
                                        <%# (Eval("Role").ToString() != "SuperAdmin" && Eval("AccStatus").ToString().ToLower() != "pending" && Eval("AccStatus").ToString().ToLower() != "deleted") ? @"
                                            <button type='button' class='btn-icon' title='Move to Deleted' onclick=""openCustomUserDeleteModal('" + Eval("UserId") + @"', '" + Eval("RoleCategory") + @"', '" + HttpUtility.JavaScriptStringEncode(Eval("Name").ToString()) + @"')"">
                                                <i class='fa-regular fa-trash-can'></i>
                                            </button>" : "" %>

                                        <%# Eval("AccStatus").ToString().ToLower() == "deleted" 
                                            ? "<span class='retention-text'><i class='fa-solid fa-clock-rotate-left'></i> Auto-purged weekly</span>" 
                                            : "" 
                                        %>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
        
                    <div id="noResults" class="no-results">
                        No users found matching this filter.
                    </div>
                </div>

                <!-- Custom User Soft-Delete Confirmation Modal -->
                <div class="modal-overlay" id="customUserDeleteModal">
                    <div class="modal-container" style="max-width: 440px;">
                        <div class="confirm-delete-box">
                            <div class="confirm-icon-circle">
                                <i class="fa-solid fa-user-xmark"></i>
                            </div>
                            <h3>Move User to Deleted?</h3>
                            <p>Are you sure you want to deactivate and schedule <strong id="deleteUserTargetName" style="color:var(--text-primary);">this user</strong> for deletion? They will be retained in Deleted Accounts and automatically removed from database table records every week.</p>
                            <div class="modal-actions" style="justify-content: center; gap: 14px;">
                                <button type="button" class="btn-cancel" onclick="closeCustomUserDeleteModal()">Cancel</button>
                                <asp:Button ID="btnConfirmSoftDelete" runat="server" Text="Confirm & Delete" 
                                    CssClass="btn-danger-confirm" OnClick="btnConfirmSoftDelete_Click" />
                            </div>
                        </div>
                    </div>
                </div>

                <uc:UserProfileDetails runat="server" ID="UserProfileDetailsCtrl" />
                <uc:CreateAdminAccount runat="server" ID="CreateAdminAccountCtrl" />

                <script>
                    let currentFilter = 'all';

                    document.addEventListener('DOMContentLoaded', () => {
                        updateCounts();

                        const hf = document.getElementById('<%= hfCurrentFilter.ClientID %>');
                        const urlParams = new URLSearchParams(window.location.search);
                        const savedFilter = (hf && hf.value && hf.value.trim() !== '') ? hf.value.trim().toLowerCase() : '';
                        const urlFilter = (urlParams.get('filter') || urlParams.get('tab') || '').toLowerCase();
                        const targetFilter = savedFilter || urlFilter || 'all';

                        let matchedTab = null;
                        document.querySelectorAll('.tab').forEach(tab => {
                            const onclickAttr = tab.getAttribute('onclick') || '';
                            if (onclickAttr.toLowerCase().includes(`'${targetFilter}'`)) {
                                matchedTab = tab;
                            }
                        });

                        if (matchedTab) {
                            filterUsers(targetFilter, matchedTab);
                        } else {
                            filterUsers('all', document.querySelector('.tab'));
                        }
                    });

                    function openCustomUserDeleteModal(userId, roleCategory, userName) {
                        document.getElementById('<%= hfDeleteTargetUserId.ClientID %>').value = userId;
                        document.getElementById('<%= hfDeleteTargetRole.ClientID %>').value = roleCategory;
                        document.getElementById('deleteUserTargetName').innerText = `"${userName}"`;
                        document.getElementById('customUserDeleteModal').classList.add('active');
                    }

                    function closeCustomUserDeleteModal() {
                        document.getElementById('customUserDeleteModal').classList.remove('active');
                    }

                    function updateCounts() {
                        const allRows = document.querySelectorAll('.user-row');
                        const activeRows = Array.from(allRows).filter(r => r.getAttribute('data-status') !== 'deleted');
                        const deletedRows = Array.from(allRows).filter(r => r.getAttribute('data-status') === 'deleted');

                        const countText = document.getElementById('userCountText');
                        if (countText) countText.innerText = `${activeRows.length} registered users`;

                        const deletedCounter = document.getElementById('deletedCount');
                        if (deletedCounter) deletedCounter.innerText = deletedRows.length;
                    }

                    function filterUsers(filterType, clickedTab) {
                        currentFilter = filterType;
                        const hf = document.getElementById('<%= hfCurrentFilter.ClientID %>');
                        if (hf) hf.value = filterType;

                        document.querySelectorAll('.tab').forEach(tab => tab.classList.remove('active'));
                        if (clickedTab) clickedTab.classList.add('active');

                        const banner = document.getElementById('deletedNoticeBanner');
                        if (banner) banner.style.display = (filterType === 'deleted') ? 'flex' : 'none';

                        applyFilters();

                        try {
                            const newUrl = new URL(window.location.href);
                            newUrl.searchParams.set('tab', filterType);
                            window.history.replaceState({ path: newUrl.href }, '', newUrl.href);
                        } catch (e) {}
                    }

                    function handleSearch() {
                        applyFilters();
                    }

                    function applyFilters() {
                        const searchTerm = document.getElementById('searchInput').value.toLowerCase().trim();
                        const rows = document.querySelectorAll('.user-row');
                        let visibleCount = 0;

                        rows.forEach(row => {
                            const role = row.getAttribute('data-role');
                            const status = row.getAttribute('data-status');
                            const name = row.querySelector('.user-name').innerText.toLowerCase();
                            const email = row.querySelector('.user-email').innerText.toLowerCase();

                            let matchesFilter = false;

                            if (currentFilter === 'all') {
                                matchesFilter = (status !== 'deleted');
                            } else if (currentFilter === 'pending') {
                                matchesFilter = (status === 'pending');
                            } else if (currentFilter === 'learner') {
                                matchesFilter = (role === 'learner' && status !== 'deleted');
                            } else if (currentFilter === 'teacher') {
                                matchesFilter = (role === 'teacher' && status !== 'deleted');
                            } else if (currentFilter === 'assistant') {
                                matchesFilter = (role === 'assistant' && status !== 'deleted');
                            } else if (currentFilter === 'admin') {
                                matchesFilter = (role === 'admin' && status !== 'deleted');
                            } else if (currentFilter === 'deleted') {
                                matchesFilter = (status === 'deleted');
                            }

                            const matchesSearch = !searchTerm || name.includes(searchTerm) || email.includes(searchTerm);

                            if (matchesFilter && matchesSearch) {
                                row.style.display = 'grid';
                                visibleCount++;
                            } else {
                                row.style.display = 'none';
                            }
                        });

                        const noResults = document.getElementById('noResults');
                        noResults.style.display = (visibleCount === 0) ? 'block' : 'none';
                    }

                    window.addEventListener('click', function (e) {
                        if (e.target === document.getElementById('customUserDeleteModal')) closeCustomUserDeleteModal();
                    });
                </script>
            </main>
        </div>
    </form>
</body>
</html>