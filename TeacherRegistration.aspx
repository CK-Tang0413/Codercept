<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TeacherRegistration.aspx.cs" Inherits="Codercept.TeacherRegistration" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Teacher Registration - Codercept</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body, html { height: 100%; background-color: #ffffff; }
        .split-layout { display: flex; min-height: 100vh; }
        
        /* Left Panel Styles */
        .left-panel { flex: 1; background: #0f0a19; background-image: radial-gradient(circle at 50% 50%, #2e1065 0%, #0f0a19 60%), linear-gradient(rgba(255, 255, 255, 0.03) 1px, transparent 1px), linear-gradient(90deg, rgba(255, 255, 255, 0.03) 1px, transparent 1px); background-size: 100% 100%, 40px 40px, 40px 40px; color: white; padding: 3rem; display: flex; flex-direction: column; position: relative; overflow: hidden; }
        .brand { display: flex; align-items: center; gap: 0.5rem; font-size: 1.25rem; font-weight: 700; text-decoration: none; color: white; }
        .hero-content { margin-top: auto; margin-bottom: auto; max-width: 80%; position: relative; z-index: 2; }
        .hero-content h1 { font-size: 4rem; line-height: 1.1; margin-bottom: 1.5rem; }
        .hero-content p { color: #a1a1aa; font-size: 1.1rem; line-height: 1.6; margin-bottom: 3rem; max-width: 400px; }
        .text-purple { color: #7c3aed; }
        .snippet { position: absolute; background: rgba(255, 255, 255, 0.05); border: 1px solid rgba(255, 255, 255, 0.1); padding: 0.5rem 1rem; border-radius: 8px; font-family: monospace; font-size: 0.85rem; color: #a1a1aa; backdrop-filter: blur(4px); }
        .snip-1 { top: 20%; left: 10%; color: #4ade80; } .snip-2 { top: 35%; right: 15%; color: #60a5fa; } .snip-3 { bottom: 25%; left: 15%; color: #c084fc; } .snip-4 { bottom: 10%; right: 20%; color: #34d399; }
        
        /* Right Panel Styles */
        .right-panel { flex: 1; display: flex; justify-content: center; align-items: center; padding: 2rem; overflow-y: auto; }
        .form-container { width: 100%; max-width: 480px; }
        .form-header h2 { font-size: 2rem; color: #18181b; margin-bottom: 0.5rem; }
        .form-header p { color: #71717a; font-size: 0.95rem; margin-bottom: 2rem; }
        
        /* Role Toggle */
        .role-toggle { display: flex; background: #e4e4e7; padding: 0.25rem; border-radius: 8px; margin-bottom: 1.5rem; }
        .role-toggle label { flex: 1; text-align: center; padding: 0.6rem; color: #71717a; font-weight: 600; font-size: 0.9rem; border-radius: 6px; cursor: pointer; transition: all 0.2s; margin: 0; }
        .role-toggle input[type="radio"] { display: none; }
        .role-toggle input[type="radio"]:checked + label { background: white; color: #18181b; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        
        /* Form Controls */
        .form-group { margin-bottom: 1.25rem; }
        .form-group label { display: block; margin-bottom: 0.5rem; font-size: 0.875rem; font-weight: 600; color: #27272a; }
        .form-control { width: 100%; padding: 0.75rem 1rem; border: 1px solid #e4e4e7; border-radius: 8px; font-size: 0.95rem; transition: border-color 0.2s; background: #fafafa; }
        .form-control:focus { outline: none; border-color: #7c3aed; background: white; box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1); }
        
        .checkbox-wrapper { display: flex; align-items: center; gap: 0.5rem; margin-bottom: 1.5rem; }
        .checkbox-wrapper label { font-size: 0.85rem; color: #71717a; cursor: pointer; }
        
        /* Checkbox Grid for Languages */
        .lang-grid { display: flex; flex-wrap: wrap; gap: 1rem; margin-bottom: 0.5rem; }
        .lang-item { display: flex; align-items: center; gap: 0.4rem; font-size: 0.9rem; color: #3f3f46; }
        .others-input { padding: 0.25rem 0.5rem; border: 1px solid #e4e4e7; border-radius: 4px; font-size: 0.85rem; width: 120px; outline: none; }
        .others-input:focus { border-color: #7c3aed; }

        /* File Upload Zone */
        .upload-zone { border: 2px dashed #d4d4d8; border-radius: 8px; padding: 2rem; text-align: center; background: #fafafa; cursor: pointer; transition: border-color 0.2s; margin-bottom: 1.5rem; position: relative; }
        .upload-zone:hover { border-color: #a855f7; }
        .upload-zone span { display: block; font-weight: 600; color: #52525b; margin-top: 0.5rem; }
        .upload-zone svg { width: 24px; height: 24px; color: #a1a1aa; }
        .file-input { position: absolute; top: 0; left: 0; width: 100%; height: 100%; opacity: 0; cursor: pointer; }
        
        /* Buttons */
        .btn-submit { width: 100%; padding: 0.875rem; background: #c084fc; color: white; border: none; border-radius: 8px; font-size: 1rem; font-weight: 600; cursor: pointer; transition: background 0.2s; }
        .btn-submit:hover { background: #a855f7; }
        .btn-back { width: 100%; padding: 0.875rem; background: transparent; color: #71717a; border: 1px solid #e4e4e7; border-radius: 8px; font-size: 1rem; font-weight: 600; cursor: pointer; transition: all 0.2s; margin-top: 0.75rem; }
        .btn-back:hover { background: #f4f4f5; color: #18181b; }
        
        /* Alert Banners */
        .alert-banner { padding: 0.75rem 1rem; border-radius: 8px; margin-bottom: 1.25rem; font-size: 0.875rem; font-weight: 500; }
        .alert-banner.error { background: #fee2e2; color: #b91c1c; border: 1px solid #fca5a5; }
        .alert-banner.success { background: #dcfce7; color: #15803d; border: 1px solid #86efac; }

        /* Step Management */
        .step-container { display: none; animation: fadeIn 0.3s ease-in-out; }
        .step-container.active { display: block; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
        
        /* Tablet & Large Mobile (768px) */
        @media (max-width: 768px) { 
            /* Break the flex row layout completely */
            .split-layout { display: block; } 
            
            /* Hide the dark left panel */
            .left-panel { display: none !important; } 
            
            /* Turn right panel into a standard block that fills the screen */
            .right-panel { 
                display: block; 
                padding: 3rem 2rem; 
                min-height: 100vh; 
            } 
            
            /* Center the form within the full-width block */
            .form-container { 
                margin: 0 auto; 
                max-width: 480px; 
            }
        }

        /* Small Mobile Phones (440px) */
        @media (max-width: 440px) {
            .right-panel { padding: 1.25rem; padding-top: 2rem; }
            .form-header h2 { font-size: 1.75rem; }
            .form-header p { margin-bottom: 1.25rem; font-size: 0.85rem; }
            
            .auth-toggle a { padding: 0.5rem; font-size: 0.85rem; }
            .form-group { margin-bottom: 1rem; }
            .form-group label { font-size: 0.8rem; }
            .form-control { padding: 0.65rem 0.85rem; font-size: 0.9rem; }
            
            .options-row { flex-direction: column; align-items: flex-start; gap: 0.75rem; margin-bottom: 1.25rem; }
            .btn-submit, .btn-guest, .btn-back { padding: 0.75rem; font-size: 0.95rem; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server" enctype="multipart/form-data">
        <asp:HiddenField ID="hfActiveStep" runat="server" Value="1" />
        <div class="split-layout">
            <div class="left-panel">
                <a href="signIn.aspx" class="brand">
                    <img src="~/img/Codercept_Icon.png" alt="Codercept Logo" runat="server" style="height: 40px; width: auto;" />
                    Codercept
                </a>
                <div class="snippet snip-1">py def teach(student):</div>
                <div class="snippet snip-2">js mentor.guide(skills)</div>
                <div class="snippet snip-3">ts const grow = () => inspire()</div>
                <div class="snippet snip-4">css visibility: visible;</div>
                <div class="hero-content">
                    <h1>Empower<br /><span class="text-purple">future</span><br />coders.</h1>
                    <p>Share your expertise, build interactive courses, and help shape the next generation of developers.</p>
                </div>
            </div>

            <div class="right-panel">
                <div class="form-container">
                    
                    <asp:Panel ID="pnlAlert" runat="server" Visible="false" CssClass="alert-banner error">
                        <asp:Label ID="lblAlertMessage" runat="server" />
                    </asp:Panel>

                    <!-- STEP 1: Basic Information -->
                    <div id="step1" class="step-container active">
                        <div class="form-header">
                            <h2>Join as an Educator</h2>
                            <p>Step 1 of 2: Create your account credentials.</p>
                        </div>

                        <div class="form-group">
                            <label>Full name</label>
                            <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="Alex Tran"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label>Email address</label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="you@university.edu"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label>Password</label>
                            <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="At least 8 characters"></asp:TextBox>
                        </div>
                        <div class="form-group">
                            <label>Confirm password</label>
                            <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="Repeat your password"></asp:TextBox>
                        </div>

                        <div class="checkbox-wrapper">
                            <input type="checkbox" id="chkShowPassword" onclick="toggleSignUpPassword()" />
                            <label for="chkShowPassword">Show Password</label>
                        </div>

                        <button type="button" class="btn-submit" onclick="validateStep1AndProceed()">Next: Qualifications</button>
                        
                        <div style="text-align: center; margin-top: 1.5rem; font-size: 0.875rem; color: #71717a;">
                            Already have an educator account? <a href="signIn.aspx" style="color: #7c3aed; font-weight: 600; text-decoration: none;">Sign in</a>
                        </div>
                    </div>

                    <!-- STEP 2: Qualifications & Upload -->
                    <div id="step2" class="step-container">
                        <div class="form-header">
                            <h2>Academic Qualification</h2>
                            <p>Step 2 of 2: Verify your teaching credentials.</p>
                        </div>

                        <!-- Role Toggle -->
                        <div class="role-toggle">
                            <input type="radio" id="roleTeacher" name="RoleSelection" value="Teacher" checked="checked" />
                            <label for="roleTeacher">Teacher</label>

                            <input type="radio" id="roleAssistant" name="RoleSelection" value="Assistant" />
                            <label for="roleAssistant">Teaching Assistant</label>
                        </div>

                        <!-- Qualifications -->
                        <div class="form-group">
                            <label>Highest Qualification Level</label>
                            <asp:TextBox ID="txtQualification" runat="server" CssClass="form-control" placeholder="e.g., Bachelor of Computer Science"></asp:TextBox>
                        </div>
                        
                        <div class="form-group">
                            <label>Subject Area (Optional)</label>
                            <asp:TextBox ID="txtSubjectArea" runat="server" CssClass="form-control" placeholder="e.g., Computer Science / Data Analytics"></asp:TextBox>
                        </div>

                        <!-- Programming Languages Checkboxes: strictly 4 languages -->
                        <div class="form-group">
                            <label>Proficient Programming Languages</label>
                            <div class="lang-grid">
                                <label class="lang-item"><input type="checkbox" runat="server" id="chkJava" /> Java</label>
                                <label class="lang-item"><input type="checkbox" runat="server" id="chkPython" /> Python</label>
                                <label class="lang-item"><input type="checkbox" runat="server" id="chkCpp" /> C++</label>
                                <label class="lang-item"><input type="checkbox" runat="server" id="chkC" /> C</label>
                            </div>
                        </div>

                        <!-- Document Upload -->
                        <div class="form-group">
                            <label>Upload Document (Certificate/Transcript - PDF, PNG, JPG)</label>
                            <div class="upload-zone" id="dropZone">
                                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
                                </svg>
                                <span id="fileNameDisplay">Add file</span>
                                <asp:FileUpload ID="fileQualification" runat="server" CssClass="file-input" onchange="updateFileName(this)" />
                            </div>
                        </div>

                        <asp:Button ID="btnSubmitRegistration" runat="server" Text="Submit Application" CssClass="btn-submit" OnClick="btnSubmitRegistration_Click" />
                        <button type="button" class="btn-back" onclick="goToStep(1)">Back to Profile Info</button>
                    </div>

                </div>
            </div>
        </div>
    </form>

    <script type="text/javascript">
        // Toggle password visibility
        function toggleSignUpPassword() {
            var pwd = document.getElementById('<%= txtPassword.ClientID %>');
            var confirmPwd = document.getElementById('<%= txtConfirmPassword.ClientID %>');
            
            if (pwd != null && confirmPwd != null) {
                var newType = pwd.type === "password" ? "text" : "password";
                pwd.type = newType;
                confirmPwd.type = newType;
            }
        }

        function validateStep1AndProceed() {
            var name = document.getElementById('<%= txtFullName.ClientID %>').value.trim();
            var email = document.getElementById('<%= txtEmail.ClientID %>').value.trim();
            var pwd = document.getElementById('<%= txtPassword.ClientID %>').value;
            var confirmPwd = document.getElementById('<%= txtConfirmPassword.ClientID %>').value;

            if (!name) {
                alert("Please enter your full name.");
                return;
            }
            if (!email || email.indexOf('@') === -1) {
                alert("Please enter a valid email address.");
                return;
            }
            if (!pwd || pwd.length < 8) {
                alert("Password must be at least 8 characters long.");
                return;
            }
            if (pwd !== confirmPwd) {
                alert("Passwords do not match.");
                return;
            }

            goToStep(2);
        }

        // Navigate between form steps
        function goToStep(stepNumber) {
            document.getElementById('step1').classList.remove('active');
            document.getElementById('step2').classList.remove('active');
            
            var target = document.getElementById('step' + stepNumber);
            if (target) {
                target.classList.add('active');
            }

            var hf = document.getElementById('<%= hfActiveStep.ClientID %>');
            if (hf) {
                hf.value = stepNumber;
            }
        }

        // Restore active step if set by server
        window.addEventListener('DOMContentLoaded', function() {
            var hf = document.getElementById('<%= hfActiveStep.ClientID %>');
            if (hf && hf.value === '2') {
                goToStep(2);
            }
        });

        // Update file name text in drop zone when file selected
        function updateFileName(input) {
            var display = document.getElementById('fileNameDisplay');
            if (input.files && input.files.length > 0) {
                display.innerText = input.files[0].name;
                display.style.color = "#7c3aed";
            } else {
                display.innerText = "Add file";
                display.style.color = "#52525b";
            }
        }
    </script>
</body>
</html>