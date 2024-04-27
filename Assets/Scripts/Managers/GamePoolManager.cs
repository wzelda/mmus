using System;
using UnityEngine;
using UnityEngine.AddressableAssets;
using XLua;
namespace LPCFramework
{
    /// <summary>
    /// 对象池管理器
    /// </summary>
    [LuaCallCSharp]
    public class GamePoolManager : Singleton<GamePoolManager>
    {
        private GameObject m_poolManagerRoot;
        private GameObject m_poolManagerBaseRoot;
        public void OnInitialize()
        {
            if(m_poolManagerRoot == null)
            {
                m_poolManagerRoot = new GameObject("PoolManagerRoot");
                UnityEngine.Object.DontDestroyOnLoad(m_poolManagerRoot);
            }
            if (m_poolManagerBaseRoot == null)
            {
                m_poolManagerBaseRoot = new GameObject("Base");
                m_poolManagerBaseRoot.transform.parent = m_poolManagerRoot.transform;
                UnityEngine.Object.DontDestroyOnLoad(m_poolManagerRoot);
            }
        }
        
        public GamePool GetPool(string poolName)
        {
            return GamePools.Instance.GetPool(poolName, m_poolManagerRoot.transform);
        }

        /// <summary>
        /// 获取角色 要判断角色的高低模，角色是否存在
        /// </summary>
        public void GetAvatarFromPool(string poolName, string resPath, Action<GameObject> callback, Vector3 pos, bool loadAsync)
        {
            
           if  (TryGetFromPoolIfExists(poolName, resPath, callback))
           {
               return;
           }

//           SingleFile fileStatus = BGDownloadMgr.GetResourceStatus(resPath);
//           if (fileStatus == null)
//           {
//               Debug.LogErrorFormat("竟然要加载一个不存在的avatar: {0}", resPath);
////               return;
//           }
//
//           if (fileStatus == null || fileStatus.isInResources || fileStatus.CheckHasDownloaded())
//           {
//               GetFromPool(poolName, resPath, callback, pos, loadAsync);
//               return;
//           }
//           
//           if (resPath.Contains("High/"))
//           {
//               resPath = resPath.Replace("High/", "Low/");       
//               poolName = "ActorLow";
//           } else if (resPath.Contains("Mid/"))
//           {
//               resPath = resPath.Replace("Mid/", "Low/");
//               poolName = "ActorLow";
//           }
           //再获取低模
           
            GetFromPool(poolName, resPath, callback, pos, loadAsync);
        }
        
        // 尝试从池子里获取, 如果不行, 则返回false
        public bool TryGetFromPoolIfExists(string poolName,string resPath, Action<GameObject> callback)
        {
            var pool = GamePools.Instance.GetPool(poolName, m_poolManagerRoot.transform);

            GameObject gameObject = pool.TryGetFromPool(resPath, callback);
            if (gameObject != null)
            {
                gameObject.SetActive(true);
                callback(gameObject);
                return true;
            }

            return false;
        }

        /*
        bool tryCheckAndSetLowObj(string poolName, string resPath,Action<GameObject> callback,  Vector3 pos, bool loadAsync, bool hasAB = false)
        {
//            Debug.LogError("tryCheckAndSetLowObj = " + resPath);
            if (hasAB)
            {
                return false;
            }
            if (!(resPath.Contains("High/Avatar") || resPath.Contains("Mid/Avatar")))
            {
                return false;
            }
            
            //先获取高中模型
            if  (TryGetFromPoolIfExists(poolName, resPath, callback))
            {
//                Debug.LogError("TryGetFromPoolIfExists success ");
                return true;
            }

            SingleFile fileStatus = BGDownloadMgr.GetResourceStatus(resPath);
            if (fileStatus == null)
            {
                Debug.LogErrorFormat("竟然要加载一个不存在的obj: {0}", resPath);
                return false;
            }

            if (fileStatus.isInResources || fileStatus.CheckHasDownloaded())
            {
                GetFromPool(poolName, resPath, callback, pos, loadAsync, true);
                return true;
            }
           
            var lowPath = resPath;
            if (lowPath.Contains("High/"))
            {
                lowPath = lowPath.Replace("High/", "Low/");       
            } else if (lowPath.Contains("Mid/"))
            {
                lowPath = lowPath.Replace("Mid/", "Low/");
            }

            SingleFile lowFileStatus = BGDownloadMgr.GetResourceStatus(lowPath);
            if (lowFileStatus != null && (lowFileStatus.isInResources || lowFileStatus.CheckHasDownloaded()))
            {
                GetFromPool(poolName, lowPath, callback, pos, loadAsync, true);
                return true;
            }

            return false;
        }
        */

        // 从池子里获取, 如果不存在, 则去加载
        public void GetFromPool(string poolName, string resPath, Action<GameObject> callback, Vector3 pos, bool loadAsync, bool hasAB = false)
        {
//            if (tryCheckAndSetLowObj(poolName, resPath, callback, pos, loadAsync, hasAB))
//            {
//                return;
//            }
            var pool = GamePools.Instance.GetPool(poolName, m_poolManagerRoot.transform);

            GameObject poolObj = pool.TryGetFromPool(resPath, callback);

            if (poolObj == null)
            {
                bool loading = false;
                PrefebContainer prefebContainer;
                if (!GamePools.Instance.prefebCache.TryGetValue(resPath, out prefebContainer))
                {
                    prefebContainer = new PrefebContainer(resPath, pool.parentRoot);
                    GamePools.Instance.prefebCache.Add(resPath, prefebContainer);
                }
                else
                {
                    loading = true;
                }
                prefebContainer.createOrQueue(pos, Quaternion.identity, null, (obj, gameObject, destroyCallback) =>
                {
                    pool.SaveObject(resPath, gameObject, obj, destroyCallback, callback);
                    
                    if (callback != null)
                        callback(gameObject);
                    callback = null;
                });

                if (!loading)
                {
                    if (pool.isPermanent)
                    {
                        // 如果是永久池, 则直接清掉ab    
                        Addressables.LoadAssetAsync<GameObject>(resPath).Completed += (h) =>
                        {
                            prefebContainer.setPrefeb(h.Result, null);

                            if (!GamePools.Instance.prefebCache.Remove(resPath))
                            {
                                Debug.LogErrorFormat("GamePool 竟然remove prefebContainer失败");
                            }
                        };                    
                    }
                    else
                    {
                        Addressables.LoadAssetAsync<GameObject>(resPath).Completed += (h) =>
                        {
                            prefebContainer.setPrefeb(h.Result, ()=>
                            {
                                Addressables.Release(h);
                            });

                            if (!GamePools.Instance.prefebCache.Remove(resPath))
                            {
                                Debug.LogErrorFormat("GamePool 竟然remove prefebContainer失败");
                            }
                        };
                    }
                }
                
            }
            else
            { 
                poolObj.SetActive(true);
                poolObj.transform.position = pos;
                if (callback != null)
                    callback(poolObj);
                callback = null;
            }
        }

        // 不需要提供poolName
        public void ReturnToPool(string poolName, GameObject go)
        {
            ReturnToPool(go);
        }

        public void ReturnToPool(GameObject go)
        {
             if (go == null)
            {
                return;
            }

             GamePoolNameTag nameTag = go.GetComponent<GamePoolNameTag>();

             if (nameTag == null)
             {
                 Debug.LogError("入池的对象竟然没有GamePoolNameTag component");
                 GameObject.Destroy(go);
                 return;
             }

             if (m_poolManagerRoot == null)
            {
                GameObject.Destroy(go);
                return;
            }

            var pool = GamePools.Instance.GetPool(nameTag.PoolName, m_poolManagerRoot.transform);
            go.SetActive(false);
            pool.ReturnToPool(nameTag);
        }

        public void OnDestruct()
        {
            GamePools.ClearAll();
        }

        public string GetResNameByPath(string resPath)
        {
            if (string.IsNullOrEmpty(resPath))
            {
                return null;
            }
            else
            {
                //路径以‘/’标记
                return System.IO.Path.GetFileNameWithoutExtension(resPath);
            }
        }

        private string GetPrefabNameByInstanceName(string name)
        {
            int idx = name.IndexOf("(Clone)");
            name = name.Substring(0, idx);
            return name;
        }
    }
}