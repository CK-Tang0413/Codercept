<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UserProfileDetails.ascx.cs" Inherits="Codercept.UserProfileDetails" %>

<!-- Dynamic User Profile Modal -->
<div class="modal-overlay" id="userProfileModal">
    <div class="modal-box">
        <div class="modal-header-row">
            <div class="modal-header-left">
                <div class="modal-avatar" id="modalAvatar">U</div>
                <div class="modal-meta">
                    <h3 id="modalName">User Name <span id="modalRoleBadge" class="badge">Role</span></h3>
                    <p id="modalSubtext">email@domain.com &bull; #ID-000</p>
                </div>
            </div>
            <button type="button" class="btn-modal-close" onclick="closeUserProfileModal()"><i class="fa-solid fa-xmark"></i></button>
        </div>

        <!-- Profile Content Placeholder dynamically generated via JavaScript -->
        <div id="modalDynamicBody"></div>

        <div class="modal-footer">
            <button type="button" class="btn-action" onclick="closeUserProfileModal()">Close</button>
        </div>
    </div>
</div>

<script>
function escapeHtml(text) {
    if (!text) return '';
    return String(text)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

function renderCourseListChips(courseStr, emptyText, iconClass, chipStyle) {
    if (!courseStr || courseStr.trim() === '' || courseStr.toLowerCase() === 'none' || courseStr.toLowerCase().startsWith('none ') || courseStr.toLowerCase() === 'none recorded') {
        return `<span style="color: var(--text-secondary); font-style: italic; font-size: 13px;">${escapeHtml(emptyText)}</span>`;
    }
    const items = courseStr.split(',').map(s => s.trim()).filter(s => s.length > 0);
    if (items.length === 0) {
        return `<span style="color: var(--text-secondary); font-style: italic; font-size: 13px;">${escapeHtml(emptyText)}</span>`;
    }
    return `<div class="chip-group" style="margin-top: 6px; display: flex; flex-wrap: wrap; gap: 8px;">` +
        items.map(name => `<span class="lang-chip" style="${chipStyle} font-size: 12px; padding: 4px 10px; border-radius: 6px; display: inline-flex; align-items: center;"><i class="${iconClass}" style="margin-right: 6px;"></i>${escapeHtml(name)}</span>`).join('') +
        `</div>`;
}

function openUserProfileModal(button) {
    const row = button.closest('.user-row');
    const id = row.getAttribute('data-id');
    const role = row.getAttribute('data-role');
    const status = row.getAttribute('data-status');
    const name = row.getAttribute('data-name');
    const email = row.getAttribute('data-email');
    const joined = row.getAttribute('data-joined') || 'N/A';

    // Set Header
    const initials = name ? name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase() : 'U';
    document.getElementById('modalAvatar').innerText = initials;
    document.getElementById('modalName').innerHTML = `${escapeHtml(name)} <span class="badge badge-${escapeHtml(role)}">${escapeHtml(role.toUpperCase())}</span>`;
    document.getElementById('modalSubtext').innerHTML = `${escapeHtml(email)} &bull; ID: #${escapeHtml(id)} &bull; Status: <strong style="color:var(--success-green);">${escapeHtml(status)}</strong>`;

    const container = document.getElementById('modalDynamicBody');
    container.innerHTML = '';

    if (role === 'learner') {
        const age = row.getAttribute('data-age') || 'N/A';
        const address = row.getAttribute('data-address') || 'N/A';
        const occupation = row.getAttribute('data-occupation') || 'N/A';
        const progress = row.getAttribute('data-progress') || 'None in progress';
        const completed = row.getAttribute('data-completed') || 'None completed';

        const progressHtml = renderCourseListChips(progress, 'None in progress', 'fa-solid fa-book-open', 'background: var(--accent-purple-bg); color: var(--accent-purple); border: 1px solid #ddd6fe;');
        const completedHtml = renderCourseListChips(completed, 'None completed', 'fa-solid fa-circle-check', 'background: rgba(34, 197, 94, 0.12); color: #16a34a; border: 1px solid rgba(34, 197, 94, 0.25);');

        container.innerHTML = `
                <div class="info-section-title"><i class="fa-regular fa-user"></i> Personal Information</div>
                <div class="info-grid">
                    <div class="info-item"><label>Learner ID</label><span>#LRN-${escapeHtml(id)}</span></div>
                    <div class="info-item"><label>Account Status</label><span>${escapeHtml(status)}</span></div>
                    <div class="info-item"><label>Age</label><span>${escapeHtml(age)}</span></div>
                    <div class="info-item"><label>Occupation</label><span>${escapeHtml(occupation)}</span></div>
                    <div class="info-item info-grid-full"><label>Address</label><span>${escapeHtml(address)}</span></div>
                    <div class="info-item info-grid-full"><label>Date Joined</label><span>${escapeHtml(joined)}</span></div>
                </div>

                <div class="info-section-title"><i class="fa-solid fa-graduation-cap"></i> Learner Progress & Achievements</div>
                <div class="info-grid">
                    <div class="info-item info-grid-full">
                        <label>Courses In Progress</label>
                        ${progressHtml}
                    </div>
                    <div class="info-item info-grid-full">
                        <label>Completed Courses & Certificates</label>
                        ${completedHtml}
                    </div>
                </div>
            `;
    } else if (role === 'teacher' || role === 'assistant') {
        const age = row.getAttribute('data-age') || 'N/A';
        const region = row.getAttribute('data-region') || 'N/A';
        const level = row.getAttribute('data-teachinglevel') || 'N/A';
        const subject = row.getAttribute('data-subject') || 'N/A';
        const qual = row.getAttribute('data-qualification') || 'N/A';
        const spec = row.getAttribute('data-specialization') || 'N/A';
        const langs = (row.getAttribute('data-languages') || 'Java, Python, C++').split(',');
        const credFile = row.getAttribute('data-credential') || 'credential_document.pdf';

        const langChips = langs.map(l => `<span class="lang-chip">${escapeHtml(l.trim())}</span>`).join('');

        container.innerHTML = `
                <div class="info-section-title"><i class="fa-solid fa-chalkboard-user"></i> Professional Profile</div>
                <div class="info-grid">
                    <div class="info-item"><label>${role === 'teacher' ? 'Teacher ID' : 'TA ID'}</label><span>#${role === 'teacher' ? 'TCH' : 'TA'}-${escapeHtml(id)}</span></div>
                    <div class="info-item"><label>Account Status</label><span>${escapeHtml(status)}</span></div>
                    <div class="info-item"><label>Age</label><span>${escapeHtml(age)}</span></div>
                    <div class="info-item"><label>Region</label><span>${escapeHtml(region)}</span></div>
                    <div class="info-item"><label>Teaching Level</label><span>${escapeHtml(level)}</span></div>
                    <div class="info-item"><label>Subject Teaching</label><span>${escapeHtml(subject)}</span></div>
                </div>

                <div class="info-section-title"><i class="fa-solid fa-award"></i> Academic & Technical Background</div>
                <div class="academic-scroll-card">
                    <div class="info-item">
                        <label>Highest Qualification Level</label>
                        <span style="font-size: 14px;">${escapeHtml(qual)}</span>
                    </div>
                    <div class="info-item">
                        <label>Subject Area / Specialization</label>
                        <span style="font-size: 14px;">${escapeHtml(spec)}</span>
                    </div>
                    <div class="info-item">
                        <label>Proficient Programming Languages</label>
                        <div class="chip-group">${langChips}</div>
                    </div>
                </div>

                <div class="info-section-title"><i class="fa-solid fa-file-pdf"></i> Verification Document</div>
                <div class="doc-item-preview">
                    <div class="doc-item-left">
                        <i class="fa-regular fa-file-pdf"></i>
                        <div>
                            <span style="font-size:13px; font-weight:500;">${escapeHtml(credFile)}</span>
                            <p style="font-size:11px; color:var(--text-secondary);">Credential Verification Document</p>
                        </div>
                    </div>
                    <a href="#" class="btn-action" target="_blank"><i class="fa-solid fa-arrow-up-right-from-square"></i> Open File</a>
                </div>
            `;
    } else if (role === 'admin') {
        container.innerHTML = `
                <div class="info-section-title"><i class="fa-solid fa-shield-halved"></i> Administrator Details</div>
                <div class="info-grid">
                    <div class="info-item"><label>Admin ID</label><span>#ADM-${escapeHtml(id)}</span></div>
                    <div class="info-item"><label>Role Privilege</label><span>SuperAdmin / Admin</span></div>
                    <div class="info-item"><label>Full Name</label><span>${escapeHtml(name)}</span></div>
                    <div class="info-item"><label>Email Address</label><span>${escapeHtml(email)}</span></div>
                    <div class="info-item info-grid-full"><label>Account Status</label><span>${escapeHtml(status)}</span></div>
                </div>
            `;
    }

    document.getElementById('userProfileModal').classList.add('active');
}

function closeUserProfileModal() {
    const modal = document.getElementById('userProfileModal');
    if (modal) {
        modal.classList.remove('active');
    }
}

// Close on background backdrop click
window.addEventListener('click', function (e) {
    const modal = document.getElementById('userProfileModal');
    if (e.target === modal) {
        closeUserProfileModal();
    }
});
</script>
