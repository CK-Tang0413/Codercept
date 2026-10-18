<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="Codercept.ForgotPassword" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Forgot Password - Codercept</title>
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
        .form-header h2 { font-size: 2rem; color: #18181b; margin-bottom: 0.5rem; }
        .form-header p { color: #71717a; font-size: 0.95rem; margin-bottom: 2rem; line-height: 1.5; }
        .form-group { margin-bottom: 1.5rem; }
        .form-group label { display: block; margin-bottom: 0.5rem; font-size: 0.875rem; font-weight: 600; color: #27272a; }
        .form-control { width: 100%; padding: 0.75rem 1rem; border: 1px solid #e4e4e7; border-radius: 8px; font-size: 0.95rem; transition: border-color 0.2s; }
        .form-control:focus { outline: none; border-color: #7c3aed; box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.1); }
        .error-message { color: #dc2626; font-size: 0.85rem; margin-top: 0.25rem; display: block; }
        .btn-submit { width: 100%; padding: 0.875rem; background: #7c3aed; color: white; border: none; border-radius: 8px; font-size: 1rem; font-weight: 600; cursor: pointer; transition: background 0.2s; margin-bottom: 1rem; }
        .btn-submit:hover { background: #6d28d9; }
        .auth-footer { text-align: center; margin-top: 1.5rem; font-size: 0.875rem; color: #71717a; }
        .auth-footer a { color: #7c3aed; text-decoration: none; font-weight: 600; }
        .auth-footer a:hover { text-decoration: underline; }
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
                <div class="snippet snip-1">SELECT * FROM Users WHERE Email = ?</div>
                <div class="snippet snip-2">Exception: PasswordNotFound</div>
                <div class="snippet snip-3">UPDATE Auth SET Token = 'new'</div>
                <div class="snippet snip-4">Response.Redirect("/reset")</div>
                <div class="hero-content">
                    <h1>Lost your<br /> <span class="text-purple">access?</span></h1>
                    <p>Don't worry, even the best developers drop a semicolon or forget a password sometimes. Let's get you back in.</p>
                </div>
            </div>

            <div class="right-panel">
                <div class="form-container">
                    <div class="form-header">
                        <h2>Reset Password</h2>
                        <p>Enter the email address associated with your Codercept account. We will verify your account to continue.</p>
                    </div>

                    <div class="form-group">
                        <label>Email address</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="you@example.com"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="Email is required" Display="Dynamic" CssClass="error-message" />
                        <asp:Label ID="lblEmailError" runat="server" CssClass="error-message"></asp:Label>
                    </div>

                    <asp:Button ID="btnVerifyEmail" runat="server" Text="Verify Email" CssClass="btn-submit" OnClick="btnVerifyEmail_Click" />
                    
                    <div class="auth-footer">
                        <p>Remember your password? <a href="signIn.aspx">Back to Sign In</a></p>
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>