--[[
    引导教程管理器
    author:{author}
    time:2020-04-07 16:02:55
]]

local GuideManager = {}

--引导的主配置
local guideConfig = nil
-- 引导开始条件
local guideConditions = nil
-- 引导触发事件
local guideTrigerEvt = {}

--是否开启引导
local isCreateGuideUI = true

-- 设置引导模式为ON
function GuideManager.SetGuideUI_ON()
    isCreateGuideUI = true
end

-- 设置引导模式为OFF
function GuideManager.SetGuideUI_OFF()
    isCreateGuideUI = false
end

-- 当前是否处于引导中
local isInGuide = false

-- 当前协助新手引导处理的特殊类
local currentGuideClass = nil

local currentFileName = nil

--当前正在执行的教程的id
local currentGuideId = nil

-- 对话面板
local StoryPanel = nil

-- 初始化引导管理器
function GuideManager:initialize()
    isInGuide = false
    guideConditions = require "Config.Guide.tutorial_condition"
    require "Config.Guide.tutorial_cfg"
    
    self.WaitingGuideList = {}
    guideConfig =  _G['GuideCfgTable']
    for k, v in pairs(guideConfig) do 
        if v.catName and v.catName ~= "" then
            require(string.format("Config.Guide.%s",v.catName))
        end
    end

    self:SetRegister()
end

function GuideManager:SetPause(pause)
    self.isMasking  = pause
    Time.timeScale = pause and 0 or 1
end

function GuideManager:SetContinueBack(backFunc)
    if isInGuide and self.isMasking then
        self.backFunc = backFunc
    else
        backFunc()
    end
end

function GuideManager:InGuide()
    return isInGuide
end

function GuideManager:SetRegister()
    EventDispatcher:Add(Event.GUIDE_STEP_OVER,self.DoNextStep,self)
    -- EventDispatcher:Add(Event.MAIN_UI_SHOW,self.EnterScene,self)
    -- EventDispatcher:Add(Event.CG_ENTER_MAINUI,self.EnterScene,self)

    for key,config in pairs(guideConfig) do
        if not IsGuideDone(config.guideId) then 
            for key,tri_cfg in ipairs(config.trigger) do
                if tri_cfg.tipType then
                    if nil == guideTrigerEvt[tri_cfg.tipType] then
                        local func = function(...) self:GuideEventCheck(tri_cfg.tipType,...) end
                        EventDispatcher:Add(tri_cfg.tipType,func)
                        guideTrigerEvt[tri_cfg.tipType] = func
                    end
                end
            end
        end
    end
end

local checkEvent = {
    [Event.CG_ENTER_MAINUI] = function (trigger,config,...)
        -- 进入游戏时有离线奖励不引导
        if PlayerData.gotOfflineReward then
            return false
        end
        return true
    end,
    [Event.OPEN_FUNC] = function (trigger,config,funcID,isUnlock)
        if not IsGuideDone(10) then
            return false
        end

        local result = false
        if trigger.param02 then
            -- param01解锁触发
            result = isUnlock and trigger.param01 == funcID
        elseif trigger.param01 and trigger.param01 ~= "" then
            -- param01未解锁且可解锁触发
            result = not isUnlock and PlayerDatas.FunctionOpenData:ReadyUnlockById(trigger.param01)
        else
            result = true
        end
        return result
    end,
    [Event.CURRENCY_CHANGED] = function (trigger,config,...)
        local funcID = trigger.param01
        if funcID then
            -- 可解锁
            return PlayerDatas.FunctionOpenData:ReadyUnlockById(funcID)
        end
        -- 没填则只是一个触发事件，判定走condition
        return true
    end,
}

--检查是否有引导响应当前事件
function GuideManager:GuideEventCheck(eventType, ...)
    local addWait
    for key,config in ipairs(guideConfig) do
        if IsGuideDone(config.guideId) then 
            --该教程已完成
        else 
            local trigger = config.trigger
            for key,tri_cfg in ipairs(trigger) do
                if tri_cfg.tipType == eventType then
                    local check = false
                    if checkEvent[eventType] then
                        check = checkEvent[eventType](tri_cfg,config,...) == true
                    else
                        -- 纯触发，走condition
                        check = true
                        -- Utils.DebugError("已经添加的引导监听事件，没有进行处理",eventType)
                    end

                    if check and self:CheckCondition(config, ...)
                    and self:CheckGideFile(config.fileName) 
                    and self:GuideTriggerFunctionCheck(tri_cfg,...)
                    then
                        if isInGuide then
                            local contains = Utils.isContainsValue(self.WaitingGuideList,config) 
                            if not contains and currentGuideId ~= config.guideId then
                                table.insert(self.WaitingGuideList,config)
                                addWait = true
                            end
                        else
                            Utils.RemoveItem(self.WaitingGuideList,config)
                            self:StartGuide(config)
                        end
                    end--如果找到了符合条件的引导配置则退出
                end
            end
        end
    end
    -- 引导id排序
    if addWait then
        table.sort(self.WaitingGuideList, function (a,b)
            return a.guideId < b.guideId
        end)
    end
end

-- 玩家进入游戏场景
function GuideManager:EnterScene()
    local config = guideConfig[1]
    if IsGuideDone(config.guideId) then
        return
    end

    if self:CheckCondition(config) then
        self:StartGuide(config)
        return true
    end
    return false
end

-- 打开UI窗口的事件响应
function GuideManager:OnUIOpenEvent(trigger,data,config)
    if trigger.param01 == data then
        return true
    end
    return false
end

-- 玩家升级
function GuideManager:ActorLevelUpgrade(trigger,config)
    if trigger.param01 == PlayerData.actorLevel then
        return true
    end
    return false
end

--获得了新装备
function GuideManager:NewEquipUpdate(trigger,list,config)
    if list==nil or type(list)~="table" then
        return false
    end

    for _,equip in ipairs(list) do
        if equip.equip.data_id == trigger.param01 then
            return true
        end
    end
    return false
end

--检查是否需要加载特殊处理脚本
function GuideManager:CheckGideFile(fileName)
    if fileName ~= nil and fileName ~= "" and fileName~=currentFileName then 
        currentFileName = fileName
        local temp = require(string.format("Guide.%s",fileName))
        currentGuideClass = temp:new()
    else
        currentFileName = nil
        currentGuideClass = nil
    end
    return true
end

--执行特殊处理的脚本的触发方法检查
function GuideManager:GuideTriggerFunctionCheck(trigger,...)
    if currentGuideClass==nil then 
        return true
    end

    local funName = trigger.param03
    if funName == nil or funName == "" then
        return true
    end

    local func = currentGuideClass:GetFunction(string.format("return %s",funName))
    local result = func(...)
    return result
end

-- 触发条件检测
function GuideManager:CheckCondition(config,...)
    -- 进入主界面后才开始
    local mainUI = UIManager.GetUI(UIInfo.MainUI.UIComName)
    if nil == mainUI or nil == mainUI.UI then
        return false
    end

    -- 弹窗关闭后正式进入
    if UIManager.HasPopup() then
        return false
    end

    -- 检测是否在指定UI上
    if not guideConditions.InUI(config) then
        return false
    end

    local func = guideConditions[config.condition]
    if func then
        return func(config, ...)
    end

    return true
end

local currentStepIndex = 0
local currentStepsConfig = nil

-- 空引导完成
function GuideManager:NilGuideEnd()
    EventDispatcher:Remove( currentStepsConfig[currentStepIndex].eventEnd,self.NilGuideEnd,self)
    self:DoNextStep()
end

-- 执行引导过程的下一步
function GuideManager:DoNextStep()
    currentStepIndex  = currentStepIndex + 1
    local stepConfig = currentStepsConfig[currentStepIndex]
    -- Utils.DebugLog("开始StartGuide:",GuideManager.TheConfig.guideName,currentStepIndex)

    if stepConfig ~= nil then 
        for _,tipConfig in ipairs(stepConfig.tips) do
            if tipConfig.tipType == "click" then
                GuideLayer:DoGuideStep(stepConfig,tipConfig)
            elseif tipConfig.tipType == "story" then
                local function storyCb(panel)
                    if nil == StoryPanel then
                        StoryPanel = panel
                    end
                    StoryPanel:Refresh(stepConfig, tipConfig, currentStepsConfig[currentStepIndex+1])
                end
                if nil == StoryPanel then
                    StoryPanel = (require "UI.Story.StoryPanel").new(storyCb)
                else
                    storyCb()
                end
            elseif tipConfig.tipType == "transition" then

            else
                -- 空引导
                EventDispatcher:Add(stepConfig.eventEnd,self.NilGuideEnd,self)
            end
        end
    else --当前的引导教程已经结束
        self:EndGuide()
    end
end

-- 开启一个引导教程
function GuideManager:StartGuide(config)
    --Time.timeScale = tonumber(0)
    -- self.TheConfig = config
    currentGuideId = config.guideId
    isInGuide = true
    currentStepsConfig = _G[config.catName]
    currentStepIndex = 0

    -- 检测脚本
    if nil == currentStepsConfig then
        Utils.DebugError("竟然没有引导脚本：",config.catName)
        if Application.platform == RuntimePlatform.WindowsEditor then
            return
        else
            self:GMFinishCurrGuide()
        end
    else
        AnalyticsManager.onGuide(config.guideId, config.guideName)
    end

    self.DoNextStep()
end

function GuideManager:CheckQueue()
    if #self.WaitingGuideList>0 then
        local config = table.remove(self.WaitingGuideList,1)
        if self:CheckCondition(config) then
            self:StartGuide(config)
            return true
        elseif not self:CheckQueue() then
            return false
        end
    else
        return false
    end
end

function GuideManager:GetGuideStepById(index)
    return currentStepsConfig[index]
end

-- 一个引导教程结束
function GuideManager:EndGuide()
    -- 保存当前引导进度到服务器
    local Progress = currentGuideId
    PlayerData.bigGuideID = Progress

    if not self:CheckQueue() then 
        self:Despose()
    end

    if self.backFunc ~= nil  then
        self.backFunc()
    end
end

--判断教程是否已经完成
function IsGuideDone(guide_id)
    if PlayerData==nil then 
        return true
    end

    local lastProgress = PlayerData.bigGuideID or 0
    return guide_id <= lastProgress
end

--关闭当前引导，后续仍会触发，GM命令
function GuideManager:MGCloseGuidePanel()
    GuideLayer:GMHide()
    self:Despose()
end

--完成当前引导，不在触发
function GuideManager:GMFinishCurrGuide()
    GuideLayer:GMHide()
    self:EndGuide()
end

--完成所有引导，GM命令
function GuideManager:GMFinishAllGuide()
    GuideLayer:GMHide()
    local Progress = 100 --2147483647
    PlayerData.bigGuideID = Progress
    self:Despose(true)
end

function GuideManager:Despose(kill)
    -- print("结束引导",self.TheConfig.guideName,currentStepIndex)
    currentStepIndex = 0
    currentStepsConfig = nil
    currentGuideClass = nil
    currentFileName = nil
    isInGuide = nil
    if StoryPanel then
        StoryPanel:Dispose(kill)
        if kill then
            LuaPackage.UnLoad(UIInfo.StoryPanel.UILogic)
            StoryPanel = nil
        end
    end
end

function GuideManager:RemoveRegister()
    EventDispatcher:Remove(Event.GUIDE_STEP_OVER,self.DoNextStep,self)
    -- EventDispatcher:Remove(Event.MAIN_UI_SHOW,self.EnterScene,self)
    -- EventDispatcher:Remove(Event.CG_ENTER_MAINUI,self.EnterScene,self)

    for key,func in pairs(guideTrigerEvt) do
        EventDispatcher:Remove(key,func)
    end
end

function Destroy()
    GuideManager:RemoveRegister()
end

return GuideManager