using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AddressableAssets;
using XLua;
/*
*
* Created: 2017-10-31
* Author: Jeremy
* Company: LightPaw
* 
*/


namespace LPCFramework
{
    public enum GraphicLevel
    {
        High,
        Medium,
        Low
    }

    public enum MemoryLeveL
    {
        Low,
        Mid
    }
    
    [LuaCallCSharp]
    public class GraphicManager : SingletonMonobehaviour<GraphicManager>, IManager
    {
        // property id 
        public int _mainTexHash;
        public int _normalMapHash;
        public int _AngleHash;
        public int _WarpHash;
        public int _WarpPosHash;
        public int _DownwardHash;
        public int __NormalMirrorHash;        
        // end


        // effects
        UBTV70sPE m_tveffect;
        WaterWave m_waterWave;
        ShakeCamera m_shakeCam;
        // end
        
        //public Vector3 ProjectorDir = new Vector3(-0.45f, -1, -0.45f);
        //
        //public Vector4 ShadowPlane = new Vector4(0.0f, 1.0f, 0.0f, 9.34f);
        //
        //public Vector4 ShadowFadeParams = new Vector4(2.0f, 1.5f, 0.33f, 0.0f);
        //
        //public float ShadowFalloff = 1.35f;

        private static readonly int UnscaleTime = Shader.PropertyToID("_UnscaleTime");

        public void OnInitialize()
        {
            //Application.targetFrameRate = 30;
            Time.fixedDeltaTime = 0.03333f;
            Screen.sleepTimeout = SleepTimeout.NeverSleep;//禁止手机休眠

            Shader.SetGlobalFloat(Shader.PropertyToID("_UnScaleFlag"), 1);

            _mainTexHash = Shader.PropertyToID("_MainTex");
            _normalMapHash = Shader.PropertyToID("_BumpMap");
            _AngleHash = Shader.PropertyToID("_Angle");
            _WarpHash = Shader.PropertyToID("_Warp");
            _WarpPosHash = Shader.PropertyToID("_WarpPos");
            _DownwardHash = Shader.PropertyToID("_Downward");
            __NormalMirrorHash = Shader.PropertyToID("_NormalMirror");
        }

        public static void SetScaleFlag(bool useUnScale)
        {
            if(useUnScale){
                Shader.SetGlobalFloat(Shader.PropertyToID("_UnScaleFlag"), 1);
            }else
            {
                Shader.SetGlobalFloat(Shader.PropertyToID("_UnScaleFlag"), 0);
            }
        }
        GameObject effectGo;

        public void SetLoadingEffect(bool active)
        {
            if (effectGo != null)
            {
                effectGo.SetActive(active);
            }
        }

        public void OpenLoadingEffect()
        {
            if (effectGo != null)
            {
                SetLoadingEffect(true);
                return;
            }

            Addressables.LoadAssetAsync<GameObject>("Prefabs/UI_loading_shalong2").Completed += (h)=>
                {                    
                    effectGo = GameObject.Instantiate(h.Result) as GameObject;
                    
                    Transform[] trans = effectGo.GetComponentsInChildren<Transform>();
                    for (int i = 0;i<trans.Length;i++)
                    {
                        trans[i].gameObject.layer = LayerMask.NameToLayer("LoginDargan");
                    }
                                       
                    effectGo.transform.parent = Camera.main.transform;
                    effectGo.transform.localPosition = new Vector3(0, 0, 52);
                    effectGo.transform.localEulerAngles = Vector3.zero;
                    effectGo.transform.localScale = Vector3.one;
                };
        }


        public void CloseLoadingEffect()
        {            
            if (effectGo != null)
            {
                effectGo.SetActive(false);
            }            
        }


        public void OnUpdate()
        {
            Shader.SetGlobalFloat(UnscaleTime, Time.unscaledTime);
        }
        public void OnDestruct()
        {
        }

        public void OpenCameraShake(float shakelv,float shaketime, Camera cam)
        {
            Camera mainCam = cam == null ? Camera.main : cam;
            if (mainCam != null)
            {
                m_shakeCam = mainCam.GetComponent<ShakeCamera>();
                if (m_shakeCam == null)
                {
                    m_shakeCam = mainCam.gameObject.AddComponent<ShakeCamera>();
                }
                m_shakeCam.isShake = true;
                m_shakeCam.shakeLv = shakelv;
                m_shakeCam.setShakeTime = shaketime;
            }
        }

        public void SetTVEffect(bool enabled)
        {
            if (Camera.main != null)
            {
                m_tveffect = Camera.main.GetComponent<UBTV70sPE>();
                if (m_tveffect != null)
                {
                    m_tveffect.enabled = enabled;
                }                
            }            
        }

        public void SetWaterWaveFromWorldPos(Vector3 worldpos)
        {            
            Vector3 screenpos = LuaUtils.WorldPosToScreenPoiont(worldpos);
            SetWaterWave(screenpos);
            
        }

        public void SetWaterWave(Vector3 screenpos)
        {
            if (Camera.main != null)
            {
                m_waterWave = Camera.main.GetComponent<WaterWave>();
                if (m_waterWave == null)
                {
                    m_waterWave = Camera.main.gameObject.AddComponent<WaterWave>();
                }
                m_waterWave.enabled = true;
                m_waterWave.OpenEffect(screenpos);
            }
        }


        private static GraphicLevel checkGPU_Adreno(string[] tokens)
        {
            int num = 0;
            for (int i = 1; i < tokens.Length; i++)
            {
                if (GraphicManager.TryGetInt(ref num, tokens[i]))
                {
                    if (num < 200)
                    {
                        return GraphicLevel.Low;
                    }
                    if (num < 300)
                    {
                        if (num > 220)
                        {
                            return GraphicLevel.Low;
                        }
                        return GraphicLevel.Low;
                    }
                    else if (num < 400)
                    {
                        if (num >= 330)
                        {
                            return GraphicLevel.High;
                        }
                        if (num >= 320)
                        {
                            return GraphicLevel.Medium;
                        }
                        return GraphicLevel.Low;
                    }
                    else if (num >= 400)
                    {
                        if (num < 420)
                        {
                            return GraphicLevel.Medium;
                        }
                        return GraphicLevel.High;
                    }
                }
            }
            return GraphicLevel.Low;
        }

        private static GraphicLevel checkGPU_PowerVR(string[] tokens)
        {
            bool flag = false;
            bool flag2 = false;
            GraphicLevel result = GraphicLevel.Low;
            int num = 0;
            for (int i = 1; i < tokens.Length; i++)
            {
                string text = tokens[i];
                if (text == "sgx")
                {
                    flag = true;
                }
                else
                {
                    if (text == "rogue")
                    {
                        flag2 = true;
                        break;
                    }
                    if (flag)
                    {
                        bool flag3 = false;
                        int num2 = text.IndexOf("mp");
                        if (num2 > 0)
                        {
                        GraphicManager.TryGetInt(ref num, text.Substring(0, num2));
                            flag3 = true;
                        }
                        else if (GraphicManager.TryGetInt(ref num, text))
                        {
                            for (int j = i + 1; j < tokens.Length; j++)
                            {
                                text = tokens[j].ToLower();
                                if (text.IndexOf("mp") >= 0)
                                {
                                    flag3 = true;
                                    break;
                                }
                            }
                        }
                        if (num > 0)
                        {
                            if (num < 543)
                            {
                                result = GraphicLevel.Low;
                            }
                            else if (num == 543)
                            {
                                result = GraphicLevel.Low;
                            }
                            else if (num == 544)
                            {
                                result = GraphicLevel.Low;
                                if (flag3)
                                {
                                    result = GraphicLevel.Medium;
                                }
                            }
                            else
                            {
                                result = GraphicLevel.Medium;
                            }
                            break;
                        }
                    }
                    else if (text.Length > 4)
                    {
                        char c = text[0];
                        char c2 = text[1];
                        if (c == 'g')
                        {
                            if (c2 >= '0' && c2 <= '9')
                            {
                            GraphicManager.TryGetInt(ref num, text.Substring(1));
                            }
                            else
                            {
                            GraphicManager.TryGetInt(ref num, text.Substring(2));
                            }
                            if (num > 0)
                            {
                                if (num >= 7000)
                                {
                                    result = GraphicLevel.High;
                                }
                                else if (num >= 6000)
                                {
                                    if (num < 6100)
                                    {
                                        result = GraphicLevel.Low;
                                    }
                                    else if (num < 6400)
                                    {
                                        result = GraphicLevel.Medium;
                                    }
                                    else
                                    {
                                        result = GraphicLevel.High;
                                    }
                                }
                                else
                                {
                                    result = GraphicLevel.Low;
                                }
                                break;
                            }
                        }
                    }
                }
            }
            if (flag2)
            {
                result = GraphicLevel.High;
            }
            return result;
        }

        private static GraphicLevel checkGPU_Mali(string[] tokens)
        {
            int num = 0;
            GraphicLevel result = GraphicLevel.Low;
            for (int i = 1; i < tokens.Length; i++)
            {
                string text = tokens[i];
                if (text.Length >= 3)
                {
                    int num2 = text.LastIndexOf("mp");
                    bool flag = text[0] == 't';
                    if (num2 > 0)
                    {
                        int num3 = (!flag) ? 0 : 1;
                        text = text.Substring(num3, num2 - num3);
                    GraphicManager.TryGetInt(ref num, text);
                    }
                    else
                    {
                        if (flag)
                        {
                            text = text.Substring(1);
                        }
                        if (GraphicManager.TryGetInt(ref num, text))
                        {
                            for (int j = i + 1; j < tokens.Length; j++)
                            {
                                text = tokens[j];
                                if (text.IndexOf("mp") >= 0)
                                {
                                    break;
                                }
                            }
                        }
                    }
                    if (num > 0)
                    {
                        if (num < 400)
                        {
                            result = GraphicLevel.Low;
                        }
                        else if (num < 500)
                        {
                            if (num == 400)
                            {
                                result = GraphicLevel.Low;
                            }
                            else if (num == 450)
                            {
                                result = GraphicLevel.Medium;
                            }
                            else
                            {
                                result = GraphicLevel.Low;
                            }
                        }
                        else if (num < 700)
                        {
                            if (!flag)
                            {
                                result = GraphicLevel.Low;
                            }
                            else if (num < 620)
                            {
                                result = GraphicLevel.Low;
                            }
                            else if (num < 628)
                            {
                                result = GraphicLevel.Medium;
                            }
                            else
                            {
                                result = GraphicLevel.High;
                            }
                        }
                        else if (!flag)
                        {
                            result = GraphicLevel.Low;
                        }
                        else
                        {
                            result = GraphicLevel.High;
                        }
                        break;
                    }
                }
            }
            return result;
        }

        private static GraphicLevel checkGPU_Tegra(string[] tokens)
        {
            bool flag = false;
            int num = 0;
            GraphicLevel result = GraphicLevel.Low;
            for (int i = 1; i < tokens.Length; i++)
            {
                if (GraphicManager.TryGetInt(ref num, tokens[i]))
                {
                    flag = true;
                    if (num >= 4)
                    {
                        result = GraphicLevel.High;
                        break;
                    }
                    if (num == 3)
                    {
                        result = GraphicLevel.Medium;
                        break;
                    }
                }
                else
                {
                    string a = tokens[i];
                    if (a == "k1")
                    {
                        result = GraphicLevel.High;
                        flag = true;
                        break;
                    }
                }
            }
            if (!flag)
            {
                result = GraphicLevel.Medium;
            }
            return result;
        }

        private static GraphicLevel checkGPU_Android(string gpuName)
        {
            GraphicLevel result = GraphicLevel.Low;
            int systemMemorySize = SystemInfo.systemMemorySize;
            if (systemMemorySize < 1500)
            {
                return GraphicLevel.Low;
            }
            gpuName = gpuName.ToLower();
            char[] separator = new char[]
            {
            ' ',
            '\t',
            '\r',
            '\n',
            '+',
            '-',
            ':'
            };
            string[] array = gpuName.Split(separator, System.StringSplitOptions.RemoveEmptyEntries);
            if (array == null || array.Length == 0)
            {
                return GraphicLevel.Low;
            }
            if (array[0].Contains("vivante"))
            {
                result = GraphicLevel.Low;
            }
            else if (array[0] == "adreno")
            {
                result = GraphicManager.checkGPU_Adreno(array);
            }
            else if (array[0] == "powervr" || array[0] == "imagination" || array[0] == "sgx")
            {
                result = GraphicManager.checkGPU_PowerVR(array);
            }
            else if (array[0] == "arm" || array[0] == "mali" || (array.Length > 1 && array[1] == "mali"))
            {
                result = GraphicManager.checkGPU_Mali(array);
            }
            else if (array[0] == "tegra" || array[0] == "nvidia")
            {
                result = GraphicManager.checkGPU_Tegra(array);
            }
            return result;
        }

        private static void checkDevice_Android(ref GraphicLevel q)
        {
            string a = SystemInfo.deviceModel.ToLower();
            if (a == "samsung gt-s7568i")
            {
                q = GraphicLevel.Low;
            }
            else if (a == "xiaomi 1s")
            {
                q = GraphicLevel.Medium;
            }
            else if (a == "xiaomi 2013022")
            {
                q = GraphicLevel.Medium;
            }
            else if (a == "samsung sch-i959")
            {
                q = GraphicLevel.Medium;
            }
            else if (a == "xiaomi mi 3")
            {
                q = GraphicLevel.High;
            }
            else if (a == "xiaomi mi 2a")
            {
                q = GraphicLevel.Medium;
            }
            else if (a == "xiaomi hm 1sc")
            {
                q = GraphicLevel.Low;
            }
        }

        public static GraphicLevel check_Android()
        {
            GraphicLevel result = GraphicManager.checkGPU_Android(SystemInfo.graphicsDeviceName);
            GraphicManager.checkDevice_Android(ref result);
            return result;
        }

        private static bool TryGetInt(ref int val, string str)
        {
            val = 0;
            bool result;
            try
            {
                val = System.Convert.ToInt32(str);
                result = true;
            }
            catch
            {
                result = false;
            }
            return result;
        }
    }
}
