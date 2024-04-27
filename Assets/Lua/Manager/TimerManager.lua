local TimerManager = {}

local Timer = require "Timer.Timer"
local DelayToDo = require "Timer.DelayToDo"
local IntervalToDo = require "Timer.IntervalToDo"
-- 当前帧时间
local theCurrRealtime = 0
-- 上一帧时间
local theLastRealtime = CS.UnityEngine.Time.realtimeSinceStartup
-- 计时器池--
local isUpdateTimeNormal = false
local TimeNormalCenter = setmetatable({}, {__mode = "k"})
local TimeNormalAddQueue = setmetatable({}, {__mode = "k"})
local TimeNormalRemoveQueue = setmetatable({}, {__mode = "k"})
local isUpdateTimeIgnore = false
local TimeIgnoreCenter = setmetatable({}, {__mode = "k"})
local TimeIgnoreAddQueue = setmetatable({}, {__mode = "k"})
local TimeIgnoreRemoveQueue = setmetatable({}, {__mode = "k"})

-- 当前服务器时间
TimerManager.lastServerTime = os.time() -- 最近同步的服务器时间
TimerManager.currentTime = os.time()
TimerManager.GetServerTime = theLastRealtime
-- 当前服务器时间,用于客户端显示
TimerManager.currentShowTime = TimerManager.currentTime

TimerManager.deltaTime = 0
TimerManager.ignoreDeltaTime = 0
TimerManager.fixedDeltaTime = CS.UnityEngine.Time.fixedDeltaTime

-- 服务器每日重置时间
TimerManager.serverDailyResetTime = "00:00"
-- 服务器与客户端时间差(比服务器时间早,则为正值)
TimerManager.serverTimeDifference = 0

-- 与服务器的Ping值
TimerManager.ping = 0

-- 正常计时--
local function timeNormalUpdate()
    if TimeNormalCenter == nil then
        return
    end
    isUpdateTimeNormal = true
    for k, v in pairs(TimeNormalCenter) do
        if v ~= nil then
            v:update(Time.fixedDeltaTime)
        end
    end
    isUpdateTimeNormal = false
    --添加
    for k, timer in pairs(TimeNormalAddQueue) do
        TimeNormalCenter[timer.InstanceId] = timer
    end
    Utils.ClearTable(TimeNormalAddQueue)
    --移除
    for timerId, v in pairs(TimeNormalRemoveQueue) do
        TimeNormalCenter[timerId] = nil
    end
    Utils.ClearTable(TimeNormalRemoveQueue)
end

-- 忽略timeScaler计时--
local function timeIgnoreUpdate(f)
    if TimeIgnoreCenter == nil then
        return
    end
    isUpdateTimeIgnore = true
    for k, v in pairs(TimeIgnoreCenter) do
        if v ~= nil then
            v:update(f)
        end
    end
    isUpdateTimeIgnore = false
    --移除
    for timerId, v in pairs(TimeIgnoreRemoveQueue) do
        TimeIgnoreCenter[timerId] = nil
    end
    Utils.ClearTable(TimeIgnoreRemoveQueue)
    --添加
    for k, timer in pairs(TimeIgnoreAddQueue) do
        TimeIgnoreCenter[timer.InstanceId] = timer
    end
    Utils.ClearTable(TimeIgnoreAddQueue)
end

-- 添加计时器--
local function addTimer(t, isIgnoreTimeScale)
    if isIgnoreTimeScale then
        if (isUpdateTimeIgnore) then
            TimeIgnoreAddQueue[t.InstanceId] = t
        else
            TimeIgnoreCenter[t.InstanceId] = t
        end
    else
        if (isUpdateTimeNormal) then
            TimeNormalAddQueue[t.InstanceId] = t
        else
            TimeNormalCenter[t.InstanceId] = t
        end
    end
end

-- 更新服务器时间
function TimerManager.updateServerTime(clientTime, serverTime)
    TimerManager.lastServerTime = math.max(Time.realtimeSinceStartup - clientTime, 0) / 2 + serverTime
    TimerManager.GetServerTime = Time.realtimeSinceStartup
    TimerManager.currentTime = TimerManager.lastServerTime
    TimerManager.currentShowTime = TimerManager.currentTime
end

-- 移除计时器--
local function removeTimer(timer)
    if timer.IsIgnoreTimeScale then
        if (isUpdateTimeIgnore) then
            TimeIgnoreRemoveQueue[timer.InstanceId] = true
        else
            TimeIgnoreCenter[timer.InstanceId] = nil
        end
    else
        if (isUpdateTimeIgnore) then
            TimeNormalRemoveQueue[timer.InstanceId] = true
        else
            TimeNormalCenter[timer.InstanceId] = nil
        end
    end
    timer:OnDispose()
end
-- 初始化--
function TimerManager.initialize()
end

-- 更新
function TimerManager.update()
    -- 忽略timeScaler
    theCurrRealtime = Time.realtimeSinceStartup
    TimerManager.ignoreDeltaTime = theCurrRealtime - theLastRealtime
    theLastRealtime = theCurrRealtime
    timeIgnoreUpdate(TimerManager.ignoreDeltaTime)

    TimerManager.deltaTime = Time.deltaTime
    -- 等服务器通知时间后，这里要算的是服务器时间
    TimerManager.currentTime = TimerManager.lastServerTime + theCurrRealtime - TimerManager.GetServerTime
    TimerManager.currentShowTime = TimerManager.currentTime
end

-- 固定更新
function TimerManager.fixedUpdate()
    timeNormalUpdate()
end

function TimerManager.setSpeed(speed)
    if (TimeNormalCenter) then
        for k, v in pairs(TimeNormalCenter) do
            if v ~= nil then
                v:setSpeed(speed)
            end
        end
    end
    if (TimeIgnoreCenter) then
        for k, v in pairs(TimeIgnoreCenter) do
            if v ~= nil then
                v:setSpeed(speed)
            end
        end
    end
end

function TimerManager.pause()
    --TimerManager.pauseTimeNormal()
    --TimerManager.pauseTimeIgnore()
end

function TimerManager.resume()
    --TimerManager.resumeTimeNormal()
    --TimerManager.resumeTimeIgnore()
end

function TimerManager.pauseTimeNormal()
    --if(TimeNormalCenter)then
    --    for k, v in pairs(TimeNormalCenter) do
    --        if v ~= nil then
    --            v:pause()
    --        end
    --    end
    --end
end

function TimerManager.pauseTimeIgnore()
    --if(TimeIgnoreCenter)then
    --    for k, v in pairs(TimeIgnoreCenter) do
    --        if v ~= nil then
    --            v:pause()
    --        end
    --    end
    --end
end

function TimerManager.resumeTimeNormal()
    --if(TimeNormalCenter)then
    --    for k, v in pairs(TimeNormalCenter) do
    --        if v ~= nil then
    --            v:resume()
    --        end
    --    end
    --end
end

function TimerManager.resumeTimeIgnore()
    --if(TimeIgnoreCenter)then
    --    for k, v in pairs(TimeIgnoreCenter) do
    --        if v ~= nil then
    --            v:resume()
    --        end
    --    end
    --end
end

-- 实例化新计时器--
-- <param name="maxCd" type="numble">时间</param>
-- <param name="isAutoReset" type="boolen">自动重置，如为True,则结束计时时，会自动重置并重新启动计时</param>
-- <param name="isIgnoreTimeScale" type="boolean">是否忽略timescaler</param>
-- <param name="funcStart" type="function">传入计时开始回调</param>
-- <param name="funcUpdate" type="function">传入计时进行回调</param>
-- <param name="funcComplete" type="function">传入计时结束回调</param>
-- <param name="funcHost" type="table">传入回调宿主，self</param>
-- <param name="isAscend" type="bool">是否为正序计时，默认为倒计时</param>
-- <returns> Timer </returns>
function TimerManager.newTimer(maxCd, isAutoReset, isIgnoreTimeScale, funcStart, funcUpdate, funcComplete, funcHost, isAscend)
    local t = Timer.new(maxCd, isAutoReset, isIgnoreTimeScale, funcStart, funcUpdate, funcComplete, funcHost, isAscend)
    addTimer(t, isIgnoreTimeScale)
    return t
end
-- 延时执行--
-- <param name="maxCd" type="numble">时间</param>
-- <param name="speedRate" type="numble">计时速率</param>
-- <param name="func" type="function">传入回调方法</param>
-- <param name="params" type="function">传入回调参数</param>
-- <param name="funcHost" type="table">传入回调宿主</param>
-- <returns> Timer </returns>
function TimerManager.waitTodo(maxCd, speedRate, func, params, funcHost, isIgnoreTimeScale)
    local t = DelayToDo.new(isIgnoreTimeScale)
    t:start(maxCd, speedRate, func, params, funcHost)
    return t.Timer
end

-- 间隔执行--
-- <param name="maxCd" type="numble">时间</param>
-- <param name="intervalTime" type="numble">间隔时间</param>
-- <param name="toDo" type="function">传入回调方法</param>
-- <param name="params" type="function">传入回调参数</param>
-- <param name="funcHost" type="table">传入回调宿主</param>
-- <returns> IntervalToDo </returns>
function TimerManager.intervalTodo(maxCd, intervalTime, toDo, params, target, isIgnoreTimeScale)
    local t = IntervalToDo.new(isIgnoreTimeScale)
    t:start(maxCd, intervalTime, toDo, params, target)
    return t
end

--- 析构指定计时器---
-- <param name="timer" type="timer">计时器实例化</param>
function TimerManager.disposeTimer(timer)
    if timer ~= nil then
        --[[ removeTimer(timer.InstanceId, timer.IsIgnoreTimeScale)
        timer:OnDispose() ]]
        removeTimer(timer)
    end
    timer = nil
end

--清空计时器
function TimerManager.ClearAllTimer()
    for timerId, timer in pairs(TimeNormalCenter) do
        TimerManager.disposeTimer(timer)
    end
    for timerId, timer in pairs(TimeIgnoreCenter) do
        TimerManager.disposeTimer(timer)
    end
    for timerId, timer in pairs(TimeNormalAddQueue) do
        TimerManager.disposeTimer(timer)
    end
    for timerId, timer in pairs(TimeNormalRemoveQueue) do
        TimerManager.disposeTimer(timer)
    end
    for timerId, timer in pairs(TimeIgnoreAddQueue) do
        TimerManager.disposeTimer(timer)
    end
    for timerId, timer in pairs(TimeIgnoreRemoveQueue) do
        TimerManager.disposeTimer(timer)
    end
end

--- 获取此时服务器显示时间---
function TimerManager.getCurServerShowTime()
    return os.date("*t", TimerManager.currentShowTime)
    -- year = tab.year,
    -- month = tab.month,
    -- day = tab.day,
    -- hour = tab.hour,
    -- min = tab.min,
    -- sec = tab.sec
end

--- 获取此时服务器时间---
function TimerManager.getCurServerTime()
    return os.date("!*t", TimerManager.currentTime)
end

-- 时间戳转换(年/月/日 小时:分钟)
function TimerManager.getTimeStamp(second)
    return os.date("%Y/%m/%d %H:%M", second)
end

-- 时间戳转换(年/月/日 小时:分钟:秒)
function TimerManager.getTimeStamp_Full(second)
    return os.date("%Y/%m/%d %H:%M:%S", second)
end

-- 显示当天的时间戳,如果超过24个小时,显示N天前
function TimerManager.getIntradayTimeStamp(timeStamp)
    if timeStamp == nil then
        return
    end
    timeStamp = timeStamp
    -- 秒数(大于等于24个小时的显示XX天前)
    local second = TimerManager.currentTime - timeStamp

    if second >= 86400 then
        return Utils.secondFuzzyConversion(second)
    else
        return os.date("%H:%M:%S", timeStamp)
    end
end

-- 获取当前是周几
function TimerManager.getCurrentWeekendTime()
    local result = os.date("%w", math.ceil(TimerManager.currentTime))
    return tonumber(result)
end

-- 获取当前客户端时间
function TimerManager.getCurrentClientTime()
    return os.time()
end

function TimerManager.getClientTomorrowZeroTimestamp()
    local curTime = os.date("!*t")
    return os.time(
        {
            year = curTime.year,
            month = curTime.month,
            day = curTime.day + 1,
            hour = 0,
            min = 0,
            sec = 0
        }
    )
end

return TimerManager
