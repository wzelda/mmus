using BaseNcoding;
using LPCFramework;
using System.IO;
using UnityEditor;

using UnityEngine;

[UnityEditor.AssetImporters.ScriptedImporter(1, "lua")]
public class LuaImporter : UnityEditor.AssetImporters.ScriptedImporter
{
    public bool encrypt = true;
    public override void OnImportAsset(UnityEditor.AssetImporters.AssetImportContext ctx)
    {
        var text = File.ReadAllText(ctx.assetPath);

        Debug.Log("OnImportAsset " + ctx.assetPath);
        if (encrypt)
        {
            var luaData = LuaUtils.Compress(text);
            text = Base91.Instace.Encode(luaData);
        }

        var asset = new TextAsset(text);
        ctx.AddObjectToAsset("main obj", asset);
        ctx.SetMainObject(asset);
    }
}