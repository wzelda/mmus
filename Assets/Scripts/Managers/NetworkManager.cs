using UnityEngine;
using System;
using System.Globalization;
using System.Text;
using System.Security.Cryptography;
using System.Collections;
using System.Collections.Generic;
using BestHTTP;
using XLua;
using UnityEngine.Networking;

namespace LPCFramework
{
    /// <summary>
    /// 网络消息管理器
    /// 负责与服务器之间的socket通信
    /// </summary>
    [LuaCallCSharp]
    public class NetworkManager : IManager
    {
        public static readonly NetworkManager Instance = new NetworkManager();

        /// <summary>
        /// 消息队列
        /// </summary>
        private readonly DisruptorUnity3d.RingBuffer<byte[]> m_msgQueue = new DisruptorUnity3d.RingBuffer<byte[]>(256);
        
        public readonly DisruptorUnity3d.RingBuffer<byte> m_downQueue = new DisruptorUnity3d.RingBuffer<byte>(1);
        
        /// <summary>
        /// 初始化
        /// </summary>
        public void OnInitialize()
        {
        }
        byte downSign;
        
        /// 更新逻辑
        /// </summary>
        public void OnUpdate()
        {
            m_downQueue.TryDequeue(out downSign);
            // 网络消息
            byte[] func;
            for (int i = 0; i < 10; i++) // 每帧最多处理10条消息
            {
                if (!m_msgQueue.TryDequeue(out func))
                {
                    return;
                }
                
                try
                {
                    LuaManager.Instance.OnReceiveMsg(ref func);
                }
                catch (Exception ex)
                {
#if UNITY_EDITOR
                    Debug.LogErrorFormat("处理消息出错 {0}", ex.ToString());
#endif
                }
            }
        }

        /// <summary>
        /// 析构
        /// </summary>
        public void OnDestruct()
        {
            Debug.Log("~NetworkManager was destroyed!");
        }

        #region 协议处理

        /// <summary>
        /// 消息进队列
        /// </summary>
        /// <param name="func"></param>
        public void queueMsg(byte[] func)
        {
            m_msgQueue.Enqueue(func);
        }

        /// <summary>
        /// 转byte[]
        /// </summary>
        /// <param name="hexString"></param>
        /// <returns></returns>
        private byte[] ConvertHexStringToByteArray(string hexString)
        {
            if (hexString.Length % 2 != 0)
            {
                throw new ArgumentException(String.Format(CultureInfo.InvariantCulture,
                    "The binary key cannot have an odd number of digits: {0}", hexString));
            }

            byte[] HexAsBytes = new byte[hexString.Length / 2];
            for (int index = 0; index < HexAsBytes.Length; index++)
            {
                string byteValue = hexString.Substring(index * 2, 2);
                HexAsBytes[index] = byte.Parse(byteValue, NumberStyles.HexNumber, CultureInfo.InvariantCulture);
            }

            return HexAsBytes;
        }

        #endregion

        #region 网络检测

        /// <summary>
        /// 网络可用
        /// </summary>
        [LuaCallCSharp]
        public bool NetAvailable
        {
            get { return Application.internetReachability != NetworkReachability.NotReachable; }
        }

        /// <summary>
        /// 是否是无线
        /// </summary>
        [LuaCallCSharp]
        public bool IsWifi
        {
            get { return Application.internetReachability == NetworkReachability.ReachableViaLocalAreaNetwork; }
        }

        #endregion

        #region http请求

        /// <summary>
        /// sha1安全签名
        /// </summary>
        /// <returns></returns>        
        public string GetSha1(string value)
        {
            SHA1 sha = new SHA1CryptoServiceProvider();
            var enc = Encoding.UTF8; //new ASCIIEncoding();

            byte[] dataToHash = enc.GetBytes(value);
            byte[] dataHashed = sha.ComputeHash(dataToHash);

            return BitConverter.ToString(dataHashed).Replace("-", "").ToLower();
        }

        //public string GetSha1Hex(string value)
        //{
        //    SHA1 sha = new SHA1CryptoServiceProvider();
        //    ASCIIEncoding enc = new ASCIIEncoding();
        //
        //    byte[] dataToHash = enc.GetBytes(value);
        //    byte[] dataHashed = sha.ComputeHash(dataToHash);
        //
        //    string hexString = BitConverter.ToString(data, 0).Replace("-", string.Empty).ToLower();
        //
        //}

        /// <summary>
        /// HttpGetProtobuf
        /// </summary>
        /// <param name="msg"></param>
        [LuaCallCSharp]
        public void HttpGetProtobuf(string url, Action<byte[], string> succeedCallBack, Action<string> errorCallBack,
            int retryCount = 5, int timeout = 5)
        {
            var request = UnityWebRequest.Get(url);
            request.timeout = (int)ConnectTimeout.TotalSeconds;

            request.SendWebRequest().completed += (opt) =>
            {
                var webReq = (opt as UnityWebRequestAsyncOperation).webRequest;
                if (webReq.isNetworkError || webReq.isHttpError)
                {
                    if (retryCount <= 1)
                    {
                        if (errorCallBack != null)
                        {
                            errorCallBack("Network error " + webReq.error);
                        }
                    }
                    else
                    {
                        this.HttpGetProtobuf(url, succeedCallBack, errorCallBack, retryCount - 1);
                    }
                }
                else
                {
                    succeedCallBack(webReq.downloadHandler.data, webReq.downloadHandler.text);
                }
            };            
        }

        private static readonly TimeSpan ConnectTimeout = TimeSpan.FromSeconds(5);

        [LuaCallCSharp]
        public void HttpPostString(string url, LuaTable param, Action<string> succeedCallBack,
            Action<string> errorCallBack = null,
            int retryCount = 5, int timeout = 5
        )
        {
            var form = new WWWForm();
            if (param != null)
            {
                param.ForEach<string, string>((key, value) => { form.AddField(key, value); });
            }

            var request = UnityWebRequest.Post(url, "");
            request.timeout = (int)ConnectTimeout.TotalSeconds;

            request.SendWebRequest().completed += (opt) =>
            {
                var webReq = (opt as UnityWebRequestAsyncOperation).webRequest;
                if (webReq.isNetworkError || webReq.isHttpError)
                {
                    if (retryCount <= 1)
                    {
                        if (errorCallBack != null)
                        {
                            errorCallBack("Network error " + webReq.error);
                        }
                    }
                    else
                    {
                        this.HttpPostString(url, param, succeedCallBack, errorCallBack, retryCount - 1, timeout);
                    }
                }
                else
                {
                    succeedCallBack(webReq.downloadHandler.text);
                }
            };
        }

        [LuaCallCSharp]
        public void HttpPostBytes(string url, LuaTable param, Action<byte[]> succeedCallBack,
            Action<string> errorCallBack = null,
            int retryCount = 5, int timeout = 5
        )
        {
            var form = new WWWForm();
            if (param != null)
            {
                param.ForEach<string, string>((key, value) => { form.AddField(key, value); });
            }

            var request = UnityWebRequest.Post(url, "");
            request.timeout = (int)ConnectTimeout.TotalSeconds;

            request.SendWebRequest().completed += (opt) =>
            {
                var webReq = (opt as UnityWebRequestAsyncOperation).webRequest;
                if (webReq.isNetworkError || webReq.isHttpError)
                {
                    if (retryCount <= 1)
                    {
                        if (errorCallBack != null)
                        {
                            errorCallBack("Network error " + webReq.error);
                        }
                    }
                    else
                    {
                        this.HttpPostBytes(url, param, succeedCallBack, errorCallBack, retryCount - 1, timeout);
                    }
                }
                else
                {
                    succeedCallBack(webReq.downloadHandler.data);
                }
            };

        }


        [LuaCallCSharp]
        public void HttpGetString(string url, Action<string> succeedCallBack, Action<string> errorCallBack = null,
            int retryCount = 5, int timeout = 5
        )
        {
            var request = UnityWebRequest.Get(url);
            request.timeout = (int)ConnectTimeout.TotalSeconds;

            request.SendWebRequest().completed += (opt) =>
            {
                var webReq = (opt as UnityWebRequestAsyncOperation).webRequest;
                if (webReq.isNetworkError || webReq.isHttpError)
                {
                    if (retryCount <= 1)
                    {
                        if (errorCallBack != null)
                        {
                            errorCallBack("Network error " + webReq.error);
                        }
                    }
                    else
                    {
                        this.HttpGetString(url, succeedCallBack, errorCallBack, retryCount - 1, timeout);
                    }
                }
                else
                {
                    succeedCallBack(webReq.downloadHandler.text);
                }
            };
        }

        [LuaCallCSharp]
        public void HttpGetBytes(string url, Action<byte[]> succeedCallBack, Action<string> errorCallBack = null,
            int retryCount = 5, int timeout = 5
        )
        {
            var request = UnityWebRequest.Get(url);
            request.timeout = (int)ConnectTimeout.TotalSeconds;

            request.SendWebRequest().completed += (opt) =>
            {
                var webReq = (opt as UnityWebRequestAsyncOperation).webRequest;
                if (webReq.isNetworkError || webReq.isHttpError)
                {
                    if (retryCount <= 1)
                    {
                        if (errorCallBack != null)
                        {
                            errorCallBack("Network error " + webReq.error);
                        }
                    }
                    else
                    {
                        this.HttpGetBytes(url, succeedCallBack, errorCallBack, retryCount - 1, timeout);
                    }
                }
                else
                {
                    succeedCallBack(webReq.downloadHandler.data);
                }
            };
        }


        private byte[] ByteArrayToHexArray(string param)
        {
            byte[] data = Encoding.UTF8.GetBytes(param);
            string hexString = BitConverter.ToString(data, 0).Replace("-", string.Empty).ToLower();
            return Encoding.UTF8.GetBytes(hexString);
        }

        public byte[] GetBytesFromHex(string hexString)
        {
            int NumberChars = hexString.Length;
            byte[] bytes = new byte[NumberChars / 2];
            for (int i = 0; i < NumberChars; i += 2)
            {
                bytes[i / 2] = Convert.ToByte(hexString.Substring(i, 2), 16);
            }

            return bytes;
        }

        public byte[] GetBytesFromBase64(string data)
        {
            return Convert.FromBase64String(data);
        }

        class HttpRequestData
        {
            public byte[] r;

            public HttpRequestData(byte[] _param)
            {
                r = _param;
            }

            public HttpRequestData()
            {
            }

            public byte[] GetReqBytes()
            {
                /* StringBuilder sbHex = new StringBuilder();
                 foreach (char chr in r)
                 {
                     sbHex.Append(Convert.ToString(Convert.ToInt32(chr),16));
                 }
                 string param = "r=" + sbHex.ToString();*/

                string param = "r=" + (r == null ? "" : BitConverter.ToString(r).Replace("-", string.Empty).ToLower());

                return Encoding.UTF8.GetBytes(param);
            }

            public byte[] GetReqBase64()
            {
                //转成 Base64 形式的 System.String  
                string strBase64 = "r=" + Convert.ToBase64String(r);
                return Encoding.UTF8.GetBytes(strBase64);
            }
        }

        [Serializable]
        class HttpResponseData
        {
            public int status;
            public string data;
            public string err;

            public byte[] GetBytesFromHex()
            {
                int NumberChars = data.Length;
                byte[] bytes = new byte[NumberChars / 2];
                for (int i = 0; i < NumberChars; i += 2)
                {
                    bytes[i / 2] = Convert.ToByte(data.Substring(i, 2), 16);
                }

                return bytes;
            }

            public byte[] GetBytesFromBase64()
            {
                return Convert.FromBase64String(data);
            }
        }

        #endregion
    }
}