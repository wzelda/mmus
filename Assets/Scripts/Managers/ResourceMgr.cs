/*
/*
* ==============================================================================
* 
* Created: 2017-4-13
* Author: Jeremy
* Company: LightPaw
* 
* ==============================================================================
*/

using System;
using System.Linq;
using System.Runtime.Serialization.Formatters.Binary;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;
using System.IO;
using System.IO.Compression;
using System.Text;
using System.Threading;
using BaseNcoding;
using FairyGUI;
using UnityEngine.Rendering;
using UnityEngine.SceneManagement;
using Object = UnityEngine.Object;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;
using UnityEngine.ResourceManagement.ResourceLocations;
using UnityEngine.ResourceManagement.ResourceProviders;

namespace LPCFramework
{
    [LuaCallCSharp]
    public class ResourceMgr : SingletonMonobehaviour<ResourceMgr>, IManager
    {
        public static bool showResourceLog = false;

        public static string RemoteURL = "http://localhost:8080";

#if (UNITY_EDITOR && !TEST_DOWNLOAD) || FULL_VERSION
    public static bool IsFullPkg = true;
#else
    public static bool IsFullPkg = false;
#endif
        public static Dictionary<string, AssetBundle> PreLoadABDic = new Dictionary<string, AssetBundle>();

//        public static Dictionary<string,  AssetBundleRef> AvatarABRef = new Dictionary<string, AssetBundleRef>();

        static void Log(Action<object> loghandle, string msg)
        {
            if (showResourceLog)
            {
                if (loghandle != null)
                {
                    loghandle(msg);
                }
            }
        }
        
        static byte[] Decompress(byte[] gzip)
        {
            // Create a GZIP stream with decompression mode.
            // ... Then create a buffer and write into while reading from the GZIP stream.
            using (GZipStream stream = new GZipStream(new MemoryStream(gzip),
                CompressionMode.Decompress))
            {
                const int size = 4096;
                byte[] buffer = new byte[size];
                using (MemoryStream memory = new MemoryStream())
                {
                    int count = 0;
                    do
                    {
                        count = stream.Read(buffer, 0, size);
                        if (count > 0)
                        {
                            memory.Write(buffer, 0, count);
                        }
                    }
                    while (count > 0);
                    return memory.ToArray();
                }
            }
        }

        public class FairyGPackageRef
        {
            public string loadPath;
            public UIPackage package;
            public AsyncOperationHandle<TextAsset> loadOperation;

            class TextureLoadHandle
            {
                public FairyGPackageRef pkgRef;
                public AsyncOperationHandle<Texture> texture;
                public AsyncOperationHandle<Texture> alpha;
                PackageItem item;

                public void Load(string name, string ext, PackageItem item)
                {
                    this.item = item;

                    var alphaAssetKey = string.Format("{0}!a{1}", name, ext);
                    var alphaLocation = Addressables.LoadResourceLocationsAsync(alphaAssetKey, typeof(Texture));

                    texture = Addressables.LoadAssetAsync<Texture>(string.Format("{0}{1}", name, ext));
                    texture.Completed += (h)=>
                    {
                        if (alphaLocation.IsDone)
                        {
                            LoadAlphaTexture(alphaLocation);
                        }
                        else
                        {
                            alphaLocation.Completed += LoadAlphaTexture;
                        }
                    };
                }

                private void LoadAlphaTexture(AsyncOperationHandle<IList<IResourceLocation>> h)
                {
                    if (h.Result.Count > 0)
                    {
                        alpha = Addressables.LoadAssetAsync<Texture>(h.Result[0]);
                        if (alpha.IsDone)
                        {
                            OnAlphaLoad(alpha);
                        }
                        else
                        {
                            alpha.Completed += OnAlphaLoad;
                        }
                    }
                    else
                    {
                        item.texture.Reload(texture.Result, null);
                        pkgRef.OnItemComplete();
                    }
                }

                private void OnAlphaLoad(AsyncOperationHandle<Texture> h)
                {
                    item.texture.Reload(texture.Result, h.Result );
                    pkgRef.OnItemComplete();
                }
            }

            Dictionary<PackageItem, TextureLoadHandle> textures = new Dictionary<PackageItem, TextureLoadHandle>();
            Dictionary<PackageItem, AsyncOperationHandle<AudioClip>> audios = new Dictionary<PackageItem, AsyncOperationHandle<AudioClip>>();
            public int completeCount;
            public Action completeAction;

            public FairyGPackageRef OnComplete(Action action)
            {
                if (completeCount >= textures.Count + audios.Count + 1)
                {
                    action();
                }
                else
                {
                    completeAction += action;
                }
                return this;
            }

            public void OnItemComplete()
            {
                completeCount++;

                if (completeAction != null && completeCount == textures.Count + audios.Count + 1)
                {
                    completeAction();
                }
            }

            public void LoadResource(string name, string extension, System.Type type, PackageItem item)
            {
                if (item.type == PackageItemType.Atlas)
                {
                    if (!textures.ContainsKey(item))
                    {
                        var handle = new TextureLoadHandle();
                        textures.Add(item, handle);
                        handle.pkgRef = this;
                        handle.Load(name, extension, item);
                    }
                }
                else if (item.type == PackageItemType.Sound)
                {
                    if (!audios.ContainsKey(item))
                    {
                        var handle = Addressables.LoadAssetAsync<AudioClip>(name + extension);
                        audios.Add(item, handle);
                        handle.Completed += (opt) =>
                        {
                            if (item.audioClip == null)
                            {
                                item.audioClip = new FairyGUI.NAudioClip(opt.Result);
                            }
                            else
                            {
                                item.audioClip.nativeClip = opt.Result;
                            }
                            OnItemComplete();
                        };
                    }
                }
            }

            public void Dispose()
            {
                foreach (var h in textures)
                {
                    if (h.Value.alpha.IsValid())
                    {
                        Addressables.Release(h.Value.alpha);
                    }
                    if (h.Value.texture.IsValid())
                    {
                        Addressables.Release(h.Value.texture);
                    }
                }
                textures.Clear();
                foreach (var h in audios)
                {
                    if (h.Value.IsValid())
                    {
                        Addressables.Release(h.Value);
                    }
                }
                audios.Clear();
            }
        }

        public Dictionary<string, FairyGPackageRef> FairyPackageCache = new Dictionary<string, FairyGPackageRef>();

        /// <summary>
        /// UI比较特殊，有FairyGUI做管理所以资源不走abmgr流程，单独提2个接口
        /// </summary>
        /// 
        [LuaCallCSharp]
        public FairyGPackageRef LoadUIPkg(string uipath, Action<string> cb)
        {
            FairyGPackageRef pkgReference = null;

            if (FairyPackageCache.TryGetValue(uipath, out pkgReference))
            {
                if (showResourceLog)
                    Debug.LogFormat("<color=#33FFFF>Get UIPackage{0} From Cache</color>", uipath);

                if (pkgReference.package != null)
                {
                    pkgReference.package.ReloadAssets();
                }

                pkgReference.OnComplete(() =>
                {
                    cb(uipath);
                    cb = null;
                });
            }
            else
            {
                if (showResourceLog)
                    Debug.LogFormat("<color=#33FFFF>Get UIPackage{0}</color>", uipath);
                pkgReference = new FairyGPackageRef();

                FairyPackageCache.Add(uipath, pkgReference);
                // 需要reload,先检测是不是ab过来的
                pkgReference.loadOperation = Addressables.LoadAssetAsync<TextAsset>(uipath + "_fui.bytes");
                pkgReference.loadOperation.Completed += (opt) =>
                {
                    //预先算上二进制fgui文件
                    pkgReference.completeCount = 1;
                    if (opt.Result == null)
                    {
                        pkgReference.OnComplete(() =>
                        {
                            cb(null);
                            cb = null;
                        });
                    }
                    else
                    {
                        pkgReference.package = UIPackage.AddPackage(opt.Result.bytes, uipath, pkgReference.LoadResource);

                        pkgReference.package.LoadAllAssets(); // ReloadAssets();

                        pkgReference.OnComplete(() =>
                        {
                            if (showResourceLog)
                                Debug.LogFormat("<color=#33FFFF>{0}</color>", uipath);
                            cb(uipath);
                            cb = null;
                        });
                    }
                };
            }

            return pkgReference;
        }

        [LuaCallCSharp]
        public void UnLoadUI(string packpath, bool destroyRes)
        {
#if UNITY_EDITOR
            Log(DebugLog.LogError, "rem package is " + packpath + " des is " + destroyRes);
#endif

            FairyGPackageRef pcache;
            if (FairyPackageCache.TryGetValue(packpath, out pcache))
            {
                if (pcache != null)
                {
#if UNITY_EDITOR
                    Log(DebugLog.LogError, "UI Package UnloadAssets:" + packpath);
#endif

                    if (destroyRes)
                    {
                        if (!StageEngine.beingQuit)
                        {
                            UIPackage.RemovePackage(pcache.package.id);
                        }

                        FairyPackageCache.Remove(packpath);
#if UNITY_EDITOR
                        Log(DebugLog.LogError, "从缓存删除UI Package:" + packpath);
#endif
                        pcache.Dispose();
                    }
                }
            }
        }
        
        [LuaCallCSharp]
        public void UnLoadFairyPackage(string packpath, bool destroyPkg)
        {
            UnLoadUI(packpath, destroyPkg);
        }

        public void ClearFairyCache()
        {
            foreach (var kv in FairyPackageCache)
            {
                kv.Value.Dispose();
            }
            FairyPackageCache.Clear();
            UIPackage.RemoveAllPackages();
        }

        public AsyncOperationHandle<SceneInstance> LoadSceneAdditive(string sceneName, Action<Scene> callback)
        {
            var handle = Addressables.LoadSceneAsync(sceneName, LoadSceneMode.Additive, true);
            handle.Completed += (o) =>
            {
                callback(o.Result.Scene);
            };
            return handle;
        }

        public AsyncOperationHandle<Object> Load(string resName, Action<Object> callback)
        {
            var handle = Addressables.LoadAssetAsync<Object>(resName);
            handle.Completed += (o) =>
            {
                callback(o.Result);
            };
            return handle;
        }

        public AsyncOperationHandle<List<Object>> Load(List<string> locations, Action<List<Object>> callback)
        {
            var handle = Addressables.LoadAssetAsync<List<Object>>(locations);
            handle.Completed += (o) =>
            {
                callback(o.Result);
            };
            return handle;
        }

        public void Release(AsyncOperationHandle<Object> handle)
        {
            if (handle.IsValid())
            {
                Addressables.Release(handle);
            }
        }
        
        public void Release(AsyncOperationHandle<List<Object>> handle)
        {
            if (handle.IsValid())
            {
                Addressables.Release(handle);
            }
        }
        public void UnloadScene(Scene scene, Action callback)
        {
            if (scene.isLoaded)
            {
                SceneManager.UnloadSceneAsync(scene).completed += (o) =>
                {
                    if (callback != null)
                    {
                        callback();
                    }
                };
            }
            else
            {
                if (callback != null)
                {
                    callback();
                }
            }
        }

        public void LuaRelease()
        {
            LuaVMManager.Instance.LuaRelease();
        }

        public void LuaGC()
        {
            LuaVMManager.Instance.LuaFullGC();
        }

        public void OnInitialize()
        {
            if (texpool == null)
                texpool = new Dictionary<string,NTexture>();

            if (loadTask == null)
                loadTask = new List<CacheTextureItem>();

            //FairyGUI.UIObjectFactory.SetLoaderExtension(typeof(GameUITextureLoader));
#if UNITY_EDITOR
            InitResHash();
#elif !FULL_VERSION
            //预加载materials.ab
            //PreLoadAssetBundle("materials");
#endif
        }


        private void InitResHash()
        {
            if (hasInitHash)
                return;

            ResourcesHash tempHash = new ResourcesHash();
/* 
#if UNITY_EDITOR
            string respath = Application.dataPath + "/Resources";
            GetResourcesFileInfo(new DirectoryInfo(respath), tempHash.ResNameList);

            FileStream fs = new FileStream(respath + "/res.txt", FileMode.Create);
            BinaryFormatter bf = new BinaryFormatter();
            bf.Serialize(fs, tempHash);
            fs.Close();
#else
            TextAsset res = Resources.Load("res") as TextAsset;
            MemoryStream ms = new MemoryStream(res.bytes);
            BinaryFormatter bf = new BinaryFormatter();
            tempHash = (ResourcesHash)bf.Deserialize(ms);
            ms.Close();            
#endif

            foreach (var resname in tempHash.ResNameList)
            {
                if (!internalResHash.Contains(resname))
                {
                    //Debug.LogError(resname);
                    internalResHash.Add(resname);
                }
            }
*/
            tempHash = null;
            hasInitHash = true;
        }

        public bool ContainInternalResurces(string resourcePath)
        {
            return internalResHash.Contains(resourcePath);
        }


        private void GetResourcesFileInfo(DirectoryInfo dirInfo, List<string> ResMap)
        {
            var dirinfos = dirInfo.GetDirectories().Where(dir => dir.Name.StartsWith(".") == false);
            var dirfiles = dirInfo.GetFiles();
            foreach (var item in dirinfos)
            {
                GetResourcesFileInfo(item, ResMap);
            }

            foreach (var item in dirfiles)
            {
                var key = item.FullName;
                try
                {
                    if (key.EndsWith(".meta"))
                        continue;

                    //Debug.LogWarning("[Res] :" + key);

                    string fileabsolute = item.FullName.Replace('\\', '/')
                        .Replace(Application.dataPath + "/Resources/", "");

                    //Debug.LogWarning("[Res 2] :" + fileabsolute);

                    fileabsolute = FileUtils.GetFileNamePathWithoutExtention(fileabsolute);

                    //Debug.LogWarning("[Res 3] :" + fileabsolute);

                    if (!ResMap.Contains(fileabsolute))
                    {
                        ResMap.Add(fileabsolute);
                    }
                }
                catch (System.Exception ex)
                {
                    Log(DebugLog.LogError, "[Error] :" + ex.StackTrace + " " + ex.Message);
                    continue;
                }
            }
        }

        public void OnUpdate()
        {
            UpdatePackageRef();
        }

        public void OnDestruct()
        {
            GamePools.ClearAll(true);
            EffectManager.Instance.ReleaseAllCache();
            
//            foreach (var ab in AvatarABRef)
//            {
//                if (ab.Value != null && ab.Value.mainBundle != null)
//                {
//                    ab.Value.mainBundle.Unload(true);
//                }
//            }   
//            AvatarABRef.Clear();
            
            foreach (var ab in PreLoadABDic)
            {
                if (ab.Value != null)
                {
                    ab.Value.Unload(false);
                }
            }   
            PreLoadABDic.Clear();
        }

        public static void Destruct()
        {
            if (_S != null)
            {
                _S.OnDestruct();
                Destroy(_S);
            }
        }

        private bool hasInitHash = false;
        HashSet<string> internalResHash = new HashSet<string>();

        float FreeTick = 0;
        float FreeCacheTime = 30; //多久时间清理一次图片，切场景时必定清理一次

        float packageTick = 0;
        float packageLifeTime = 15; //多久清理一次没用的UI包

        List<CacheTextureItem> loadTask;
        Dictionary<string, NTexture> texpool;

        public delegate void LoadCompleteCallback(FairyGUI.NTexture texture);

        public delegate void LoadErrorCallback(string error);

        bool isDoLoadTask = false;

        private void UpdatePackageRef()
        {
            //packageTick += Time.unscaledDeltaTime;
            //if (packageTick >= packageLifeTime)
            //{
            //    foreach (var itempair in FairyPackageCache)
            //    {
            //        var pkgRef = itempair.Value;
            //        //有标签表明需要卸载了，并且还没有被卸载
            //        if (pkgRef.isRemove && pkgRef.needReload == false)
            //        {
            //            float passtime = Time.realtimeSinceStartup - pkgRef.removeTime;
            //            if (passtime > packageLifeTime)
            //            {
            //                // 卸载后再加上标签标明需要reload，这样其他引用不需要执行reload                            
            //                pkgRef.package.UnloadAssets();
            //                if (showResourceLog)
            //                    UnityEngine.Debug.LogError("Unload Asset  UIPackage :" + pkgRef.package.name);
            //                pkgRef.needReload = true;
            //                pkgRef.hasReload = false;
            //            }
            //        }
            //    }
            //}
        }

        public void InitFairyGuiDefaultClickAudio(string respath)
        {
            Addressables.LoadAssetAsync<AudioClip>(respath).Completed += (h) =>
            {
                if (h.IsDone && h.Result != null)
                {
                    FairyGUI.UIConfig.buttonSound = new FairyGUI.NAudioClip(h.Result);
                }
            };
        }

        internal class CacheTextureItem
        {
            public string url;
            public LoadCompleteCallback onSuccess;
            public LoadErrorCallback onFail;
            public FairyGUI.GLoader gLoader;

            public void SetTexture(FairyGUI.NTexture texture)
            {
                if (onSuccess != null && gLoader != null && url == gLoader.url)
                    onSuccess(texture);
            }
        }

        /*
        internal class GameUITextureLoader : FairyGUI.GLoader
        {
            protected override void LoadExternal()
            {
			    //Instance.LoadUITexture(this.url, OnLoadSuccess, OnLoadFail, this);
                TextureManager.GetTexture(this.url, OnLoadSuccess, OnLoadFail);
            }

            protected override void FreeExternal(FairyGUI.NTexture texture)
            {
                if (texture.nativeTexture == null)
                {
                    Debug.LogWarning("Only Happen In Editor");
                    return;
                }

#if UNITY_EDITOR
                Log(DebugLog.LogError, "free texture " + texture.nativeTexture.name);
#endif
                TextureManager.Return(texture);
                //texture.refCount--;                
                //Debug.LogWarning("free texture " + texture.nativeTexture.name + " cur count is :" + texture.refCount);
            }

            void OnLoadSuccess(FairyGUI.NTexture texture)
            {
                if (string.IsNullOrEmpty(this.url))
                    return;

#if UNITY_EDITOR
                Log(DebugLog.LogError, "load UI Texture :" + this.url + " suc: " + texture.nativeTexture.name);
#endif
                this.onExternalLoadSuccess(texture);
            }

            void OnLoadFail(string error)
            {
#if UNITY_EDITOR
                Log(DebugLog.LogError, "load UI Texture :" + this.url + " failed: " + error);
#endif
                this.onExternalLoadFailed();
            }
        }
        */
    }

    [System.Serializable]
    public class ResourcesHash
    {
        public List<string> ResNameList = new List<string>();
    }

}
