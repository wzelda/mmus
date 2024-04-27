local FishConfig = Utils.LoadConfig("Config.FishConfig")

local FishData = class()

FishGrowthEnum = {
    Little = 0,
    Middle = 1,
    Large = 2
}

function FishData:CreateData()
    self.fishes = {}
    -- 第一条鱼默认解锁
    self.lastUnlockTime = 0
    self.normalBoxCollectCount = 0
    self.adBoxCollectCount = 0
    self.lastShowNormalBoxTime = 0
    self.lastShowAdBoxTime = 0
end

local function CheckData(data)
    if data.level == nil then
        data.level = 1
    end
    if data.growth == nil then
        data.growth = 0
    end
    if data.stage == nil then
        data.stage = 0
    end
    return data
end

function FishData:updateData(data)
    local fishList = {}
    for _, v in ipairs(data.fishList) do
        fishList[v.ID] = CheckData(v)
    end
    self.fishes = fishList
    self.lastUnlockTime = data.lastUnlockTime or TimerManager.getCurrentClientTime()
    self.lastShowNormalBoxTime = TimerManager.getCurrentClientTime()
    self.lastShowAdBoxTime = TimerManager.getCurrentClientTime()
    self.normalBoxCollectCount = data.normalBoxCollectCount or 0
    self.adBoxCollectCount = data.adBoxCollectCount or 0
end

-- 快进鱼儿解锁计时
function FishData:SkipUnlockTime(seconds)
    self.lastUnlockTime = self.lastUnlockTime - seconds
end

-- 快进宝箱展示cd
function FishData:SkipBoxShowCd(seconds)
    self.lastShowNormalBoxTime = self.lastShowNormalBoxTime - seconds
    self.lastShowAdBoxTime = self.lastShowAdBoxTime - seconds
end

-- 重置鱼儿解锁计时
function FishData:ResetUnlockTime()
    self.lastUnlockTime = TimerManager.getCurrentClientTime()
end

function FishData:Save(data)
    local fishList = {}
    for _, v in pairs(self.fishes) do
        table.insert(fishList, v)
    end
    data.fishList = fishList
    data.lastUnlockTime = self.lastUnlockTime
    data.lastShowNormalBoxTime = self.lastShowNormalBoxTime
    data.lastShowAdBoxTime = self.lastShowAdBoxTime
    data.normalBoxCollectCount = self.normalBoxCollectCount
    data.adBoxCollectCount = self.adBoxCollectCount
end

-- 计算鱼的收入
function FishData:GetFishIncome(fish, otherFactor, config)
    if nil == fish then
        return 0
    end
    -- TODO 需要计算装饰物强化系数，全局强化系数
    config = config or FishConfig.FishesByID[fish.ID]
    return config.IncomeBase * (config.RealBaseLevel + fish.level - 1) * (1 + self:GetIncomeFactor(config.ID) + otherFactor)
end

function FishData:GetIncomeBase(fish)
    local config = FishConfig.FishesByID[fish.ID]
    return config.IncomeBase * (config.RealBaseLevel + fish.level - 1)
end

function FishData:GetFishIncomeById(fishId)
    return self:GetFishIncome(self:GetFish(fishId), 0)
end

-- 根据鱼的阶段查找鱼的产出系数
function FishData:GetIncomeFactor(id)
    return PlayerData.Datas.BufferData:GetFishBufferFactor(id)
end

function FishData:GetFishModelAndScale(id, growth)
    if growth == nil then
        local fish = self.fishes[id]
        growth = fish and fish.growth or FishGrowthEnum.Little
    end
    local config = FishConfig.FishesByID[id]
    if growth == FishGrowthEnum.Little then
        return config.Model2, config.LittleScale
    elseif growth == FishGrowthEnum.Middle then
        return config.Model1, config.MiddleScale
    elseif growth == FishGrowthEnum.Large then
        return config.Model, config.LargeScale
    end
end

function FishData:GetFightFishModelAndScale(id, growth)
    if growth == nil then
        local fish = self.fishes[id]
        growth = fish and fish.growth or FishGrowthEnum.Little
    end
    local config = FishConfig.FishesByID[id]
    if growth == FishGrowthEnum.Little then
        return config.FightModel2, config.LittleScale
    elseif growth == FishGrowthEnum.Middle then
        return config.FightModel1, config.MiddleScale
    elseif growth == FishGrowthEnum.Large then
        return config.FightModel, config.LargeScale
    else
        return config.FightModel1, config.LittleScale
    end
end

function FishData:GetFishUIModelAndScale(id, growth)
    if growth == nil then
        local fish = self.fishes[id]
        growth = fish and fish.growth or FishGrowthEnum.Little
    end
    local config = FishConfig.FishesByID[id]
    if growth == FishGrowthEnum.Little then
        return config.FightModel2, config.UILittleScale
    elseif growth == FishGrowthEnum.Middle then
        return config.FightModel1, config.UIMiddleScale
    elseif growth == FishGrowthEnum.Large then
        return config.FightModel, config.UILargeScale
    else
        return config.FightModel, config.UILittleScale
    end
end

function FishData:GetTotalIncome()
    local income = 0
    local factor = PlayerData.Datas.BufferData:GetAllFishFactor()
    if self.fishes then
        for _, f in pairs(self.fishes) do
            income = income + self:GetFishIncome(f, factor)
        end
    end
    return income
end

-- 新发现鱼奖励
function FishData:DiscoverFishReward(cfg, isAD)
    local adReward = isAD and cfg.RewardAD or 1
    if adReward < 1 then
        adReward = 1
    end

    if cfg.RewardType == CommonRewardType.Coin then
        PlayerData:RewardCoin(cfg.Reward * adReward)
    elseif cfg.RewardType == CommonRewardType.Diamond then
        PlayerData:RewardDiamond(cfg.Reward * adReward)
    elseif cfg.RewardType == CommonRewardType.IncomeTimes then
        PlayerData:RewardCoin(PlayerData:GetRealCoinIncome() * cfg.Reward * adReward)
    end
end

local function GetInitFishData(id)
    local cfg = FishConfig.FishesByID[id]
    local fish = {ID = id, level = cfg.BaseLevel, stage = 0, growth = 0}
    return fish
end

-- 获取鱼
function FishData:AddFish(id)
    if self.fishes[id] == nil then
        self.fishes[id] = GetInitFishData(id)
        self.lastUnlockTime = TimerManager.getCurrentClientTime()
        PlayerData.incomeDirty = true
        EventDispatcher:Dispatch(Event.FISH_UNLOCK_SUCCESS)
    end
end

-- 放弃了钓鱼
function FishData:GiveUpFishing(id)
    if self.GiveUpId == id then
        self.GiveUpTimes = self.GiveUpTimes + 1
    else
        self.GiveUpId = id
        self.GiveUpTimes = 1
    end
end

function FishData:RemoveFish(id)
    if self.fishes[id] ~= nil then
        self.fishes[id] = nil
        self.lastUnlockTime = TimerManager.getCurrentClientTime()
        PlayerData.incomeDirty = true
    end
end

-- 获取升级进度
function FishData:GetUpProgress(fish, cfg)
    return fish.level, self:GetMaxLevel(fish.ID), fish.level >= cfg.MaxLv
end

function FishData.IsMaxLevel(fish, cfg)
    if fish == nil or cfg == nil then
        return
    end
    return fish.level >= cfg.MaxLv
end

-- 获取升级消耗
local function GetLvlUpCost(level, cfg)
    local cost = cfg.UpCostBase + cfg.UpCostFactor * (cfg.RealBaseLevel + level - 1)
    return cost
end

-- 获取可升级的次数，以及消耗的金币数量
function FishData:GetLvlUpCostBatch(lv, cfg)
    local cost = 0
    local batchCount = 0
    for i = lv + 1, cfg.MaxLv do
        if i - lv > PlayerData.batchCount then
            break
        end

        local newCost = cost + GetLvlUpCost(i - 1, cfg)
        if newCost > PlayerData.coinNum then
            break
        end

        batchCount = batchCount + 1
        cost = newCost
    end

    return cost, batchCount
end

-- 领取手动漂流宝箱奖励
function FishData:GetNormalBoxReward()
    PlayerData:RewardCoin(self:NormalBoxRewardCount())
    self.lastShowNormalBoxTime = TimerManager.getCurrentClientTime()
    self.normalBoxCollectCount = self.normalBoxCollectCount + 1
    PlayerDatas.AdvData:AddOpenFloatBoxCount()
    -- 打开宝箱音效
    AudioManager.PlayEAXSound(1008)
end

function FishData:ShowAdBox()
    self.lastShowAdBoxTime = TimerManager.getCurrentClientTime()
end

-- 领取广告漂流宝箱奖励
function FishData:GetAdBoxReward()
    PlayerData:RewardCoin(self:AdBoxRewardCount())
    self.lastShowAdBoxTime = TimerManager.getCurrentClientTime()
    self.adBoxCollectCount = self.adBoxCollectCount + 1
    PlayerDatas.AdvData:AddOpenFloatBoxCount()
    -- 打开宝箱音效
    AudioManager.PlayEAXSound(1008)
end

function FishData:NormalBoxRewardCount()
    if ConfigData.miscConfig.BoxConfigByKey["NormalBoxCds"] then
        return PlayerData:GetRealCoinIncome() * ConfigData.miscConfig.BoxConfigByKey["NormalBoxCds"].Rate
    end
    return 0
end

function FishData:AdBoxRewardCount()
    if ConfigData.miscConfig.BoxConfigByKey["AdBoxCds"] then
        return PlayerData:GetRealCoinIncome() * ConfigData.miscConfig.BoxConfigByKey["AdBoxCds"].Rate
    end
    return 0
end
-- 是否可以生产手动宝箱
function FishData:CanCreateNormalBox()
    return ConfigData.miscConfig.BoxConfigByKey["NormalBoxCds"] and self.normalBoxCollectCount < ConfigData.miscConfig.BoxConfigByKey["NormalBoxCds"].Number and (ConfigData.miscConfig.BoxConfigByKey["NormalBoxCds"].Cd + self.lastShowNormalBoxTime) <= TimerManager.getCurrentClientTime()
end

-- 是否可以生产广告宝箱宝箱
function FishData:CanCreateAdBox()
    if PlayerDatas.FunctionOpenData:CheckUnlock(GameSystemType.FID_MOVEAD) and ConfigData.miscConfig.BoxConfigByKey["AdBoxCds"] and self.adBoxCollectCount < ConfigData.miscConfig.BoxConfigByKey["AdBoxCds"].Number and (ConfigData.miscConfig.BoxConfigByKey["AdBoxCds"].Cd + self.lastShowAdBoxTime) <= TimerManager.getCurrentClientTime() then
        return true
    else
        return false
    end
end

function FishData:GetLvlUpCost(lv, cfg)
    return GetLvlUpCost(lv, cfg)
end

function FishData:GetMaxLevel(id)
    local fish = self.fishes[id]
    local cfg = FishConfig.FishesByID[id]
    return cfg.StageLevels[fish.stage + 1] or cfg.MaxLv
end

-- 升级鱼儿
function FishData:LevelupFish(id)
    local fish = self.fishes[id]
    local cfg = FishConfig.FishesByID[id]

    if fish == nil then
        self.fishes[id] = GetInitFishData(id)
        fish = self.fishes[id]
    end

    local cost, batchCount = self:GetLvlUpCostBatch(fish.level, cfg)
    PlayerData:ConsumeCoin(cost)
    fish.level = fish.level + batchCount
    PlayerData.Datas.BufferData:ChangeFishState(fish)
    PlayerData.incomeDirty = true
    EventDispatcher:Dispatch(Event.FISH_LEVELUP)

    -- 统计上报鱼类升级等级
    AnalyticsManager.onJoinSystem(GameSystemType.FID_FISHING, id, cfg.Name, fish.level)
end

-- 鱼儿成长
function FishData:FishGrow(id)
    local fish = self.fishes[id]
    local maxLv = self:GetMaxLevel(id)
    local cfg = FishConfig.FishesByID[id]
    if fish.level >= maxLv and fish.level <= cfg.MaxLv then
        fish.stage = fish.stage + 1
        fish.growth = fish.growth + 1
    -- if fish.level >= cfg.LargeLv then
    --     fish.growth = FishGrowthEnum.Large
    -- elseif fish.level >= cfg.MiddleLv then
    --     fish.growth = FishGrowthEnum.Middle
    -- else
    --     return false
    -- end
    end
    PlayerData.Datas.BufferData:ChangeFishState(fish)
    EventDispatcher:Dispatch(Event.FISH_GROWUP)
end

-- 是否拥有指定等级的鱼种，level为可选参数
function FishData:OwnedFish(id, level)
    local fish = self.fishes[id]
    if fish == nil then
        return false
    end

    level = level or 1
    return self.fishes[id].level >= level
end

-- 是否拥有指定成长阶段的鱼种
function FishData:OwnedFishGrowth(id, growth)
    local fish = self.fishes[id]
    if fish == nil then
        return false
    end

    growth = growth or 0
    return fish.growth >= growth
end

function FishData:GetFish(id)
    return self.fishes[id]
end

function FishData:CanDoSomething()
    local seaData = PlayerData.Datas.SeaData
    local fishConfig = nil
    local fish = nil
    local productConfig = nil
    local value, max, isMaxLv
    local maxGrowth
    local cost, batch
    local fishOpenCount = seaData:GetFishOpenCount(seaData.currentSea)
    for i, v in ipairs(seaData:GetProducts(seaData.currentSea)) do
        fishConfig = FishConfig.FishesByID[v.ItemID]
        fish = self:GetFish(v.ItemID)
        if i > fishOpenCount + 1 then
            break
        else
            if i <= fishOpenCount then
                value, max, isMaxLv = self:GetUpProgress(fish, fishConfig)
                maxGrowth = fish.growth == FishGrowthEnum.Large
                if value >= max then
                    if not isMaxLv or not maxGrowth then
                        return true
                    end
                --[[else
                    cost,batch = self:GetLvlUpCostBatch(value, fishConfig)
                    if batch ~= 0 then
                        return true
                    end]]
                end
            else
                local readyCount = 0
                local depends = DependManager.GetDepends(fishConfig.Depends)
                for i1, v1 in ipairs(depends) do
                    local ready = DependManager.CheckDependency(v1)
                    if ready then
                        readyCount = readyCount + 1
                    end
                end
                if readyCount >= #depends and (TimerManager.getCurrentClientTime() - self.lastUnlockTime) >= v.CostTime then
                    return true
                end
            end
        end
    end
    return false or self:CanUnlockNextFishSence()
end

function FishData:CanUnlockNextFishSence()
    local seaId = PlayerDatas.SeaData:GetNextSea()
    local cfg = ConfigData.seaConfig.SeasByID[seaId]
    if cfg then
        return DependManager.PassedDepend(cfg.Depends)
    end
    return false
end

function FishData:DailyReset()
    self.lastShowNormalBoxTime = 0
    self.lastShowAdBoxTime = TimerManager.getCurrentClientTime()
    self.normalBoxCollectCount = 0
    self.adBoxCollectCount = 0
end
return FishData
