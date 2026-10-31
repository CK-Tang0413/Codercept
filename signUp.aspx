<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="signUp.aspx.cs" Inherits="Codercept.signUp" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Sign Up - Codercept</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body, html { height: 100%; background-color: #ffffff; }
        .split-layout { display: flex; min-height: 100vh; }
        .left-panel { flex: 1; background: #0f0a19; background-image: radial-gradient(circle at 50% 50%, #2e1065 0%, #0f0a19 60%), linear-gradient(rgba(255, 255, 255, 0.03) 1px, transparent 1px), linear-gradient(90deg, rgba(255, 255, 255, 0.03) 1px, transparent 1px); background-size: 100% 100%, 40px 40px, 40px 40px; color: white; padding: 3rem; display: flex; flex-direction: column; position: relative; overflow: hidden; }
        .brand { display: flex; align-items: center; gap: 0.5rem; font-size: 1.25rem; font-weight: 700; }
        .hero-content { margin-top: auto; margin-bottom: auto; max-width: 80%; position: relative; z-index: 2; }
        .hero-content h1 { font-size: 4rem; line-height: 1.1; margin-bottom: 1.5rem; }
        .hero-content p { color: #a1a1aa; font-size: 1.1rem; line-height: 1.6; margin-bottom: 3rem; max-width: 400px; }
        .text-purple { color: #7c3aed; }
        .snippet { position: absolute; background: rgba(255, 255, 255, 0.05); border: 1px solid rgba(255, 255, 255, 0.1); padding: 0.5rem 1rem; border-radius: 8px; font-family: monospace; font-size: 0.85rem; color: #a1a1aa; backdrop-filter: blur(4px); }
        .snip-1 { top: 20%; left: 10%; color: #4ade80; } .snip-2 { top: 35%; right: 15%; color: #60a5fa; } .snip-3 { bottom: 25%; left: 15%; color: #c084fc; } .snip-4 { bottom: 10%; right: 20%; color: #34d399; }
        .right-panel { flex: 1; display: flex; justify-content: center; align-items: center; padding: 2rem; }
        .form-container { width: 100%; max-width: 420px; }
        .auth-toggle { display: flex; background: #f4f4f5; padding: 0.25rem; border-radius: 8px; margin-bottom: 2rem; }
        .auth-toggle a { flex: 1; text-align: center; padding: 0.6rem; text-decoration: none; color: #71717a; font-weight: 600; font-size: 0.9rem; border-radius: 6px; }
        .auth-toggle a.active { background: white; color: #18181b; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        .form-header h2 { font-size: 2rem; color: #18181b; margin-bottom: 0.5rem; }
        .form-header p { color: #71717a; font-size: 0.95rem; margin-bottom: 2rem; }
        .form-group { margin-bottom: 1.25rem; }
        .form-group label { display: block; margin-bottom: 0.5rem; font-size: 0.875rem; font-weight: 600; color: #27272a; }
        .form-control { width: 100%; padding: 0.75rem 1rem; border: 1px solid #e4e4e7; border-radius: 8px; font-size: 0.95rem; transition: border-color 0.2s; }
        .form-control:focus { outline: none; border-color: #7c3aed; box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1); }
        .error-message { color: #dc2626; font-size: 0.85rem; margin-top: 0.25rem; display: block; }
        .options-row { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; }
        .checkbox-wrapper { display: flex; align-items: center; gap: 0.5rem; }
        .checkbox-wrapper label { font-size: 0.85rem; color: #71717a; cursor: pointer; }
        .btn-submit { width: 100%; padding: 0.875rem; background: #7c3aed; color: white; border: none; border-radius: 8px; font-size: 1rem; font-weight: 600; cursor: pointer; transition: background 0.2s; }
        .btn-submit:hover { background: #6d28d9; }
        .auth-footer { text-align: center; margin-top: 1.5rem; font-size: 0.875rem; color: #71717a; }
        .auth-footer a { color: #7c3aed; text-decoration: none; font-weight: 600; }
        .auth-footer a:hover { text-decoration: underline; }
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
    <form id="form1" runat="server">
        <div class="split-layout">
            <div class="left-panel">
                <div class="brand">
                    <img src="~/img/Codercept_Icon.png" alt="Codercept Logo" runat="server" style="height: 40px; width: auto;" />
                    Codercept
                </div>
                <div class="snippet snip-1">git commit -m "Start learning"</div>
                <div class="snippet snip-2">INSERT INTO Future VALUES (You)</div>
                <div class="snippet snip-3">while(alive) { code(); }</div>
                <div class="snippet snip-4">status: 201 Created</div>
                <div class="hero-content">
                    <h1>Start your<br /> <span class="text-purple">journey.</span></h1>
                    <p>Join our community of developers. Build projects, master new languages, and level up your skills.</p>
                </div>
            </div>

            <div class="right-panel">
                <div class="form-container">
                    <div class="auth-toggle">
                        <a href="signIn.aspx">Sign In</a>
                        <a href="signUp.aspx" class="active">Sign Up</a>
                    </div>
                    <div class="form-header">
                        <h2>Create an account</h2>
                        <p>Join as a Learner and start coding today.</p>
                    </div>

                    <asp:Label ID="lblSystemError" runat="server" CssClass="error-message" style="margin-bottom: 1rem; text-align:center; font-weight: bold;"></asp:Label>

                    <div class="form-group">
                        <label>Full Name</label>
                        <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="John Doe"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName" ErrorMessage="Name is required" Display="Dynamic" CssClass="error-message" />
                    </div>

                    <div class="form-group">
                        <label>Email address</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="you@example.com"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Email is required" Display="Dynamic" CssClass="error-message" />
                    </div>
                    
                    <div class="form-group">
                        <label>Password</label>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="********"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvPassword" runat="server" ControlToValidate="txtPassword" ErrorMessage="Password is required" Display="Dynamic" CssClass="error-message" />
                    </div>

                    <div class="form-group">
                        <label>Confirm Password</label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="********"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvConfirmPassword" runat="server" ControlToValidate="txtConfirmPassword" ErrorMessage="Please confirm your password" Display="Dynamic" CssClass="error-message" />
                        <asp:CompareValidator ID="cvPasswords" runat="server" ControlToValidate="txtConfirmPassword" ControlToCompare="txtPassword" ErrorMessage="Passwords do not match" Display="Dynamic" CssClass="error-message" />
                    </div>

                    <div class="options-row" style="justify-content: flex-start;">
                        <div class="checkbox-wrapper">
                            <input type="checkbox" id="chkShowPasswordSignUp" onclick="toggleSignUpPasswords()" />
                            <label for="chkShowPasswordSignUp">Show Passwords</label>
                        </div>
                    </div>

                    <asp:Button ID="btnSignUp" runat="server" Text="Create Account" CssClass="btn-submit" OnClick="btnSignUp_Click" />
                    
                    <div class="auth-footer">
                        <p>Already have an account? <a href="signIn.aspx">Sign in here</a></p>
                        <p style="margin-top: 0.8rem;">
                            <a href="TeacherRegistration.aspx">Want to teach instead? Register here</a>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script type="text/javascript">
        function toggleSignUpPasswords() {
            var pwd = document.getElementById('<%= txtPassword.ClientID %>');
            var pwdConfirm = document.getElementById('<%= txtConfirmPassword.ClientID %>');
            
            if (pwd != null && pwdConfirm != null) {
                if (pwd.type === "password") {
                    pwd.type = "text";
                    pwdConfirm.type = "text";
                } else {
                    pwd.type = "password";
                    pwdConfirm.type = "password";
                }
            }
        }
    </script>
</body>
</html>