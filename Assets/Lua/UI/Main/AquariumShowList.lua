
-- 观赏馆界面的展示列表
local DecorationConfig = Utils.LoadConfig("Config.DecorationConfig")
local FishConfig = Utils.LoadConfig("Config.FishConfig")
local DependManager = require ("Manager.DependManager")
local AquariumConfig = Utils.LoadConfig("Config.AquariumConfig")

local AquariumShowList = UIManager.PanelFactory(UIInfo.AquariumShowList)


local OpenStatus = {
    Opened = 0, -- 已解锁
    Opening = 1, -- 可以解锁
    Prepare = 2, -- 准备解锁
    Invisible = 3 -- 不可见
}

local panel
local aquarium -- 观赏馆数据
--local aquariumCfg -- 观赏馆配置
local showList -- 展示列表
local incomeFactor -- 收入增益
local levelUpEffects = {}
local isadd

local function OpenShow(showItem, index)
    -- 如果支持广告解锁，弹出广告解锁对话框
    if CommonCostType.IsAD(showItem.info.UnlockType) then
        if showItem.info.UnlockType == CommonCostType.AD then
            -- 调用广告播放
            SDKManager:PlayAD(function()
                PlayerDatas.AquariumData:OpenShowItem(aquarium, showItem, true)
            end)
        else
            UIManager.OpenUI(UIInfo.ItemPopupUI, nil, nil, "AquariumUnlockItem", showItem, function(ad)
                if ad then
                    SDKManager:PlayAD(function()
                        PlayerDatas.AquariumData:OpenShowItem(aquarium, showItem, true)
                    end)
                else
                    PlayerDatas.AquariumData:OpenShowItem(aquarium, showItem)
                end
            end)
        end
    else
        PlayerDatas.AquariumData:OpenShowItem(aquarium, showItem)
    end
end

local function LevelupShow(showItem, btn)
    if showItem.info.Type == CommonItemType.Decoration then
        UIManager.ShowEffect(ClickEffectType.Gold,btn:LocalToRoot(btn.size / 2), UISortOrder.ClickEffect)

        PlayerDatas.DecorationData:LevelupDecoration(showItem.info.ItemID)
    end
end

local function Grow(showItem)
    local lastGrowth = showItem.decoration.growth
    PlayerDatas.DecorationData:DecorationGrow(showItem.info.ItemID)
    if showItem.decoration.growth ~= lastGrowth then
        UIManager.OpenUI(UIInfo.ItemPopupUI, nil, nil, "GrowUpDecoration", showItem, function()
            PlayerDatas.DecorationData:DecorationGrow(showItem.info.ItemID)
        end)
    end
end

local function itemRender(index, ui)
    local showItem = showList[index + 1]
    local isFish = showItem.info.Type == CommonItemType.Fish
    local slot = ui:GetChild("slot")
    local buyBtn = ui:GetChild("Button_Buy")
    local reddot = ReddotManger:CreateEffect(RedDotType.FishItemBtn,AnchorType.Center,buyBtn)
    local Type_C = ui:GetController("Type_C")
    local clickAction
    local uiicon = ui:GetChild("icon")
    uiicon.onClick:Clear()
    local Type_P = ui:GetController("Type_P")
    local txtDesc = ui:GetChild("Text_Desc")
    local Effect_Lv = ui:GetTransition("Effect_Lv")

    local itemQuality =  isFish and showItem.fishConfig.Quality or showItem.decorationConfig.Quality
    UIUtils.SetControllerIndex(Type_P, itemQuality)

    ui:GetChild("Text_Quality").text = Localize("Quality" .. tostring(itemQuality))
    if showItem.status == OpenStatus.Invisible then
        -- 未解锁，隐藏信息
        ui:GetController("State_C").selectedIndex = 2
        Type_C.selectedIndex = 4
        ui:GetController("Status_C").selectedIndex = 1
        ui:GetChild("title").text = "???"
        txtDesc.text = "???"
        txtDesc.grayed = true
    else
        ui:GetController("State_C").selectedIndex = 0
        if isFish then
            CommonUIUtils.SetTextByQuality(ui:GetChild("title"), showItem.fishConfig.Name..'('..Localize("FishGrade"..tostring(showItem.info.Grade))..')', itemQuality, showItem.status >= OpenStatus.Opening)
            ui:GetChild("icon").icon = "ui://Library/"..showItem.fishConfig.Icon
        else
            CommonUIUtils.SetTextByQuality(ui:GetChild("title"), showItem.decorationConfig.Name, itemQuality, showItem.status >= OpenStatus.Opening)
            ui:GetChild("icon").icon = "ui://Library/".. showItem.decorationConfig.Icon
        end

        ui:GetChild("icon").grayed = showItem.status > OpenStatus.Opening

        if showItem.status == OpenStatus.Opened then
            local bar = ui:GetChild("Bar")
            local income = PlayerDatas.AquariumData:GetShowIncome(showItem.info, incomeFactor)
            ui:GetChild("Label_Income").text = Utils.GetCountFormat(income)..Localize("UnitSeconds")
            local value,max,isMaxLv = PlayerDatas.DecorationData:GetUpProgress(showItem.decoration, showItem.decorationConfig)
            local maxGrowth = showItem.decoration.growth == DecorationGrowthEnum.Large
            bar.max = max
            bar.value = value
            
            ui:GetController("Status_C").selectedIndex = 0
            if isMaxLv then
                -- 已满级
                Type_C.selectedIndex = 3
                ui:GetChild("Text_Full").text = Localize("LevelUpFull")
            else
                local cost,batch,nextCost = PlayerDatas.DecorationData:GetLvlUpCostBatch(showItem.decoration.level, showItem.decorationConfig)
                buyBtn:GetChild("Label_Icon").icon = ConstantValue.CoinIconURL

                if batch == 0 then
                    Type_C.selectedIndex = 2
                    buyBtn:GetChild("Label_Icon").text = Utils.GetCountFormat(nextCost)
                    clickAction = "tiggerBox"
                else
                    clickAction = "levelup"
                    Type_C.selectedIndex = 0
                    buyBtn.text = LocalizeExt("UpgradeButtonBatch", {batch})
                    buyBtn:GetChild("Label_Icon").text = Utils.GetCountFormat(cost)
                end
            end
            ui:GetChild("Text_Lev").text ='【'.. LocalizeExt("Level", {value})..'】'

            local popdata = {}
            popdata.itemIcon = showItem.decorationConfig.Icon
            popdata.data = showItem.decorationConfig
            uiicon.onClick:Set(function ()
                UIManager.OpenPopupUI(UIInfo.ShowFishInfoUI, popdata)
            end)
        else
            -- 依赖条件判定
            local readyCount = 0
            local depends = DependManager.GetDepends(showItem.info.Depends)
            for i,v in ipairs(depends) do
                local depText = ui:GetChild("Text_Dep"..tostring(i))
                local depState_C = depText:GetController("state_C")
                local ready = DependManager.CheckDependency(v)
                
                if depText then
                    depText.text = v.title
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

            if showItem.status == OpenStatus.Opening and readyCount >= #depends then
                if isFish then
                    ui:GetController("Status_C").selectedIndex = 1
                    txtDesc.text = LocalizeExt("ShowFishReady")
                    txtDesc.grayed = false
                else
                    -- 策划老师要求可以解锁的项目要显示进度条 #ID1004160
                    local bar = ui:GetChild("Bar")
                    ui:GetChild("Label_Income").text = Utils.GetCountFormat(0)..Localize("UnitSeconds")
                    bar.max = 100
                    bar.value = 0
                    ui:GetChild("Text_Lev").text = '【'..LocalizeExt("Level", {0})..'】'
                    ui:GetController("Status_C").selectedIndex = 0
                end
                
                clickAction = "unlock"
                -- 解锁条件满足
                local costReady
                if showItem.info.UnlockType == CommonCostType.Free then
                    Type_C.selectedIndex = 5
                    buyBtn:GetChild("Text_Set").text = isFish and Localize("ShowFish") or Localize("UnlockRightNow")                    
                elseif showItem.info.UnlockType == CommonCostType.AD then
                    Type_C.selectedIndex = 1
                    buyBtn:GetChild("Text_Desc").text = isFish and Localize("ShowFish") or Localize("UnlockRightNow")
                else
                    buyBtn:GetChild("Text_Set").text = isFish and Localize("ShowFish") or Localize("Unlock")
                    --Type_C.selectedIndex = 7
                    local cost = 0
                    if CommonCostType.IsCoin(showItem.info.UnlockType) then
                        cost = showItem.info.UnlockCoin
                        buyBtn:GetChild("Label_Icon").icon = ConstantValue.CoinIconURL
                        costReady = CommonCostType.IsAD(showItem.info.UnlockType) or PlayerData.coinNum >= showItem.info.UnlockCoin
                    elseif CommonCostType.IsDiamond(showItem.info.UnlockType) then
                        cost = showItem.info.UnlockDiamond
                        buyBtn:GetChild("Label_Icon").icon = ConstantValue.DiamondIconURL
                        costReady = CommonCostType.IsAD(showItem.info.UnlockType) or PlayerData.diamondNum >= showItem.info.UnlockDiamond
                    end

                    if cost == 0 then
                        Type_C.selectedIndex = 5
                    else
                        buyBtn:GetChild("Label_Icon").text = Utils.GetCountFormat(cost)
                        if costReady then
                            Type_C.selectedIndex = 7
                        else
                            Type_C.selectedIndex = 9
                            clickAction = nil
                        end
                    end
                end
            else
                Type_C.selectedIndex = 4
                ui:GetController("Status_C").selectedIndex = 2
            end
        end
    end
    reddot:SetConditions(clickAction == "grow" or clickAction == "unlock")
    buyBtn.onClick:Set(function()
        if clickAction == "levelup" then
            LevelupShow(showItem, buyBtn)
            if levelUpEffects[ui] == nil then
                local function callBack(wrap)
                    levelUpEffects[ui] = wrap
                end
                    local safeArea = UIUtils.ScreenSafeArea()
                    local effectsize =(safeArea.width / UIContentScaler.scaleFactor/1080)
                    CommonUIUtils.CreateUIModelFromPool(GameObjectManager.UIEffPoolName,"Prefabs/Particle/waibao/UI/Eff_UI_waibiankuang.prefab",slot,callBack,nil,Vector3((1.5*effectsize),1.35,1))
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
        elseif clickAction == "grow" then
            Grow(showItem)
        elseif clickAction == "unlock" then
            OpenShow(showItem, index + 1)
        elseif clickAction == "tiggerBox" then
            EventDispatcher:Dispatch(Event.LACK_MONEY)
        end
    end)
end
local function onListScroll()
    EventDispatcher:Dispatch(Event.SHOW_INCOME)
end

function AquariumShowList.UpdateList(data)
    -- 功能未开启的时候会报空值异常，这里简单保护一下
    if panel == nil or panel.List == nil then
        return
    end

    if data then
        if aquarium ~= data then
            panel.lastFocusPosition = nil
            aquarium = data
            
            panel.lastScrollPosition = 0
            panel.List.scrollPane:SetPosY(0)
            panel:RefreshList()
        else
            panel:RefreshList()
        end
    elseif aquarium then
        panel:RefreshList()
    end
end

function AquariumShowList:RefreshList()
    local bufsData = PlayerDatas.BufferData
    aquariumID = aquarium.ID

    self.List.itemRenderer = itemRender
    if not isadd then
        self.List.scrollPane.onScroll:Add(onListScroll)
        isadd = true
    end
    incomeFactor = bufsData:GetAquariumFactor(aquariumID) + bufsData:GetAquariumFactor(0)
    showList = {}

    local decorationCount = 0 -- 未开启的展示物数量
    local fishCount = 0 -- 未放入的鱼数量
    local newFocusPosition = nil
    for i,v in ipairs(AquariumConfig.GetShowList(aquariumID)) do
        local item = { info = v }
        if v.Type == CommonItemType.Decoration then
            item.decorationConfig = DecorationConfig.DecorationsByID[v.ItemID]
            item.decoration = PlayerDatas.DecorationData:GetDecoration(v.ItemID)
            if item.decorationConfig == nil then
                Utils.DebugError("Invalid decoration "..tostring(v.ItemID))
                item = nil
            else
                if aquarium.openItems[v.ID] then
                    item.status = OpenStatus.Opened
                else
                    if decorationCount == 0 then
                        item.status = OpenStatus.Opening
                    elseif decorationCount < 2 then
                        item.status = OpenStatus.Prepare
                    else
                        item.status = OpenStatus.Invisible
                    end

                    decorationCount = decorationCount + 1
                end
            end
        elseif v.Type == CommonItemType.Fish then
            if aquarium.openItems[v.ID] then
                -- 已解锁的鱼不显示
                item = nil
            else
                item.fishConfig = FishConfig.FishesByID[v.ItemID]
                item.fish = PlayerDatas.FishData:GetFish(v.ItemID)
                if item.fishConfig == nil then
                    Utils.DebugError("Invalid fish "..tostring(v.ItemID))
                    item = nil
                elseif DependManager.PassedDepend(item.info.Depends) then
                    newFocusPosition = #showList
                    item.status = OpenStatus.Opening
                else
                    --如果解锁条件未满足，不显示条目
                    if fishCount < 1 then
                        item.status = OpenStatus.Prepare
                    else
                        item = nil
                    end
                    fishCount = fishCount + 1
                end
            end
        end
        if item then
            table.insert(showList, item)
        end
    end

    self.List.numItems = #showList

    -- 滚动到新解锁的鱼项目位置
    if newFocusPosition and self.lastFocusPosition ~= newFocusPosition then
        self.List:ScrollToView(newFocusPosition, true)
    end
    self.lastFocusPosition = newFocusPosition
end

function AquariumShowList:OnAquariumShowItem(showItem)
    AquariumShowList:RefreshList()
    WeakGuideManager:Hide()
end

function AquariumShowList:OnDecorationLevelup()
    AquariumShowList:RefreshList()
end

function AquariumShowList:OnOpen()
    panel = self
end

function AquariumShowList:OnShow(list, data, config)
    self.List = list

    local isNew = aquarium == nil or aquarium.ID ~= data.ID
    aquarium = data

    if self.backupScrollPosition == nil then
        self.backupScrollPosition = self.List.scrollPane.posY
    end
    
    if isNew then
        self.lastScrollPosition = 0
    end
    self.List.scrollPane:SetPosY(self.lastScrollPosition)
    self.lastFocusPosition = nil
    AquariumShowList:RefreshList(isNew)
end

function AquariumShowList:OnHide()
    -- 切页时会反复触发OnHide，这里需要加个保护
    if self.backupScrollPosition then
        -- 保存列表滚动位置
        self.lastScrollPosition = self.List.scrollPane.posY
        -- 还原其他界面的滚动位置（临时，FishList也要重构成子页面）
        self.List.scrollPane:SetPosY(self.backupScrollPosition)
        self.backupScrollPosition = nil
    end
end
function AquariumShowList:Close()
    if levelUpEffects then
        for k , v in pairs(levelUpEffects) do
            CommonUIUtils.ReturnUIModelToPool(v,GameObjectManager.UIEffPoolName)
        end
        levelUpEffects = {}
    end
end

function AquariumShowList:OnRegister()
    EventDispatcher:Add(Event.AQUARIUM_SHOW_ITEM, self.OnAquariumShowItem, self)
    EventDispatcher:Add(Event.AQUARIUM_LEVELUP_DECORATION, self.OnDecorationLevelup, self)
end

function AquariumShowList:OnUnRegister()
    EventDispatcher:Remove(Event.AQUARIUM_SHOW_ITEM, self.OnAquariumShowItem, self)
    EventDispatcher:Remove(Event.AQUARIUM_LEVELUP_DECORATION, self.OnDecorationLevelup, self)
end

return AquariumShowList