<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminCourseReviews.aspx.cs" Inherits="Codercept.AdminCourseReviews" %>
<%@ Register Src="~/AdminSidebar.ascx" TagPrefix="uc" TagName="AdminSidebar" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Course Reviews & Feedback - Codercept</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="css/admin-portal.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        .breadcrumb-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 24px;
        }

        .btn-back {
            color: var(--text-secondary);
            text-decoration: none;
            font-size: 13px;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: color 0.2s;
        }
        .btn-back:hover { color: var(--text-primary); }

        /* Course Overview Hero Card */
        .course-hero-card {
            background-color: var(--bg-panel);
            border: 1px solid var(--border-color);
            border-radius: 12px;
            padding: 28px;
            margin-bottom: 32px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .hero-info h2 {
            font-size: 20px;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .hero-info p {
            font-size: 14px;
            color: var(--text-secondary);
            max-width: 650px;
            line-height: 1.5;
            margin-bottom: 14px;
        }

        .hero-meta-pills {
            display: flex;
            align-items: center;
            gap: 16px;
            font-size: 13px;
            color: var(--text-secondary);
        }
        .hero-meta-pills span {
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .hero-meta-pills i { color: var(--accent-purple); }

        .hero-rating-box {
            text-align: center;
            padding: 16px 28px;
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: 10px;
            min-width: 140px;
        }
        .hero-rating-score {
            font-size: 32px;
            font-weight: 700;
            color: var(--text-primary);
            line-height: 1;
            margin-bottom: 6px;
        }
        .hero-stars {
            color: var(--warning-orange);
            font-size: 13px;
            margin-bottom: 4px;
        }

        /* Review Comments List */
        .reviews-section-header {
            font-size: 16px;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .reviews-list {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .review-card {
            background-color: var(--bg-panel);
            border: 1px solid var(--border-color);
            border-radius: 10px;
            padding: 20px 24px;
            transition: border-color 0.2s;
        }
        .review-card:hover { border-color: rgba(99, 102, 241, 0.4); }

        .review-header-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;
        }

        .reviewer-meta {
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .reviewer-avatar {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background-color: #21232c;
            color: var(--text-primary);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            font-size: 13px;
        }
        .reviewer-info h5 {
            font-size: 14px;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 2px;
        }
        .reviewer-info p {
            font-size: 12px;
            color: var(--text-secondary);
        }

        .review-comment-body {
            font-size: 14px;
            color: var(--text-secondary);
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div style="display: flex; height: 100vh; overflow: hidden;">
            <uc:AdminSidebar runat="server" ID="SidebarCtrl" />

            <main class="main-content" style="flex: 1; overflow-y: auto;">
                <div class="breadcrumb-row">
                    <a href="AdminCourses.aspx" class="btn-back">
                        <i class="fa-solid fa-arrow-left"></i> Back to Courses
                    </a>
                </div>

                <!-- Course Overview Hero -->
                <div class="course-hero-card">
                    <div class="hero-info">
                        <h2>
                            <asp:Literal ID="litCourseTitle" runat="server">Course Title</asp:Literal>
                            <span class="badge badge-python" id="badgeLanguage" runat="server">Python</span>
                        </h2>
                        <p><asp:Literal ID="litCourseDesc" runat="server">Course description details...</asp:Literal></p>
                        <div class="hero-meta-pills">
                            <span><i class="fa-solid fa-chalkboard-user"></i> <asp:Literal ID="litTeacherName" runat="server">Teacher Name</asp:Literal></span>
                            <span><i class="fa-solid fa-layer-group"></i> <asp:Literal ID="litDifficulty" runat="server">Difficulty</asp:Literal></span>
                            <span><i class="fa-solid fa-clock"></i> <asp:Literal ID="litDuration" runat="server">Duration</asp:Literal></span>
                            <span><i class="fa-solid fa-user-graduate"></i> <asp:Literal ID="litEnrolledCount" runat="server">0</asp:Literal> Enrolled</span>
                        </div>
                    </div>
                    <div class="hero-rating-box">
                        <div class="hero-rating-score"><asp:Literal ID="litAvgScore" runat="server">0.0</asp:Literal></div>
                        <div class="hero-stars"><i class="fa-solid fa-star"></i> <i class="fa-solid fa-star"></i> <i class="fa-solid fa-star"></i> <i class="fa-solid fa-star"></i> <i class="fa-solid fa-star"></i></div>
                        <div style="font-size: 12px; color: var(--text-secondary);"><asp:Literal ID="litTotalReviews" runat="server">0</asp:Literal> reviews</div>
                    </div>
                </div>

                <!-- Reviews Feed -->
                <div class="reviews-section-header">
                    <i class="fa-regular fa-comment-dots"></i> Learner Feedback & Reviews
                </div>

                <div class="reviews-list">
                    <asp:Repeater ID="rptReviews" runat="server">
                        <ItemTemplate>
                            <div class="review-card">
                                <div class="review-header-row">
                                    <div class="reviewer-meta">
                                        <div class="reviewer-avatar"><%# GetInitials(Eval("LearnerName").ToString()) %></div>
                                        <div class="reviewer-info">
                                            <h5><%# Eval("LearnerName") %></h5>
                                            <p><%# Eval("SubmissionDate", "{0:MMM dd, yyyy HH:mm}") %></p>
                                        </div>
                                    </div>
                                    <div class="col-rating">
                                        <i class="fa-solid fa-star"></i> <%# Eval("Rating", "{0:0.0}") %> / 5.0
                                    </div>
                                </div>
                                <div class="review-comment-body">
                                    <%# Eval("CourseFeedBack") %>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>

                    <asp:Panel ID="pnlNoReviews" runat="server" Visible="false" CssClass="empty-placeholder">
                        <i class="fa-regular fa-message" style="font-size: 26px; margin-bottom: 8px; display: block;"></i>
                        No student reviews have been submitted for this course yet.
                    </asp:Panel>
                </div>
            </main>
        </div>
    </form>
</body>
</html>