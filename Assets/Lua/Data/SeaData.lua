
local SeaConfig = Utils.LoadConfig("Config.SeaConfig")

local SeaData = class()

function SeaData:CreateData()
    self.seas = {}

    -- 初始化开放海域
    for _,v in ipairs(SeaConfig.Seas) do
        if DependManager.PassedDepend(v.Depends) then
            self:OpenSea(v.ID)
            break
        end
    end
end

-- 进入海域调用
function SeaData:OpenSea(seaID)
    self.currentSea = seaID
    if nil == self.seas[seaID] then
        -- 初始化等待时间
        local sea = {ID=seaID}
        sea.OpenTime = os.time()
        self.seas[seaID] = sea
        EventDispatcher:Dispatch(Event.SEA_UNLOCK, seaID)
    end
    EventDispatcher:Dispatch(Event.SEA_SWITCH, seaID)
end

-- 是否已完成海域钓鱼
function SeaData:FinishedSea(id)
    local sea = self.seas[id]
    if sea == nil then
        return false
    end

    local seaCfg = SeaConfig.SeasByID[id]
    
    local config
    local fishData = PlayerData.Datas.FishData

    for _,v in ipairs(seaCfg.Products) do
        config = SeaConfig.ProductsByID[v]
        if not config or not fishData:OwnedFish(config.ItemID) then
            return false
        end
    end
    return true
end

function SeaData:updateData(data)
    local seas = {}
    for _,v in ipairs(data.seas) do
        seas[v.ID] = v
    end
    self.seas = seas
    self.currentSea = data.currentSea
end

function SeaData:Save(data)
    local seas = {}
    for _,v in pairs(self.seas) do
        table.insert(seas, v)
    end
    data.seas = seas
    data.currentSea = self.currentSea
end

function SeaData:GetCurSea()
    return self.seas[self.currentSea], SeaConfig.SeasByID[self.currentSea]
end

function SeaData:GetSea(seaID)
    return self.seas[seaID]
end

function SeaData:GetFishOpenCount(seaID)
    local seaCfg = SeaConfig.SeasByID[seaID]

    local count = 0
    local config = nil
    local fishData = PlayerData.Datas.FishData
    for _,v in ipairs(seaCfg.Products) do
        config = SeaConfig.ProductsByID[v]
        if config and fishData:OwnedFish(config.ItemID) then
            count = count + 1
        else
            break;
        end
    end
    return count
end

-- GM工具调用, 取消解锁上一条鱼
function SeaData:GMLockPrevFish(n)
    local c = 0
    local _,seaCfg= self:GetCurSea()

    for i=#seaCfg.Products,1,-1 do
        local pid = seaCfg.Products[i]
        local product = SeaConfig.ProductsByID[pid]
        if product.Type == CommonItemType.Fish then
            if PlayerData.Datas.FishData:GetFish(product.ItemID) ~= nil then
                c = c+1
                PlayerData.Datas.FishData:RemoveFish(product.ItemID)
                if c >= n then
                    return
                end
            end
        end
    end
end

-- GM工具调用，解锁下一条鱼
function SeaData:GMUnlockNextFish(n)
    local c = 0
    for _,sea in pairs(self.seas) do
        local seaCfg = SeaConfig.SeasByID[sea.ID]
        for _,v in ipairs(seaCfg.Products) do
            local product = SeaConfig.ProductsByID[v]
            if product.Type == CommonItemType.Fish then
                if PlayerData.Datas.FishData:GetFish(product.ItemID) == nil then
                    c = c+1
                    PlayerData.Datas.FishData:AddFish(product.ItemID)
                    if c >= n then
                        return
                    end
                end
            end
        end
    end
end

-- GM工具调用，解锁全部鱼类
function SeaData:GMUnlockAllFish()
    for _,sea in pairs(self.seas) do
        local seaCfg = SeaConfig.SeasByID[sea.ID]
        for _,v in ipairs(seaCfg.Products) do
            local product = SeaConfig.ProductsByID[v]
            if product.Type == CommonItemType.Fish then
                PlayerData.Datas.FishData:AddFish(product.ItemID)
            end
        end
    end
end

-- GM工具调用，解锁全部海域
function SeaData:GMUnlockAllSea()
    local seasCfg = SeaConfig.Seas
    for i, v in ipairs(seasCfg) do
        if not self:SeaUnlocked(v.ID) then
            self:OpenSea(v.ID)
        end
    end
end

-- 获取产出列表
function SeaData:GetProducts(seaID)
    local seaCfg = SeaConfig.SeasByID[seaID]

    local p = {}
    for _,v in ipairs(seaCfg.Products) do
        table.insert(p, SeaConfig.ProductsByID[v])
    end

    return p
end

-- 海域是否已解锁
function SeaData:SeaUnlocked(seaID)
    return nil ~= self.seas[seaID]
end

-- 下个海域
function SeaData:GetNextSea()
    local seasCfg = SeaConfig.Seas
    local nextId
    local order = 0
    for i, v in ipairs(seasCfg) do
        if not self:SeaUnlocked(v.ID) then
            nextId = v.ID
            order = i
            break
        end
    end
    return nextId, order
end

-- 获取最新解锁的海域
function SeaData:GetLastSea()
    local seasCfg = SeaConfig.Seas
    local lastID
    for i, v in ipairs(seasCfg) do
        if not self:SeaUnlocked(v.ID) then
            break
        end
        lastID = v.ID
    end
    return lastID
end

return SeaData