<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminCourses.aspx.cs" Inherits="Codercept.Admin_Courses" %>
<%@ Register Src="~/AdminSidebar.ascx" TagPrefix="uc" TagName="AdminSidebar" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Course Management - Codercept</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="css/admin-portal.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        .list-header,
        .list-row {
            grid-template-columns: 2.5fr 1fr 1.5fr 0.8fr 1fr 1.2fr;
        }

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

        .col-teacher {
            font-size: 14px;
            color: var(--text-secondary);
        }

        .col-enrolled {
            font-size: 14px;
            font-weight: 600;
            text-align: center;
            color: var(--text-primary);
        }

        .col-rating {
            font-size: 14px;
            color: var(--text-secondary);
            display: flex;
            align-items: center;
            gap: 4px;
        }
        .col-rating i { color: var(--warning-orange); font-size: 12px; }

        .btn-reviews {
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            color: var(--text-secondary);
            padding: 7px 14px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
        }
        .btn-reviews:hover {
            border-color: var(--accent-purple);
            color: #a5b4fc;
            background-color: var(--accent-purple-bg);
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div style="display: flex; height: 100vh; overflow: hidden;">
            <uc:AdminSidebar runat="server" ID="SidebarCtrl" />
            
            <main class="main-content" style="flex: 1; overflow-y: auto;">
                <div class="page-content-wrapper">
                    <div class="page-header">
                        <h1>Course Management</h1>
                        <p>
                            <asp:Literal ID="litCourseSummary" runat="server">Browse active curriculum offerings and inspect user feedback</asp:Literal>
                        </p>
                    </div>

                    <div class="course-table">
                        <div class="list-header">
                            <div>Course</div>
                            <div>Language</div>
                            <div>Teacher</div>
                            <div style="text-align: center;">Enrolled</div>
                            <div>Average Rating</div>
                            <div style="text-align: right;">Action</div>
                        </div>

                        <div id="courseListContainer">
                            <asp:Repeater ID="rptCourses" runat="server">
                                <ItemTemplate>
                                    <div class="list-row">
                                        <div class="course-meta">
                                            <h5><%# Eval("CourseTitle") %></h5>
                                            <p><%# Eval("DifficultyLevel") %> &bull; <%# Eval("CourseDuration") %></p>
                                        </div>
                                        <div>
                                            <span class="badge <%# GetLanguageBadgeClass(Eval("Language").ToString()) %>">
                                                <%# Eval("Language") %>
                                            </span>
                                        </div>
                                        <div class="col-teacher"><%# Eval("TeacherName") %></div>
                                        <div class="col-enrolled"><%# Eval("EnrolledCount") %></div>
                                        <div class="col-rating">
                                            <i class="fa-solid fa-star"></i> <%# Eval("Rating", "{0:0.0}") %> 
                                            <span style="font-size: 12px; color: var(--text-secondary);">(<%# Eval("ReviewCount") %>)</span>
                                        </div>
                                        <div style="text-align: right;">
                                            <a href='AdminCourseReviews.aspx?courseId=<%# Eval("CourseId") %>' class="btn-reviews">
                                                <i class="fa-regular fa-comments"></i> View Reviews
                                            </a>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>

                            <asp:Panel ID="pnlNoCourses" runat="server" Visible="false" CssClass="empty-placeholder">
                                No courses available in database.
                            </asp:Panel>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    </form>
</body>
</html>