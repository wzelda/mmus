
local FunctionOpenConfig = Utils.LoadConfig("Config.FunctionOpenConfig")

local FunctionOpenData = class()

function FunctionOpenData:CreateData()
    self.functions = {}
    self.unlockedFuncs = {}

    -- 初始化开放功能
    for _,v in ipairs(FunctionOpenConfig.Functions) do
        if v.UnlockType == CommonCostType.Free then
            self:OpenFunction(v.ID)
        end
    end
end

-- 解锁功能+消耗材料
function FunctionOpenData:OpenFunctionConsume(func)
    if func.UnlockType == CommonCostType.Coin or func.UnlockType == CommonCostType.CoinAD then
        PlayerData:ConsumeCoin(func.UnlockCost)
    elseif func.UnlockType == CommonCostType.Diamond or func.UnlockType == CommonCostType.DiamondAD then
        PlayerData:ConsumeDiamond(func.UnlockCost)
    elseif func.UnlockType ~= CommonCostType.Free then
        Utils.DebugError("Can't unlock item "..tostring(func.ID))
        return false
    end

    self:OpenFunction(func.ID)
    AnalyticsManager.onUnlockSystem(func.ID)
end

-- 解锁功能
function FunctionOpenData:OpenFunction(functionID)
    if nil == self.functions[functionID] then
        local f = {ID=functionID}
        self.functions[functionID] = f

        -- 子系统初始化
        if functionID == GameSystemType.FID_AQUARIUM then
            PlayerDatas.AquariumData:OnFunctionOpen()
        elseif functionID == GameSystemType.FID_IMPROVE then
            PlayerDatas.AdminData:OnFunctionOpen()
        end
    end
end

-- 是否可以解锁
function FunctionOpenData:ReadyUnlockFunc(func)
    if func.IncomeSpeed ~= 0 then
        return PlayerData:GetRealCoinIncome() >= func.IncomeSpeed
    else
        if func.UnlockType == CommonCostType.Free then
            return true
        elseif func.UnlockType == CommonCostType.Coin then
            return PlayerData.coinNum >= func.UnlockCost
        elseif func.UnlockType == CommonCostType.Diamond then
            return PlayerData.diamondNum >= func.UnlockCost
        --elseif CommonCostType.IsAD(func.UnlockType) then
        --    return true
        else
            return false
        end
    end
end

-- 是否可以解锁，传功能id
function FunctionOpenData:ReadyUnlockById(funcID)
    local func = FunctionOpenConfig.FunctionsByID[funcID]
    if nil == func then return true end
    
    return self:ReadyUnlockFunc(func)
end

-- 是否解锁
function FunctionOpenData:CheckUnlock(funcID)
    if self.unlockedFuncs[funcID] then return true end

    local func = FunctionOpenConfig.FunctionsByID[funcID]
    if nil == func then return true end

    local mainTaskFinish = func.MainTask == 0 or PlayerDatas.TaskData:GotMainTaskPrize(func.MainTask)
    if mainTaskFinish then
        return true
    end

    return false
end

-- 检测功能解锁
function FunctionOpenData:CheckAllFuncOpen()
    if self.dispatched == nil then
        self.dispatched = {}
    end
    for funcID, func in pairs(FunctionOpenConfig.FunctionsByID) do
        -- 目前只有主线任务解锁
        if func.MainTask ~= 0 then
            if self:CheckUnlock(funcID) and not self.unlockedFuncs[funcID] then
                PlayerData.Datas.FishShipData:Unlock(func.ID)
                EventDispatcher:Dispatch(Event.UNLOCK_FUNC, funcID)
                self.dispatched[funcID] = true
                if nil == self.unlockedFuncs[funcID] then
                    self.unlockedFuncs[funcID] = funcID
                end
            end
        end
    end
end

-- 是否开放功能
function FunctionOpenData:IsFunctionOpened(id)
    if nil ~= self.functions[id] then
        return true
    end

    local func = FunctionOpenConfig.FunctionsByID[id]

    if func then
        if func.UnlockType == CommonCostType.Free then
            self:OpenFunction(id)
            return true
        end
    end

    return false
end

function FunctionOpenData:updateData(data)
    if data.functions then
        local functions = {}
        for _,v in ipairs(data.functions) do
            functions[v.ID] = v
        end
        self.functions = functions
    else
        self:CreateData()
    end

    self.unlockedFuncs = {}
    if data.unlockedFuncs then
        for _,v in ipairs(data.unlockedFuncs) do
            self.unlockedFuncs[v] = v
        end
    end

    EventDispatcher:Remove(Event.CURRENCY_CHANGED, self.CheckAllFuncOpen, self)
    EventDispatcher:Add(Event.CURRENCY_CHANGED, self.CheckAllFuncOpen, self)
end

function FunctionOpenData:Save(data)
    local functions = {}
    for _,v in pairs(self.functions) do
        table.insert(functions, v)
    end
    data.functions = functions
    local unlockedFuncs = {}
    for _,v in pairs(self.unlockedFuncs) do
        table.insert(unlockedFuncs, v)
    end
    data.unlockedFuncs = unlockedFuncs
end

-- GM工具调用，解锁全部功能
function FunctionOpenData:GMUnlockAll()
    for _,v in ipairs(FunctionOpenConfig.Functions) do
        self:OpenFunction(v.ID)
    end
end

return FunctionOpenData