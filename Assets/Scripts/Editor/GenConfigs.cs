/*
 * Tencent is pleased to support the open source community by making xLua available.
 * Copyright (C) 2016 THL A29 Limited, a Tencent company. All rights reserved.
 * Licensed under the MIT License (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 * http://opensource.org/licenses/MIT
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using DG.Tweening;
using DG.Tweening.Core;
using FairyGUI;
using LPCFramework;
using UnityEngine;
using XLua;

public static class GenConfigs {
    //lua中要使用到C#库的配置，比如C#标准库，或者Unity API，第三方库等。
    [LuaCallCSharp]
    public static List<Type> LuaCallCSharp = new List<Type> () {
        typeof (System.Object),

#if UNITY_IPHONE || UNITY_IOS
        typeof (UnityEngine.iOS.Device),
        typeof (UnityEngine.iOS.DeviceGeneration),
#endif
        typeof (UnityEngine.Object),
        typeof (UnityEngine.SystemLanguage),
        typeof (Vector2),
        typeof (Vector3),
        typeof (Vector4),
        typeof (Rect),
        typeof (Quaternion),
        typeof (Color),
        typeof (Camera),
        typeof (Ray),
        typeof (Bounds),
        typeof (Ray2D),
        typeof (Time),
        typeof (Touch),
        typeof (TouchPhase),
        typeof (GameObject),
        typeof (Component),
        typeof (Behaviour),
        typeof (Transform),
        typeof (Resources),
        typeof (Material),
        typeof (TextAsset),
        typeof (Keyframe),
        typeof (AudioSource),
        typeof (AudioClip),
        typeof (AnimationCurve),
        typeof (AnimationClip),
        typeof (MonoBehaviour),
        typeof (ParticleSystem),
        typeof (ParticleSystem.MainModule),
        typeof (ParticleSystem.MinMaxCurve),
        typeof (PlayerPrefs),
        typeof (UnityEngine.Playables.PlayableDirector),
        typeof (UnityEngine.RenderSettings),
        typeof (SkinnedMeshRenderer),
        typeof (Renderer),
        typeof (WaitForSeconds),
        typeof (WaitForEndOfFrame),
        typeof (System.Collections.Generic.List<int>),
        typeof (Action<string>),
        typeof (UnityEngine.Debug),
        typeof (Mesh),
        typeof (Mathf),
        typeof (Animator),
        typeof (Application),
        typeof (AnimationCurve),
        typeof (Input),
        typeof (Gyroscope),
        typeof (SystemInfo),
        typeof (Handheld),

        // fairy being
        typeof (EventContext),
        typeof (FairyGUI.EventDispatcher),
        typeof (EventListener),
        typeof (InputEvent),
        typeof (DisplayObject),
        typeof (Container),
        typeof (Stage),
        typeof (FairyGUI.Controller),
        typeof (GObject),
        typeof (GGraph),
        typeof (GGroup),
        typeof (GImage),
        typeof (GLoader),
        typeof (GMovieClip),
        typeof (NAudioClip),
        typeof (TextFormat),
        typeof (GTextField),
        typeof (GRichTextField),
        typeof (GTextInput),
        typeof (GComponent),
        typeof (GList),
        typeof (GRoot),
        typeof (GLabel),
        typeof (GButton),
        typeof (GComboBox),
        typeof (GProgressBar),
        typeof (GSlider),
        typeof (PopupMenu),
        typeof (ScrollPane),
        typeof (Transition),
        typeof (DragDropManager),
        typeof (UIConfig),
        //typeof(UIPackage),
        typeof (Window),
        typeof (GObjectPool),
        typeof (Relations),
        typeof (RelationType),
        typeof (Timers),
        typeof (FontManager),
        typeof (GoWrapper),
        typeof (TypingEffect),
        typeof (FairyGUI.LongPressGesture),
        typeof (GTweener),
        typeof (FairyGUI.AutoSizeType),
        // fairy end

        typeof (DebugLog),
        typeof (LineRenderer),
        typeof (TrailRenderer),
        typeof (SpriteRenderer),
        typeof (ShortcutExtensions),
        typeof (Tween),
        typeof (Ease),
        typeof (AxisConstraint),
        typeof (TweenExtensions),
        typeof (TweenSettingsExtensions),
        typeof (UnityEngine.Playables.PlayableDirector),
        typeof (LPCFramework.AudioState),
        typeof (LPCFramework.GroupId),
        typeof (LPCFramework.AudioSourceData),
        typeof (UnityEngine.AsyncOperation),
        typeof (LoopType),
        typeof (BoxCollider),
        typeof (CapsuleCollider),
        typeof (UnityEngine.Light),
        typeof (NetworkReachability),
        typeof (DG.Tweening.DOTween),
        typeof (UnityEngine.Video.VideoPlayer),
        typeof (QualitySettings),
        typeof (Physics),
        typeof (RaycastHit),
        typeof (RenderTexture),

        //sdk
        // typeof (LightGameFactory),
        //typeof (TradPlus),
#if UNITY_IOS
        typeof(TradPlusiOS),
#else
        //typeof(TradPlusAndroid),
#endif
        //sdk end
    };

    //C#静态调用Lua的配置（包括事件的原型），仅可以配delegate，interface
    [CSharpCallLua]
    public static List<Type> CSharpCallLua = new List<Type>() {
        typeof(System.Collections.IEnumerator),
        typeof (Action),
        typeof (Action<bool, float>),
        typeof (Action<bool, string>),
        typeof (Action<bool, string[]>),
        typeof (Action<float, string, string>),
        typeof (Action<string, string>),
        typeof (Action<string, string, string>),
        typeof (Action<string[], float[], string[], string>),
        typeof (Action<int, bool>),
        typeof (Action<string, int>),
        typeof (Action<int, string>),
        typeof (Func<bool>),
        typeof (Func<double, double, double>),
        typeof (System.Func<float>),
        typeof (System.Action<bool>),
        typeof (System.Func<int>),
        typeof (Action<Vector3>),
        typeof (Action<Vector3, Vector3>),
        typeof (Action<Touch, Touch>),
        typeof (Action<UnityEngine.Object>),
        typeof (Action<UnityEngine.GameObject>),
        typeof (Action<UnityEngine.GameObject, Vector3>),
        typeof (Action<UnityEngine.GameObject, Vector3, Vector2, Vector3>),
        typeof (Action<EffectItem>),
        typeof (Action<string>),
        typeof (Action<double>),
        typeof (Action<float>),
        typeof (Action<int>),
        typeof (Action<long>),
        typeof (Action<byte[]>),
        typeof (Action<byte[], string>),
        typeof (Action<UnityEngine.SceneManagement.Scene>),
        typeof (DOGetter<Vector3>),
        typeof (DOGetter<double>),
        typeof (DOGetter<float>),
        typeof (DOGetter<int>),
        typeof (DOSetter<Vector3>),
        typeof (DOSetter<double>),
        typeof (DOSetter<float>),
        typeof (DOSetter<int>),
        typeof (FairyGUI.EventCallback0),
        typeof (FairyGUI.EventCallback1),
        typeof (LoadSuccessCallback),
        typeof (PlayCompleteCallback),
        typeof (TransitionHook),
        typeof (ListItemRenderer),
        typeof (ListItemProvider),
        typeof (TweenCallback),
        typeof (GTweenCallback1),
        typeof (Application.LogCallback),
        typeof (UnityEngine.Events.UnityAction<bool, string>),
        typeof (Func<string, bool>),
    };

    //黑名单
    [BlackList]
    public static List<List<string>> BlackList = new List<List<string>> () {
        new List<string> () { "UnityEngine.WWW", "movie" },
        new List<string> () { "UnityEngine.Input", "location" },
        new List<string> () { "ProFlare", "OccludingObject" },
        new List<string> () { "ProFlare", "EditDynamicTriggering" },
        new List<string> () { "ProFlare", "EditOcclusion" },
        new List<string> () { "BezierSolution.BezierSpline", "Reset" },
        new List<string> () { "UnityEngine.Input", "IsJoystickPreconfigured", "System.String" },
        new List<string> () { "UnityEngine.Handheld", "SetActivityIndicatorStyle", "UnityEngine.iOS.ActivityIndicatorStyle" },
        new List<string> () { "UnityEngine.Handheld", "SetActivityIndicatorStyle", "UnityEngine.AndroidActivityIndicatorStyle" },
#if UNITY_WEBGL
        new List<string> () { "UnityEngine.WWW", "threadPriority" },
#endif
        new List<string> () { "UnityEngine.Texture2D", "alphaIsTransparency" },
        new List<string> () { "UnityEngine.Security", "GetChainOfTrustValue" },
        new List<string> () { "UnityEngine.CanvasRenderer", "onRequestRebuild" },
        new List<string> () { "UnityEngine.Light", "areaSize" },
        new List<string> () { "UnityEngine.Light", "lightmapBakeType" },
        new List<string> () { "UnityEngine.Light", "shadowAngle" },
        new List<string> () { "UnityEngine.Light", "shadowRadius" },
        new List<string> () { "UnityEngine.LineRenderer", "GetPositions", "UnityEngine.Vector3[]" },
        new List<string> () { "UnityEngine.TrailRenderer", "GetPositions", "UnityEngine.Vector3[]" },
        new List<string> () { "UnityEngine.AnimatorOverrideController", "PerformOverrideClipListCleanup" },
#if !UNITY_WEBPLAYER
        new List<string> () { "UnityEngine.Application", "ExternalEval" },
#endif
        new List<string> () { "UnityEngine.GameObject", "networkView" }, //4.6.2 not support
        new List<string> () { "UnityEngine.Component", "networkView" }, //4.6.2 not support
        new List<string> () { "System.IO.FileInfo", "GetAccessControl", "System.Security.AccessControl.AccessControlSections" },
        new List<string> () { "System.IO.FileInfo", "SetAccessControl", "System.Security.AccessControl.FileSecurity" },
        new List<string> () { "System.IO.DirectoryInfo", "GetAccessControl", "System.Security.AccessControl.AccessControlSections" },
        new List<string> () { "System.IO.DirectoryInfo", "SetAccessControl", "System.Security.AccessControl.DirectorySecurity" },
        new List<string> () { "System.IO.DirectoryInfo", "CreateSubdirectory", "System.String", "System.Security.AccessControl.DirectorySecurity" },
        new List<string> () { "System.IO.DirectoryInfo", "Create", "System.Security.AccessControl.DirectorySecurity" },
        new List<string> () { "UnityEngine.MonoBehaviour", "runInEditMode" },
    };

    /*
    [Hotfix]
    public static List<Type> by_property {
        get {
            return (from type in Assembly.Load ("Assembly-CSharp").GetTypes () where type.Namespace == "LPCFramework" || type.Namespace == "BehaviorDesigner.Runtime" || type.Namespace == "BehaviorDesigner.Runtime.Tasks"
                select type).ToList ();
        }
    }

    static GenConfigs () {
        LuaCallCSharp.AddRange ((from type in Assembly.Load ("Assembly-CSharp").GetTypes () where type.Namespace == "BehaviorDesigner.Runtime" || type.Namespace == "BehaviorDesigner.Runtime.Tasks"
            select type).ToList ());
    }
    */
}