using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class CommonTools
{

    static public T AddMissingComponent<T>(this GameObject go) where T : Component
    {

        T comp = go.GetComponent<T>();

        if (comp == null)
        {

            comp = go.AddComponent<T>();
        }
        return comp;

    }


    static public string GetHierarchy(GameObject obj)
    {
        if (obj == null) return "";
        string path = obj.name;

        while (obj.transform.parent != null)
        {
            obj = obj.transform.parent.gameObject;
            path = obj.name + "\\" + path;
        }
        return path;
    }

    static public float SpringLerp(float strength, float deltaTime)
    {
        if (deltaTime > 1f) deltaTime = 1f;
        int ms = Mathf.RoundToInt(deltaTime * 1000f);
        deltaTime = 0.001f * strength;
        float cumulative = 0f;
        for (int i = 0; i < ms; ++i) cumulative = Mathf.Lerp(cumulative, 1f, deltaTime);
        return cumulative;
    }

    static public Vector3 SpringLerp(Vector3 from, Vector3 to, float strength, float deltaTime)
    {
        return Vector3.Lerp(from, to, SpringLerp(strength, deltaTime));
    }


}
