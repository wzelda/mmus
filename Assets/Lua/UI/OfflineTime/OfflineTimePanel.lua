local OfflineTimePanel = UIManager.PanelFactory(UIInfo.OfflineTimeUI)

local panel = OfflineTimePanel
local reward
local multi
local rewardType
local adMulti
local fishjumpcount = 0

function OfflineTimePanel:OnOpen(arg)
    panel = self
    self.EffectWrap = {}
    self.timeinterval=nil
    self:sortingOrder(UISortOrder.PopupUI)
    self.window = self.UI:GetChild("Window")
    self.closeBtn = self.window:GetChild("closeBtn")
    self.rateLabel = self.window:GetChild("rateLabel")
    self.getMultiBtn = self.window:GetChild("getBtn")
    self.multiTxt = self.getMultiBtn:GetChild("Text_Mult")
    self.title = self.window:GetChild("title")
    --self.offlineTimeTxt = self.window:GetChild("offlineTimeTxt")
    --self.offlineRewardTxt = self.window:GetChild("title")
end

local function CalcReward()
    local addReward = reward * multi
    if rewardType == CommonCostType.Coin then
        PlayerData:RewardCoin(addReward, false)
    elseif rewardType == CommonCostType.Diamond then
        PlayerData:RewardDiamond(addReward, false)
    end
    PlayerData.gotOfflineReward = nil
end

function OfflineTimePanel.DoClose()
    CalcReward()
    UIUtils.MoneyEffect(rewardType, panel.getMultiBtn)
    UIManager.ClosePopupUI(UIInfo.OfflineTimeUI)
end

function OfflineTimePanel:OnShow(arg)
    reward = arg.Reward
    rewardType = arg.RewardType
    adMulti = ConfigData:GetOfflineReward().Adadd or 1
    multi = 1
    self.title.text = Localize("OfflineReward")
    --self.offlineRewardTxt.text = Localize("OfflineReward")
    --self.offlineTimeTxt.text = Utils.secondConversion(arg.OfflineDur)
    self.rateLabel.text = Utils.ResourceHandler(arg.Reward)
    self.multiTxt.text = LocalizeExt("ADReward", {adMulti})
    local slot = self.window:GetChild("slot")

    if self.timer then
        self.timer:onComplete()
        self.timer = nil
    end
    local function effectCallback(wrap)
        wrap.wrapTarget.transform.localPosition = Vector3(-1.573,-2.793,3)
        self.EffectWrap[slot] = wrap
        self.timer = TimerManager.intervalTodo(-1,4,
            function() 
            wrap.wrapTarget:SetActive(false)              
            wrap.wrapTarget.transform.localRotation = Quaternion.Euler(Vector3(0,OfflineTimePanel:FishJumpCount(),0))
            wrap.wrapTarget:SetActive(true)      
            end,
            nil, nil, true
        )
    end
    CommonUIUtils.CreateUIModelFromPool(
        GameObjectManager.UIEffPoolName ,
        "Prefabs/Particle/waibao/UI/Eff_UI_yulaihuitiaoyue.prefab",
        slot, effectCallback,nil,Vector3(1.2,1.2,1)
    )
    AnalyticsManager.onADButtonShow("激励视频", "离线奖励", "离线奖励")
end

function OfflineTimePanel.GetMulti()
    SDKManager:PlayAD(function ()
        multi = adMulti
        panel.DoClose()
    end, "离线奖励", "离线奖励")
end

-- 绑定事件
function OfflineTimePanel:OnRegister()
    self.closeBtn.onClick:Add(self.DoClose)
    self.getMultiBtn.onClick:Add(self.GetMulti)

    -- EventDispatcher:Add(Event.TOGGLE_MAINUI_SHOW, self.Toggle, self)
end

-- 解绑事件
function OfflineTimePanel:OnUnRegister()
    self.closeBtn.onClick:Clear()
    self.getMultiBtn.onClick:Clear()
    -- EventDispatcher:Remove(Event.TOGGLE_MAINUI_SHOW, self.Toggle, self)
end

function OfflineTimePanel:FishJumpCount()
        if fishjumpcount % 2 == 0 then
            fishjumpcount = fishjumpcount + 1
            return 180
        else 
            fishjumpcount = fishjumpcount + 1
            return 0
        end
end

function OfflineTimePanel:OnClose()
    EventDispatcher:Dispatch(Event.CG_ENTER_MAINUI)
    for k, v in pairs(self.EffectWrap) do
        CommonUIUtils.ReturnUIModelToPool(v,GameObjectManager.UIEffPoolName)
    end
    self.EffectWrap = nil
    if self.timer ~=nil then
        self.timer:onComplete()
        self.timer = nil
    end
end

return OfflineTimePanel