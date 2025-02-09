﻿

using UnityEngine;


[CreateAssetMenu(fileName = "SimSettingsAnimatedWaves", menuName = "Crest/Animated Waves Sim Settings", order = 10000)]
public class SimSettingsAnimatedWaves : SimSettingsBase
{
    public enum CollisionSources
    {
        None,
        OceanDisplacementTexturesGPU,
        GerstnerWavesCPU,
    }
    [Tooltip("Where to obtain ocean shape on CPU for physics / gameplay."), Header("Readback to CPU"), SerializeField]
    CollisionSources _collisionSource = CollisionSources.OceanDisplacementTexturesGPU;
    public CollisionSources CollisionSource { get { return _collisionSource; } }

    [SerializeField, Tooltip("Cache CPU requests for ocean height. Requires restart.")]
    bool _cachedHeightQueries = true;
    public bool CachedHeightQueries { get { return _cachedHeightQueries; } }

    [Header("GPU Readback Settings")]
    [Tooltip("Minimum floating object width. The larger the objects that will float, the lower the resolution of the read data. If an object is small, the highest resolution LODs will be sample for physics. This is an optimisation. Set to 0 to disable this optimisation and always copy high res data.")]
    public float _minObjectWidth = 3f;

    // By default copy waves big enough to do buoyancy on a 50m wide object. This ensures we get the wavelengths, and by extension makes
    // sure we get good range on wave physics.
    [Tooltip("Similar to the minimum width, but this setting will exclude the larger LODs from being copied. Set to 0 to disable this optimisation and always copy low res data.")]
    public float _maxObjectWidth = 500f;


    public void GetMinMaxGridSizes(out float minGridSize, out float maxGridSize)
    {
        // Wavelengths that repeat twice or more across the object are irrelevant and don't need to be read back.
        minGridSize = 0.5f * _minObjectWidth / Ocean.Instance._minTexelsPerWave;
        maxGridSize = 0.5f * _maxObjectWidth / Ocean.Instance._minTexelsPerWave;
    }
}

