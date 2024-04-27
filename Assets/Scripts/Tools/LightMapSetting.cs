using UnityEngine;
using UnityEngine.Rendering;

namespace LPCFramework
{
    [ExecuteInEditMode]
    public class LightMapSetting : MonoBehaviour
    {
        [HideInInspector]
        public Texture2D []lightmapFar, lightmapNear;
        [HideInInspector]
        public LightmapsMode mode;
        //场景中的Fog信息  
        [System.Serializable]
        public struct FogInfo
        {
            public bool fog;
            public FogMode fogMode;
            public Color fogColor;
            public float fogStartDistance;
            public float fogEndDistance;
            public float fogDensity;
        }
        //环境信息
        [System.Serializable]
        public struct AmbientInfo
        {
            public AmbientMode ambientMode;
            public Color ambientLight;
            public Color ambientEquatorColor;
            public Color ambientGroundColor;
            public float ambientIntensity;
            public Color ambientSkyColor;
        }
        public FogInfo fogInfo;
        [HideInInspector]
        public AmbientInfo ambientInfo;

#if UNITY_EDITOR
        public void OnEnable()
        {
            //Debug.Log("[SerializedLightmapSetting] hook");
            UnityEditor.Lightmapping.completed += LoadLightmaps;
        }
        public void OnDisable()
        {
            //Debug.Log("[SerializedLightmapSetting] unhook");
            UnityEditor.Lightmapping.completed -= LoadLightmaps;
        }
#endif
        [ContextMenu("SetLightMaps")]
        public void Start ()
        {
            if(Application.isPlaying)
            {
                LightmapSettings.lightmapsMode = mode;
                int l1 = (lightmapFar == null) ? 0 : lightmapFar.Length;
                int l2 = (lightmapNear == null) ? 0 : lightmapNear.Length;
                int l = (l1 < l2) ? l2 : l1;
                LightmapData[] lightmaps = null;
                if (l > 0)
                {
                    lightmaps = new LightmapData[l];
                    for (int i = 0; i < l; i++)
                    {
                        lightmaps[i] = new LightmapData();
                        if (i < l1)
                            lightmaps[i].lightmapColor = lightmapFar[i];
                        if (i < l2)
                            lightmaps[i].lightmapDir = lightmapNear[i];
                    }
                }
                LightmapSettings.lightmaps = lightmaps;
//                Destroy(this);;

                RenderSettings.fog = fogInfo.fog;
                RenderSettings.fogMode = fogInfo.fogMode;
                RenderSettings.fogColor = fogInfo.fogColor;
                RenderSettings.fogStartDistance = fogInfo.fogStartDistance;
                RenderSettings.fogEndDistance = fogInfo.fogEndDistance;
                RenderSettings.fogDensity = fogInfo.fogDensity;

                //环境信息
//                RenderSettings.ambientMode = ambientInfo.ambientMode;
//                RenderSettings.ambientLight = ambientInfo.ambientLight;
//                RenderSettings.ambientEquatorColor = ambientInfo.ambientEquatorColor;
//                RenderSettings.ambientGroundColor = ambientInfo.ambientGroundColor;
//                RenderSettings.ambientIntensity = ambientInfo.ambientIntensity;
//                RenderSettings.ambientSkyColor = ambientInfo.ambientSkyColor;
            }
        }

        private void OnDestroy()
        {
            LightmapSettings.lightmaps = null;
        }
#if UNITY_EDITOR
        [ContextMenu("LoadLightmaps")]
        public void LoadLightmaps()
        {
            mode = LightmapSettings.lightmapsMode;
            lightmapFar = null;
            lightmapNear = null;
            if (LightmapSettings.lightmaps != null && LightmapSettings.lightmaps.Length > 0)
            {
                int l = LightmapSettings.lightmaps.Length;
                lightmapFar = new Texture2D[l];
                lightmapNear = new Texture2D[l];
                for (int i = 0; i < l; i++)
                {
                    lightmapFar[i] = LightmapSettings.lightmaps[i].lightmapColor;
                    lightmapNear[i] = LightmapSettings.lightmaps[i].lightmapDir;
                }
            }
            MeshLightmapSetting[] savers = GameObject.FindObjectsOfType<MeshLightmapSetting>();
            foreach(MeshLightmapSetting s in savers)
            {
                s.SaveSettings();
            }
            
            fogInfo = new FogInfo();
            fogInfo.fog = RenderSettings.fog;
            fogInfo.fogMode = RenderSettings.fogMode;
            fogInfo.fogColor = RenderSettings.fogColor;
            fogInfo.fogStartDistance = RenderSettings.fogStartDistance;
            fogInfo.fogEndDistance = RenderSettings.fogEndDistance;
            fogInfo.fogDensity = RenderSettings.fogDensity;
          
            //环境信息
//            ambientInfo = new AmbientInfo();
//            ambientInfo.ambientMode = RenderSettings.ambientMode;
//            ambientInfo.ambientLight = RenderSettings.ambientLight;
//            ambientInfo.ambientEquatorColor = RenderSettings.ambientEquatorColor;
//            ambientInfo.ambientGroundColor = RenderSettings.ambientGroundColor;
//            ambientInfo.ambientIntensity = RenderSettings.ambientIntensity;
//            ambientInfo.ambientSkyColor = RenderSettings.ambientSkyColor;
        }
#endif
    }

}