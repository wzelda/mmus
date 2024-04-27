using System;
using System.Reflection;
using System.Security.Cryptography.X509Certificates;
using UnityEngine;

/// <summary>
/// singleton tool
/// lvchengyuan
/// </summary>
/// <typeparam name="T"></typeparam>

public class Singleton<T> : IDisposable where T : new()
{
    static Singleton()
    {

    }

    public virtual void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this);
    }

    protected virtual void DisposeGC() { }

    private void Dispose(Boolean disposing)
    {
        if (disposing)
            DisposeGC();

    }

    protected static T _Object = default(T);

    public static T Instance
    {
        get
        {
            if (null == _Object)
            {
                _Object = new T();
                if (null == _Object)
                {
                    UnityEngine.Debug.LogError("Error Create Singleton !" + _Object.GetType().ToString());
                }
            }
            return (_Object);
        }
        set { _Object = value; }
    }

    public static Boolean Instantiated { get { return (null != _Object); } }
}

public class SingletonMonobehaviour<T> : MonoBehaviour where T : SingletonMonobehaviour<T>
{
    internal static T _S;

    public static T Instance
    {
        get
        {
            if (_S == null)
            {
                _S = (T)GameObject.FindObjectOfType(typeof(T));
                if (_S == null)
                {
                    GameObject instanceObject = new GameObject(typeof(T).Name);
                    _S = instanceObject.AddComponent<T>();
                    if (LPCFramework.Launcher.Instance != null && LPCFramework.Launcher.Instance.transform != null)
                    {
                        _S.transform.parent = LPCFramework.Launcher.Instance.transform;
                    }
                }
            }
            return _S;
        }
    }
}




