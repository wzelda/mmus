using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DebugLog{
    public static bool showLog;

    public static void Log(object message)
    {
        if (showLog)
            Debug.Log(message);
    }

    public static void LogWarning(object message)
    {
        if (showLog)
            Debug.LogWarning(message);
    }

    public static void LogError(object message)
    {
        if (showLog)
            Debug.LogError(message);
    }
    public static void LogError(object message, params object[] args)
    {
        if (showLog)
            Debug.LogErrorFormat(message.ToString(), args);
    }

    public static void LogFormat(string format, params object[] args)
    {
        if (showLog)
            Debug.LogFormat(format, args);
    }

}
