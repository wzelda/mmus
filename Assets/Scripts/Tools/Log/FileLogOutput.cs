/*
*===============================================================
*
*Created:  02/11/2017 11:36
*Author:   Better
*Company:  LightPaw
*
*================================================================
*/
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.IO;
using UnityEngine;

namespace LPCFramework
{

    /// <summary>
    /// 文本日志输出
    /// </summary>
   public class FileLogOutput : ILogOutput
    {

#if UNITY_EDITOR
                string mDevicePersistentPath = Application.dataPath + "/../PersistentPath";

#elif UNITY_STANDALONE_WIN
                string mDevicePersistentPath = Application.dataPath + "/PersistentPath";

#elif UNITY_STANDALONE_OSX
                string mDevicePersistentPath = Application.dataPath + "/PersistentPath";

#else
                string mDevicePersistentPath = Application.persistentDataPath;

#endif

        static string LogPath = "Log";

        private Queue<LogManager.LogData> mWritingLogQueue = null;
        private Queue<LogManager.LogData> mWaitingLogQueue = null;
        private object mLogLock = null;
        private Thread mFileLogThread = null;
        private bool mIsRunning = false;
        private StreamWriter mLogWriter = null;

        public FileLogOutput()
        {
            this.mWritingLogQueue = new Queue<LogManager.LogData>();
            this.mWaitingLogQueue = new Queue<LogManager.LogData>();
            this.mLogLock = new object();
            System.DateTime now = System.DateTime.Now;
            string logName = string.Format("Q{0}_{1}_{2}_{3}",
                    now.Year, now.Month, now.Day, now.Hour);
            string logPath = string.Format("{0}/{1}/{2}.txt", mDevicePersistentPath, LogPath, logName);
            string logDir = Path.GetDirectoryName(logPath);
            if (!Directory.Exists(logDir))
                Directory.CreateDirectory(logDir);
            if (!File.Exists(logPath))
            {
               FileStream fs = File.Create(logPath);
               fs.Close();
            }
        
            this.mLogWriter = new StreamWriter(logPath,true);
            this.mLogWriter.AutoFlush = true;
            this.mIsRunning = true;
            this.mFileLogThread = new Thread(new ThreadStart(WriteLog));
            this.mFileLogThread.Start();
        }

        void WriteLog()
        {
            while (this.mIsRunning)
            {
                if (this.mWritingLogQueue.Count == 0)
                {
                    lock (this.mLogLock)
                    {
                        while (this.mWaitingLogQueue.Count == 0)
                            Monitor.Wait(this.mLogLock);
                        Queue<LogManager.LogData> tmpQueue = this.mWritingLogQueue;
                        this.mWritingLogQueue = this.mWaitingLogQueue;
                        this.mWaitingLogQueue = tmpQueue;
                    }
                }
                else
                {
                    while (this.mWritingLogQueue.Count > 0)
                    {
                        LogManager.LogData log = this.mWritingLogQueue.Dequeue();
                        if (log.Level == LogLevel.ERROR)
                        {
                            this.mLogWriter.WriteLine("---------------------------------------------------------------------------------------------------------------------");
                            this.mLogWriter.WriteLine(System.DateTime.Now.ToString() + "\t" + log.Log + "\n");
                            this.mLogWriter.WriteLine(log.Track);
                            this.mLogWriter.WriteLine("---------------------------------------------------------------------------------------------------------------------");
                        }
                        else
                        {
                            this.mLogWriter.WriteLine(System.DateTime.Now.ToString() + "\t" + log.Log);
                        }
                    }
                }
            }
        }

        public void Log(LogManager.LogData logData)
        {
            //只有大于等于这个等级的才会输出到文件
            if (logData.Level >= LogManager.Instance.fileOutputLogLevel)
            {
                lock (this.mLogLock)
                {
                    this.mWaitingLogQueue.Enqueue(logData);
                    Monitor.Pulse(this.mLogLock);
                }
            }
        }

        public int GetErrorNum()
        {
            return 0;
        }

        public void Close()
        {
            this.mIsRunning = false;
            this.mLogWriter.Close();
        }
    }
}