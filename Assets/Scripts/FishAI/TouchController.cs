using UnityEngine;

/// <summary>
/// 触碰控制器
/// </summary>
public class TouchController : TouchControllerBase
{
    /// <summary>
    /// 修正比例
    /// </summary>
    private float m_rate = 50f;

    /// <summary>
    /// 最后一次缩放距离
    /// </summary>
    private float m_lastScaleDistance;

    /// <summary>
    /// 当前缩放距离
    /// </summary>
    private float m_scaleDistance;

    /// <summary>
    /// 是否开始缩放
    /// </summary>
    private bool m_isStartZoom = true;

    private float m_inertiaDuration = 1.0f;
    private float m_scrollVelocity = 0.0f;
    private float m_timeTouchPhaseEnded;
    private Vector2 m_scrollDirection = Vector2.zero;
    private Vector2 m_lastMovePosition;
    private int dragFingerId = -1; // 当前拖拽的FingerId，防止多点触摸产生跳跃

    public override void Update()
    {
        
        // 如果只有一个触点
        if (Input.touchCount == 1)
        {
            var m_oneTouch = Input.touches[0];

            // 触点开始
            if (m_oneTouch.phase == TouchPhase.Began)
            {
                // 触发开始回调函数
                if (this.m_beginCallback != null)
                {
                    this.m_beginCallback(m_oneTouch.position);
                }
                m_scrollVelocity = 0.0f;
                m_lastMovePosition = m_oneTouch.position;
                dragFingerId = m_oneTouch.fingerId;
            }
            // 触点移动
            else if (m_oneTouch.phase == TouchPhase.Moved)
            {
                // 多点触摸时需要检测触摸点是否发生改变
                if (dragFingerId != m_oneTouch.fingerId)
                {
                    if (this.m_beginCallback != null)
                    {
                        this.m_beginCallback(m_oneTouch.position);
                    }

                    m_scrollVelocity = 0.0f;
                    m_lastMovePosition = m_oneTouch.position;
                    dragFingerId = m_oneTouch.fingerId;
                }

                Vector2 delta = m_oneTouch.deltaPosition;

                m_scrollDirection = delta.normalized;
                m_scrollVelocity = delta.magnitude / m_oneTouch.deltaTime;

                if (m_scrollVelocity <= 100)
                {
                    m_scrollVelocity = 0;
                }
                // 触发移动回调函数
                if (this.m_moveCallback != null)
                {
                    this.m_moveCallback(m_lastMovePosition, m_oneTouch.position);
                }
                m_lastMovePosition = m_oneTouch.position;
            }
            // 触点结束
            else if (m_oneTouch.phase == TouchPhase.Ended)
            {
                m_timeTouchPhaseEnded = Time.time;
                // 触发结束回调函数
                if (this.m_endCallback != null)
                {
                    this.m_endCallback();
                }
                dragFingerId = -1;
            }
        }
        else
        {
            dragFingerId = -1;
        }

        // 如果有多个触点
        if (Input.touchCount > 1)
        {
            var m_oneTouch = Input.touches[0];
            var m_twoTouch = Input.touches[1];

            // 如果是缩放
            if (m_oneTouch.phase == TouchPhase.Moved || m_twoTouch.phase == TouchPhase.Moved)
            {
                if (m_isStartZoom)
                {
                    this.m_lastScaleDistance = Vector2.Distance(m_oneTouch.position, m_twoTouch.position);
                    m_isStartZoom = false;
                }

                this.m_scaleDistance = Vector2.Distance(m_oneTouch.position, m_twoTouch.position);
                // 触发缩放回调函数
                this.m_scaleCallback((this.m_scaleDistance - this.m_lastScaleDistance) / this.m_rate);
                this.m_lastScaleDistance = this.m_scaleDistance;
            }

            if (m_oneTouch.phase == TouchPhase.Ended || m_twoTouch.phase == TouchPhase.Ended)
            {
                m_isStartZoom = true;
            }
        }

        // 触发每帧执行更新
        if (this.m_moveCallback != null && Input.touchCount == 0)
        {
            if (m_scrollVelocity != 0.0f)
            {
                Vector2 pos = m_lastMovePosition;

                float t = (Time.time - m_timeTouchPhaseEnded) / m_inertiaDuration;
                float frameVelocity = Mathf.Lerp(m_scrollVelocity, 0.0f, t);
                pos += m_scrollDirection.normalized * frameVelocity * Time.deltaTime;

                if (t >= 1.0f)
                {
                    m_scrollVelocity = 0.0f;
                }

                this.m_moveCallback(m_lastMovePosition, pos);
                m_lastMovePosition = pos;
            }
        }
    }
    
}

