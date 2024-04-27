using System;
using System.Collections.Generic;
using UnityEngine;
using Object = UnityEngine.Object;

namespace LPCFramework
{
    public class PrefebContainer
    {
        public string path;
        
        public Transform defaultParent;

        public DateTime loadedTime;

        private PrefebAsker firstAsker;
        private LinkedList<PrefebAsker> askerList;

        public PrefebContainer(string path, Transform parent)
        {
            this.path = path;
            this.defaultParent = parent;
        }
        
        public void setPrefeb(Object obj, Action prefebDestroyCallback)
        {
            if (firstAsker != null)
            {
                firstAsker.give(obj, defaultParent, prefebDestroyCallback);

                firstAsker = null;
            }

            if (askerList != null)
            {
                foreach (var asker in askerList)
                {
                    asker.give(obj, defaultParent, prefebDestroyCallback);
                }
                askerList = null;
            }

        }

        public void createOrQueue(Vector3 pos, Quaternion rotation, Transform parent, Action<Object, GameObject, Action> cb)
        {
            var asker = new PrefebAsker(pos, rotation, cb, parent);
            if (firstAsker == null)
            {
                firstAsker = asker; 
                return;
            }
            
            if (askerList == null)
            {
                askerList = new LinkedList<PrefebAsker>();
            }

            askerList.AddLast(asker);
        }

        public void clear()
        {
            firstAsker = null;
            askerList = null;
        }
        
        public static void protectedCallback(Action<Object, GameObject, Action> cb, Object prefeb, GameObject go, Action destroyCallback){
            //try
            {
                cb(prefeb, go, destroyCallback);
            }
            //catch (Exception ex)
            {
                //Debug.LogErrorFormat("从池里获取对象cb报错: {0}", ex);
            }
        }
    }
    
    public class PrefebAsker
    {
        private readonly Vector3 pos;
        private readonly  Quaternion rotation;
        private Action<Object, GameObject, Action> cb;
        private Transform parent;
        private GameObject gameObject;

        public PrefebAsker(Vector3 pos, Quaternion rotation, Action<Object, GameObject, Action> cb, Transform parent)
        {
            this.pos = pos;
            this.rotation = rotation;
            this.parent = parent;
            this.cb = cb;
        }

        public void give(Object prefeb, Transform defaultParent, Action destroyCallback)
        {
            if (cb == null)
            {
                return;
            }
            
            if (parent == null)
            {
                gameObject = Object.Instantiate(prefeb, pos, rotation, defaultParent) as GameObject;
            }
            else
            {
                gameObject = Object.Instantiate(prefeb, pos, rotation, parent) as GameObject;
            }

            parent = null;
            
            PrefebContainer.protectedCallback(cb, prefeb, gameObject, destroyCallback);
            cb = null;
        }
    }
}