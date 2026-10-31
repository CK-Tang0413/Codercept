<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LandingPage.aspx.cs" Inherits="Codercept.LandingPage" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Codercept - Master Coding Interactive</title>
    
    <!-- Import Global Variables -->
    <link href="css/global.css" rel="stylesheet" type="text/css" />

    <style>

        /* 1. Base Public Page Reset & Enable Scrolling */
        html, body { 
            height: auto !important; 
            min-height: 100vh;
            margin: 0; 
            padding: 0; 
            background: var(--bg-main); 
            color: var(--text-primary); 
            font-family: 'Inter', sans-serif; 
            overflow-y: auto !important; /* Forces vertical scrolling */
            overflow-x: hidden; 
        }
        /* Base Public Page Reset */
        body { margin: 0; padding: 0; background: var(--bg-main); color: var(--text-primary); font-family: 'Inter', sans-serif; overflow-x: hidden; }
        
        /* Public Navigation */
        .public-nav { position: fixed; top: 0; width: 100%; height: 70px; background: rgba(15, 23, 42, 0.85); backdrop-filter: blur(10px); border-bottom: 1px solid var(--border-light); display: flex; align-items: center; justify-content: space-between; padding: 0 5%; z-index: 1000; }
        .nav-brand { display: flex; align-items: center; gap: 0.75rem; font-size: 1.25rem; font-weight: 700; color: white; text-decoration: none; }
        .nav-brand img { width: 32px; height: 32px; }
        .nav-links { display: flex; gap: 2rem; align-items: center; }
        /* 2. Brighter, Larger Nav Links */
        .nav-link { 
            color: #f8fafc; /* Bright white/grey */
            text-decoration: none; 
            font-weight: 600; 
            font-size: 1.05rem; /* Increased size */
            transition: color 0.2s; 
        }
        .nav-link:hover { color: #c084fc; /* Light purple on hover */ }
        .nav-actions { display: flex; gap: 1rem; align-items: center; }
        
        .btn-outline { padding: 0.6rem 1.25rem; border-radius: 8px; font-weight: 600; text-decoration: none; color: white; border: 1px solid rgba(255, 255, 255, 0.2); transition: all 0.2s; }
        .btn-outline:hover { background: rgba(255, 255, 255, 0.1); }
        .btn-sunset { padding: 0.6rem 1.25rem; border-radius: 8px; font-weight: 600; text-decoration: none; color: white; background: linear-gradient(120deg, #7c3aed 0%, #db2777 50%, #f97316 100%); border: none; box-shadow: 0 4px 15px rgba(124, 58, 237, 0.25); transition: transform 0.2s, opacity 0.2s; }
        .btn-sunset:hover { opacity: 0.92; transform: translateY(-1px); }

        /* Hero Section */
        .hero { position: relative; min-height: 85vh; display: flex; align-items: center; justify-content: center; text-align: center; padding: 100px 5% 50px; overflow: hidden; }
        .hero::before { content: ""; position: absolute; inset: 0; background: radial-gradient(circle at 50% 30%, rgba(124, 58, 237, 0.15), transparent 60%); z-index: 0; }
        .hero-content { position: relative; z-index: 1; max-width: 800px; display: flex; flex-direction: column; align-items: center; }
        .hero-badge { background: rgba(124, 58, 237, 0.1); border: 1px solid var(--accent-border); color: var(--accent-light); padding: 0.4rem 1rem; border-radius: 20px; font-size: 0.85rem; font-weight: 600; margin-bottom: 1.5rem; display: inline-block; }
        .hero h1 { font-size: 3.5rem; line-height: 1.1; margin-bottom: 1.5rem; font-weight: 800; letter-spacing: -0.03em; }
        .hero h1 span { background: linear-gradient(120deg, #7c3aed 0%, #db2777 50%, #f97316 100%); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
        .hero p { font-size: 1.15rem; color: var(--text-secondary); line-height: 1.6; margin-bottom: 2.5rem; max-width: 600px; }
        .hero-buttons { display: flex; gap: 1rem; }
        .hero-buttons .btn-sunset { padding: 0.875rem 2rem; font-size: 1.05rem; }
        /* 3. Visible Hero Outline Button */
        .hero-buttons .btn-outline { 
            padding: 0.875rem 2rem; 
            font-size: 1.05rem; 
            background: transparent; 
            color: var(--text-primary) !important; /* Force dark text */
            border: 2px solid var(--border-light); 
            font-weight: 600;
        }
        .hero-buttons .btn-outline:hover { 
            border-color: var(--accent-primary); 
            background: rgba(124, 58, 237, 0.05); /* Very light purple tint on hover */
        }

        /* Container Standard */
        .container { max-width: 1200px; margin: 0 auto; padding: 5rem 5%; }
        .section-header { text-align: center; margin-bottom: 3.5rem; }
        .section-header h2 { font-size: 2.25rem; font-weight: 700; margin-bottom: 1rem; }
        .section-header p { font-size: 1.05rem; color: var(--text-secondary); max-width: 600px; margin: 0 auto; }

        /* About / Features Grid */
        .features-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 2rem; }
        .feature-card { background: var(--bg-surface); border: 1px solid var(--border-light); padding: 2.5rem 2rem; border-radius: 16px; text-align: center; transition: transform 0.2s; box-shadow: var(--shadow); }
        .feature-card:hover { transform: translateY(-5px); border-color: var(--accent-primary); }
        .feature-icon { width: 64px; height: 64px; background: rgba(124, 58, 237, 0.1); color: var(--accent-light); border-radius: 16px; display: inline-flex; align-items: center; justify-content: center; margin-bottom: 1.5rem; }
        .feature-icon svg { width: 32px; height: 32px; }
        .feature-title { font-size: 1.25rem; font-weight: 600; margin-bottom: 1rem; color: white; }
        .feature-desc { font-size: 0.95rem; color: var(--text-secondary); line-height: 1.6; }

        /* Footer */
        .footer { background: var(--bg-surface); border-top: 1px solid var(--border-light); padding: 3rem 5%; text-align: center; color: var(--text-muted); font-size: 0.9rem; }

        @media (max-width: 992px) {
            .hero h1 { font-size: 2.5rem; }
            .features-grid { grid-template-columns: 1fr; }
            .nav-links { display: none; } /* Hide links on mobile, keep buttons */
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        
        <!-- Public Navigation -->
        <nav class="public-nav">
            <a href="LandingPage.aspx" class="nav-brand">
                <img src="img/Codercept_Icon.png" alt="Codercept" />
                Codercept
            </a>
            <div class="nav-links">
                <a href="#about" class="nav-link">About</a>
                <a href="#courses" class="nav-link">Courses</a>
            </div>
            <div class="nav-actions">
                <a href="signIn.aspx" class="btn-outline">Sign In</a>
                <a href="signUp.aspx" class="btn-sunset">Sign Up</a>
            </div>
        </nav>

        <!-- Hero Section -->
        <header class="hero">
            <div class="hero-content">
                <div class="hero-badge">Welcome to the future of learning</div>
                <h1>Master Coding with <span>Interactive</span> Precision.</h1>
                <p>An immersive e-learning platform designed for aspiring developers. Experience real-time coding challenges, comprehensive courses, and an active developer community.</p>
                <div class="hero-buttons">
                    <a href="signUp.aspx" class="btn-sunset">Start Learning for Free</a>
                    <a href="#courses" class="btn-outline">Explore Catalog</a>
                </div>
            </div>
        </header>

        <!-- About / Features Section -->
        <section id="about" class="container" style="background: rgba(255,255,255,0.02); border-top: 1px solid var(--border-light); border-bottom: 1px solid var(--border-light); max-width: 100%;">
            <div style="max-width: 1200px; margin: 0 auto;">
                <div class="section-header">
                    <h2>Why choose Codercept?</h2>
                    <p>We bridge the gap between theory and practical application with our state-of-the-art interactive platform.</p>
                </div>
                <div class="features-grid">
                    <div class="feature-card">
                        <div class="feature-icon">
                            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4"/></svg>
                        </div>
                        <h3 class="feature-title">Integrated IDE</h3>
                        <p class="feature-desc">Write, execute, and test code directly in your browser. No local environment setup required to pass our dynamic coding assessments.</p>
                    </div>
                    <div class="feature-card">
                        <div class="feature-icon">
                            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/></svg>
                        </div>
                        <h3 class="feature-title">Structured Curriculum</h3>
                        <p class="feature-desc">From basic logic to advanced data structures, our courses are meticulously crafted by industry veterans and verified teachers.</p>
                    </div>
                    <div class="feature-card">
                        <div class="feature-icon">
                            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 8h2a2 2 0 012 2v6a2 2 0 01-2 2h-2v4l-4-4H9a1.994 1.994 0 01-1.414-.586m0 0L11 14h4a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2v4l.586-.586z"/></svg>
                        </div>
                        <h3 class="feature-title">Active Community</h3>
                        <p class="feature-desc">Get stuck? Jump into our integrated discussion forums to ask questions, share knowledge, and learn alongside your peers.</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- Course Preview Section -->
        <section id="courses" class="container">
            <div class="section-header">
                <h2>Explore Our Courses</h2>
                <p>Browse a preview of our top-rated programming courses. Sign up to unlock full syllabuses, chapters, and enroll.</p>
            </div>

            <!-- Reuse the Course Grid layout from LearnerDashboard -->
            <div class="course-grid">
                <asp:Repeater ID="rptPublicCourses" runat="server">
                    <ItemTemplate>
                        <!-- Clicking intercept via JavaScript -->
                        <a href="javascript:showRegistrationModal();" class="course-card">
                            <div class='course-thumbnail course-thumbnail--<%# Eval("LanguageCSS") %>'>
                                <span class='card-floating-badge badge-<%# Eval("DifficultyLevel").ToString().ToLower() %>'><%# Eval("DifficultyLevel") %></span>
                                <span><%# Eval("Language").ToString().Substring(0, 1) %></span>
                            </div>
                            
                            <div class="course-content">
                                <h3 class="course-title"><%# Eval("CourseTitle") %></h3>
                                <p class="course-desc"><%# Eval("CourseDescription") %></p>
                                
                                <div class="course-meta-grid">
                                    <span class="course-meta-item">📖 <%# Eval("Chapters") %> chapters</span>
                                    <span class="course-meta-item">⏱️ <%# Eval("CourseDuration") %></span>
                                    <span class="course-meta-item">⭐ <%# Eval("Rating") %> Rating</span>
                                    <span class="course-meta-item">👥 <%# Eval("EnrolledCount") %> enrolled</span>
                                </div>
                                
                                <span class="course-action-btn enroll" style="background: rgba(255,255,255,0.05); color: var(--text-secondary); text-align: center;">Sign In to View</span>
                            </div>
                        </a>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </section>

        <!-- Footer -->
        <footer class="footer">
            <p>&copy; <%= DateTime.Now.Year %> Codercept. All rights reserved.</p>
        </footer>

        <!-- Registration Intercept Modal -->
        <div id="registrationModal" style="display: none; position: fixed; inset: 0; background: rgba(15, 23, 42, 0.7); backdrop-filter: blur(5px); z-index: 9999; justify-content: center; align-items: center;">
            <div style="background: var(--bg-surface); border: 1px solid var(--border-light); padding: 2.5rem; border-radius: 16px; max-width: 450px; text-align: center; box-shadow: 0 20px 40px rgba(0,0,0,0.5); width: 90%; animation: popIn 0.3s ease-out;">
            
                <div style="width: 56px; height: 56px; background: rgba(124, 58, 237, 0.1); color: var(--accent-light); border-radius: 50%; display: inline-flex; align-items: center; justify-content: center; margin-bottom: 1.5rem;">
                    <svg fill="none" stroke="currentColor" viewBox="0 0 24 24" width="28" height="28"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/></svg>
                </div>

                <h3 style="margin-bottom: 1rem; color: white; font-size: 1.5rem;">Unlock Course Content</h3>
                <p style="margin-bottom: 2rem; color: var(--text-secondary); font-size: 0.95rem; line-height: 1.6;">
                    You need a free account to view chapter details, take quizzes, and enroll in courses. Ready to start your learning journey?
                </p>
            
                <div style="display: flex; gap: 1rem; justify-content: center;">
                    <button type="button" onclick="hideRegistrationModal()" style="padding: 0.75rem 1.5rem; border: 1px solid var(--border-light); background: var(--bg-main); border-radius: 8px; cursor: pointer; color: var(--text-secondary); font-weight: 600; flex: 1; transition: background 0.2s;">
                        Cancel
                    </button>
                    <a href="signUp.aspx" class="btn-sunset" style="flex: 1; text-align: center;">
                        Sign Up Now
                    </a>
                </div>
                <div style="margin-top: 1.5rem; font-size: 0.85rem; color: var(--text-muted);">
                    Already have an account? <a href="signIn.aspx" style="color: var(--accent-light); text-decoration: none; font-weight: 600;">Sign in</a>
                </div>
            </div>
        </div>

        <style>
            @keyframes popIn { 0% { transform: scale(0.95); opacity: 0; } 100% { transform: scale(1); opacity: 1; } }
        </style>

        <script type="text/javascript">
function showRegistrationModal() {
    var modal = document.getElementById('registrationModal');
    if (modal) modal.style.display = 'flex';
}

function hideRegistrationModal() {
    var modal = document.getElementById('registrationModal');
    if (modal) modal.style.display = 'none';
}

// Close on outside click
window.onclick = function (event) {
    var modal = document.getElementById('registrationModal');
    if (event.target == modal) hideRegistrationModal();
}
</script>
    </form>
</body>
</html>