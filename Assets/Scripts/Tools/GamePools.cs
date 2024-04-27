
//对象缓存池
//每个对象池的缓存大小
//最新的对象进入后 当缓存池超过数量，移除最老的对象

using BestHTTP;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Threading;
using UnityEngine;
using UnityEngine.EventSystems;
using Object = UnityEngine.Object;
using Random = System.Random;

namespace LPCFramework
{

    public class GamePoolNameTag : MonoBehaviour
    {
        // 入池前需要设置, get时会get到名字是这个的对象
        public string NameTagPath;
        public string PoolName;

        public int id;
    }
    
    
    public class GamePools : SingletonMonobehaviour<GamePools>
    {
        /// <summary>
        /// 缓存池dic
        /// </summary>
        private readonly Dictionary<string, GamePool> pools = new Dictionary<string, GamePool>();
        
        // 所有的池, 里面东西都清完后才清掉prefeb.
        // 每个新建的给出去的东西, 池都要track
        public readonly Dictionary<string, PrefebContainer> prefebCache = new Dictionary<string, PrefebContainer>();
        
        private Transform m_poolManagerBaseRoot;

        private const int CHECK_OLD_INTERVAL = 5; // 多少秒检测一次超时
        private float lastCheckTime;

        public int OLD_REMOVE_SECONDS = 30;


#if UNITY_EDITOR
        private Thread mainThread;

        public void Awake()
        {
            mainThread = Thread.CurrentThread;
            //设置缓存数量
            LuaUtils.SetSystemMemoryCacheSize();
        }
#endif


        /// <summary>
        /// 获取对象池
        /// </summary>
        /// <param name="poolName"></param>
        /// <returns></returns>
        public GamePool GetPool(string poolName, Transform root)
        {
#if UNITY_EDITOR
            if (Thread.CurrentThread != mainThread)
            {
                Debug.LogError("获取对象池竟然不是在主线程!!!");
            }
#endif
            if (m_poolManagerBaseRoot == null)
            {
                m_poolManagerBaseRoot = root;
            }
            GamePool pool;
            if (!pools.TryGetValue(poolName, out pool))
            {
                var poolSize = 100;
                if (poolName.Contains("Actor"))
                {
                    //角色缓存
                    poolSize = LuaUtils.GetSystemMemoryCache(1);
                }
                else
                {
                    //其他缓存
                    poolSize = LuaUtils.GetSystemMemoryCache(2);
                }
                
                pool = new GamePool(poolName, m_poolManagerBaseRoot, poolSize);
                pools.Add(poolName, pool);
            }

            return pool;
        }

        private void Update()
        {
            
            if (Time.realtimeSinceStartup - lastCheckTime > 2)
            {
                lastCheckTime = Time.realtimeSinceStartup;
                     
                DateTime now = DateTime.Now;
                DateTime oldLimit = DateTime.Now.AddSeconds(-OLD_REMOVE_SECONDS);
                foreach (var pool in pools.Values)
                {
                    if (now > pool.nextCheckTime)
                    {
                        pool.removeOlder(oldLimit);
                        pool.nextCheckTime = now.AddSeconds(CHECK_OLD_INTERVAL);
                    }
                }
            }
        }

        public void printContent()
        {
            foreach (var pool in pools.Values)
            {
                pool.printContent();
            }
        }

        public static void ClearAll(bool reduceSize = false)
        {
            if (_S != null)
            {
                _S.clearAll(reduceSize);
            }
        }

        private void clearAll(bool reduceSize)
        {
            foreach (var pool in pools.Values)
            {
                pool.clearAll(reduceSize);
            }

            if (reduceSize)
            {
                // 被警告内存不够时, 缩短缓存时间
                OLD_REMOVE_SECONDS = OLD_REMOVE_SECONDS * 2 / 3 + 1;
                if (OLD_REMOVE_SECONDS < 40)
                {
                    OLD_REMOVE_SECONDS = 40;
                }
            }
        }
        
        // 替换掉正在使用的prefeb
        public void ReplacePrefeb(string name, Object prefeb, Action destroyCallback)
        {
            foreach (var pool in pools.Values)
            {
                var rightPool = pool.ReplacePrefeb(name, prefeb, destroyCallback);
                if (rightPool)
                {
                    return;
                }
            }
        }
        
        /// <summary>
        /// 重新设置池子的大小
        /// </summary>
        public void ResetPoolsSize()
        {
            foreach (var pool in pools.Values)
            {
                pool.poolSize = LuaUtils.GetSystemMemoryCache(1);
            }
        }
    }

    class Holder
    {
       public LinkedList<BestHTTP.Tuple<Holder, int>> list;
        public GameObject gameObject;
        public LinkedListNode<BestHTTP.Tuple<Holder, int>> node;
        public Object prefeb;
        public Action destroyPrefeb;
        // 仅仅保存一下, 替换黑人的时候再调用一次
        // 不使用时, 就清掉
        public Action<GameObject> callback;
        public LinkedHashMap<int, Holder> map;
        
        // 是否返回出去, 正在使用的
        public bool isInUse;
        public DateTime lastUseTime;
        public int id;

        public Holder(int id, GameObject gameObject, Object prefeb, Action destroyPrefeb)
        {
            this.id = id;
            this.prefeb = prefeb;
            this.destroyPrefeb = destroyPrefeb;
            this.gameObject = gameObject;
            this.isInUse = true;
        }

        public void recycleAndMoveToLast()
        {
            isInUse = false;
            callback = null;
            lastUseTime = DateTime.Now;
            list.Remove(node);
            list.AddLast(node);
        }

        public void removeAndDestroy()
        {
            callback = null;
            map.Remove(id);
            if (gameObject != null)
            {
                Object.Destroy(gameObject);
                gameObject = null;
            }

            prefeb = null;
        }

        public bool isAlive(DateTime deadline)
        {
            if (gameObject == null || (!isInUse && lastUseTime < deadline))
            {
                return false;
            }

            return true;
        }

        public GameObject reuseIfPossible(Action<GameObject> callback)
        {
            if (!isInUse && gameObject != null)
            {
                isInUse = true;
                this.callback = callback;
                list.Remove(node);
                list.AddFirst(node);
                
                return gameObject;
            }
            else
            {
                return null;
            }
        }
    }
    

    /// <summary>
    /// 单个类型的缓存池
    /// </summary>
    public class GamePool
    {
        //热更标识 1005 4
        public static bool HotFixSign_1005_4 = true;

        
        private static  Random rand = new Random();
        // linkedlist里面, 越后面的就是越老的没有在用的, 前面的是在用的.
        private readonly Dictionary<string, LinkedHashMap<int, Holder>> objs = new Dictionary<string, LinkedHashMap<int, Holder>>();

        private int counter;
        
        //池子的大小
        public int poolSize = 100;
        public readonly Transform parentRoot;

        // 现有个数, 不管有用或者没用
        private int currentCount;
        
        private readonly string poolName;

        public DateTime nextCheckTime;

        public bool isPermanent;
        
        public GamePool(string poolName, Transform parent, int poolSize)
        {
            var gameObj = new GameObject(poolName);
            gameObj.transform.SetParent(parent);
            parentRoot = gameObj.transform;
            this.poolName = poolName;
            this.poolSize = poolSize;
            nextCheckTime = DateTime.Now.AddSeconds(rand.Next(30));

            if (poolName.Equals("Permanent") || poolName.Equals("MapPool"))
            {
                this.isPermanent = true;
            }
        }

        /// <summary>
        /// 从池子中获取对象
        /// </summary>
        /// <param name="name"></param>
        /// <typeparam name="T"></typeparam>
        /// <returns></returns>
        public GameObject TryGetFromPool(string name, Action<GameObject> callback)
        {
            LinkedHashMap<int, Holder> map;
            if (objs.TryGetValue(name, out map))
            {
                if (map.Count == 0)
                {
                    return null;
                }

                Holder holder = map.Last();
                GameObject result = holder.reuseIfPossible(callback);
                if (result != null)
                {
                    return result;
                }
                
                // 不够, 都是active的

                result = Object.Instantiate(holder.prefeb) as GameObject;

                createHolder(name, result, holder.prefeb, holder.destroyPrefeb, callback, map);

                return result;
            }

            return null;
        }
        
        private void createHolder(string name, GameObject gameObject, Object prefeb, Action destroyPrefebCallback, Action<GameObject> callback,
            LinkedHashMap<int, Holder> map)
        {
            int id = ++counter;
            var newHolder = new Holder(id, gameObject, prefeb, destroyPrefebCallback);

            newHolder.map = map;
            newHolder.node = map.AddFirst(id, newHolder);
            newHolder.list = map.List();

            newHolder.callback = callback;
            GamePoolNameTag nameTag = gameObject.AddComponent<GamePoolNameTag>();
            nameTag.NameTagPath = name;
            nameTag.PoolName = poolName;
            nameTag.id = id;
            
            currentCount++;
        }

        // 外面创建出来一个GameObject, 这里保存一下
        public void SaveObject(string name, GameObject gameObject, Object prefeb, Action destroyPrefebCallback, Action<GameObject> callback)
        {
            
            LinkedHashMap<int, Holder> map;
            if (!objs.TryGetValue(name, out map))
            {
                map = new LinkedHashMap<int, Holder>();
                objs.Add(name, map);
            }
            
            createHolder(name, gameObject, prefeb, destroyPrefebCallback, callback, map);
        }

        // 替换掉正在使用的prefeb
        public bool ReplacePrefeb(string name, Object prefeb, Action destroyCallback)
        {
            LinkedHashMap<int, Holder> map;
            if (!objs.TryGetValue(name, out map))
            {
                // 没人需要
                return false;
            }

            var count = map.Count;
            
            bool used = false;
            
            var node = map.Values().First;

            for (int i = 0; i < count && node != null; i++)
            {
                var holder = node.Value.Item1;
                node = node.Next;
                
                if (holder.gameObject == null)
                {
                    holder.removeAndDestroy();
                    currentCount--;
                    continue;
                }

                if (!holder.isInUse)
                {
                    // 没在用, 就不直接实例化出来了
                    holder.removeAndDestroy();
                    currentCount--;
                    continue;
                }
                
                GameObject oldObject = holder.gameObject;
                GameObject newObject = Object.Instantiate(prefeb, oldObject.transform.position, oldObject.transform.rotation, oldObject.transform.parent) as GameObject;

                if (holder.callback == null)
                {
                    Debug.LogError("替换时, 竟然有人在使用, 但是没有callback");
                    continue;
                }

                var olbNameTag = oldObject.GetComponent<GamePoolNameTag>();
                 
                var newNameTag = newObject.AddComponent<GamePoolNameTag>();
                
                newNameTag.NameTagPath = olbNameTag.NameTagPath;
                newNameTag.PoolName = olbNameTag.PoolName;
                newNameTag.id = olbNameTag.id;

                holder.prefeb = prefeb;
                holder.destroyPrefeb = destroyCallback;
                holder.gameObject = newObject;

                used = true;
                
                Object.Destroy(oldObject);
                // 不需要管原来的destroyCallback, 黑人不需要管
                
                try
                {
                    holder.callback(newObject); // 用个新对象, 再调用一次当初要对象的那个callback
                }
                catch (Exception ex)
                {
                    Debug.LogError("竟然callback有报错");
                }
            }
            
            // 如果used为false, 那算了吧, 走你
            if (!used)
            {
                if (destroyCallback != null)
                {
                    destroyCallback();
                }
            }

            return true;
        }
        
        
        /// <summary>
        /// 将之前用的, 返回加进缓冲池
        /// </summary>
        /// <param name="name"></param>
        /// <param name="obj"></param>
        public void ReturnToPool(GamePoolNameTag nameTag)
        {
            if (nameTag == null || nameTag.gameObject == null)
            {
                Debug.LogError("竟然回池了一个已经不存在的GameObject");
                return;
            }

            string name = nameTag.name;
            GameObject gameObject = nameTag.gameObject;
            
            LinkedHashMap<int, Holder> list;
            if (!objs.TryGetValue(nameTag.NameTagPath, out list))
            {
                Debug.LogError("竟然回池了一个之前不是从池里出去的");
                Object.Destroy(gameObject);
                return;
            }

            Holder holder;
            if (!list.TryGetValue(nameTag.id, out holder))
            {
                Debug.LogError("回池时, 竟然没有找到原来的holder");
                Object.Destroy(gameObject);
                return;
            }

            if (holder.gameObject != gameObject)
            {
                Debug.LogError("回池时, 取出来的竟然不是原来的GameObject");
                Object.Destroy(gameObject);
                return;
            }

            if (!holder.isInUse)
            {
                Debug.LogErrorFormat("回池了一个之前就已经回过池的: {0}", name);
                return;
            }
            
            gameObject.transform.SetParent(parentRoot);
            holder.recycleAndMoveToLast();
            
            if (currentCount <= poolSize)
            {
                return;
            }
            
            // 检查每个map的最后一个东西, 找出最老的, 删掉
            
            DateTime oldestTime = default(DateTime);
            Holder oldestNode = null;

            foreach (var ll in objs.Values)
            {
                if (ll.Count > 0)
                {
                    var node = ll.Last();

                    if (!node.isInUse)
                    {
                        if (oldestNode == null || node.lastUseTime < oldestTime)
                        {
                            oldestTime = node.lastUseTime;
                            oldestNode = node;
                        }
                    }
                }
            }

            if (oldestNode != null)
            {
                oldestNode.removeAndDestroy();
                currentCount--;

                if (oldestNode.list.Count == 0)
                {
                    // 没东西了, 清掉prefeb
                    destroyPrefeb(oldestNode);
                }
            }
        }

        private void destroyPrefeb(Holder holder)
        {
            if (holder.destroyPrefeb != null)
            {
                holder.destroyPrefeb();
            }
        }

        public void printContent()
        {
            foreach (var pair in objs)
            {
                if (pair.Value.Count == 0)
                {
                    continue;
                }
                
                Debug.LogFormat("GamePool池 {0}个{1}", pair.Value.Count, pair.Key);
            }
        }

        public void clearAll(bool reduceSize = false)
        {
            foreach (var list in objs.Values)
            {
                var count = list.Count;
                
                if (count == 0)
                {
                    continue;
                }

                Holder lastNode = list.Last();

                var node = list.LastNode();

                for (int i = 0; i < count && node != null; i++)
                {
                    var holder = node.Value.Item1;
                    node = node.Previous;
                    
                    if (holder.isInUse && holder.gameObject != null)
                    {
                        break; // 前面都是在用的
                    }
                    
                    holder.removeAndDestroy();
                    currentCount--;
                } 

                if (list.Count == 0)
                {
                    destroyPrefeb(lastNode);
                }
            }

            if (reduceSize)
            {
                poolSize = poolSize * 2 / 3 + 1; // 降低缓存数量
            }
        }

        public void removeOlder(DateTime lastUseTime)
        {
            foreach (var list in objs.Values)
            {
                var count = list.Count;
                
                if (count == 0)
                {
                    continue;
                }

                var node = list.LastNode();
                var lastHolder = node.Value.Item1;
                
                for (int i = 0; i < count && node != null; i++){
                    
                    var holder = node.Value.Item1;

                    if (holder.isInUse && holder.gameObject != null)
                    {
                        break; // 前面的都是在用的
                    }

                    node = node.Previous;
                    
                    // 如果是永久保留的, 且只剩不多了, 就不删了
                    if (isPermanent && list.Count <= 2)
                    {
                        break;
                    }
                    
                    
                    if (!holder.isAlive(lastUseTime))
                    {
                        holder.removeAndDestroy();
                        currentCount--;
                    }
                }


                if (list.Count == 0)
                {
                    destroyPrefeb(lastHolder);
                }
            }
        }
    }
}


