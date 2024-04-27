using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;

//相机震动脚本
public class CameraShake : MonoBehaviour
{
    public float amplitudeX = 0.2f;    //上下幅度
    public float amplitudeY = 0.4f;    //左右幅度
    public float duration = 0.25f;   //震屏时间
    public float shakeTime = 5;     //震屏次数

    public Vector3 oldCameraPos;
    public DateTime startTime;
    public float range;
    public Transform targetTrans;
    public bool enableShake = false;

    //public void OnEnable()
    //{
    //    StartShake();
    //}

    public void StartShake(Camera targetCamera = null)
    {
        targetCamera = targetCamera == null ? Camera.main : targetCamera;
        if (targetCamera == null) return;
        targetTrans = targetCamera.transform;
        oldCameraPos = targetCamera.transform.position;
        startTime = DateTime.Now;
        range = shakeTime * 2 * Mathf.PI;
        enableShake = true;
    }
    public void StopShake()
    {
        if (targetTrans)
            targetTrans.position = oldCameraPos;
        enableShake = false;
    }

    public void Update()
    {
        if (enableShake)
        {
            float dt = (float)(DateTime.Now - startTime).TotalSeconds;

            if (dt < duration)
            {
                float factor = 1;
                float percent = dt / duration;
                float angle = range * percent;
                float xo = amplitudeX * (float)Math.Cos(angle);
                float yo = amplitudeY * (float)Math.Sin(angle);

                factor = percent;

                xo *= factor;
                yo *= factor;

                if (targetTrans)
                    targetTrans.Translate(new Vector3(xo, yo, 0));
            }
            else
            {
                StopShake();
            }
        }
    }

}
