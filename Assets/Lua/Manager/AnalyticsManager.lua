-- 统计分析、事件上报
local AnalyticsManager = {}

-- local reportSDK = CS.ByteDance.Union.LGLogManager

local json = require "rapidjson"
local SeaConfig = Utils.LoadConfig("Config.SeaConfig")

local FunctionOpenConfig

-- 全局参数
local globalParams = {
    lev = 1,
    max_lev = 1,
    play_id = 0,
    play_lev = 0,
    max_play_id = 0,
    max_play_lev = 0
}

local function reportEvent(evt, params)
    if AnalyticsManager.blockReport then
        return
    end

    local jsobj = {}

    for k,v in pairs(globalParams) do
        jsobj[k] = v
    end

    for k,v in pairs(params) do
        jsobj[k] = v
    end

    -- reportSDK.OnEventV3(evt, json.encode(jsobj))
end

local function OnSwitchSea()
    local seaData = PlayerDatas.SeaData
    local currentSea = seaData:GetCurSea().ID
    globalParams.play_id = currentSea
    globalParams.play_lev = seaData:GetFishOpenCount(currentSea) + 1
end

local function OnUnlockSea()
    local seaData = PlayerDatas.SeaData
    local lastSea = seaData:GetLastSea()
    local lastSeaCfg = SeaConfig.SeasByID[lastSea]
    globalParams.max_play_id = lastSea
    globalParams.max_play_lev = #lastSeaCfg.Products
end

function AnalyticsManager.onPlayerLoaded()
    local seaData = PlayerDatas.SeaData
    local currentSea = seaData:GetCurSea().ID
    globalParams.play_id = currentSea
    globalParams.play_lev = seaData:GetFishOpenCount(currentSea) + 1
    local lastSea = seaData:GetLastSea()
    local lastSeaCfg = SeaConfig.SeasByID[lastSea]
    globalParams.max_play_id = lastSea
    globalParams.max_play_lev = #lastSeaCfg.Products

    globalParams.lev = PlayerDatas.AchievementData.achieveTitleId or 1
    globalParams.max_lev = #ConfigData.achievementConfig.AchievementTitle

    reportEvent("gt_log_in", {log_type="default"})

    AnalyticsManager.onModuleConvertion(2, "login_result", "success")

    reportEvent("gt_init_info", {
        user_id = PlayerData.id,
        user_name = "",
        extra_1=tostring(PlayerData.diamondNum),
        extra_2=tostring(PlayerData.coinNum),
        extra_3=tostring(PlayerData:GetRealCoinIncome()),
        extra_4=tostring(PlayerDatas.AchievementData.achieveTitleId),
        extra_5=""
    })
end

local function GetRitID()
    return SDKManager.ritId or 0
end

function AnalyticsManager.onADRequest(type, rid)
    rid = rid or GetRitID()
    reportEvent("gt_ad_request", {ad_type=type, rit_id=rid})
end

function AnalyticsManager.onADSend(type, rid, ad_code)
    rid = rid or GetRitID()
    reportEvent("gt_ad_send", {ad_type=type, rit_id=rid, ad_code=tostring(ad_code)})
end

function AnalyticsManager.onADButtonShow(type, position, position_type, rit_id)
    rit_id = rit_id or GetRitID()
    reportEvent("gt_ad_button_show", {ad_type=type, ad_position=position,ad_position_type=position_type, rit_id=rit_id})
end

function AnalyticsManager.onADButtonClick(type, position, position_type, rit_id)
    rit_id = rit_id or GetRitID()
    reportEvent("gt_ad_button_click", {ad_type=type, ad_position=position,ad_position_type=position_type, rit_id=rit_id})
end

function AnalyticsManager.onADShow(type, position, position_type, rit_id, rit_scene, rit_scene_describe)
    rit_id = rit_id or GetRitID()
    reportEvent("gt_ad_show", {ad_type=type, ad_position=position,ad_position_type=position_type, rit_id=rit_id, rit_scene=rit_scene, rit_scene_describe=rit_scene})
end

function AnalyticsManager.onADShowEnd(type, position, position_type, rit_id, result)
    rit_id = rit_id or GetRitID()
    reportEvent("gt_ad_show_end", {ad_type=type, ad_position=position,ad_position_type=position_type, rit_id=rit_id, result=result})
end

function AnalyticsManager.onGuide(guide_id, guide_name)
    reportEvent("gt_guide", {guide_id=guide_id, guide_name=guide_name})
end


function AnalyticsManager.onStartPlay(play_type, play_id, play_lev)
    globalParams.play_id = play_id
    globalParams.play_lev = play_lev

    reportEvent("gt_start_play", {
        play_type=play_type, play_id=play_id, play_lev=play_lev,
        is_continue = 1,
        role_id = "",
        pet_id = "",
        skin_id = "",
        equ1_id = "",
        equ2_id = "",
        equ3_id = "",
        equ4_id = "",
        equ5_id = "",
        equ6_id = "",
        role_type1_num = 0,
        role_type2_num = 0,
        role_type3_num = 0
    })
end

function AnalyticsManager.onEndPlay(play_type, play_id, play_lev, result, percentage, skill_times, duration)
    skill_times = skill_times or 0
    reportEvent("gt_end_play", {
        play_type=play_type, play_id=play_id, play_lev=play_lev, result=result, percentage=percentage, skill_times=skill_times,
        score=0,
        duration=duration,
        kill_num = 0,
        passed = "no",
        rank = "",
        is_continue = 1,
        role_id = "",
        pet_id = "",
        skin_id = "",
        equ1_id = "",
        equ2_id = "",
        equ3_id = "",
        equ4_id = "",
        equ5_id = "",
        equ6_id = "",
        role_type1_num = 0,
        role_type2_num = 0,
        role_type3_num = 0
    })
end

-- 解锁功能
function AnalyticsManager.onUnlockSystem(system_id, accessory_id, accessory_name)
    FunctionOpenConfig = FunctionOpenConfig or Utils.LoadConfig("Config.FunctionOpenConfig")
    local func = FunctionOpenConfig.FunctionsByID[system_id]
    result = tostring(result)
    reportEvent("gt_unlock_system", {system_name=func.Title, system_id=system_id,
        accessory_id= accessory_id or 0,
        accessory_name= accessory_name or ""
    })
end

function AnalyticsManager.onJoinSystem(system_id, accessory_id,accessory_name, result)
    FunctionOpenConfig = FunctionOpenConfig or Utils.LoadConfig("Config.FunctionOpenConfig")
    local func = FunctionOpenConfig.FunctionsByID[system_id]
    result = tostring(result)
    reportEvent("gt_join_system", {system_name=func.Title, system_id=system_id, accessory_id=accessory_id, accessory_name=accessory_name,
        result_1=result, result_2=""
    })
end

function AnalyticsManager.onModuleConvertion(module_id, module_name, result)
    reportEvent("gt_module_conversion", {module_id=module_id, module_name=module_name, result=result})
end

function AnalyticsManager.onMissionEnd(mission_type, mission_id, mission_name)
    reportEvent("gt_mission_end", {mission_type=mission_type, mission_id=mission_id, mission_name=mission_name,
        mission_lev = 0
    })
end

function AnalyticsManager.onMissionReward(mission_type, mission_id, mission_name)
    reportEvent("gt_mission_reward", {mission_type=mission_type, mission_id=mission_id, mission_name=mission_name})
end

-- 领取主线任务奖励
local function  OnGetMainTaskPrize(info)
    AnalyticsManager.onMissionReward("主线任务", info.cfg.ID, info.cfg.Name)
end

-- 成就任务
local function OnGetArchievePrize(info)
    AnalyticsManager.onMissionReward("成就任务", info.cfg.ID, info.cfg.Name)
end

-- 获得称号
local function OnUpgradeTitle(info)
    reportEvent("gt_levelup", {type="称号等级", aflev=globalParams.lev})
    globalParams.lev = PlayerDatas.AchievementData.achieveTitleId
end

function AnalyticsManager.initialize()
    EventDispatcher:Add(Event.SEA_SWITCH, OnSwitchSea)
    EventDispatcher:Add(Event.SEA_UNLOCK, OnUnlockSea)
    EventDispatcher:Add(Event.GET_MAIN_TASK_PRIZE, OnGetMainTaskPrize)
    EventDispatcher:Add(Event.GET_ACHIEVE_PRIZE, OnGetArchievePrize)
    EventDispatcher:Add(Event.UPGRADE_ACHIEVE_TITLE, OnUpgradeTitle)
    
    AnalyticsManager.onModuleConvertion(1, "initialize", "success")
end

function AnalyticsManager.onDestroy()
    EventDispatcher:Remove(Event.SEA_SWITCH, OnSwitchSea)
    EventDispatcher:Remove(Event.SEA_UNLOCK, OnUnlockSea)
    EventDispatcher:Remove(Event.GET_MAIN_TASK_PRIZE, OnGetMainTaskPrize)
    EventDispatcher:Remove(Event.GET_ACHIEVE_PRIZE, OnGetArchievePrize)
    EventDispatcher:Remove(Event.UPGRADE_ACHIEVE_TITLE, OnUpgradeTitle)
end

return AnalyticsManager