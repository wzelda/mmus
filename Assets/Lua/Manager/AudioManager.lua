local AudioManager = {}

local AudioConfig = require("Config.AudioConfig") --音乐配置
local audioMusicVolume = nil
local audioEffectVolume = nil
local audioMusicSwitch = 1
local audioEffectSwitch = 1
-- 震动开关
local vibrateSwitch = false
-- 当前背景音乐
local curBgAudio
-- 当前循环音效
local loopEAXList = {}

local audioEAXFrameMap = {}

local AudioCSManager = CS.LPCFramework.AudioManager.Instance
-- 当场景切换
local function onSceneExit()
    AudioCSManager:SetAudioListener(nil)
end
--Event.addListener(Event.EXIT_SCENCE, onSceneExit)

-- 当场景切换
local function onSceneEnter()
    local target = CS.UnityEngine.Camera.main
    if nil ~= target then
        target = target.gameObject
    end
    AudioCSManager:SetAudioListener(target)
end
--Event.addListener(Event.ENTER_SCENCE, onSceneEnter)

--美术需求同一帧只播一个特效，以防止音效较多爆炸
-- 如果true, 则已经有了, 如果false, 则会自己把自己加进去
local function putEAXSoundIfAbsent(audioname)
    if audioEAXFrameMap.frame ~= Time.frameCount then
        for k,v in pairs(audioEAXFrameMap) do audioEAXFrameMap[k]=nil end
        audioEAXFrameMap.frame = Time.frameCount
        audioEAXFrameMap[audioname] = true
        return false
    end
    
    if audioEAXFrameMap[audioname] then
        return true
    else
        audioEAXFrameMap[audioname] = true
        return false
    end
end

local function getAudioCfgByName(audioname)
    for i, v in ipairs(AudioConfig.AudioConfig) do
        if v.Name == audioname then
            return v
        end
    end
end

local function getAudioPathByName(audioname)
    local cfg = getAudioCfgByName(audioname)
    return cfg and cfg.Path
end

local function getAudioPathById(audioId)
    local cfg = AudioConfig.AudioConfigByID[audioId]
    return cfg and cfg.Path
end

function AudioManager.initialize()
    vibrateSwitch = LocalData.getVibrateOn()
end

function AudioManager.PlayEAXSound(audioId, isLoop, isCanPitch)
    if(putEAXSoundIfAbsent(audioId))then
        return nil
    else
        isLoop = isLoop or false
        if isLoop then
            loopEAXList[audioId] = audioId
        end
        if(isCanPitch == nil)then
            isCanPitch = true
        end
        local cfg = AudioConfig.AudioConfigByID[audioId]
        if cfg then
            return AudioCSManager:PlayerEAXAudio(cfg.Name, cfg.Path, isLoop, isCanPitch)
        end
    end
end

function AudioManager.StopEAXSound(audioId)
    if loopEAXList == nil or audioId == nil then
        return
    end
    loopEAXList[audioId] = nil
    local cfg = AudioConfig.AudioConfigByID[audioId]
    if cfg and cfg.Name then
        AudioCSManager:StopEAX(cfg.Name)
    end
end

function AudioManager.PauseBGAudio()
    AudioCSManager:PauseBGAudio()
end

-- 播放
function AudioManager.PlayerBgAudio(audioId)
    if curBgAudio == audioId then return end

    curBgAudio = audioId
    local cfg = AudioConfig.AudioConfigByID[audioId]
    if cfg then
        return AudioCSManager:PlayerBgAudio(cfg.Name, cfg.Path)
    end
end

-- 播放循环音效
-- stopOther:播放时停止其他循环音乐
function AudioManager.PlayerLoopEAX(audioId, stopOther)
    if loopEAXList[audioId] then return end

    stopOther = stopOther or false
    if stopOther then
        for k, v in pairs(loopEAXList) do
            AudioManager.StopEAXSound(v)
        end
        loopEAXList = {}
    end

    return AudioManager.PlayEAXSound(audioId, true)
end

function AudioManager.SetEXAPitch(pitch)
    
    return AudioCSManager:SetEXAPitch(pitch or 1)
end

function AudioManager.GetGroupState(audiogroupid)
    
    return AudioCSManager:GetGroupState(audiogroupid)
end

function AudioManager.SetGroupState(audiogroupid,option)
    AudioCSManager:SetGroupState(audiogroupid,option)
end

function AudioManager.DoAudioState(audioSourceData, option)
    if(audioSourceData and not Utils.unityTargetIsNil(audioSourceData.audiosource))then
        AudioCSManager:DoAudioState(audioSourceData,option)
    end
end

function AudioManager.ClearAllAudio()
    AudioCSManager:ClearAllAudio()
end

function AudioManager.ClearAuidoEff()
    AudioCSManager:ClearAuidoEff()
end

-- 获取声效开关
function AudioManager.GetSwitchAudioEffect()
    return LocalData.getAudioEffectSwitch()
end

-- 获取音乐开关
function AudioManager.GetSwitchAudioMusic()
    return LocalData.getAudioMusicSwitch()
end

-- 全局声效
function AudioManager.GetAudioEffectVolume()
    return LocalData.getAudioEffectVolume()
end

-- 全局音乐
function AudioManager.GetAudioMusicVolume()
    return LocalData.getAudioMusicVolume()
end

-- 全局声效开关
function AudioManager.SwitchAudioEffect(on)
    audioEffectSwitch = on
    LocalData.saveAudioEffectSwitch(on)
    local curValue = audioEffectSwitch * audioEffectVolume
    AudioCSManager:SetAudioEffectVolume(curValue)
end

-- 全局音乐开关
function AudioManager.SwitchAudioMusic(on)
    audioMusicSwitch = on
    LocalData.saveAudioMusicSwitch(on)
    AudioCSManager:SetAudioMusicVolume(audioMusicSwitch * audioMusicVolume)
end

-- 全局声效
function AudioManager.SetAudioEffectVolume(volume, save)
    audioEffectVolume = volume
    local curValue = audioEffectSwitch * audioEffectVolume
    AudioCSManager:SetAudioEffectVolume(curValue)
    if save ~= false then
        LocalData.saveAudioEffectVolume(volume)
    end
end

-- 全局音乐
function AudioManager.SetAudioMusicVolume(volume, save)
    audioMusicVolume = volume
    AudioCSManager:SetAudioMusicVolume(audioMusicSwitch * audioMusicVolume)
    if save ~= false then
        LocalData.saveAudioMusicVolume(volume)
    end
end

function AudioManager.SetAudioVolumeDown() 
    CS.LPCFramework.AudioManager.Instance:SetAudioMusicVolume(0)
end

function AudioManager.SetAudioVolumeUp() 
    CS.LPCFramework.AudioManager.Instance:SetAudioMusicVolume(audioMusicSwitch * audioMusicVolume)
end

function AudioManager.EnableVibrate(flag) 
    vibrateSwitch = flag == true
    LocalData.saveVibrateOn(vibrateSwitch)
end

function AudioManager.IsVibrate() 
    return vibrateSwitch == true
end

function AudioManager.Vibrate()
    print("震动开启：",vibrateSwitch)
    if vibrateSwitch then
        UnityEngine.Handheld.Vibrate()
    end
end

-- 设置全局音量
--audioMusicSwitch = AudioManager.GetSwitchAudioMusic()
--audioEffectSwitch = AudioManager.GetSwitchAudioEffect()

AudioManager.SetAudioEffectVolume(AudioManager.GetAudioEffectVolume())
AudioManager.SetAudioMusicVolume(AudioManager.GetAudioMusicVolume())

return AudioManager
