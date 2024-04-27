using UnityEngine;

/// <summary>
/// 触碰回调函数
/// </summary>
public class TouchCallback
{
    // 开始回调函数，（按钮按下、触碰）触发一次
    public delegate void Begin(Vector2 pos);

    // 移动回调函数，移动时触发
    public delegate void Move(Vector2 from, Vector2 to);

    // 缩放回调函数，缩放时触发
    public delegate void Scale(float distance);

    // 结束回调函数，（按钮松开，触离）触发一次
    public delegate void End();
}