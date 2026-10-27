using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace Codercept
{
    public partial class TAProfile : System.Web.UI.Page
    {
        public class QualificationItem
        {
            public string Name { get; set; }
            public string Date { get; set; }
            public string DocumentUrl { get; set; }
            public bool HasDocument { get { return !string.IsNullOrEmpty(DocumentUrl); } }
        }

        private static readonly string[] TeachingLevels = new[] { "Beginner", "Intermediate", "Advanced" };
        private readonly string connString = TAHelpers.ConnectionString;

        protected string Email;
        protected string MemberSince;

        private int TaId
        {
            get { return Convert.ToInt32(Session["UserId"]); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null)
            {
                Response.Redirect("signIn.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadProfileData();

                if (Request.QueryString["saved"] == "1")
                {
                    Master.ShowToast("Personal details updated");
                }
            }
            else
            {
                // Ensure Email and MemberSince are populated on postback
                LoadHeaderFieldsOnly();
            }
        }

        private void LoadHeaderFieldsOnly()
        {
            using (SqlConnection con = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand("SELECT Email, DateJoined FROM [dbo].[Teaching_Assistant] WHERE TA_Id = @TA_Id", con))
            {
                cmd.Parameters.AddWithValue("@TA_Id", TaId);
                con.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        Email = reader["Email"].ToString();
                        DateTime dateJoined = reader["DateJoined"] != DBNull.Value ? Convert.ToDateTime(reader["DateJoined"]) : DateTime.Now;
                        MemberSince = dateJoined.ToString("MMMM d, yyyy", System.Globalization.CultureInfo.InvariantCulture);
                    }
                }
            }
        }

        private void LoadProfileData()
        {
            using (SqlConnection con = new SqlConnection(connString))
            {
                con.Open();

                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT Name, Email, Age, Region, TeachingLevel, AccStatus, DateJoined, QualificationName, QualificationDocument
                    FROM [dbo].[Teaching_Assistant]
                    WHERE TA_Id = @TA_Id", con))
                {
                    cmd.Parameters.AddWithValue("@TA_Id", TaId);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            Session.Clear();
                            Response.Redirect("signIn.aspx");
                            return;
                        }

                        Email = reader["Email"].ToString();
                        DateTime dateJoined = reader["DateJoined"] != DBNull.Value ? Convert.ToDateTime(reader["DateJoined"]) : DateTime.Now;
                        MemberSince = dateJoined.ToString("MMMM d, yyyy", System.Globalization.CultureInfo.InvariantCulture);

                        txtName.Text = reader["Name"].ToString();
                        txtAge.Text = reader["Age"] != DBNull.Value ? reader["Age"].ToString() : "";
                        txtRegion.Text = reader["Region"] != DBNull.Value ? reader["Region"].ToString() : "";

                        string level = reader["TeachingLevel"] != DBNull.Value ? reader["TeachingLevel"].ToString() : "";
                        ListItem item = ddlTeachingLevel.Items.FindByValue(level);
                        if (item != null)
                        {
                            ddlTeachingLevel.SelectedValue = level;
                        }
                        else
                        {
                            ddlTeachingLevel.Items.Insert(0, new ListItem("Select a level", ""));
                            ddlTeachingLevel.SelectedValue = "";
                        }

                        // Qualifications
                        string qualName = reader["QualificationName"] != DBNull.Value ? reader["QualificationName"].ToString() : "";
                        string qualDoc = reader["QualificationDocument"] != DBNull.Value ? reader["QualificationDocument"].ToString() : "";

                        var qualifications = new List<QualificationItem>();
                        if (!string.IsNullOrWhiteSpace(qualName))
                        {
                            qualifications.Add(new QualificationItem
                            {
                                Name = qualName,
                                Date = dateJoined.ToString("MMMM d, yyyy", System.Globalization.CultureInfo.InvariantCulture),
                                DocumentUrl = SafeDocumentUrl(qualDoc)
                            });
                        }

                        phQualEmpty.Visible = qualifications.Count == 0;
                        rptQualifications.DataSource = qualifications;
                        rptQualifications.DataBind();
                    }
                }
            }
        }

        private string SafeDocumentUrl(string stored)
        {
            if (string.IsNullOrWhiteSpace(stored)) return "";
            stored = stored.Trim();
            if (stored.StartsWith("~/")) return ResolveUrl(stored);
            if (stored.StartsWith("/") && !stored.StartsWith("//")) return stored;
            return "";
        }

        protected void btnUpdateProfile_Click(object sender, EventArgs e)
        {
            string name = txtName.Text.Trim();
            int age = 0;
            string ageText = txtAge.Text.Trim();
            string region = txtRegion.Text.Trim();
            string level = ddlTeachingLevel.SelectedValue;

            bool nameError = name.Length < 2 || name.Length > 50 || name.IndexOfAny(new[] { '<', '>' }) >= 0;
            bool ageError = !string.IsNullOrEmpty(ageText) && (!int.TryParse(ageText, out age) || age < 18 || age > 100);
            bool regionError = region.Length > 50;
            bool levelError = !string.IsNullOrEmpty(level) && !TeachingLevels.Contains(level);

            MarkError(fldName, hintName, nameError, "Enter a name of 2 to 50 characters, without < or >.");
            MarkError(fldAge, hintAge, ageError, "Enter an age as a whole number from 18 to 100.");
            MarkError(fldAddress, hintAddress, regionError, "The address/region can be at most 50 characters.");
            MarkError(fldTeachingLevel, hintTeachingLevel, levelError, "Choose your teaching level.");

            if (nameError || ageError || regionError || levelError) return;

            try
            {
                using (SqlConnection con = new SqlConnection(connString))
                using (SqlCommand cmd = new SqlCommand(@"
                    UPDATE [dbo].[Teaching_Assistant]
                    SET Name = @Name,
                        Age = @Age,
                        Region = @Region,
                        TeachingLevel = @Level
                    WHERE TA_Id = @TA_Id", con))
                {
                    cmd.Parameters.AddWithValue("@Name", name);
                    cmd.Parameters.AddWithValue("@Age", age > 0 ? (object)age : DBNull.Value);
                    cmd.Parameters.AddWithValue("@Region", region.Length > 0 ? (object)region : DBNull.Value);
                    cmd.Parameters.AddWithValue("@Level", string.IsNullOrEmpty(level) ? (object)DBNull.Value : level);
                    cmd.Parameters.AddWithValue("@TA_Id", TaId);

                    con.Open();
                    cmd.ExecuteNonQuery();
                }

                Session["UserName"] = name;
                Response.Redirect("TAProfile.aspx?saved=1");
            }
            catch (SqlException)
            {
                Master.ShowToast("Could not update your details. Please try again.");
            }
        }

        private static void MarkError(HtmlGenericControl field, HtmlGenericControl hint, bool error, string message)
        {
            string css = (field.Attributes["class"] ?? "").Replace(" has-error", "");
            field.Attributes["class"] = error ? css + " has-error" : css;
            hint.InnerText = error ? message : "";
        }
    }
}
