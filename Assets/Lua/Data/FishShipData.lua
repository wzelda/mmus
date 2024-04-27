
-- 成就
local FishShipData = class()

function FishShipData:CreateData()
    self.ships = {
        [1] = true;
        [2] = false;
        [3] = false;
    }
    self.shipsCollectTime = nil
    self.cdShipId = 0
end

function FishShipData:updateData(data)
    self:CreateData()
    if not data then return end
    if data.ships then
        for i, v in ipairs(data.ships) do
            self.ships[i] = v
        end
    end
    self.cdShipId = data.cdShipId or 0
    self.shipsCollectTime = data.shipsCollectTime or nil
    local passedTime = nil
    if self.shipsCollectTime then
        passedTime = TimerManager.getCurrentClientTime() - self.shipsCollectTime
    end
    if self.cdShipId ~= 0 and self.shipsCollectTime ~= nil and passedTime >= 0 then
        if self.cdShipId ~= 0 then
            self.ships[self.cdShipId] = true
            self.cdShipId = 0
        end
    end
    local count = passedTime and math.floor( passedTime/ self:GetCd()) or 0
    if self.cdShipId ~= 0 and count >= 2 then
        for i, v in ipairs(data.ships) do
            self.ships[i] = true
        end
        self.cdShipId = 0
    elseif self.cdShipId == 0 and count >= 3 then
        for i, v in ipairs(data.ships) do
            self.ships[i] = true
        end
        self.cdShipId = 0
    elseif count > 0 then
        for i, v in ipairs(data.ships) do
            if count > 0 and not self.ships[i] then
                self.ships[i] = true
                if i == self.cdShipId then
                    self.cdShipId = 0
                end
                count = count - 1
            end
        end
        self.shipsCollectTime = TimerManager.getCurrentClientTime() + self:GetCd() - passedTime%self:GetCd()
    end
    if PlayerDatas.FunctionOpenData:CheckUnlock(GameSystemType.FID_SHIPFISH) then
        if self.cdShipId == 0  then
            self:StartCdNextShip()
        else
            self:SetShipCd(self.cdShipId)
        end
    end
end

function FishShipData:Save(data)
    local ships = {}
    for i, v in ipairs(self.ships) do
        ships[i] = v
    end
    data.ships = ships
    data.cdShipId = self.cdShipId
    data.shipsCollectTime = self.shipsCollectTime
    
end

-------------------------------------- 对外接口 ----------------------------------------

function FishShipData:CdEend()
    self.ships[self.cdShipId] = true
    self.cdShipId = 0
    self:StartCdNextShip()
end

function FishShipData:SetShipCd(id)
    if id then
        if self.shipsCollectTime == nil or self.shipsCollectTime <= TimerManager.getCurrentClientTime() then
            self.shipsCollectTime = self:GetCd() + TimerManager.getCurrentClientTime()
        end
        if self.timer == nil then
            self.timer = TimerManager.newTimer( self.shipsCollectTime -TimerManager.getCurrentClientTime(), false, true, nil,nil,function()
                self:CdEend()
            end)
        else
            self.timer:resetMax(self.shipsCollectTime -TimerManager.getCurrentClientTime())
        end
        self.timer:start()
    end
end

function FishShipData:StartCdNextShip()
    self.cdShipId = 0
    for i, v in ipairs(self.ships) do
        if not v then
            self.cdShipId = i
            break
        end
    end
    if self.cdShipId ~= 0 then
       self:SetShipCd(self.cdShipId)
    end
    EventDispatcher:Dispatch(Event.SHIPFISH_CD_CLEAR)
end

function FishShipData:Unlock(funcType)
    if self.cdShipId == 0 and funcType == GameSystemType.FID_SHIPFISH then
        self:StartCdNextShip()
    end
end

function FishShipData:GetCd()
    return ConfigData.miscConfig.FishShipByKey["ShipFishingCd"] and ConfigData.miscConfig.FishShipByKey["ShipFishingCd"].Number or 1
end

function FishShipData:GetRewardCount()
    return (ConfigData.miscConfig.FishShipByKey["ShipFishingRewardRate"]
    and ConfigData.miscConfig.FishShipByKey["ShipFishingRewardRate"].Number or 1)*PlayerData:GetRealCoinIncome() 
end

function FishShipData:GetImmediatelyCost()
    return math.floor((ConfigData.miscConfig.FishShipByKey["ShipFishingCost"] and
    ConfigData.miscConfig.FishShipByKey["ShipFishingCost"].Number
    or 1)*((self.shipsCollectTime or 0) -TimerManager.getCurrentClientTime())/self:GetCd())
end

function FishShipData:GetShipReward(id)
    if self.ships[id] then
        self.ships[id] = false
        if self.cdShipId == 0 then
            self:StartCdNextShip(self.cdShipId)
        end
        PlayerData:RewardCoin(self:GetRewardCount())
        EventDispatcher:Dispatch(Event.SHIPFISH_GETREWAD)
    end
end

function FishShipData:ImmediatelyClearCd()
    if self.cdShipId ~= 0 then
        self.ships[self.cdShipId] = true
        local cost = self:GetImmediatelyCost()
        PlayerData:ConsumeDiamond(cost)
        self.shipsCollectTime = nil
        self:StartCdNextShip()

        -- 统计上报立即返航操作
        AnalyticsManager.onJoinSystem(GameSystemType.FID_SHIPFISH, 1, "立即返航", cost)
    end
end

function FishShipData:HasReward()
    for i , v in ipairs(self.ships) do
        if v then
            return true
        end
    end
    return false
end

return FishShipData