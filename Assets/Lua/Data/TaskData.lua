
-- 任务
local TaskData = class()

-- 任务类型，与策划约定
-- 1	累计解锁N个鱼
-- 2	累计鱼类【成长】了N次
-- 3	累计解锁N个装饰物
-- 4	累计装饰物【成长】了N次
-- 5	累计解锁N个海域
-- 6	获得成就称号-名字名字（即达成N个成就并领取宝箱）
-- 7	累计【进修】N次
-- 8	解锁指定海域
-- 9	指定1个或多个鱼类条目达到NN级
-- 10	指定1个或多个装饰物条目达到NN级
-- 11	【进修】指定科技条目
-- 12	指定观赏馆的培养进度达成NN%
-- 13	秒产出>=填写的参数值
-- 14	累计收益金币数>=填写的参数值
-- 15	累计打开N个漂流宝箱（是不是广告的都计入）
-- 16	累计通过点击场景赚取收益N次
-- 17	累计观看广告NN次
-- 18	累计沉船探宝NN次（任意一档都计数）
-- 19   观赏馆指定展示项目已解锁
-- 20   解锁指定观赏馆
-- 21   解锁指定功能

function TaskData:CreateData()
    -- 已完成主线任务
    self.endMainTasks = {}
    -- 当前主线任务
    self.curMainTask = nil
    self.reportedMainTask = {}
    self.reportedAchivementTask = {}
end

function TaskData:updateData(data)
    self:CreateData()
    if not data then return end

    self.curMainTask = data.curMainTask
    if data.endMainTasks then
        for id, v in pairs(data.endMainTasks) do
            self.endMainTasks[id] = v
        end
    end

    if data.reportedMainTask then
        for k, v in ipairs(data.reportedMainTask) do
            self.reportedMainTask[v] = v
        end
    end
    if data.reportedAchivementTask then
        for k, v in ipairs(data.reportedAchivementTask) do
            self.reportedAchivementTask[v] = v
        end
    end
end

function TaskData:Save(data)
    data.curMainTask = self.curMainTask
    if next(self.endMainTasks) then
        local list = {}
        for id, v in pairs(self.endMainTasks) do
            list[id] = v
        end
        data.endMainTasks = list
    end

    data.achieveTitleId = self.achieveTitleId
    if next(self.reportedMainTask) then
        local reportedMainTask = {}
        for k, v in pairs(self.reportedMainTask) do
            table.insert(reportedMainTask, k)
        end
        data.reportedMainTask = reportedMainTask
    end
    if next(self.reportedAchivementTask) then
        local list = {}
        for id, v in pairs(self.reportedAchivementTask) do
            table.insert(list, id)
        end
        data.reportedAchivementTask = list
    end
end

-------------------------------------- 任务目标条件 ----------------------------------------

-- 对应任务类型是否完成
-- return: 是否完成，进度，总进度(若不等于Target)
TaskData.CheckTargetFunc = {
    [1] = function (param)
        if type(param) == "number" then
            local progress = Utils.GetTableLength(PlayerDatas.FishData.fishes)
            return progress >= param, progress
        end
    
        return false, 0
    end,
    [2] = function (param)
        if type(param) == "number" then
            local progress = 0
            for k, fish in pairs(PlayerDatas.FishData.fishes) do
                progress = progress + fish.growth
            end
            return progress >= param, progress
        end
    
        return false, 0
    end,
    [3] = function (param)
        if type(param) == "number" then
            local progress = Utils.GetTableLength(PlayerDatas.DecorationData.decorations)
            return progress >= param, progress
        end
    
        return false, 0
    end,
    [4] = function (param)
        if type(param) == "number" then
            local progress = 0
            for k, decoration in pairs(PlayerDatas.DecorationData.decorations) do
                progress = progress + decoration.growth
            end
            return progress >= param, progress
        end
    
        return false, 0
    end,
    [5] = function (param)
        if type(param) == "number" then
            local progress = Utils.GetTableLength(PlayerDatas.SeaData.seas)
            return progress >= param, progress
        end
    
        return false, 0
    end,
    [6] = function (target, id)
        local over = PlayerDatas.AchievementData:PassTitle(id)
        return over, over and 1 or 0, 1
    end,
    [7] = function (param)
        if type(param) == "number" then
            local progress = Utils.GetTableLength(PlayerDatas.AdminData.trainList)
            return progress >= param, progress
        end
    
        return false, 0
    end,
    [8] = function (target, seaId)
        local over = PlayerDatas.SeaData:SeaUnlocked(seaId)
        -- 进度只有1
        return over, over and 1 or 0, 1
    end,
    [9] = function (target, ids)
        local over = false
        local progress = 0
        local total = 0
        if type(ids) == "table" then
            total = #ids
            over = true
            for _, id in pairs(ids) do
                if not PlayerDatas.FishData:OwnedFish(id, target) then
                    over = false
                else
                    progress = progress + 1
                end
            end
        else
            total = 1
            over = PlayerDatas.FishData:OwnedFish(ids, target) == true
            progress = over and 1 or 0
        end

        return over, progress, total
    end,
    [10] = function (target, ids)
        local over = false
        local progress = 0
        local total = 0
        if type(ids) == "table" then
            total = #ids
            over = true
            for _, id in pairs(ids) do
                if not PlayerDatas.DecorationData:OwnedDecorationLevel(id, target) then
                    over = false
                else
                    progress = progress + 1
                end
            end
        else
            total = 1
            over = PlayerDatas.DecorationData:OwnedDecorationLevel(ids, target) == true
            progress = over and 1 or 0
        end

        return over, progress, total
    end,
    [11] = function (target, id)
        local over = PlayerDatas.AdminData:IsTrained(id)
        return over, over and 1 or 0, 1
    end,
    [12] = function (target, id)
        local progress = PlayerDatas.AquariumData:GetProgressById(id)
        return progress >= target, progress * 100, target * 100
    end,
    [13] = function (param)
        if type(param) == "number" then
            local progress = PlayerData:GetRealCoinIncome()
            return progress >= param, progress
        end
    
        return false, 0
    end,
    [14] = function (param)
        if type(param) == "number" then
            return PlayerData.coinNum >= param, PlayerData.coinNum
        end
    
        return false, 0
    end,
    [15] = function (param)
        if type(param) == "number" then
            local progress = PlayerDatas.AdvData.openFloatBoxCount
            return progress >= param, progress
        end
    
        return false, 0
    end,
    [16] = function (param)
        
    end,
    [17] = function (param)
        if type(param) == "number" then
            local progress = PlayerDatas.AdvData.clickAdCount
            return progress >= param, progress
        end
    
        return false, 0
    end,
    [18] = function (param)
        if type(param) == "number" then
            local progress = PlayerDatas.AdvData.shipExchangeCount
            return progress >= param, progress
        end
    
        return false, 0
    end,
    [19] = function (target, param)
        local unlock = false
        if type(param) == "number" then
            unlock = PlayerDatas.AquariumData:IsShowItemUnlocked(param)
        end
        local progress = unlock and 1 or 0
    
        return unlock, progress, 1
    end,
    [20] = function (target, id)
        -- 解锁指定观赏馆
        local unlock = nil ~= PlayerDatas.AquariumData:GetAquarium(id)
        local progress = unlock and 1 or 0
    
        return unlock, progress, 1
    end,
    [21] = function (target, id)
        -- 解锁指定功能
        local unlock = PlayerDatas.FunctionOpenData:IsFunctionOpened(id)
        local progress = unlock and 1 or 0
    
        return unlock, progress, 1
    end,
}

-- 任务相关事件
TaskData.Events = {
    Event.FISH_LEVELUP,
    Event.FISH_UNLOCK_SUCCESS,
    Event.FISH_GROWUP,
    Event.AQUARIUM_LEVELUP_DECORATION,
    Event.AQUARIUM_SHOW_ITEM,
    Event.ADMIN_TRAIN_SUCCESS,
    Event.UPGRADE_ACHIEVE_TITLE,
    Event.UPGRADE_ACHIEVE_TITLE,
    Event.UPGRADE_ACHIEVE_TITLE,
    Event.CURRENCY_CHANGED,
}

-------------------------------------- 任务目标条件end ----------------------------------------

-------------------------------------- 对外接口 ----------------------------------------

function TaskData:ReportMainTaskComplete(task)
    if self.reportedMainTask[task.ID] then
        return
    end

    self.reportedMainTask[task.ID] = task.ID
    AnalyticsManager.onMissionEnd("主线任务", task.ID, task.Name)
end

function TaskData:ReportAchivementTaskComplete(task)
    if self.reportedAchivementTask[task.ID] then
        return
    end

    self.reportedAchivementTask[task.ID] = task.ID
    AnalyticsManager.onMissionEnd("成就任务", task.ID, task.Name)
end

-- 任务信息，返回参数 1是否完成 2进度值 3目标值
function TaskData:GetTaskInfo(id)
    local cfg = ConfigData:GetTask(id)
    if cfg and self.CheckTargetFunc[cfg.Type] then
        local param = #cfg.Params > 1 and cfg.Params or cfg.Params[1]
        local finish, progress, total = self.CheckTargetFunc[cfg.Type](cfg.Target, param)
        finish = finish == true
        progress = progress or 0
        total = total or cfg.Target
        return finish, progress, total
    end

    return false, 0, 0
end

function TaskData:IsComplete(id)
    return self:GetTaskInfo(id) == true
end

function TaskData:GetProgress(id)
    local _, progress, target = self:GetTaskInfo(id)
    -- 总进度
    if not target then
        local cfg = ConfigData:GetTask(id)
        target = cfg.Target
    end
    return progress or 0, target
end

-------------------------------------- 对外接口end ----------------------------------------

-------------------------------------- 主线任务 ----------------------------------------

-- 当前主线任务
function TaskData:GetCurMainTask()
    if nil == self.curMainTask then
        for i, v in ipairs(ConfigData.mainTaskConfig.MainTask) do
            if self:IsMainTaskUnlock(v.ID) and nil == self.endMainTasks[v.ID] then
                self.curMainTask = v.ID
                break
            end
        end
    end

    return ConfigData:GetMainTask(self.curMainTask)
end

-- 主线任务已解锁
function TaskData:IsMainTaskUnlock(id)
    local cfg = ConfigData:GetMainTask(id)
    if cfg then
        return cfg.Prev == 0 or nil ~= self.endMainTasks[cfg.Prev]
    end

    return false
end

-- 主线任务已完成
function TaskData:IsMainTaskComplete(id)
    id = id or self.curMainTask
    local cfg = ConfigData:GetMainTask(id)
    if cfg then
        return self:IsComplete(cfg.TaskId)
    end

    return false
end

-- 领取主线任务奖励
function TaskData:GetMainTaskPrize(id)
    if self.endMainTasks[id] or not self:IsMainTaskComplete(id) then return end

    local cfg = ConfigData:GetMainTask(id)
    self.endMainTasks[id] = id
    self.curMainTask = nil
    for i, v in ipairs(ConfigData.mainTaskConfig.MainTask) do
        if self:IsMainTaskUnlock(v.ID) and nil == self.endMainTasks[v.ID] then
            self.curMainTask = v.ID
            break
        end
    end
    local info = {}
    info.RewardType = cfg.RewardType
    info.Reward = cfg.Reward
    info.cfg = cfg
    EventDispatcher:Dispatch(Event.GET_MAIN_TASK_PRIZE, info)
end

function TaskData:MainTaskRed()
    return self:IsMainTaskComplete() == true and nil == self.endMainTasks[self.curMainTask]
end

-- 主线任务已领取
function TaskData:GotMainTaskPrize(id)
    return nil ~= self.endMainTasks[id]
end

-------------------------------------- 主线任务end ----------------------------------------

return TaskData