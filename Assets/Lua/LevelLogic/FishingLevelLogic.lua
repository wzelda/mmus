local FishingLevelLogic = class(require "LevelLogic.LevelLogic")
local SeaConfig = Utils.LoadConfig("Config.SeaConfig")
local FishConfig = Utils.LoadConfig("Config.FishConfig")
local PlayerDisplayConfig = Utils.LoadConfig("Config.PlayerDisplayConfig")
local fishData = PlayerData.Datas.FishData
-- 血条
FishingLevelLogic.hpBar = nil
-- 缓动血条
FishingLevelLogic.redhpBar = nil
-- 伤害飘字
FishingLevelLogic.damageText = nil
-- 暴击伤害飘字
FishingLevelLogic.critDamageText = nil

-- 每过多少秒跳一次伤害
FishingLevelLogic.DamageHitUnit = 0.16
FishingLevelLogic.DamageTime = 0
-- 在钓鱼场景里放大的倍数
FishingLevelLogic.FixScale = 2.5
local isHighPower = false
local playAudioId = nil
function FishingLevelLogic:SetFishesActive()
    if self.fishes == nil then
        return
    end
    for k ,  v in pairs(self.fishes) do
        v:SetActive(self.SelectKey == k)
    end
end

function FishingLevelLogic:RandomFishResult()
    local model,scale = 0,0
    local unlockFish = nil
    if self.UnlockCount == 0 then
        unlockFish = self.DefautFish
        scale = 1
    else
        local index = math.random(self.UnlockCount)
        index = math.ceil( index )
        index = index == 0 and 1 or index
        unlockFish = self.UnlockFishes[index]
        if unlockFish then
            model,scale = fishData:GetFightFishModelAndScale(unlockFish)
        end
    end
    
    self.SelectKey =  unlockFish.."_"..scale 
    local fishCfg = FishConfig.FishesByID[unlockFish]
    self.FishLogicScript:SetFishInstance(self.fishes[self.SelectKey],fishCfg.MousePath)
    self:SetFishesActive()
    
end

local function FishCallUI(type)
    EventDispatcher:Dispatch(Event.FISH_CALL_UI, type)
end

local function FishCallAudio(id)
    if not FishingLevelLogic.IsPlayer then
        return
    end
    if id == 0 then
        isHighPower = false
        AudioManager.StopEAXSound(3007)
        AudioManager.StopEAXSound(3008)
    elseif id == 1 then
        if playAudioId ~= 1 then
            AudioManager.StopEAXSound(3008)
            AudioManager.PlayEAXSound(3007,true)
        end
        isHighPower = false
    elseif id == 2 then
        isHighPower = true
        if playAudioId ~= 2 then
            AudioManager.StopEAXSound(3007)
            AudioManager.PlayEAXSound(3008,true)
        end
    else
        AudioManager.PlayEAXSound(id)
    end
    playAudioId = id
end

local function FishResult()
    EventDispatcher:Dispatch(Event.FISH_RESULT)
end


function FishingLevelLogic:PlayAudio(type)
    local audioName = nil
    if type == FishStateEnum.Throw then
        AudioManager.PlayEAXSound(3002)
    elseif type == FishStateEnum.WaitFishBite then
        AudioManager.PlayEAXSound(3003)
    elseif type == FishStateEnum.FishBite then
        if self.IsPlayer then
            self:StratFightBG()
            AudioManager.PlayEAXSound(3004)
        end
    elseif type == FishStateEnum.Fight then
        audioName = nil
    elseif type == FishStateEnum.CriticalStrikeChance then
        audioName = nil
    elseif type == FishStateEnum.InAir then
        audioName = nil
    elseif type == FishStateEnum.ShowHunter then
        audioName = nil
    elseif type == FishStateEnum.PullBack then
        AudioManager.PlayEAXSound(3013)
        FishCallAudio(0)
    elseif type == FishStateEnum.PullUp then
        AudioManager.PlayEAXSound(3014)
        -- AudioManager.PlayEAXSound(3015)
        AudioManager.StopEAXSound(self.powerAudioId)
        audioName = nil
    elseif type == FishStateEnum.Show then
        audioName = nil
    elseif type == FishStateEnum.Crit then
        AudioManager.PlayEAXSound(3009)
    elseif type == FishStateEnum.ShowGold then
        audioName = nil
    elseif type == FishStateEnum.HuntStart then
        audioName = nil
    elseif type == FishStateEnum.FishBite then
        audioName = nil
    elseif type == FishStateEnum.HunterJump then
        audioName = nil
    end
end

function FishingLevelLogic:FishCallUI(type)
    if type == FishStateEnum.InAir and self.IsPlayer then
        self.cameraController:LookAt(self.LureObj,6)
        Time.timeScale = 1
    elseif  type == FishStateEnum.CriticalStrikeChance and self.IsPlayer then
        self.cameraController:LookAt(self.LureObj,6)
         self.cameraSwitch:SwitchFov(3.4,0.6)
         Time.timeScale = 0.85
         EventDispatcher:Dispatch(Event.CG_CANCRIT)
    elseif type == FishStateEnum.Throw and self.IsPlayer then
        self.cameraController:RevertOrigin()
        self.cameraController:CameraThrowAction(12,0.5)
        self.cameraSwitch:SwitchFov(1.2,3)
        if self.IsPlayer then
            AudioManager.Vibrate()
        end
    elseif type == FishStateEnum.FishBite and self.IsPlayer then
        self.cameraController:Shake(0.8)
        if self.IsPlayer then
            AudioManager.Vibrate()
        end
    elseif type == FishStateEnum.Crit then
        -- self.cameraSwitch:SwitchFov(3.4,0.6)
        if self.IsPlayer then
            AudioManager.Vibrate()
            self.cameraController:Shake(0.8)
        end
        Time.timeScale = 1
    elseif type == FishStateEnum.HuntStart and self.IsPlayer then
        self.cameraController:LookAt(self.LureObj,6)
    elseif type == FishStateEnum.HunterJump then
        self.cameraSwitch:SwitchFov(3.4,0.8)
    elseif type == FishStateEnum.Fight and self.IsPlayer then
        self.DamageTime = 0
        self.cameraSwitch:SwitchFov(1,1.5,function()
            self.cameraController:StopLookAt()
            self.cameraController:RevertOrigin(1.5)
        end)
    elseif type == FishStateEnum.PullBack and self.IsPlayer then
        self:HideHpBar()
        self.cameraController:LookAt(self.LureObj,6)
        self.cameraSwitch:SwitchFov(1.4,3)
    elseif type == FishStateEnum.PullUp and self.IsPlayer then
        self.cameraController:LookAt(self.FishPrefabObj,0,true)
        if self.IsPlayer then
            AudioManager.Vibrate()
        end
    elseif type == FishStateEnum.Show then
        self.cameraController:StopLookAt()
        self.cameraController:RevertOrigin()
        if self.IsBox then
            UIManager.OpenUI(UIInfo.ItemPopupUI, nil, nil, "NormalBox", PlayerData.Datas.FishData:NormalBoxRewardCount(), function(ad)
                PlayerData.Datas.FishData:GetNormalBoxReward()
            end)
        else
            if self.itemFish.productConfig.EnableAD then
                AnalyticsManager.onADButtonShow("激励视频", "新的发现_鱼种", "新的发现")
            end
            UIManager.OpenUI(UIInfo.ItemPopupUI, nil, nil, "FishReward", self.itemFish, function(ad)
                if self.itemFish.productConfig.EnableAD and ad then
                    SDKManager:PlayAD(function()
                        PlayerData.Datas.FishData:DiscoverFishReward(self.itemFish.productConfig, true)
                        EventDispatcher:Dispatch(Event.ADD_FISH_EFFECT)
                        EventDispatcher:Dispatch(Event.ITEMPOP_GETREWARD, 
                        self.itemFish.productConfig.RewardType == CommonRewardType.Diamond and 2 or 1 )
                    end, "新的发现_鱼种", "新的发现")
                else
                    PlayerData.Datas.FishData:DiscoverFishReward(self.itemFish.productConfig)
                    EventDispatcher:Dispatch(Event.ADD_FISH_EFFECT)
                    EventDispatcher:Dispatch(Event.ITEMPOP_GETREWARD, 
                    self.itemFish.productConfig.RewardType == CommonRewardType.Diamond and 2 or 1)
                end
            end)
            PlayerData.Datas.FishData:AddFish(self.FishId)
        end
    elseif type == FishStateEnum.ShowGold and not self.IsPlayer then
        EventDispatcher:Dispatch(Event.FISH_FISH_END)
    end
    self.type = type
    self:SetHpbarActive(type)
    if self.IsPlayer then
        self:PlayAudio(type)
    end
end

function FishingLevelLogic:AutoFishStart()
    self:OnBottomListFold(PlayerData.bottomListFolded, 0)
    self.IsPlayer = false
    self.FishLogicScript:AutoFishStart()
    self:PlayBgMusic()
    AudioManager.StopEAXSound(self.powerAudioId)
    self.cameraController:StopLookAt()
end

function FishingLevelLogic:SetUIParent()
    if self.uipanel and self.uipanel.transform.parent == nil then
        self.uipanel.transform.parent = self.LureObj
        self.uipanel.transform.localPosition = Vector3(0, 2, 0)
        self.uipanel.ui:SetScale(2.5, 2.5)
        if self.type == FishStateEnum.Fight then
            self:ShowHpBar()
        else
            self:HideHpBar()
        end
        
    end
end

function FishingLevelLogic:ShowHpBar()
    if self.uipanel and self.uipanel.ui then
        self.uipanel.ui.visible = true
    end
end

function FishingLevelLogic:HideHpBar()
    if self.uipanel and self.uipanel.ui then
        self.uipanel.ui.visible = false
    end
end

function FishingLevelLogic:SetHpbarActive(type)
    if self.hpBar == nil then
        return
    end
    self.hpBar.visible = type == FishStateEnum.Fight and (self.LastHp == nil or self.LastHp > 0)
    if self.redhpBar == nil then
        return
    end
    self.redhpBar.visible = type == FishStateEnum.Fight and(self.LastHp == nil or self.LastHp > 0)

end

function FishingLevelLogic:PalyNextEffect(value)
    if self.Index == nil or self.Index == 4 then
        self.Index = 1
    end
    if self.Texts then
        self.Texts.text = "-"..math.floor( math.random(self.Damage -5,self.Damage +10) ) 
    end
    if self.Effects then
        self.Effects:Play()
    end
    self.Index = self.Index + 1
end

function FishingLevelLogic:UpdateHp(value,addTime)
    
    if self.LastHp == nil then
        self.LastHp = value
    end
    if self.type == FishStateEnum.Fight and self.LastHp ~= value then
        self:PalyNextEffect()
    else
        self.DamageTime = 0
    end
    self:SetUIParent()
    self.LastHp = value
    self.hpBar.value = value
    self.redhpBar:TweenValue(value, 0.7)
    
end




function FishingLevelLogic:SetHpBarMax(value)
    if self.hpBar then
        self.hpBar.max = value
    end
    if self.redhpBar then
        self.redhpBar.value = value
        self.redhpBar.max = value
    end
end

function FishingLevelLogic:CritDamage(value)
    self:SetUIParent()
    self.LastHp = self.LastHp -value
    self.damageText.visible = true
    self.damageText.text = "-".. value
    -- self.Effect:Play()
    UIUtils.SetControllerIndex( self.State_C, 0)
    UIUtils.SetControllerIndex( self.State_C, 1)
end

local function UpdateUIHp(value)
    EventDispatcher:Dispatch(Event.FISH_UPDATE_HP, value)
end

local function CritDamage(value)
    EventDispatcher:Dispatch(Event.FISH_CRITDAMAGE, value)
end

function FishingLevelLogic:InitLogicScript()
    self.Rope = self.LineObj.gameObject:GetComponent(typeof(CS.FishingRope))
    if Utils.unityTargetIsNil(self.Rope) then
        self.Rope = self.LineObj.gameObject:AddComponent(typeof(CS.FishingRope))
    end
    self.FishLogicScript = self.ToolsPos.gameObject:GetComponent(typeof(CS.FishingTempLogic))
    if Utils.unityTargetIsNil(self.FishLogicScript) then
        self.FishLogicScript = self.ToolsPos.gameObject:AddComponent(typeof(CS.FishingTempLogic))
    end
    self.FishLogicScript.LineStartTransform = self.LineStartObj
    self.FishLogicScript.StartBiteTransform = self.StartBiteObj
    self.FishLogicScript.StartMoveTransform = self.StartMoveObj
    self.FishLogicScript.PullUpTransform = self.PullUpObj
    self.FishLogicScript:SetRodInstance(self.Rodskin)
    self.FishLogicScript:SetLureInstance(self.LureObj)
    self.FishLogicScript.RodHead = self.Head
    self.FishLogicScript.FishingRodRoot = self.RodResetObj
    self.FishLogicScript.EffectPos = self.FishEffectsObj
    self.FishLogicScript.EnterWaterEffect = self.EnterWaterEffectObj.gameObject
    self.FishLogicScript.CritEffect = self.CritEffectObj.gameObject
    self.FishLogicScript.SkillEffect= self.PullUpEffectObj.gameObject
    self.FishLogicScript.WaitEffect= self.WaitEffect.gameObject
    self.FishLogicScript.JumpOutEffect = self.JumpOutEffectObj.gameObject
    self.FishLogicScript.FishMoveEffect = self.MoveEffectObj.gameObject
    self.FishLogicScript.LureEnterWaterEffect = self.LureEnterWaterEffect.gameObject
    self.FishLogicScript.FishPrefab = self.FishPrefabObj
    self.FishLogicScript.BoxHead = self.BoxHead
    self.FishLogicScript.AdBox = self.AdBox
    self.FishLogicScript.NormalBox = self.NormalBox
    self.FishLogicScript.BoxStart = self.BoxStart
    self.FishLogicScript.BoxEnd = self.BoxEnd
    self.FishLogicScript.FishingLine = self.Rope
    self.FishLogicScript:SetAutoCallBack(FishResult)
    self.FishLogicScript:SetFishCallUI(FishCallUI)
    self.FishLogicScript:SetFishCallAudio(FishCallAudio)
    self.FishLogicScript:SetCritDamage(CritDamage)
    self.FishLogicScript:AutoFishStart()
end

function FishingLevelLogic:LoadFish(model,scale,id)
    if model == nil then
        return
    end
    -- if self.fishes == nil then
    --     self.fishes = {}
    -- end
    model = string.format( "Prefabs/Fishes/%s.prefab",model)
    GameObjectManager:GetFromPool(GameObjectManager.FightFishesPoolName,model, function(go)
        local key = id.."_"..scale
        self.fishes[key] = go
        local t = go.transform
        go:SetActive(self.SelectKey == key)
        t.parent = self.FishPrefabObj
        t.localPosition = ConstantValue.V3Zero
        t.localRotation = Quaternion.Euler(0, 0, 0)
        t.localScale = ConstantValue.V3One * scale * self.FixScale
        end)
end


function FishingLevelLogic:InitFishes(config)
    self.fishes = {}
    self.UnlockFishes = {}
    self.DefautFish = nil
    self.UnlockCount = 0
    local productConfig = nil
    local fishCfg = nil
    for k , v in pairs(config.Products) do
        productConfig = SeaConfig.ProductsByID[v]
        if productConfig then
            fishCfg = FishConfig.FishesByID[productConfig.ItemID]
            self:LoadFish(fishCfg.FightModel,fishCfg.LargeScale,fishCfg.ID)
            self:LoadFish(fishCfg.FightModel1,fishCfg.LittleScale,fishCfg.ID)
            self:LoadFish(fishCfg.FightModel2,fishCfg.MiddleScale,fishCfg.ID)
            if fishData:OwnedFish(productConfig.ItemID) then
                self.UnlockCount = self.UnlockCount + 1
                table.insert( self.UnlockFishes,productConfig.ItemID)  
            end
            if self.DefautFish == nil then
                self.DefautFish = productConfig.ItemID
            end
            if fishCfg.ID == 1001005 or fishCfg.ID == 1002002 or fishCfg.ID == 1003005 then
                -- 被捕食者吃掉的鱼：黄腹水虎鱼or红鲷鱼or黄金鲽鱼
                self.EatedFish = productConfig.ItemID
            end
        end
    end
end

function FishingLevelLogic:InitObject(config)
    local loadCb = function(obj)
        self.RodStartObj= obj
        if self.RodStartObj then
            local t = self.RodStartObj.transform
            t.parent = self.ToolsPos.transform
            t.localPosition = ConstantValue.V3Zero
            t.localRotation = Quaternion.Euler(0, 0, 0)
            t.localScale = ConstantValue.V3One
            self.Head = self.RodStartObj.transform:Find("Head")
            self.RodResetObj= self.Head:Find("RodResetObj")
            self.Rodskin= self.RodResetObj.transform:Find("Rodskin")
            self.LineStartObj= self.Rodskin.transform:Find("Bone001/Bone002/Bone003/Bone004/Bone005/Bone006/Bone007/Bone008/Point001")

            self.HelpObj= self.RodStartObj.transform:Find("HelpObj")
            self.StartBiteObj= self.HelpObj.transform:Find("StartBite")
            self.StartMoveObj= self.HelpObj.transform:Find("StartMove")
            self.PullUpObj= self.HelpObj.transform:Find("PullUp")
            self.LineObj= self.HelpObj.transform:Find("Line")
            self.LureObj= self.HelpObj.transform:Find("Lure")
            self.FishEffectsObj= self.RodStartObj.transform:Find("FishEffects")
            self.FishPrefabObj = self.FishEffectsObj.transform:Find("FishPrefab")
            self.EnterWaterEffectObj= self.FishEffectsObj.transform:Find("EnterWaterEffectObj")
            self.CritEffectObj = self.FishEffectsObj.transform:Find("CritEffectObj")
            self.JumpOutEffectObj= self.FishEffectsObj.transform:Find("JumpOutEffectObj")
            self.MoveEffectObj= self.FishEffectsObj.transform:Find("MoveEffect")
            self.PullUpEffectObj= self.FishEffectsObj.transform:Find("PullUpEffect")
            self.WaitEffect= self.FishEffectsObj.transform:Find("WaitEffect")
            self.LureEnterWaterEffect = self.FishEffectsObj.transform:Find("LureEnterWaterEffect")
            
            self.BoxHead= self.RodStartObj.transform:Find("Box/BoxHead")
            self.AdBox= self.BoxHead.transform:Find("Box_01")
            self.NormalBox= self.BoxHead.transform:Find("Box_01")
            self.BoxStart= self.RodStartObj.transform:Find("Box/BoxStart")
            self.BoxEnd= self.RodStartObj.transform:Find("Box/BoxEnd")
            self:InitFishes(config)
            self:InitLogicScript()
        end
        
    end
    self.startObjHandle = GameObjectManager:GetFromPool(GameObjectManager.FightFishesPoolName,"Prefabs/FishHelp/RodStartObj.prefab",loadCb)
end

-- 背景音乐
function FishingLevelLogic:PlayBgMusic()
    local _, curSeaCfg = PlayerDatas.SeaData:GetCurSea()
    if curSeaCfg then
        AudioManager.PlayerBgAudio(curSeaCfg.Audio)
    end
    AudioManager.PlayerLoopEAX(50)
end

function FishingLevelLogic:SetEffectsActive(bool)
    if self.EnterWaterEffectObj then
        self.EnterWaterEffectObj.gameObject:SetActive(bool)
    end
    if self.JumpOutEffectObj then
        self.JumpOutEffectObj.gameObject:SetActive(bool)
    end
    if self.MoveEffectObj then
        self.MoveEffectObj.gameObject:SetActive(bool)
    end
end

function FishingLevelLogic:LoadAll(config)
    self.ToolsPos = GameObject.Find("FishToolsPos");
    if self.ToolsPos == nil then
        return
    end
    self:InitObject(config)
    self:PlayBgMusic(config)
end

function FishingLevelLogic:OnBottomListFold(fold, duration)
    if (fold) then
        self.cameraSwitch:RevertOrigin(duration or 0.3)
    else
        self.cameraSwitch:Switch(UIUtils.ViewHeightUnfold / UIUtils.ViewHeightFold, duration or 0.3, 103)
    end
end

function FishingLevelLogic:StageClick(touchPos)
    local obj = LuaUtils.ScreenHitGameObject(touchPos)
    if obj and obj.tag == "Box" then
        self.IsBox = true
        if self.IsAd then
            AnalyticsManager.onADButtonShow("激励视频", "漂流宝箱_钓鱼", "漂流宝箱")
            UIManager.OpenUI(UIInfo.ItemPopupUI, nil, nil, "AdBox", PlayerData.Datas.FishData:AdBoxRewardCount(), function(ad)
                if ad then
                    SDKManager:PlayAD(function()
                        PlayerData.Datas.FishData:GetAdBoxReward()
                    end, "漂流宝箱_钓鱼", "漂流宝箱")
                end
            end)
        else
            self:SetFishesActive()
            self.FishLogicScript:BoxModeStart()
            UIManager.OpenUI(UIInfo.FishFightUI,nil,nil,self.FishLogicScript:GetBoxAngle()):next(
            function()
                self.cameraSwitch:RevertOrigin(0)
            end)
        end
        
    end
end

function FishingLevelLogic:CreateNormalBox()
    self.FishLogicScript:CreateNormalBox()
    self.IsAd = false
end

function FishingLevelLogic:CreateAdBox()
    self.FishLogicScript:CreateAdBox()
    self.IsAd = true
end

local function Click(touchPos)
    EventDispatcher:Dispatch(Event.FISH_STAGE_CLICK,touchPos)
end

local function Touch(touchPos)
    EventDispatcher:Dispatch(Event.FISH_STAGE_TOUCH, touchPos)
end

-- 加载场景
function FishingLevelLogic:load(data, callback)
    if data == nil then
        callback()
        return
    end
    local config = SeaConfig.SeasByID[data.seaId]
    data.sceneName = config and config.Scene or data.sceneName
    self:super("load", data, function()
        -- TODO 加载资源
        self:LoadAll(config)
        
        EventDispatcher:Add(Event.BOTTOM_LIST_FOLD, self.OnBottomListFold, self)
        self.cameraSwitch = CS.UnityEngine.Camera.main.gameObject:EnsureComponent(typeof(CS.FishCameraSwitch))
        self.cameraController = CS.UnityEngine.Camera.main.gameObject:EnsureComponent(typeof(CS.CameraController))
        self:OnBottomListFold(PlayerData.bottomListFolded, 0)
        callback()
    end)
    EventDispatcher:Add(Event.FISH_THROW, self.Throw, self)
    EventDispatcher:Add(Event.FISH_PLAYER_TOUCHBEGIN, self.PlayerTouchBegin, self)
    EventDispatcher:Add(Event.FISH_PLAYER_TOUCHEND, self.PlayerTouchEnd, self)
    EventDispatcher:Add(Event.FISH_CRIT_SUCCESS, self.CritSuccess, self)
    EventDispatcher:Add(Event.FISH_UNLOCK, self.FishFight, self)
    EventDispatcher:Add(Event.FISH_FIGHT_END, self.AutoFishStart,self)
    EventDispatcher:Add(Event.FISH_CALL_UI, self.FishCallUI,self)
    EventDispatcher:Add(Event.FISH_UPDATE_HP, self.UpdateHp, self)
    EventDispatcher:Add(Event.FISH_CRITDAMAGE, self.CritDamage, self)
    CS.LPCFramework.EasyTouchManager.Instance:OnTouchClick("+", Click)
    EventDispatcher:Add(Event.STAGE_ON_TOUCH_MOVE, Touch)
    EventDispatcher:Add(Event.FISH_STAGE_CLICK, self.StageClick, self)
    -- EventDispatcher:Add(Event.FISH_CREATE_NORMALBOX, self.CreateNormalBox, self)
    -- EventDispatcher:Add(Event.FISH_CREATE_ADBOX, self.CreateAdBox, self)
    EventDispatcher:Add(Event.FISH_RESULT, self.RandomFishResult, self)
end

local function UnloadFish(fish)
    GameObjectManager:ReturnToPool(GameObjectManager.FightFishesPoolName, fish)
end

function FishingLevelLogic:UnRegister()
    EventDispatcher:Remove(Event.BOTTOM_LIST_FOLD, self.OnBottomListFold, self)
    EventDispatcher:Remove(Event.FISH_THROW, self.Throw, self)
    EventDispatcher:Remove(Event.FISH_PLAYER_TOUCHBEGIN, self.PlayerTouchBegin, self)
    EventDispatcher:Remove(Event.FISH_PLAYER_TOUCHEND, self.PlayerTouchEnd, self)
    EventDispatcher:Remove(Event.FISH_CRIT_SUCCESS, self.CritSuccess, self)
    EventDispatcher:Remove(Event.FISH_UNLOCK, self.FishFight, self)
    EventDispatcher:Remove(Event.FISH_FIGHT_END, self.AutoFishStart,self)
    EventDispatcher:Remove(Event.FISH_CALL_UI, self.FishCallUI,self)
    EventDispatcher:Remove(Event.FISH_UPDATE_HP, self.UpdateHp, self)
    EventDispatcher:Remove(Event.FISH_CRITDAMAGE, self.CritDamage, self)
    EventDispatcher:Remove(Event.FISH_STAGE_CLICK, self.StageClick, self)
    -- EventDispatcher:Remove(Event.FISH_CREATE_NORMALBOX, self.CreateNormalBox, self)
    -- EventDispatcher:Remove(Event.FISH_CREATE_ADBOX, self.CreateAdBox, self)
    EventDispatcher:Remove(Event.FISH_RESULT, self.RandomFishResult, self)
    EventDispatcher:Remove(Event.STAGE_ON_TOUCH_MOVE, Touch)
    CS.LPCFramework.EasyTouchManager.Instance:OnTouchClick("-", Click)
end

function FishingLevelLogic:onDeactive()
    Time.timeScale = 1
    self:UnloadAll()
    self:SetEffectsActive(false)
    self:UnRegister()
end

function FishingLevelLogic:UnloadAll()
    if self.fishes then
        for _,fish in pairs(self.fishes) do
            UnloadFish(fish)
        end
        self.fishes = nil
    end
    self.Rope = nil
    self.FishLogicScript = nil
    self.SelectKey = nil
    if self.RodStartObj then
        GameObjectManager:ReturnToPool(GameObjectManager.FightFishesPoolName, self.RodStartObj)
        self.RodStartObj = nil
    end
end

function FishingLevelLogic:reload(...)
    self:UnloadAll()
    self:UnRegister()
    self:load(...)
end
-- 退出场景
function FishingLevelLogic:unload()
    self:super("unload", self)
    self:UnloadAll()
    self:UnRegister()
end

function FishingLevelLogic:Create3dUI()
    local tag = GameObject("tag")
    local uipanel = nil
    tag:AddComponent(typeof(CS.LookAtCamera)).isReverse = false
    uipanel = tag:AddComponent(typeof(CS.FairyGUI.UIPanel))
    uipanel.packageName = "FishFightTemp"
    uipanel.componentName  = "Hub"
    uipanel.ui.container.renderMode = UnityEngine.RenderMode.WorldSpace
    uipanel.ui.container.renderCamera = CS.Camera.main
    uipanel.ui.container.fairyBatching = true
    -- UIUtils.SetHudShader(uipanel.ui)
    uipanel.ui.visible = false
    self.hpBar = uipanel.ui:GetChild("Bar")
    self.redhpBar = self.hpBar:GetChild("bar2")
    self.damageText = uipanel.ui:GetChild("text"):GetChild("text")
    -- self.Effect =  uipanel.ui:GetTransition("Effect")
    self.State_C =  uipanel.ui:GetController("state_c")
    self.Effects = self.hpBar:GetTransition("Effect_E")
    self.Texts = self.hpBar:GetChild("HPTitle")
    self.hpBar.visible = false
    self.redhpBar.visible = false
    self.damageText.visible = false
    self.uipanel = uipanel
end

-- 切换模式 手动/自动
function FishingLevelLogic:ChangePlaymode(playmodeFishId)
    if self.FishLogicScript == nil then
        return
    end
    self.IsBox = false
    if playmodeFishId then
        
        local model,scale = fishData:GetFightFishModelAndScale(playmodeFishId)
        local fishCfg = FishConfig.FishesByID[playmodeFishId]
        self.HunterKey =  playmodeFishId.."_"..scale 
        self.SelectKey = (fishCfg.Hunter and self.DefautFish or playmodeFishId) .."_".. scale
        
        local selectFishCfg = FishConfig.FishesByID[fishCfg.Hunter and self.DefautFish or playmodeFishId]
        local playConfig = fishCfg and PlayerDisplayConfig.PlayerDisplayByID[fishCfg.PlayerDisplayId]
        if fishCfg.Hunter then
            self.SelectKey = (self.EatedFish or self.DefautFish).."_".. 1
            selectFishCfg = FishConfig.FishesByID[self.EatedFish or self.DefautFish]
        end
        self:SetFishesActive()
        self.FishLogicScript:SetFishInstance(self.fishes[self.SelectKey],selectFishCfg.MousePath)
        if fishCfg.Hunter then
            self.FishLogicScript:SetHunterInstance(self.fishes[self.HunterKey],fishCfg.MousePath)
        end
        self.DamageHitUnit = playConfig.DamageHitTime
        self.FishLogicScript:SetUpdateUIHp(UpdateUIHp, self.DamageHitUnit)
        self.Damage = playConfig.NormalDamage*self.DamageHitUnit
        self.LastHp = playConfig.Hp
        self.FishLogicScript:PlayModeStart(playConfig.Hp,playConfig.NormalDamage,
        playConfig.EventHpPers,playConfig.EventTypes,playConfig.EventDamages,Vector3(playConfig.Xoffset,playConfig.Yoffset,playConfig.Zoffset)*scale*self.FixScale)

        local _, curSeaCfg = PlayerDatas.SeaData:GetCurSea()

        AnalyticsManager.onStartPlay("手动钓鱼", playmodeFishId, 0)
        UIManager.OpenUI(UIInfo.FishFightUI,nil,nil,nil, self.itemFish, playConfig):next(
            function()
                self.cameraSwitch:RevertOrigin(0)
                -- 3d中ui使用的资源与该ui界面中一致，所以不再引用一遍
                self:Create3dUI()
                -- 已经删除 移动到3d界面
                self:SetHpBarMax(playConfig.Hp)
            end
        )
    else
        self:OnBottomListFold(PlayerData.bottomListFolded, 0)
        self.FishLogicScript:AutoFishStart()
    end
end

function FishingLevelLogic:StopSeaBg()
    AudioManager.PauseBGAudio()
end

function FishingLevelLogic:StratFightBG()
    AudioManager.PlayerBgAudio(40)
end

function FishingLevelLogic:FishFight(playmodeFishId,itemFish)
    self.FishId = playmodeFishId
    self.itemFish = itemFish
    self.IsPlayer = true
    self:ChangePlaymode(playmodeFishId)
    self:StopSeaBg()
end

-- 抛竿
function FishingLevelLogic:Throw(vetcor3)
    local vetcor = Vector3()
    self.FishLogicScript:PlayerThrow(vetcor)
    self:PlayAudio(FishStateEnum.Throw)
end

function FishingLevelLogic:PlayerTouchBegin()
    self.FishLogicScript:PlayerTouchBegin()
    self.powerAudioId = isHighPower and 3006 or 3005
    AudioManager.PlayEAXSound(self.powerAudioId, true)
end

function FishingLevelLogic:PlayerTouchEnd()
    self.FishLogicScript:PlayerTouchEnd()
    AudioManager.StopEAXSound(self.powerAudioId)
end

function FishingLevelLogic:CritSuccess()
    self.FishLogicScript:CritSuccess()
end

return FishingLevelLogic