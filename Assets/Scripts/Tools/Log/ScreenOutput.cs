using System;
using System.Collections;
using System.Threading;
using System.Collections.Generic;
using UnityEngine;
using FairyGUI;

namespace LPCFramework
{
    public class ScreenOutput : ILogOutput
    {
        #region Inspector Settings

        /// <summary>  
        /// The hotkey to show and hide the console window.  
        /// </summary>  
        public KeyCode toggleKey = KeyCode.Escape;

        /// <summary>  
        /// Whether to open the window by shaking the device (mobile-only).  
        /// </summary>  
        public bool shakeToOpen = true;

        /// <summary>  
        /// The (squared) acceleration above which the window should open.  
        /// </summary>  
        public float shakeAcceleration = 3f;

        /// <summary>  
        /// Whether to only keep a certain number of logs.  
        ///  
        /// Setting this can be helpful if memory usage is a concern.  
        /// </summary>  
        public int maxLogNum = 200;

        #endregion

        List<LogManager.LogData> logs = new List<LogManager.LogData>();
        private List<LogManager.LogData> _errorLogs = new List<LogManager.LogData>();
        Vector2 scrollPosition;
        bool collapse;
        public bool visible;

        public bool showError
        {
            get;
            set;
        }    

        static string pkgPath = null;
        static GComponent view = null;
        static GList recordList = null;
        static GButton closeBtn, clearBtn, errBtn;

        public ScreenOutput()
        {
            
        }

        //日志UI
        public void CreateUI(){
            UIPackage.AddPackage("UI/ScreenLog/ScreenLog");
            view = UIPackage.CreateObject("ScreenLog", "ScreenLog").asCom;
            view.sortingOrder = 3000;
            GRoot.inst.AddChild(view);
            recordList = view.GetChild("List").asList;
            recordList.SetVirtual();
            closeBtn = view.GetChild("CloseBtn").asButton;
            clearBtn = view.GetChild("ClearBtn").asButton;
            errBtn = view.GetChild("ErrorBtn").asButton;
            recordList.itemRenderer = ItemRanderer;
            closeBtn.onClick.Add(()=>{SetVisible(false);});
            clearBtn.onClick.Add(()=>{
                logs.Clear();
                _errorLogs.Clear();
                recordList.numItems = logs.Count;
                
                if (LogManager.Instance.ErrorTriggle != null)
                {
                    LogManager.Instance.ErrorTriggle();
                }
            });
            
            errBtn.onClick.Add(() =>
            {
                showError = !showError;
                if (showError)
                {
                    recordList.numItems = _errorLogs.Count;
                }
                else
                {
                    recordList.numItems = logs.Count;    
                }
                
            });
            view.visible = visible;
        }
        public void SetVisible(bool v)
        {
            visible = v;
            if(view != null){
                view.visible = v;
            }else{
                CreateUI();
            }
            if(v){
                recordList.numItems = logs.Count;
                if(logs.Count > 0){
                    recordList.ScrollToView(logs.Count - 1);
                }
            }
        }
		//获取错误数量
		public int GetErrorNum()
        {
            return _errorLogs.Count;
        }
		
        /// <summary>  
        /// Displays a scrollable list of logs.  
        /// </summary>  
        void ItemRanderer(int index, GObject obj)
        {
            if (showError)
            {
                obj.asCom.GetController("LogLevel").selectedIndex = (int)_errorLogs[index].Level;
                string t = string.Format("{0}\t{1}\n", _errorLogs[index].Log, _errorLogs[index].Track);
                obj.asCom.GetChild("Text").text = t;
            }
            else
            {
                obj.asCom.GetController("LogLevel").selectedIndex = (int)logs[index].Level;
                string t = string.Format("{0}\t{1}\n", logs[index].Log, logs[index].Track);
                obj.asCom.GetChild("Text").text = t;   
            }
        }
        


        /// <summary>  
        /// Records a log from the log callback.  
        /// </summary>  
        /// <param name="message">Message.</param>  
        /// <param name="stackTrace">Trace of where the message came from.</param>  
        /// <param name="type">Type of message (error, exception, warning, assert).</param>  
        public void Log(LogManager.LogData logData)
        {
            //只有大于等于这个等级的才会输出到文件
            if (logData.Level >= LogManager.Instance.uiOutputLogLevel)
            {
                logs.Add(logData);
                if(logs.Count > maxLogNum){
                    logs.RemoveAt(0);
                }
                if(view!= null && visible && !showError){
                    recordList.numItems = logs.Count;
                    if(logs.Count > 0){
                        recordList.ScrollToView(logs.Count - 1);
                    }
                }

                if (logData.Level == LogLevel.ERROR)
                {
                    _errorLogs.Add(logData);              
                    if(_errorLogs.Count > maxLogNum){
                        _errorLogs.RemoveAt(0);
                    }
                    if(view!= null && visible && showError){
                        recordList.numItems = _errorLogs.Count;
                        if(logs.Count > 0){
                            recordList.ScrollToView(logs.Count - 1);
                        }
                    }

                    if (LogManager.Instance.ErrorTriggle != null)
                    {
                        LogManager.Instance.ErrorTriggle();
                    }
                }
            }
        }
 

        public void Close()
        {
            if(view != null){
                recordList.itemRenderer = null;
                closeBtn.onClick.Clear();
                clearBtn.onClick.Clear();
                view.Dispose();
                view = null;
            }
        }
    }
}
