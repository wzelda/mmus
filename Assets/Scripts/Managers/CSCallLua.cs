/*
 *
 * Created: 2017-10-31
 * Author: Jeremy
 * Company: LightPaw
 * 
 */
using System;
using System.Collections;
using System.Collections.Generic;
using FairyGUI;
using UnityEngine;
using XLua;
using Object = System.Object;

namespace LPCFramework {
    public class CSCallLua {
        private System.Action initialize = null;
        private System.Action update = null;
        private System.Action fixedUpdate = null;
        private System.Action lateUpdate = null;
        private System.Action onAppFocus = null;
        private System.Action onAppUnFocus = null;
        private System.Action onAppPause = null;
        private System.Action onAppUnPause = null;
        private System.Action onLuaDestroy = null;
        private System.Action<byte[]> onReceiveMsg = null;

        private System.Action<System.String, System.Object> dispatcher = null;

        public void Initialize () {
            if (null != initialize) {
                initialize ();
            }
        }

        public void Update () {
            update ();
        }

        public void FixedUpdate () {
            fixedUpdate ();
        }

        public void LateUpdate () {
            lateUpdate ();
        }

        public void OnAppFocus () {
            if (null != onAppFocus) {
                onAppFocus ();
            }
        }
        public void OnAppUnFocus () {
            if (null != onAppFocus) {
                onAppUnFocus ();
            }
        }

        public void OnAppPause () {
            if (null != onAppPause) {
                onAppPause ();
            }
        }
        public void OnAppUnPause () {
            if (null != onAppPause) {
                onAppUnPause ();
            }
        }

        public void OnReceiveMsg (ref byte[] msg) {
            onReceiveMsg (msg);
        }

        public void OnDispatcher (string eventID, Object value) {
            dispatcher (eventID, value);
        }

        public void OnDestroy () {
            if (null != onLuaDestroy) {
                onLuaDestroy ();
            }

            onLuaDestroy = null;

            initialize = null;
            update = null;
            fixedUpdate = null;
            lateUpdate = null;
            onAppFocus = null;
            onAppUnFocus = null;
            onAppPause = null;
            onAppUnPause = null;
            onReceiveMsg = null;
            dispatcher = null;
        }

        public void Bind () {
            if (LuaVMManager.Instance.Lua_Env == null) return;

            LuaVMManager.Instance.DoFile ("GlobalManager");

            initialize = LuaVMManager.Instance.BindToLua<System.Action> ("initialize");

            onLuaDestroy = LuaVMManager.Instance.BindToLua<System.Action> ("onLuaDestroy");

            update = LuaVMManager.Instance.BindToLua<System.Action> ("update");

            fixedUpdate = LuaVMManager.Instance.BindToLua<System.Action> ("fixedUpdate");
            lateUpdate = LuaVMManager.Instance.BindToLua<System.Action> ("lateUpdate");
            onAppFocus = LuaVMManager.Instance.BindToLua<System.Action> ("onAppFocus");
            onAppUnFocus = LuaVMManager.Instance.BindToLua<System.Action> ("onAppUnFocus");
            onAppPause = LuaVMManager.Instance.BindToLua<System.Action> ("onAppPause");
            onAppUnPause = LuaVMManager.Instance.BindToLua<System.Action> ("onAppUnPause");

            onReceiveMsg = LuaVMManager.Instance.BindToLua<System.Action<byte[]>> ("onReceiveMsg");

            dispatcher = LuaVMManager.Instance.BindToLua<System.Action<string, System.Object>> ("dispatcher");
        }
    }
}