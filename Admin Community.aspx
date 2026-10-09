<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin Community.aspx.cs" Inherits="Codercept.Admin_Community" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Community Management</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        :root {
            --bg-body: #0a0a0f;
            --bg-panel: #14151a;
            --text-primary: #f3f4f6;
            --text-secondary: #9ca3af;
            --border-color: #2b2d3a;
            
            --accent-purple: #7c3aed;
            --accent-purple-hover: #6d28d9;
            --accent-purple-bg: rgba(124, 58, 237, 0.1);
            
            --success-green: #10b981;
            --success-green-bg: rgba(16, 185, 129, 0.05);
            --success-green-border: rgba(16, 185, 129, 0.2);
            
            --warning-orange: #f59e0b;
            --warning-orange-bg: rgba(245, 158, 11, 0.05);
            --warning-orange-border: rgba(245, 158, 11, 0.2);
            
            --info-blue: #3b82f6;
            --info-blue-bg: rgba(59, 130, 246, 0.05);
            --info-blue-border: rgba(59, 130, 246, 0.2);
            
            --gray-badge: #4b5563;
            --gray-badge-bg: rgba(75, 85, 99, 0.2);
            
            --course-python: #2563eb;
            --course-python-bg: rgba(37, 99, 235, 0.15);
            --course-java: #d97706;
            --course-java-bg: rgba(217, 119, 6, 0.15);
            --course-c: #dc2626;
            --course-c-bg: rgba(220, 38, 38, 0.15);
            --course-cpp: #9333ea;
            --course-cpp-bg: rgba(147, 51, 234, 0.15);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Inter', sans-serif;
        }

        body {
            background-color: var(--bg-body);
            color: var(--text-primary);
        }

        .main-content {
            padding: 32px 40px;
        }

        /* --- Header & Top Actions --- */
        .page-header-container {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 32px;
        }

        .page-header h1 {
            font-size: 24px;
            font-weight: 600;
            margin-bottom: 4px;
        }

        .page-header p {
            color: var(--text-secondary);
            font-size: 14px;
        }

        .btn-primary {
            background-color: var(--accent-purple);
            color: white;
            border: none;
            padding: 10px 16px;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: background-color 0.2s;
        }

        .btn-primary:hover {
            background-color: var(--accent-purple-hover);
        }

        /* --- Section Headers --- */
        .section-header {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 16px;
            margin-top: 32px;
        }
        .section-header:first-of-type { margin-top: 0; }
        .section-header i { color: var(--text-secondary); font-size: 14px; }

        /* --- Announcements List --- */
        .announcements-list {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .announcement-card {
            background-color: var(--bg-body);
            border: 1px solid var(--border-color);
            border-radius: 10px;
            padding: 20px 24px;
            display: flex;
            gap: 16px;
            position: relative;
        }

        .announcement-card.success { border-color: var(--success-green-border); background-color: var(--success-green-bg); }
        .announcement-card.warning { border-color: var(--warning-orange-border); background-color: var(--warning-orange-bg); }
        .announcement-card.info { border-color: var(--info-blue-border); background-color: var(--info-blue-bg); }

        .announcement-icon { margin-top: 2px; }
        .announcement-card.success .announcement-icon { color: var(--success-green); }
        .announcement-card.warning .announcement-icon { color: var(--warning-orange); }
        .announcement-card.info .announcement-icon { color: var(--info-blue); }

        .announcement-content { flex: 1; }
        
        .announcement-title-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 4px;
        }

        .announcement-content h4 {
            font-size: 16px;
            font-weight: 600;
        }

        .pin-status {
            font-size: 12px;
            color: var(--accent-purple);
            display: flex;
            align-items: center;
            gap: 4px;
            margin-bottom: 12px;
        }

        .announcement-content p {
            font-size: 14px;
            color: var(--text-secondary);
            line-height: 1.5;
            margin-bottom: 16px;
        }

        .announcement-meta {
            font-size: 12px;
            color: var(--gray-badge);
        }

        .announcement-actions {
            display: flex;
            align-items: center;
            gap: 16px;
            font-size: 12px;
        }

        .status-text.success { color: var(--success-green); }
        .status-text.warning { color: var(--warning-orange); }
        .status-text.info { color: var(--info-blue); }

        .icon-btn {
            background: none;
            border: none;
            color: var(--text-secondary);
            cursor: pointer;
            font-size: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            width: 28px;
            height: 28px;
            border-radius: 50%;
            transition: all 0.2s;
        }
        .icon-btn:hover { background-color: rgba(255, 255, 255, 0.1); color: var(--text-primary); }
        .icon-btn.active { background-color: var(--accent-purple-bg); color: var(--accent-purple); }

        /* --- Featured Courses List --- */
        .courses-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .course-card {
            background-color: var(--bg-panel);
            border: 1px solid var(--border-color);
            border-radius: 10px;
            padding: 16px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .course-info {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .course-badge {
            padding: 4px 10px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 500;
        }
        .badge-python { background-color: var(--course-python-bg); color: var(--course-python); }
        .badge-java { background-color: var(--course-java-bg); color: var(--course-java); }
        .badge-c { background-color: var(--course-c-bg); color: var(--course-c); }
        .badge-cpp { background-color: var(--course-cpp-bg); color: var(--course-cpp); }

        .course-details h5 {
            font-size: 15px;
            font-weight: 600;
            margin-bottom: 4px;
        }

        .course-details p {
            font-size: 13px;
            color: var(--text-secondary);
        }

        .btn-feature {
            background: none;
            border: 1px solid var(--border-color);
            color: var(--text-secondary);
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 500;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s;
        }
        
        .btn-feature:hover { border-color: var(--text-secondary); }
        
        .btn-feature.active {
            border-color: var(--warning-orange-border);
            color: var(--warning-orange);
            background-color: var(--warning-orange-bg);
        }

        /* --- Modal Styles --- */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background-color: rgba(0, 0, 0, 0.7);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }

        .modal-overlay.active {
            display: flex;
        }

        .modal-container {
            background-color: #1e1f26; /* Slightly lighter than panel for depth */
            border: 1px solid var(--border-color);
            border-radius: 12px;
            width: 100%;
            max-width: 500px;
            padding: 24px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.5);
        }

        .modal-header {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 24px;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-label {
            display: block;
            font-size: 13px;
            color: var(--text-secondary);
            margin-bottom: 8px;
        }

        .form-control {
            width: 100%;
            background-color: var(--bg-panel);
            border: 1px solid var(--border-color);
            border-radius: 6px;
            padding: 10px 12px;
            color: var(--text-primary);
            font-size: 14px;
            outline: none;
            transition: border-color 0.2s;
        }
        
        .form-control:focus {
            border-color: var(--accent-purple);
        }

        textarea.form-control {
            min-height: 120px;
            resize: vertical;
        }

        .form-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 24px;
        }

        .type-select-wrapper {
            width: 60%;
        }

        .toggle-container {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 13px;
            color: var(--text-secondary);
        }

        /* Toggle Switch styling */
        .switch {
            position: relative;
            display: inline-block;
            width: 36px;
            height: 20px;
        }
        .switch input { opacity: 0; width: 0; height: 0; }
        .slider {
            position: absolute;
            cursor: pointer;
            top: 0; left: 0; right: 0; bottom: 0;
            background-color: var(--border-color);
            transition: .4s;
            border-radius: 20px;
        }
        .slider:before {
            position: absolute;
            content: "";
            height: 14px;
            width: 14px;
            left: 3px;
            bottom: 3px;
            background-color: white;
            transition: .4s;
            border-radius: 50%;
        }
        input:checked + .slider {
            background-color: var(--accent-purple);
        }
        input:checked + .slider:before {
            transform: translateX(16px);
        }

        .modal-actions {
            display: flex;
            justify-content: space-between;
            gap: 16px;
        }

        .btn-cancel {
            flex: 1;
            background: none;
            border: 1px solid var(--border-color);
            color: var(--text-secondary);
            padding: 10px;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn-cancel:hover { background-color: rgba(255, 255, 255, 0.05); color: var(--text-primary); }

        .btn-submit {
            flex: 1;
            background-color: var(--accent-purple);
            color: white;
            border: none;
            padding: 10px;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .btn-submit:hover { background-color: var(--accent-purple-hover); }

        select option {
            background-color: var(--bg-panel);
            color: var(--text-primary);
        }
    </style>
</head>
<body>
    <div class="main-content">
        
        <!-- Header -->
        <div class="page-header-container">
            <div class="page-header">
                <h1>Community</h1>
                <p>Manage announcements and featured content</p>
            </div>
            <button class="btn-primary" onclick="openModal()">
                <i class="fa-solid fa-plus"></i> New Announcement
            </button>
        </div>

        <!-- Announcements Section -->
        <div class="section-header">
            <i class="fa-regular fa-bell"></i> Announcements (3)
        </div>

        <div class="announcements-list">
            <!-- Success Announcement -->
            <div class="announcement-card success">
                <div class="announcement-icon"><i class="fa-solid fa-check"></i></div>
                <div class="announcement-content">
                    <div class="announcement-title-row">
                        <h4>New C++ Module Now Available!</h4>
                        <div class="announcement-actions">
                            <span class="status-text success">Success</span>
                            <button class="icon-btn active" title="Unpin"><i class="fa-solid fa-location-dot"></i></button>
                            <button class="icon-btn" title="Delete"><i class="fa-regular fa-trash-can"></i></button>
                        </div>
                    </div>
                    <div class="pin-status"><i class="fa-solid fa-thumbtack" style="font-size: 10px;"></i> Pinned</div>
                    <p>We are excited to announce the launch of "Data Structures with C++" by Prof. Michael Torres. Enroll today to master linked lists, trees, and hash tables from scratch.</p>
                    <div class="announcement-meta">2024-08-20 — System Admin</div>
                </div>
            </div>

            <!-- Warning Announcement -->
            <div class="announcement-card warning">
                <div class="announcement-icon"><i class="fa-solid fa-triangle-exclamation"></i></div>
                <div class="announcement-content">
                    <div class="announcement-title-row">
                        <h4>Scheduled Maintenance — Sept 5, 2024</h4>
                        <div class="announcement-actions">
                            <span class="status-text warning">Warning</span>
                            <button class="icon-btn active" title="Unpin"><i class="fa-solid fa-location-dot"></i></button>
                            <button class="icon-btn" title="Delete"><i class="fa-regular fa-trash-can"></i></button>
                        </div>
                    </div>
                    <div class="pin-status"><i class="fa-solid fa-thumbtack" style="font-size: 10px;"></i> Pinned</div>
                    <p>The platform will undergo scheduled maintenance on September 5th from 2:00 AM to 4:00 AM UTC. Some features may be temporarily unavailable during this period.</p>
                    <div class="announcement-meta">2024-08-25 — System Admin</div>
                </div>
            </div>

            <!-- Info Announcement -->
            <div class="announcement-card info">
                <div class="announcement-icon"><i class="fa-solid fa-circle-exclamation"></i></div>
                <div class="announcement-content">
                    <div class="announcement-title-row">
                        <h4>Python Quiz Marathon This Weekend</h4>
                        <div class="announcement-actions">
                            <span class="status-text info">Info</span>
                            <button class="icon-btn" title="Pin"><i class="fa-solid fa-location-dot"></i></button>
                            <button class="icon-btn" title="Delete"><i class="fa-regular fa-trash-can"></i></button>
                        </div>
                    </div>
                    <p>Complete all Python course quizzes this weekend to earn the special "Python Master" badge on your profile. Top scorers will be featured on the leaderboard.</p>
                    <div class="announcement-meta">2024-08-28 — System Admin</div>
                </div>
            </div>
        </div>

        <!-- Featured Courses Section -->
        <div class="section-header">
            <i class="fa-regular fa-star"></i> Featured Courses
        </div>

        <div class="courses-list">
            
            <div class="course-card">
                <div class="course-info">
                    <span class="course-badge badge-python">Python</span>
                    <div class="course-details">
                        <h5>Python for Beginners</h5>
                        <p>Dr. Sarah Park &bull; 128 enrolled</p>
                    </div>
                </div>
                <button class="btn-feature active">
                    <i class="fa-solid fa-star"></i> Featured
                </button>
            </div>

            <div class="course-card">
                <div class="course-info">
                    <span class="course-badge badge-java">Java</span>
                    <div class="course-details">
                        <h5>Java Fundamentals</h5>
                        <p>Prof. Michael Torres &bull; 94 enrolled</p>
                    </div>
                </div>
                <button class="btn-feature active">
                    <i class="fa-solid fa-star"></i> Featured
                </button>
            </div>

            <div class="course-card">
                <div class="course-info">
                    <span class="course-badge badge-c">C</span>
                    <div class="course-details">
                        <h5>C Programming Essentials</h5>
                        <p>Prof. Michael Torres &bull; 67 enrolled</p>
                    </div>
                </div>
                <button class="btn-feature">
                    <i class="fa-regular fa-star"></i> Feature
                </button>
            </div>

            <div class="course-card">
                <div class="course-info">
                    <span class="course-badge badge-cpp">C++</span>
                    <div class="course-details">
                        <h5>C++ Object-Oriented Programming</h5>
                        <p>Dr. Sarah Park &bull; 82 enrolled</p>
                    </div>
                </div>
                <button class="btn-feature active">
                    <i class="fa-solid fa-star"></i> Featured
                </button>
            </div>
            
            <div class="course-card">
                <div class="course-info">
                    <span class="course-badge badge-python">Python</span>
                    <div class="course-details">
                        <h5>Advanced Python — Data Structures & Algorithms</h5>
                        <p>Dr. Sarah Park &bull; 45 enrolled</p>
                    </div>
                </div>
                <button class="btn-feature">
                    <i class="fa-regular fa-star"></i> Feature
                </button>
            </div>

            <div class="course-card">
                <div class="course-info">
                    <span class="course-badge badge-cpp">C++</span>
                    <div class="course-details">
                        <h5>Data Structures with C++</h5>
                        <p>Prof. Michael Torres &bull; 38 enrolled</p>
                    </div>
                </div>
                <button class="btn-feature">
                    <i class="fa-regular fa-star"></i> Feature
                </button>
            </div>

        </div>
    </div>

    <!-- New Announcement Modal -->
    <div class="modal-overlay" id="announcementModal">
        <div class="modal-container">
            <h3 class="modal-header">New Announcement</h3>
            
            <div class="form-group">
                <label class="form-label">Title</label>
                <input type="text" class="form-control" placeholder="Announcement title..." id="modalTitle" />
            </div>

            <div class="form-group">
                <label class="form-label">Content</label>
                <textarea class="form-control" placeholder="Announcement details..." id="modalContent"></textarea>
            </div>

            <div class="form-row">
                <div class="type-select-wrapper">
                    <label class="form-label">Type</label>
                    <select class="form-control" id="modalType">
                        <option value="announcement">Announcement</option>
                        <option value="invitation">Invitation</option>
                    </select>
                </div>
                <div class="toggle-container">
                    <label class="switch">
                        <input type="checkbox" id="modalPinToggle" />
                        <span class="slider"></span>
                    </label>
                    <span>Pin it</span>
                </div>
            </div>

            <div class="modal-actions">
                <button class="btn-cancel" onclick="closeModal()">Cancel</button>
                <button class="btn-submit" onclick="submitAnnouncement()">Post Announcement</button>
            </div>
        </div>
    </div>

    <!-- JavaScript logic -->
    <script>
// Modal logic
const modal = document.getElementById('announcementModal');

function openModal() {
    modal.classList.add('active');
    // Clear previous inputs
    document.getElementById('modalTitle').value = '';
    document.getElementById('modalContent').value = '';
    document.getElementById('modalType').value = 'announcement';
    document.getElementById('modalPinToggle').checked = false;
}

function closeModal() {
    modal.classList.remove('active');
}

// Close modal if user clicks outside the container
modal.addEventListener('click', function (e) {
    if (e.target === modal) {
        closeModal();
    }
});

function submitAnnouncement() {
    const title = document.getElementById('modalTitle').value;
    const content = document.getElementById('modalContent').value;

    if (!title.trim() || !content.trim()) {
        alert("Please fill in both title and content.");
        return;
    }

    // In a real application, you would send this data to your backend API
    console.log("Submitting Announcement:", {
        title: title,
        content: content,
        type: document.getElementById('modalType').value,
        pinned: document.getElementById('modalPinToggle').checked
    });

    closeModal();
    alert("Announcement posted successfully!");
}

// Toggle Feature logic
document.querySelectorAll('.btn-feature').forEach(btn => {
    btn.addEventListener('click', function () {
        if (this.classList.contains('active')) {
            this.classList.remove('active');
            this.innerHTML = '<i class="fa-regular fa-star"></i> Feature';
        } else {
            this.classList.add('active');
            this.innerHTML = '<i class="fa-solid fa-star"></i> Featured';
        }
    });
});
</script>
</body>
</html>
