using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

namespace LPCFramework{
[LuaCallCSharp]
//相机各个效果
public class CameraEffectUtil
{

    //相机震动
    public static void StartShake()
    {
            CameraShake shakeScript = Camera.main.gameObject.AddComponentIfNotExist<CameraShake>();
            shakeScript.StartShake();
    }

    //设置相机模糊
    public static void SetSceneBlur(bool isOpen, float blurSpread)
    {
        /* if (isOpen)
        {
            var blur = Camera.main.gameObject.AddComponentIfNotExist<.ImageEffects.Blur>();
            Shader blurShader = Shader.Find("Hidden/BlurEffectConeTap");
            blur.blurSpread = blurSpread;
            blur.blurShader = blurShader;
        }
        else
        {
            if (Camera.main && Camera.main.gameObject)
                Camera.main.gameObject.RemoveComponentIfExist<UnityStandardAssets.ImageEffects.Blur>();
        } */
    }
}
}