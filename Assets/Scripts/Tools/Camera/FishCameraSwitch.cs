using DG.Tweening;
using DG.Tweening.Plugins.Options;
using DG.Tweening.Core;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BehaviorDesigner.Runtime.Tasks;

/// <summary>
/// 这个组件用于在折叠UI界面时，改变摄像机的FOV和角度
/// </summary>
[DisallowMultipleComponent]
public class FishCameraSwitch : MonoBehaviour
{
    private Camera mViewCamera = null;

    public float fovOrigin;
    public Vector3 rotationOrigin;
    public Vector3 positionOrigin;

    // helpTransform用于镜头对焦
    private Transform helpTransform;
    // rotateTransform用于镜头旋转
    private Transform rotateTransform;
    // 相机的实际坐标系
    private Transform camTransform;

    public Camera EnsureCamera()
    {
        if (mViewCamera == null)
        {
            ViewCamera = GetComponent<Camera>();
        }
        return mViewCamera;
    }

    public Camera ViewCamera
    {
        get
        {
            return mViewCamera;
        }
        set
        {
            mViewCamera = value;
            fovOrigin = value.fieldOfView;
            camTransform = value.transform;
            positionOrigin = camTransform.position;
            rotationOrigin = camTransform.eulerAngles;

            var helpObj = new GameObject("help");
            helpObj.hideFlags = HideFlags.DontSave;
            helpTransform = helpObj.transform;
            helpTransform.SetPositionAndRotation(camTransform.position, camTransform.rotation);
            var rotateObj = new GameObject("rotate");
            rotateObj.hideFlags = HideFlags.DontSave;
            rotateTransform = rotateObj.transform;
            rotateTransform.SetParent(helpTransform, false);
            rotateTransform.SetPositionAndRotation(camTransform.position, camTransform.rotation);
        }
    }
       

    // 切换角度，ratio为新的画面对比原来画面的高度
    public TweenerCore<float, float, FloatOptions> Switch(float ratio, float duration, float maxFov)
    {
        var viewCamera = EnsureCamera();
        // 计算新的FOV
        var c = Mathf.Cos(Mathf.Deg2Rad * fovOrigin) + 2 * ratio - 1;
        var s = Mathf.Sin(Mathf.Deg2Rad * fovOrigin);
        var targetFOV = Mathf.Atan2(s, c) * 2 * Mathf.Rad2Deg;

        if (targetFOV > maxFov)
        {
            targetFOV = maxFov;
        }
        //Debug.LogFormat(this, "originFov: {0} ratio: {1} targetFOV: {2}", fovOrigin, ratio, targetFOV);
        return DOTween.To(() => viewCamera.fieldOfView, (v) =>
        {
            viewCamera.fieldOfView = v;
            var angles = new Vector3();
            // 摄像机的X旋转角度跟随FOV变化
            angles.x = (v - fovOrigin) / 2;
            rotateTransform.localEulerAngles = angles;

            ApplyCameraTransform();
        },
        targetFOV, duration);
    }

    public void ApplyCameraTransform()
    {
        camTransform.position = rotateTransform.position;
        camTransform.rotation = rotateTransform.rotation;
    }

    public TweenerCore<float, float, FloatOptions> SwitchFov(float ratio, float duration,System.Action callBack)
    {
        var viewCamera = EnsureCamera();
        // 计算新的FOV
        var targetFOV = Mathf.Asin(Mathf.Sin(Mathf.Deg2Rad * fovOrigin / 2) / ratio) * 2 * Mathf.Rad2Deg;

        return DOTween.To(() => viewCamera.fieldOfView, (v) =>
        {
            viewCamera.fieldOfView = v;
        },
        targetFOV, duration).OnComplete(()=>{
            if (null !=callBack)
            {
                callBack();
            }
        });
    }

    // 还原原始视角
    public TweenerCore<float, float, FloatOptions> RevertOrigin(float duration)
    {
        var viewCamera = EnsureCamera();

        return DOTween.To(() => viewCamera.fieldOfView, (v) =>
        {
            viewCamera.fieldOfView = v;
            var angles = new Vector3();
            // 摄像机的X旋转角度跟随FOV变化
            angles.x = (v - fovOrigin) / 2;
            rotateTransform.localEulerAngles = angles;

            ApplyCameraTransform();
        },
        fovOrigin, duration);
    }

    // 调整位置和角度
    public Tween TweenLookAt(Vector3 position, Vector3 rotation, float duration, TweenCallback callback)
    {
        Debug.Log("LookAt " + position.ToString() + " " + rotation.ToString());
        DOTween.Kill(helpTransform);
        var s = DOTween.Sequence();
        s.Append(helpTransform.DOMove(position, duration));
        s.Join(helpTransform.DORotate(rotation, duration));
        s.OnUpdate(() =>
        {
            ApplyCameraTransform();
        });
        s.OnComplete(callback);
        return s;
    }

    // 还原位置和角度
    public Tween RevertOriginPosition(float duration, TweenCallback callback)
    {
        DOTween.Kill(helpTransform);
        var s = DOTween.Sequence();
        s.Append(helpTransform.DOMove(positionOrigin, duration));
        s.Join(helpTransform.DORotate(rotationOrigin, duration));
        s.OnUpdate(() =>
        {
            ApplyCameraTransform();
        });
        if (callback != null)
        {
            s.OnComplete(callback);
        }
        return s;
    }
}