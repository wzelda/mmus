﻿

using UnityEngine;


[CreateAssetMenu(fileName = "SimSettingsFoam", menuName = "Crest/Foam Sim Settings", order = 10000)]
public class SimSettingsFoam : SimSettingsBase
{
    [Range(0f, 20f), Tooltip("Speed at which foam fades/dissipates.")]
    public float _foamFadeRate = 0.8f;
    [Range(0f, 5f), Tooltip("Scales intensity of foam generated from waves.")]
    public float _waveFoamStrength = 1f;
    [Range(0f, 1f), Tooltip("How much of the waves generate foam.")]
    public float _waveFoamCoverage = 0.8f;
    [Range(0f, 3f), Tooltip("Foam will be generated in water shallower than this depth.")]
    public float _shorelineFoamMaxDepth = 0.65f;
    [Range(0f, 5f), Tooltip("Scales intensity of foam generated in shallow water.")]
    public float _shorelineFoamStrength = 2f;
}

