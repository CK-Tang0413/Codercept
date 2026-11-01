<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VerifyOTP.aspx.cs" Inherits="Codercept.VerifyOTP" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Verify OTP - Codercept</title>
    <link href="css/global.css" rel="stylesheet" type="text/css" />
    <style>
        /* Add your specific auth-page styling here to match ForgotPassword.aspx */
        .auth-container { max-width: 400px; margin: 5rem auto; padding: 2rem; background: var(--bg-surface); border-radius: 12px; text-align: center; }
        .form-group { margin-bottom: 1.5rem; text-align: left; }
        .form-control { width: 100%; padding: 0.75rem; border-radius: 8px; border: 1px solid var(--border-light); background: transparent; color: var(--text-primary); }
        .btn-submit { width: 100%; padding: 0.75rem; background: var(--accent-primary); color: #fff; border: none; border-radius: 8px; cursor: pointer; font-weight: bold; }
        .error-msg { color: #ef4444; font-size: 0.875rem; display: block; margin-top: 0.5rem; }
        @media (max-width: 440px) {
            .auth-container { margin: 2rem 1rem; padding: 1.5rem; }
            h2 { font-size: 1.5rem; }
            p { font-size: 0.9rem; }
            .form-control { padding: 0.65rem 0.85rem; font-size: 0.9rem; }
            .btn-submit { padding: 0.75rem; font-size: 0.95rem; }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="auth-container">
            <h2>Verify Your Email</h2>
            <p style="color: var(--text-secondary); margin-bottom: 2rem; line-height: 1.5;">
                We've sent a 6-digit code to your email. It will expire in <strong>5 minutes</strong>.<br /><br />
                <span style="font-size: 0.85rem; color: var(--accent-light);">
                    <em>Tip: Keep this window open while you check your inbox.</em>
                </span>
            </p>

            <div class="form-group">
                <label style="color: var(--text-secondary); display: block; margin-bottom: 0.5rem;">One-Time Password (OTP)</label>
                <asp:TextBox ID="txtOTP" runat="server" CssClass="form-control" MaxLength="6" placeholder="123456"></asp:TextBox>
                <asp:Label ID="lblError" runat="server" CssClass="error-msg"></asp:Label>
            </div>

            <asp:Button ID="btnVerify" runat="server" Text="Verify OTP" CssClass="btn-submit" OnClick="btnVerify_Click" />
            
            <div style="margin-top: 1.5rem;">
                <a href="ForgotPassword.aspx" style="color: var(--accent-light); text-decoration: none; font-size: 0.875rem;">Resend Code / Go Back</a>
            </div>
        </div>
    </form>
</body>
</html>