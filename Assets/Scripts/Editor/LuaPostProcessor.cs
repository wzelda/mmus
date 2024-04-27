using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEngine;
using UnityEditor;
using System.IO;
using LPCFramework;
using BaseNcoding;
using UnityEditor.AddressableAssets.Settings;
using UnityEditor.AddressableAssets;

namespace Assets.Editor.XLua
{
    class LuaPostProcessor : AssetPostprocessor
    {
        /*
        [MenuItem("打包/资源打包/Lua资源预处理")]
        public static void MakeLuaAddressable()
        {
            GenLuaBytesFolder("Assets/Lua");
        }

        [MenuItem("Assets/Lua资源打包预处理")]
        public static void GenLuaBytesFiles()
        {
            string path = AssetDatabase.GetAssetPath(Selection.activeObject);
            if (!string.IsNullOrEmpty(path))
            {
                if (AssetDatabase.IsValidFolder(path))
                {
                    GenLuaBytesFolder(path);
                }
                else
                {
                    GenLuaBytesFile(path);
                    AssetDatabase.SaveAssets();
                }
            }
        }

        static void GenLuaBytesFolder(string path)
        {
            foreach (var luaAsset in AssetDatabase.FindAssets("*", new string[] { path }))
            {
                GenLuaBytesFile(AssetDatabase.GUIDToAssetPath(luaAsset));
            }
            AssetDatabase.SaveAssets();
        }

        static void GenLuaBytesFile(string luaAsset)
        {
            if (luaAsset.EndsWith(".lua"))
            {
                var luaByteFile = luaAsset + ".bytes";
                var luaTxt = File.ReadAllText(luaAsset);
                var luaData = LuaUtils.Compress(luaTxt);
                luaTxt = Base91.Instace.Encode(luaData);
                File.WriteAllText(luaByteFile, luaTxt);

                //var asset = new TextAsset(luaTxt);
                AssetDatabase.Refresh();

                var settings = AddressableAssetSettingsDefaultObject.Settings;
                if (settings != null)
                {
                    var guid = AssetDatabase.AssetPathToGUID(luaByteFile);
                    var group = settings.FindGroup("Lua");
                    var entry = settings.CreateOrMoveEntry(guid, group);
                    entry.labels.Add("Lua");
                    entry.address = luaAsset.Replace("Assets/", "");
                    settings.SetDirty(AddressableAssetSettings.ModificationEvent.EntryMoved, entry, true);
                }
            }
        }

        [MenuItem("打包/资源打包/清除Lua字节码资源文件")]
        public static void ClearLuaBytesFiles()
        {
            foreach (var luaAsset in AssetDatabase.FindAssets("*.lua", new string[] { "Assets/Lua" }))
            {
                var assetPath = AssetDatabase.GUIDToAssetPath(luaAsset);
                if (assetPath.EndsWith(".lua.bytes"))
                {
                    AssetDatabase.DeleteAsset(assetPath);
                }
            }
        }
        */

        private static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromPath)
        {
            foreach (string asset in importedAssets)
            {
                if (asset.EndsWith(".lua"))
                {
                    string luaText = null;
                    using (var luaFile = File.OpenRead(asset))
                    {
                        if (luaFile.Length < 3) continue;

                        byte[] head = new byte[3];
                        luaFile.Read(head, 0, 3);

                        if (head[0] != 0xef || head[1] != 0xbb || head[2] != 0xbf)
                        {
                            continue;
                        }

                        luaFile.Seek(0, SeekOrigin.Begin);

                        var streamReader = new StreamReader(luaFile, Encoding.UTF8);
                        luaText = streamReader.ReadToEnd();
                    }

                    Debug.Log("Automatic remove utf8 bom: " + asset);
                    File.WriteAllText(asset, luaText, new UTF8Encoding(false));
                }
            }
        }
    }
}