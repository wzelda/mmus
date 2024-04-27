local AquariumLevelLogic = class(require "LevelLogic.LevelLogic")
local DecorationConfig = Utils.LoadConfig("Config.DecorationConfig")
local FishConfig = Utils.LoadConfig("Config.FishConfig")
local AquariumConfig = Utils.LoadConfig("Config.AquariumConfig")

local XUtils = require("Common.XUtils")
local yield_return = (require 'Common.XCoroutine').yield_return
local unpack = unpack or table.unpack

local function ToVector3(t)
    return Vector3(unpack(t))
end

-- 卸载鱼
local function UnloadFish(fish)
    if fish.model then
        GameObjectManager:ReturnToPool(GameObjectManager.AquariumFishesPoolName, fish.model)

        if fish.animHandle then 
            ResourceMgr:Release(fish.animHandle)
        end

        if fish.bTreeHandle then 
            ResourceMgr:Release(fish.bTreeHandle)
        end
    end
end

-- TODO 把鱼类加载卸载独立出来
local function LoadFishAI(fish, aiRes, cb)
    local loadCb = function(obj)
        local bTree = fish.model:EnsureComponent(typeof(CS.BehaviorDesigner.Runtime.BehaviorTree))
        fish.bTree = bTree
        bTree.StartWhenEnabled = false
        bTree.PauseWhenDisabled = true
        bTree.RestartWhenComplete = false
        bTree.ResetValuesOnRestart = false
        bTree.ExternalBehavior = obj
        bTree:EnableBehavior()

        if(cb)then
            cb()
        end
    end
    fish.bTreeHandle = ResourceMgr:Load(ConstantValue.BehaviorTreeResFolder .. aiRes, loadCb)
end

local function LoadFishAnim(fish, animRes, cb)
    local  animator = fish.model:GetComponentInChildren(typeof(CS.UnityEngine.Animator))

    local loadCb = function(obj)
        animator.applyRootMotion = false
        animator.runtimeAnimatorController = obj
        if cb then cb() end
    end

    fish.animHandle = ResourceMgr:Load("Animations/"..animRes, loadCb)
end

local function fishFallPosition(target, mainCamera)
    local fishPoint = GameObject.Find("Scene/Fish_Point")
    if fishPoint then
        return fishPoint.transform.position
    end

    mainCamera = mainCamera or CS.UnityEngine.Camera.main
    local ray = UIUtils.ViewCenterToRay(mainCamera)
    
    local d = Vector3.Distance(mainCamera.transform.position, target.transform.position) / 2

    return ray:GetPoint(d)
end

-- 加载鱼类
function AquariumLevelLogic:LoadFish(id, Grade, showEffect)
    local fishModelKey,scale = PlayerData.Datas.FishData:GetFishModelAndScale(id, Grade)
    local fishModel = FishConfig.FishModelsByID[fishModelKey]

    if fishModel == nil then
        Utils.DebugError("Invalid fish model "..fishModelKey.." fish:"..tostring(id).." grow:"..tostring(Grade))
        return
    end

    local fish = {}
    self.fishes[fish] = false
    GameObjectManager:GetFromPool(GameObjectManager.AquariumFishesPoolName, "Prefabs/Fishes/"..fishModel.ID..".prefab", function(fishObj)
        if self.fishes[fish] == nil then
            GameObjectManager:ReturnToPool(GameObjectManager.AquariumFishesPoolName, fishObj)
            return
        end
        fish.model=fishObj
        local t = fishObj.transform
    
        fishObj:SetActive(false)
        t.parent = nil
        t.localScale = ConstantValue.V3One * fishModel.Scale * scale * self.config.Scale
        Utils.SetLayer(fishObj, LayerMask.NameToLayer("Fish"))

        LoadFishAnim(fish, fishModel.SwimAnim, function()
            if self.fishes[fish] == nil then
                UnloadFish(fish)
                return
            end

            fish.moveController = fishObj:EnsureComponent(typeof(CS.FishAI.FishMoveController))
            fish.fishAI = fishObj:EnsureComponent(typeof(CS.FishAI.Fish))

            fish.fishAI._minAnimationSpeed = 0.1
            fish.fishAI._maxAnimationSpeed = fishModel.Speed
            fish.moveController._speedRange = CS.FishBehavior.MyRange(0.1, fishModel.Speed)
            fish.moveController._speedFactor = self.config.Scale
            fish.moveController._turnSpeedWeight = CS.FishBehavior.MyRange(fishModel.TurnSpeed / 2, fishModel.TurnSpeed)
            fish.moveController._escapeSpeed = fishModel.Speed * self.config.Scale * 4

            LoadFishAI(fish, fishModel.SwimAI, function()
                if self.fishes[fish] == nil then
                    UnloadFish(fish)
                    return
                end
                self.fishes[fish] = true
                fishObj:SetActive(true)
    
                if showEffect then
                    --fishObj.transform.position = fishFallPosition(self.aquariumTank)
                    fish.moveController:StartFallDown(fishFallPosition(self.aquariumTank))
                    self:ShowEffect(self.effectPutFish, nil, t.position, 0.3 * fishModel.Size * scale * self.config.Scale, t)
                    --震动
                    AudioManager.Vibrate()
                else
                    fishObj.transform.position = self.aquariumTank:RandomPosition()
                end
            end)
        end)
    end)
end

local function UnloadEffect(effect)
    if effect.gameobject then
        GameObjectManager:ReturnToPool("AquariumEffectUnlock", effect.gameobject)
        effect.gameobject = nil
    end
end

function AquariumLevelLogic:ShowEffect(effect, parent, position, size, followTarget)
    size = size or 1

    if effect.gameobject then
        effect.gameobject:SetActive(false)
        effect.gameobject.transform.parent = parent
        effect.gameobject.transform.localPosition = position
        effect.gameobject.transform.localScale = Vector3(size, size, size)
        effect.gameobject:SetActive(true)
        if followTarget then
            CS.FollowTarget.AddFollowTarget(effect.gameobject.transform, followTarget)
        end
    elseif self.effects[effect] == nil then
        self.effects[effect] = false
        GameObjectManager:GetFromPool("AquariumEffectUnlock", effect.path, function(go)
            if self.effects[effect] == nil then
                GameObjectManager:ReturnToPool("AquariumEffectUnlock", go)
                return
            end
    
            self.effects[effect] = true
            go:SetActive(false)
            effect.gameobject = go
            
            go.transform.parent = parent
            go.transform.localPosition = position
            go.transform.localScale = Vector3(size, size, size)

            if followTarget then
                CS.FollowTarget.AddFollowTarget(effect.gameobject.transform, followTarget)
            end

            go:SetActive(true)
        end)
    end
end

-- 装饰物镜头动画
function AquariumLevelLogic:PlayEffectSequence(...)
    if self.effectQueue == nil then
        self.effectQueue = {}
    end
    
    table.insert(self.effectQueue, {...})

    if #self.effectQueue == 1 then
        self.cameraSwitch:StartCoroutine(XUtils.cs_generator(function()
            local lastItem
            while #self.effectQueue > 0 do
                local target, effect, cfg, scale = unpack(self.effectQueue[1])
                local go = target.gameObject
                if lastItem ~= cfg then
                    lastItem = cfg
                    self.cameraSwitch:TweenLookAt(ToVector3(cfg.LookPosition), ToVector3(cfg.LookRotation), 1)
                    coroutine.yield(CS.UnityEngine.WaitForSeconds(1))
                end

                self:ShowEffect(effect, self.decorationRoot, ToVector3(cfg.EffectPosition), cfg.ModelSize * scale)

                -- 如果没解锁
                if not go.activeSelf then
                    go:SetActive(true)
                end
                target.localScale = Vector3(scale, scale, scale)

                local waitTime = 0
                -- 等待队列
                while waitTime < 0.5 and #self.effectQueue == 1 do
                    coroutine.yield()
                    waitTime = waitTime + Time.deltaTime
                end
                table.remove(self.effectQueue, 1)
            end

            if #self.effectQueue == 0 then
                -- 还原镜头
                self.cameraSwitch:RevertOriginPosition(1)
            end
        end))
    end
end

-- 显示装饰物
function AquariumLevelLogic:ShowDecoration(id, visible, showEffect, callback)
    local cfg = DecorationConfig.DecorationsByID[id]
    local decoration = PlayerDatas.DecorationData:GetDecoration(id)
    local model,scale = PlayerDatas.DecorationData:GetModelAndScale(decoration, cfg)
    local t = self.decorationRoot:Find(model)
    if not Utils.unityTargetIsNil(t) then
        local go = t.gameObject
        -- 特效展示
        if showEffect and visible then
            self:PlayEffectSequence(t, self.effectUnlockItem, cfg, scale)
            TimerManager.waitTodo(2, 1, function()
                if callback then callback() end
            end)
        else
            go:SetActive(visible)
            if callback then callback() end
        end
    else
        Utils.DebugError("can't find decoration object "..model)
        if callback then callback() end
    end
end

-- 显示所有已解锁展示项目
function AquariumLevelLogic:ShowItems()
    local aquariumData = PlayerData.Datas.AquariumData
    local aquaraium = aquariumData:GetCurAquarium()

    for _,v in ipairs(AquariumConfig.GetShowList(aquaraium.ID)) do
        if aquaraium.openItems[v.ID] then
            if v.Type == CommonItemType.Decoration then
                self:ShowDecoration(v.ItemID, true)
            elseif v.Type == CommonItemType.Fish then
                self:LoadFish(v.ItemID, v.Grade)
            end
        else
            if v.Type == CommonItemType.Decoration then
                self:ShowDecoration(v.ItemID, false)
            end
        end
    end
end

-- 解锁展示项目事件回调
function AquariumLevelLogic:ShowItem(showItem)
    if type(showItem) == "number" then
        local AquariumConfig = Utils.LoadConfig("Config.AquariumConfig")
        showItem = AquariumConfig.ShowItemsByID[showItem]
    end

    if showItem.Type == CommonItemType.Decoration then
        self:ShowDecoration(showItem.ItemID, true, true, function()
            -- 弹出新发现奖励， TODO 此处应该加个延迟
            if showItem.EnableAD then
                AnalyticsManager.onADButtonShow("激励视频", "新的发现_装饰物", "新的发现")
            end
            UIManager.OpenUI(UIInfo.ItemPopupUI, nil, nil, "DecorationReward", showItem, function(ad)
                if showItem.EnableAD and ad then
                    SDKManager:PlayAD(function()
                        PlayerData.Datas.AquariumData:DiscoverDecorationReward(showItem,true)
                        EventDispatcher:Dispatch(Event.ITEMPOP_GETREWARD, showItem.RewardType == CommonRewardType.Diamond and 2 or 1 )
                    end, "新的发现_装饰物", "新的发现")
                else
                    PlayerDatas.AquariumData:DiscoverDecorationReward(showItem)
                    EventDispatcher:Dispatch(Event.ITEMPOP_GETREWARD, showItem.RewardType == CommonRewardType.Diamond and 2 or 1 )
                end
            end)
        end)
    elseif showItem.Type == CommonItemType.Fish then
        self:LoadFish(showItem.ItemID, showItem.Grade, true)
    end
end

function AquariumLevelLogic:OnBottomListFold(fold, duration)
    if (fold) then
        self.cameraSwitch:RevertOrigin(duration or 0.3)
    else
        self.cameraSwitch:Switch(UIUtils.ViewHeightUnfold / UIUtils.ViewHeightFold, duration or 0.3, 103)
    end
end

function AquariumLevelLogic:OnMainUIShow()
    self:OnBottomListFold(PlayerData.bottomListFolded, 0)
end

function AquariumLevelLogic:OnMainUIHide()
    self.cameraSwitch:RevertOrigin(0)
end

-- 装饰物升级特效
function AquariumLevelLogic:OnDecorationLevelup(decoration, cfg)
    local model,scale = PlayerDatas.DecorationData:GetModelAndScale(decoration, cfg)
    local t = self.decorationRoot:Find(model)
    if not Utils.unityTargetIsNil(t) then
        self:PlayEffectSequence(t, self.effectUnlockItem, cfg, scale)
    end
end

-- 装饰物成长
function AquariumLevelLogic:OnDecorationGrow(decoration, cfg)
    local model,scale = PlayerDatas.DecorationData:GetModelAndScale(decoration, cfg)
    local t = self.decorationRoot:Find(model)
    if not Utils.unityTargetIsNil(t) then
        self:PlayEffectSequence(t, self.effectUnlockItem, cfg, scale)
    end
end

-- 加载场景
function AquariumLevelLogic:load(data, callback)
    self.config = data.config
    self:UnloadAllFish()
    self:UnloadAllEffects()
    self:super("load", data, function()
        -- TODO 加载展示资源
        self.aquariumTank = GameObject.Find("AquariumTank"):GetComponent(typeof(CS.FishAI.Aquarium))
        self.decorationRoot = GameObject.Find("Decorations").transform

        if CS.UnityEngine.PlayerPrefs.GetInt("EnableDrag") == 1 then
            self.aquariumTank:EnableDrag()
        else
            self.aquariumTank:DisableDrag()
        end

        self:ShowItems()

        self.effectUnlockItem = {path="Prefabs/Particle/Eff_sce_shengji.prefab"}
        self.effectPutFish = {path="Prefabs/Particle/waibao/Eff_Aquarium_Born_bubble.prefab"}
        callback()

        EventDispatcher:Add(Event.AQUARIUM_SHOW_ITEM, self.ShowItem, self)
        EventDispatcher:Add(Event.BOTTOM_LIST_FOLD, self.OnBottomListFold, self)
        EventDispatcher:Add(Event.MAIN_UI_SHOW, self.OnMainUIShow, self)
        EventDispatcher:Add(Event.MAIN_UI_HIDE, self.OnMainUIHide, self)
        EventDispatcher:Add(Event.AQUARIUM_LEVELUP_DECORATION, self.OnDecorationLevelup, self)

        self.cameraSwitch = CS.UnityEngine.Camera.main.gameObject:EnsureComponent(typeof(CS.FishCameraSwitch))
        self.cameraController = CS.UnityEngine.Camera.main.gameObject:EnsureComponent(typeof(CS.CameraController))

        self:OnBottomListFold(PlayerData.bottomListFolded, 0)
        self.cameraSwitch:RevertOriginPosition(0)
        AudioManager.StopEAXSound(50)
        AudioManager.PlayerLoopEAX(55)
    end)
end

function AquariumLevelLogic:onDeactive()
    self.effectQueue = {}

    EventDispatcher:Remove(Event.BOTTOM_LIST_FOLD, self.OnBottomListFold, self)
    EventDispatcher:Remove(Event.AQUARIUM_SHOW_ITEM, self.ShowItem, self)
    EventDispatcher:Remove(Event.MAIN_UI_SHOW, self.OnMainUIShow, self)
    EventDispatcher:Remove(Event.MAIN_UI_HIDE, self.OnMainUIHide, self)
    EventDispatcher:Remove(Event.AQUARIUM_LEVELUP_DECORATION, self.OnDecorationLevelup, self)
    self:UnloadAllFish()
    self:UnloadAllEffects()
    AudioManager.StopEAXSound(55)
    AudioManager.PlayerLoopEAX(50)
end

function AquariumLevelLogic:UnloadAllFish()
    if self.fishes ~= nil then
        for fish,_ in pairs(self.fishes) do
            UnloadFish(fish)
        end
    end
    self.fishes = {}
end

function AquariumLevelLogic:UnloadAllEffects()
    if self.effects ~= nil then
        for effect,_ in pairs(self.effects) do
            UnloadEffect(effect)
        end
    end
    self.effects = {}
end

-- 退出场景
function AquariumLevelLogic:unload()
    self:super("unload")
    EventDispatcher:Remove(Event.AQUARIUM_SHOW_ITEM, self.ShowItem, self)
    self:UnloadAllFish()
    self:UnloadAllEffects()
end

return AquariumLevelLogic