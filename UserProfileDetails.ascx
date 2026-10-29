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

<!-- Document Viewer Modal for User Profile (nested z-index so it overlays profile modal) -->
<div class="modal-overlay" id="userProfileDocModal" style="z-index: 2200;">
    <div class="modal-box large">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
            <h3 id="userProfileDocModalTitle" style="color: var(--text-primary); font-size: 18px; font-weight: 600;">Document Viewer</h3>
            <button type="button" class="btn-view-doc" onclick="closeUserProfileDocModal()"><i class="fa-solid fa-xmark"></i> Close</button>
        </div>

        <!-- Dynamic Container that switches based on file extension -->
        <div id="userProfileDynamicPreviewContainer" style="flex: 1; min-height: 480px; display: flex; align-items: center; justify-content: center; background: #0b0c10; border-radius: 8px; border: 1px solid var(--border-color); overflow: hidden;">
            <!-- Content injected via JavaScript -->
        </div>

        <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 14px;">
            <a id="btnUserProfileDocExternal" href="#" class="btn-view-doc" target="_blank">
                <i class="fa-solid fa-arrow-up-right-from-square"></i> Open in New Tab
            </a>
            <button type="button" class="btn-modal-cancel" onclick="closeUserProfileDocModal()">Done Reading</button>
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

function resolveClientDocUrl(rawDoc) {
    if (!rawDoc || !rawDoc.trim() || rawDoc.trim().toLowerCase() === 'n/a' || rawDoc.trim().toLowerCase() === 'none') {
        return '';
    }
    var clean = rawDoc.trim().replace(/\\/g, '/');
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
        return clean;
    }
    if (clean.startsWith('~/')) {
        clean = clean.substring(1);
    }
    if (!clean.startsWith('/')) {
        if (clean.startsWith('media/') || clean.startsWith('UploadedCertificates/')) {
            clean = '/' + clean;
        } else {
            clean = '/media/uploads/qualifications/' + clean;
        }
    }
    return clean;
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

function openUserProfileDocModal(docTitle, fileUrl) {
    var titleEl = document.getElementById('userProfileDocModalTitle');
    if (titleEl) titleEl.innerText = docTitle;

    var btnExternal = document.getElementById('btnUserProfileDocExternal');
    if (btnExternal) btnExternal.href = fileUrl;

    var container = document.getElementById('userProfileDynamicPreviewContainer');
    if (!container) return;
    container.innerHTML = '';

    var cleanUrl = (fileUrl || '').split('?')[0].split('#')[0];
    var ext = cleanUrl.split('.').pop().toLowerCase();

    if (ext === 'pdf') {
        container.innerHTML = '<iframe src="' + fileUrl + '" style="width: 100%; height: 100%; min-height: 500px; border: none;"></iframe>';
    }
    else if (['png', 'jpg', 'jpeg', 'webp', 'gif'].includes(ext)) {
        container.innerHTML = '<img src="' + fileUrl + '" alt="' + escapeHtml(docTitle) + '" style="max-width: 100%; max-height: 500px; object-fit: contain; padding: 10px;" />';
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

    var modal = document.getElementById('userProfileDocModal');
    if (modal) modal.classList.add('active');
}

function closeUserProfileDocModal() {
    var modal = document.getElementById('userProfileDocModal');
    if (modal) modal.classList.remove('active');
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

        const rawCred = (row.getAttribute('data-credential') || '').trim();
        const credUrl = resolveClientDocUrl(rawCred);
        let credFileName = (row.getAttribute('data-credential-name') || '').trim();
        if (!credFileName && credUrl) {
            const parts = credUrl.split('/');
            credFileName = parts[parts.length - 1] || 'Credential Document';
        }

        const ext = credFileName.split('.').pop().toLowerCase();
        let iconClass = 'fa-regular fa-file-pdf';
        if (['png', 'jpg', 'jpeg', 'webp', 'gif'].includes(ext)) iconClass = 'fa-regular fa-file-image';
        else if (['doc', 'docx'].includes(ext)) iconClass = 'fa-regular fa-file-word';

        let docPreviewHtml = '';
        if (credUrl) {
            docPreviewHtml = `
                <div class="info-section-title"><i class="fa-solid fa-file-lines"></i> Verification Document</div>
                <div class="doc-item-preview">
                    <div class="doc-item-left">
                        <i class="${escapeHtml(iconClass)}"></i>
                        <div>
                            <span style="font-size:13px; font-weight:500;">${escapeHtml(credFileName)}</span>
                            <p style="font-size:11px; color:var(--text-secondary);">${escapeHtml(ext.toUpperCase())} &bull; Attached Document</p>
                        </div>
                    </div>
                    <div style="display: flex; align-items: center; gap: 8px;">
                        <button type="button" class="btn-view-doc" onclick="openUserProfileDocModal('${escapeHtml(credFileName).replace(/'/g, "\\'")}', '${escapeHtml(credUrl).replace(/'/g, "\\'")}')" title="Preview Document">
                            <i class="fa-solid fa-eye"></i> View
                        </button>
                        <a href="${escapeHtml(credUrl)}" class="btn-action" target="_blank" title="Open file in new tab">
                            <i class="fa-solid fa-arrow-up-right-from-square"></i> Open File
                        </a>
                    </div>
                </div>
            `;
        } else {
            docPreviewHtml = `
                <div class="info-section-title"><i class="fa-solid fa-file-lines"></i> Verification Document</div>
                <div class="doc-item-preview" style="color: var(--text-secondary); font-size: 13px; padding: 12px 16px;">
                    <div class="doc-item-left">
                        <i class="fa-solid fa-circle-info" style="color: var(--text-secondary); font-size: 16px;"></i>
                        <span>No verification document uploaded.</span>
                    </div>
                </div>
            `;
        }

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

                ${docPreviewHtml}
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
    const docModal = document.getElementById('userProfileDocModal');
    if (e.target === docModal) {
        closeUserProfileDocModal();
    }
});
</script>
