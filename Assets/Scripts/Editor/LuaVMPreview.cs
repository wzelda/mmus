using LPCFramework;
using UnityEditor;
using UnityEngine;

namespace Assets.Editor.XLua
{

    [UnityEditor.CustomPreview(typeof(LuaManager))]
    public class LuaVMPreview : ObjectPreview
    {
        public override bool HasPreviewGUI()
        {
            return true;
        }

        public override void OnPreviewGUI(Rect r, GUIStyle background)
        {
            var lua = target as LuaManager;
            GUI.Label(r, "Memory " + LuaVMManager.Instance.Lua_Env.Memroy + "K");
        }
    }
}
