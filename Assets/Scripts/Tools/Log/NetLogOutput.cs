/*
*===============================================================
*
*Created:  #CREATIONDATE#
*Author:   #DEVELOPERNAME#
*Company:  #COMPANY#
*
*================================================================
*/
using System;
using System.Collections;
using System.Threading;
using System.Collections.Generic;
using UnityEngine;
using System.Net;


namespace LPCFramework
{
    public class NetLogOutput : ILogOutput
    {

        private Queue<LogManager.LogData> mWritingLogQueue = null;
        private Queue<LogManager.LogData> mWaitingLogQueue = null;
        private object mLogLock = null;
        private Thread mFileLogThread = null;
        private bool mIsRunning = false;

        private DeviceBasicInfo deviceInfo;
        private PlayerInfo playerInfo;

        public NetLogOutput()
        {
            this.mWritingLogQueue = new Queue<LogManager.LogData>();
            this.mWaitingLogQueue = new Queue<LogManager.LogData>();
            this.mLogLock = new object();
            this.mIsRunning = true;
            this.mFileLogThread = new Thread(new ThreadStart(WriteLog));
            this.mFileLogThread.Start();

            //获取设备基本信息
            deviceInfo = GetDeviceInfo();
        }

        string GetIp()
        {
            string hostName;

            hostName = System.Net.Dns.GetHostName();
            var ipEntry = System.Net.Dns.GetHostEntry(hostName);
            IPAddress[] addr = ipEntry.AddressList;
            if (addr.Length == 0)
            {
                return "Can't get IP";
            }

            return addr[addr.Length - 1].ToString();
        }

        DeviceBasicInfo GetDeviceInfo()
        {
            DeviceBasicInfo dbi = new DeviceBasicInfo();
            dbi.deviceName = SystemInfo.deviceName;
            dbi.osVersion = SystemInfo.operatingSystem;
            dbi.packageName = Application.identifier;
            dbi.packageVersion = Application.version;
            dbi.ip = GetIp(); //Network.player.ipAddress;
            return dbi;
        }

        PlayerInfo GetPlayerInfo()
        {
            object[] objs = LuaVMManager.Instance.DoString(" if(PlayerData) then return PlayerData.id,PlayerData.playerName else return nil end");
            if (objs == null || objs[0] == null)
            {
                return null;
            }
            else
            {
                PlayerInfo pi = new PlayerInfo();
                pi.ID = objs[0].ToString();
                pi.name = objs[1].ToString();
                return pi;
            }
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
                        LogRecord lr = new LogRecord(playerInfo, deviceInfo);
                        lr.recordTime = lr.recordTime = System.DateTime.Now.ToString();
                        lr.log = log.Log;
                        lr.track = log.Track;
                        //Debug.Log(JsonUtility.ToJson(lr));
                    }
                }
            }
        }

        public void Log(LogManager.LogData logData)
        {
            //只有大于等于这个等级的才会输出到文件
            if (logData.Level >= LogManager.Instance.netOutputLogLevel)
            {
                lock (this.mLogLock)
                {
                    if (playerInfo == null)
                    {
                        playerInfo = GetPlayerInfo();
                    }
                    if (playerInfo != null)
                    {
                        this.mWaitingLogQueue.Enqueue(logData);
                        Monitor.Pulse(this.mLogLock);
                    }
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
        }

        //上报日志记录
        public class LogRecord {
            public LogRecord(PlayerInfo pi, DeviceBasicInfo dbi) {
                ID = pi.ID;
                name = pi.name;
                deviceName = dbi.deviceName;
                osVersion = dbi.osVersion;
                packageName = dbi.packageName;
                packageVersion = dbi.packageVersion;
                ip = dbi.ip;
            }

            public string ID;          //玩家ID
            public string name;        //玩家name
            public string recordTime;  //错误记录时间
            public string deviceName;  //设备名字
            public string osVersion;   //设备操作系统
            public string packageName; //包名
            public string packageVersion; //包版本号
            public string ip;            //设备IP
            public string log;
            public string track;
        }
        //玩家信息（lua中赋值）
        [System.Serializable]
        public class PlayerInfo {
            public string ID;          //玩家ID
            public string name;        //玩家name
        }
        //设备信息
        [System.Serializable]
        public class DeviceBasicInfo
        {
            public string deviceName;  //设备名字
            public string osVersion;   //设备操作系统
            public string packageName; //包名
            public string packageVersion; //包版本号
            public string ip;            //设备IP
        }
    }
}