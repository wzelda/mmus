local QualityMgr = {}


local deviceInfoCfg = nil

-- 设备高中低，跟腾讯发来的机型列表一致
DeviceQuality = 
{
    High = 1,
    Mid = 2,
    Low = 3
}

-- 当前机型的配置等级
QualityMgr.CurDeviceQuality = nil
-- 当前画质等级
QualityMgr.GraphicQuality = nil

-- 用户设定的画质
function QualityMgr.GetUserQuaility()
    return LocalData.getGraphicQuality(0)
end

function QualityMgr.SaveUserQuaility(level)
    if nil == level then return end
    QualityMgr.ApplyGraphicsQuality(level, true)
end

function QualityMgr.SetQuaility(level)
    if nil == level then return end
    
    QualityMgr.CurDeviceQuality = level
    QualityMgr.SaveUserQuaility(level)
end

function QualityMgr.GetDeviceQuality()
    if QualityMgr.CurDeviceQuality ~= nil then
        return QualityMgr.CurDeviceQuality
    end

    local SystemInfo = CS.UnityEngine.SystemInfo

    local deviceModel = SystemInfo.deviceModel

    if (deviceInfoCfg == nil) then
        deviceInfoCfg = require "Config.DevicesInfoConfig"
    end

    print("Device model Begin :"..deviceModel)

    local level = DeviceQuality.Low
    -- deviceModel 
    -- ios deviceModel = deviceInfoCfg中的key
    -- android deviceModel = [xxx deviceInfoCfg中的key]

    local findex = string.find(deviceModel, " ")
    if findex ~= nil then
        deviceModel = string.sub(deviceModel, findex, -1)
    end
    print("Device model After :".. deviceModel)


    print("SystemInfo processorFrequency :", SystemInfo.processorFrequency)

    print("SystemInfo processorCount :", SystemInfo.processorCount)

    print("SystemInfo systemMemorySize :", SystemInfo.systemMemorySize)

    print("SystemInfo graphicsMemorySize :", SystemInfo.graphicsMemorySize)

    --if deviceInfoCfg ~= nil and deviceInfoCfg[deviceModel] ~= nil 
    --and deviceInfoCfg[deviceModel].DeviceLevel ~= nil 
    --and type(deviceInfoCfg[deviceModel].DeviceLevel) == "number" then
    --
    --    -- 使用腾讯发来的表来分一个等级
    --    QualityMgr.CurDeviceQuality = deviceInfoCfg[deviceModel].DeviceLevel
    --
    --    if QualityMgr.CurDeviceQuality == nil then
    --
    --        QualityMgr.CurDeviceQuality = 1
    --
    --    end
    --
    --    print("From Cfg CurDeviceQuality :", QualityMgr.CurDeviceQuality)
    --else

        -- 否则自己根据 内存，主频,内核 来临时区分下高中低配置
        -- 
        if (SystemInfo.systemMemorySize <= 0) and (SystemInfo.processorCount <= 0) then
            --無法獲取機器信息 大概率為新機型
            QualityMgr.CurDeviceQuality = DeviceQuality.High
        elseif (SystemInfo.systemMemorySize <= 1100) and (SystemInfo.processorCount <= 1) then
            -- 低端机器
            QualityMgr.CurDeviceQuality = DeviceQuality.High 


        --elseif (SystemInfo.systemMemorySize < 4100) and (SystemInfo.processorCount < 6) then
            -- 中端機器
            --QualityMgr.CurDeviceQuality = DeviceQuality.Low

        else
            QualityMgr.CurDeviceQuality = DeviceQuality.High
        end
        print("From NoCfg CurDeviceQuality :", QualityMgr.CurDeviceQuality)
    --end
    if LuaUtils.SetSystemMemoryCacheSize then
        LuaUtils.SetSystemMemoryCacheSize()
    end

    return QualityMgr.CurDeviceQuality
end

function QualityMgr.InitQuaility()
    QualityMgr.GetDeviceQuality()
    -- 用户设定优先
    local level = QualityMgr.GetUserQuaility()
    if level and level ~= 0 then
        QualityMgr.GraphicQuality = level
    else
        QualityMgr.GraphicQuality = QualityMgr.CurDeviceQuality
    end
    QualityMgr.ApplyGraphicsQuality(QualityMgr.GraphicQuality, true)
end

function QualityMgr.ApplyGraphicsQuality(quality, save)
    if not Application.isEditor then
        Application.targetFrameRate = quality > DeviceQuality.Mid and 60 or 30
    end
    if save then
        QualityMgr.GraphicQuality = quality
        LocalData.saveGraphicQuality(quality)
    end
end

return QualityMgr

