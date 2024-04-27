using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;
using System.Threading;
using XLua;
using Object = UnityEngine.Object;
using UnityEngine.AddressableAssets;

namespace LPCFramework
{
    /// <summary>
    /// 特效管理类
    /// </summary>
    [LuaCallCSharp]
    public class EffectManager : Singleton<EffectManager>, IManager
    {
        
        // 每个列表里, first都是active的, last都是inactive的, 什么都有
        private readonly Dictionary<string, LinkedList<EffectItem>> cache = new Dictionary<string, LinkedList<EffectItem>>();

        // key是路径
        private readonly Dictionary<string, PrefebContainer> prefebCache = new Dictionary<string, PrefebContainer>();
        
        private GameObject root;
        
        
        #region Common

        public int OLD_REMOVE_SECONDS = 60;
        
        // 每个特效最多缓存18个
        public int MAX_CACHE_EACH = 18;
        
        public DateTime updateTime = DateTime.Now;

        private bool isInBattle;
        

#if UNITY_EDITOR
        private Thread mainThread;
#endif

        public void OnInitialize()
        {
            if (root == null)
            {
                root = new GameObject("EffectManagerRoot");
                UnityEngine.Object.DontDestroyOnLoad(root);
                
#if UNITY_EDITOR
                mainThread = Thread.CurrentThread;
#endif
            }
            
            var memory = SystemInfo.systemMemorySize;
            if (memory >= 6000)
            {
                OLD_REMOVE_SECONDS = OLD_REMOVE_SECONDS + 120;
            } else if (memory >= 3000)
            {
                OLD_REMOVE_SECONDS = OLD_REMOVE_SECONDS + 60;
            }
        }

        private LinkedListNode<EffectItem> node;
        private EffectItem firstItem;
        private LinkedListNode<EffectItem> nextNode;
        private EffectItem item;
        private int count;
        private int toRemoveCount;
        private DateTime deadTime;

        private float deltaTime;
        public void OnUpdate()
        {
            /* if (DateTime.Now.Subtract(updateTime).TotalMilliseconds < 1000)
            {
                return;
            }
            updateTime = DateTime.Now;*/
            deadTime = DateTime.Now.AddSeconds(-OLD_REMOVE_SECONDS);
            deltaTime = Time.deltaTime;
            foreach (var list in cache.Values)
            {
                count = list.Count;
                if (count == 0)
                {
                    continue;
                }

                node = list.First;

                firstItem = node.Value;

                toRemoveCount = count - MAX_CACHE_EACH; // 需要移除的个数
                
                for (int i = 0; i < count; i++)
                {
                    item = node.Value;
                    nextNode = node.Next;

                    if (item.destroyed)
                    {
                        Debug.LogError("竟然有一个已经destroy的特效在池子里");
                    }
                    
                    if (item.isPoolActive && item.gameObject != null)
                    {
                        if (item.UpdateItem(deltaTime))
                        {
                            // 死掉了
                            list.Remove(node);

                            if (toRemoveCount > 0)
                            {
                                item.Dispose();
                                toRemoveCount--;
                            }
                            else
                            {
                                poolEffectItem(item);
                            
                                list.AddLast(node);
                            }
                        } 
                    }
                    else
                    {
                        if (isInBattle && item.gameObject != null)
                        {
                            break;
                        }
                        // 死掉了的, 看下剩余时间
                        if (item.gameObject == null || item.lastUseTime <= deadTime)
                        {
                            list.Remove(node);
                            item.Dispose();
                            toRemoveCount--;
                        }
                        else
                        {
                            break; // 后续的都是没过期的
                        }
                    }

                    node = nextNode;
                }

                if (list.Count == 0)
                {
                    destroyPrefeb(firstItem);
                }
            }
        }

        private void poolEffectItem(EffectItem item)
        {
            item.isPoolActive = false;
            item.gameObject.transform.parent = root.transform;
            item.lastUseTime = DateTime.Now;
        }
        
        public void OnDestruct()
        {
            foreach (var list in cache.Values)
            {
                if (list.Count == 0)
                {
                    continue;
                }

                EffectItem lastItem = list.Last.Value;

                do
                {
                    EffectItem item = list.Last.Value;
                    item.Dispose();
                    list.RemoveLast();
                } while (list.Count > 0);

                destroyPrefeb(lastItem);
            }
            
            cache.Clear();
        }

        /// <summary>
        /// 创建一个特效
        /// </summary>
        /// <param name="fxInfo"></param>
        /// <param name="position"></param>
        /// <param name="rotation"></param>
        /// <param name="finishLoad"></param>
        public void CreateFx(LuaTable fxConfig, Vector3 position, Quaternion rotation, Action<EffectItem> callback,bool loadAsync)
        {
#if UNITY_EDITOR
            if (Thread.CurrentThread != mainThread)
            {
                Debug.LogError("竟然不是从主线程调用CreateFx");
            }
#endif
            /* if (callback == null)
            {
                Debug.LogError("CreateFx竟然没有callback");
            } */
            
            EffectInfo fxInfo = new EffectInfo(fxConfig);
            string resPath = fxInfo.path;
            string resId = fxInfo.resName;

            LinkedList<EffectItem> list;

            if (cache.TryGetValue(resId, out list) && list.Count > 0)
            {
                var node = list.Last;
                EffectItem last = node.Value;
                if (last.isPoolActive || last.destroyed || last.gameObject == null)
                {
                    if (last.destroyed || last.gameObject == null)
                    {
                        Debug.LogError("池子里竟然有已经destroy的特效");
                    }
                    // 都是active, 新建一个

                    GameObject gameObject = Object.Instantiate(last.prefeb, position, rotation, root.transform) as GameObject;
                    
                    EffectItem item = DealNewEffectItem(gameObject, fxInfo, position, rotation, callback);
                    item.prefeb = last.prefeb;
                    item.destroyPrefabCallback = last.destroyPrefabCallback;
                    item.isPoolActive = true;
                    list.AddFirst(item);
                }
                else
                {
                    // 不active
                    last.isPoolActive = true;
                    list.Remove(node);
                    list.AddFirst(node);
                    
                    DealEffectItem(last, position, rotation, callback);
                }
            }
            else
            {
                //判断是否要替换高中模
//                if (TryGetEffectLow(fxConfig, position, rotation, callback,loadAsync))
//                {
//                    return;
//                }
                if (list == null)
                {
                    list = new LinkedList<EffectItem>();
                    cache.Add(resId, list);
                }

                bool loading = false;
                PrefebContainer prefebContainer;
                if (!prefebCache.TryGetValue(resPath, out prefebContainer))
                {
                    prefebContainer = new PrefebContainer(resPath, root.transform);
                    prefebCache.Add(resPath, prefebContainer);
                }
                else
                {
                    loading = true;
                }
                
                prefebContainer.createOrQueue(position, rotation, root.transform, (prefeb, gameObject, destroyCallback) =>
                {
                    EffectItem item = DealNewEffectItem(gameObject, fxInfo, position, rotation, callback);
                    item.prefeb = prefeb;
                    item.destroyPrefabCallback = destroyCallback;
                    item.isPoolActive = true;
                    list.AddFirst(item);
                });

                if (!loading)
                {
                    Addressables.LoadAssetAsync<GameObject>(resPath).Completed += (h) =>
                    {
                        var res = h.Result;
                        if (res == null)
                        {
                            Debug.LogErrorFormat("资源竟然不存在: {0}", resPath);
                            res = new GameObject("Fake Empty");
                        }
                        
                        prefebContainer.setPrefeb(res, ()=>
                        {
                            Addressables.Release(h);
                        });

                        if (!prefebCache.Remove(resPath))
                        {
                            Debug.LogErrorFormat("竟然EffectManager remove Prefeb Container失败了");
                        }
                    };
                }
            }
        }
        /// <summary>
        /// 判断是否是高中模，替换成低模
        /// </summary>
        /// <param name="fxConfig"></param>
        /// <param name="position"></param>
        /// <param name="rotation"></param>
        /// <param name="callback"></param>
        /// <param name="loadAsync"></param>
        /// <returns></returns>
//        bool TryGetEffectLow(LuaTable fxConfig, Vector3 position, Quaternion rotation, Action<EffectItem> callback,bool loadAsync)
//        {
//            string resPath = fxConfig.GetInPath<string>("realResname");
//
//            string toReplace;
//
//            if (resPath.Contains("Mid/"))
//            {
//                toReplace = "Mid/";
//            } else if (resPath.Contains("High/"))
//            {
//                toReplace = "High/";
//            }
//            else
//            {
//                return false;
//            }
//
//            SingleFile fileStatus = BGDownloadMgr.GetResourceStatus(resPath);
//            if (fileStatus == null)
//            {
//                Debug.LogErrorFormat("竟然要加载一个不存在的特效: {0}", resPath);
//                return false;
//            }
//
//            if (fileStatus.isInResources || fileStatus.CheckHasDownloaded())
//            {
//                return false;
//            }
//            
////            string lowResPath = resPath.Replace(toReplace, "Low/");
//
//            SingleFile lowStatus = BGDownloadMgr.GetResourceStatus(lowResPath);
//            if (lowStatus != null && (lowStatus.isInResources || lowStatus.CheckHasDownloaded()))
//            {
//                fxConfig.SetInPath("realResname", lowResPath);
//                CreateFx(fxConfig, position, rotation, callback, loadAsync);
//
//                return true;   
//            }
//            
//            return false;
//        }

        EffectItem DealNewEffectItem(GameObject gameObject, EffectInfo fxInfo, Vector3 position, Quaternion rotation, Action<EffectItem> callback)
        {
            EffectItem effItem = new EffectItem(fxInfo, gameObject);
            DealEffectItem(effItem, position, rotation, callback);
            return effItem;
        }

        void DealEffectItem(EffectItem effectItem, Vector3 position, Quaternion rotation, Action<EffectItem> callback)
        {
            //if (uid != 0) effectItem.transform.name = uid.ToString();
            effectItem.transform.position = position;
            effectItem.transform.rotation = rotation;
            effectItem.StartFx();
            if (callback != null)
            {
                callback(effectItem);
            }
        }

        // 退出战斗, 不用的特效只保留1分钟
        public void OnLeftBattle()
        {
            isInBattle = false;
        }

        // 准备进入战斗, 特效一直保留
        public void OnEnterBattle()
        {
            isInBattle = true;
        }

        private void destroyPrefeb(EffectItem item)
        {
            if (item.destroyPrefabCallback != null)
            {
                item.destroyPrefabCallback();
            }
        }

        public void printContent()
        {
            foreach (var pair in cache)
            {
                Debug.LogFormat("EffectManager包含 {0}个{1}", pair.Value.Count, pair.Key);
            }
        }
        
        public void ReleaseAllCache()
        {
            foreach (var list in cache.Values)
            {
                var count = list.Count;
                if (count == 0)
                {
                    continue;
                }

                EffectItem lastItem = list.Last.Value;

                for (int i = 0; i < count; i++){
                    EffectItem item = list.Last.Value;
                    if (item.isPoolActive)
                    {
                        break;
                    }
                    else
                    {
                        item.Dispose();
                        list.RemoveLast();
                    }
                }

                if (list.Count == 0)
                {
                    destroyPrefeb(lastItem);
                }
            }
        }

        #endregion Common      
    }
}
