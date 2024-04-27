using BehaviorDesigner.Runtime;
using UnityEngine;

namespace LPCFramework
{
    public class Main : MonoBehaviour
    {
        void Awake()
        {
            GameObject launcher = GameObject.Find("Launcher");
            
            if (launcher == null)
            {
                launcher = new GameObject("Launcher");
                launcher.AddComponent<Launcher>();
                DontDestroyOnLoad(launcher);
            }
            launcher.GetComponent<Launcher>().Initialize();

            DontDestroyOnLoad(Behavior.CreateBehaviorManager());
        }
        
    }
}
