-- 游戏顶部UI
local MainTopUI = class()
local panel = MainTopUI

local rightBtnKey = {
    LunchTime = 1,
    ShipTreasure = 2,
    DoubleMoney = 3,
    ShipFish = 4,
}
function MainTopUI:HandleUIOpen(uiname)
    -- 打开特殊UI的处理
    if uiname == UIInfo.EarthUI.UIComName then
        self.stateController.selectedIndex = 2
        self.rightList.visible = false
    end
end

function MainTopUI:HandleUIClose(uiname)
    -- 关闭特殊UI的处理
    if uiname == UIInfo.EarthUI.UIComName then
        self:OnOpenFunction(self.curFunction, PlayerDatas.FunctionOpenData:IsFunctionOpened(self.curFunction))
    end
end

function MainTopUI:OnOpenFunction(functionID, opened)
    self.curFunction = functionID

    if opened then
        self.rightList.visible = true
        if functionID == GameSystemType.FID_AQUARIUM then
            self.stateController.selectedIndex = 1
        elseif functionID == GameSystemType.FID_IMPROVE
        or functionID == GameSystemType.FID_LIBRARY
        then
            -- 进修
            self.rightList.visible = false
            self.stateController.selectedIndex = 3
        elseif functionID == GameSystemType.FID_FISHING then
            self.stateController.selectedIndex = 0
        else
            self.stateController.selectedIndex = 0
        end
    else
        self.rightList.visible = false
        self.stateController.selectedIndex = 3
    end
end

function MainTopUI:RefreshCurrency(coin, diamond)
    if coin then
        self.coinLabel.text = Utils.GetCountFormat(coin)
    end
    if diamond then
        self.diamondLabel.text = Utils.GetCountFormat(diamond)
    end
end

function MainTopUI:OnCoinIncome(coin)
    self:RefreshCurrency(PlayerData.coinNum)
    self:RefreshIncomeSpeed()
end

function MainTopUI:OnCurrencyChange(coin)
    self:RefreshCurrency(PlayerData.coinNum, PlayerData.diamondNum)
end

function MainTopUI:RefreshIncomeSpeed()
    self.Text_Desc.text = Utils.GetCountFormat(PlayerData:GetRealCoinIncome()) .. Localize("UnitSeconds")
end

-- 右侧列表按钮
function MainTopUI:GetRightBtn(key)
    local btn = self.rightBtns[key]
    return btn
end

function MainTopUI:ShowRightBtn(key, flag)
    if flag then
        self:GetRightBtn(key).visible = true
    elseif self.rightBtns[key] then
        self.rightBtns[key].visible = false
    end
end

-- 刷新右侧列表
function MainTopUI:RefreshRightList()
    self:RefreshLunch()
    self:RefreshShipTreasure()
    self:RefreshDoubleMoney()
    self:RefreshShipFish()
end

-- 饭点广告
function MainTopUI:OnLunchAd(flag)
    if not PlayerDatas.FunctionOpenData:CheckUnlock(GameSystemType.FID_LUNCH) then
        self:ShowRightBtn(rightBtnKey.LunchTime, false)
        return
    end

    self:ShowRightBtn(rightBtnKey.LunchTime, flag)
    if flag then
        local btn = self:GetRightBtn(rightBtnKey.LunchTime)
        -- 不用倒计时了，备注备用
        -- PlayerDatas.AdvData:SetLunchEndUpdate(function (t, f)
        --     btn.text = Utils.secondConversion(f)
        -- end)
        local function openLunchUI()
            UIManager.OpenPopupUI(UIInfo.ItemPopupUI, "LunchTime")
        end
        btn.onClick:Set(openLunchUI)
        local slot = btn:GetChild("slot")
        slot.visible = false
        if PlayerDatas.AdvData:HavingLunch() then
            slot.visible = true
            if nil == self.EffectWrap[slot] then
                local function effectCallback(wrap)
                    self.EffectWrap[slot] = wrap
                end  
                CommonUIUtils.CreateUIModelFromPool(
                    GameObjectManager.UIEffPoolName ,
                    "Prefabs/Particle/waibao/UI/Eff_UI_6biankuosankuang.prefab",
                    slot, effectCallback
                )
            end
        end
    end
end

function MainTopUI:OnGetLunchReward()
    self:ShowRightBtn(rightBtnKey.LunchTime, false)
end

function MainTopUI:ctor(parent)
    UIManager.CreateFairyCom(UIInfo.MainTopUI.UIPackagePath, UIInfo.MainTopUI.UIName, UIInfo.MainTopUI.UIComName, false, function(ui, pkgId)
        self.UI = ui
        ui.sortingOrder = 2
        self.PackageId = pkgId
        parent:AddChild(ui)

        UIUtils.SetUIFitScreen(ui, true)
        
        ui:AddRelation(parent, RelationType.Size)
        self:OnOpen()
    end)
end

function MainTopUI:RefreshLunch()
    if PlayerDatas.AdvData:HavingLunch() then
        self:OnLunchAd(true)
    else
        self:OnLunchAd(false)
    end
end

-- 沉船探宝
function MainTopUI:RefreshShipTreasure()
    local btn = self:GetRightBtn(rightBtnKey.ShipTreasure)
    if not PlayerDatas.FunctionOpenData:CheckUnlock(GameSystemType.FID_SHIPTREASURE) then
        btn.visible = false
        return
    end

    btn.visible = true
    btn.onClick:Set(function ()
        UIManager.OpenPopupUI(UIInfo.ShipTreasureUI)
    end)
end

-- 收益翻倍
function MainTopUI:RefreshDoubleMoney()
    local btn = self:GetRightBtn(rightBtnKey.DoubleMoney)
    if not PlayerDatas.FunctionOpenData:CheckUnlock(GameSystemType.FID_DOUBLEMONEY) then
        btn.visible = false
        return
    end

    btn.visible = true
    btn.onClick:Set(function ()
        UIManager.OpenPopupUI(UIInfo.ItemPopupUI, "DoubleMoney")
    end)

    local function showEffect(flag)
        local slot = btn:GetChild("slot")
        if flag then
        slot.visible = true
            if nil == self.EffectWrap[slot] then
                local function effectCallback(wrap)
                    self.EffectWrap[slot] = wrap
                end
                CommonUIUtils.CreateUIModelFromPool(
                    GameObjectManager.UIEffPoolName ,
                    "Prefabs/Particle/waibao/UI/Eff_UI_tishi.prefab",
                    slot, effectCallback, nil, 0.7
                )
            end
        else
            slot.visible = false
        end
    end

    local cd = PlayerData.doubleEndtime - TimerManager.getCurrentClientTime()
    if cd > 0 then
        showEffect(false)
        if nil == self.doubleMoneyTimer then
            self.doubleMoneyTimer = TimerManager.newTimer(cd, false, true, nil, function (t, f)
                btn.text = Utils.secondConversion(f)
            end,
            function ()
                btn.text = ""
                showEffect(true)
            end)
        end
        self.doubleMoneyTimer:start(cd)
    else
        if self.doubleMoneyTimer then
            self.doubleMoneyTimer:pause()
        end
        btn.text = ""
        showEffect(true)
    end
end

local function FishShipHasReward()
    return PlayerData.Datas.FishShipData:HasReward()
end

function MainTopUI:RefreshShipFish()
    local btn = self:GetRightBtn(rightBtnKey.ShipFish)
    if not PlayerDatas.FunctionOpenData:CheckUnlock(GameSystemType.FID_SHIPFISH) then
        btn.visible = false
        return
    end
    btn.visible = true
    self.ShipFishRed = ReddotManger:CreateRedDot(RedDotType.FishShip,AnchorType.TopRight,btn)
    self.ShipFishRed:SetConditions(FishShipHasReward)
    self.ShipFishRed:SetEventListener(Event.SHIPFISH_CD_CLEAR,Event.SHIPFISH_GETREWAD)
    btn.onClick:Set(function ()
        UIManager.OpenPopupUI(UIInfo.ShipFishUI)
    end)
end

function MainTopUI:ShowGold()
    -- UIManager.ShowEffect(ClickEffectType.CollectGold,self.GoldIcon:LocalToRoot(Vector2.zero),
    -- UISortOrder.ClickEffect, Vector3(0,-6.28,0))
    UIUtils.MoneyEffect(CommonRewardType.Coin)
end

function MainTopUI:ShowDiamondEffect()
    -- UIManager.ShowEffect(ClickEffectType.DiamondEffect,self.diamondIcon:LocalToRoot(self.diamondIcon.size / 2),
    --  UISortOrder.ClickEffect, Vector3(0,-6.28,0))
    UIUtils.MoneyEffect(CommonRewardType.Diamond)
end

function MainTopUI:PlayDefaultMoneyEffect(rewardType)
    if rewardType == CommonRewardType.Coin then
        self:ShowGold()
    elseif rewardType == CommonRewardType.Diamond then
        self:ShowDiamondEffect()
    end
end

function MainTopUI:PlayRewardEffect(rewardType)
    if rewardType == CommonRewardType.Coin then
        -- self:ShowGold()
        self.Effect_Gold1:Play(function()
            UIManager.ShowEffect(ClickEffectType.GoldShanKuangEffect,self.GoldIcon:LocalToRoot(self.GoldIcon.size / 2), UISortOrder.ClickEffect,Vector3(-0.24,0.18,0))
            self.Effect_Gold2:Play(
            function()
                UIManager.HideEffect(ClickEffectType.GoldShanKuangEffect)
            end
        )
        end)
        
    elseif rewardType == CommonRewardType.Diamond then
        -- self:ShowDiamondEffect()
        self.Effect_Dm1:Play(function()
            UIManager.ShowEffect(ClickEffectType.DmShanKuangEffect,self.diamondIcon:LocalToRoot(self.diamondIcon.size / 2), UISortOrder.ClickEffect)
            self.Effect_Dm2:Play(function()
                UIManager.HideEffect(ClickEffectType.DmShanKuangEffect)
            end)
        end)
    end
end

-- 成就头衔
function MainTopUI:UpdateAchieveTile()
    local cfg = PlayerDatas.AchievementData:CurTitle()
    if cfg then
        self.achieveBtn.text = string.format("[color=#fffef1,#E7FF77]%s", cfg.Name)
        UIUtils.LoadIcon(self.achieveBtn, cfg.Icon, true)
    end
end

function MainTopUI:OnBottomTabChange(tabIndex)
    self:UpdateTopState()
end

function MainTopUI:OnSceneLoaded()
    self:UpdateTopState()
end

function MainTopUI:UpdateTopState()
    self:UpdateSmallMap()
end

function MainTopUI:UpdateSmallMap()
    local slot = self.smallMap:GetChild("EffectGraph")
    local nextSea = PlayerDatas.SeaData:GetNextSea()
    local cfg = ConfigData.seaConfig.SeasByID[nextSea]
    if cfg and DependManager.PassedDepend(cfg.Depends) then
        slot.visible = true
        if nil == self.EffectWrap[slot] then
            local function effectCallback(wrap)
                self.EffectWrap[slot] = wrap
            end
            CommonUIUtils.CreateUIModelFromPool(
                GameObjectManager.UIEffPoolName ,
                "Prefabs/Particle/waibao/UI/Eff_UI_jiesuokuosan.prefab",
                slot, effectCallback, nil, 1.3
            )
        end
    else
        slot.visible = false
    end
end

local function CanUnlockNextFishSence()
    return PlayerData.Datas.FishData:CanUnlockNextFishSence()
end

local function CanBuildNewAquarium()
    return PlayerDatas.AquariumData:CanBuildNewAquarium()
end

function MainTopUI:StartMoveAd()
    AnalyticsManager.onADButtonShow("激励视频", "漂流宝箱_主界面", "漂流宝箱")
    PlayerData.Datas.FishData:ShowAdBox()
    self.Button_MoveAd.visible = true
    self.Effect_MoveAd:Play(
        function()
            self.Button_MoveAd.visible = false
        end
    )
end

function MainTopUI:StopMoveAd()
    self.Button_MoveAd.visible = false
    self.Effect_MoveAd:Stop()
end

function MainTopUI:ShowAd()
    -- 引导时不弹宝箱以免卡住
    if GuideManager:InGuide() then
        return
    end

    self:StopMoveAd()
    UIManager.OpenUI(UIInfo.ItemPopupUI, nil, nil, "AdBox", PlayerData.Datas.FishData:AdBoxRewardCount(), function(ad)
        if ad then
            SDKManager:PlayAD(function()
                PlayerData.Datas.FishData:GetAdBoxReward()
                EventDispatcher:Dispatch(Event.ITEMPOP_GETREWARD, CommonCostType.Coin)
            end, "漂流宝箱_主界面", "漂流宝箱")
        end
    end)
end

-- 弱的点击提示
function MainTopUI:ShowWeakTips(btn, flag)
    local slot = btn:GetChild("slot")
    if flag then
        if nil == self.EffectWrap[slot] then
            local function effectCallback(wrap)
                self.EffectWrap[slot] = wrap
            end
            CommonUIUtils.CreateUIModelFromPool(
                GameObjectManager.UIEffPoolName ,
                "Prefabs/Particle/waibao/UI/Eff_UI_tishi.prefab",
                slot, effectCallback, nil, 0.7
            )
        end
    elseif self.EffectWrap[slot] then
        CommonUIUtils.ReturnUIModelToPool(self.EffectWrap[slot],GameObjectManager.UIEffPoolName)
    end
end

-- 收益增加效果
function MainTopUI:AddIncomeTips(num)
    if nil == num then return end

    self.coinLabel:GetChild('Text_Income').text = '+' .. Utils.ResourceHandler(num)
    self.coinLabel:GetTransition('Effect_Improve'):Play()
end

function MainTopUI:OnOpen()
    panel = self
    -- FIX:进游戏切换海域后返回按钮消失
    self.curFunction = GameSystemType.FID_FISHING
    
    self.EffectWrap = {}
    self.stateController = self.UI:GetController("State_C")
    self.zoomBtn = self.UI:GetChild("Button_Zoom")
    self.aquariumBtn = self.UI:GetChild("aquariumBtn")
    self.aquariumReddot = ReddotManger:CreateRedDot(RedDotType.Normal,AnchorType.TopRight,self.aquariumBtn)
    self.aquariumReddot:SetConditions(CanBuildNewAquarium)
    self.aquariumReddot:SetEventListener(Event.AQUARIUM_SHOW_ITEM,Event.AQUARIUM_LEVELUP_DECORATION,Event.LOADING_COMPLETE)

    self.coinLabel = self.UI:GetChild("Label_Title")
    self.diamondLabel = self.UI:GetChild("Label_Money")
    self.Effect_MoveAd = self.UI:GetTransition("Effect_MoveAd")
    self.Button_MoveAd = self.UI:GetChild("Button_MoveAd")

    self.coinLabel:GetChild("n22").text = Localize("Revenue")
    self.diamondIcon = self.diamondLabel:GetChild("icon")
    self.Text_Desc = self.coinLabel:GetChild("Text_Desc")
    self.GoldIcon = self.coinLabel:GetChild("icon")
    
    self.headBtn = self.UI:GetChild("Button_Head")
    self.mapBtn = self.UI:GetChild("mapBtn")
    self.mapBtn.text = Localize("ChangeSea")
    self.smallMap = self.UI:GetChild("Label_Map")
    self.smallMapReddot = ReddotManger:CreateRedDot(RedDotType.NewFishMap,AnchorType.TopRight,self.mapBtn)
    self.smallMapReddot:SetConditions(CanUnlockNextFishSence)
    self.smallMapReddot:SetEventListener(Event.FISH_LEVELUP,Event.AQUARIUM_LEVELUP_DECORATION,Event.LOADING_COMPLETE)
    self.rightList = self.UI:GetChild("List")
    self.rightBtns = {
        [rightBtnKey.DoubleMoney] =  self.rightList:GetChildAt(0),
        [rightBtnKey.LunchTime] =  self.rightList:GetChildAt(1),
        [rightBtnKey.ShipTreasure] =  self.rightList:GetChildAt(2),
        [rightBtnKey.ShipFish] =  self.rightList:GetChildAt(3),
    }
    self.rightList.foldInvisibleItems = true
    self.returnBtn = self.UI:GetChild("returnBtn")
    self.returnBtn.text = Localize("ReturnSea")
    self.achieveBtn = self.UI:GetChild("achieveBtn")
    self.Effect_Gold1 = self.UI:GetChild("Label_Title"):GetTransition("Effect_Gold1")
    self.Effect_Gold2 = self.UI:GetChild("Label_Title"):GetTransition("Effect_Gold2")
    self.Effect_Dm1 = self.UI:GetChild("Label_Money"):GetTransition("Effect_Dm1")
    self.Effect_Dm2 = self.UI:GetChild("Label_Money"):GetTransition("Effect_Dm2")
    self.zoomBtn.onClick:Add(function() self:ShowZoomView() end)
    self.aquariumBtn.onClick:Add(function() self:ShowAquariumSelect() end)
    self.coinLabel.onClick:Add(function() self:OnCoinLabelClick() end)
    self.headBtn.onClick:Add(function() self:OnHeadClick() end)
    self.mapBtn.onClick:Add(function() self:OnMapClick() end)
    self.returnBtn.onClick:Set(function() self:OnReturnClick() end)
    self.smallMap.onClick:Set(function() self:OnSmallMapClick() end)
    self.achieveBtn.onClick:Set(function() self:ShowAchievement() end)
    self.Button_MoveAd.onClick:Set(function() self:ShowAd() end)

    self:ShowWeakTips(self.aquariumBtn, PlayerPrefs.GetInt("ClickAquariumSelect") ~= 1)
    self:ShowWeakTips(self.zoomBtn, PlayerPrefs.GetInt("ClickAquariumPhoto") ~= 1)

    EventDispatcher:Add(Event.OPEN_FUNC, self.OnOpenFunction, self)
    EventDispatcher:Add(Event.COIN_INCOME, self.OnCoinIncome, self)
    EventDispatcher:Add(Event.CURRENCY_CHANGED, self.OnCurrencyChange, self)
    EventDispatcher:Add(Event.FISH_LEVELUP, self.RefreshIncomeSpeed, self)
    EventDispatcher:Add(Event.FISH_GROWUP, self.RefreshIncomeSpeed, self)
    EventDispatcher:Add(Event.ADD_BUFFER, self.RefreshIncomeSpeed, self)
    EventDispatcher:Add(Event.OPENED_TAB, self.HandleUIOpen, self)
    EventDispatcher:Add(Event.CLOSED_TAB, self.HandleUIClose, self)
    EventDispatcher:Add(Event.AD_LUNCH_SHOW, self.OnLunchAd, self)
    EventDispatcher:Add(Event.GET_MAIN_TASK_PRIZE, self.RefreshRightList, self)
    EventDispatcher:Add(Event.AD_GET_LUNCH_REWARD, self.OnGetLunchReward, self)
    EventDispatcher:Add(Event.FISH_FISH_END, self.ShowGold, self)
    EventDispatcher:Add(Event.AD_GET_DOUBLE_MONEY, self.RefreshDoubleMoney, self)
    EventDispatcher:Add(Event.PLAY_REWARD_EFFECT, self.PlayRewardEffect, self)
    EventDispatcher:Add(Event.UPGRADE_ACHIEVE_TITLE, self.UpdateAchieveTile, self)
    EventDispatcher:Add(Event.MAIN_TAB_OPEN, self.OnBottomTabChange, self)
    EventDispatcher:Add(Event.LOADING_COMPLETE, self.OnSceneLoaded, self)
    EventDispatcher:Add(Event.FISH_LEVELUP, self.UpdateTopState, self)
    EventDispatcher:Add(Event.AQUARIUM_LEVELUP_DECORATION, self.UpdateTopState, self)
    EventDispatcher:Add(Event.CURRENCY_CHANGED, self.UpdateTopState, self)
    EventDispatcher:Add(Event.UNLOCK_FUNC, self.RefreshRightList, self)
    EventDispatcher:Add(Event.RESET_PLAYERDATA, self.RefreshRightList, self)
    EventDispatcher:Add(Event.ADMIN_EFF_END, self.DoAcceffect, self)
    EventDispatcher:Add(Event.LACK_MONEY, self.DoShipMoneyTip, self)
    EventDispatcher:Add(Event.DEFAULT_MONEY_EFFECT, self.PlayDefaultMoneyEffect, self)
    EventDispatcher:Add(Event.ADMIN_ADD_INCOME, self.AddIncomeTips, self)

    -- 引导
    CommonUIObjectManager:Add(UIKey.EarthBtn, self.mapBtn)
    CommonUIObjectManager:Add(UIKey.BuildAquaBtn, self.aquariumBtn)

    self:RefreshCurrency(PlayerData.coinNum, PlayerData.diamondNum)
    self:RefreshIncomeSpeed()
    self:RefreshRightList()
    self:UpdateAchieveTile()
    self:UpdateTopState()
    self:CheckGuide()
end

-- 强制引导处理
function MainTopUI:CheckGuide()
    if not IsGuideDone(1) then
        self:OnMapClick()
    end
end

function MainTopUI:DoAcceffect()
    local slot = self.coinLabel:GetChild("slot")
    if nil == self.EffectWrap[slot] then
        local function effectCallback(wrap)
            self.EffectWrap[slot] = wrap
        end
        CommonUIUtils.CreateUIModelFromPool(
            GameObjectManager.UIEffPoolName ,
            "Prefabs/Particle/waibao/UI/Eff_UI_shouyibaodian.prefab",
            slot, effectCallback
        )
    end
    slot.visible = false
    slot.visible = true
    self.coinLabel:GetTransition('Effect_Income'):Play()
end

function MainTopUI:DoShipMoneyTip()
    local btn = self:GetRightBtn(rightBtnKey.ShipTreasure)
    if not btn.visible then
        return
    end

    local slot = btn:GetChild("slot")
    if self.shipTipTimer then return end

    if nil == self.EffectWrap[slot] then
        local function effectCallback(wrap)
            self.EffectWrap[slot] = wrap
        end
        CommonUIUtils.CreateUIModelFromPool(
            GameObjectManager.UIEffPoolName ,
            "Prefabs/Particle/waibao/UI/Eff_UI_6biankuosankuang.prefab",
            slot, effectCallback
        )
    end    
    UIManager.ShowMsg(Localize("GoToShipTreasure"))
    slot.visible = true
    if self.shipTipTimer then
        TimerManager.disposeTimer(self.shipTipTimer)
    end
    self.shipTipTimer = TimerManager.waitTodo(5, 1, function()
        slot.visible = false
        panel.shipTipTimer = nil
    end)
end

function MainTopUI:ShowZoomView()
    UIManager.OpenUI(UIInfo.PhotoUI)
    EventDispatcher:Dispatch(Event.SHOW_INCOME, self.tabIndex,false)
    PlayerPrefs.SetInt("ClickAquariumPhoto", 1)
    self:ShowWeakTips(self.zoomBtn, false)
end

function MainTopUI:ShowAquariumSelect()
    UIManager.OpenUI(UIInfo.AquariumSelectUI)
    EventDispatcher:Dispatch(Event.SHOW_INCOME, self.tabIndex,false)
    PlayerPrefs.SetInt("ClickAquariumSelect", 1)
    self:ShowWeakTips(self.aquariumBtn, false)
end

function MainTopUI:ShowAchievement()
    EventDispatcher:Dispatch(Event.ACHIEVE_TAB_OPEN)
end


function MainTopUI:OnCoinLabelClick()
end

function MainTopUI:OnHeadClick()
    UIManager.OpenUI(UIInfo.InformationUI)
end

function MainTopUI:OnMapClick()
    UIManager.OpenTab(UIInfo.MainUI, UIInfo.EarthUI)
    EventDispatcher:Dispatch(Event.SHOW_INCOME, self.tabIndex,false)
end

function MainTopUI:OnReturnClick()
    self:RefreshRightList()
    EventDispatcher:Dispatch(Event.MAIN_UI_RETURN)
    EventDispatcher:Dispatch(Event.SHOW_INCOME, 0,true)
end

function MainTopUI:OnSmallMapClick()
    if nil == PlayerDatas.SeaData:GetNextSea() then return end
    UIManager.OpenUI(UIInfo.OceanAeraUI)
end

function MainTopUI:OnUpdate()
    if PlayerData.Datas.FishData:CanCreateAdBox() then
        self:StartMoveAd()
    end
end

function MainTopUI:Close()
    self.rightBtns = nil
    PlayerDatas.AdvData:SetLunchEndUpdate(nil)
    self.zoomBtn.onClick:Clear()
    self.aquariumBtn.onClick:Clear()
    self.coinLabel.onClick:Clear()
    self.mapBtn.onClick:Clear()
    self.returnBtn.onClick:Clear()
    self.smallMap.onClick:Clear()
    self.achieveBtn.onClick:Clear()
    self.Button_MoveAd.onClick:Clear()
    TimerManager.disposeTimer(self.doubleMoneyTimer)
    self.doubleMoneyTimer = nil
    if self.shipTipTimer then
        TimerManager.disposeTimer(self.shipTipTimer)
        self.shipTipTimer = nil
    end
    for k, v in pairs(self.EffectWrap) do
        CommonUIUtils.ReturnUIModelToPool(v,GameObjectManager.UIEffPoolName)
    end
    self.EffectWrap = nil
    if self.MainTaskEffectWrap then
        CommonUIUtils.ReturnUIModelToPool(self.MainTaskEffectWrap,GameObjectManager.UIEffPoolName)
        self.MainTaskEffectWrap = nil
    end
    self.smallMapReddot:Destroy()
    self.aquariumReddot:Destroy()
    if self.ShipFishRed then
        self.ShipFishRed:Destroy()
    end
    EventDispatcher:Remove(Event.OPEN_FUNC, self.OnOpenFunction, self)
    EventDispatcher:Remove(Event.COIN_INCOME, self.OnCoinIncome, self)
    EventDispatcher:Remove(Event.CURRENCY_CHANGED, self.OnCurrencyChange, self)
    EventDispatcher:Remove(Event.FISH_LEVELUP, self.RefreshIncomeSpeed, self)
    EventDispatcher:Remove(Event.FISH_GROWUP, self.RefreshIncomeSpeed, self)
    EventDispatcher:Remove(Event.OPENED_TAB, self.HandleUIOpen, self)
    EventDispatcher:Remove(Event.CLOSED_TAB, self.HandleUIClose, self)
    EventDispatcher:Remove(Event.AD_LUNCH_SHOW, self.OnLunchAd, self)
    EventDispatcher:Remove(Event.GET_MAIN_TASK_PRIZE, self.RefreshRightList, self)
    EventDispatcher:Remove(Event.AD_GET_LUNCH_REWARD, self.OnGetLunchReward, self)
    EventDispatcher:Remove(Event.FISH_FISH_END, self.ShowGold, self)
    EventDispatcher:Remove(Event.AD_GET_DOUBLE_MONEY, self.RefreshDoubleMoney, self)
    EventDispatcher:Remove(Event.ADD_BUFFER, self.RefreshIncomeSpeed, self)
    EventDispatcher:Remove(Event.PLAY_REWARD_EFFECT, self.PlayRewardEffect, self)
    EventDispatcher:Remove(Event.UPGRADE_ACHIEVE_TITLE, self.UpdateAchieveTile, self)
    EventDispatcher:Remove(Event.MAIN_TAB_OPEN, self.OnBottomTabChange, self)
    EventDispatcher:Remove(Event.LOADING_COMPLETE, self.OnSceneLoaded, self)
    EventDispatcher:Remove(Event.FISH_LEVELUP, self.UpdateTopState, self)
    EventDispatcher:Remove(Event.AQUARIUM_LEVELUP_DECORATION, self.UpdateTopState, self)
    EventDispatcher:Remove(Event.CURRENCY_CHANGED, self.UpdateTopState, self)
    EventDispatcher:Remove(Event.UNLOCK_FUNC, self.RefreshRightList, self)
    EventDispatcher:Remove(Event.RESET_PLAYERDATA, self.RefreshRightList, self)
    EventDispatcher:Remove(Event.ADMIN_EFF_END, self.DoAcceffect, self)
    EventDispatcher:Remove(Event.LACK_MONEY, self.DoShipMoneyTip, self)
    EventDispatcher:Remove(Event.DEFAULT_MONEY_EFFECT, self.PlayDefaultMoneyEffect, self)
    EventDispatcher:Remove(Event.ADMIN_ADD_INCOME, self.AddIncomeTips, self)
end

return MainTopUI