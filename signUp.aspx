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
        .form-header p { color: #71717a; font-size: 0.95rem; margin-bottom: 2rem; } /* Increased margin-bottom since badges are gone */
        .form-group { margin-bottom: 1.25rem; }
        .form-group label { display: block; margin-bottom: 0.5rem; font-size: 0.875rem; font-weight: 600; color: #27272a; }
        .form-control { width: 100%; padding: 0.75rem 1rem; border: 1px solid #e4e4e7; border-radius: 8px; font-size: 0.95rem; transition: border-color 0.2s; }
        .form-control:focus { outline: none; border-color: #7c3aed; box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1); }
        .checkbox-wrapper { display: flex; align-items: center; gap: 0.5rem; margin-bottom: 1.5rem; }
        .checkbox-wrapper label { font-size: 0.85rem; color: #71717a; cursor: pointer;}
        .btn-submit { width: 100%; padding: 0.875rem; background: #c084fc; color: white; border: none; border-radius: 8px; font-size: 1rem; font-weight: 600; cursor: pointer; transition: background 0.2s; }
        .btn-submit:hover { background: #a855f7; }
        @media (max-width: 768px) { .split-layout { flex-direction: column; } .left-panel { padding: 2rem; } .hero-content h1 { font-size: 2.5rem; } .snippet { display: none; } }
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
                <div class="snippet snip-1">py print("Hello, World!")</div>
                <div class="snippet snip-2">js console.log("Codercept")</div>
                <div class="snippet snip-3">ts const learn = () => grow()</div>
                <div class="snippet snip-4">css color: #7c5aed;</div>
                <div class="hero-content">
                    <h1>Start your<br /><span class="text-purple">coding</span><br />journey.</h1>
                    <p>Learn programming from scratch — no prior experience needed. Your fundamentals start here.</p>
                </div>
            </div>

            <div class="right-panel">
                <div class="form-container">
                    <div class="auth-toggle">
                        <a href="signIn.aspx">Sign In</a>
                        <a href="signUp.aspx" class="active">Sign Up</a>
                    </div>
                    <div class="form-header">
                        <h2>Join Codercept</h2>
                        <p>Create a free account and start learning today.</p>
                    </div>

                    <div class="form-group">
                        <label>Full name</label>
                        <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="Alex Tran"></asp:TextBox>
                    </div>
                    <div class="form-group">
                        <label>Email address</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="you@example.com"></asp:TextBox>
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

                    <asp:Button ID="btnSignUp" runat="server" Text="Create my free account" CssClass="btn-submit" OnClick="btnSignUp_Click" />
                </div>
            </div>
        </div>
    </form>

    <script type="text/javascript">
        function toggleSignUpPassword() {
            var pwd = document.getElementById('<%= txtPassword.ClientID %>');
            var confirmPwd = document.getElementById('<%= txtConfirmPassword.ClientID %>');
            
            if (pwd != null && confirmPwd != null) {
                if (pwd.type === "password") {
                    pwd.type = "text";
                    confirmPwd.type = "text";
                } else {
                    pwd.type = "password";
                    confirmPwd.type = "password";
                }
            }
        }
    </script>
</body>
</html>