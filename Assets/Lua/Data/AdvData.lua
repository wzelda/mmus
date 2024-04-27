
-- 广告
local AdvData = class()

function AdvData:CreateData()
    -- 累计点击广告次数
    self.clickAdCount = 0
    -- 沉船探宝次数
    self.shipExchangeCount = 0
    -- 每日沉船探宝次数
    self.dailyShipExchangeCount = 0
    -- 沉船探宝广告cd
    self.shipAdCd = 0
    -- 打开漂流宝箱次数
    self.openFloatBoxCount = 0
    -- 剩余吃饭时间列表
    self.lunchList = {}
    self.lunchStartList = {}
    self.lunchEndList = {}
    -- 上次领取吃饭奖励时间
    self.lastLunchtime = 0
    self:CheckLunch()
end

function AdvData:updateData(data)
    self:CreateData()
    if not data then return end

    self.clickAdCount = LocalData.getAdClickCount()
    self.shipExchangeCount = LocalData.getShipExchangeCount()
    self.openFloatBoxCount = data.openFloatBoxCount or 0
    self.lastLunchtime = data.lastLunchtime or 0
    local clientTime = TimerManager.getCurrentClientTime()
    local dailyCount = LocalData.getDailyShipExchangeCount()
    if dailyCount and dailyCount ~= "" then
        local info = Utils.stringSplit(dailyCount, "|")
        local dateinfo = Utils.FormatUnixTime2Date(tonumber(info[1]))
        local todayUnix = Utils.FormatUnixTime2Date(clientTime)
        if dateinfo.day == todayUnix.day and dateinfo.month == todayUnix.month and dateinfo.year == todayUnix.year then
            self.dailyShipExchangeCount = tonumber(info[2])
        end
    end
    
    self.shipAdCd = (data.shipAdCd or 0) - (clientTime - LocalData.getOfflineTime())
    self:StartShipCdTimer()
end

function AdvData:Save(data)
    LocalData.saveAdClickCount(self.clickAdCount)
    LocalData.saveShipExchangeCount(self.shipExchangeCount)
    data.openFloatBoxCount = self.openFloatBoxCount
    data.lastLunchtime = self.lastLunchtime
    data.shipAdCd = self.shipAdCd
end

function AdvData:DailyReset()
    self.dailyShipExchangeCount = 0
    self.shipAdCd = 0
end

-------------------------------------- 吃饭时间广告 ----------------------------------------

function AdvData:CheckLunch()
    local curTime = TimerManager.getCurrentClientTime()
    local todayUnix = Utils.FormatUnixTime2Date(curTime)
    local unixinfo = {day=todayUnix.day, month=todayUnix.month, year=todayUnix.year, hour=0, min=0, sec=0}
    self.lunchStartTime = {}
    self.lunchEndTime = {}
    -- 早饭
    unixinfo.hour = 7
    local breakfast1 = os.time(unixinfo)
    table.insert(self.lunchStartTime, breakfast1)
    unixinfo.hour = 10
    local breakfast2 = os.time(unixinfo)
    table.insert(self.lunchEndTime, breakfast2)
    -- 午饭
    unixinfo.hour = 11
    local lunch1 = os.time(unixinfo)
    table.insert(self.lunchStartTime, lunch1)
    unixinfo.hour = 14
    local lunch2 = os.time(unixinfo)
    table.insert(self.lunchEndTime, lunch2)
    -- 晚饭
    unixinfo.hour = 17
    local dinner1 = os.time(unixinfo)
    table.insert(self.lunchStartTime, dinner1)
    unixinfo.hour = 24
    local dinner2 = os.time(unixinfo)
    table.insert(self.lunchEndTime, dinner2)

    self.lunchStartList = {}
    for i, v in ipairs(self.lunchStartTime) do
        if curTime < v then
            table.insert(self.lunchStartList, v)
        end
    end
    self.lunchEndList = {}
    for i, v in ipairs(self.lunchEndTime) do
        if curTime < v then
            table.insert(self.lunchEndList, v)
            -- 处于吃饭时间内
            if curTime >= self.lunchStartTime[i] then
                EventDispatcher:Dispatch(Event.AD_LUNCH_SHOW, true)
            end
        end
    end

    if #self.lunchStartList > 0 then
        if nil == self.lunchStartTimer then
            self.lunchStartTimer = TimerManager.newTimer(0, false, true, nil, nil, function ()
                self:OnLunchStartTimerEnd()
            end)
        end
        self.lunchStartTimer:start(self.lunchStartList[1] - curTime)
    end
    if #self.lunchEndList > 0 then
        if nil == self.lunchEndTimer then
            local onEndUpdate = function (t, f)
                if self.onLunchEndUpdate then
                    self.onLunchEndUpdate(t, f)
                end
            end
            self.lunchEndTimer = TimerManager.newTimer(0, false, true, nil, onEndUpdate, function ()
                self:OnLunchEndTimerEnd()
            end)
        end
        self.lunchEndTimer:start(self.lunchEndList[1] - curTime)
    end
end

function AdvData:OnLunchStartTimerEnd()
    EventDispatcher:Dispatch(Event.AD_LUNCH_SHOW, true)
    table.remove(self.lunchStartList, 1)
    if #self.lunchStartList > 0 then
        self.lunchStartTimer:start(self.lunchStartList[1] - TimerManager.getCurrentClientTime())
    end
end

function AdvData:OnLunchEndTimerEnd()
    EventDispatcher:Dispatch(Event.AD_LUNCH_SHOW, false)
    table.remove(self.lunchEndList, 1)
    if #self.lunchEndList > 0 then
        self.lunchEndTimer:start(self.lunchEndList[1] - TimerManager.getCurrentClientTime())
    end
end

-- 设置吃饭时间计时update函数
function AdvData:SetLunchEndUpdate(callback)
    self.onLunchEndUpdate = callback
end

-- 处于吃饭时间
function AdvData:HavingLunch()
    local curTime = TimerManager.getCurrentClientTime()
    for i, v in ipairs(self.lunchStartTime) do
        if curTime >= v and curTime < self.lunchEndTime[i]
        and not (self.lastLunchtime >= v and self.lastLunchtime < self.lunchEndTime[i])
        then
            return true
        end
    end
    return false
end

function AdvData:DoLunchReward()
    self.lastLunchtime = TimerManager.getCurrentClientTime()
    EventDispatcher:Dispatch(Event.AD_GET_LUNCH_REWARD)
end

-------------------------------------- 吃饭时间广告end ----------------------------------------

function AdvData:AddClickCount()
    self.clickAdCount = self.clickAdCount + 1
    EventDispatcher:Dispatch(Event.AD_ADDTIMES)
end

function AdvData:StartShipCdTimer()
    if self.shipAdCd > 0 then
        if nil == self.shipAdTimer then
            self.shipAdTimer = TimerManager.newTimer(0, false, true, nil,
                function (t, f)
                    self.shipAdCd = f
                end, 
                function ()
                    self.shipAdCd = 0
                end
            )
        end
        self.shipAdTimer:start(self.shipAdCd)
    end
end

function AdvData:GetAdShipTreasure()
    local treasureCfg = ConfigData:GetShipTreasure()
    for _, cfg in pairs(treasureCfg) do
        if cfg.FreeTimes > 0 then
            return cfg
        end
    end
end

function AdvData:AddShipExchangeCount()
    self.shipExchangeCount = self.shipExchangeCount + 1
    self.dailyShipExchangeCount = self.dailyShipExchangeCount + 1
    local dailyCount = string.format("%s|%s", TimerManager.getCurrentClientTime(), self.dailyShipExchangeCount)
    LocalData.saveDailyShipExchangeCount(dailyCount)
    local freeShip = self:GetAdShipTreasure()
    if freeShip and self.dailyShipExchangeCount > freeShip.CdFree then
        self.shipAdCd = freeShip.Cd
        self:StartShipCdTimer()
    end
end

function AdvData:AddOpenFloatBoxCount()
    self.openFloatBoxCount = self.openFloatBoxCount + 1
end

return AdvData