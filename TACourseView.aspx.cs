using System;
using System.Collections.Generic;
using System.Linq;

namespace Codercept
{
    public partial class TACourseView : System.Web.UI.Page
    {
        // 1. Define Dummy Data Structures
        public class DummyItem
        {
            public string Title { get; set; }
            public string Kind { get; set; }
            public string KindCss { get; set; }
        }

        public class DummyChapter
        {
            public int Number { get; set; }
            public string Title { get; set; }
            public bool IsFocus { get; set; }
            public string CssClass { get; set; }
            public List<DummyItem> Items { get; set; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // Security Check
            if (Session["UserType"] == null || Session["UserType"].ToString() != "TA")
            {
                Response.Redirect("signIn.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadCourse();
            }
        }

        private static DummyItem Lesson(string title) { return new DummyItem { Title = title, Kind = "Lesson", KindCss = "kind-lesson" }; }
        private static DummyItem Quiz(string title) { return new DummyItem { Title = title, Kind = "Quiz", KindCss = "kind-quiz" }; }
        private static DummyItem Assessment(string title) { return new DummyItem { Title = title, Kind = "Assessment", KindCss = "kind-assessment" }; }
        private static DummyItem Exam(string title) { return new DummyItem { Title = title, Kind = "Exam", KindCss = "kind-exam" }; }

        private void LoadCourse()
        {
            int.TryParse(Request.QueryString["id"], out int courseId);
            int.TryParse(Request.QueryString["focus"], out int focusChapter);

            // 2. Generate Dummy Data (course ids match the learner pages' dummy courses)
            string title, description, language, level, teacher, duration;
            List<DummyChapter> chapters;

            switch (courseId)
            {
                case 1:
                    title = "Python for Beginners"; language = "Python"; level = "Beginner"; teacher = "Dr. Lim"; duration = "6 weeks";
                    description = "Learn Python from scratch: variables, control flow, functions and data structures.";
                    chapters = new List<DummyChapter>
                    {
                        new DummyChapter { Number = 1, Title = "Getting Started", Items = new List<DummyItem> { Lesson("Installing Python"), Lesson("Your first program"), Quiz("Variables Quiz") } },
                        new DummyChapter { Number = 2, Title = "Control Flow", Items = new List<DummyItem> { Lesson("Conditions"), Lesson("Loops"), Quiz("Loops Quiz") } },
                        new DummyChapter { Number = 3, Title = "Functions", Items = new List<DummyItem> { Lesson("Defining functions"), Lesson("Parameters and arguments"), Assessment("Functions Assessment") } }
                    };
                    break;
                case 2:
                    title = "Java Fundamentals"; language = "Java"; level = "Beginner"; teacher = "Dr. Lim"; duration = "8 weeks";
                    description = "Understand Java syntax, object basics and program flow.";
                    chapters = new List<DummyChapter>
                    {
                        new DummyChapter { Number = 1, Title = "Java Basics", Items = new List<DummyItem> { Lesson("Types and variables"), Lesson("Operators"), Quiz("Variables Quiz") } },
                        new DummyChapter { Number = 2, Title = "Control Flow", Items = new List<DummyItem> { Lesson("if / else"), Lesson("Loops"), Assessment("Loops Assessment"), Exam("Control Flow Exam") } }
                    };
                    break;
                case 3:
                    title = "C Programming Essentials"; language = "C"; level = "Intermediate"; teacher = "Mr. Rahman"; duration = "6 weeks";
                    description = "Master C: pointers, memory management and more.";
                    chapters = new List<DummyChapter>
                    {
                        new DummyChapter { Number = 1, Title = "C Basics", Items = new List<DummyItem> { Lesson("Compiling C programs"), Lesson("Types and operators"), Quiz("Basics Quiz") } },
                        new DummyChapter { Number = 2, Title = "Pointers", Items = new List<DummyItem> { Lesson("Addresses and pointers"), Lesson("Pointer arithmetic"), Quiz("Pointers Quiz") } }
                    };
                    break;
                case 4:
                    title = "C++ Object-Oriented Programming"; language = "C++"; level = "Intermediate"; teacher = "Mr. Rahman"; duration = "7 weeks";
                    description = "Deep dive into C++ OOP: classes, inheritance, polymorphism and templates.";
                    chapters = new List<DummyChapter>
                    {
                        new DummyChapter { Number = 1, Title = "Classes and Objects", Items = new List<DummyItem> { Lesson("Defining classes"), Lesson("Constructors"), Assessment("Classes Assessment") } },
                        new DummyChapter { Number = 2, Title = "Inheritance", Items = new List<DummyItem> { Lesson("Base and derived classes"), Lesson("Virtual functions"), Quiz("Inheritance Quiz") } }
                    };
                    break;
                case 5:
                    title = "Responsive Web Design"; language = "HTML/CSS"; level = "Beginner"; teacher = "Ms. Tan"; duration = "5 weeks";
                    description = "Build responsive websites with HTML5, CSS3 and Flexbox.";
                    chapters = new List<DummyChapter>
                    {
                        new DummyChapter { Number = 1, Title = "HTML Foundations", Items = new List<DummyItem> { Lesson("Document structure"), Lesson("Semantic elements"), Quiz("HTML Quiz") } },
                        new DummyChapter { Number = 2, Title = "Flexbox Layouts", Items = new List<DummyItem> { Lesson("Flex containers"), Lesson("Flex items"), Quiz("Flexbox Quiz") } }
                    };
                    break;
                default:
                    phCourse.Visible = false;
                    phNotFound.Visible = true;
                    return;
            }

            // 3. Highlight the chapter the TA is currently reviewing
            foreach (var chapter in chapters)
            {
                chapter.IsFocus = chapter.Number == focusChapter;
                chapter.CssClass = chapter.IsFocus ? "focus" : "";
            }

            litTitle.Text = title;
            litDescription.Text = description;
            litLanguage.Text = language;
            litLevel.Text = level;
            litTeacher.Text = teacher;
            litDuration.Text = duration;
            litChapterCount.Text = chapters.Count.ToString();

            rptChapters.DataSource = chapters;
            rptChapters.DataBind();
        }
    }
}
