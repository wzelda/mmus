--[[ 
 * Descripttion: 
 * version: 
 * Author: Bryant
 * Date: 2020-10-26 12:26:30
 * LastEditors: Bryant
 * LastEditTime: 2020-10-26 12:27:20
]]

local StoryPanel = class()
local panel = StoryPanel

local currentStep = nil
local wait

function StoryPanel:ctor(cb)
    panel = self

    UIManager.CreateFairyCom(
        UIInfo.StoryPanel.UIPackagePath,
        UIInfo.StoryPanel.UIName,
        UIInfo.StoryPanel.UIComName,
        true,
        function (ui, pkgId)
            self.PackageId = pkgId
            self.UI = ui
            self.mask = self.UI:GetChild("mask")
            self.bg = self.UI:GetChild("bg")
            self.com = self.UI:GetChild("com")
            self.continue = self.com:GetChild("continue")
            self.narrate0 = self.com:GetChild("Narrate")
            self.narrate1 = self.UI:GetChild("Narrate")
            self.name = self.com:GetChild("Name")
            self.state_C = self.UI:GetController("state_C")
            self.roles = {
                [1] = self.com:GetController("Girl"),
            }

            self.UI.sortingOrder = UISortOrder.NewGuide
            self.UI.visible = false
            -- 打字效果
            self.typing0 = TypingEffect(self.narrate0)
            self.typing1 = TypingEffect(self.narrate1)

            if cb then
                cb(self)
            end
        end
    )
end

function StoryPanel:Show()
    self.UI.visible = true
    self.mask.visible = true
    self.com.visible = false
    self.bg.visible = false
    TimerManager.waitTodo(self.currentStep.delayTime,1,function()
        if self.currentStep.pause then
            GuideManager:SetPause(true)
        end
        self.mask.visible = false
        self.com.visible = true
        self.bg.visible = true
        self.typing:Start()
        self.typing:PrintAll(0.02)
    end,nil,nil,true)
    -- 禁止点击2秒
    wait = true
    TimerManager.waitTodo(1,1,function()
        wait = false
    end,nil,nil,true)
    EventDispatcher:Remove(self.currentStep.eventBegin,self.Show,self)
end

local function ContinueClick()
    if wait then return end
    
    panel.typing:Cancel()
    panel.UI.visible = false
    panel.continue.onClick:Clear()
    GuideManager:SetPause(false)
    GuideManager:DoNextStep()
end

function StoryPanel:Refresh(stepConfig,tip,nextStepConfig)
    self.currentStep = stepConfig
    -- param04:对话类型 1 黑屏
    if type(tip.param04) == 'number' then
        UIUtils.SetControllerIndex(self.state_C, tip.param04)
        self.narrate = self.narrate1
        self.typing = self.typing1
    else
        UIUtils.SetControllerIndex(self.state_C, 0)
        self.narrate = self.narrate0
        self.typing = self.typing0
    end
    -- param05:对话配置id
    local config = ConfigData:GetStoryConfigById(tip.param05) 

    for key,ctr in ipairs(self.roles) do
        if key == config.role_id then
            ctr.selectedIndex = config.face
        else
            ctr.selectedIndex = 0
        end
    end
    
    -- self.name.text = "[color=#fffed3,#dbb876]" .. LocazationMgr.getServerLocStr(config.role) 
    self.narrate.text = Localize(config.Dialog) 

    self.bg.onClick:Add(ContinueClick)
    self.com.onClick:Add(ContinueClick)

    self.UI.visible = false
    
    if stepConfig.eventBegin == "" or stepConfig.eventBegin==nil then 
        self:Show()
    else
        EventDispatcher:Add(stepConfig.eventBegin,self.Show,self)
    end
end

function StoryPanel:Dispose(kill)
    panel.typing:Cancel()
    if kill then
        UIManager.DisposeFairyCom(self.PackageId, self.UI, true)
        Utils.ClearTableRef(self)
    else
        panel.UI.visible = false
        panel.continue.onClick:Clear()
    end
end

return StoryPanel