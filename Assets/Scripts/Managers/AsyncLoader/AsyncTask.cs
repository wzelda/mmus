using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;

namespace LPCFramework
{
    [LuaCallCSharp]
    public class AsyncTask
    {
        public System.Action OnBeginTask = null;
        public LoadSuccessCallback loadSucCallback = null;
        public int TaskWeight = 1;

        public AsyncTask(System.Action task,LoadSuccessCallback callback ,int weight)
        {
            OnBeginTask = task;
            loadSucCallback = callback;
            TaskWeight = weight;
        }

        public void Destroy()
        {
            OnBeginTask = null;
            loadSucCallback = null;
        }
    }
}
