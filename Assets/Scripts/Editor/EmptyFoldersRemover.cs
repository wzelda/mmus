using UnityEngine;
using UnityEditor;
using System.IO;

public class EmptyFoldersRemover
{
    const string AssetsString = "Assets";

    [MenuItem("Tools/移除空目录")]
    public static void RemoveEmptyFolders()
    {
        RemoveEmptyFolders(AssetsString);
    }

    public static void RemoveEmptyFolders(string path)
    {
        var dirs = Directory.GetDirectories(path);

        if (dirs.Length == 0)
        {
            DeleteUpmostEmptyDirectory(path);
        }
        else
        {
            foreach (var dir in dirs)
            {
                RemoveEmptyFolders(dir);
            }
        }
    }

    static void DeleteUpmostEmptyDirectory(string assetDir)
    {
        try
        {
            if (assetDir == AssetsString)
                return;
            string absoluteDir = AssetPathToAbsolutePath(assetDir);
            string[] files = Directory.GetFiles(absoluteDir, "*.*", SearchOption.AllDirectories);
            if (files.Length == 0)
            {
                AssetDatabase.DeleteAsset(assetDir);
                DeleteUpmostEmptyDirectory(Path.GetDirectoryName(assetDir));
            }
        }
        catch
        {
        }
    }

    static string AssetPathToAbsolutePath(string assetPath)
    {
        if (assetPath == AssetsString)
            return Application.dataPath;
        else
            return Path.Combine(Application.dataPath, assetPath.Substring(AssetsString.Length + 1));
    }
}