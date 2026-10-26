using System;
using System.Collections.Generic;
using System.Web.Script.Serialization;

namespace Codercept
{
    public partial class TeacherDomainInput : System.Web.UI.UserControl
    {
        private List<string> suggestions;

        /// <summary>Existing domains offered in the dropdown (Subject WHERE SubjectType = 'Domain').</summary>
        protected List<string> Suggestions
        {
            get
            {
                if (suggestions == null) suggestions = TeacherCourseData.GetDomainNames();
                return suggestions;
            }
        }

        /// <summary>The domain names in the box. The list travels in a hidden field as a JSON array.</summary>
        public List<string> Domains
        {
            get
            {
                try
                {
                    return new JavaScriptSerializer().Deserialize<List<string>>(hfTeacherDomains.Value) ?? new List<string>();
                }
                catch (ArgumentException)
                {
                    return new List<string>();
                }
            }
            set { hfTeacherDomains.Value = new JavaScriptSerializer().Serialize(value ?? new List<string>()); }
        }

        public void ShowError(string message)
        {
            fldTeacherDomains.Attributes["class"] = "tp-inline-field has-error";
            hintTeacherDomains.InnerText = message;
        }

        public void ClearError()
        {
            fldTeacherDomains.Attributes["class"] = "tp-inline-field";
            hintTeacherDomains.InnerText = "";
        }
    }
}
