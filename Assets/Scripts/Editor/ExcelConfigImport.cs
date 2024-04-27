using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEditor;
using System.Diagnostics;
using UnityEngine;
using System.IO;

public class ExcelConfigImport
{
    [MenuItem("Tools/导入Excel配置文件")]
    public static void Import()
    {
        FishingProjectConfig.lastExcelPath = EditorUtility.OpenFolderPanel("Select Excel file folder", FishingProjectConfig.lastExcelPath, "");

        var xlsxFolder = FishingProjectConfig.lastExcelPath;
        if (!Directory.Exists(xlsxFolder))
        {
            return;
        }

        string exportScriptFile;
        if (Application.platform == RuntimePlatform.WindowsEditor)
        {
            exportScriptFile = Path.Combine(xlsxFolder, "tools/ExportLua.bat");
        }
        else
        {
            exportScriptFile = Path.Combine(xlsxFolder, "tools/ExportLua.sh");
        }

        if (!File.Exists(exportScriptFile))
        {
            UnityEngine.Debug.LogError("Not exist script file: " + exportScriptFile);
            return;
        }

        var processStartInfo = new ProcessStartInfo();

        if (Application.platform == RuntimePlatform.WindowsEditor)
        {
            //processStartInfo.WindowStyle = ProcessWindowStyle.Hidden;
            //processStartInfo.CreateNoWindow = false;
            processStartInfo.FileName = exportScriptFile;
            processStartInfo.Arguments = Path.Combine(Application.dataPath, "Lua/Config");
            processStartInfo.UseShellExecute = true;
        }
        else
        {
            processStartInfo.FileName = exportScriptFile;
            processStartInfo.Arguments = Path.Combine(Application.dataPath, "Lua/Config");
            processStartInfo.UseShellExecute = false;
            processStartInfo.RedirectStandardError = true;
            processStartInfo.RedirectStandardOutput = true;
        }

        processStartInfo.WorkingDirectory = Path.GetDirectoryName(exportScriptFile);

        try
        {
            var process = Process.Start(processStartInfo);
            process.WaitForExit();

            if (process.ExitCode != 0)
            {
                if (Application.platform != RuntimePlatform.WindowsEditor)
                {
                    UnityEngine.Debug.LogError(process.StandardOutput.ReadToEnd());
                    UnityEngine.Debug.LogError(process.StandardError.ReadToEnd());
                }
            }
            else
            {
                if (Application.platform != RuntimePlatform.WindowsEditor)
                {
                    UnityEngine.Debug.Log(process.StandardOutput.ReadToEnd());
                }
            }
        }
        catch (Exception e)
        {
            UnityEngine.Debug.LogError(e.Message);
        }
    }
}