using System;
using System.Web;

namespace Codercept
{
    public partial class TeacherQuestionCard : System.Web.UI.UserControl
    {
        private TeacherQuestion question;

        /// <summary>exam | quiz | assessment</summary>
        public string Mode { get; set; }

        public int Number { get; set; }

        public TeacherQuestion Question
        {
            get { if (question == null) question = TeacherQuestion.Blank(); return question; }
            set { question = value; }
        }

        protected bool IsExam { get { return Mode == "exam"; } }

        protected string HeaderLabel
        {
            get
            {
                if (Mode == "exam") return "EXAM QUESTION";
                if (Mode == "assessment") return "ASSESSMENT QUESTION";
                return "QUIZ QUESTION";
            }
        }

        /// <summary>
        /// One answer row. Also used for the "Add answer" template, so keep the markup in one place.
        /// The correct state is shown by the label/button pair; TeacherPortal.js keeps them in sync.
        /// </summary>
        protected string AnswerRow(int index, string text, bool correct)
        {
            return "<div class=\"answer-row" + (correct ? " is-correct" : "") + "\" data-tp-answer>"
                + "<span class=\"drag-handle\">" + TeacherIcons.Svg("grip", 16) + "</span>"
                + "<span class=\"answer-letter\">" + (char)('A' + index) + "</span>"
                + "<input type=\"text\" data-tp-f=\"answer\" aria-label=\"Answer " + (index + 1) + "\" placeholder=\"Type here\" value=\"" + HttpUtility.HtmlAttributeEncode(text) + "\" />"
                + "<span class=\"correct-label\"" + (correct ? "" : " hidden") + ">" + TeacherIcons.Svg("check", 13) + "Correct answer</span>"
                + "<button type=\"button\" class=\"set-correct-link\" data-tp-answer-correct" + (correct ? " hidden" : "") + ">Set as correct answer</button>"
                + "<button type=\"button\" class=\"remove-answer\" aria-label=\"Remove answer " + (index + 1) + "\" data-tp-answer-remove>" + TeacherIcons.Svg("x", 15) + "</button>"
                + "</div>";
        }
    }
}
