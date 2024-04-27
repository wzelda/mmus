using FairyGUI;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;
using System.IO;

namespace LPCFramework
{
    [LuaCallCSharp]
    public class Launcher : MonoBehaviour
    {
        public static Launcher Instance;
        public bool waitToEnter = false;

        public GComponent splash;

        public Launcher()
        {
            Instance = this;
        }
        public void Initialize()
        {
            GraphicManager.Instance.OnInitialize();

            waitToEnter = true;
        }

        private void Awake()
        {
            ShowSplash();
        }
       
        public void ShowSplash()
        {
            if (splash == null)
            {
                GRoot.inst.SetContentScaleFactor(1080, 1920);
                UIPackage.AddPackage("UI/Splash/Splash");
                splash = UIPackage.CreateObject("Splash", "Splash") as GComponent;
                GRoot.inst.AddChild(splash);
                splash.SetSize(GRoot.inst.width, GRoot.inst.height);
                splash.AddRelation(GRoot.inst, RelationType.Size);

                var img = splash.GetChild("ImgShow") as GLoader;

                Sprite logo = null;

                var customLogo = PlayerPrefs.GetString("CustomLogo", "logo.png");
                if (!string.IsNullOrEmpty(customLogo))
                {
                    var path = Path.Combine(Application.persistentDataPath, customLogo);
                    if (File.Exists(path))
                    {
                        byte[] bytes = File.ReadAllBytes(Path.Combine(Application.persistentDataPath, customLogo));
                        Texture2D texture = new Texture2D(10, 10);
                        texture.filterMode = FilterMode.Trilinear;
                        texture.LoadImage(bytes);
                        logo = Sprite.Create(texture, new Rect(0,0,texture.width, texture.height), new Vector2(0.5f,0.0f), 1.0f);
                    }
                }

                if (logo == null)
                {
                    logo = Resources.Load<Sprite>("logo");
                }

                img.texture = new NTexture(logo);
            }
        }
        
        public void HideSplash()
        {
            if (splash != null)
            {
                splash.Dispose();
                UIPackage.RemovePackage("UI/Splash/Splash");
                splash = null;
            }
        }

        private void FixedUpdate()
        {
            if (waitToEnter) { 
                InitGameLogic();
                waitToEnter = false;
            }
        }
        public void ReStartLuaEnv()
        {
            StartCoroutine(LateInit());
        }
        private void InitGameLogic()
        {
            LuaManager.Instance.OnInitialize();
        }
        private IEnumerator LateInit()
        {
            yield return 0;
            LuaManager.Instance.OnInitialize();
        }
    }
}