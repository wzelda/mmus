-- 本地存储
local LocalDataType = {
    AccountId = "AccountId",
    Password = "Password",            
    AudioMusic = "AudioMusic",
    AudioEffect = "AudioEffect",
    AudioMusicOn = "AudioMusicOn",
    AudioEffectOn = "AudioEffectOn",            
}
-- c#层
local PlayerPrefs = CS.UnityEngine.PlayerPrefs

-- 本地数据
LocalData = {}

-- 清除所有
function LocalData.clearAll()
    PlayerPrefs.Clear()
end

-- 唯一key值
local function getUnqiodKey()
    -- 服务器id和账户id
    -- return NetworkManager.account.server.sid .. "_" .. NetworkManager.account.id
    return PlayerData.id or ""
end

-- 包含用户信息的唯一key
local function getUniqueKey(key)
    return string.format("%s_%s", getUnqiodKey(), key)
end

-- 保存用户帐号
function LocalData.saveUserAccount(id)
    -- 账户信息
    NetworkManager.account.id = id
    PlayerPrefs.SetString(LocalDataType.AccountId, id)
end

-- 获取用户帐号
function LocalData.getUserAccount()
    return PlayerPrefs.GetString(LocalDataType.AccountId)
end

-- 保存音乐状态
function LocalData.saveAudioMusicSwitch(stat)
    PlayerPrefs.SetInt(LocalDataType.AudioMusicOn, stat)
end

-- 获取音乐状态
function LocalData.getAudioMusicSwitch()
    return PlayerPrefs.GetInt(LocalDataType.AudioMusicOn)
end

-- 保存音效状态
function LocalData.saveAudioEffectSwitch(stat)
    PlayerPrefs.SetInt(LocalDataType.AudioEffectOn, stat)
end

-- 获取音效状态
function LocalData.getAudioEffectSwitch()
    return PlayerPrefs.GetInt(LocalDataType.AudioEffectOn)
end

-- 保存音乐音量
function LocalData.saveAudioMusicVolume(volume)
    PlayerPrefs.SetFloat(LocalDataType.AudioMusic, volume * 2)
end

-- 获取音乐音量
function LocalData.getAudioMusicVolume()
    return PlayerPrefs.GetFloat(LocalDataType.AudioMusic, 1) * 0.5
end

-- 保存音效音量
function LocalData.saveAudioEffectVolume(volume)
    PlayerPrefs.SetFloat(LocalDataType.AudioEffect, volume * 1.25)
end

-- 获取音效音量
function LocalData.getAudioEffectVolume()
    return PlayerPrefs.GetFloat(LocalDataType.AudioEffect, 1) * 0.8
end

-- 获取画面质量
function LocalData.getGraphicQuality(defaultValue)
    return PlayerPrefs.GetInt(LocalDataType.GraphicQuality, defaultValue)
end

-- 保存画面质量
function LocalData.saveGraphicQuality(value)
    PlayerPrefs.SetInt(LocalDataType.GraphicQuality, value)
end

-- 获取离线时间
function LocalData.getOfflineTime()
    return PlayerPrefs.GetInt(getUniqueKey("OfflineTime"), 0)
end

-- 保存离线时间
function LocalData.saveOfflineTime(value)
    PlayerPrefs.SetInt(getUniqueKey("OfflineTime"), math.floor(value))
end

-- 获取翻倍收益时间
function LocalData.getDoubleTime()
    return PlayerPrefs.GetInt(getUniqueKey("DoubleTime"), 0)
end

-- 保存翻倍收益时间
function LocalData.saveDoubleTime(value)
    PlayerPrefs.SetInt(getUniqueKey("DoubleTime"), math.floor(value))
end

-- 获取是否震动，默认开启
function LocalData.getVibrateOn()
    return PlayerPrefs.GetInt("VibrateOn", 1) == 1
end

-- 保存震动
function LocalData.saveVibrateOn(flag)
    PlayerPrefs.SetInt("VibrateOn", flag and 1 or 0)
end

-- 获取广告点击次数
function LocalData.getAdClickCount()
    return PlayerPrefs.GetInt(getUniqueKey("AdClickCount"), 0)
end

-- 保存广告点击次数
function LocalData.saveAdClickCount(value)
    if nil == value then return end
    PlayerPrefs.SetInt(getUniqueKey("AdClickCount"), math.floor(value))
end

-- 获取沉船探宝次数
function LocalData.getShipExchangeCount()
    return PlayerPrefs.GetInt(getUniqueKey("ShipExchangeCount"), 0)
end

-- 保存沉船探宝次数
function LocalData.saveShipExchangeCount(value)
    if nil == value then return end
    PlayerPrefs.SetInt(getUniqueKey("ShipExchangeCount"), math.floor(value))
end

-- 获取当日沉船探宝次数
function LocalData.getDailyShipExchangeCount()
    return PlayerPrefs.GetString(getUniqueKey("DailyShipExchangeCount"))
end

-- 保存当日沉船探宝次数
function LocalData.saveDailyShipExchangeCount(value)
    if nil == value then return end
    PlayerPrefs.SetString(getUniqueKey("DailyShipExchangeCount"), value)
end

-- 获取用户数据保存时间
function LocalData.getDataSaveTime()
    return PlayerPrefs.GetInt(getUniqueKey("DataSaveTime"), 0)
end

-- 保存用户数据保存时间
function LocalData.saveDataSaveTime(value)
    value = value or 0
    PlayerPrefs.SetInt(getUniqueKey("DataSaveTime"), math.floor(value))
end

-- 强制引导id
function LocalData.getBigGuideID()
    return PlayerPrefs.GetInt(getUniqueKey("BigGuideID"), 0)
end

function LocalData.saveBigGuideID(value)
    value = value or 0
    PlayerPrefs.SetInt(getUniqueKey("BigGuideID"), value)
end

return LocalData
