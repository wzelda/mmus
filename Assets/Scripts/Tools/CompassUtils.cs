using System;
using System.Collections.Generic;
using UnityEngine;

namespace LPCFramework
{
    /// <summary>
    /// 指南针工具箱
    /// </summary>
    public class CompassUtils
    {    
        /// <summary>
        /// 单例
        /// </summary>
        private static CompassUtils _instance;
        /// <summary>
        /// 执行列表
        /// </summary>
        private Dictionary<string, Action<float>> _actionList = new Dictionary<string, Action<float>>();
        
        /// <summary>
        /// 单例
        /// </summary>
        public static CompassUtils Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = new CompassUtils();
                    Input.compass.enabled = true;
                }
                return _instance;
            }
        }
        
        /// <summary>
        /// 添加执行指令
        /// </summary>
        /// <param name="act"></param>
        public void AddAction(string key, Action<float> act)
        {
            if (_actionList != null)
            {
                if (_actionList.ContainsKey(key))
                {
                    _actionList.Remove(key);
                }
                _actionList.Add(key, act);
            }
        }
        
        /// <summary>
        /// 移除执行的方法
        /// </summary>
        /// <param name="key"></param>
        public void RemoveAction(string key)
        {
            if (_actionList != null)
            {
                if (_actionList.ContainsKey(key))
                {
                    _actionList.Remove(key);
                }
            }
        }
        
        /// <summary>
        /// 每帧更新数值
        /// </summary>
        public void Update() {
            if (_actionList == null)
            {
                return;
            }
            foreach (var act in _actionList)
            {
                if (act.Value == null)
                {
                    continue;
                }
                act.Value(Input.compass.trueHeading);
            }
        }

        /// <summary>
        /// 清除所有的方法
        /// </summary>
        public void ClearActions()
        {
            if (_actionList == null)
            {
                return;
            }
            
            _actionList.Clear();
           
        }
    }    
}