local ImproveBreakUI = UIManager.PanelFactory(UIInfo.ImproveBreakUI)

local panel = ImproveBreakUI
local trainCfg
local techCfg
local AquariumConfig = Utils.LoadConfig("Config.AquariumConfig")
local lockui

function ImproveBreakUI:OnOpen(arg)
    panel = self

    self.window = self.UI:GetChild("window")
    self.icon = self.window:GetChild("icon")
    self.name = self.window:GetChild("Text_Item")
    self.income = self.window:GetChild("title")
    self.effect = self.window:GetTransition('Effect')
    self.Effect_T = self.window:GetTransition('Effect_T')
    self.window:GetChild("textbtn").text = Localize('ClickToClose')
    self.EffectGraph = self.window:GetChild("EffectGraph")
end

function ImproveBreakUI.DoClose()
    if lockui then return end

    panel.effect:Play(function ()
        UIManager.CloseUI(UIInfo.ImproveBreakUI)
    end)
end

-- 计算增加收益
local function calcAddIncome()
    local buffcfg = ConfigData:GetBufferById(trainCfg.Buffer)
    if nil == buffcfg then return 0 end

    local allfactor = 0
    for _, v in ipairs(techCfg.Trains) do
        local trcfg = ConfigData:GetAdminTrain(v)
        local cfg = ConfigData:GetBufferById(trcfg and trcfg.Buffer)
        if cfg then
            allfactor = allfactor + cfg.Factor
        end
    end
    local itemcfg
    local addincome = 0
    if buffcfg.ItemType == 0 then
        itemcfg = PlayerDatas.FishData:GetFish(buffcfg.ItemID)
        if itemcfg then
            addincome = PlayerDatas.FishData:GetIncomeBase(itemcfg) * allfactor
        end
    elseif buffcfg.ItemType == 1 then
        itemcfg = AquariumConfig.ShowItemsByID[buffcfg.ItemID]
        if itemcfg then
            addincome = PlayerDatas.AquariumData:GetIncomeBase(itemcfg) * allfactor
        end
    end

    return addincome
end

function ImproveBreakUI:OnShow(info)
    trainCfg = info.trainCfg
    techCfg = info.techCfg
    
    UIUtils.LoadIcon(self.icon, techCfg.Icon, false, UIInfo.ImproveUI.UIName)
    self.name.text = trainCfg.Name
    self.income.text = string.format(Localize('IncomeAdd'), Utils.ResourceHandler(calcAddIncome()))

    local function effectCallback(wrap)
        self.EffectWrap = wrap
    end  
    CommonUIUtils.CreateUIModelFromPool(
        GameObjectManager.UIEffPoolName ,
        "Prefabs/Particle/waibao/UI/EFF_UI_faxianguangxiao.prefab",
        self.EffectGraph, effectCallback
    )

    lockui = true
    self.Effect_T:Play(function () lockui = false end)
end

-- 绑定事件
function ImproveBreakUI:OnRegister()
    self.UI.onClick:Set(self.DoClose)
end

-- 解绑事件
function ImproveBreakUI:OnUnRegister()
    self.UI.onClick:Clear()
end

function ImproveBreakUI:OnClose()
    if self.EffectWrap then
        CommonUIUtils.ReturnUIModelToPool(self.EffectWrap,GameObjectManager.UIEffPoolName)
        self.EffectWrap = nil
    end

    local trainId = trainCfg and trainCfg.ID
    EventDispatcher:Dispatch(Event.ADMIN_CLOSE_BREAKUI, self.icon, Vector3.zero, trainId)
end

return ImproveBreakUI