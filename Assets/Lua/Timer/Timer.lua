--------------------------------------------------------------
------------------------计时器--------------------------------
--------------------------------------------------------------
local timeNomralId = 0
local timeIgnoreId = 0

local Timer = class()
-- 实例化Id--
Timer.InstanceId = 0

-- 最大值
Timer.MaxCd = 0
-- 当前值
Timer.CurCd = 0
-- 计时倍率
Timer.Speed = 1

-- 是否自动重置
Timer.IsAutoReset = false
-- 是否忽略timescaler
Timer.IsIgnoreTimeScale = false
-- 是否开始
Timer.IsStart = false
-- 是否暂停
Timer.IsPause = false
-- 计时对象--
Timer.Target = nil
-- 是否为正计时，默认为倒计时
Timer.IsAscend = false

-- 计时开始回掉
function Timer.onStart(t)
end
-- 计时进行回掉
function Timer.onUpdate(t, f)
end
-- 计时结束回掉
function Timer.onComplete(t)
end

function Timer:ctor(maxCd, isAutoReset, isIgnoreTimeScale, funcStart, funcUpdate, funcComplete, target, isAscend)
    self.MaxCd = maxCd
    self.IsAutoReset = isAutoReset
    self.IsIgnoreTimeScale = isIgnoreTimeScale
    self.IsStart = false
    self.IsPause = true

    if isIgnoreTimeScale then
        timeIgnoreId = timeIgnoreId + 1
        self.InstanceId = timeIgnoreId
    else
        timeNomralId = timeNomralId + 1
        self.InstanceId = timeNomralId
    end

    if nil ~= funcStart then
        self.onStart = funcStart
    end
    if nil ~= funcComplete then
        self.onComplete = funcComplete
    end
    if nil ~= funcUpdate then
        self.onUpdate = funcUpdate
    end

    self.Target = target

    self.IsAscend = isAscend or false
end

-- 开始计时
-- <param name="startTime" type="number">可以指定起始时间，否则以默认的时间开始计时</param>
function Timer:start(startTime)
    -- 倒计时
    if not self.IsAscend then
        -- 为数字且大于等于0
        if type(startTime) == "number" and startTime >= 0 then
            self.CurCd = startTime
        else
            self.CurCd = self.MaxCd
        end
        -- 正计时
    else
        -- 为数字且小于等于MaxCd
        if type(startTime) == "number" and startTime <= self.MaxCd then
            self.CurCd = startTime
        else
            self.CurCd = 0
        end
    end

    self.onStart(self.Target)
    self.IsStart = true
    self.IsPause = false
end

function Timer:addCd(f)
    self.CurCd = self.CurCd + f
    self.MaxCd = self.MaxCd + f
end

-- 重置
-- <param name="isSkipComplete" type="bool">重置时是否跳过调用Complete的回调方法，默认跳过</param>
function Timer:reset(isSkipComplete)
    if isSkipComplete ~= nil and not isSkipComplete then
        self.onComplete(self.Target)
    end

    -- 正序计时，从0开始；倒序，从max开始
    if self.IsAscend == true then
        self.CurCd = 0
    else
        self.CurCd = self.MaxCd
    end
end
-- 重置MaxCD
-- <param name="count" type="number">重置最大cd</param>
function Timer:resetMax(count)
    self.MaxCd = count
    self:reset()
end

function Timer:setSpeed(speed)
    self.Speed = speed
end

function Timer:pause()
    self.IsPause = true
end

function Timer:resume()
    self.IsPause = false
end

function Timer:update(f)
    if not self.IsStart or self.IsPause then
        return
    end    
    f = f * self.Speed

    -- 正序计时
    if self.IsAscend == true then
        self.CurCd = self.CurCd + f
    else
        self.CurCd = self.CurCd - f
    end

    self.onUpdate(self.Target, self.CurCd)

    -- 计时是否结束
    if self.IsAscend == true then
        if self.CurCd < self.MaxCd then
            return
        end
    else
        if self.CurCd > 0 then
            return
        end
    end

    self.IsStart = false
    self.onComplete(self.Target)

    if self.IsAutoReset then
        self:reset()
        self:start()
    end
end

function Timer:OnDispose()
    self.Target = nil
    self.onStart = nil
    self.onUpdate = nil
    self.onComplete = nil
end

return Timer