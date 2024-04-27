
local BufferConfig = Utils.LoadConfig("Config.BufferConfig")
local FishConfig = Utils.LoadConfig("Config.FishConfig")

local BufferData = class()


local TargetType =
{
    Fish = 0,
    Decoration = 1,
    All = 1,
}


function BufferData:AddFishRequire(config)
    if self.FishRequireConfig[config.ItemID] == nil then
        self.FishRequireConfig[config.ItemID] = {}
    end
    self.FishRequireConfig[config.ItemID][config.ID] = config
end

function BufferData:AddDecorationRequire(config)
    if self.DecorationRequireConfig[config.ItemID] == nil then
        self.DecorationRequireConfig[config.ItemID] = {}
    end
    self.DecorationRequireConfig[config.ItemID][config.ID] = config
end

function BufferData:AddAllRequire(config)
    if self.AllRequireConfig[config.ItemID] == nil then
        self.AllRequireConfig[config.ItemID] = {}
    end
    self.AllRequireConfig[config.ItemID][config.ID] = config
end

function BufferData:CreateData()
    self.CompleteBufferRequires = {}
    self.CompleteFishBuffers = {}
    self.AquariumBuffers = {}
    self.CompleteDecorationBuffers = {}
    self.CompleteAllBuffers = {}
    self.FishRequireConfig = {}
    self.DecorationRequireConfig = {}
    self.AllRequireConfig = {}
    self.BufferRootConfigMap = {}
    self.AllBufferLevel = {}
    local fishData = PlayerData.Datas.FishData
    local decorationData = PlayerData.Datas.DecorationData
    for i, v  in ipairs(BufferConfig.BufferRequire) do
        if v.ItemType == TargetType.Fish then
            self:AddFishRequire(v)
        elseif v.ItemType == TargetType.Decoration then
            self:AddDecorationRequire(v)
        else
            self:AddAllRequire(v)
        end
        if v.ItemType == TargetType.Fish and fishData.fishes[v.ItemID] 
        and self:FishBufferRequireEnough(fishData.fishes[v.ItemID],v) then
            self.CompleteBufferRequires[v.ID] = true
        elseif v.ItemType == TargetType.Decoration and decorationData.decorations[v.ItemID] 
        and decorationData.decorations[v.ItemID].level >= v.RequireLevel then
            self.CompleteBufferRequires[v.ID] = true
        end
    end

    local complete = false
    local config = nil
    for i, v  in ipairs(BufferConfig.BufferHead) do
        complete = true
        
        for _, requireId in ipairs(v.Requires) do
            if not self.CompleteBufferRequires[requireId] then
                complete = false
            end
            if self.BufferRootConfigMap[requireId] == nil then
                self.BufferRootConfigMap[requireId] = {}
            end
            self.BufferRootConfigMap[requireId][v.ID] = v
        end
        if complete then
            for _, bufferId in ipairs(v.Buffers) do
                config = BufferConfig.Buffers[bufferId]
                if config.ItemType == TargetType.Fish then
                    self:ActivateFishBuffer(config)
                elseif config.ItemType == TargetType.Decoration then
                    self:ActivateDecorationBuffer(config)
                else
                    self:ActivateAllBuffer(config)
                end
            end
        end
    end
end

function BufferData:AddIncomeBuffer(id, dispathEvent)
    local config = BufferConfig.BuffersByID[id]
    BufferData:ActivateAllBuffer(config, dispathEvent)
end

-- 叠加buffer
function BufferData:AddBufferLevel(config, bufferTable)
    if self.AllBufferLevel[config.ItemID] == nil then
        self.AllBufferLevel[config.ItemID] = {}
    end
    local level = self.AllBufferLevel[config.ItemID][config.ID]
    if nil == level then
        level = 0
    end
    level = level + 1
    self.AllBufferLevel[config.ItemID][config.ID] = level

    if bufferTable[config.ItemID] == nil then
        bufferTable[config.ItemID] = {}
    end
    bufferTable[config.ItemID][config.ID] = (1 + config.Factor)^level - 1
end

function BufferData:ActivateFishBuffer(config,dispathEvent)
    self:AddBufferLevel(config, self.CompleteFishBuffers)
    if dispathEvent then
        EventDispatcher:Dispatch(Event.ADD_BUFFER,config)
    end
    PlayerData.incomeDirty = true
end

function BufferData:ActivateAquariumBuffer(config,dispathEvent)
    self:AddBufferLevel(config, self.AquariumBuffers)
    if dispathEvent then
        EventDispatcher:Dispatch(Event.ADD_BUFFER,config)
    end
    PlayerData.incomeDirty = true
end

function BufferData:DecorationBuffer(config,dispathEvent)
    self:AddBufferLevel(config, self.CompleteDecorationBuffers)
    if dispathEvent then
        EventDispatcher:Dispatch(Event.ADD_BUFFER,config)
    end
    PlayerData.incomeDirty = true
end

function BufferData:ActivateAllBuffer(config,dispathEvent)
    self.CompleteAllBuffers[config.ID] = { config = config, startTime = Time.realtimeSinceStartup}
    if dispathEvent then
        EventDispatcher:Dispatch(Event.ADD_BUFFER,config)
    end
    PlayerData.incomeDirty = true
end

-- 根据类型加buff
function BufferData:ActivateBuffer(config,dispathEvent)
    if nil == config then return end
    
    if config.ItemType == 0 then
        -- 鱼类buff
        self:ActivateFishBuffer(config,dispathEvent)
    elseif config.ItemType == 1 then
        -- 装饰物buff
        self:DecorationBuffer(config, dispathEvent)
    elseif config.ItemType == 2 then
        -- 所有buff
        self:ActivateAllBuffer(config, dispathEvent)
    elseif config.ItemType == 3 then
        -- 鱼缸buff
        self:ActivateAquariumBuffer(config, dispathEvent)
    end
    PlayerData.incomeDirty = true
end

function BufferData:updateData()
    BufferData:CreateData()
end

function BufferData:DecorationBufferRequireEnough(decoration,requireConfig)
    local config = DecorationConfig.DecorationsByID[decoration.ID]
    if requireConfig.RequireLevel == config.MiddleLv then
        return decoration.growth >= DecorationGrowthEnum.Middle
    elseif requireConfig.RequireLevel == config.LargeLv then
        return decoration.growth >= DecorationGrowthEnum.Large
    elseif decoration.level >= requireConfig.RequireLevel then
        return true
    else
        return false
    end
end

function BufferData:FishBufferRequireEnough(fish,requireCofnig)
    local config = FishConfig.FishesByID[fish.ID]
    if requireCofnig.RequireLevel == config.MiddleLv then
        return fish.growth >= FishGrowthEnum.Middle
    elseif requireCofnig.RequireLevel == config.LargeLv then
        return fish.growth >= FishGrowthEnum.Large
    elseif fish.level >= requireCofnig.RequireLevel then
        return true
    else
        return false
    end
end

function BufferData:ChangeFishState(fish)
    if fish == nil then
        return
    end
    if self.FishRequireConfig[fish.ID] == nil then
        return
    end
    local newCompleteRequireIds = {}
    for k , v in pairs(self.FishRequireConfig[fish.ID]) do
        if not self.CompleteBufferRequires[v.ID] and self:FishBufferRequireEnough(fish,v) then
            table.insert( newCompleteRequireIds, v.ID)
            self.CompleteBufferRequires[v.ID] = true
        end 
    end
    local complete = false
    local config = nil
    for i, requireId in ipairs(newCompleteRequireIds) do
        for k , v in pairs(self.BufferRootConfigMap[requireId]) do
            complete = true
            for _,  id in ipairs(v.Requires) do
                if not self.CompleteBufferRequires[id] then
                    complete = false
                    break
                end
            end
            if complete then
                for _, bufferId in ipairs(v.Buffers) do
                    config = BufferConfig.Buffers[bufferId]
                    if config.ItemType == TargetType.Fish then
                        self:ActivateFishBuffer(config,true)
                    elseif config.ItemType == TargetType.Decoration then
                        self:ActivateDecorationBuffer(config,true)
                    else
                        self:ActivateAllBuffer(config,true)
                    end
                end
            end
        end
    end
end

function BufferData:ChangeDecorationState(decoration)
    if decoration == nil then
        return
    end
    if self.DecorationRequireConfig[decoration.ID] == nil then
        return
    end
    local newCompleteRequireIds = {}
    for k , v in pairs(self.DecorationRequireConfig[decoration.ID]) do
        if not self.CompleteBufferRequires[v.ID] and self:DecorationBufferRequireEnough(decoration,v) then
            table.insert( newCompleteRequireIds, v.ID)
            self.CompleteBufferRequires[v.ID] = true
        end 
    end
    local complete = false
    local config = nil
    for i, requireId in ipairs(newCompleteRequireIds) do
        for k , v in pairs(self.BufferRootConfigMap[requireId]) do
            complete = true
            for _,  id in ipairs(v.Requires) do
                if not self.CompleteBufferRequires[id] then
                    complete = false
                    break
                end
            end
            if complete then
                for _, bufferId in ipairs(v.Buffers) do
                    config = BufferConfig.Buffers[bufferId]
                    if config.ItemType == TargetType.Fish then
                        self:ActivateDecorationBuffer(config,true)
                    elseif config.ItemType == TargetType.Decoration then
                        self:ActivateDecorationBuffer(config,true)
                    else
                        self:ActivateAllBuffer(config,true)
                    end
                end
            end
        end
    end
end

-- 鱼类收入增益
function BufferData:GetFishBufferFactor(id)
    local factor = 0
    if self.CompleteFishBuffers[id] then
        for k , v in pairs(self.CompleteFishBuffers[id] ) do
            factor = factor + v
        end
    end
    return factor
end

-- 装饰物收入增益
function BufferData:GetDecorationBufferFactor(id)
    local factor = 0
    if self.CompleteDecorationBuffers[id] then
        for k , v in pairs(self.CompleteDecorationBuffers[id] ) do
            factor = factor + v
        end
    end
    return factor
end

-- 观赏馆收入增益
function BufferData:GetAquariumFactor(id)
    local factor = 0
    if self.AquariumBuffers[id] then
        for k , v in pairs(self.AquariumBuffers[id]) do
            factor = factor + v.Factor
        end
    end
    return factor
end

function BufferData:GetAquariumCost(id)
    local factor = 0
    if self.AquariumBuffers[id] then
        for k , v in pairs(self.AquariumBuffers[id]) do
            factor = factor + v.Cost
        end
    end
    return factor
end

-- 全部鱼类收入增益, 暂无需求
function BufferData:GetAllFishFactor()
    local factor = 0
    return factor
end

-- 全部收入增益系数
function BufferData:GetAllBufferFactor()
    local factor = 0
    -- 临时增益（广告）需要单独计算
    local factorTemp = 1
    local rmlist = {}
    for k , v in pairs(self.CompleteAllBuffers) do
        if v.config.LifeTime == 0 then
            -- 永久Buf
            factor = factor + v.config.Factor
        else
            -- 临时增益（广告）
            if Time.realtimeSinceStartup - v.startTime < v.config.LifeTime then
                factorTemp = factorTemp * v.config.Factor
            else
                table.insert(rmlist, k)
            end
        end
    end

    for _,id in ipairs(rmlist) do
        self.CompleteAllBuffers[id] = nil
    end

    return factor,factorTemp
end

return BufferData