-- region *.lua
-- Date
-- 发现物品，升级物品弹出框

local FishGrowthUI = UIManager.PanelFactory(UIInfo.FishGrowthUI)
FishGrowthUI.Rotate = false;
FishGrowthUI.UsedTime = 0;
FishGrowthUI.WaitTime = 0.5;
FishGrowthUI.RotateTime = 2.5;
FishGrowthUI.InitSpeed = 40;
FishGrowthUI.AddSpeed = 500;
FishGrowthUI.ChangeScaleTime  = 0.5;

function FishGrowthUI:ShowCurrentFish()
    self.ShowCurrent = true;
    -- self.FishWrap.rotationY = 90
    
    AudioManager.Vibrate()
    self.window.visible = true
    self.Button_NoAD.visible = true
    self.EffectWrap.visible = false
    local function effectCallback1(wrap)
        self.EffectWrap1 = wrap
    end
    local function callback(wrap)
        self.FishWrap = wrap
        self.FishWrap.rotationY = 90
    end
    CommonUIUtils.CreateUIModelFromPool(GameObjectManager.UIEffPoolName ,string.format( "Prefabs/Fishes/%s.prefab",self.CurrentModel),self.Graph, callback,self.CurrentScale*9)
    CommonUIUtils.CreateUIModelFromPool(GameObjectManager.UIEffPoolName ,"Prefabs/Particle/waibao/UI/Eff_UI_yushengjie_baodian.prefab",self.EffectGraph1, effectCallback1)
end



function FishGrowthUI:ShowFishGrowth(fishConfig,lastGrowth,currentGrowth)
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
         self.UsedTime = 0;
        self.Speed = self.InitSpeed;
        self.RotationY = self.FishWrap.rotationY
        self.Roate = true;
    end
    local model,scale = PlayerData.Datas.FishData:GetFishUIModelAndScale(fishConfig.ID, lastGrowth)
    scale = scale *0.6
    self.CurrentModel,self.CurrentScale = PlayerData.Datas.FishData:GetFishUIModelAndScale(fishConfig.ID, currentGrowth)
    self.Scale = self.CurrentScale*100*9
    self.LastScale = scale*100*9
    CommonUIUtils.CreateUIModelFromPool(GameObjectManager.UIEffPoolName ,string.format( "Prefabs/Fishes/%s.prefab",model),self.Graph, callback,scale*9)
    local function effectCallback(wrap)
        self.EffectWrap = wrap
        self.EffectWrap.z =100
    end   
    CommonUIUtils.CreateUIModelFromPool(GameObjectManager.UIEffPoolName ,"Prefabs/Particle/waibao/UI/Eff_UI_yushengjie_suduxian.prefab",self.EffectGraph, effectCallback)
end

-- 子类初始化UI控件
-- action: 发现奖励，成长奖励，
function FishGrowthUI:OnOpen(action, data, callback)
    self.action = action
    self.data = data
    self.callback = callback

    --self.UI.sortingOrder = UISortOrder.FishGrowthUI
    self.Graph = self.UI:GetChild("Graph")
    self.State = self.UI:GetController("State")
    UIUtils.SetControllerIndex(self.State,PlayerDatas.SeaData.currentSea-3000000)
    self.EffectGraph = self.UI:GetChild("EffectGraph")
    self.EffectGraph1 = self.UI:GetChild("EffectGraph1")
    self.BG = self.UI:GetChild("n44")
    self.Graph_BG = self.BG:GetChild("Graph_BG")
    self.BGType_C = self.BG:GetController("Type_C")
    UIUtils.SetControllerIndex(self.BGType_C, 3)
    self.window = self.UI:GetChild("groeCom")
    self.nameLabel = self.window:GetChild("Text_Name")
    self.qualityLabel = self.window:GetChild("Text_Quality")
    -- self.bgCom = self.window:GetChild("bg")
    self.window.visible = false
    self.stateCtrl = self.window:GetController("State_C")
    
    self.closeBtn = self.window:GetChild("btnClose")

    self.Button_NoAD = self.window:GetChild("Button_NoAD")
    self.Button_NoAD.text = Localize("ClickToClose")
    self.Button_NoAD.visible = false
    self.Text_Desc_1 = self.window:GetChild("Text_Desc_1")
    self.Text_Desc_2 = self.window:GetChild("Text_Desc_2")
    self:ShowFishGrowth(data.fishConfig, data.fish.growth -1,data.fish.growth)
end

local function CloseUI()
    UIManager.ClosePopupUI(UIInfo.FishGrowthUI)
end

-- 子类绑定各种事件
function FishGrowthUI:OnRegister()
    local callback = self.callback
    self.BG.onClick:Add(function()
        if self.Button_NoAD.visible then
            CloseUI()
        end
    end)
end

function FishGrowthUI:OnShow()
    
end

function FishGrowthUI:OnHide()
    --UIManager.tipsTool():CloseItemPopupUIAnim(self.UI, true, UIInfo.FishGrowthUI)
end

-- 强制刷新,比如网络事件监听，切换语言包，断线重连等
function FishGrowthUI:OnRefresh(...)
end

-- 解绑各类事件
function FishGrowthUI:OnUnRegister()
    self.BG.onClick:Clear()


    if self.timer then
        self.timer = TimerManager.disposeTimer(self.timer)
    end
    if self.effectTimer then
        self.effectTimer = TimerManager.disposeTimer(self.effectTimer)
    end
end

function FishGrowthUI:Lerp(startValue,endValue,progress,smooth)
    progress = progress > 1 and 1 or progress
    local scale  = startValue + (endValue - startValue)*progress
    return smooth and scale or math.random( scale*0.9,scale*1.1)
end

function FishGrowthUI:OnUpdate()
    if self.Roate then
        self.UsedTime = self.UsedTime + TimerManager.deltaTime
        if self.UsedTime >= self.WaitTime then
            self.FishWrap.scale = Vector2.one * self:Lerp(self.LastScale,self.Scale,(self.UsedTime - self.WaitTime)/(self.RotateTime- self.WaitTime))
        end
        self.Speed = self.Speed + self.AddSpeed* TimerManager.deltaTime
        self.RotationY = self.RotationY + self.Speed*TimerManager.deltaTime
        if self.RotationY >= 360 then
            self.RotationY = 0
        end
        self.FishWrap.rotationY = self.RotationY
        if self.UsedTime >= self.RotateTime then
            self.UsedTime = 0
            self.Roate = false
            self:ShowCurrentFish()
        end
    end
    if self.ShowCurrent then
        self.UsedTime = self.UsedTime + TimerManager.deltaTime
        self.FishWrap.scale = Vector2.one * self:Lerp(self.Scale*0.8,self.Scale,self.UsedTime/self.ChangeScaleTime,true)
        if self.UsedTime >= self.ChangeScaleTime then
            self.ShowCurrent = false;
        end
    end
end

-- 关闭
function FishGrowthUI:OnClose()
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

return FishGrowthUI

--endregion
