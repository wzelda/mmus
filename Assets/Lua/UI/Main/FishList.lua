
-- 钓鱼界面的鱼类列表
local FishConfig = Utils.LoadConfig("Config.FishConfig")
local DependManager = require ("Manager.DependManager")

local FishList = {}

local fishes
local sea
local fishOpenCount
local fishData
local timer = nil
local lastTimeUi = nil
local incomeFactor
local redDots = {}
local levelUpEffects = {}
local isadd

local function LevelupShow(itemFish,btn)
    UIManager.ShowEffect(ClickEffectType.Gold,btn:LocalToRoot(btn.size / 2), UISortOrder.ClickEffect)
    PlayerData.Datas.FishData:LevelupFish(itemFish.productConfig.ItemID)
end

local function TiggerBox()
    -- if fishData:CanCreateAdBox() then
    --     EventDispatcher:Dispatch(Event.FISH_CREATE_ADBOX)
    -- elseif fishData:CanCreateNormalBox() then
    --     EventDispatcher:Dispatch(Event.FISH_CREATE_NORMALBOX)
    -- end
end
local function Unlock(itemFish)
    EventDispatcher:Dispatch(Event.FISH_UNLOCK,itemFish.productConfig.ItemID,itemFish)
end

local function AdUnlock(itemFish)
    SDKManager:PlayAD(function()
        PlayerData.Datas.FishData:AddFish(itemFish.productConfig.ItemID)
    end)
end


local function Grow(itemFish)
    local lastGrowth = itemFish.fish.growth
    PlayerData.Datas.FishData:FishGrow(itemFish.productConfig.ItemID)
    if itemFish.fish.growth ~= lastGrowth then
        UIManager.OpenUI(UIInfo.FishGrowthUI, nil, nil, "GrowUpFish", itemFish, function()
            PlayerData.Datas.FishData:FishGrow(itemFish.productConfig.ItemID)
        end)
    end
end

local function GetMinutes(t)
    ---以15分钟为单位 900秒
    t = math.ceil( t/900 )
    return LocalizeExt("TimeUnlockDesc",{t*15})
end

local function itemRender(index, ui)
    index = index + 1
    local itemFish = fishes[index]
    local buyBtn = ui:GetChild("Button_Buy")
    local Type_C = ui:GetController("Type_C")
    local uiicon = ui:GetChild("icon")
    local Type_P = ui:GetController("Type_P")
    local graph = ui:GetChild("Garph")
    local Effect_Lv = ui:GetTransition("Effect_Lv")
    UIUtils.SetControllerIndex(Type_P, itemFish.fishConfig.Quality)
    uiicon.onClick:Clear()
    local reddot = ReddotManger:CreateEffect(RedDotType.FishItemBtn,AnchorType.Center,buyBtn)
    redDots[buyBtn] = reddot
    local clickAction
    local bar = ui:GetChild("Bar")
    ui:GetChild("Text_Quality").text = Localize("Quality" .. tostring(itemFish.fishConfig.Quality))
    local txtDesc = ui:GetChild("Text_Desc")
    if index > fishOpenCount + 1 then
        -- 未发现
        ui:GetController("State_C").selectedIndex = 1
        ui:GetController("Type_C").selectedIndex = 4
        ui:GetController("Status_C").selectedIndex = 1
        ui:GetChild("title").text = "???"
        txtDesc.text = Localize("CannotUnlock") 
        txtDesc.grayed = true
    else
        ui:GetChild("title").text = itemFish.fishConfig.Name 
        
        if index <= fishOpenCount then
            -- 已解锁
            ui:GetController("State_C").selectedIndex = 0
            ui:GetController("Type_C").selectedIndex = 0
            ui:GetController("Status_C").selectedIndex = 0
            CommonUIUtils.SetTextByQuality(ui:GetChild("title"), itemFish.fishConfig.Name, itemFish.fishConfig.Quality)
            
            ui:GetChild("icon").icon = "ui://Library/"..itemFish.fishConfig.Icon
            ui:GetChild("icon").grayed = false
            local income = fishData:GetFishIncome(itemFish.fish, incomeFactor, itemFish.fishConfig)
            ui:GetChild("Label_Income").text = Utils.GetCountFormat(income).. Localize("UnitSeconds")
            local value,max,isMaxLv = fishData:GetUpProgress(itemFish.fish, itemFish.fishConfig)
            local maxGrowth = itemFish.fish.growth == FishGrowthEnum.Large
            bar.max = max
            bar.value = value
            ui:GetController("Status_C").selectedIndex = 0
            if value >= max then
                -- 已满级
                if isMaxLv and maxGrowth then
                    ui:GetController("Type_C").selectedIndex = 3
                    ui:GetChild("Text_Full").text = Localize("LevelUpFull")
                else
                    clickAction = "grow"
                    ui:GetController("Type_C").selectedIndex = 8
                    buyBtn:GetChild("Text_Unlock").text = Localize("Growth") 
                end
            else
                local cost,batch = fishData:GetLvlUpCostBatch(value, itemFish.fishConfig)
                
                if batch == 0 then
                    ui:GetController("Type_C").selectedIndex = 2
                    buyBtn.title = LocalizeExt("UpgradeButtonBatch", {1})
                    buyBtn:GetChild("Label_Icon").text = Utils.GetCountFormat(fishData:GetLvlUpCost(value, itemFish.fishConfig))
                    clickAction = "tiggerBox"
                else
                    clickAction = "levelup"
                    ui:GetController("Type_C").selectedIndex = 0
                    buyBtn.title = LocalizeExt("UpgradeButtonBatch", {batch})
                    buyBtn:GetChild("Label_Icon").text = Utils.GetCountFormat(cost)
                end
            end
            ui:GetChild("Text_Lev").text = '【'..LocalizeExt("Level",{value})..'】'

            local fishModelKey, scale = PlayerDatas.FishData:GetFishModelAndScale(itemFish.fishConfig.ID, itemFish.fish.growth)
            local fishModel = FishConfig.FishModelsByID[fishModelKey]
            local fishModelPath = fishModel and "Prefabs/Fishes/"..fishModel.ID..".prefab"
            local popdata = {}
            popdata.modelPath = fishModelPath
            popdata.data = itemFish.fishConfig
            uiicon.onClick:Set(function ()
                UIManager.OpenPopupUI(UIInfo.ShowFishInfoUI, popdata)
            end)
        else
            ui:GetController("State_C").selectedIndex = 1
            ui:GetController("Status_C").selectedIndex = 1
            ui:GetChild("Text_Condition").text = Localize("UnlockRequire")
            -- 依赖条件判定
            local readyCount = 0
            local depends = DependManager.GetDepends(itemFish.fishConfig.Depends)
            for i,v in ipairs(depends) do
                local depText = ui:GetChild("Text_Dep"..tostring(i))
                local depState_C = depText:GetController("state_C")
                local ready = DependManager.CheckDependency(v)
                
                if depText then
                    depText.title = v.title
                    depText.grayed = not ready
                    depState_C.selectedIndex = ready and 1 or 0
                    depText.visible = true
                end

                if ready then
                    readyCount = readyCount + 1
                end
            end

            for i=#depends+1,4,1 do
                local depText = ui:GetChild("Text_Dep"..tostring(i))
                if depText then
                    depText.visible = false
                end
            end
            
            CommonUIUtils.SetTextByQuality(ui:GetChild("title"), itemFish.fishConfig.Hunter and itemFish.fishConfig.NickName or itemFish.fishConfig.Name, itemFish.fishConfig.Quality)
            
            if readyCount < #depends then
                ui:GetController("Status_C").selectedIndex = 2
                ui:GetController("Type_C").selectedIndex = 4
            elseif (TimerManager.getCurrentClientTime() - fishData.lastUnlockTime) >= itemFish.productConfig.CostTime then
                ui:GetController("Type_C").selectedIndex = 6
                --txtDesc.text = Localize("WaitUnlock")
                --txtDesc.grayed = false
                buyBtn:GetChild("Text_Unlock").text = Localize("Challenge")
                clickAction = "unlock"
                
                -- 策划老师要求可以解锁的项目要显示进度条 #ID1004160
                ui:GetController("Status_C").selectedIndex = 0
                ui:GetChild("Label_Income").text = Utils.GetCountFormat(0)..Localize("UnitSeconds")
                ui:GetChild("Text_Lev").text = '【'..LocalizeExt("Level", {0})..'】'
                local bar = ui:GetChild("Bar")
                bar.max = 100
                bar.value = 0
            else
                -- 正在解锁中
                if itemFish.productConfig.ADUnlock then
                    ui:GetController("Type_C").selectedIndex = 1
                    buyBtn:GetChild("Text_Desc").text = Localize("UnlockRightNow")
                    clickAction = "adUnlock"
                else
                    ui:GetController("Type_C").selectedIndex = 4
                end
                ui:GetChild("Text_Desc").text = GetMinutes(TimerManager.getCurrentClientTime() - fishData.lastUnlockTime)
                txtDesc.grayed = true
            end
        end
    end

    if index == 1 then
        CommonUIObjectManager:Add(UIKey.FistFishBtn, buyBtn)
        -- if bar.value < 4 or clickAction == "unlock" then
        --     WeakGuideManager:ShowHang(buyBtn, UIInfo.MainBottomUI)
        -- else
        --     WeakGuideManager:Hide()
        -- end
    end

    reddot:SetConditions(clickAction == "grow" or clickAction == "unlock")
    buyBtn.onClick:Set(function()
        if index == 1 then
            EventDispatcher:Dispatch(Event.CG_CLICK_BTN, UIKey.FistFishBtn)
        end
        if clickAction == "levelup" then
            if levelUpEffects[ui] == nil then
                local function callBack(wrap)
                    levelUpEffects[ui] = wrap
                end
                -- Vector3(0.8, 0.5, 1)
                AudioManager.PlayEAXSound(1001)
                local safeArea = UIUtils.ScreenSafeArea()
                local effectsize =(safeArea.width / UIContentScaler.scaleFactor/1080)
                CommonUIUtils.CreateUIModelFromPool(GameObjectManager.UIEffPoolName,"Prefabs/Particle/waibao/UI/Eff_UI_waibiankuang.prefab",graph,callBack,nil,Vector3((1.5*effectsize),1.35,1))
            else
                levelUpEffects[ui].visible = false
                levelUpEffects[ui].visible = true
            end
            EventDispatcher:Add(Event.SHOW_INCOME, function ()
                    if levelUpEffects[ui] then
                        levelUpEffects[ui].visible = false
                    end 
                end)
            Effect_Lv:Play()
            LevelupShow(itemFish,buyBtn)
        elseif clickAction == "grow" then
            Grow(itemFish)
        elseif clickAction == "unlock" then
            Unlock(itemFish)
        elseif clickAction == "adUnlock" then
            AdUnlock(itemFish)
        elseif "tiggerBox" == clickAction then
            TiggerBox()
            EventDispatcher:Dispatch(Event.LACK_MONEY)
        end
    end)
end



function FishList.SetTimer(index,ui,time)
    time = time or 0
    if time == 0 then
        if ui == lastTimeUi then
            timer.pause()
        end
        return
    end
    local function funcUpdate(f,t)
        ui:GetChild("Text_Desc").text = GetMinutes(t)ui:GetChild("Text_Desc").text = GetMinutes(t)
    end
    local function funcComplete()
        itemRender(index,ui)
    end
    if timer == nil then
        timer = TimerManager.newTimer(time,false,false,nil,funcUpdate,funcComplete)
        timer:start()
    else
        timer:resetMax(time)
        timer.onUpdate = funcUpdate
        timer.onComplete = funcComplete
        timer:start()
    end
end

local function onListScroll()
    -- WeakGuideManager:Hide()
    EventDispatcher:Dispatch(Event.SHOW_INCOME)
end

function FishList.UpdateList(list, seaData, seaID)
    seaID = seaID or seaData.currentSea
    
    list.itemRenderer = itemRender
    if not isadd then
        list.scrollPane.onScroll:Add(onListScroll)
        isadd = true
    end
    fishData  = PlayerData.Datas.FishData
    sea = seaData:GetSea(seaID)
    fishes = {}
    fishOpenCount = seaData:GetFishOpenCount(seaID)
    incomeFactor = PlayerData.Datas.BufferData:GetAllFishFactor()

    for _,v in ipairs(seaData:GetProducts(seaID)) do
        local fish = {
            fishConfig = FishConfig.FishesByID[v.ItemID],
            productConfig = v,
            fish = fishData:GetFish(v.ItemID)
        }
        table.insert(fishes, fish)
    end
    
    list.numItems = #fishes
end

function FishList:Close()
    if timer then
        timer = TimerManager.disposeTimer(timer)
    end
    for k , v in pairs(redDots) do
        v:Destroy()
    end
    if levelUpEffects then
        for k , v in pairs(levelUpEffects) do
            CommonUIUtils.ReturnUIModelToPool(v,GameObjectManager.UIEffPoolName)
        end
        levelUpEffects = {}
    end
end

return FishList