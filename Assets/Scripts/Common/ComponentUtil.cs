using System;
using System.Collections.Generic;
using UnityEngine;
using XLua;

namespace LPCFramework {
    /// <summary>
    /// component扩展
    /// </summary>
    [LuaCallCSharp]
    public static class ComponentUtil {
        /// <summary>
        /// 如果物体没有T组件，则添加
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="gameObject"></param>
        /// <returns></returns>
        public static T AddComponentIfNotExist<T> (this GameObject gameObject) where T : Component {
            if (gameObject == null) {
                return null;
            }
            var component = gameObject.GetComponent<T> ();
            if (component == null)
                component = gameObject.AddComponent<T> ();
            return component;
        }

        static public Component EnsureComponent(this GameObject go, Type t)
        {
            Component comp = go.GetComponent(t);

            if (comp == null)
            {
                comp = go.AddComponent(t);
            }
            return comp;
        }

        /// <summary>
        /// 如果物体T组件，则删除
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="gameObject"></param>
        /// <returns></returns>
        public static void RemoveComponentIfExist<T> (this GameObject gameObject) where T : Component {
            if (gameObject == null) {
                return;
            }
            var component = gameObject.GetComponent<T> ();
            if (component != null)
                Transform.Destroy (component);
        }

        /// <summary>
        /// 递归地设置物体所有节点的层级
        /// </summary>
        /// <param name="gameObject"></param>
        /// <param name="layer"></param>
        public static void SetLayerRecursively (this GameObject gameObject, int layer) {
            gameObject.layer = layer;

            for (int i = 0; i < gameObject.transform.childCount; i++) {
                Transform child = gameObject.transform.GetChild (i);
                SetLayerRecursively (child.gameObject, layer);
            }
        }
        /// <summary>
        /// 递归查找指定对象
        /// </summary>
        /// <param name="transform"></param>
        /// <param name="name"></param>
        /// <returns></returns>
        public static Transform GetTransformRecursively (this Transform transform, string name) {
            Transform result = null;

            foreach (Transform child in transform) {
                if (child.name == name) {
                    result = child;
                    return result;
                } else {
                    result = GetTransformRecursively (child, name);
                    if (result != null)
                        break;
                }
            }

            return result;
        }
        /// <summary>
        /// 递归查找指定对象
        /// </summary>
        /// <param name="transform"></param>
        /// <param name="name"></param>
        /// <returns></returns>
        public static Transform[] GetTransformArrayRecursively (this Transform transform, string[] nameArray, ref Transform[] resultArray) {
            if (transform == null || nameArray == null || nameArray.Length <= 0) {
                return null;
            }

            if (resultArray == null)
                resultArray = new Transform[nameArray.Length];

            foreach (Transform child in transform) {
                for (int i = 0; i < nameArray.Length; ++i) {
                    if (child.name == nameArray[i]) {
                        resultArray[i] = child;
                        break;
                    }
                }
                // 进入此节点的子节点查找
                GetTransformArrayRecursively (child, nameArray, ref resultArray);
            }

            return resultArray;
        }
        /// <summary>
        /// 设置物体所有节点的碰撞启用/关闭
        /// </summary>
        /// <param name="gameObject"></param>
        /// <param name="tf"></param>
        public static void SetCollisionRecursively (this GameObject gameObject, bool tf) {
            Collider[] colliders = gameObject.GetComponentsInChildren<Collider> ();
            foreach (Collider collider in colliders)
                collider.enabled = tf;
        }
        /// <summary>
        /// 设置物体所有节点的可见性
        /// </summary>
        /// <param name="gameObject"></param>
        /// <param name="tf"></param>
        public static void SetVisualRecursively (this GameObject gameObject, bool tf) {
            Renderer[] renderers = gameObject.GetComponentsInChildren<Renderer> ();
            foreach (Renderer renderer in renderers)
                renderer.enabled = tf;
        }
        /// <summary>
        /// 递归地从子节点中获取T指定Tag的T组件
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="gameObject"></param>
        /// <param name="tag"></param>
        /// <returns></returns>
        public static T[] GetComponentsInChildrenWithTag<T> (this GameObject gameObject, string tag) where T : Component {
            List<T> results = new List<T> ();

            if (gameObject.CompareTag (tag))
                results.Add (gameObject.GetComponent<T> ());

            foreach (Transform t in gameObject.transform)
                results.AddRange (t.gameObject.GetComponentsInChildrenWithTag<T> (tag));

            return results.ToArray ();
        }
        /// <summary>
        /// 从父级获取第一个T组件
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="gameObject"></param>
        /// <returns></returns>
        public static T GetComponentInParents<T> (this GameObject gameObject) where T : Component {
            for (Transform t = gameObject.transform; t != null; t = t.parent) {
                T result = t.GetComponent<T> ();
                if (result != null)
                    return result;
            }

            return null;
        }
        /// <summary>
        /// 从父级获取所有T组件
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="gameObject"></param>
        /// <returns></returns>
        public static T[] GetComponentsInParents<T> (this GameObject gameObject) where T : Component {
            List<T> results = new List<T> ();
            for (Transform t = gameObject.transform; t != null; t = t.parent) {
                T result = t.GetComponent<T> ();
                if (result != null)
                    results.Add (result);
            }

            return results.ToArray ();
        }

        /// <summary>
        /// 获取物体碰撞遮罩，换句话说就是，获取需要忽略的碰撞层级
        /// </summary>
        /// <param name="gameObject"></param>
        /// <param name="layer"></param>
        /// <returns></returns>
        public static int GetCollisionMask (this GameObject gameObject, int layer = -1) {
            if (layer == -1)
                layer = gameObject.layer;

            int mask = 0;
            for (int i = 0; i < 32; i++)
                mask |= (Physics.GetIgnoreLayerCollision (layer, i) ? 0 : 1) << i;

            return mask;
        }

        /// <summary>
        /// 改变Color的alpha值
        /// eg: GUI.color = desiredColor.WithAlpha(currentAlpha);
        /// </summary>
        /// <param name="color"></param>
        /// <param name="alpha"></param>
        /// <returns></returns>
        public static Color WithAlpha (this Color color, float alpha) {
            return new Color (color.r, color.g, color.b, alpha);
        }
        public static void ForceCrossFade (this Animator animator, int anim, float transitionDuration, int layer = 0, float normalizedTime = float.NegativeInfinity) {
            animator.Update (0);

            if (animator.GetNextAnimatorStateInfo (layer).fullPathHash == 0) {
                animator.CrossFade (anim, transitionDuration, layer, normalizedTime);
            } else {
                animator.Play (animator.GetNextAnimatorStateInfo (layer).fullPathHash, layer);
                animator.Update (0);
                animator.CrossFade (anim, transitionDuration, layer, normalizedTime);
            }
        }
    }
}