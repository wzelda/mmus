using System.IO;
using UnityEditor;
using UnityEngine;
using System.Collections.Generic;

namespace FishClient.Editor
{
    public class Tools
    {

        [MenuItem("Tools/清除游戏存档")]
        public static void ClearPlayerData()
        {
            PlayerPrefs.DeleteAll();
            foreach (var dir in Directory.GetDirectories(Application.persistentDataPath))
            {
                Debug.Log("Delete folder " + dir);
                Directory.Delete(dir, true);
            }

            foreach (var file in Directory.GetFiles(Application.persistentDataPath))
            {
                Debug.Log("Delete file " + file);
                File.Delete(file);
            }
        }

        [MenuItem("Tools/打开游戏存储目录")]
        public static void ShowPlayerDataFile()
        {
            EditorUtility.OpenWithDefaultApp(Application.persistentDataPath);
        }

        [MenuItem("Tools/同步UI资源")]
        public static void SyncUIMaster()
        {
            FishingProjectConfig.lastUIPath = EditorUtility.OpenFolderPanel("选择FairyUI分支导出目录", FishingProjectConfig.lastUIPath, "");

            if (string.IsNullOrEmpty(FishingProjectConfig.lastUIPath))
            {
                Debug.Log("Source directory not valid!");
                return;
            }
            var UIPath = "UI";
            var dirs = Directory.GetDirectories(Path.Combine(Application.dataPath, UIPath), "*");
            foreach (var uidir in dirs)
            {
                var a = Path.GetFileName(uidir);
                if (a.StartsWith("."))
                {
                    continue;
                }
                var pkgDirs = Directory.GetDirectories(FishingProjectConfig.lastUIPath);
                int i = 0;
                foreach (var d in pkgDirs)
                {
                    if (Path.GetFileName(d) == a)
                    {
                        i = i++;
                        EditorUtility.DisplayProgressBar("正在同步UI资源", UIPath + "/" + a, (float)i / pkgDirs.Length);
                        SyncFlatFolder(d, UIPath + "/" + a, false);
                    }
                }
            }
            EditorUtility.ClearProgressBar();
            AssetDatabase.Refresh();
        }

        // 同步两个目录下的文件
        private static void SyncFlatFolder(string srcFolder, string dstFolder, bool forceCopy)
        {
            var absDstFolder = Application.dataPath + "/" + dstFolder;
            if (!Directory.Exists(absDstFolder))
            {
                Directory.CreateDirectory(absDstFolder);
            }

            var syncFiles = new List<string>();
            foreach (var f in Directory.GetFiles(srcFolder, "*.*"))
            {
                if (f.EndsWith(".png") || f.EndsWith(".bytes") || f.EndsWith(".mp3"))
                {
                    syncFiles.Add(Path.GetFileName(f));

                    var dstFilename = Path.Combine(absDstFolder, Path.GetFileName(f));
                    if (File.Exists(dstFilename) && !forceCopy)
                    {
                        var srcFileInfo = new FileInfo(f);
                        var dstFileInfo = new FileInfo(dstFilename);

                        if (srcFileInfo.LastWriteTime != dstFileInfo.LastWriteTime ||
                            srcFileInfo.Length != dstFileInfo.Length)
                        {
                            File.Copy(f, dstFilename, true);
                        }
                    }
                    else
                    {
                        File.Copy(f, dstFilename, true);
                    }
                }
            }

            var filesInDstFolder = AssetDatabase.FindAssets("", new string[] { "Assets/" + dstFolder });
            
            foreach (var guid in filesInDstFolder)
            {
                var f = AssetDatabase.GUIDToAssetPath(guid);

                if (f.EndsWith(".png") || f.EndsWith(".bytes") || f.EndsWith(".mp3"))
                {
                    if (!syncFiles.Contains(Path.GetFileName(f)))
                    {
                        Debug.Log("Delete file " + f);
                        AssetDatabase.DeleteAsset(f);
                    }
                }
            }
        }
    }
}
