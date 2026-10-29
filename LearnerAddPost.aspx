<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LearnerAddPost.aspx.cs" Inherits="Codercept.LearnerAddPost" %>
<%@ Register Src="~/LearnerSideBar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Create New Post - Codercept</title>

    <!-- 1. Import Global Variables & Shared Layout -->
    <link href="css/global.css" rel="stylesheet" type="text/css" />

    <!-- 2. Page-Specific Styles -->
    <style>
        /* Header & Navigation */
        .page-header { 
            display: flex; 
            align-items: center; 
            gap: 1rem; 
            margin-bottom: 2rem; 
        }
        
        .btn-back { 
            color: var(--text-secondary); 
            text-decoration: none; 
            display: flex; 
            align-items: center; 
            justify-content: center;
            width: 40px; 
            height: 40px; 
            border-radius: 50%;
            background: rgba(255, 255, 255, 0.02);
            border: 1px solid var(--border-light);
            transition: all 0.2s; 
        }
        
        .btn-back:hover { 
            color: var(--text-primary); 
            background: rgba(255, 255, 255, 0.05);
            border-color: var(--text-secondary);
        }

        .header-text h1 { font-size: 1.75rem; color: var(--text-primary); margin-bottom: 0.25rem; }
        .header-text p { color: var(--text-secondary); font-size: 0.95rem; }

        /* Form Container */
        .post-form-container { 
            background: var(--bg-surface); 
            border: 1px solid var(--border-light); 
            border-radius: 12px; 
            padding: 2.5rem; 
            max-width: 800px; 
        }
        
        .form-group { margin-bottom: 1.5rem; }
        .form-group label { 
            display: block; 
            margin-bottom: 0.5rem; 
            font-size: 0.9rem; 
            font-weight: 600; 
            color: var(--text-primary); 
        }
        
        .form-control { 
            width: 100%; 
            background: var(--bg-main); 
            border: 1px solid var(--border-light); 
            padding: 0.875rem 1rem; 
            border-radius: 8px; 
            color: var(--text-primary); 
            font-size: 0.95rem; 
            outline: none; 
            transition: border-color 0.2s; 
        }
        
        .form-control:focus { border-color: var(--accent-primary); }
        .form-control::placeholder { color: var(--text-muted); }
        
        /* Multi-line specific */
        textarea.form-control { 
            resize: vertical; 
            min-height: 200px; 
            line-height: 1.5;
        }
        
        /* Form Actions */
        .form-actions { 
            display: flex; 
            gap: 1rem; 
            margin-top: 2.5rem; 
            justify-content: flex-end; 
            padding-top: 1.5rem;
            border-top: 1px solid var(--border-light);
        }
        
        .btn-cancel { 
            padding: 0.75rem 1.5rem; 
            background: transparent; 
            color: var(--text-secondary); 
            border: 1px solid var(--border-light); 
            border-radius: 8px; 
            font-weight: 600; 
            text-decoration: none; 
            transition: all 0.2s; 
            cursor: pointer; 
        }
        
        .btn-cancel:hover { 
            background: rgba(255, 255, 255, 0.05); 
            color: var(--text-primary); 
        }
        
        .btn-submit { 
            padding: 0.75rem 2rem; 
            background: var(--accent-primary); 
            color: white; 
            border: none; 
            border-radius: 8px; 
            font-weight: 600; 
            cursor: pointer; 
            transition: background 0.2s; 
        }
        
        .btn-submit:hover { background: var(--accent-hover); }
        
        /* Helper text for tags */
        .helper-text {
            display: block;
            margin-top: 0.4rem;
            font-size: 0.8rem;
            color: var(--text-muted);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="dashboard-layout">
            
            <!-- Sidebar Injected Here -->
            <uc:Sidebar runat="server" ID="LearnerSideBarCtrl" />

            <!-- Main Content -->
            <main class="main-content">
                
                <div class="page-header">
                    <a href="LearnerForum.aspx" class="btn-back" title="Back to Forum">
                        <!-- Left Arrow SVG -->
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18" />
                        </svg>
                    </a>
                    <div class="header-text">
                        <h1>Create New Post</h1>
                        <p>Ask a question or share your knowledge with the community</p>
                    </div>
                </div>

                <div class="post-form-container">
    
                    <div class="form-group">
                        <label>Title</label>
                        <asp:TextBox ID="txtPostTitle" runat="server" CssClass="form-control" placeholder="e.g., What is String in Python?"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvTitle" runat="server" ControlToValidate="txtPostTitle" 
                            ErrorMessage="Title is required." Display="Dynamic" 
                            style="color: #f87171; font-size: 0.8rem; margin-top: 0.25rem; display: block;" />
                    </div>

                    <div class="form-group">
                        <label>Description</label>
                        <asp:TextBox ID="txtPostDesc" runat="server" CssClass="form-control" TextMode="MultiLine" placeholder="Provide details, code snippets, or background context..."></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvDesc" runat="server" ControlToValidate="txtPostDesc" 
                            ErrorMessage="Description is required." Display="Dynamic" 
                            style="color: #f87171; font-size: 0.8rem; margin-top: 0.25rem; display: block;" />
                    </div>

                    <div class="form-group">
                        <label>Tags</label>
                        <asp:TextBox ID="txtPostTags" runat="server" CssClass="form-control" placeholder="e.g., Python, Fundamental, Urgent"></asp:TextBox>
                        <asp:RequiredFieldValidator ID="rfvTags" runat="server" ControlToValidate="txtPostTags" 
                            ErrorMessage="At least one tag is required." Display="Dynamic" 
                            style="color: #f87171; font-size: 0.8rem; margin-top: 0.25rem; display: block;" />
                        <span class="helper-text">Separate tags with commas.</span>
                    </div>

                    <div class="form-actions">
                        <a href="LearnerForum.aspx" class="btn-cancel">Cancel</a>
                        <asp:Button ID="btnPublishPost" runat="server" Text="Publish Post" CssClass="btn-submit" OnClick="btnPublishPost_Click" />                    
                    </div>

                </div>

            </main>
        </div>
    </form>
</body>
</html>