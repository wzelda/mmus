using UnityEngine;

/// <summary>
/// 平台控制器
/// </summary>
public class TouchControllerBase
{
    protected TouchCallback.Begin m_beginCallback;
    protected TouchCallback.Move m_moveCallback;
    protected TouchCallback.Scale m_scaleCallback;
    protected TouchCallback.End m_endCallback;

    /// <summary>
    /// 初始化回调函数
    /// </summary>
    /// <param name="beginCallback">Begin callback.</param>
    /// <param name="moveCallback">Move callback.</param>
    /// <param name="scaleCallback">Scale callback.</param>
    /// <param name="updateCallback">Update callback.</param>
    /// <param name="endCallback">End callback.</param>
    public virtual void Init(TouchCallback.Begin beginCallback, TouchCallback.Move moveCallback, TouchCallback.Scale scaleCallback, TouchCallback.End endCallback)
    {
        this.m_beginCallback = beginCallback;
        this.m_moveCallback = moveCallback;
        this.m_scaleCallback = scaleCallback;
        this.m_endCallback = endCallback;
    }


    public virtual void Update() { }
}

