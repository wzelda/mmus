using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using XLua;
//Unity交互接口
namespace LPCFramework {
    [LuaCallCSharp]
    public class UnityUtils {
        public static void SetLayerRecursively (GameObject gameObject, int layer) {
            gameObject.SetLayerRecursively (layer);
        }
        public static void SetParticleLayerRecursively (GameObject gameObject, string layer) {
            ParticleSystemRenderer[] psrs = gameObject.GetComponentsInChildren<ParticleSystemRenderer> ();
            for (int i = 0; i < psrs.Length; i++) {
                psrs[i].sortingLayerName = layer;
            }
        }
        public static Vector3 QuaternionEular (Vector3 oriV3, int angle) {
            return Quaternion.Euler (0, angle, 0) * oriV3;
        }
        //设置清空拖尾
        public static void ClearTrail (GameObject go) {
            if (go) {
                TrailRenderer[] trs = go.GetComponentsInChildren<TrailRenderer> (true);
                for (int i = 0; i < trs.Length; i++) {
                    TrailRenderer tr = trs[i];
                    tr.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
                    tr.receiveShadows = false;
                    tr.Clear ();
                }
            }
        }

        public static bool HasNavMeshAtOrigin (int areaMask = NavMesh.AllAreas, int agentTypeID = 0) {
            var hit = new NavMeshHit ();
            var filter = new NavMeshQueryFilter ();
            filter.areaMask = areaMask;
            filter.agentTypeID = agentTypeID;
            return NavMesh.SamplePosition (Vector3.zero, out hit, 0.1f, filter);
        }

        public static RaycastHit NoHit;
        public static RaycastHit Raycast (Vector3 source, Vector3 dir, float maxDistance, int[] layers) {
            RaycastHit hit;
            if (Physics.Raycast (source, dir, out hit, maxDistance, GetAllLayer (layers))) {
                return hit;
            }
            return NoHit;
        }

        public static RaycastHit[] RaycastAll (Vector3 source, Vector3 dir, float maxDistance, int[] layers) {
            return Physics.RaycastAll (source, dir, maxDistance, GetAllLayer (layers));
        }

        public static RaycastHit[] BoxCastAll (Vector3 source, Vector3 halfExtents, Vector3 dir, Quaternion rotation, float maxDistance, int[] layers) {
            return Physics.BoxCastAll (source, halfExtents, dir, rotation, maxDistance, GetAllLayer (layers));
        }

        //获取采样点
        public static Vector3 GetSimplePosition (Vector3 sourcepos, out bool hasData) {
            UnityEngine.AI.NavMeshHit hit;
            hasData = false;
            if (UnityEngine.AI.NavMesh.SamplePosition (sourcepos, out hit, 10, -1)) {
                sourcepos = hit.position;
                hasData = true;
            } else if (UnityEngine.AI.NavMesh.FindClosestEdge (sourcepos, out hit, -1)) {
                hasData = true;
                sourcepos = hit.position;
            }
            //DebugLog.LogError("获取采样点失败，该点不在地图信息中 " + sourcepos);
            return sourcepos;
        }
        //判断是否有可达路径
        public static bool HasNavPath (NavMeshAgent agent, Vector3 targetPos) {
            if (agent.isOnNavMesh) {
                NavMeshPath path = new NavMeshPath ();
                if (agent.CalculatePath (targetPos, path)) {
                    return path.status == NavMeshPathStatus.PathComplete;
                } else {
                    return false;
                }
            } else {
                return false;
            }
        }

        //角色骨骼
        public static Transform[] GetPartGoBones (GameObject partGo) {
            SkinnedMeshRenderer skin = partGo.GetComponentInChildren<SkinnedMeshRenderer> ();
            if (skin) {
                return skin.bones;
            } else {
                return null;
            }
        }

        public static void SetPartGoBones (GameObject partGo, Transform[] bones) {
            SkinnedMeshRenderer skin = partGo.GetComponentInChildren<SkinnedMeshRenderer> ();
            if (skin) {
                skin.bones = bones;
            }
        }

        public static int GetAllLayer (int[] layers) {
            int l = 1;
            if (layers.Length > 0) {
                foreach (int layer in layers) {
                    l |= (1 << layer);
                }
            } else {
                l = -1;
            }
            return l;
        }

        public static void DestroyChild (GameObject go) {
            if (go) {
                for (int i = 0; i < go.transform.childCount; i++) {
                    GameObject.Destroy(go.transform.GetChild(i));
                }
            }
        }

        public static void SetShader (Renderer renderer, string shaderName) {
            Texture originTex = renderer.material.mainTexture;
            UnityEngine.Material mat = new UnityEngine.Material (UnityEngine.Shader.Find (shaderName));
            renderer.material = mat;
            mat.mainTexture = originTex;
        }

        public static void SetMaterialColor (UnityEngine.Material mat, float r, float g, float b, float a) {
            mat.color = new Color (r, g, b, a);
        }

        static MaterialPropertyBlock mpb = null;
        public static void SetMaterialFloat (Renderer renderer, string name, float val) {
            if (mpb == null) {
                mpb = new MaterialPropertyBlock ();
            }
            renderer.GetPropertyBlock (mpb);
            mpb.SetFloat (name, val);
            renderer.SetPropertyBlock (mpb);
        }

        //--------------------------------伤害范围检测--------------------------------------
        /// <summary>
        /// 扇形伤害检测
        /// </summary>
        /// <param name="sourcePos"></param>
        /// <param name="forward"></param>
        /// <param name="targetPos"></param>
        /// <param name="minAngle"></param>
        /// <param name="range"></param>
        /// <returns></returns>
        public static bool IsInSector (Vector3 sourcePos, Vector3 forward, Vector3 targetPos, float targetRadius, int minAngle, float range) {
            Vector3 deltaPos = targetPos - sourcePos;
            deltaPos.y = 0;
            float dis = deltaPos.magnitude;
            if (dis < range + targetRadius) {
                //角度检测
                if (minAngle >= 360) { //圆形
                    return true;
                } else {
                    float angle = Vector3.Angle (deltaPos, forward) * 2;
                    return angle <= minAngle;
                }
            } else {
                return false;
            }
        }

        public static bool IsInRect (Vector3 sourcePos, Vector3 sourceDir, Transform sourceTrans, Transform targetTarns, float rangeValue1, float rangeValue2, float addRange) {
            Vector3 deltaA = targetTarns.position - sourcePos;
            deltaA.y = 0;
            float ds = deltaA.magnitude;
            if (ds > addRange) {
                deltaA = deltaA.normalized * (ds - addRange);
            }
            float forwardDotA = Vector3.Dot (sourceDir, deltaA);
            if (forwardDotA > 0 && forwardDotA <= rangeValue2) {
                if (Mathf.Abs (Vector3.Dot (sourceTrans.right, deltaA)) < rangeValue1 * 0.5) {
                    return true;
                }
            }
            return false;
        }
    }
}