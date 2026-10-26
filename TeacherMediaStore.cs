using System;
using System.IO;
using System.Linq;
using System.Web;

namespace Codercept
{
    /// <summary>
    /// Stores the files teachers upload for their courses under ~/media/uploads/&lt;courseId&gt;/ and removes them again.
    /// Only images, PDF and MP4 up to 25 MB are accepted. A file is checked by its extension AND by the first bytes of its
    /// content, then saved under a random name, so a teacher's file name never decides where or as what it is stored.
    /// The database keeps only the relative path (for example "media/uploads/5/3f2a....pdf").
    /// </summary>
    public static class TeacherMediaStore
    {
        public const int MaxBytes = 25 * 1024 * 1024;

        private const string Root = "media/uploads/";

        private static readonly string[] Extensions = { ".jpg", ".jpeg", ".png", ".gif", ".webp", ".pdf", ".mp4" };

        /// <summary>
        /// Saves an uploaded file for a course and returns its relative path, or null (with error set) when the file is not allowed.
        /// The caller has already checked that the course belongs to the signed-in teacher.
        /// </summary>
        public static string Save(HttpPostedFile file, int courseId, out string error)
        {
            error = null;
            if (file == null || file.ContentLength == 0)
            {
                error = "The chosen file is empty.";
                return null;
            }
            if (file.ContentLength > MaxBytes)
            {
                error = "The file is larger than 25 MB.";
                return null;
            }

            string extension = Path.GetExtension(file.FileName ?? "").ToLowerInvariant();
            if (!Extensions.Contains(extension))
            {
                error = "Only images (JPG, PNG, GIF, WebP), MP4 video and PDF files can be uploaded.";
                return null;
            }
            if (!LooksLike(extension, file))
            {
                error = "The file's content does not match its type (" + extension + ").";
                return null;
            }

            string relative = Root + courseId + "/" + Guid.NewGuid().ToString("N") + extension;
            string physical = HttpContext.Current.Server.MapPath("~/" + relative);
            Directory.CreateDirectory(Path.GetDirectoryName(physical));
            file.SaveAs(physical);
            return relative;
        }

        /// <summary>Deletes a stored file. Anything outside media/uploads is ignored, and a missing or locked file is not an error.</summary>
        public static void Delete(string relativePath)
        {
            if (string.IsNullOrEmpty(relativePath) || !relativePath.StartsWith(Root, StringComparison.Ordinal)
                || relativePath.Contains("..") || relativePath.Contains("\\")) return;
            try
            {
                string root = Path.GetFullPath(HttpContext.Current.Server.MapPath("~/" + Root));
                string physical = Path.GetFullPath(HttpContext.Current.Server.MapPath("~/" + relativePath));
                if (physical.StartsWith(root, StringComparison.OrdinalIgnoreCase) && File.Exists(physical)) File.Delete(physical);
            }
            catch (IOException) { }
            catch (UnauthorizedAccessException) { }
        }

        /// <summary>Compares the first bytes of the upload with what a file of that extension starts with.</summary>
        private static bool LooksLike(string extension, HttpPostedFile file)
        {
            byte[] head = new byte[12];
            int read = file.InputStream.Read(head, 0, head.Length);
            file.InputStream.Position = 0;
            if (read < 12) return false;

            switch (extension)
            {
                case ".jpg":
                case ".jpeg": return head[0] == 0xFF && head[1] == 0xD8 && head[2] == 0xFF;
                case ".png": return head[0] == 0x89 && head[1] == 0x50 && head[2] == 0x4E && head[3] == 0x47;
                case ".gif": return head[0] == 0x47 && head[1] == 0x49 && head[2] == 0x46 && head[3] == 0x38;
                case ".webp": return Ascii(head, 0, "RIFF") && Ascii(head, 8, "WEBP");
                case ".pdf": return Ascii(head, 0, "%PDF");
                case ".mp4": return Ascii(head, 4, "ftyp");
                default: return false;
            }
        }

        private static bool Ascii(byte[] bytes, int offset, string text)
        {
            for (int i = 0; i < text.Length; i++)
            {
                if (bytes[offset + i] != (byte)text[i]) return false;
            }
            return true;
        }
    }
}
