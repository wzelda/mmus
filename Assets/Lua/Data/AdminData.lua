
local AdminData = class()

local function TechInfo(id)
    local t = {}
    t.ID = id
    t.Index = 0
    t.Cd = 0
    t.Ready = false

    return t
end

function AdminData:CreateData()
    -- 已解锁头衔ID
    self.titleList = {}
    -- 当前头衔ID
    self.titleID = 0
    -- 声望
    self.reputation = 0
    -- 上次营销时间
    self.prevMarketTime = 0
    -- 下次营销时间
    self.nextMarketTime = 0
    -- 营销次数
    self.marketTimes = 0
    -- 当前头衔所需金币
    self.titleCoin = 0
    -- 已进修ID
    self.trainList = {}
    -- 已进修科技信息
    self.techInfoList = {}
end

function AdminData:OnFunctionOpen()
end

function AdminData:updateData(data)
    if not data then return end

    self.titleList = {}
    if data.titleList then
        for _,v in ipairs(data.titleList) do
            self.titleList[v.ID] = v
        end
    end
    self.titleID = data.titleID or 0
    self.reputation = data.reputation or 0
    self.prevMarketTime = data.prevMarketTime or 0
    self.nextMarketTime = data.nextMarketTime or 0
    self.marketTimes = data.marketTimes or 0
    self.techBreaking = data.techBreaking
    self:CalcTitleInfo()

    self.trainList = {}
    if data.trainList then
        for _, v in ipairs(data.trainList) do
            self.trainList[v] = v
            local buffer = ConfigData:GetBufferById(ConfigData:GetAdminTrain(v).Buffer)
            PlayerDatas.BufferData:ActivateBuffer(buffer)
        end
    end
    self.techInfoList = {}
    if data.techInfoList then
        for id, v in pairs(data.techInfoList) do
            if nil == v.Cd then
                v.Cd = 0
            end
            self.techInfoList[tonumber(id)] = v
        end
    end

    self:StartBreakTimer()
end

function AdminData:Save(data)
    if self.titleList then
        local titleList = {}
        for _,v in pairs(self.titleList) do
            table.insert(titleList, v)
        end
        data.titleList = titleList
    end
    data.titleID = self.titleID
    data.reputation = self.reputation
    data.prevMarketTime = self.prevMarketTime
    data.nextMarketTime = self.nextMarketTime
    data.marketTimes = self.marketTimes
    data.techBreaking = self.techBreaking
    
    if next(self.trainList) then
        local trainList = {}
        for _, v in pairs(self.trainList) do
            table.insert(trainList, v)
        end
        data.trainList = trainList
    end
    if next(self.techInfoList) then
        local techInfoList = {}
        for id, v in pairs(self.techInfoList) do
            techInfoList[tostring(id)] = v
        end
        data.techInfoList = techInfoList
    end
end

-------------------------------------- 营销 ----------------------------------------

function AdminData:OnIncomeTimer(player)
    -- 营销暂不开放
    -- local clientTime = TimerManager.getCurrentClientTime()
    -- if PlayerData.coinNum >= self.titleCoin then
    --     -- 达成金币条件
    --     local titleCfg = ConfigData:GetAdminMarketTitle(self.titleID)
    --     if titleCfg then
    --         self.reputation = self.reputation + titleCfg.Rate / 60
    --     end
    -- end
    -- -- 营销冷却
    -- if self.nextMarketTime > clientTime then
    --     self.nextMarketTime = self.nextMarketTime - 1
    -- end
end

-- 当前头衔信息
function AdminData:CalcTitleInfo()
    local titleCfg = ConfigData:GetAdminMarketTitle(self.titleID)
    self.titleCoin = titleCfg and titleCfg.Coin or 0
end

-- 可以营销
function AdminData:CanMarket()
    if PlayerData.coinNum >= self.titleCoin 
    and self.nextMarketTime <= TimerManager.getCurrentClientTime()
    then
        return true
    end

    return false
end

-- 是否当日首次营销
function AdminData:IsDailyFirstMarket()
    if self.prevMarketTime == 0 then
        return true
    end
    local todayUnix = Utils.FormatUnixTime2Date(TimerManager.getCurrentClientTime())
    local zeroUnix = os.time({day=todayUnix.day, month=todayUnix.month, year=todayUnix.year, hour=0, minute=0, second=0})
    return self.prevMarketTime < zeroUnix
end

------------------------------------ 营销end ---------------------------------------

-------------------------------------- 进修 ----------------------------------------

function AdminData:Train(id)
    local techInsInfo = self.techInfoList[id]
    if nil == techInsInfo then
        techInsInfo = TechInfo(id)
        self.techInfoList[id] = techInsInfo
    end
    if self:TechFinished(id) then
        print("tech trained!", id)
        return
    end
    
    local trainCfg, trainId = self:GetCurTrain(id)
    if nil == trainCfg then
        print("居然科技配置为空",id)
        return
    end
    self.trainList[trainId] = trainId
    local buffer = ConfigData:GetBufferById(trainCfg.Buffer)
    PlayerDatas.BufferData:ActivateBuffer(buffer)
    techInsInfo.Index = techInsInfo.Index + 1
    EventDispatcher:Dispatch(Event.ADMIN_TRAIN_SUCCESS, id, trainId)

    -- 统计上报进修的项目，进度
    AnalyticsManager.onJoinSystem(GameSystemType.FID_IMPROVE, trainId, trainCfg.Name, techInsInfo.Index)
end

-- 进修科技条目的下标
function AdminData:GetTechOrder(techId, itemId)
    local tech = ConfigData:GetTech(techId)
    if tech then
        for i, v in ipairs(tech.Trains) do
            if v == itemId then
                return i
            end
        end
    end
    return nil
end

-- 可以进修
function AdminData:CanTrain(id)
    local cfg = ConfigData:GetAdminTrain(id)
    if cfg and self:TrainUnlocked(id)
    and PlayerData:ResEnough(cfg.CostType, cfg.Cost)
    then
        return true
    end

    return false
end

-- 进修项目已解锁
function AdminData:TrainUnlocked(id)
    local cfg = ConfigData:GetAdminTrain(id)
    if nil == cfg then return false end

    if cfg.Prev == 0 or self.trainList[cfg.Prev] then
        return true
    end
    
    return false
end

-- 已进修
function AdminData:IsTrained(id)
    return nil ~= self.trainList[id]
end

-- 科技已完成
function AdminData:TechFinished(id)
    local tech = self.techInfoList[id]
    if tech then
        local cfg = ConfigData:GetTech(tech.ID)
        return tech.Index >= #cfg.Trains
    end
    return false
end

-- 科技已解锁
function AdminData:TechUnlocked(id)
    local cfg = ConfigData:GetTech(id)
    if nil == cfg then return false end

    if DependManager.PassedDepend(cfg.Depends) then
        return true
    end
    return false
end

-- 科技当前项目
function AdminData:GetCurTrain(techId)
    local cfg = ConfigData:GetTech(techId)
    if nil == cfg then return nil end

    local techInfo = self.techInfoList[techId]
    local trainId
    if nil == techInfo then
        if cfg then
            trainId = cfg.Trains[1]
        end
    else
        trainId = cfg.Trains[techInfo.Index + 1]
    end

    return ConfigData:GetAdminTrain(trainId), trainId
end

-- 突破次数
function AdminData:GetBreakNum()
    local num = 0
    for id, _ in pairs(self.techInfoList) do
        if self:TechFinished(id) then
            num = num + 1
        end
    end

    return num
end

function AdminData:UpdateTech(techId)
    if nil == self.techInfoList[techId] then
        self.techInfoList[techId] = TechInfo(techId)
    end
end

function AdminData:TickTechBreak(techId)
    local techCfg = ConfigData:GetTech(techId)
    if nil == techCfg or self:IsBreakCd() then return end
    
    local techInfo = self.techInfoList[techId]
    if nil == techInfo then return end

    techInfo.Cd = techCfg.BreakCd
    self.techBreaking = techId
    self:StartBreakTimer()
end

function AdminData:IsBreakCd()
    if nil ~= self.techBreaking then
        return true
    end

    for _, v in pairs(self.techInfoList) do
        if v.Cd and v.Cd > 0 then
            self.techBreaking = v.ID
            return true
        end
    end

    return false
end

function AdminData:ReadyBreak(dispatch)
    if nil == self.techBreaking then return end


    local techInfo = self.techInfoList[self.techBreaking]
    techInfo.Cd = 0
    techInfo.Ready = true
    self.techBreaking = nil
    if self.techBreakTimer then
        TimerManager.disposeTimer(self.techBreakTimer)
        self.techBreakTimer = nil
    end

    if dispatch ~= false then
        EventDispatcher:Dispatch(Event.ADMIN_TECHBREAK_READY)
    end
end

function AdminData:ClearBreakCd(cb)
    SDKManager:PlayAD(function ()
        self:ReadyBreak(false)
        if cb then
            cb()
        end
    end)
end

function AdminData:StartBreakTimer()
    if not self:IsBreakCd() then return end

    local techInfo = self.techInfoList[self.techBreaking]
    if nil == self.techBreakTimer then
        self.techBreakTimer = TimerManager.newTimer(0, false, true, nil,
            function (t, f)
                self.techInfoList[self.techBreaking].Cd = f
            end, 
            function ()
                self:ReadyBreak()
            end
        )
    end
    self.techBreakTimer:start(techInfo.Cd)
end

-- 切页红点
function AdminData:Red()
    if not PlayerDatas.FunctionOpenData:IsFunctionOpened(GameSystemType.FID_IMPROVE) then
        return PlayerDatas.FunctionOpenData:ReadyUnlockById(GameSystemType.FID_IMPROVE)
    end

    local isBreaking = self:IsBreakCd()
    if isBreaking then
        return false
    end
    -- 改红点条件了
    -- for i, v in ipairs(ConfigData.adminConfig.Technology) do
    --     if not self:TechFinished(v.ID) and self:TechUnlocked(v.ID) then
    --         local trainCfg = self:GetCurTrain(v.ID)
    --         if trainCfg and PlayerData:ResEnough(trainCfg.CostType, trainCfg.Cost) == true then
    --             return true
    --         end
    --     end
    -- end

    local totalNum = 0
    for techId, techInfo in pairs(self.techInfoList) do
        local finish = self:TechFinished(techId)
        if not finish then
            totalNum = totalNum + 1
        end
        if not finish and techInfo.Ready then
            return true
        end
    end
    if totalNum == 0 then
        -- 全部完成
        return false
    end
    if not isBreaking then
        return true
    end

    return false
end

-------------------------------------- 进修end ----------------------------------------

return AdminData