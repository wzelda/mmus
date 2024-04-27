
local DecorationConfig = Utils.LoadConfig("Config.DecorationConfig")

local DecorationData = class()

DecorationGrowthEnum =
{
    Little = 0,
    Middle = 1,
    Large = 2,
}

function DecorationData:CreateData()
    self.decorations = {}
end

local function CheckData(data)
    if data.level == nil then
        data.level = 1
    end
    if data.growth == nil then
        data.growth = 0
    end
    if data.stage == nil  then
        data.stage = 0
    end
    return data
end

function DecorationData:updateData(data)
    local decorationList = {}
    for _,v in ipairs(data.decorationList) do
        decorationList[v.ID] = CheckData(v)
    end
    self.decorations = decorationList
end

function DecorationData:Save(data)
    local decorationList = {}
    for _,v in pairs(self.decorations) do
        table.insert(decorationList, v)
    end
    data.decorationList = decorationList
end

function DecorationData:GetModelAndScale(decoration, config, growth)
    if growth == nil then
        growth = decoration and decoration.growth or DecorationGrowthEnum.Little
    end
    if growth == DecorationGrowthEnum.Little then
        return config.Model1, config.LittleScale
    elseif growth == DecorationGrowthEnum.Middle then
        return config.Model2,config.MiddleScale
    elseif growth == DecorationGrowthEnum.Large then
        return config.Model,config.LargeScale
    end
end

local function GetInitDecorationData(id)
    local cfg = DecorationConfig.DecorationsByID[id]
    local decoration = {ID = id,level = cfg.BaseLevel,stage = 0,growth = 0}
    return decoration
end

-- 升级装饰物
function DecorationData:AddDecoration(id)
    if self.decorations[id] == nil then
        self.decorations[id] = GetInitDecorationData(id)
        PlayerData.incomeDirty = true
    end
end

-- 移除装饰物(GM使用)
function DecorationData:RemoveDecoration(id)
    if self.decorations[id] ~= nil then
        self.decorations[id] = nil
        PlayerData.incomeDirty = true
    end
end

-- 获取升级进度
function DecorationData:GetUpProgress(decoration, cfg)
    return decoration.level, self:GetMaxLevel(decoration, cfg) ,decoration.level >= cfg.MaxLv
end

function DecorationData.IsMaxLevel(decoration, cfg)
    if decoration ==nil or cfg == nil then
        return
    end
    return decoration.level >= cfg.MaxLv
end

function DecorationData:GetMaxLevel(decoration, cfg)
    return cfg.StageLevels[decoration.stage + 1] or cfg.MaxLv
end

-- 获取升级消耗
local function GetLvlUpCost(level, cfg)
    --local factor = 1 -- TODO BufData中获取升级消耗降低系数
    local cost = cfg.UpCostBase + cfg.UpCostFactor * (cfg.RealBaseLevel + level - 1)
    return cost
end

-- 获取可升级的次数，以及消耗的金币数量
function DecorationData:GetLvlUpCostBatch(lv, cfg)
    local cost = 0
    local batchCount = 0
    local nextCost
    for i=lv+1,cfg.MaxLv do
        if i-lv > PlayerData.batchCount then break end
    
        nextCost = cost + GetLvlUpCost(i-1, cfg)
        if nextCost > PlayerData.coinNum then break end

        batchCount = batchCount + 1
        cost = nextCost
    end
    
    return cost,batchCount,nextCost
end

-- 升级装饰物
function DecorationData:LevelupDecoration(id)
    local decoration = self.decorations[id]
    local cfg = DecorationConfig.DecorationsByID[id]

    if decoration == nil then
        decoration = {level = 1}
        self.decorations[id] = decoration
    end

    local cost,batchCount = self:GetLvlUpCostBatch(decoration.level, cfg)
    
    if batchCount > 0 then
        PlayerData:ConsumeCoin(cost)
        decoration.level = decoration.level + batchCount
        PlayerData.incomeDirty = true
        EventDispatcher:Dispatch(Event.AQUARIUM_LEVELUP_DECORATION, decoration, cfg)
    end

    -- 统计上报装饰物升级等级
    AnalyticsManager.onJoinSystem(GameSystemType.FID_AQUARIUM, id, cfg.Name, decoration.level)
end

-- 装饰物成长
function DecorationData:DecorationGrow(id)
    local decoration = self.decorations[id]
    local cfg = DecorationConfig.DecorationsByID[id]
    local maxLv = self:GetMaxLevel(decoration, cfg)
    if decoration.level >= maxLv and decoration.level <= cfg.MaxLv then
        decoration.stage = decoration.stage + 1
        if decoration.level >= cfg.LargeLv then
            decoration.growth = DecorationGrowthEnum.Large
        elseif decoration.level >= cfg.MiddleLv then
            decoration.growth = DecorationGrowthEnum.Middle
        else
            return false
        end
    end
    PlayerData.Datas.BufferData:ChangeDecorationState(decoration)
    EventDispatcher:Dispatch(Event.DECORATION_GROWUP)
end

function DecorationData:OwnedDecoration(id, level)
    local decoration = self.decorations[id]
    if decoration == nil then return false end
    level = level or 1
    return self.decorations[id].level >= level
end

-- 是否拥有指定成长阶段的装饰物
function DecorationData:OwnedDecorationGrowth(id, growth)
    local decoration = self.decorations[id]
    if decoration == nil then return false end

    growth = growth or 0
    return decoration.growth >= growth
end

function DecorationData:GetDecoration(id)
    return self.decorations[id]
end

-- 是否拥有指定等级的装饰物
function DecorationData:OwnedDecorationLevel(id, level)
    local decoration = self.decorations[id]
    if decoration == nil then return false end

    level = level or 1
    return decoration.level >= level
end

return DecorationData