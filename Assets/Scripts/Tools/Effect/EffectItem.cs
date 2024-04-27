using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;
using Object = UnityEngine.Object;

namespace LPCFramework {
    public enum ENEffectStatus {
        //初始
        EffectState_NULL = 0,
        //未激活
        EffectState_NoActive,
        //延时
        EffectState_Dealy,
        //激活
        EffectState_Active,
        //结束
        EffectState_END,
    }

    /// <summary>
    /// 特效类
    /// 制作要求：特效制作放在一个空物体下
    /// </summary>
    [LuaCallCSharp]
    public class EffectItem {
        public string id; //配置表中ID

        public Object prefeb;
        public Action destroyPrefabCallback;
        float delayTime = 0.0f;
        public float timeLife = 0f;
        public float duration = 0; //持续时间，-1为一直存在
        float fadeInTime = 0f;
        float fadeOutTime = 0f;
        float fadeInTotalTime = 0f;
        float fadeOutTotalTime = 0f;
        public float startTime;

        public GameObject gameObject;
        public Transform transform;
        public EffectInfo info;
        public ENEffectStatus effectStatus = ENEffectStatus.EffectState_NULL;

        ParticleSystem[] childParticleList = new ParticleSystem[] { };
        List<ParticleSystem> canDoScaleParticleList = new List<ParticleSystem> ();
        bool doScale = false;
        List<Vector3> scaleParticSizeleList = new List<Vector3> ();

        Animation[] childAnimationList = new Animation[] { };
        Animator[] childAnimatorList = new Animator[] { };
        Renderer[] childRenderList = new Renderer[] { };
        TrailRenderer[] childTrailRendererList = new TrailRenderer[] { };
        LineRenderer[] childLineRenderList = new LineRenderer[] { };
        ParticleSystem.MinMaxGradient[] particleColorList = null;
        Color[] lineStartColorList = null;
        Color[] lineEndColorList = null;
        SpriteRenderer[] childSpriteRenderList = new SpriteRenderer[] { };
        Color[] spriteColorList = null;

        // --- EffectManager使用 ---

        #region effect_manager_use

        public bool isPoolActive;
        public DateTime lastUseTime;

        #endregion

        public EffectItem (EffectInfo _info, GameObject obj) {
            gameObject = obj;

            transform = gameObject.transform;
            info = _info;
            id = info.id;
            fadeInTotalTime = info.FadeInTime;
            fadeOutTotalTime = info.FadeOutTime;
            doScale = false;
            Init (gameObject);
        }

        public bool IsActive () {
            return effectStatus == ENEffectStatus.EffectState_Active;
        }

        //设置特效播放速度
        float speed_ = 1.0f;
        public float speed {
            get { return speed_; }
            set {
                speed_ = value;
                for (int i = 0; i < childAnimationList.Length; i++) {
                    Animation x1 = childAnimationList[i];
                    foreach (AnimationState clip in x1) {
                        if (clip)
                            clip.speed = speed_;
                    }
                }
                for (int i = 0; i < childAnimatorList.Length; i++) {
                    childAnimatorList[i].speed = speed_;
                }
                for (int i = 0; i < childParticleList.Length; i++) {
                    ParticleSystem.MainModule main = childParticleList[i].main;
                    main.simulationSpeed = speed_;
                }
            }
        }

        void Init (GameObject go) {
            childAnimationList = go.GetComponentsInChildren<Animation> ();
            childAnimatorList = go.GetComponentsInChildren<Animator> ();
            childParticleList = go.GetComponentsInChildren<ParticleSystem> ();
            particleColorList = new ParticleSystem.MinMaxGradient[childParticleList.Length];
            for (int i = 0; i < childParticleList.Length; i++) {
                ParticleSystem _ps = childParticleList[i];
                ParticleSystem.MainModule main = _ps.main;
                particleColorList[i] = main.startColor;
                ParticleSystemRenderer renderer = _ps.GetComponent<ParticleSystemRenderer> ();
                if (renderer && renderer.sharedMaterial && _ps.main.scalingMode == ParticleSystemScalingMode.Local) {
                    canDoScaleParticleList.Add (_ps);
                    scaleParticSizeleList.Add (_ps.transform.localScale);
                }
            }

            childRenderList = go.GetComponentsInChildren<Renderer> ();
            childLineRenderList = go.GetComponentsInChildren<LineRenderer> ();
            int lineLength = childLineRenderList.Length;
            lineStartColorList = new Color[lineLength];
            lineEndColorList = new Color[lineLength];
            for (int i = 0; i < childLineRenderList.Length; i++) {
                lineStartColorList[i] = childLineRenderList[i].startColor;
                lineEndColorList[i] = childLineRenderList[i].endColor;
            }
            childTrailRendererList = go.GetComponentsInChildren<TrailRenderer> ();
            childSpriteRenderList = go.GetComponentsInChildren<SpriteRenderer> ();
            spriteColorList = new Color[childSpriteRenderList.Length];
            for (int i = 0; i < childSpriteRenderList.Length; i++) {
                spriteColorList[i] = childSpriteRenderList[i].color;
            }
        }

        public void StartFx () {
            if (info.delay > 0f) {
                delayTime = info.delay;
                if (gameObject.activeSelf) {
                    gameObject.SetActive (false);
                }
                effectStatus = ENEffectStatus.EffectState_Dealy;
            } else {
                Play ();
            }
        }
        void Play () {
            if (!gameObject.activeSelf) {
                gameObject.SetActive (true);
            }
            for (int m = 0; m < childTrailRendererList.Length; m++) {
                childTrailRendererList[m].Clear ();
                childTrailRendererList[m].enabled = true;
            }
            /* for (int n = 0; n < childLineRenderList.Length; n++) {
                childLineRenderList[n].startColor = lineStartColorList[n];
                childLineRenderList[n].endColor = lineEndColorList[n];
            }
            for (int n = 0; n < childSpriteRenderList.Length; n++) {
                childSpriteRenderList[n].color = spriteColorList[n];
            }
            for (int n = 0; n < childParticleList.Length; n++) {
                ParticleSystem.MainModule main = childParticleList[n].main;
                main.startColor = particleColorList[n];
                childParticleList[n].Play ();
            }

            for (int n = 0; n < childRenderList.Length; n++) {
                childRenderList[n].enabled = true;
            }

            for (int n = 0; n < childAnimationList.Length; n++) {
                if (childAnimationList[n].clip == null)
                    continue;
                childAnimationList[n].Stop ();
                childAnimationList[n].Play ();
            }
            for (int n = 0; n < childAnimatorList.Length; n++) {
                if (childAnimatorList[n] == null || !childAnimatorList[n].gameObject.activeSelf)
                    continue;
                if (childAnimatorList[n].runtimeAnimatorController) {
                    AnimatorStateInfo asi = childAnimatorList[n].GetCurrentAnimatorStateInfo (0);
                    childAnimatorList[n].CrossFade (asi.fullPathHash, 0);
                }
            } */

            timeLife = 0f;
            duration = info.duration; //毫秒单位
            //speed = 1.0f; //目前战斗中全部使用TimeScale处理加速，如果特殊则在单独的粒子或者动画中设为不受时间影响
            fadeInTime = 0;
            if (info.FadeInTime > 0) {
                fadeInTime = info.FadeInTime;
            }
            effectStatus = ENEffectStatus.EffectState_Active;
        }

        public bool Stop (bool force = false) {
            if (effectStatus == ENEffectStatus.EffectState_NULL) {
                return true;
            }

            if (force) {
                Close ();
                return true;
            }

            //StopEffect();

            if (info != null && fadeOutTotalTime > 0f) {
                effectStatus = ENEffectStatus.EffectState_END;
                fadeOutTime = fadeOutTotalTime;
            } else {
                Close ();
                return true;
            }

            return false;
        }

        static ParticleSystem.Particle[] tmpParticles = new ParticleSystem.Particle[16];

        // 返回是否可以删掉了
        public bool UpdateItem (float deltaTime) {
            switch (effectStatus) {
                case ENEffectStatus.EffectState_NULL:
                    return true;

                case ENEffectStatus.EffectState_Dealy: //延时播发特效
                    delayTime -= deltaTime;
                    if (delayTime <= 0.0f) {
                        Play ();
                    }
                    break;
                case ENEffectStatus.EffectState_Active: //计算播放时长
                    timeLife += deltaTime * speed;
                    if (fadeInTime > 0) {
                        DoFade (transform, fadeInTime, fadeInTotalTime);
                        fadeInTime -= deltaTime;
                    }
                    if (timeLife > duration && duration > 0) {
                        return Stop ();
                    }
                    break;
                case ENEffectStatus.EffectState_END:
                    if (fadeOutTime > 0f) {
                        DoFade (false, fadeOutTime, fadeOutTotalTime);
                        fadeOutTime -= deltaTime;
                    } else {
                        Close ();
                        return true;
                    }
                    break;
            }

            return false;
        }
        //程序做特效淡出
        private void DoFade (bool isInFade, float fadeTime, float fadeTotalTime) {
            float aFacor = fadeTime / fadeTotalTime;
            if (isInFade) {
                aFacor = 1 - aFacor;
            }
            for (int i = 0; i < childParticleList.Length; i++) {
                ParticleSystem x = childParticleList[i];
                ParticleSystem.MinMaxGradient oldColorGradient = particleColorList[i];
                if (x != null) {
                    ParticleSystem.MainModule main = x.main;
                    ParticleSystem.MinMaxGradient colorGradient = main.startColor;
                    Color a = colorGradient.color;
                    Color b = colorGradient.colorMax;
                    Color c = colorGradient.colorMin;
                    a.a = aFacor * oldColorGradient.color.a;
                    b.a = aFacor * oldColorGradient.colorMax.a;
                    c.a = aFacor * oldColorGradient.colorMin.a;
                    colorGradient.color = a;
                    colorGradient.colorMax = b;
                    colorGradient.colorMin = c;
                    main.startColor = colorGradient;
                }
            }
            foreach (LineRenderer x1 in childLineRenderList) {
                if (x1 != null) {
                    Color startColor = x1.startColor;
                    Color endColor = x1.endColor;

                    startColor.a *= aFacor;
                    endColor.a *= aFacor * 3;
                    x1.startColor = startColor;
                    x1.endColor = endColor;
                }
            }
            for (int i = 0; i < childSpriteRenderList.Length; i++) {
                SpriteRenderer x1 = childSpriteRenderList[i];
                if (x1 != null) {
                    Color color = x1.color;
                    color.a = aFacor * spriteColorList[i].a;
                    x1.color = color;
                }
            }
        }
        private void Close () {
            if (effectStatus == ENEffectStatus.EffectState_NULL) {
                return;
            }
            Reset ();
            if (gameObject != null) {
                gameObject.SetActive (false);
            }
            effectStatus = ENEffectStatus.EffectState_NULL;
        }
        private void ResetScale () {
            if (gameObject != null && doScale) {
                //如果有粒子使用脚本景区缩放处理
                for (int i = 0; i < canDoScaleParticleList.Count; i++) {
                    ParticleSystem particle = canDoScaleParticleList[i];
                    particle.transform.localScale = scaleParticSizeleList[i];
                }
                doScale = false;
            }
        }
        public void DoScale (float scaleSize) {
            if (gameObject == null) {
                return;
            }
            //如果有粒子使用脚本景区缩放处理
            for (int i = 0; i < canDoScaleParticleList.Count; i++) {
                ParticleSystem particle = canDoScaleParticleList[i];
                particle.transform.localScale *= scaleSize;
            }
            doScale = true;
        }

        //重置
        public void Reset () {
            if (destroyed) {
                return;
            }
            //SetActive(true);
            id = string.Empty;
            delayTime = 0f;
            fadeOutTime = 0f;
            timeLife = 0f;
            duration = 0f;
            startTime = 0f;
            ResetScale ();
            gameObject.SetLayerRecursively (LayerMask.NameToLayer ("Default"));
            transform.localScale = Vector3.one;
            effectStatus = ENEffectStatus.EffectState_NoActive;
        }
        //删除特效
        public bool destroyed;
        public void Dispose () {
            //EffectMgr.Instance.CloseFx(this);
            if (destroyed) {
                Debug.LogError ("竟然又dispose了一个已经dispose过的");
            } else {
                destroyed = true;
            }

            if (gameObject != null) {
                GameObject.Destroy (gameObject);
                gameObject = null;
            }

            prefeb = null;
            transform = null;
            info = null;
            childParticleList = null;
            canDoScaleParticleList = null;
            childAnimationList = null;
            childAnimatorList = null;
            childTrailRendererList = null;
            childLineRenderList = null;
            childRenderList = null;
            effectStatus = ENEffectStatus.EffectState_NULL;
        }

    }
	

	 public class EffectInfo
    {
        public string id;
        public string name;
        public string path;
        //缓冲池以实际资源名为ID
        public string resID;
        public string resName;
        public float duration;
        public string slotPos;//人物身上绑点
        public float delay;
        public float FadeInTime;
        public float FadeOutTime;
        public int BindType;
        public EffectInfo()
        { }

        public EffectInfo(LuaTable fxTable)
        {
            id = fxTable.GetInPath<string>("id");
            path = fxTable.GetInPath<string>("path");
            resName = fxTable.GetInPath<string>("res");
            resID = path;
            duration = fxTable.GetInPath<float>("duration") / 1000;
            slotPos = fxTable.GetInPath<string>("slotPos");
            delay = fxTable.GetInPath<float>("delay") / 1000;
            FadeInTime = fxTable.GetInPath<float>("FadeInTime") / 1000;
            FadeOutTime = fxTable.GetInPath<float>("FadeOutTime") / 1000;
            BindType = fxTable.GetInPath<int>("BindType");
        }
    }


}