using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

#if NETFX_CORE
    using Windows.Security.Cryptography;
    using Windows.Security.Cryptography.Core;
    using Windows.Storage.Streams;
#else
    using Cryptography = System.Security.Cryptography;
    using FileStream = System.IO.FileStream;
#endif

namespace BestHTTP.Extensions
{
    public static class Extensions
    {
        #region ASCII Encoding (These are required because Windows Phone doesn't supports the Encoding.ASCII class.)

        /// <summary>
        /// On WP8 platform there are no ASCII encoding.
        /// </summary>
        public static string AsciiToString(this byte[] bytes)
        {
            StringBuilder sb = new StringBuilder(bytes.Length);
            foreach (byte b in bytes)
                sb.Append(b <= 0x7f ? (char)b : '?');
            return sb.ToString();
        }

        public static void SendAsASCII(this BinaryWriter stream, string str)
        {
            for (int i = 0; i < str.Length; ++i)
            {
                char ch = str[i];

                stream.Write((byte)((ch < (char)0x80) ? ch : '?'));
            }
        }

        #endregion
        
        #region Other Extensions

        public static string GetRequestPathAndQueryURL(this Uri uri)
        {
            string requestPathAndQuery = uri.GetComponents(UriComponents.PathAndQuery, UriFormat.UriEscaped);

            // http://forum.unity3d.com/threads/best-http-released.200006/page-26#post-2723250
            if (string.IsNullOrEmpty(requestPathAndQuery))
                requestPathAndQuery = "/";

            return requestPathAndQuery;
        }

        public static string[] FindOption(this string str, string option)
        {
            //s-maxage=2678400, must-revalidate, max-age=0
            string[] options = str.ToLower().Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            option = option.ToLower();

            for (int i = 0; i < options.Length; ++i)
                if (options[i].Contains(option))
                    return options[i].Split(new char[] { '=' }, StringSplitOptions.RemoveEmptyEntries);

            return null;
        }

        public static void WriteArray(this Stream stream, byte[] array)
        {
            stream.Write(array, 0, array.Length);
        }

        /// <summary>
        /// Returns true if the Uri's host is a valid IPv4 or IPv6 address.
        /// </summary>
        public static bool IsHostIsAnIPAddress(this Uri uri)
        {
            if (uri == null)
                return false;

            return IsIpV4AddressValid(uri.Host) || IsIpV6AddressValid(uri.Host);
        }

        // Original idea from: https://www.code4copy.com/csharp/c-validate-ip-address-string/
        // Working regex: https://www.regular-expressions.info/ip.html
        private static readonly System.Text.RegularExpressions.Regex validIpV4AddressRegex = new System.Text.RegularExpressions.Regex("\\b(?:\\d{1,3}\\.){3}\\d{1,3}\\b", System.Text.RegularExpressions.RegexOptions.IgnoreCase);

        /// <summary>
        /// Validates an IPv4 address.
        /// </summary>
        public static bool IsIpV4AddressValid(string address)
        {
            if (!string.IsNullOrEmpty(address))
                return validIpV4AddressRegex.IsMatch(address.Trim());

            return false;
        }

        /// <summary>
        /// Validates an IPv6 address.
        /// </summary>
        public static bool IsIpV6AddressValid(string address)
        {
#if !NETFX_CORE
            if (!string.IsNullOrEmpty(address))
            {
                System.Net.IPAddress ip;
                if (System.Net.IPAddress.TryParse(address, out ip))
                  return ip.AddressFamily == System.Net.Sockets.AddressFamily.InterNetworkV6;
            }
#endif
            return false;
        }

        #endregion

        #region String Conversions

        public static int ToInt32(this string str, int defaultValue = default(int))
        {
            if (str == null)
                return defaultValue;

            try
            {
                return int.Parse(str);
            }
            catch
            {
                return defaultValue;
            }
        }

        public static long ToInt64(this string str, long defaultValue = default(long))
        {
            if (str == null)
                return defaultValue;

            try
            {
                return long.Parse(str);
            }
            catch
            {
                return defaultValue;
            }
        }

        public static DateTime ToDateTime(this string str, DateTime defaultValue = default(DateTime))
        {
            if (str == null)
                return defaultValue;

            try
            {
                DateTime.TryParse(str, out defaultValue);
                return defaultValue.ToUniversalTime();
            }
            catch
            {
                return defaultValue;
            }
        }

        public static string ToStrOrEmpty(this string str)
        {
            if (str == null)
                return String.Empty;

            return str;
        }

        #endregion

        #region Efficient String Parsing Helpers

        internal static string Read(this string str, ref int pos, char block, bool needResult = true)
        {
            return str.Read(ref pos, (ch) => ch != block, needResult);
        }

        internal static string Read(this string str, ref int pos, Func<char, bool> block, bool needResult = true)
        {
            if (pos >= str.Length)
                return string.Empty;

            str.SkipWhiteSpace(ref pos);

            int startPos = pos;

            while (pos < str.Length && block(str[pos]))
                pos++;

            string result = needResult ? str.Substring(startPos, pos - startPos) : null;

            // set position to the next char
            pos++;

            return result;
        }

        internal static string ReadPossibleQuotedText(this string str, ref int pos)
        {
            string result = string.Empty;
            if (str == null)
                return result;

            // It's a quoted text?
            if (str[pos] == '\"')
            {
                // Skip the starting quote
                str.Read(ref pos, '\"', false);

                // Read the text until the ending quote
                result = str.Read(ref pos, '\"');

                // Next option
                str.Read(ref pos, ',', false);
            }
            else
                // It's not a quoted text, so we will read until the next option
                result = str.Read(ref pos, (ch) => ch != ',' && ch != ';');

            return result;
        }

        internal static void SkipWhiteSpace(this string str, ref int pos)
        {
            if (pos >= str.Length)
                return;

            while (pos < str.Length && char.IsWhiteSpace(str[pos]))
                pos++;
        }

        internal static string TrimAndLower(this string str)
        {
            if (str == null)
                return null;

            char[] buffer = new char[str.Length];
            int length = 0;

            for (int i = 0; i < str.Length; ++i)
            {
                char ch = str[i];
                if (!char.IsWhiteSpace(ch) && !char.IsControl(ch))
                    buffer[length++] = char.ToLowerInvariant(ch);
            }

            return new string(buffer, 0, length);
        }

        internal static char? Peek(this string str, int pos)
        {
            if (pos < 0 || pos >= str.Length)
                return null;

            return str[pos];
        }

        #endregion
        
        #region Buffer Filling

        /// <summary>
        /// Will fill the entire buffer from the stream. Will throw an exception when the underlying stream is closed.
        /// </summary>
        public static void ReadBuffer(this Stream stream, byte[] buffer)
        {
            int count = 0;

            do
            {
                int read = stream.Read(buffer, count, buffer.Length - count);

                if (read <= 0)
                    throw ExceptionHelper.ServerClosedTCPStream();

                count += read;
            } while (count < buffer.Length);
        }

        public static void ReadBuffer(this Stream stream, byte[] buffer, int length)
        {
            int count = 0;

            do
            {
                int read = stream.Read(buffer, count, length - count);

                if (read <= 0)
                    throw ExceptionHelper.ServerClosedTCPStream();

                count += read;
            } while (count < length);
        }

        #endregion

        #region BufferPoolMemoryStream
        
        #endregion
    }

    public static class ExceptionHelper
    {
        public static Exception ServerClosedTCPStream()
        {
            return new Exception("TCP Stream closed unexpectedly by the remote server");
        }
    }
}