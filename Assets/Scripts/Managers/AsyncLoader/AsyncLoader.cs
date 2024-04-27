using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;


public delegate float LoadSuccessCallback();

namespace LPCFramework
{    
    [LuaCallCSharp]

    public class AsyncLoader : SingletonMonobehaviour<AsyncLoader>
    {
        Dictionary<System.Action, AsyncTask> AsyncTaskMap = new Dictionary<System.Action, AsyncTask>();
        
        public Dictionary<System.Action, AsyncTask> Tasks
        {
            get
            {
                return AsyncTaskMap;
            }
        }

        public float GetTaskLoadSuc(System.Action task)
        {
            if (AsyncTaskMap.ContainsKey(task) && AsyncTaskMap[task] != null && AsyncTaskMap[task].loadSucCallback != null)
            {
                return AsyncTaskMap[task].loadSucCallback();
            }

            return 0;
        }


        public int TaskCount
        {
            get
            {
                return AsyncTaskMap.Count;
            }

        }

        public int TotalTaskWeights
        {
            get
            {
                int weight = 0;
                foreach (var taskky in AsyncTaskMap)
                {
                    weight += taskky.Value.TaskWeight;
                }
                return weight;
            }
        }



        public void RegistTaskList(System.Action task, LoadSuccessCallback loadsuc,int weight)
        {
            if (!AsyncTaskMap.ContainsKey(task))
            {
                AsyncTask atask = new AsyncTask(task,loadsuc,weight);
                AsyncTaskMap.Add(task, atask);
            }

        }

        public void OnUnRegistTask(System.Action task)
        {
            if (AsyncTaskMap.ContainsKey(task))
            {
                AsyncTaskMap[task].Destroy();
                AsyncTaskMap.Remove(task);                
            }
        }

        public void ClearTasks()
        {
            foreach (var task in AsyncTaskMap)
            {
                task.Value.Destroy();
            }
            AsyncTaskMap.Clear();
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
            ClearTasks();
        }

    }
}
