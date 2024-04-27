using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UnscaledDeltaTimeParticleSystem : MonoBehaviour {

	// Use this for initialization
	void Start ()
    {
        _Init();
    }
	
    void _Init()
    {
        ParticleSystem.MainModule mm;       
        ParticleSystem[] children = transform.GetComponentsInChildren<ParticleSystem>();
        for(int i = 0; i < children.Length; ++i)
        {
            mm = children[i].main;
            mm.useUnscaledTime = true;
        }
    }
}
