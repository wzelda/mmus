using UnityEngine;
using System.Collections;

/// <summary>
/// 鼠标控制器
/// </summary>
public class MouseController : TouchControllerBase
{
    /// 鼠标枚举
    enum MouseTypeEnum
    {
        LEFT = 0
    }

    /// <summary>
    /// 缩放距离
    /// </summary>
    private float m_scrollDistance;

    /// <summary>
    /// 鼠标按住状态
    /// </summary>
    private bool m_mousePressStatus;

    private Vector3 oldMousePosition;

    public override void Update()
    {
        // 按下鼠标、轴
        if (!this.m_mousePressStatus && Input.GetMouseButton((int)MouseTypeEnum.LEFT))
        {
            oldMousePosition = Input.mousePosition;
            this.m_mousePressStatus = true;
            // 触发开始回调函数
            if (this.m_beginCallback != null) this.m_beginCallback(oldMousePosition);
        }

        // 松开鼠标、轴
        if (this.m_mousePressStatus && !Input.GetMouseButton((int)MouseTypeEnum.LEFT))
        {
            this.m_mousePressStatus = false;
            // 触发结束回调函数
            if (this.m_endCallback != null) this.m_endCallback();
        }

        // 如果鼠标在按住状态
        if (this.m_mousePressStatus)
        {
            // 触发移动回调函数
            var delta = Input.mousePosition - oldMousePosition;
            delta.x = delta.x / Screen.width;
            delta.y = delta.y / Screen.height;
            if (this.m_moveCallback != null) this.m_moveCallback(oldMousePosition, Input.mousePosition);
            oldMousePosition = Input.mousePosition;
        }

        // 鼠标滚轮拉近拉远
        this.m_scrollDistance = Input.GetAxis("Mouse ScrollWheel");

        // 触发缩放回调函数
        if (this.m_scrollDistance != 0f && this.m_scaleCallback != null)
        {
            this.m_scaleCallback(this.m_scrollDistance * 10);
        }
        
    }
}

