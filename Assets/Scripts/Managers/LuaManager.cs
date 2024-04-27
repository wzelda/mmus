using System;
using UnityEngine;
using System.Collections;
using System.IO;
using XLua;

namespace LPCFramework
{
    /// <summary>
    /// 游戏Lua逻辑管理器
    /// </summary>    
    [LuaCallCSharp]
    public class LuaManager : SingletonMonobehaviour<LuaManager>, IManager
    {
        //热更标识 1005 4
        public static bool HotFixSign_1005_4 = true;
        
        
        
        // 是否已初始化
        protected static bool m_isInitialized = false;
        
        public bool Test = false;


        public int _gcBattleTimes = 4;
        /// <summary>
        /// 初始化
        /// </summary>
        public void OnInitialize()
        {
            _gcBattleTimes = SystemInfo.systemMemorySize >= 2048 ? 10 : 4;

           if (m_isInitialized)
           {
               //Debug.LogError("ReInit!!!!!!!!");
               m_isInitialized = false;
               OnDestruct();
               Test = true;                
           
               StartCoroutine(LateInit());
               return;
           }
           // 检查资源
           //CheckExtractResource();
           InitLuaManagers();  
        }

        IEnumerator LateInit()
        {
            yield return new WaitForSecondsRealtime(0.5f);;
            InitLuaManagers();
        }

        /// <summary>
        /// 跟lua绑定的逻辑管理器
        /// </summary>
        private void InitLuaManagers()
        {
            if (NetworkManager.Instance != null)
            {
                NetworkManager.Instance.OnInitialize();                
            }

            if (GamePoolManager.Instance != null)
                GamePoolManager.Instance.OnInitialize();

            //if (SceneLoader.Instance != null)
            //    SceneLoader.Instance.OnInitialize();

            if (AudioManager.Instance != null)
            {
                AudioManager.Instance.OnInitialize();
            }

            if (TouchManager.Instance != null)
            {
                TouchManager.Instance.OnInitialize();
            }

            if (EasyTouchManager.Instance != null)
            {
                EasyTouchManager.Instance.OnInitialize();
            }
            //日志管理
            LogManager.Instance.OnInitialize();

            EffectManager.Instance.OnInitialize();

            ResourceMgr.Instance.OnInitialize();
    
            if (LuaVMManager.Instance != null)
            {
                LuaVMManager.Instance.OnInitialize();                
            }
            
            // 初始化游戏逻辑
            OnInitializeGameLogic();
        }
        
        /// <summary>
        /// lua逻辑加载
        /// </summary>
        private void OnInitializeGameLogic()
        {
            m_isInitialized = true;
        }
        
        void Update()
        {
//            var watch = LuaUtils.GetCodeWatch();
//            watch.Reset();
//            watch.Start();
            if (!m_isInitialized)
                return;

            NetworkManager.Instance.OnUpdate();
            
            AudioManager.Instance.OnUpdate();

            LuaVMManager.Instance.OnUpdate();

            ResourceMgr.Instance.OnUpdate();
            
            //TextureManager.OnUpdate();
            
            EffectManager.Instance.OnUpdate();
            
            TouchManager.Instance.OnUpdate();
            
            EasyTouchManager.Instance.OnUpdate();
            
            GameLogicMgr.Instance.LogicUpdate();

            GraphicManager.Instance.OnUpdate();
            
            CompassUtils.Instance.Update();
        }
        
        void FixedUpdate()
        {
            if (!m_isInitialized)
                return;
            
            LuaVMManager.Instance.FixedUpdate();
        }
        void LateUpdate() {
            if (!m_isInitialized)
                return;
            LuaVMManager.Instance.LateUpdate();
        }
        void OnApplicationFocus(bool hasFocus)
        {
            if (!m_isInitialized)
                return;

            LuaVMManager.Instance.OnApplicationFocus(hasFocus);

            if (hasFocus)
            {
                AudioManager.Instance.ResumeBGAudio();
            }
            else
            {
                AudioManager.Instance.PauseBGAudio();
            }
        }

        void OnApplicationPause(bool hasPause)
        {
            if (!m_isInitialized)
                return;

            LuaVMManager.Instance.OnApplicationPause(hasPause);
            
            if (!hasPause)
            {
                AudioManager.Instance.ResumeBGAudio();
            }
            else
            {
                AudioManager.Instance.PauseBGAudio();
            }
        }

        public void OnReceiveMsg(ref byte[] msg)
        {
            if (!m_isInitialized)
                return;
                
            LuaVMManager.Instance.OnReceiveMsg(ref msg);
        }

        /// <summary>
        /// 引擎自带函数-析构
        /// </summary>
        void OnDestroy()
        {
            OnDestruct();
        }

        /// <summary>
        /// 逻辑更新
        /// </summary>
        public void OnUpdate()
        {
  
        }

        private float lastGcTime;
        
        public int GC_INTERVAL_ON_OOM = 10;
        private void OnLowMemory()
        {
            Debug.LogError("收到低内存警报");

            if (Time.realtimeSinceStartup - lastGcTime > GC_INTERVAL_ON_OOM)
            {
                GamePools.ClearAll(true);
                EffectManager.Instance.ReleaseAllCache();
                //TextureManager.ClearCache();
                LuaVMManager.Instance.GC();
                Resources.UnloadUnusedAssets();
                System.GC.Collect();
                lastGcTime = Time.realtimeSinceStartup;
            }
        }

        // 仅供gm命令调用
        public void GmClearPoolAndPrint()
        {
            GamePools.ClearAll(false);
            EffectManager.Instance.ReleaseAllCache();
            //TextureManager.ClearCache();
            LuaVMManager.Instance.GC();

            Resources.UnloadUnusedAssets();
            System.GC.Collect();
            
            GamePools.Instance.printContent();
            EffectManager.Instance.printContent();
            //TextureManager.printContent();
        }

        public void ClearResource(Action cb)
        {
            StartCoroutine(ClearResourceAsync(cb));
        }

        private int ClearTimes = 0;
        
        
        IEnumerator ClearResourceAsync(Action cb)
        {
            ClearTimes++;
            if (ClearTimes % _gcBattleTimes == 0)
            {
                LuaVMManager.Instance.LuaFullGC();
                yield return Resources.UnloadUnusedAssets();
            } 
            else if (ClearTimes % (_gcBattleTimes/2) == 0)
            {
                LuaVMManager.Instance.GC();
            }
            
            if (cb != null)
            {
                cb();
            }
            
            yield break;
        }
        
        /// <summary>
        /// 析构函数
        /// </summary>
        public void OnDestruct()
        {
            // 停止所有协同
            //StopAllCoroutines();

            NetworkManager.Instance.OnDestruct();

            AudioManager.Destruct();

            EffectManager.Instance.OnDestruct();
            
            GamePoolManager.Instance.OnDestruct();

            LogManager.Destruct();

            AsyncLoader.Destruct();

            EasyTouchManager.Destruct();
            
            ResourceMgr.Destruct();

            try
            {
              LuaVMManager.Instance.OnDestruct();
            }
            catch (Exception e)
            {
                Debug.LogError(e.ToString());
            }

            LuaVMManager.Instance = null;
            
            //清除指南针工具方法
            CompassUtils.Instance.ClearActions();

            Debug.Log("~LuaManager was destroyed!");

        }
    }
}