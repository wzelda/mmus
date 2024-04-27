/*
 *
 * Created: 2017-10-31
 * Author: Jeremy
 * Company: LightPaw
 * 
 */

using BaseNcoding;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;
using XLua;

namespace LPCFramework {
    public class LuaVMManager : Singleton<LuaVMManager>, IManager {
        /// <summary>
        /// 初始化xlua的虚拟机
        /// </summary>
        private LuaEnv m_luaEnv;
        private CSCallLua m_Cs2Lua;

        internal float m_lastGCTime = 0;
        internal const float GCInterval = 1; //Lua GC in every second
        internal float m_lastFullGCTime = 0;
        internal const float FullGCInterval = 60; //Lua GC in every second

        public LuaEnv Lua_Env {
            get {
                return m_luaEnv;
            }
        }

        public CSCallLua CS2Lua {
            get {
                return m_Cs2Lua;
            }
        }

        /// <summary>
        /// 初始化
        /// </summary>
        public void OnInitialize() {
            PreloadLua("Lua",
                () =>
                {
                    if (m_luaEnv == null)
                    {
                        m_luaEnv = new LuaEnv();

                        m_luaEnv.AddBuildin("lpeg", XLua.LuaDLL.Lua.LoadLpeg);
                        m_luaEnv.AddBuildin("rapidjson", XLua.LuaDLL.Lua.LoadRapidJson);
                        m_luaEnv.AddBuildin("protobuf.c", XLua.LuaDLL.Lua.LoadLuaProfobuf);
                    }

                    InitLoader();

                    if (m_Cs2Lua == null)
                    {
                        m_Cs2Lua = new CSCallLua();
                        m_Cs2Lua.Bind();
                        m_Cs2Lua.Initialize();
                    }
                });
        }

        /// <summary>
        /// 初始化lualoader
        /// </summary>
        public void InitLoader () {
            if (m_luaEnv == null) {
                return;
            }

            m_luaEnv.AddLoader (CustomLoader);

            //  后续替换为加密loader
            //m_luaEnv.AddLoader(new LuaLoader("BgIAAACkAABSU0ExAAQAAAEAAQDZvE3rMTExypposdWnVwuWyVGbVvAUSypyzvnQ0ihfqa7KX25Bi8n8RGtBHUdlGUulbmBvaiauB3101NAOojJisT79/BkfhRk4wj3t1srycJi6l0NYcWXCFwWz7MrWYjiKPRbJounndvWUBRiCJYPMIbzgtLpjkPkIxT4fLiYQxA==",
            //     (ref string filepath) =>
            //     {
            //         return ResourceMgr.Instance.LoadLua(filepath);
            //     }));   
        }

        private bool needGC = false;

        public void OnUpdate () {
            if (m_luaEnv == null)
                return;

            m_Cs2Lua.Update ();

            if (needGC) {
                m_luaEnv.GC ();
                needGC = false;
            }

            if (Time.time - m_lastGCTime > GCInterval) {
                m_luaEnv.Tick ();
                m_lastGCTime = Time.time;
                needGC = true;
            }
        }

        public void GC () {
            if (m_luaEnv == null)
                return;

            m_luaEnv.Tick ();
            m_luaEnv.FullGc ();
        }

        public void LuaRelease () {
            if (m_luaEnv == null)
                return;

        }

        public void LuaFullGC () {
            if (m_luaEnv == null)
                return;

            m_luaEnv.FullGc ();
        }

        public void FixedUpdate () {
            if (m_luaEnv == null)
                return;
            //
            //            if (Time.unscaledTime - m_lastFullGCTime > FullGCInterval)
            //            {
            //                m_luaEnv.FullGc();
            //                m_lastFullGCTime = Time.unscaledTime;
            //            }
            m_Cs2Lua.FixedUpdate ();
        }

        public void LateUpdate () {
            if (m_luaEnv == null)
                return;
            m_Cs2Lua.LateUpdate ();
        }
        public void OnApplicationFocus (bool hasFocus) {
            if (m_Cs2Lua != null) {
                if (hasFocus)
                    m_Cs2Lua.OnAppFocus ();
                else
                    m_Cs2Lua.OnAppUnFocus ();
            }
        }
        public void OnApplicationPause (bool hasPause) {
            if (m_Cs2Lua != null) {
                if (hasPause)
                    m_Cs2Lua.OnAppPause ();
                else
                    m_Cs2Lua.OnAppUnPause ();
            }
        }
        public void OnReceiveMsg (ref byte[] msg) {
            if (m_Cs2Lua != null) {
                m_Cs2Lua.OnReceiveMsg (ref msg);
            }
        }

        public static void PreloadLua(string key, System.Action callback)
        {
            Addressables.LoadAssetsAsync<TextAsset>(key, (asset)=> {
                if (asset != null)
                {
                    //Debug.Log("preloaded " + asset.name);
                }
            }).Completed += (opt)=>
            {
                Debug.LogWarning("Preload all");
                if (opt.Status == AsyncOperationStatus.Succeeded)
                {
                    callback();
                }
            };
        }

        /// <summary>
        /// 自定义loader
        /// </summary>
        /// <param name="fileName"></param>
        /// <returns></returns>
        private static byte[] CustomLoader (ref string fileName) {
            fileName = fileName.Replace('.', '/') + ".lua";
            string realPath = string.Format("Lua/{0}", fileName);
            byte[] luaBytes = null;

            var opt = Addressables.LoadAssetAsync<TextAsset>(realPath);
            if (opt.IsDone && opt.Result != null)
            {
                luaBytes = opt.Result.bytes;
                if (luaBytes.Length > 3 && luaBytes[0] == 'a' && luaBytes[1] == 'f' && luaBytes[2] == ')')
                {
                    luaBytes = Base91.Instace.Decode(opt.Result.text);
                    luaBytes = LuaUtils.Decompress(luaBytes, 0, luaBytes.Length);
                }
            }
            else
            {
#if UNITY_EDITOR && XXXX
                realPath = Application.dataPath + "/Lua/" + fileName;

                if (File.Exists(realPath))
                {
                    luaBytes = File.ReadAllBytes(realPath);
                }
#endif
            }

            // 去除UTF-8编码BOM头
            if (luaBytes != null && luaBytes[0] == 0xef && luaBytes[1] == 0xbb && luaBytes[2] == 0xbf)
            {
                Debug.LogWarning("The lua contains bom header: " + fileName);
                var bytes_no_bom = new byte[luaBytes.Length - 3];
                System.Array.Copy(luaBytes, 3, bytes_no_bom, 0, bytes_no_bom.Length);
                luaBytes = bytes_no_bom;
            }

            return luaBytes;
        }

        /// <summary>
        /// 执行Lua脚本
        /// </summary>
        public object[] DoString (string luaString) {
            return m_luaEnv.DoString (luaString);
        }

        /// <summary>
        /// 执行Lua文件
        /// </summary>
        public object[] DoFile (string filename, string chunkName = "chunk", LuaTable env = null) {
            return m_luaEnv.DoString ("require '" + filename + "'", chunkName, env);
        }
        /// <summary>
        /// 调用Lua全局方法中的指定方法
        /// </summary>
        public object[] CallFunction (string funcName, params object[] args) {
            LuaFunction func = m_luaEnv.Global.Get<LuaFunction> (funcName);
            if (func != null) {
                return func.Call (args);
            }
            return null;
        }
        /// <summary>
        /// 绑定C# class, interface, delegate等到lua
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="key"></param>
        /// <returns></returns>
        public T BindToLua<T> (string key) {
            T f = m_luaEnv.Global.Get<T> (key);
            return f;
        }

        public void OnDestruct () {

            if (m_Cs2Lua != null) {
                m_Cs2Lua.OnDestroy ();
            }
            m_Cs2Lua = null;

            if (m_luaEnv != null) {
                m_luaEnv.Tick ();
                m_luaEnv.FullGc ();
                m_luaEnv.Dispose ();
            }

            m_luaEnv = null;

            Debug.Log ("~Lua VM was destroyed!");
        }
    }
}