<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Certificates.aspx.cs" Inherits="Codercept.Certificates" %>
<%@ Register Src="~/LearnerSideBar.ascx" TagPrefix="uc" TagName="Sidebar" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Certificates - Codercept</title>

    <!-- Import Global Variables & Shared Layout -->
    <link href="css/global.css" rel="stylesheet" type="text/css" />

    <!-- Page-Specific Styles and Local Variables -->
    <style>
        :root {
            /* Local variables for Certificate Cards */
            --cert-card-bg: var(--bg-surface);
            --cert-img-bg: rgba(255, 255, 255, 0.02);
            --cert-img-border: rgba(255, 255, 255, 0.1);
            
            /* Download Button Variables */
            --cert-btn-bg: var(--accent-transparent);
            --cert-btn-text: var(--accent-light);
            --cert-btn-border: rgba(124, 58, 237, 0.3);
            --cert-btn-hover-bg: var(--accent-primary);
            --cert-btn-hover-text: var(--text-primary);
        }

        /* Page Header */
        .page-header { margin-bottom: 2.5rem; }
        .page-header h1 { font-size: 1.75rem; margin-bottom: 0.25rem; color: var(--text-primary); }
        .page-header p { color: var(--text-secondary); font-size: 1rem; }

        /* Certificates Grid */
        .cert-grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); 
            gap: 2rem; 
            padding-bottom: 2rem; 
        }

        /* Individual Certificate Card */
        .cert-card { 
            background: var(--cert-card-bg); 
            border: 1px solid var(--border-light); 
            border-radius: 12px; 
            padding: 1.5rem; 
            display: flex; 
            flex-direction: column; 
            transition: transform 0.2s, border-color 0.2s; 
        }

        .cert-card:hover { 
            transform: translateY(-4px); 
            border-color: rgba(124, 58, 237, 0.4); 
        }

        /* Course Title */
        .cert-title { 
            font-size: 1.15rem; 
            font-weight: 600; 
            color: var(--text-primary); 
            margin-bottom: 1.25rem; 
            text-align: center;
        }

        /* Certificate Image Area (Placeholder) */
        .cert-img-wrapper { 
            background: var(--cert-img-bg); 
            border: 1px dashed var(--cert-img-border); 
            border-radius: 8px; 
            padding: 2rem; 
            margin-bottom: 1.5rem; 
            display: flex; 
            justify-content: center; 
            align-items: center; 
            min-height: 180px; 
        }

        .cert-img-wrapper img { 
            max-height: 60px; 
            opacity: 0.6; 
            filter: grayscale(100%);
            transition: opacity 0.2s, filter 0.2s;
        }

        .cert-card:hover .cert-img-wrapper img {
            opacity: 1;
            filter: grayscale(0%);
        }

        /* Certificate Details */
        .cert-details { 
            text-align: left; 
            font-size: 0.85rem; 
            color: var(--text-secondary); 
            line-height: 1.6; 
            margin-bottom: 1.5rem; 
            flex: 1;
        }
        
        .cert-details strong {
            color: var(--text-primary);
            font-weight: 500;
        }

        /* Download Button */
        .btn-download { 
            display: block; 
            width: 100%; 
            padding: 0.75rem; 
            background: var(--cert-btn-bg); 
            color: var(--cert-btn-text); 
            border: 1px solid var(--cert-btn-border);
            text-decoration: none; 
            border-radius: 8px; 
            font-weight: 600; 
            text-align: center; 
            transition: all 0.2s; 
            cursor: pointer; 
        }

        .btn-download:hover { 
            background: var(--cert-btn-hover-bg); 
            color: var(--cert-btn-hover-text); 
            border-color: var(--cert-btn-hover-bg);
        }

        /* Responsive */
        @media (max-width: 768px) {
            .cert-grid { grid-template-columns: 1fr; }
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
                    <h1>Certificates</h1>
                    <p>View and download your earned credentials</p>
                </div>

                <asp:Label ID="lblNoCerts" runat="server" Visible="false" CssClass="cert-details" style="text-align: center; display: block; margin-top: 2rem;">
                    You haven't earned any certificates yet. Complete a course to see your credentials here!
                </asp:Label>

                <div class="cert-grid">
                    <asp:Repeater ID="rptCertificates" runat="server" OnItemCommand="rptCertificates_ItemCommand">
                        <ItemTemplate>
                            <div class="cert-card">
                                <div class="cert-title"><%# Eval("CourseTitle") %></div>
                
                                <div class="cert-img-wrapper">
                                    <!-- This calls a C# method to generate the stamped image as a Base64 string -->
                                    <img src='<%# GetCertificateImageBase64(Eval("CourseTitle").ToString(), Eval("IssueDate", "{0:MMMM dd, yyyy}")) %>' alt="Certificate Preview" style="max-height: 120px; opacity: 1; filter: none;" />
                                </div>
                
                                <div class="cert-details">
                                    <div>Issued by: <strong><%# Eval("Issuer") %></strong></div>
                                    <div>Issue Date: <strong><%# Eval("IssueDate", "{0:dd MMM yyyy}") %></strong></div>
                                    <div>Credential ID: <strong><%# Eval("CertId") %></strong></div>
                                </div>
                
                                <!-- Passes the CourseName and Date to the backend click event -->
                                <asp:LinkButton ID="btnDownload" runat="server" CssClass="btn-download" 
                                    CommandName="DownloadPDF" 
                                    CommandArgument='<%# Eval("CourseTitle") + "|" + Eval("IssueDate", "{0:MMMM dd, yyyy}") %>'>
                                    Download PDF
                                </asp:LinkButton>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

            </main>
        </div>
    </form>
</body>
</html>