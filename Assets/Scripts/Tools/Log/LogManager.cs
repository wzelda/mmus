/*
*===============================================================
*
*Created:  02/11/2017 11:37
*Author:   Better
*Company:  LightPaw
*
*================================================================
*/

using System;
using UnityEngine;
using System.Collections.Generic;
using System.Threading;
using XLua;

namespace LPCFramework
{
    /// <summary>
    /// 日志等级，为不同输出配置用
    /// </summary>
    [LuaCallCSharp]
    public enum LogLevel
    {
        LOG = 0,
        WARNING = 1,
        ERROR = 2,
        ASSERT = 3,
        EXCEPTION = 4,
        LUALOG = 5,
        MAX = 6,
    }

    /// <summary>
    /// 封装日志模块
    /// </summary>
    [LuaCallCSharp]
    public class LogManager : SingletonMonobehaviour<LogManager>, IManager
    {
        /// <summary>
        /// 日志数据类
        /// </summary>
        public class LogData
        {
            public string Log { get; set; }
            public string Track { get; set; }
            public LogLevel Level { get; set; }
            public string recordTime { get; set; }  //错误记录时间
        }
        /// <summary>
        /// UI输出日志等级，只要大于等于这个级别的日志，都会输出到屏幕
        /// </summary>
       public LogLevel uiOutputLogLevel = LogLevel.ERROR;
        /// <summary>
        /// 文本输出日志等级，只要大于等于这个级别的日志，都会输出到文本
        /// </summary>
       public LogLevel fileOutputLogLevel = LogLevel.ERROR;
        /// <summary>
        /// 网络上传输出日志等级
        /// </summary>
        public LogLevel netOutputLogLevel = LogLevel.ERROR;
        /// <summary>
        /// unity日志和日志输出等级的映射
        /// </summary>
       private Dictionary<LogType, LogLevel> logTypeLevelDict = null;
        /// <summary>
        /// 日志输出列表
        /// </summary>
        private List<ILogOutput> logOutputList = null;
        private int mainThreadID = -1;

        public Action ErrorTriggle;
        /// <summary>
        /// 日志调用回调，主线程和其他线程都会回调这个函数，在其中根据配置输出日志
        /// </summary>
        /// <param name="log">日志</param>
        /// <param name="track">堆栈追踪</param>
        /// <param name="type">日志类型</param>
        void LogCallback(string log, string track, LogType type)
        {
            if (this.mainThreadID == Thread.CurrentThread.ManagedThreadId)
                Output(log, track, type);
        }

        void LogMultiThreadCallback(string log, string track, LogType type)
        {
            if (this.mainThreadID != Thread.CurrentThread.ManagedThreadId)
                Output(log, track, type);
        }

        public void Output(string log, string track, LogType type)
        {
            LogLevel level = this.logTypeLevelDict[type];
            LogData logData = new LogData
            {
                Log = log,
                Track = track,
                Level = level,
                recordTime = System.DateTime.Now.ToString()
            };
            for (int i = 0; i < this.logOutputList.Count; ++i)
            {
                this.logOutputList[i].Log(logData);
            }
        }

        public void OutputToScreen(string log, string track, int type)
        {
            LogLevel level = (LogLevel)type;
            LogData logData = new LogData
            {
                Log = log,
                Track = track,
                Level = level,
                recordTime = System.DateTime.Now.ToString()
            };
            for (int i = 0; i < this.logOutputList.Count; ++i)
            {
                if (this.logOutputList[i].GetType() == typeof(ScreenOutput)) {
                    this.logOutputList[i].Log(logData);
                }
            }
        }

        public void OpenScreenOutLog()
        {
            for (int i = 0; i < this.logOutputList.Count; ++i)
            {
                if (this.logOutputList[i].GetType() == typeof(ScreenOutput))
                {
                    ScreenOutput so = this.logOutputList[i] as ScreenOutput;
                    so.SetVisible(!so.visible);
                }
            }
        }

        public void OnInitialize()
        {
            Application.logMessageReceived += LogCallback;
            Application.logMessageReceivedThreaded += LogMultiThreadCallback;

            if (this.logTypeLevelDict == null)
            {
                this.logTypeLevelDict = new Dictionary<LogType, LogLevel>
                        {
                                { LogType.Log, LogLevel.LOG },
                                { LogType.Warning, LogLevel.WARNING },
                                { LogType.Assert, LogLevel.ASSERT },
                                { LogType.Error, LogLevel.ERROR },
                                { LogType.Exception, LogLevel.ERROR },
                        };
                this.uiOutputLogLevel = LogLevel.ERROR;
                this.fileOutputLogLevel = LogLevel.ERROR;
                this.netOutputLogLevel = LogLevel.ERROR;
                this.mainThreadID = Thread.CurrentThread.ManagedThreadId;
                this.logOutputList = new List<ILogOutput>
                        {
                                //new FileLogOutput(),
                                //new NetLogOutput(),
                                new ScreenOutput()
                        };
            }
        }
        
        /// <summary>
        /// 获取错误数量
        /// </summary>
        /// <returns></returns>
        public int GetErrorNum()
        {
            if (this.logOutputList == null)
            {
                return 0;
            }

            var errorNum = 0;
            foreach (var l in this.logOutputList)
            {
                if (l != null)
                {
                    errorNum += l.GetErrorNum();
                }
            }

            return errorNum;
        }

        public void OnUpdate()
        {

        }

        public static void Destruct()
        {
            if (_S != null)
            {
                _S.OnDestruct();
            }
        }

        public void OnDestruct()
        {
            Application.logMessageReceived -= LogCallback;
            Application.logMessageReceivedThreaded -= LogMultiThreadCallback;
            for (int i = 0; i < this.logOutputList.Count; ++i)
                this.logOutputList[i].Close();
            
            ErrorTriggle = null;
        }
    }
}