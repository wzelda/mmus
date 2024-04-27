using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;
using System;
using System.Text;
using System.IO;
using System.Security.Cryptography;
//using YamlDotNet.Serialization;
//using YamlDotNet.Serialization.NamingConventions;
using System.Runtime.Serialization.Formatters.Binary;

namespace LPCFramework
{
    [LuaCallCSharp]
    public class FileUtils
    {
        public static byte[] ObjectToByteArray(object obj)
        {
            if (obj == null)
                return null;
            BinaryFormatter bf = new BinaryFormatter();
            using (MemoryStream ms = new MemoryStream())
            {
                bf.Serialize(ms, obj);
                return ms.ToArray();
            }
        }

        public static object ByteArrayToObject(byte[] arrBytes)
        {
            object obj = null;

            using (MemoryStream memStream = new MemoryStream())
            {
                BinaryFormatter binForm = new BinaryFormatter();
                memStream.Write(arrBytes, 0, arrBytes.Length);
                memStream.Seek(0, SeekOrigin.Begin);
                obj = (object)binForm.Deserialize(memStream);
            }
            return obj;
        }

        /// <summary>
        /// 读取文件，以string格式返回
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        public static string ReadFileToString(string path)
        {
            if (!File.Exists(path))
            {
                Debug.Log("[warning] 文件不存在: " + path);
                return string.Empty;
            }

            string text = string.Empty;
            try
            {
                StreamReader sr = new StreamReader(path);
                text = sr.ReadToEnd();
                sr.Close();
                sr.Dispose();
            }
            catch (Exception e)
            {
                Debug.LogError("[error] 读取文件错误: " + e);
                return string.Empty;
            }

            return text;
        }
        /// <summary>
        /// 读取文件，以bytes格式返回
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        public static byte[] ReadFileToBytes(string path)
        {
            if(!File.Exists(path))
            {
                Debug.Log("[warning] 文件不存在: " + path);
                return null;
            }

            string text = string.Empty;
            
            try
            {
                StreamReader sr = new StreamReader(path);
                text = sr.ReadToEnd();
                sr.Close();
                sr.Dispose();
            }
            catch (Exception e)
            {
                Debug.LogError("[error] 读取文件错误: " + e);
                return null;
            }

            return UTF8Encoding.UTF8.GetBytes(text);
        }

        public static List<string> getAllFolderinDir(string dir)
        {
            List<string> fileList = new List<string>();
            fileList.AddRange(Directory.GetDirectories(dir));
            string[] subDirs = Directory.GetDirectories(dir);
            foreach (string subdir in subDirs)
            {
                fileList.AddRange(getAllFolderinDir(subdir));

            }
            return fileList;
        }


        /// <summary>
        /// 以覆盖的形式写文件
        /// </summary>
        /// <param name="path"></param>
        /// <param name="content"></param>
        public static bool WriteFile(string path, byte[] content)
        {
            try
            {
                string parentFolder = Path.GetDirectoryName(path);
                if (!Directory.Exists(parentFolder)) {
                    Directory.CreateDirectory(parentFolder);
                }
                FileStream fs = new FileStream(path, FileMode.Create);
                fs.Write(content, 0, content.Length);

                fs.Close();
                fs.Dispose();
            }
            catch (Exception e)
            {
                //路径与名称未找到文件则直接返回空
                Debug.LogError("[error] 写入文件错误: " + e);
                return false;
            }

            return true;
        }

        #region Proto序列化/反序列化
        /*
        public static T DeserializeProto<T>(string filePath) where T : class
        {
            byte[] content = ReadFileToBytes(filePath);
            if (null == content)
                return null;

            using (System.IO.MemoryStream stream = new System.IO.MemoryStream(content))
            {
                T info = ProtoBuf.Serializer.Deserialize<T>(stream);
                return info;
            }
        }

        public static bool SerializeProto<T>(T info, string folder, string fileName) where T : class
        {
            if (!Directory.Exists(folder))
            {
                Directory.CreateDirectory(folder);
            }

            string filePath = Path.Combine(folder, fileName);

            using (System.IO.MemoryStream stream = new System.IO.MemoryStream())
            {
                ProtoBuf.Serializer.Serialize<T>(stream, info);
                if (stream.Length > 0)
                {
                    return FileUtils.WriteFile(filePath, stream.ToArray());
                }
            }

            return false;
        }
        */
        #endregion
        /*YAML序列化/反序列化
                #region YAML序列化/反序列化

                private static Deserializer YamlDeserializer = new DeserializerBuilder().Build();
                //private static Deserializer YamlDeserializer = new DeserializerBuilder().WithNamingConvention(new CamelCaseNamingConvention()).Build();

                private static Serializer YamlSerializer = new Serializer();

                /// <summary>
                /// 反序列化YAML字符串到指定的类型对象
                /// </summary>
                /// <typeparam name="T">反虚拟化的对象类型。</typeparam>
                /// <param name="content">文件内容</param>
                /// <returns>反序列化的对象。抛出异常或者返回null都表示失败。</returns>
                public static T DeserializeYAMLContent<T>(string content) where T : class
                {
                    if (string.IsNullOrEmpty(content))
                        return null;

                    T tOut = null;
                    try
                    {
                        tOut = YamlDeserializer.Deserialize<T>(content);
                    }
                    catch (Exception e)
                    {
                        Debug.LogError("[error] 解析YAML文件错误: " + e);
                    }

                    return tOut;
                }
                /// <summary>
                /// 序列化YAML内容到指定文件
                /// </summary>
                /// <param name="path"></param>
                /// <param name="content"></param>
                public static bool SerializeYAMLContent(string path, object content)
                {
                    if (string.IsNullOrEmpty(path) || null == content)
                        return false;

                    try
                    {
                        string strContent = YamlSerializer.Serialize(content);
                        if(!string.IsNullOrEmpty(strContent))
                        {
                            return WriteFile(path, UTF8Encoding.UTF8.GetBytes(strContent));
                        }
                    }
                    catch (Exception e)
                    {
                        Debug.LogError("[error] 解析YAML文件错误: " + e);
                    }

                    return false;
                }



                #endregion
        */
        /// <summary>
        /// 获取文件名(有后缀无路径)或者文件夹
        /// </summary>
        /// <param name="path"></param>
        /// <param name="separator"></param>
        /// <returns></returns>
        public static string GetFileName(string path, char separator = '/')
        {
            if (!path.Contains("/")) return path;
            return path.Substring(path.LastIndexOf(separator) + 1);
        }
        /// <summary>
        /// 获取文件名(无后缀无路径)
        /// </summary>
        /// <param name="fileName"></param>
        /// <param name="separator"></param>
        /// <returns></returns>
        public static string GetFileNameWithoutExtention(string fileName, char separator = '/')
        {
            if (!fileName.Contains("/")) return fileName;
            return GetFileNamePathWithoutExtention(GetFileName(fileName, separator));
        }
        /// <summary>
        /// 获取文件路径
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        public static string GetFilePath(string path)
        {
            if (!path.Contains("/")) return path;
            return path.Substring(0, path.LastIndexOf('/'));
        }
        /// <summary>
        /// 获取包含不带后缀的文件名路径
        /// </summary>
        /// <param name="fileName"></param>
        /// <returns></returns>
        public static string GetFileNamePathWithoutExtention(string fileName)
        {
            if (!fileName.Contains(".")) return fileName;
            return fileName.Substring(0, fileName.LastIndexOf('.'));
        }
        /// <summary>
        /// 获取文件的上一级文件夹名称
        /// </summary>
        /// <param name="filename"></param>
        /// <returns></returns>
        public static string GetFileParentFolder(string filename)
        {
            if (!filename.Contains("/")) return filename;
            string filepath = GetFilePath(filename);

            if (!filepath.Contains("/")) return filepath;

            string parentfolder = filepath.Substring(filepath.LastIndexOf('/'), (filepath.Length - filepath.LastIndexOf('/'))).Replace("/", "");
            return parentfolder;
        }

        /// <summary>
        /// HashToMD5Hex
        /// </summary>
        public static string HashToMD5Hex(string sourceStr)
        {
            byte[] Bytes = Encoding.UTF8.GetBytes(sourceStr);
            using (MD5CryptoServiceProvider md5 = new MD5CryptoServiceProvider())
            {
                byte[] result = md5.ComputeHash(Bytes);
                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < result.Length; i++)
                    builder.Append(result[i].ToString("x2"));
                return builder.ToString();
            }
        }

        /// <summary>
        /// 计算字符串的MD5值
        /// </summary>
        public static string GetMD5ForString(string source)
        {
            MD5CryptoServiceProvider md5 = new MD5CryptoServiceProvider();
            byte[] data = System.Text.Encoding.UTF8.GetBytes(source);
            byte[] md5Data = md5.ComputeHash(data, 0, data.Length);
            md5.Clear();

            string destString = "";
            for (int i = 0; i < md5Data.Length; i++)
            {
                destString += System.Convert.ToString(md5Data[i], 16).PadLeft(2, '0');
            }
            destString = destString.PadLeft(32, '0');
            return destString;
        }

        /// <summary>
        /// 计算文件的MD5值
        /// </summary>
        public static string GetMD5ForFile(string file)
        {
            try
            {
                FileStream fs = new FileStream(file, FileMode.Open);
                System.Security.Cryptography.MD5 md5 = new System.Security.Cryptography.MD5CryptoServiceProvider();
                byte[] retVal = md5.ComputeHash(fs);
                fs.Close();

                // Loop through each byte of the hashed data 
                // and format each one as a hexadecimal string.
                StringBuilder sb = new StringBuilder();
                for (int i = 0; i < retVal.Length; i++)
                {
                    sb.Append(retVal[i].ToString("x2"));
                }
                return sb.ToString();
            }
            catch (Exception ex)
            {
                throw new Exception("md5file() fail, error:" + ex.Message);
            }
        }

        /*
        /// <summary>
        /// 局部加密解密
        /// </summary>
        /// <param name="input"></param>
        public static void Encrypt(ref byte[] input)
        {
            if (input.Length > ConstDefines.EncryptLen)
            {
                byte[] tmp = new byte[ConstDefines.EncryptLen];
                System.Array.Copy(input, 0, tmp, 0, ConstDefines.EncryptLen);
                byte[] de = RC4(tmp, ConstDefines.EncryptKey);
                for (int i = 0; i < ConstDefines.EncryptLen; i++)
                {
                    input[i] = de[i];
                }
            }
        }

        /// <summary>
        /// 整个文件加密
        /// </summary>
        /// <param name="input"></param>
        public static void EncryptAll(ref byte[] input)
        {
            byte[] tmp = new byte[input.LongLength];
            System.Array.Copy(input, 0, tmp, 0, ConstDefines.EncryptLen);
            byte[] de = RC4(tmp, ConstDefines.EncryptKey);
            System.Array.Copy(de, 0, input, 0, ConstDefines.EncryptLen);
            tmp = null;
            de = null;
        }*/

        /// <summary>
        /// RC4 字符串
        /// </summary>
        /// <param name="str"></param>
        /// <param name="pass"></param>
        /// <returns></returns>
        public static string RC4(string str, String pass)
        {
            Byte[] data = System.Text.Encoding.UTF8.GetBytes(str);
            Byte[] bt = RC4(data, pass);
            return System.Text.Encoding.UTF8.GetString(bt);
        }

        public static Byte[] RC4(Byte[] data, String pass)
        {
            if (data == null || pass == null) return null;
            Byte[] output = new Byte[data.Length];
            Int64 i = 0;
            Int64 j = 0;
            Byte[] mBox = GetKey(System.Text.Encoding.UTF8.GetBytes(pass), 256);

            // 加密
            for (Int64 offset = 0; offset < data.Length; offset++)
            {
                i = (i + 1) % mBox.Length;
                j = (j + mBox[i]) % mBox.Length;
                Byte temp = mBox[i];
                mBox[i] = mBox[j];
                mBox[j] = temp;
                Byte a = data[offset];
                //Byte b = mBox[(mBox[i] + mBox[j] % mBox.Length) % mBox.Length];
                // mBox[j] 一定比 mBox.Length 小，不需要在取模
                Byte b = mBox[(mBox[i] + mBox[j]) % mBox.Length];
                output[offset] = (Byte)((Int32)a ^ (Int32)b);
            }

            data = output;

            return output;
        }
        static private Byte[] GetKey(Byte[] pass, Int32 kLen)
        {
            Byte[] mBox = new Byte[kLen];

            for (Int64 i = 0; i < kLen; i++)
            {
                mBox[i] = (Byte)i;
            }
            Int64 j = 0;
            for (Int64 i = 0; i < kLen; i++)
            {
                j = (j + mBox[i] + pass[i % pass.Length]) % kLen;
                Byte temp = mBox[i];
                mBox[i] = mBox[j];
                mBox[j] = temp;
            }
            return mBox;
        }
        public static void ClearPlayerData()
        {
            PlayerPrefs.DeleteAll();
            foreach (var dir in Directory.GetDirectories(Application.persistentDataPath))
            {
                Debug.Log("Delete folder " + dir);
                Directory.Delete(dir, true);
            }

            foreach (var file in Directory.GetFiles(Application.persistentDataPath))
            {
                Debug.Log("Delete file " + file);
                File.Delete(file);
            }
        }
    }
}
