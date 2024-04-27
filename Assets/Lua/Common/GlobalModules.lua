NetworkManager = nil
LocalizationMgr = nil
AudioManager = nil
QualityMgr = nil
UIManager = nil
VideoMgr = nil
LevelMgrUtil = nil
LoadingUtils = nil

Configs = nil

Utils = nil
UIUtils = nil
UnityUtils = nil
ConstantValue = nil
GameObjectManager = nil
--玩家数据
PlayerData = nil
PlayerDatas = nil

--服务器下发的配置数据
ConfigData = nil
-- 通用ui组件填充方法合集
CommonUIUtils = nil
--[[ -- 强制引导
CompulsiveGuideManager = nil
-- 弱引导
WeakGuideManager = nil ]]
--数字格式转换工具
NumberTranslatorTool = nil

SDKManager = nil

XLuaUtils = nil

GuideManager = nil

local GlobalModule = {}

function GlobalModule.LoadUtils()
    Utils = require "Common.Utils"
    UIUtils = require "Common.UIUtils"
    UIUtils.initialize()
    UnityUtils = require "Common.UnityUtils"
    LoadingUtils = require "UI.Loading.LoadingUtils"
    NumberTranslatorTool = require 'Common.NumberTranslatorTool'
end

function GlobalModule.LoadModule()
    XLuaUtils = require "Common.XUtils"
    require "Common.GameEnum"
    require "Common.LocalValue"
    ConstantValue = require "Common.ConstantValue"
    Configs = require "Config.Configs"
    UIConfig = require "UI.Core.UIConfig"
    LocalizationMgr = require "Manager.LocalizationMgr"
    AudioManager = require "Manager.AudioManager"
    UIManager = require "Manager.UIManager"
    CommonUIObjectManager = require "Manager.CommonUIObjectManager"
    VideoMgr = require "Manager.VideoMgr"
    SDKManager = (require "Manager.SDKManager").new()

    LocalizationMgr.initialize()
    GuideManager = require "Guide.GuideManager"
    GuideLayer = require "UI.Guide.GuideLayer"
    DependManager = require ("Manager.DependManager")
    ReddotManger = require ("Manager.ReddotManger")
    --StoryLayer = require "UI.Story.StoryPanel"

    -- CompulsiveGuideManager = require "Manager.CompulsiveGuideManager"
    WeakGuideManager = require "Guide.WeakGuideManager"
    ConstantValue.initialize()
    UIManager.initialize()
    AudioManager.initialize()

    if GameObjectManager == nil then
        GameObjectManager = (require "Manager.GameObjectManager").new()
    end
end

--热更结束后加载
local function LoadLuaFile(complete)
    if QualityMgr == nil then
        QualityMgr = (require "Manager.QualityMgr")

        QualityMgr.InitQuaility()
    end

    --coroutine.yield()

    local loadluanum = 3

    if QualityMgr.DeviceQuality == DeviceQuality.High then
        loadluanum = 9
    elseif QualityMgr.DeviceQuality == DeviceQuality.Mid then
        loadluanum = 6
    else
        loadluanum = 3
    end

    --客户端配置数据
    --[[ local x = 0
    for k, fun in pairs(Configs) do
        if fun ~= nil and type(fun) == "function" then
            fun()
            x = x + 1
            if x % loadluanum == 0 then
            --coroutine.yield()
            end
        end
    end ]]

    local classcfg = require "Config.ClassConfig"
    x = 0
    for k, fun in pairs(classcfg) do
        if fun ~= nil and type(fun) == "function" then
            fun()
            x = x + 1
            if x % loadluanum == 0 then
            --coroutine.yield()
            end
        end
    end

    if CommonUIUtils == nil then
        CommonUIUtils = require "Common.CommonUIUtils"
    end

    NetworkManager = require "Manager.NetworkManager"
    NetworkManager.initialize()
    --coroutine.yield()

    --玩家数据
    PlayerData = ClassConfig.PlayerDataClass()

    PlayerData:ctor()

    PlayerDatas = PlayerData.Datas

    --print("F6  ".. tostring(Time.realtimeSinceStartup))

    --服务器下发的配置数据
    ConfigData = ClassConfig.ConfigDataClass()

    if complete then
        complete()
    end
end

function GlobalModule.OnHotUpdate()
    LoadLuaFile()
end

return GlobalModule
