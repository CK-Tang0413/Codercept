<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin Courses.aspx.cs" Inherits="Codercept.Admin_Courses" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Course Management</title>
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
            
            --success-green: #10b981;
            --success-green-bg: rgba(16, 185, 129, 0.1);
            --success-green-border: rgba(16, 185, 129, 0.2);
            
            --warning-orange: #f59e0b;
            --warning-orange-bg: rgba(245, 158, 11, 0.05);
            --warning-orange-border: rgba(245, 158, 11, 0.2);
            
            /* Language Badges */
            --course-python: #3b82f6; 
            --course-python-bg: rgba(59, 130, 246, 0.15);
            
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

        /* --- Header --- */
        .page-header {
            margin-bottom: 24px;
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

        /* --- Table Setup --- */
        .course-table {
            background-color: var(--bg-panel);
            border: 1px solid var(--border-color);
            border-radius: 10px;
            overflow: hidden;
        }
        
        .list-header, .list-row {
            display: grid;
            grid-template-columns: 2.5fr 1fr 1.5fr 0.8fr 0.8fr 1fr 0.8fr 1.2fr;
            padding: 16px 24px;
            align-items: center;
        }

        .list-header {
            border-bottom: 1px solid var(--border-color);
            color: var(--text-secondary);
            font-size: 13px;
            font-weight: 500;
        }
        
        .list-row {
            border-bottom: 1px solid var(--border-color);
        }
        .list-row:last-child {
            border-bottom: none;
        }

        /* --- Column Styles --- */
        
        /* Course Info */
        .course-meta h5 {
            font-size: 15px;
            font-weight: 500;
            margin-bottom: 2px;
            color: var(--text-primary);
        }
        .course-meta p {
            font-size: 13px;
            color: var(--text-secondary);
        }

        /* Language Badges */
        .badge {
            display: inline-flex;
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 500;
        }
        .badge-python { background-color: var(--course-python-bg); color: var(--course-python); }
        .badge-java { background-color: var(--course-java-bg); color: var(--course-java); }
        .badge-c { background-color: var(--course-c-bg); color: var(--course-c); }
        .badge-cpp { background-color: var(--course-cpp-bg); color: var(--course-cpp); }

        /* Teacher */
        .col-teacher {
            font-size: 14px;
            color: var(--text-secondary);
        }

        /* Enrolled */
        .col-enrolled {
            font-size: 14px;
            font-weight: 500;
            text-align: center;
        }

        /* Rating */
        .col-rating {
            font-size: 14px;
            color: var(--text-secondary);
            display: flex;
            align-items: center;
            gap: 4px;
        }
        .col-rating i { color: var(--warning-orange); font-size: 12px; }

        /* Status */
        .badge-status {
            display: inline-flex;
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 500;
            border: 1px solid transparent;
        }
        .status-published {
            background-color: var(--success-green-bg);
            color: var(--success-green);
            border-color: var(--success-green-border);
        }
        .status-draft {
            background-color: rgba(255,255,255,0.05);
            color: var(--text-secondary);
            border-color: var(--border-color);
        }

        /* Featured Star Button */
        .col-featured {
            text-align: center;
        }
        
        .btn-star {
            background: none;
            border: none;
            cursor: pointer;
            font-size: 16px;
            padding: 4px;
            transition: transform 0.2s ease;
        }
        
        .btn-star:hover {
            transform: scale(1.15);
        }
        
        .star-active { color: var(--warning-orange); }
        .star-inactive { color: var(--border-color); }

        /* Actions */
        .col-actions {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 8px;
        }
        
        .btn-action {
            background: none;
            padding: 6px 12px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
            border: 1px solid var(--border-color);
            color: var(--text-secondary);
        }
        
        .btn-action:hover {
            background-color: rgba(255, 255, 255, 0.05);
            color: var(--text-primary);
        }

        /* Active state for unfeature button */
        .btn-action.active-feature {
            border-color: var(--warning-orange-border);
            color: var(--warning-orange);
            background-color: var(--warning-orange-bg);
        }
        .btn-action.active-feature:hover {
            background-color: rgba(245, 158, 11, 0.15);
        }
        
    </style>
</head>
<body>
    <div class="main-content">
        
        <!-- Header -->
        <div class="page-header">
            <h1>Course Management</h1>
            <p>6 total courses, 6 published</p>
        </div>

        <!-- Table -->
        <div class="course-table">
            <div class="list-header">
                <div>Course</div>
                <div>Language</div>
                <div>Teacher</div>
                <div style="text-align: center;">Enrolled</div>
                <div>Rating</div>
                <div>Status</div>
                <div style="text-align: center;">Featured</div>
                <div style="text-align: right;">Actions</div>
            </div>

            <div id="courseListContainer">
                
                <!-- Course 1 -->
                <div class="list-row">
                    <div class="course-meta">
                        <h5>Python for Beginners</h5>
                        <p>Beginner</p>
                    </div>
                    <div><span class="badge badge-python">Python</span></div>
                    <div class="col-teacher">Dr. Sarah Park</div>
                    <div class="col-enrolled">128</div>
                    <div class="col-rating"><i class="fa-solid fa-star"></i> 4.8</div>
                    <div><span class="badge-status status-published">Published</span></div>
                    <div class="col-featured">
                        <button class="btn-star" onclick="toggleFeature(this)">
                            <i class="fa-solid fa-star star-active"></i>
                        </button>
                    </div>
                    <div class="col-actions">
                        <button class="btn-action active-feature" onclick="toggleFeature(this)">Unfeature</button>
                        <button class="btn-action" onclick="togglePublish(this)">Unpublish</button>
                    </div>
                </div>

                <!-- Course 2 -->
                <div class="list-row">
                    <div class="course-meta">
                        <h5>Java Fundamentals</h5>
                        <p>Beginner</p>
                    </div>
                    <div><span class="badge badge-java">Java</span></div>
                    <div class="col-teacher">Prof. Michael Torres</div>
                    <div class="col-enrolled">94</div>
                    <div class="col-rating"><i class="fa-solid fa-star"></i> 4.6</div>
                    <div><span class="badge-status status-published">Published</span></div>
                    <div class="col-featured">
                        <button class="btn-star" onclick="toggleFeature(this)">
                            <i class="fa-solid fa-star star-active"></i>
                        </button>
                    </div>
                    <div class="col-actions">
                        <button class="btn-action active-feature" onclick="toggleFeature(this)">Unfeature</button>
                        <button class="btn-action" onclick="togglePublish(this)">Unpublish</button>
                    </div>
                </div>

                <!-- Course 3 -->
                <div class="list-row">
                    <div class="course-meta">
                        <h5>C Programming Essentials</h5>
                        <p>Intermediate</p>
                    </div>
                    <div><span class="badge badge-c">C</span></div>
                    <div class="col-teacher">Prof. Michael Torres</div>
                    <div class="col-enrolled">67</div>
                    <div class="col-rating"><i class="fa-solid fa-star"></i> 4.5</div>
                    <div><span class="badge-status status-published">Published</span></div>
                    <div class="col-featured">
                        <button class="btn-star" onclick="toggleFeature(this)">
                            <i class="fa-regular fa-star star-inactive"></i>
                        </button>
                    </div>
                    <div class="col-actions">
                        <button class="btn-action" onclick="toggleFeature(this)">Feature</button>
                        <button class="btn-action" onclick="togglePublish(this)">Unpublish</button>
                    </div>
                </div>

                <!-- Course 4 -->
                <div class="list-row">
                    <div class="course-meta">
                        <h5>C++ Object-Oriented Programming</h5>
                        <p>Intermediate</p>
                    </div>
                    <div><span class="badge badge-cpp">C++</span></div>
                    <div class="col-teacher">Dr. Sarah Park</div>
                    <div class="col-enrolled">82</div>
                    <div class="col-rating"><i class="fa-solid fa-star"></i> 4.7</div>
                    <div><span class="badge-status status-published">Published</span></div>
                    <div class="col-featured">
                        <button class="btn-star" onclick="toggleFeature(this)">
                            <i class="fa-solid fa-star star-active"></i>
                        </button>
                    </div>
                    <div class="col-actions">
                        <button class="btn-action active-feature" onclick="toggleFeature(this)">Unfeature</button>
                        <button class="btn-action" onclick="togglePublish(this)">Unpublish</button>
                    </div>
                </div>

                <!-- Course 5 -->
                <div class="list-row">
                    <div class="course-meta">
                        <h5>Advanced Python — Data Structures & Algorithms</h5>
                        <p>Advanced</p>
                    </div>
                    <div><span class="badge badge-python">Python</span></div>
                    <div class="col-teacher">Dr. Sarah Park</div>
                    <div class="col-enrolled">45</div>
                    <div class="col-rating"><i class="fa-solid fa-star"></i> 4.9</div>
                    <div><span class="badge-status status-published">Published</span></div>
                    <div class="col-featured">
                        <button class="btn-star" onclick="toggleFeature(this)">
                            <i class="fa-regular fa-star star-inactive"></i>
                        </button>
                    </div>
                    <div class="col-actions">
                        <button class="btn-action" onclick="toggleFeature(this)">Feature</button>
                        <button class="btn-action" onclick="togglePublish(this)">Unpublish</button>
                    </div>
                </div>

                <!-- Course 6 -->
                <div class="list-row">
                    <div class="course-meta">
                        <h5>Data Structures with C++</h5>
                        <p>Advanced</p>
                    </div>
                    <div><span class="badge badge-cpp">C++</span></div>
                    <div class="col-teacher">Prof. Michael Torres</div>
                    <div class="col-enrolled">38</div>
                    <div class="col-rating"><i class="fa-solid fa-star"></i> 4.4</div>
                    <div><span class="badge-status status-published">Published</span></div>
                    <div class="col-featured">
                        <button class="btn-star" onclick="toggleFeature(this)">
                            <i class="fa-regular fa-star star-inactive"></i>
                        </button>
                    </div>
                    <div class="col-actions">
                        <button class="btn-action" onclick="toggleFeature(this)">Feature</button>
                        <button class="btn-action" onclick="togglePublish(this)">Unpublish</button>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <!-- JavaScript logic -->
    <script>
        // Toggle Feature status (Syncs both the star icon and the text button)
        function toggleFeature(element) {
            const row = element.closest('.list-row');
            
            // Get both the action button and the star icon inside this row
            const actionBtn = row.querySelector('.col-actions .btn-action:first-child');
            const starIcon = row.querySelector('.col-featured i');

            // Determine if it is currently featured by checking the action button's class
            const isCurrentlyFeatured = actionBtn.classList.contains('active-feature');

            if (isCurrentlyFeatured) {
                // Turn OFF feature
                actionBtn.classList.remove('active-feature');
                actionBtn.innerText = 'Feature';
                
                starIcon.classList.remove('star-active', 'fa-solid');
                starIcon.classList.add('star-inactive', 'fa-regular');
            } else {
                // Turn ON feature
                actionBtn.classList.add('active-feature');
                actionBtn.innerText = 'Unfeature';
                
                starIcon.classList.remove('star-inactive', 'fa-regular');
                starIcon.classList.add('star-active', 'fa-solid');
            }
        }

        // Toggle Publish status
        function togglePublish(button) {
            const row = button.closest('.list-row');
            const statusBadge = row.querySelector('.badge-status');

            if (button.innerText === 'Unpublish') {
                // Change to Draft
                button.innerText = 'Publish';
                statusBadge.classList.remove('status-published');
                statusBadge.classList.add('status-draft');
                statusBadge.innerText = 'Draft';
            } else {
                // Change to Published
                button.innerText = 'Unpublish';
                statusBadge.classList.remove('status-draft');
                statusBadge.classList.add('status-published');
                statusBadge.innerText = 'Published';
            }
        }
    </script>
</body>
</html>
