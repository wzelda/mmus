using System;
using System.IO;
using System.Runtime.Serialization.Formatters.Binary;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.Serialization;

class FishingProjectConfig
{
    [Serializable]
    class ConfigSaveData
    {
        [SerializeField]
        internal string lastExcelPath;
        [SerializeField]
        internal string lastUIPath;
    }

    static ConfigSaveData s_Data;

    public static string lastExcelPath
    {
        get
        {
            ValidateData();
            return s_Data.lastExcelPath;
        }
        set
        {
            ValidateData();
            s_Data.lastExcelPath = value;
            SaveData();
        }
    }
    
    public static string lastUIPath
    {
        get
        {
            ValidateData();
            return s_Data.lastUIPath;
        }
        set
        {
            ValidateData();
            s_Data.lastUIPath = value;
            SaveData();
        }
    }

    internal static void SerializeForHash(Stream stream)
    {
        ValidateData();
        BinaryFormatter formatter = new BinaryFormatter();
        formatter.Serialize(stream, s_Data);
    }
    
    static void ValidateData()
    {
        if (s_Data == null)
        {
            var dataPath = Path.GetFullPath(".");
            dataPath = dataPath.Replace("\\", "/");
            dataPath += "/Library/FishingConfig.dat";
            if (File.Exists(dataPath))
            {
                BinaryFormatter bf = new BinaryFormatter();
                try
                {
                    using (FileStream file = new FileStream(dataPath, FileMode.Open, FileAccess.Read))
                    {
                        var data = bf.Deserialize(file) as ConfigSaveData;
                        if (data != null)
                        {
                            s_Data = data;
                        }
                    }
                }
                catch
                {
                    //if the current class doesn't match what's in the file, Deserialize will throw. since this data is non-critical, we just wipe it
                    Addressables.LogWarning("Error reading Addressable Asset project config (play mode, etc.). Resetting to default.");
                    File.Delete(dataPath);
                }
            }
            //check if some step failed.
            if (s_Data == null)
            {
                s_Data = new ConfigSaveData();
            }
        }
    }

    static void SaveData()
    {
        if (s_Data == null)
            return;
        var dataPath = Path.GetFullPath(".");
        dataPath = dataPath.Replace("\\", "/");
        dataPath += "/Library/FishingConfig.dat";
        BinaryFormatter bf = new BinaryFormatter();
        FileStream file = File.Create(dataPath);
        bf.Serialize(file, s_Data);
        file.Close();
    }
}