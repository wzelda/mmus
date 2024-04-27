/*
*===============================================================
*
*Created:  02/11/2017 11:35
*Author:   Better
*Company:  LightPaw
*
*================================================================
*/
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace LPCFramework
{
    /// <summary>
    /// 日志输出接口
    /// </summary>
    public interface ILogOutput
    {
        /// <summary>
        /// 输出日志数据
        /// </summary>
        /// <param name="logData">日志数据</param>
        void Log(LogManager.LogData logData);
        
        /// <summary>
        /// 获取报错的数量
        /// </summary>
        /// <returns></returns>
        int GetErrorNum();
        /// <summary>
        /// 关闭
        /// </summary>
        void Close();
    }
}