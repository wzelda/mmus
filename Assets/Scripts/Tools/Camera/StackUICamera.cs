using System.Collections;
using System.Collections.Generic;
using System;
using UnityEngine;
using UnityEngine.Rendering.Universal;

#if !FISHING_ART
using FairyGUI;
#endif

[DefaultExecutionOrder(1000)]
[RequireComponent(typeof(Camera))]
public class StackUICamera : MonoBehaviour
{
    private void OnEnable()
    {
#if !FISHING_ART
        var data = GetComponent<Camera>().GetUniversalAdditionalCameraData();
        if (!data.cameraStack.Contains(StageCamera.main))
        {
            data.cameraStack.Add(StageCamera.main);
        }
#endif
    }
}
