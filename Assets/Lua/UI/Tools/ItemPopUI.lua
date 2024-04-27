-- region *.lua
-- Date
-- 发现物品，升级物品弹出框

local ItemPopupUI = UIManager.PanelFactory(UIInfo.ItemPopupUI)
local DecorationConfig = Utils.LoadConfig("Config.DecorationConfig")
local panel = ItemPopupUI
--ItemPopupUI.HidePrePanel = true

-- stateIndex : 0 :无确认按钮（有x按钮） 1：单个确认按钮  2：确认 取消按钮 3:确认取消 同时背景层不可点击
function ItemPopupUI:SetItemPopupUIState(stateIndex)
    self.stateCtrl.selectedIndex = stateIndex
end

function ItemPopupUI:ShowQuality(quality, always)
    
end

function ItemPopupUI:ShowFish(fishConfig, productConfig)
    self.nameLabel.text = fishConfig.Name
    self.qualityLabel.text = Localize("Quality" .. tostring(fishConfig.Quality))
    CommonUIUtils.SetColorByQuality(self.qualityLabel, fishConfig.Quality)
    -- -- TODO 显示3D模型
    local function callback(wrap)
        self.FishWrap = wrap
        self.FishWrap.rotationY = 90
        self.FishWrap.z = 120
    end
    local model,scale = PlayerData.Datas.FishData:GetFishUIModelAndScale(fishConfig.ID, 2)
    -- todo 用配置里的模型
    CommonUIUtils.CreateUIModelFromPool(GameObjectManager.UIEffPoolName ,
    string.format( "Prefabs/Fishes/%s.prefab",fishConfig.Model1),self.Graph, callback,scale*8)
    local function effectCallback(wrap)
        self.EffectWrap = wrap
    end   
    CommonUIUtils.CreateUIModelFromPool(GameObjectManager.UIEffPoolName ,"Prefabs/Particle/waibao/UI/EFF_UI_faxianguangxiao.prefab",self.EffectGraph, effectCallback)
end

function ItemPopupUI:ShowNromalBox()
    -- -- TODO 显示3D模型
    local function callback(wrap)
        self.FishWrap = wrap
        self.FishWrap.rotationY = 90
    end
    CommonUIUtils.CreateUIModelFromPool(GameObjectManager.UIEffPoolName ,"Prefabs/FishHelp/Box_01.prefab",self.Graph, callback,5)
end

function ItemPopupUI:ShowAdBox()
    -- -- TODO 显示3D模型
    local function callback(wrap)
        self.FishWrap = wrap
        self.FishWrap.rotationY = 90
    end
    CommonUIUtils.CreateUIModelFromPool(GameObjectManager.UIEffPoolName ,"Prefabs/FishHelp/Box_01.prefab",self.Graph, callback,5)
end

function ItemPopupUI:ShowCurrentFish(model)
    local function callback(wrap)
        self.FishWrap = wrap
        self.FishWrap.rotationY = 90
        self.FishWrap.z = 120
    end
    -- todo 用配置里的模型
    CommonUIUtils.CreateUIModelFromPool(GameObjectManager.UIEffPoolName ,string.format( "Prefabs/Fishes/%s.prefab",model),self.Graph, callback,10)
     
end

function ItemPopupUI:ShowFishGrowth(fishConfig,lastGrowth,currentGrowth)
    lastGrowth = lastGrowth or 0
    currentGrowth = currentGrowth or 1
    self.nameLabel.text = fishConfig.Name
    self.qualityLabel.text = Localize("Quality" .. tostring(fishConfig.Quality))
    CommonUIUtils.SetColorByQuality(self.qualityLabel, fishConfig.Quality)
    self.Text_Desc_1.text = Localize("FishGrade"..lastGrowth)
    self.Text_Desc_2.text = Localize("FishGrade"..currentGrowth)
    local function callback(wrap)
        self.FishWrap = wrap
         self.FishWrap.rotationY = 90
         self.FishWrap.z = 120
    end
    local model = PlayerData.Datas.FishData:GetFishModelAndScale(fishConfig.ID, lastGrowth)
    local currentModel = PlayerData.Datas.FishData:GetFishModelAndScale(fishConfig.ID, currentGrowth)
    -- todo 用配置里的模型
    CommonUIUtils.CreateUIModelFromPool(GameObjectManager.UIEffPoolName ,string.format( "Prefabs/Fishes/%s.prefab",model),self.Graph, callback,5)
    local function effectCallback(wrap)
        self.EffectWrap = wrap
    end
    -- todo 用配置里的模型
    CommonUIUtils.CreateUIModelFromPool(GameObjectManager.UIEffPoolName ,"Prefabs/Particle/waibao/UI/EFF_UI_shengjieguangxiao.prefab",self.EffectGraph, effectCallback)
    if self.effectTimer == nil then
        self.effectTimer = TimerManager.newTimer(1, false, true, nil, nil, function()
            self:ShowCurrentFish(currentModel)
        end)
        self.effectTimer:start()
    else
        self.effectTimer:reset()
        self.effectTimer:start()
    end
end

function ItemPopupUI:ShowDecoration(decorationConfig)
    self.nameLabel.text = decorationConfig.Name
    self.qualityLabel.text = Localize("Quality" .. tostring(decorationConfig.Quality))
    CommonUIUtils.SetColorByQuality(self.qualityLabel, decorationConfig.Quality)
    self.window:GetChild("Icon_Item").icon = "ui://Library/"..decorationConfig.Icon
end

function ItemPopupUI:ShowDecorationGrowth(decorationConfig, decoration)
    self.nameLabel.text = decorationConfig.Name
    self.qualityLabel.text = Localize("Quality" .. tostring(decorationConfig.Quality))
    CommonUIUtils.SetColorByQuality(self.qualityLabel, decorationConfig.Quality)
    self.window:GetChild("Icon_Item").icon = "ui://Library/"..decorationConfig.Icon
end

function ItemPopupUI:ShowGetRewardEffect(rewardType)
    UIUtils.MoneyEffect(rewardType, self.window:GetChild("RewardCom"))
end

function ItemPopupUI:ShowDoubleMoney()
    local cfg = ConfigData:GetDoubleReward()
    local buffCfg = ConfigData:GetBufferById(cfg.Buffer)
    local dur = cfg.Duration
    local lastDoubleTime = LocalData.getDoubleTime()
    local first = nil == lastDoubleTime or lastDoubleTime == 0
    -- 取消首次免费，备注备用
    -- if first then
    --     -- 首次
    --     UIUtils.SetControllerIndex(self.button1State_C, 0)
    -- else
    --     UIUtils.SetControllerIndex(self.button1State_C, 1)
    -- end
    UIUtils.SetControllerIndex(self.button1State_C, 1)

    self.titleLabel.text = Localize("DoubleMoneyTime")
    self.Text_Desc_5.text = cfg.Desc
    local timerBar = self.window:GetChild("bar")
    local timerBarTitle = timerBar:GetChild("title")
    timerBar.max = cfg.MaxDur * 60
    timerBar.value = 0
    local cd = PlayerData.doubleEndtime - TimerManager.getCurrentClientTime()
    if cd > 0 then
        self.timer = TimerManager.newTimer(cd, false, true, nil, function (t, f)
            local canAdd = f < timerBar.max
            self.button1.visible = canAdd
            self.Text_Desc_6.visible = not canAdd
            timerBar.value = f
            timerBarTitle.text = Utils.secondConversion(f)
        end,
        function ()
            self.button1.enabled = true
        end)
        self.timer:start()
    else
        timerBarTitle.text = "00:00:00"
    end

    self.callback = function ()
        local curTime = TimerManager.getCurrentClientTime()
        local function addBuff()
            PlayerData:AddDoubleRewardTime(buffCfg.LifeTime)
            PlayerData:AddDoubleRewardBuff(true)
            LocalData.saveDoubleTime(curTime)
            EventDispatcher:Dispatch(Event.AD_GET_DOUBLE_MONEY)
        end
        -- 取消首次免费，备注备用
        -- if first then
        --     addBuff()
        -- else
        --     SDKManager:PlayAD(addBuff)
        -- end
        SDKManager:PlayAD(addBuff, "翻倍增益_翻倍增益", "翻倍增益")
    end
    AnalyticsManager.onADButtonShow("激励视频", "翻倍增益_翻倍增益", "翻倍增益")
end

function ItemPopupUI:ShowPeriodReward()
    local cfg = ConfigData:GetPeriodReward()
    local rewardDur = ConfigData:GetPeriodRewardDur() or 0
    local diamond = cfg.Diamond
    local adReward = PlayerData:GetRealCoinIncome() * rewardDur * 60
    self.titleLabel.text = Localize("LunchTime")
    self.subtitle.text = Localize("LunchTimeDesc1")
    self.Text_Desc_7.text = Localize("GrabNow")
    self.reward=self.window:GetChild("RewardCom")
    self.reward:GetChild("coinNum").text = Utils.ResourceHandler(adReward)
    self.reward:GetChild("diamondNum").text = Utils.ResourceHandler(diamond)

    local function effectCallback(wrap)
        self.EffectWrap = wrap
    end  
    CommonUIUtils.CreateUIModelFromPool(
        GameObjectManager.UIEffPoolName ,
        "Prefabs/Particle/waibao/UI/EFF_UI_faxianguangxiao.prefab",
        self.BackEffectGraph, effectCallback
    )

    AnalyticsManager.onADButtonShow("激励视频", "吃饭时间_吃饭时间", "吃饭时间")

    self.callback = function ()
        SDKManager:PlayAD(function ()
            PlayerData:RewardCoin(adReward)
            UIUtils.MoneyEffect(CommonCostType.Coin)
            if diamond ~= 0 then
                PlayerData:RewardDiamond(diamond)
                UIUtils.MoneyEffect(CommonCostType.Diamond)
            end
            PlayerDatas.AdvData:DoLunchReward()
        end, "吃饭时间", "吃饭时间")
    end
end

function ItemPopupUI:ShowAchieveTitlePrize()
    UIUtils.SetControllerIndex(self.stateCtrl, 8)
    local cfg = PlayerDatas.AchievementData:NextTitle()
    if nil == cfg then return end

    self.titleLabel.text = Localize("AchieveTotalPrize")
    self.button2.text = Localize("GetReward")
    UIUtils.FillResBtn(self.button2money, cfg.RewardType, cfg.Reward)
    local finish = PlayerDatas.AchievementData:TitleAchieved()
    UIUtils.SetControllerIndex(self.button2:GetController("Status_C1"), finish and 0 or 1)
    self.button2.touchable = finish == true
    self.callback = function ()
        if not finish then return end
        PlayerDatas.AchievementData:CollectTitlePrize()
        self:ShowGetRewardEffect(cfg.RewardType)
    end
end

-- 子类初始化UI控件
-- action: 发现奖励，成长奖励，
function ItemPopupUI:OnOpen(action, data, callback)
    panel = self
    self.action = action
    self.data = data
    self.callback = callback

    --self.UI.sortingOrder = UISortOrder.ItemPopupUI
    self.window = self.UI:GetChild("Window")

    self.titleLabel = self.window:GetChild("Text_Title")
    self.nameLabel = self.window:GetChild("Text_Name")
    self.qualityLabel = self.window:GetChild("Text_Quality")
    -- self.bgCom = self.window:GetChild("bg")

    self.stateCtrl = self.window:GetController("State_C")
    self.typeCtrl = self.window:GetController("Type_C")

    self.button1 = self.window:GetChild("Button_1")
    self.button1State_C = self.button1:GetController("State_C")
    self.button2 = self.window:GetChild("Button_2")
    self.Label_Money = self.window:GetChild("Label_Money")
    self.button2money = self.button2:GetChild("Label_Money")
    self.Label_Icon = self.window:GetChild("Label_Icon")
    
    self.button2State_C = self.button2:GetController("State_C")

    self.closeBtn = self.window:GetChild("btnClose")

    self.Button_NoAD = self.window:GetChild("Button_NoAD")
    self.Graph = self.window:GetChild("Graph")
    self.EffectGraph = self.window:GetChild("EffectGraph")
    self.BackEffectGraph = self.window:GetChild("BackEffectGraph")
    self.subtitle = self.window:GetChild("Text_Subtitle")
    self.Text_Desc_1 = self.window:GetChild("Text_Desc_1")
    self.Text_Desc_2 = self.window:GetChild("Text_Desc_2")
    self.Text_Desc_3 = self.window:GetChild("Text_Desc_3")
    self.Text_Desc_4 = self.window:GetChild("Text_Desc_4")
    self.Text_Desc_5 = self.window:GetChild("Text_Desc_5")
    self.Text_Desc_6 = self.window:GetChild("Text_Desc_6")
    self.Text_Desc_7 = self.window:GetChild("Text_Desc_7")
    -- 默认状态
    self.titleLabel.text = Localize("NewDiscovery")
    if action == "FishReward" then
        if data.productConfig.EnableAD then
            self.stateCtrl.selectedIndex = 0
            UIUtils.SetControllerIndex(self.button2State_C, 1)
            UIUtils.SetControllerIndex(self.button1State_C, 3)
            self.button2:GetChild("Text_Mult").text = LocalizeExt("ADReward", {data.productConfig.RewardAD})
            self.button1.title = Localize("GetRewardNow")
        else
            self.stateCtrl.selectedIndex = 9
            UIUtils.SetControllerIndex(self.button2State_C, 4)
            self.button2:GetChild("n13").text = Localize("GetReward")
        end
        CommonUIUtils.SetCurrencyLabel(self.Label_Money,data.productConfig.Reward, data.productConfig.RewardType)
        CommonUIUtils.SetCurrencyLabel(self.button2:GetChild("Label_Money"), data.productConfig.Reward, data.productConfig.RewardType)
        self:ShowFish(data.fishConfig, data.productConfig)
    elseif action == "DecorationReward" then
        local decorationCfg = DecorationConfig.DecorationsByID[data.ItemID]
        if data.EnableAD then
            self.stateCtrl.selectedIndex = 0
            UIUtils.SetControllerIndex(self.button2State_C, 1)
            self.button2:GetChild("Text_Mult").text = LocalizeExt("ADReward", {data.RewardAD})
            self.button1.title = Localize("GetRewardNow")
            UIUtils.SetControllerIndex(self.button1State_C, 3)
        else
            self.stateCtrl.selectedIndex = 9
            UIUtils.SetControllerIndex(self.button2State_C, 4)
            self.button2:GetChild("n13").text = Localize("GetReward")
        end
        CommonUIUtils.SetCurrencyLabel(self.Label_Money,data.RewardPoint, data.RewardType)
        CommonUIUtils.SetCurrencyLabel(self.button2:GetChild("Label_Money"), data.RewardPoint, data.RewardType)
        self:ShowDecoration(decorationCfg)
    elseif action == "AquariumUnlockItem" then
        self.stateCtrl.selectedIndex = 1
        if data.info.Type == CommonItemType.Decoration then
            self:ShowDecoration(data.decorationConfig, data.decoration)
            self.titleLabel.text = Localize("TitleUnlockDecoration")
        else
            self:ShowFish(data.fishConfig, data.info)
            self.titleLabel.text = Localize("TitleUnlockFish")
        end

        if data.info.UnlockType == CommonCostType.CoinAD then
            self.button1.title = Localize("PayToGain")..UIUtils.HtmlImg(ConstantValue.CoinIconURL)..Utils.GetCountFormat(data.info.UnlockCoin)
            self.button1.enabled = PlayerData.coinNum >= data.info.UnlockCoin
        else
            self.button1.title = Localize("PayToGain")..UIUtils.HtmlImg(ConstantValue.DiamondIconURL)..Utils.GetCountFormat(data.info.UnlockDiamond)
            self.button1.enabled = PlayerData.diamondNum >= data.info.UnlockDiamond
        end
        self.button2:GetChild("Text_Mult").text = Localize("GetDecoration")
    elseif action == "GrowUpFish" then
        self.stateCtrl.selectedIndex = 2
        self.button1:GetChild("title").text = Localize("Cooooool")
        self.titleLabel.text = Localize("GrownUp")
        self:ShowFishGrowth(data.fishConfig, data.fish.growth -1,data.fish.growth)
    elseif action == "GrowUpDecoration" then
        self.stateCtrl.selectedIndex = 5
        self:ShowDecorationGrowth(data.decorationConfig, data.decoration)
        self.button1:GetChild("title").text = Localize("Cooooool")
        self.titleLabel.text = Localize("GrownUp")
    elseif action == "DoubleMoney" then
        UIUtils.SetControllerIndex(self.stateCtrl, 6)
        self.button1.text = Localize("DoDoubleMoney")
        self.button1:GetChild("Text_Mult").text = Localize("DoDoubleMoney")
        self.Text_Desc_6.text = Localize("DoubleTimeLimited")
        self.Text_Desc_6.visible = false
        self:ShowDoubleMoney()
    elseif action == "NormalBox" then
        UIUtils.SetControllerIndex(self.stateCtrl, 3)
        self.titleLabel.text = Localize("InWaterBox")
        UIUtils.SetControllerIndex(self.button2State_C, 0)
        self.Label_Icon.title = Utils.GetCountFormat(data)
        self.button2:GetChild("title").text = Localize("GetReward")
        AudioManager.PlayEAXSound(1007)
    elseif action == "AdBox" then
        UIUtils.SetControllerIndex(self.stateCtrl, 3)
        UIUtils.SetControllerIndex(self.button2State_C, 1)
        self.titleLabel.text = Localize("InWaterBox")
        self.Label_Icon.title = Utils.GetCountFormat(data)
        self.button2:GetChild("Text_Mult").text = Localize("GetReward")
        local function effectCallback(wrap)
            self.EffectWrap = wrap
        end   
        CommonUIUtils.CreateUIModelFromPool(GameObjectManager.UIEffPoolName ,"Prefabs/Particle/waibao/UI/Eff_UI_piaoliubaoxiang.prefab",self.Graph, effectCallback)
        self.Button_NoAD.title = Localize("NoADThanks")
        AudioManager.PlayEAXSound(1007)
    elseif action == "LunchTime" then
        UIUtils.SetControllerIndex(self.stateCtrl, 7)
        UIUtils.SetControllerIndex(self.button1State_C, 1)
        self.button1:GetChild("Text_Mult").text = Localize("DoDinner")
        self:ShowPeriodReward()
    elseif action == "AchieveTitlePrize" then
        self:ShowAchieveTitlePrize()
    end
end

local function CloseUI()
    UIManager.ClosePopupUI(UIInfo.ItemPopupUI)
end

-- 子类绑定各种事件
function ItemPopupUI:OnRegister()
    local callback = self.callback
    self.button1.onClick:Add(function()
        CloseUI()
        callback()
    end)

    self.button2.onClick:Add(function()
        CloseUI()
        callback(true)
    end)
    
    self.closeBtn.onClick:Add(function()
       CloseUI()
    end)

    self.Button_NoAD.onClick:Add(function()
        CloseUI()
        -- callback()
    end)
    EventDispatcher:Add(Event.ITEMPOP_GETREWARD, self.ShowGetRewardEffect, self)
end

function ItemPopupUI:OnShow()
    
end

function ItemPopupUI:OnHide()
    --UIManager.tipsTool():CloseItemPopupUIAnim(self.UI, true, UIInfo.ItemPopupUI)
end

-- 强制刷新,比如网络事件监听，切换语言包，断线重连等
function ItemPopupUI:OnRefresh(...)
end

-- 解绑各类事件
function ItemPopupUI:OnUnRegister()
    self.button1.onClick:Clear()
    self.button2.onClick:Clear()
    self.Button_NoAD.onClick:Clear()

    if self.timer then
        self.timer = TimerManager.disposeTimer(self.timer)
    end
    if self.effectTimer then
        self.effectTimer = TimerManager.disposeTimer(self.effectTimer)
    end
    EventDispatcher:Remove(Event.ITEMPOP_GETREWARD, self.ShowGetRewardEffect, self)
end

-- 关闭
function ItemPopupUI:OnClose()
    self.callback = nil
    if self.FishWrap then
        CommonUIUtils.ReturnUIModelToPool(self.FishWrap,GameObjectManager.UIEffPoolName)
        self.FishWrap = nil
    end
    if self.EffectWrap then
        CommonUIUtils.ReturnUIModelToPool(self.EffectWrap,GameObjectManager.UIEffPoolName)
        self.EffectWrap = nil
    end
end

return ItemPopupUI

--endregion
