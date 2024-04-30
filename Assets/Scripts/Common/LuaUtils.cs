using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Formatters.Binary;
using System.Text;
using System.Text.RegularExpressions;
using BestHTTP.Extensions;
using DG.Tweening;
using FairyGUI;
using FairyGUI.Utils;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;
using XLua;
using Debug = UnityEngine.Debug;
using Object = System.Object;

namespace LPCFramework {
    [LuaCallCSharp]
    public class LuaUtils {
        public static int EncodeOffset = 0;
        static Ray m_ray;
        static RaycastHit m_hit;

        public static GameObject ScreenHitGameObject (Vector3 screenPos) {
            if (Camera.main != null) {
                m_ray = Camera.main.ScreenPointToRay (screenPos);
                if (Physics.Raycast (m_ray, out m_hit, 1000)) {
                    return m_hit.collider.gameObject;
                }
            }

            return null;
        }

        public static GameObject ScreenHitGameObjectByLayer (Vector3 screenPos, int layerMask) {
            if (Camera.main != null) {
                layerMask = 1 << layerMask;
                m_ray = Camera.main.ScreenPointToRay (screenPos);
                if (Physics.Raycast (m_ray, out m_hit, 1000, layerMask)) {
                    return m_hit.collider.gameObject;
                }
            }

            return null;
        }

        public static void SetCameraRender (Camera camera, bool render) {
            if (camera != null) {
                if (render) {
                    //Camera.main.cullingMask = -1;
                    camera.cullingMask =
                        (1 << LayerMask.NameToLayer ("MapLayer")) +
                        (1 << LayerMask.NameToLayer ("Actor")) +
                        (1 << LayerMask.NameToLayer ("Ground")) +
                        (1 << LayerMask.NameToLayer ("Default"));
                } else {
                    camera.cullingMask = 0;
                }
            }
        }

        [LuaCallCSharp]
        public static Vector3 ScreenHitWorldPos (int layerMask, bool needShift = false) {
            if (Camera.main != null) {
                if (needShift)
                    layerMask = 1 << layerMask;

#if UNITY_EDITOR || UNITY_STANDALONE_WIN || UNITY_STANDALONE_OSX
                m_ray = Camera.main.ScreenPointToRay (Input.mousePosition);
#else
                if (Input.touchCount == 1)
                    m_ray = Camera.main.ScreenPointToRay (Input.touches[0].position);
#endif
                if (Physics.Raycast (m_ray, out m_hit, 500, layerMask))
                    return m_hit.point;
            }

            return Vector3.zero;
        }

        [LuaCallCSharp]
        public static Vector3 ScreenPosHitWorldPos (Vector2 screenpos, int layerMask, bool needShift = false) {
            if (Camera.main != null) {
                if (needShift)
                    layerMask = 1 << layerMask;

                m_ray = Camera.main.ScreenPointToRay (screenpos);
                if (Physics.Raycast (m_ray, out m_hit, 500, layerMask))
                    return m_hit.point;
            }

            return Vector3.zero;
        }

        public static Vector3 WorldPosToScreenPoiont (Vector3 worldpos) {
            if (Camera.main != null) {
                return Camera.main.WorldToScreenPoint (worldpos);
            }

            return Vector3.zero;
        }

        public static Vector3 WorldToGameScreenPoint (GameObject go) {
            if (Camera.main != null) {
                return Camera.main.WorldToScreenPoint (go.transform.position);
            }

            return Vector3.zero;
        }

        [LuaCallCSharp]
        public static Vector3 ScreenToWorldPoint (GameObject go) {
            if (Camera.main != null) {
                return Camera.main.ScreenToWorldPoint (go.transform.position);
            }

            return Vector3.zero;
        }

        [LuaCallCSharp]
        public static Vector2 WorldPosToScreenPoint (Vector3 pos) {
            Vector2 v = Camera.main.WorldToViewportPoint (pos);
            v = new Vector2 (v.x * GRoot.inst.width, (1 - v.y) * GRoot.inst.height);
            return v;
        }

        [LuaCallCSharp]
        public static Vector2 WorldToScreenPoint (GameObject go) {
            return WorldPosToScreenPoint (go.transform.position);
        }

        public static void DontDestroyChildOnLoad (GameObject child) {
            Transform parentTransform = child.transform;

            // If this object doesn't have a parent then its the root transform.
            while (parentTransform.parent != null) {
                // Keep going up the chain.
                parentTransform = parentTransform.parent;
            }

            GameObject.DontDestroyOnLoad (parentTransform.gameObject);
        }

        public static void GC () {
            if (ResourceMgr.showResourceLog) {
                Debug.LogError ("CALL LuaGC & SystemGC & UnloadUnusedAssets");
            }

            LuaVMManager.Instance.GC ();
            System.GC.Collect();
            Resources.UnloadUnusedAssets();
        }
        public static void SetSortingLayer (Transform target, string newSortingLayer) {
            Renderer[] renders = target.GetComponentsInChildren<Renderer> ();
            foreach (Renderer render in renders) {
                render.sortingLayerName = newSortingLayer;
            }
        }

        public static void SetSortingLayerAndRenderQueue (Transform target, string newSortingLayer, int renderQueue) {
            Renderer[] renders = target.GetComponentsInChildren<Renderer> ();
            foreach (Renderer render in renders) {
                render.sortingLayerName = newSortingLayer;
                Material[] ms = render.materials;
                for (int i = 0; i < ms.Length; i++) {
                    ms[i].renderQueue = renderQueue;
                }
            }
        }

        /// <summary>
        /// 判断对象为空
        /// </summary>
        public static bool IsNil (UnityEngine.Object target) {
            if (null == target) {
                return true;
            } else {
                return false;
            }
        }

        /// <summary>
        /// 复制文本到剪贴板
        /// </summary>
        public static void Copy (string content) {
            TextEditor t = new TextEditor ();
            t.text = content;
            t.OnFocus ();
            t.Copy ();
        }

        //打印byte数组
        public static void Prase (byte[] datas) {
            string hexString = string.Empty;
            if (datas != null) {
                System.Text.StringBuilder strB = new System.Text.StringBuilder ();
                for (int i = 0; i < datas.Length; i++) {
                    strB.Append (datas[i].ToString ("X2"));
                }

                hexString = strB.ToString ();
            }

            Debug.Log (hexString);
        }

        public static List<GComponent> GetFairyHitCom (Vector3 worldPos) {
            Vector2 screenPos = StageCamera.main.WorldToScreenPoint (worldPos);
            screenPos.y = Screen.height - screenPos.y;
            Vector2 mousePos = Input.mousePosition;
            List<GComponent> overComList = new List<GComponent> ();
            HitTestContext.ClearRaycastHitCache ();
            DisplayObject _touchTarget = Stage.inst.HitTest (screenPos, true); //Stage.inst.HitTest(screenPos, true);
            //string s = "";
            while (_touchTarget != null) {
                //s += _touchTarget.gameObject.name + "\n";
                if (_touchTarget.gOwner != null && _touchTarget.gOwner.asCom != null) {
                    overComList.Add (_touchTarget.gOwner.asCom);
                }

                _touchTarget = _touchTarget.parent;
            }

            //Debug.LogError(s);
            return overComList;
        }

        //是否有拖尾
        public static void BulletSetActive (GameObject go, bool active) {
            Renderer[] renders = go.transform.GetComponentsInChildren<Renderer> ();
            for (int i = 0; i < renders.Length; i++) {
                if (!renders[i].gameObject.name.Contains ("Trail")) {
                    renders[i].enabled = active;
                }
            }
        }

        public static void SetActive (GameObject go, bool active) {
            Renderer[] renders = go.transform.GetComponentsInChildren<Renderer> ();
            for (int i = 0; i < renders.Length; i++) {
                renders[i].enabled = active;
            }
        }

        public static void SetSkinMeshUpdateWhenScreen (GameObject go, bool val) {
            Renderer[] renders = go.transform.GetComponentsInChildren<Renderer> ();
            for (int i = 0; i < renders.Length; i++) {
                if (renders[i] is SkinnedMeshRenderer)
                    ((SkinnedMeshRenderer) renders[i]).updateWhenOffscreen = val;
            }
        }

        public static void SetLightActive (Light light, float v) {
            light.intensity = v;
            //light.gameObject.SetActive(false);
        }

        public static void QuitGame () {
#if UNITY_EDITOR
            UnityEditor.EditorApplication.isPlaying = false;
#else
            Application.Quit ();
#endif
        }

        public static int GetCullingMask (string layerName) {
            return 1 << LayerMask.NameToLayer (layerName);
        }

                // 获取设备类型
        public static string GetDeviceType () {
#if UNITY_IPHONE || UNITY_IOS
            return "ios";
#elif UNITY_ANDROID
            return "android";
#elif UNITY_STANDALONE_OSX
            return "mac";
#elif UNITY_WEBGL
            return "webgl";
#endif
            return "editor";
        }

        public static void SwitchActiveScene(Scene scene)
        {
            if (SceneManager.GetActiveScene() == scene)
            {
                return;
            }

            foreach (var go in SceneManager.GetActiveScene().GetRootGameObjects())
            {
                if (go != null && !go.CompareTag("ManualSwitchActive"))
                {
                    go.SetActive(false);
                }
            }

            SceneManager.SetActiveScene(scene);
            foreach (var go in scene.GetRootGameObjects())
            {
                if (go != null && !go.CompareTag("ManualSwitchActive"))
                {
                    go.SetActive(true);
                }
            }
        }

        public static void SetLayerRecursively (GameObject gameObject, int layer) {
            gameObject.SetLayerRecursively (layer);
        }

        public static void SetSpriteRendererSize (GameObject go, Vector2 size) {
            SpriteRenderer spriteR = go.GetComponent<SpriteRenderer> ();
            if (null != spriteR)
                spriteR.size = size;
        }

        //获取网络状态
        public static int GetNetworkStatus () {
            return (int) Application.internetReachability;
        }

        #region 字符串操作
        public static string LuaBytesToString (byte[] bytes) {
            return System.BitConverter.ToString (bytes);
        }

        public static string BytesToString (byte[] bytes) {
            return System.Text.Encoding.Default.GetString (bytes);
        }
        //字符串lua 传递
        public static string CSFormat (string locstr, params string[] strs) {
            string dyStr = string.Format (locstr, strs);
            return dyStr;
        }

        public static string numberToChinese (int num) {
            string[] chnNumChar = { "零", "一", "二", "三", "四", "五", "六", "七", "八", "九" };
            string[] chnUnitSection = { "", "万", "亿", "万亿" };

            //转化一个阿拉伯数字为中文字符串
            if (num == 0) {
                return "零";
            }

            int unitPos = 0; //节权位标识
            string All = string.Empty;
            string chineseNum = string.Empty; //中文数字字符串
            bool needZero = false; //下一小结是否需要补零
            string strIns = string.Empty;
            while (num > 0) {
                int section = num % 10000; //取最后面的那一个小节
                if (needZero) {
                    //判断上一小节千位是否为零，为零就要加上零
                    All = chnNumChar[0] + All;
                }

                chineseNum = sectionTOChinese (section, chineseNum); //处理当前小节的数字,然后用chineseNum记录当前小节数字
                if (section != 0) {
                    //此处用if else 选择语句来执行加节权位
                    strIns = chnUnitSection[unitPos]; //当小节不为0，就加上节权位
                    chineseNum = chineseNum + strIns;
                } else {
                    strIns = chnUnitSection[0]; //否则不用加
                    chineseNum = strIns + chineseNum;
                }

                All = chineseNum + All;
                chineseNum = "";
                needZero = (section < 1000) && (section > 0);
                num = num / 10000;
                unitPos++;
            }

            return All;
        }

        static string sectionTOChinese (int section, string chineseNum) {
            string[] chnNumChar = { "零", "一", "二", "三", "四", "五", "六", "七", "八", "九" };
            string[] chnUnitChar = { "", "十", "百", "千" };

            string setionChinese = string.Empty; //小节部分用独立函数操作
            int unitPos = 0; //小节内部的权值计数器
            bool zero = true; //小节内部的制零判断，每个小节内只能出现一个零
            while (section > 0) {
                int v = section % 10; //取当前最末位的值
                if (v == 0) {
                    if (!zero) {
                        zero = true; //需要补零的操作，确保对连续多个零只是输出一个
                        chineseNum = chnNumChar[0] + chineseNum;
                    }
                } else {
                    zero = false; //有非零的数字，就把制零开关打开
                    setionChinese = chnNumChar[v]; //对应中文数字位
                    setionChinese = setionChinese + chnUnitChar[unitPos]; //对应中文权位
                    chineseNum = setionChinese + chineseNum;
                }

                unitPos++;
                section = section / 10;
            }

            return chineseNum;
        }

        /// <summary>
        /// 分割字符串
        /// </summary>
        /// <param name="str"></param>
        /// <param name="split"></param>
        /// <returns></returns>
        public static string[] SplitString (string str, string split) {
            return str.Split (split[0]);
        }

        // 获取字符串长度 中文2 英文1
        public static int GetStringLength (string srcString) {
            int len = 0;
            byte[] b;

            for (int i = 0; i < srcString.Length; i++) {
                b = System.Text.Encoding.Default.GetBytes (srcString.Substring (i, 1));
                if (b.Length > 1)
                    len += 2;
                else
                    ++len;
            }

            return len;
        }

        // 获取有效长度字符串
        public static string GetValidLengthString (string srcString, int maxLen) {
            string result = string.Empty;
            int byteLen = System.Text.Encoding.Default.GetByteCount (srcString); // 单字节字符长度
            int charLen = srcString.Length; // 把字符平等对待时的字符串长度
            int byteCount = 0; // 记录读取进度
            int pos = 0; // 记录截取位置
            if (byteLen > maxLen) {
                for (int i = 0; i < charLen; i++) {
                    if (System.Convert.ToInt32 (srcString.ToCharArray () [i]) > 255) // 按中文字符计算加2
                    {
                        byteCount += 2;
                    } else // 按英文字符计算加1
                    {
                        byteCount += 1;
                    }

                    if (byteCount > maxLen) // 超出时只记下上一个有效位置
                    {
                        pos = i;
                        break;
                    } else if (byteCount == maxLen) // 记下当前位置
                    {
                        pos = i + 1;
                        break;
                    }
                }

                if (pos >= 0) {
                    result = srcString.Substring (0, pos);
                }
            } else {
                result = srcString;
            }

            return result;
        }
        #endregion
        //设置头顶血条
        public static void SetTopUIXY (Camera UICamera, Vector3 topPos, float ScreenHeight, float YOffest,
            float XOffest, FairyGUI.GObject topBar) {
            Vector3 tempV3Pos = topPos;
            tempV3Pos = UICamera.WorldToScreenPoint (tempV3Pos);
            Vector2 tempV2Pos = Vector2.zero;
            tempV2Pos.y = ScreenHeight - tempV3Pos.y + YOffest;
            tempV2Pos.x = tempV3Pos.x + XOffest;
            topBar.xy = GRoot.inst.GlobalToLocal (tempV2Pos);
        }

        public static float GetIOSKeyboardHeight () {
#if UNITY_IPHONE || UNITY_IOS
            return UnityEngine.TouchScreenKeyboard.area.height;
#endif
            return 0;
        }

        public static float GetKeyboardHeight () {
            float height = 0;
            if (Application.platform == RuntimePlatform.IPhonePlayer)
                height = GetIOSKeyboardHeight ();

            return height;
        }

        public static byte[] Decompress (byte[] zippedData, int offset, int length) {
            using (var outBuffer = new BufferPoolMemoryStream (2048)) {
                using (MemoryStream ms = new MemoryStream (zippedData, offset, length)) {
                    DecompressStream(ms, outBuffer);
                }

                return outBuffer.ToArray ();
            }
        }

        public static void DecompressStream(Stream ins, Stream outs)
        {
            using (GZipStream compressedzipStream = new GZipStream(ins, CompressionMode.Decompress))
            {
                byte[] block = VariableSizedBufferPool.Get(2048, true);
                while (true)
                {
                    int bytesRead = compressedzipStream.Read(block, 0, block.Length);
                    if (bytesRead <= 0)
                        break;
                    else
                        outs.Write(block, 0, bytesRead);
                }

                VariableSizedBufferPool.Release(block);
            }
        }

        public static byte[] Decompress (byte[] zippedData) {
            return Decompress (zippedData, 0, zippedData.Length);
        }
        public static byte[] Compress (string str) {
            byte[] unZippedData = System.Text.Encoding.UTF8.GetBytes (str);
            MemoryStream ms = new MemoryStream ();
            GZipStream compressedzipStream = new GZipStream (ms, CompressionMode.Compress, true);
            compressedzipStream.Write (unZippedData, 0, unZippedData.Length);
            compressedzipStream.Close ();
            return ms.ToArray ();
        }
        public static bool SaveLocalFile (string fileName, byte[] data) {
            string dir = Application.persistentDataPath + "/data/";
            if (!Directory.Exists (dir)) {
                Directory.CreateDirectory (dir);
            }

            string path = dir + fileName;

            if (File.Exists (path))

                File.Delete (path);

            FileStream fs = new FileStream (path, FileMode.CreateNew);

            if (fs == null)
                return false;

            fs.Write (data, 0, data.Length);

            fs.Close ();

            return true;
        }

        public static byte[] GetLocalFile (string FileName)
        {
            byte[] data = null;
            string path = Application.streamingAssetsPath + "/data/" + FileName; //-----------首先检查Streaming目录
            if (File.Exists(path))
            {
                 data = File.ReadAllBytes(path);
            }
            else
            {
                FileStream fs = null;
                path = Application.persistentDataPath + "/data/" + FileName;
                if (File.Exists (path) == false)
                    return null;
                fs = new FileStream (path, FileMode.Open);
                if (fs == null || fs.Length == 0)
                    return null;
                
                data = new byte[fs.Length];
                fs.Read (data, 0, data.Length);

                fs.Close ();
            }

            return data;

        }

        //相机添加显示层级
        public static void CameraAddLayer (Camera camera, int newLayer) {
            if (camera != null) {
                camera.cullingMask |= (1 << newLayer);
            }
        }

        //相机关闭x层
        public static void CameraRemoveLayer (Camera camera, int oldLayer) {
            if (camera != null) {
                camera.cullingMask &= ~(1 << oldLayer);
            }
        }

        private static int SystemMemoryCacheSize = 100;

        /// <summary>
        /// 设置缓存数量,缓存数量过高可能导致iphone6的设备崩溃
        /// </summary>
        public static void SetSystemMemoryCacheSize (int defaultCache = -1) {
            if (defaultCache > -1) {
                SystemMemoryCacheSize = defaultCache;
                return;
            }

            if (SystemInfo.systemMemorySize < 1025) {
                SystemMemoryCacheSize = 6;
            } else if (SystemInfo.systemMemorySize < 2050) {
                SystemMemoryCacheSize = 12;
            } else if (SystemInfo.systemMemorySize < 5000) {
                SystemMemoryCacheSize = 30;
            }
        }

        /// <summary>
        /// 根据内存获取缓存数量
        /// </summary>
        /// <param name="cacheType"></param>
        /// <returns></returns>
        public static int GetSystemMemoryCache (int cacheType) {

            return SystemMemoryCacheSize;
        }

        /// <summary>
        /// 获取对象的bytes
        /// </summary>
        /// <param name="obj"></param>
        /// <returns></returns>
        public static byte[] GetObjectBytes (Object obj) {
            using (MemoryStream ms = new MemoryStream ()) {
                var formatter = new BinaryFormatter ();
                formatter.Serialize (ms, obj);
                return ms.GetBuffer ();
            }
        }

        /// <summary>
        /// 通过bytes获取对象
        /// </summary>
        /// <param name="bs"></param>
        /// <returns></returns>
        public static Object GetBytesObject (byte[] bs) {
            using (MemoryStream ms = new MemoryStream (bs)) {
                IFormatter formatter = new BinaryFormatter ();
                return formatter.Deserialize (ms);
            }
        }

        /// <summary>
        /// bytes拼接
        /// </summary>
        /// <param name="bs1"></param>
        /// <param name="bs2"></param>
        /// <returns></returns>
        public static byte[] BytesAppendBytes (byte[] bs1, byte[] bs2) {
            var tempBytes = new List<byte> ();
            tempBytes.AddRange (bs1);
            tempBytes.AddRange (bs2);
            return tempBytes.ToArray ();
        }

        /// <summary>
        /// bytes 移除末尾指定长度的bytes
        /// </summary>
        /// <param name="bs1"></param>
        /// <param name="bs2"></param>
        /// <returns></returns>
        public static byte[] BytesRemoveByteLast (byte[] bs1, byte[] bs2) {
            var tempBytes = bs1.ToList ();
            tempBytes.RemoveRange (bs1.Length - bs2.Length, bs2.Length);
            return tempBytes.ToArray ();
        }
        /// <summary>
        /// bytes 移除开头指定长度的bytes
        /// </summary>
        /// <param name="bs1"></param>
        /// <param name="bs2"></param>
        /// <returns></returns>
        public static byte[] BytesRemoveByteFirst (byte[] bs1, byte[] bs2) {
            var tempBytes = bs1.ToList ();
            tempBytes.RemoveRange (0, bs2.Length);
            return tempBytes.ToArray ();
        }

        /// <summary>
        /// 通过移位的方式加密string
        /// </summary>
        /// <param name="origin"></param>
        /// <param name="offset"></param>
        /// <returns></returns>
        public static string EncodeStringWithOffset (string origin, int offset) {
            if (offset == 0) {
                return origin;
            }
            var bytes = Encoding.UTF8.GetBytes (origin);

            for (int i = 0; i < bytes.Length; i++) {
                bytes[i] = (byte) (bytes[i] + offset);
            }

            return Encoding.UTF8.GetString (bytes);
        }

        /// <summary>
        /// 通过移位的方式解密string
        /// </summary>
        /// <param name="origin"></param>
        /// <param name="offset"></param>
        /// <returns></returns>
        public static string DecodeStringWithOffset (string origin, int offset) {
            if (offset == 0) {
                return origin;
            }
            var bytes = Encoding.UTF8.GetBytes (origin);

            for (int i = 0; i < bytes.Length; i++) {
                bytes[i] = (byte) (bytes[i] - offset);
            }

            return Encoding.UTF8.GetString (bytes);
        }

        /// <summary>
        /// 获取加密资源命名
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        public static string GetEncodeResName (string path) {
            if (EncodeOffset == 0) {
                return path;
            }
            var fileName = Path.GetFileName (path);
            var filePath = Path.GetDirectoryName (path);

            fileName = LuaUtils.EncodeStringWithOffset (fileName, EncodeOffset);

            return filePath + "/" + fileName;
        }

        public static int BitOrOp (int[] ops) {
            int r = 0;
            foreach (int op in ops) {
                r = r | op;
            }
            return r;
        }
        public static bool BitHasOp (int bitSwitch, int value) {
            return bitSwitch == (bitSwitch | value);
        }

        private static Stopwatch watch;
        /// <summary>
        /// 获取代码计时监控
        /// </summary>
        /// <returns></returns>
        public static Stopwatch GetCodeWatch () {
            if (watch == null) {
                watch = new Stopwatch ();
            }

            return watch;
        }

        /// <summary>
        /// 获取监控时间
        /// </summary>
        public static void PrintCodeTime (string sign) {
            if (watch == null) {
                return;
            }
            Debug.LogError ("In milliseconds: " + sign + "|" + watch.ElapsedMilliseconds);
        }

        private static DateTime dt;
        public static string TransIntToTime (int timeNum) {
            return string.Format ("{0:D2}", timeNum / 3600) + ":" + string.Format ("{0:D2}", timeNum % 3600 / 60) + ":" + string.Format ("{0:D2}", timeNum % 60);
        }

        public static Func<string, bool> FilterFunc;
        private static string Stars = "*******************************************************************************************************************************";
        /// <summary>
        /// 屏蔽字替换
        /// </summary>
        /// <param name="words">需要判断的文本</param>
        /// <returns>替换之后的本文</returns>
        public static string FilterWords (string words) {
            if (FilterFunc == null) {
                return words;
            }
            var result = "";

            var i = 0;

            OUTLOOP:
                while (i < words.Length) {
                    var s = "";
                    if (i == 0) {
                        s = words;
                    } else {
                        s = words.Remove (0, i);
                    }
                    var res = FilterFunc (s);

                    i++;
                    if (res) {
                        result += Stars.Substring (0, s.Length);
                        break;
                    }
                    for (var j = s.Length - 1; j >= 0; j--) {
                        s = s.Remove (s.Length - 1, 1);
                        res = FilterFunc (s);

                        if (res) {
                            result += Stars.Substring (0, s.Length);
                            i += s.Length - 1;
                            goto OUTLOOP;
                        }
                    }

                    result += words[i - 1].ToString ();
                }

            return result;
        }

        /// <summary>
        /// 判断文本是否包含屏蔽字
        /// </summary>
        /// <param name="words">需要检测的文本</param>
        /// <returns>true if has or false </returns>
        public static bool CheckWordsHasFilter (string words) {
#if CHANNEL_WATER_HUNTER_LB
            return false;
#endif
            if (FilterFunc == null) {
                return false;
            }
            var i = 0;
            while (i < words.Length) {
                var s = "";
                if (i == 0) {
                    s = words;
                } else {
                    s = words.Remove (0, i);
                }
                var res = FilterFunc (s);

                i++;
                if (res) {
                    return true;
                }
                for (var j = s.Length - 1; j >= 0; j--) {
                    s = s.Remove (s.Length - 1, 1);
                    res = FilterFunc (s);

                    if (res) {
                        return true;
                    }
                }
            }

            return false;
        }

        public static bool ContainMethod (object instance, string propertyName) {
            if (instance != null && !string.IsNullOrEmpty (propertyName)) {
                System.Type type = instance.GetType ();
                System.Reflection.MethodInfo _findedPropertyInfo = type.GetMethod (propertyName);
                return (_findedPropertyInfo != null);
            }
            return false;
        }

        public static Color GetColorByHex (string hex) {
            Color nowColor;
            ColorUtility.TryParseHtmlString (hex, out nowColor);
            return nowColor;
        }

        //获取不重复的随机数组
        public static int[] GetRandoms (int sum, int min, int max) {
            int[] arr = new int[sum];
            int j = 0;
            //表示键和值对的集合。
            Hashtable hashtable = new Hashtable ();
            System.Random rm = new System.Random ();
            while (hashtable.Count < sum) {
                //返回一个min到max之间的随机数
                int nValue = rm.Next (min, max);
                // 是否包含特定值
                if (!hashtable.ContainsValue (nValue)) {
                    //把键和值添加到hashtable
                    hashtable.Add (nValue, nValue);
                    arr[j] = nValue;

                    j++;
                }
            }

            return arr;
        }
        public static void SetEffectTimeModel (GameObject effGo, bool useUnscaledTime) {
            if (effGo == null) {
                return;
            }
            ParticleSystem[] childParticleList = effGo.GetComponentsInChildren<ParticleSystem> ();
            for (int i = 0; i < childParticleList.Length; i++) {
                ParticleSystem.MainModule main = childParticleList[i].main;
                main.useUnscaledTime = useUnscaledTime;
            }
            Animator[] childAnimatorList = effGo.GetComponentsInChildren<Animator> ();
            for (int i = 0; i < childAnimatorList.Length; i++) {
                if (useUnscaledTime) {
                    childAnimatorList[i].updateMode = AnimatorUpdateMode.UnscaledTime;
                } else {
                    childAnimatorList[i].updateMode = AnimatorUpdateMode.Normal;
                }
            }
        }
        public static Texture2D SizeTextureBilinear (Texture2D originalTexture, Vector2 size) {
            Texture2D newTexture = new Texture2D (Mathf.CeilToInt (size.x), Mathf.CeilToInt (size.y));
            float scaleX = originalTexture.width / size.x;
            float scaleY = originalTexture.height / size.y;
            int maxX = originalTexture.width - 1;
            int maxY = originalTexture.height - 1;
            for (int y = 0; y < newTexture.height; y++) {
                for (int x = 0; x < newTexture.width; x++) {
                    float targetX = x * scaleX;
                    float targetY = y * scaleY;
                    int x1 = Mathf.Min (maxX, Mathf.FloorToInt (targetX));
                    int y1 = Mathf.Min (maxY, Mathf.FloorToInt (targetY));
                    int x2 = Mathf.Min (maxX, x1 + 1);
                    int y2 = Mathf.Min (maxY, y1 + 1);

                    float u = targetX - x1;
                    float v = targetY - y1;
                    float w1 = (1 - u) * (1 - v);
                    float w2 = u * (1 - v);
                    float w3 = (1 - u) * v;
                    float w4 = u * v;
                    Color color1 = originalTexture.GetPixel (x1, y1);
                    Color color2 = originalTexture.GetPixel (x2, y1);
                    Color color3 = originalTexture.GetPixel (x1, y2);
                    Color color4 = originalTexture.GetPixel (x2, y2);
                    Color color = new Color (Mathf.Clamp01 (color1.r * w1 + color2.r * w2 + color3.r * w3 + color4.r * w4),
                        Mathf.Clamp01 (color1.g * w1 + color2.g * w2 + color3.g * w3 + color4.g * w4),
                        Mathf.Clamp01 (color1.b * w1 + color2.b * w2 + color3.b * w3 + color4.b * w4),
                        Mathf.Clamp01 (color1.a * w1 + color2.a * w2 + color3.a * w3 + color4.a * w4)
                    );
                    newTexture.SetPixel (x, y, color);

                }
            }
            newTexture.Apply ();
            return newTexture;
        }

        public static void CreateRenderTexture (DisplayObject srcGo, GImage holder, int width, int height, Vector2 offset) {
            RenderTexture renderTexture = new RenderTexture (width, height, 24, RenderTextureFormat.ARGB32) {
                antiAliasing = 1,
                filterMode = FilterMode.Bilinear,
                anisoLevel = 0,
                useMipMap = false
            };

            CaptureCamera.Capture (srcGo, renderTexture, height, offset);
            holder.texture = new NTexture (renderTexture);
        }

        public static void ClearTexture (GImage img, bool destroyMaterials) {
            img.texture.Unload (destroyMaterials);
        }

        // RenderTexture to Texture2D
        public static Texture2D RenderTexture2Texture2D (RenderTexture renderTexture, int width = 0, int height = 0) {
            if (0 == width)
                width = renderTexture.width;
            if (0 == height)
                height = renderTexture.height;

            Texture2D texture2D = new Texture2D (width, height, TextureFormat.ARGB32, false);
            RenderTexture.active = renderTexture;
            texture2D.ReadPixels (new Rect (0, 0, width, height), 0, 0);
            texture2D.Apply ();

            return texture2D;
        }

        public static Texture2D GetTexture2D (DisplayObject srcGo, int width, int height, Vector2 offset) {
            RenderTexture renderTexture = new RenderTexture (width, height, 24, RenderTextureFormat.ARGB32) {
                antiAliasing = 1,
                filterMode = FilterMode.Bilinear,
                anisoLevel = 0,
                useMipMap = false
            };

            CaptureCamera.Capture (srcGo, renderTexture, height, offset);

            return RenderTexture2Texture2D (renderTexture);
        }

        public static Texture2D ScaleTexture (Texture2D source, int targetWidth, int targetHeight) {
            Texture2D result = new Texture2D (targetWidth, targetHeight, source.format, false);

            float incX = (1.0f / (float) targetWidth);
            float incY = (1.0f / (float) targetHeight);

            for (int i = 0; i < result.height; ++i) {
                for (int j = 0; j < result.width; ++j) {
                    Color newColor = source.GetPixelBilinear ((float) j / (float) result.width, (float) i / (float) result.height);
                    result.SetPixel (j, i, newColor);
                }
            }

            result.Apply ();
            return result;
        }

        public static string CreateUUID()
        {
            return Guid.NewGuid().ToString();
        }

        // 获取设备唯一标识
        public static string GetUniqueID()
        {
#if UNITY_IOS
            return UnityEngine.iOS.Device.advertisingIdentifier;
#else
            return SystemInfo.deviceUniqueIdentifier;
#endif
        }

        public static byte[] LoadPlayerStore(string filename)
        {
            filename = Path.Combine(Application.persistentDataPath, filename);
            if (!File.Exists(filename))
            {
                return null;
            }

            var bytes = File.ReadAllBytes(filename);
            
            bytes = FileUtils.RC4(bytes, "1234");
            return bytes;
        }

        public static void SavePlayerStore(string filename, byte[] bytes)
        {
            bytes = FileUtils.RC4(bytes, "1234");
            File.WriteAllBytes(Path.Combine(Application.persistentDataPath, filename), bytes);
        }

        public static bool IsUrl(string url)
        {
            var rg = new Regex("(https?|ftp|file)://[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]");
            return rg.IsMatch(url);
        }
    }

}