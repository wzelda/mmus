
-- 沉船探宝UI
local ShipTreasureUI = UIManager.PanelFactory(UIInfo.ShipTreasureUI)

local panel = ShipTreasureUI
local treasureCfg
local rewardById

function ShipTreasureUI:OnOpen(arg)
    panel = self
    local advData = PlayerDatas.AdvData
    treasureCfg = ConfigData:GetShipTreasure()
    rewardById = {}

    self.window = self.UI:GetChild("window")
    self.baseWindow = self.window:GetChild("baseWindow")
    self.closeBtn = self.baseWindow:GetChild("closeBtn")
    self.tipTxt = self.window:GetChild("tipCom"):GetChild("tipTxt")

    self.btns = {}
    for id, v in pairs(treasureCfg) do
        local reward = v.RewardDur * 60 * PlayerData:GetRealCoinIncome()
        rewardById[id] = reward
        local key = "prizeBtn" .. id
        local btn = self.window:GetChild(key)
        if btn then
            btn:GetChild("titleCom"):GetChild("title").text = v.Name
            local costBtn = btn:GetChild("costBtn")
            costBtn:GetChild("freeTips").text = Localize("Free")
            local costLabel = costBtn:GetChild("costLabel")
            local freeCtrl = costBtn:GetController("state_c")
            local cost = self:GetCost(v)
            costLabel.text = self:GetCost(v)
            UIUtils.SetControllerIndex(freeCtrl, cost == 0 and 1 or 0)
            btn:GetChild("prizeLabel").text = Utils.ResourceHandler(reward)
            costBtn.onClick:Set(function ()
                local cost = self:GetCost(v)
                if cost == 0 and advData.shipAdCd > 0 then
                    UIManager.ShowMsg(Localize('ShipFreeCd'))
                    return
                end

                if PlayerData:ResEnough(v.CostType, cost) then
                    self:DoExchange(id)
                    -- 刷新下次消耗
                    cost = self:GetCost(v)
                    costLabel.text = self:GetCost(v)
                    UIUtils.SetControllerIndex(freeCtrl, cost == 0 and 1 or 0)
                else
                    UIManager.ShowMsg(Localize("NotEnoughDiamond"))
                end
            end)
            self.btns[id] = btn
        end
    end
end

function ShipTreasureUI.DoClose()
    UIManager.ClosePopupUI(UIInfo.ShipTreasureUI)
end

function ShipTreasureUI:OnShow(...)
    self.tipTxt.text = Localize("ShipTreasureTip")
    self.baseWindow.text = Localize("ShipTreasure")
    self:Refresh()

    AnalyticsManager.onADButtonShow("激励视频", "沉船探宝_沉船探宝", "沉船探宝")
end

-- 绑定事件
function ShipTreasureUI:OnRegister()
    self.closeBtn.onClick:Set(self.DoClose)

    -- EventDispatcher:Add(Event.CURRENCY_SPEND, self.Refresh, self)
end

-- 解绑事件
function ShipTreasureUI:OnUnRegister()
    self.closeBtn.onClick:Clear()
    -- EventDispatcher:Remove(Event.CURRENCY_SPEND, self.Refresh, self)
end

function ShipTreasureUI:OnClose()
    rewardById = nil
    if self.shipAdTimer then
        TimerManager.disposeTimer(self.shipAdTimer)
        self.shipAdTimer = nil
    end
end

function ShipTreasureUI:GetCost(cfg)
    local cost
    if cfg.FreeTimes > PlayerDatas.AdvData.dailyShipExchangeCount then
        cost = 0
    else
        cost = cfg.Cost
    end
    return cost
end

function ShipTreasureUI:DoExchange(id)
    local cfg = treasureCfg[id]
    local cost = self:GetCost(cfg)
    local function exchange()
        PlayerData:Exchange(cfg.CostType, cost, CommonCostType.Coin, rewardById[id])
        PlayerDatas.AdvData:AddShipExchangeCount()
        self:Refresh()
        UIUtils.MoneyEffect(CommonCostType.Coin, self.btns[id])
        -- 统计上报沉船探宝操作
        AnalyticsManager.onJoinSystem(GameSystemType.FID_SHIPTREASURE, id, cfg.Name, cost)
    end
    if cost == 0 then
        SDKManager:PlayAD(exchange, "沉船探宝_沉船探宝", "沉船探宝")
    else
        exchange()
    end
end

function ShipTreasureUI:Refresh()
    local advData = PlayerDatas.AdvData
    for id, btn in pairs(self.btns) do
        local cfg = treasureCfg[id]
        -- btn.enabled = PlayerData:ResEnough(cfg.CostType, cfg.Cost)
        if cfg.FreeTimes > 0 then
            local costBtn = btn:GetChild("costBtn")
            local cd_c = costBtn:GetController('type_C')
            if advData.shipAdCd > 0 then
                UIUtils.SetControllerIndex(cd_c, 1)
                local cdtxt = costBtn:GetChild("cdText")
                if nil == self.shipAdTimer then
                    self.shipAdTimer = TimerManager.newTimer(0, false, true, nil,
                        function (t, f)
                            cdtxt.text = Utils.secondConversion(f, true)
                        end, 
                        function ()
                            UIUtils.SetControllerIndex(cd_c, 0)
                        end
                    )
                end
                self.shipAdTimer:start(advData.shipAdCd)
            else
                UIUtils.SetControllerIndex(cd_c, 0)
            end
        end
    end
end

return ShipTreasureUI