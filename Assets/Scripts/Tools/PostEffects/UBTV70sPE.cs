
//#define DEBUG_RENDER

using UnityEngine;

[ExecuteInEditMode]
public class UBTV70sPE : LPCPostEffectBase
{
    public float Corner = 50f;
    public float Scan = 10f;
    public float ShiftAmount = 0.025f;
    public Texture2D Noise;
    public Shader Shader;    

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (_material)
        {
            DestroyImmediate(_material);
            _material = null;
        }
        if (Shader)
        {
            _material = new Material(Shader);
            _material.hideFlags = HideFlags.HideAndDontSave;

            if (_material.HasProperty("_Corner"))
            {
                _material.SetFloat("_Corner", Corner);
            }
            if (_material.HasProperty("_Scan"))
            {
                _material.SetFloat("_Scan", Scan);
            }
            if (_material.HasProperty("_ShiftAmount"))
            {
                _material.SetFloat("_ShiftAmount", ShiftAmount);
            }
            if (_material.HasProperty("_NoiseTex"))
            {
                _material.SetTexture("_NoiseTex", Noise);
            }
        }

        if (Shader != null && _material != null)
        {
            Graphics.Blit(source, destination, _material);
        }
    }
}