using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;
using XLua;

//相机过渡脚本
namespace LPCFramework
{
    [LuaCallCSharp]
    public class CameraFade : MonoBehaviour
    {
        protected Vector3 targetPos;
        protected Quaternion targetRot;
        protected float duration = 0.5f;   //过渡时间
        protected Vector3 oldPos;
        protected Quaternion oldRot;
        protected Vector3 fromPos;
        protected Quaternion fromRot;
        protected Vector3 wholeDist;
        protected DateTime startTime;
        protected float lastTime;
        protected float range;
        protected bool runFade = false;
        protected bool runnedFade = false;

        public void StartFade(Transform targetPos, float duration, bool savePos = true)
        {
            if (!targetPos) return;
            StartFade(targetPos.position, targetPos.rotation, duration, savePos);
        }

        public void StartFade(Vector3 targetPos, Quaternion targetRot, float duration, bool savePos = true)
        {
            this.targetPos = targetPos;
            this.targetRot = targetRot;
            this.duration = duration;
            if (savePos)
            {
                oldPos = this.transform.position;
                oldRot = this.transform.rotation;
            }
            fromPos = this.transform.position;
            fromRot = this.transform.rotation;
            this.wholeDist = this.targetPos - this.transform.position;
            startTime = DateTime.Now;
            lastTime = 0;
            runFade = true;
            runnedFade = true;
        }

        public void ReturnFromFade(float duration)
        {
            if (runnedFade)
            {
                StartFade(oldPos, oldRot, duration, false);
                runnedFade = false;
            }
        }

        public void StopFade()
        {
            //if (this.camera)
            //    this.camera.transform.position = oldCameraPos;
            runFade = false;
        }

        public void Update()
        {
            if (runFade)
            {
                float dt = (float)(DateTime.Now - startTime).TotalSeconds;
                if (dt < duration)
                {
                    float percent = dt / duration;
                    Vector3 delta = this.wholeDist * percent;
                    this.transform.position = fromPos + (delta);
                    if (targetRot != null)
                    {
                        this.transform.rotation = Quaternion.Lerp(fromRot, targetRot, percent);
                    }
                    lastTime = dt;
                }
                else
                {
                    this.transform.position = targetPos;
                    this.transform.rotation = targetRot;
                    runFade = false;
                }
            }
        }

    }
}