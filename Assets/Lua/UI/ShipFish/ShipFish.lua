-- region *.lua
-- Date
local ShipFish = UIManager.PanelFactory(UIInfo.ShipFishUI)

function ShipFish:ClearCd()
    if self.button2State_C.selectedIndex == 1 then
        UIManager.ShowMsg(Localize("NotEnoughDiamond"),TipMsgType.WAIT)
    else
        PlayerData.Datas.FishShipData:ImmediatelyClearCd()
    end
end

function ShipFish:Refresh()
    
    local fishShipData = PlayerData.Datas.FishShipData
    local cost = fishShipData:GetImmediatelyCost()
    UIUtils.SetControllerIndex(self.stateCtrl, fishShipData:HasReward() and 0 or 1)
    self.Text_Desc_6.text = Localize("FishShipHasReward")
    self.button2Title.text = Localize("ComeBackImmediately")
    CommonUIUtils.SetCurrencyLabel(self.Label_Money, 
    cost, CommonCostType.Diamond)
    UIUtils.SetControllerIndex(self.button2State_C, PlayerData:ResEnough(CommonCostType.Diamond,cost) and 0 or 1)
    for i, v in ipairs(self.Ships) do
        local graph =self.Ships[i]:GetChild("Graph")
        graph.visible = false
        v.visible = fishShipData.ships[i]
        v.title = Utils.GetCountFormat(fishShipData:GetRewardCount())
        UIUtils.SetControllerIndex(v:GetController("States_C"), 0)
        if fishShipData.ships[i] then
            self.Effects[i]:Stop()
            v.x = self.xTb[i]
-- 收获特效            
            graph.visible = true
            if nil == self.EffectWrap[graph] then
                local function effectCallback(wrap)
                    self.EffectWrap[graph] = wrap
                end  
                CommonUIUtils.CreateUIModelFromPool(
                    GameObjectManager.UIEffPoolName ,
                    "Prefabs/Particle/waibao/UI/Eff_UI_bulaoshouhuo.prefab",
                    graph, effectCallback, nil,ShipFish:SetEffectSize(i)
                )
            end
        end
        v.onClick:Set(
            function()
                if fishShipData.ships[i] then
                    SDKManager:PlayAD(function()
                        UIUtils.MoneyEffect(CommonCostType.Coin, v)
                        fishShipData:GetShipReward(i)
                    end, "远洋捕捞_远洋捕捞", "远洋捕捞")
                else
                    -- 留着 可以添加飘提示得方法
                     
                end
            end
        )
    end
    if fishShipData.cdShipId ~= 0 then
        local ship = self.Ships[fishShipData.cdShipId]
        
        ship.visible = true
        if not self.Effects[fishShipData.cdShipId].playing then
            self.Effects[fishShipData.cdShipId]:Play(-1,0,nil)
        end
        UIUtils.SetControllerIndex(ship:GetController("States_C"), 1)
        if self.timer then
            TimerManager.disposeTimer(self.timer)
        end
        if fishShipData.shipsCollectTime -TimerManager.getCurrentClientTime() > 0 then
            self.timer = TimerManager.newTimer(fishShipData.shipsCollectTime -TimerManager.getCurrentClientTime(), false, true, nil,function(f,t)
                ship.title = Utils.secondConversion(t)
                cost = fishShipData:GetImmediatelyCost()
                CommonUIUtils.SetCurrencyLabel(self.Label_Money, 
                cost, CommonCostType.Diamond)
                UIUtils.SetControllerIndex(self.button2State_C, PlayerData:ResEnough(CommonCostType.Diamond,cost) and 0 or 1)
            end,function()
                self:Refresh()
            end)
            self.timer:start()
        end
    end
end

-- 子类初始化UI控件
function ShipFish:OnOpen()
    self.EffectWrap = {}
    --self.UI.sortingOrder = UISortOrder.ShipFish
    self.window = self.UI:GetChild("frame")

    self.stateCtrl = self.window:GetController("States_C")
    
    self.Button_2 = self.window:GetChild("Button_2")
    self.button2State_C = self.Button_2:GetController("Status_C1")
    self.button2Title = self.Button_2:GetChild("title")
    self.Label_Money = self.Button_2:GetChild("Label_Money")
    self.Button_2:GetChild("n14").text = Localize("CostTips")
    self.closeBtn = self.window:GetChild("btnClose")

    self.Ships = 
    {
        [1] = self.window:GetChild("Ship1"),
        [2] = self.window:GetChild("Ship2"),
        [3] = self.window:GetChild("Ship3")
    }
    self.xTb = 
    {
        [1] = self.Ships[1].x,
        [2] = self.Ships[2].x,
        [3] = self.Ships[3].x
    }
    self.Effects = 
    {
        [1] = self.window:GetTransition("t1"),
        [2] = self.window:GetTransition("t2"),
        [3] = self.window:GetTransition("t3")
    }
    self.Text_Title = self.window:GetChild("Text_Title")
    self.Text_Title.text = Localize("ShipFish")
    self.Text_Desc_6 = self.window:GetChild("Text_Desc_6")
    
    self:Refresh()

    AnalyticsManager.onADButtonShow("激励视频", "远洋捕捞_远洋捕捞", "远洋捕捞")
end

function ShipFish:CloseUI()
    UIManager.ClosePopupUI(UIInfo.ShipFishUI)
end

-- 子类绑定各种事件
function ShipFish:OnRegister()
    local callback = self.callback
    self.Button_2.onClick:Add(function()
        self:ClearCd()
    end)
    self.closeBtn.onClick:Add(function()
        self:CloseUI()
    end)
    EventDispatcher:Add(Event.SHIPFISH_GETREWAD, self.Refresh, self)
    EventDispatcher:Add(Event.SHIPFISH_CD_CLEAR, self.Refresh, self)
end

function ShipFish:OnShow()
    
end
-- 设置不同大小船的特效大小
function ShipFish:SetEffectSize(shipid)
    if shipid == 1 then
        return Vector3(0.5,0.4,1)
    end
    if shipid == 3 then
        return Vector3(0.65,0.65,1)
    end
    if shipid == 2 then
        return Vector3(0.8,0.8,1)
    end
end

function ShipFish:OnHide()
    --UIManager.tipsTool():CloseItemPopupUIAnim(self.UI, true, UIInfo.ShipFish)
end

-- 强制刷新,比如网络事件监听，切换语言包，断线重连等
function ShipFish:OnRefresh(...)
end

-- 解绑各类事件
function ShipFish:OnUnRegister()
    self.Button_2.onClick:Clear()
    self.closeBtn.onClick:Clear()
    if self.timer then
        self.timer = TimerManager.disposeTimer(self.timer)
    end
    EventDispatcher:Remove(Event.SHIPFISH_GETREWAD, self.Refresh, self)
    EventDispatcher:Remove(Event.SHIPFISH_CD_CLEAR, self.Refresh, self)
end

-- 关闭
function ShipFish:OnClose()
    for k, v in pairs(self.EffectWrap) do
        CommonUIUtils.ReturnUIModelToPool(v,GameObjectManager.UIEffPoolName)
    end
    self.EffectWrap = nil
end

return ShipFish

--endregion
