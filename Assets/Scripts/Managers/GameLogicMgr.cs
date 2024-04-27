using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;

public class TickItem
{
    System.Action endCb;
    float lifetime;
    float tick;    
    public void Refresh(System.Action cb, float lifeTime)
    {
        endCb = cb;
        lifetime = lifeTime;
        tick = 0;
    }

    public void Update()
    {
        tick += Time.unscaledDeltaTime;
        if (tick >= lifetime)
        {
            if (endCb != null)
            {
                endCb();
            }
        }
    }
}


public class LogicRun
{
    public System.Action cb;
    public Boolean isRemove = false;
}


public class GameLogicMgr : SingletonMonobehaviour<GameLogicMgr>
{
    private List<LogicRun> m_OnUpdate = new List<LogicRun>();

    private int curFrame;

    /// <summary>
    /// 设置当前游戏帧数
    /// </summary>
    /// <param name="frame"></param>
    public void SetGameFrame(int frame)
    {
        if (curFrame != frame)
        {
            curFrame = frame;
            Application.targetFrameRate = frame;
        }
    }
    
    public void LogicUpdate()
    {
        for (int i = m_OnUpdate.Count - 1; i >= 0; i--)
        {
            if (m_OnUpdate[i] == null || m_OnUpdate[i].isRemove)
            {
                m_OnUpdate.RemoveAt(i);
            }
        }

        for (int i = 0; i < m_OnUpdate.Count; i++)
        {
            if (m_OnUpdate[i].isRemove)
            {
                continue;
            }

            try
            {
                m_OnUpdate[i].cb();
            }
            catch (System.Exception ex)
            {
               UnityEngine.Debug.LogError("[Error] " + ex.StackTrace + "  " + ex.Message);
            }
        }
    }

    public LogicRun FindUpdate(System.Action cb)
    {
        for (int i = 0; i < m_OnUpdate.Count; i++)
        {
            if (m_OnUpdate[i].cb == cb)
            {
                return m_OnUpdate[i];
            }
        }

        return null;
    }


    public void AddUpdate(System.Action cb)
    {
        if (null == cb)
        {
            return;
        }

        LogicRun tCb = FindUpdate(cb);

        if (tCb != null)
        {
            tCb.isRemove = false;
            //Debug.LogWarning("[Error]Add Update Repeated " + cb.Target + "===> " + cb.Method);
            return;
        }

        tCb = new LogicRun();
        tCb.cb = cb;
        m_OnUpdate.Add(tCb);

    }

    public void RemoveUpdate(System.Action cb)
    {
        for (int i = 0; i < m_OnUpdate.Count; i++)
        {
            if (m_OnUpdate[i].cb == cb)
            {
                m_OnUpdate[i].isRemove = true;
                break;
            }
        }
    }

    public void ClearAll()
    {
        for (int i = 0; i < m_OnUpdate.Count; i++)
        {
            m_OnUpdate[i].isRemove = true;
        }
    }

}