<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminCourses.aspx.cs" Inherits="Codercept.Admin_Courses" %>
<%@ Register Src="~/AdminSidebar.ascx" TagPrefix="uc" TagName="AdminSidebar" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Course Management</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="css/admin-portal.css" rel="stylesheet" type="text/css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
        <style>
        /* Course Table Grid Columns */
        .list-header,
        .list-row {
            grid-template-columns: 2.5fr 1fr 1.5fr 0.8fr 0.8fr 1fr 1fr;
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
            font-weight: 500;
            text-align: center;
        }

        .col-rating {
            font-size: 14px;
            color: var(--text-secondary);
            display: flex;
            align-items: center;
            gap: 4px;
        }
        .col-rating i { color: var(--warning-orange); font-size: 12px; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />

        <div style="display: flex; height: 100vh; overflow: hidden;">
            <!-- Inject Sidebar -->
            <uc:AdminSidebar runat="server" ID="SidebarCtrl" />
            
            <!-- Main Content -->
            <main class="main-content" style="flex: 1; overflow-y: auto;">
                <div class="page-content-wrapper">
                    
                    <asp:UpdatePanel ID="upnlCourses" runat="server">
                        <ContentTemplate>
                            
                            <div class="page-header">
                                <h1>Course Management</h1>
                                <p>
                                    <asp:Literal ID="litCourseSummary" runat="server">Loading courses...</asp:Literal>
                                </p>
                            </div>

                            <!-- Course Table -->
                            <div class="course-table">
                                <div class="list-header">
                                    <div>Course</div>
                                    <div>Language</div>
                                    <div>Teacher</div>
                                    <div style="text-align: center;">Enrolled</div>
                                    <div>Rating</div>
                                    <div>Status</div>
                                    <div style="text-align: left;">Actions</div>
                                </div>

                                <div id="courseListContainer">
                                    <asp:Repeater ID="rptCourses" runat="server" OnItemCommand="rptCourses_ItemCommand">
                                        <ItemTemplate>
                                            <div class="list-row">
                                                <div class="course-meta">
                                                    <h5><%# Eval("CourseTitle") %></h5>
                                                    <p><%# Eval("DifficultyLevel") %></p>
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
                                                </div>
                                                <div>
                                                    <span class="badge-status <%# Eval("Status").ToString() == "Published" ? "status-published" : "status-draft" %>">
                                                        <%# Eval("Status") %>
                                                    </span>
                                                </div>
                                                <div class="col-actions">
                                                    <asp:LinkButton ID="btnTogglePublish" runat="server" 
                                                        CommandName="TogglePublish" 
                                                        CommandArgument='<%# Eval("CourseId") + "|" + Eval("Status") %>'
                                                        CssClass='<%# Eval("Status").ToString() == "Published" ? "btn-action" : "btn-action btn-publish-state" %>'>
                                                        <i class='<%# Eval("Status").ToString() == "Published" ? "fa-regular fa-circle-pause" : "fa-regular fa-circle-play" %>'></i>
                                                        <%# Eval("Status").ToString() == "Published" ? "Unpublish" : "Publish" %>
                                                    </asp:LinkButton>
                                                </div>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>

                                    <asp:Panel ID="pnlNoCourses" runat="server" Visible="false" CssClass="empty-placeholder">
                                        No courses found in database.
                                    </asp:Panel>
                                </div>
                            </div>

                        </ContentTemplate>
                    </asp:UpdatePanel>

                </div>
            </main>
        </div>
    </form>
</body>
</html>