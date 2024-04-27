
-- 观赏馆数据

local AquariumConfig = Utils.LoadConfig("Config.AquariumConfig")
local FishConfig = Utils.LoadConfig("Config.FishConfig")
local DecorationConfig = Utils.LoadConfig("Config.DecorationConfig")

-- 获取展示列表
function AquariumConfig.GetShowList(AquariumID)
    local aquariumCfg = AquariumConfig.AquariumsByID[AquariumID]

    local showList = {}
    for _,v in ipairs(aquariumCfg.ShowItems) do
        table.insert(showList, AquariumConfig.ShowItemsByID[v])
    end

    return showList
end

local AquariumData = class()

AquariumData.TheConfig = AquariumConfig

function AquariumData:CreateData()
    self.aquariums = {}
end

function AquariumData:OnFunctionOpen()
    -- 初始化开放观赏馆
    for _,v in ipairs(AquariumConfig.Aquariums) do
        if v.Depends == 0 then
            self:OpenAquarium(v.ID)
        end
    end
end

-- 进入观赏馆调用
function AquariumData:OpenAquarium(AquariumID, dispatch)
    if self.aquariums[AquariumID] == nil then
        local aquarium = {ID=AquariumID}
        
        aquarium.openItems = {}
        self.aquariums[AquariumID] = aquarium

        if dispatch then
            EventDispatcher:Dispatch(Event.AQUARIUM_UNLOCK, aquarium) 
        end
    end

    if self.currentAquarium ~= AquariumID then
        self.currentAquarium = AquariumID

        if dispatch then
            EventDispatcher:Dispatch(Event.AQUARIUM_SWITCH, AquariumID) 
        end
    end
end

-- 解锁展示物
function AquariumData:OpenShowItem(aquarium, showItem, adUnlock)
    local itemInfo = showItem.info
    if adUnlock and CommonCostType.IsAD(itemInfo.UnlockType) then
        Utils.DebugLog("AD unclock "..tostring(itemInfo.ItemID))
    else
        if itemInfo.UnlockType == CommonCostType.Coin or itemInfo.UnlockType == CommonCostType.CoinAD then
            PlayerData:ConsumeCoin(itemInfo.UnlockCoin)
        elseif itemInfo.UnlockType == CommonCostType.Diamond or itemInfo.UnlockType == CommonCostType.DiamondAD then
            PlayerData:ConsumeDiamond(itemInfo.UnlockDiamond)
        elseif itemInfo.UnlockType ~= CommonCostType.Free then
            Utils.DebugError("Can't unlock item "..tostring(itemInfo.ItemID))
            return false
        end
    end

    if itemInfo.Type == CommonItemType.Decoration then
        PlayerData.Datas.DecorationData:AddDecoration(itemInfo.ItemID)
        AnalyticsManager.onUnlockSystem(GameSystemType.FID_AQUARIUM, showItem.decorationConfig.ID, showItem.decorationConfig.Name)
    end

    aquarium.openItems[itemInfo.ID] = true
    PlayerData.incomeDirty = true
    EventDispatcher:Dispatch(Event.AQUARIUM_SHOW_ITEM, itemInfo)

    return true
end

function AquariumData:GMOpenAllAquariums()
    for _,v in ipairs(AquariumConfig.Aquariums) do
        if self.aquariums[v.ID] == nil then
            local aquarium = {ID=v.ID}
            aquarium.openItems = {}
            self.aquariums[v.ID] = aquarium
        end
    end
end

function AquariumData:GMOpenAllShowItems()
    for _,aquarium in pairs(self.aquariums) do
        local aquariumCfg = AquariumConfig.AquariumsByID[aquarium.ID]

        for _,item in pairs(aquariumCfg.ShowItems) do
            local showItem = AquariumConfig.ShowItemsByID[item]

            if showItem then
                aquarium.openItems[item] = true
                
                if showItem.Type == CommonItemType.Decoration then
                    PlayerData.Datas.DecorationData:AddDecoration(showItem.ItemID)
                end
            end
        end
    end
end

function AquariumData:GMClosePrevItems(n)
    local aquarium,aquariumCfg = self:GetCurAquarium()
    local c = 0
    for i=#aquariumCfg.ShowItems,1,-1 do
        local item = aquariumCfg.ShowItems[i]
        local showItem = AquariumConfig.ShowItemsByID[item]
        
        if showItem and aquarium.openItems[item] then
            aquarium.openItems[item] = nil
            if showItem.Type == CommonItemType.Decoration then
                PlayerData.Datas.DecorationData:RemoveDecoration(showItem.ItemID)
            end
            c = c+1
            if c >= n then
                return
            end
        end
    end
end

function AquariumData:GMEnableDrag(enable)
    CS.UnityEngine.PlayerPrefs.SetInt("EnableDrag", enable and 1 or 0)
end

-- 计算展出物品收入
function AquariumData:GetShowIncome(show, otherFactor)
    if show.Type == CommonItemType.Fish then
        return 0 --math.floor(show.IncomeBase * factor)
    elseif show.Type == CommonItemType.Decoration then
        local decoration = PlayerData.Datas.DecorationData.decorations[show.ItemID]
        if decoration == nil then
            Utils.DebugError("未获得装饰物ID:"..tostring(show.ItemID))
            return 0
        end
        local decorationCfg = DecorationConfig.DecorationsByID[show.ItemID]
        local decorationBufFactor = PlayerData.Datas.BufferData:GetDecorationBufferFactor(show.ItemID)
        return math.floor(show.IncomeBase * (decorationCfg.RealBaseLevel + decoration.level - 1) * (1 + decorationBufFactor + otherFactor))
    end
end

function AquariumData:GetIncomeBase(show)
    local decoration = PlayerData.Datas.DecorationData.decorations[show.ItemID]
    if decoration == nil then
        Utils.DebugError("未获得装饰物ID:"..tostring(show.ItemID))
        return 0
    end
    local decorationCfg = DecorationConfig.DecorationsByID[show.ItemID]
    return math.floor(show.IncomeBase * (decorationCfg.RealBaseLevel + decoration.level - 1))
end

function AquariumData:GetTotalIncome()
    local income = 0
    for id,aquarium in pairs(self.aquariums) do
        income = income + self:GetIncome(aquarium)
    end
    return income
end

function AquariumData:GetIncome(aquarium)
    local income = 0
    -- 全部观赏馆收入增益
    local allFactor = PlayerData.Datas.BufferData:GetAquariumFactor(0)
    for i,v in ipairs(AquariumConfig.GetShowList(aquarium.ID)) do
        -- 观赏馆收入增益
        local aquariumFactor = PlayerData.Datas.BufferData:GetAquariumFactor(aquarium.ID)
        if aquarium.openItems[v.ID] then
            income = income + self:GetShowIncome(v, allFactor + aquariumFactor)
        end
    end
    return income
end

-- 是否完成观赏馆建设
function AquariumData:FinishedAquarium(id)
    local aquarium = self.aquariums[id]
    if aquarium == nil then
        return false
    end
    
    local progress,max = self:GetProgress2(aquarium)

    if max == 0 then
        return false
    end

    return progress==max
end

function AquariumData:GetProgress2(aquarium)
    local max = 0
    local value = 0
    for i,show in ipairs(AquariumConfig.GetShowList(aquarium.ID)) do
        if show.Type == CommonItemType.Decoration then
            local decoration = PlayerData.Datas.DecorationData.decorations[show.ItemID]
            local decorationCfg = DecorationConfig.DecorationsByID[show.ItemID]

            max = max + decorationCfg.MaxLv
            
            if decoration then
                value = value + decoration.level
            end
        end
    end

    return value,max
end

function AquariumData:GetProgress(aquarium)
    local value,max = self:GetProgress2(aquarium)

    if max == 0 then
        return 0
    end

    return value / max
end

function AquariumData:GetProgressById(AquariumID)
    local aquarium = self:GetAquarium(AquariumID)
    if nil == aquarium then
        return 0
    end
    return self:GetProgress(aquarium)
end

-- 新发现装饰物奖励
function AquariumData:DiscoverDecorationReward(cfg, isAD)
    local adReward = isAD and cfg.RewardAD or 1
    if adReward < 1 then
        adReward = 1
    end
    
    if cfg.RewardType == CommonRewardType.Coin then
        PlayerData:RewardCoin(cfg.RewardPoint * adReward)
    elseif cfg.RewardType == CommonRewardType.Diamond then
        PlayerData:RewardDiamond(cfg.RewardPoint * adReward)
    elseif cfg.RewardType == CommonRewardType.IncomeTimes then
        PlayerData:RewardCoin(PlayerData:GetRealCoinIncome() * cfg.RewardPoint * adReward)
    end
end

-- 读取观赏馆数据
local function readAquarium(v)
    local a = {
        ID=v.ID,
        openItems = {}
    }

    if v.openItems then
        for _,showId in ipairs(v.openItems) do
            a.openItems[showId] = true
        end
    end

    return a
end

-- 写入观赏馆数据
local function writeAquaraium(a)
    local o = {
        ID = a.ID,
        openItems = {}
    }

    for k,v in pairs(a.openItems) do
        if v then
            table.insert(o.openItems, k)
        end
    end

    return o
end

-- 更新观赏馆系统数据
-- 特地说明一下，序列化不支持lua中以数字为key的table，所以需要转换为数组表示
-- 在读取的时候将数组转换为table
function AquariumData:updateData(data)
    local aquariums = {}
    for _,v in ipairs(data.aquariums) do
        aquariums[v.ID] = readAquarium(v)
    end
    self.aquariums = aquariums
    self.currentAquarium = data.currentAquarium
end

-- 保存观赏馆数据
function AquariumData:Save(data)
    local aquariums = {}
    for _,v in ipairs(self.aquariums) do
        table.insert(aquariums, writeAquaraium(v))
    end
    data.aquariums = aquariums
    data.currentAquarium = self.currentAquarium
end

function AquariumData:GetCurAquarium()
    return self.aquariums[self.currentAquarium], AquariumConfig.AquariumsByID[self.currentAquarium]
end

function AquariumData:GetAquarium(AquariumID)
    return self.aquariums[AquariumID]
end

-- 判定指定的展示项目是否已解锁
function AquariumData:IsShowItemUnlocked(showItemID)
    for _,v in pairs(self.aquariums) do
        if v.openItems[showItemID] then
            return true
        end
    end
    return false
end

-- 可以修建新的观赏馆
function AquariumData:CanBuildNewAquarium()
    for _,v in ipairs(AquariumConfig.Aquariums) do
        if self.aquariums[v.ID] == nil then
            if DependManager.PassedDepend(v.Depends) then
                return true
            end
        end
    end
end

-- 界面内是否有需要操作的
function AquariumData:CanDoSomething()
    if not PlayerDatas.FunctionOpenData:IsFunctionOpened(GameSystemType.FID_AQUARIUM) then
        return PlayerDatas.FunctionOpenData:ReadyUnlockById(GameSystemType.FID_AQUARIUM)
    end

    if self:CanBuildNewAquarium() then
        return true
    end

    local aquarium = self:GetCurAquarium()
    local decorationData = PlayerDatas.DecorationData

    if aquarium == nil then
        return false
    end

    for i,v in ipairs(AquariumConfig.GetShowList(self.currentAquarium)) do
        if aquarium.openItems[v.ID] == nil then
            -- 未解锁，检查解锁条件
            if DependManager.PassedDepend(v.Depends) then
                if CommonCostType.IsCoin(v.UnlockType) then
                    return CommonCostType.IsAD(v.UnlockType) or PlayerData.coinNum >= v.UnlockCoin
                elseif CommonCostType.IsDiamond(v.UnlockType) then
                    return CommonCostType.IsAD(v.UnlockType) or PlayerData.diamondNum >= v.UnlockDiamond
                else
                    return true
                end
            end
        else
            if v.Type == CommonItemType.Decoration then
                local decoration = decorationData:GetDecoration(v.ItemID)
                local cfg = DecorationConfig.DecorationsByID[v.ItemID]
                local value,max,isMaxLv = decorationData:GetUpProgress(decoration, cfg)
                maxGrowth = decoration.growth == DecorationGrowthEnum.Large
                if value >= max then
                    if not isMaxLv --[[or not maxGrowth]] then
                        return true
                    end
                --[[else
                    -- 可升级不再显示红点
                    cost,batch = decorationData:GetLvlUpCostBatch(value, cfg)
                    if batch ~= 0 then
                        return true
                    end]]
                end
            end
        end
    end

    -- TODO 检查是否有观赏馆满足解锁条件

    return false
end

return AquariumData