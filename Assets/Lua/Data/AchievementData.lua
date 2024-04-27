
-- 成就
local AchievementData = class()

function AchievementData:CreateData()
    -- 称号id
    self.achieveTitleId = nil
    -- 已领取成就奖励
    self.collectedPrizeList = {}
    -- 已领取头衔奖励
    self.collectedTitlePrize = {}
end

function AchievementData:updateData(data)
    self:CreateData()
    if not data then return end

    self.achieveTitleId = data.achieveTitleId
    if nil == self.achieveTitleId then
        -- 初始称号
        self:CurTitle()
    end
    if data.collectedPrizeList then
        for k, v in pairs(data.collectedPrizeList) do
            if type(v) == "number" then
                self.collectedPrizeList[v] = v
            end
        end
    end
    if data.collectedTitlePrize then
        for k, v in pairs(data.collectedTitlePrize) do
            if type(v) == "number" then
                self.collectedTitlePrize[v] = v
            end
        end
    end
end

function AchievementData:Save(data)
    data.achieveTitleId = self.achieveTitleId
    if next(self.collectedPrizeList) then
        local collectedPrizeList = {}
        for k, v in pairs(self.collectedPrizeList) do
            table.insert(collectedPrizeList, v)
        end
        data.collectedPrizeList = collectedPrizeList
    end
    if next(self.collectedTitlePrize) then
        local list = {}
        for id, v in pairs(self.collectedTitlePrize) do
            table.insert(list, v)
        end
        data.collectedTitlePrize = list
    end
end

-------------------------------------- 对外接口 ----------------------------------------

-- 当前称号
function AchievementData:CurTitle()
    if nil == self.achieveTitleId then
        local cfg = ConfigData.achievementConfig.AchievementTitle[1]
        self.achieveTitleId = cfg and cfg.ID
    end

    return ConfigData:GetAchieveTitle(self.achieveTitleId)
end

-- 下一级称号
function AchievementData:NextTitle()
    if nil == self.achieveTitleId then
        self:CurTitle()
    end
    local allCfg = ConfigData.achievementConfig.AchievementTitle
    for i, v in ipairs(allCfg) do
        if v.ID == self.achieveTitleId then
            return allCfg[i + 1]
        end
    end

    return nil
end

-- 已获得称号
function AchievementData:PassTitle(titleId)
    return nil ~= self.achieveTitleId and self.achieveTitleId >= titleId
end

-- 成就已解锁
function AchievementData:IsAchieveUnlock(id)
    local cfg = ConfigData:GetAchieveTask(id)
    if cfg.Prev == 0 or self.collectedPrizeList[cfg.Prev] then
        return true
    end

    return false
end

-- 成就已领取
function AchievementData:IsAchieveCollect(id)
    return nil ~= self.collectedPrizeList[id]
end

-- 成就达成
function AchievementData:IsComplete(id)
    local cfg = ConfigData:GetAchieveTask(id)
    if nil == cfg then return false end

    if PlayerDatas.TaskData:IsComplete(cfg.TaskId) then
        return true
    end

    return false
end

-- 领取成就奖励
function AchievementData:GetAchievePrize(id, multiple)
    if not self:IsAchieveCollect(id) and self:IsComplete(id) then
        self.collectedPrizeList[id] = id
        local info = {}
        local cfg = ConfigData:GetAchieveTask(id)
        if cfg then
            multiple = multiple or 1
            info.RewardType = cfg.RewardType
            info.Reward = cfg.Reward * multiple
            info.cfg = cfg
            PlayerData:RewardMoney(info.RewardType, info.Reward)
        end
        EventDispatcher:Dispatch(Event.GET_ACHIEVE_PRIZE, info)
    end
end

-- 累计达成成就数，领取后才算达成
function AchievementData:AchieveNum()
    return Utils.GetTableLength(self.collectedPrizeList)
end

-- 头衔进度已达成
function AchievementData:TitleAchieved()
    local cfg = self:NextTitle()
    if cfg and self:AchieveNum() >= cfg.Condition then
        return true
    end

    return false
end

-- 领取头衔奖励
function AchievementData:CollectTitlePrize()
    if nil == self.collectedTitlePrize[self.achieveTitleId] and self:TitleAchieved() then
        self.collectedTitlePrize[self.achieveTitleId] = self.achieveTitleId
        local info = {}
        local cfg = ConfigData:GetAchieveTitle(self.achieveTitleId)
        if cfg then
            info.RewardType = cfg.RewardType
            info.Reward = cfg.Reward
        end
        self:UpgradeTitle(true)
        local curCfg = ConfigData:GetAchieveTitle(self.achieveTitleId)
        PlayerData:RewardMoney(curCfg.RewardType, curCfg.Reward)
        EventDispatcher:Dispatch(Event.GET_ACHIEVE_TITLE_PRIZE, info)
    end
end

-- 升级头衔
function AchievementData:UpgradeTitle(flag)
    flag = flag or self:TitleAchieved()
    if not flag then
        return false
    end

    local nextCfg = self:NextTitle()
    if nextCfg then
        self.achieveTitleId = nextCfg.ID
        UIManager.OpenPopupUI(UIInfo.AchieveAwardTitleUI)
        EventDispatcher:Dispatch(Event.UPGRADE_ACHIEVE_TITLE)
        return true
    end
end

-- 红点
function AchievementData:Red()
    if not PlayerDatas.FunctionOpenData:IsFunctionOpened(GameSystemType.FID_LIBRARY) then
        return PlayerDatas.FunctionOpenData:ReadyUnlockById(GameSystemType.FID_LIBRARY)
    end
    
    for i, v in ipairs(ConfigData.achievementConfig.AchievementTask) do
        if self:IsAchieveUnlock(v.ID) and self:IsComplete(v.ID)
        and not self:IsAchieveCollect(v.ID) then
            return true
        end
    end
    
    return false
end

return AchievementData