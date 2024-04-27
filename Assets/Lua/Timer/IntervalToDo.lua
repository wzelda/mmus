-- 间隔执行类--
local IntervalToDo = class()
IntervalToDo.IsWork = false
IntervalToDo.Timer = nil
IntervalToDo.Params = nil
IntervalToDo.Target = nil
IntervalToDo.ToDo = nil
IntervalToDo.intervalTime = nil
IntervalToDo.tempIntervalCount = nil
function IntervalToDo:ctor(isIgnoreTimeScale)
    self.Timer = TimerManager.newTimer(0, false, isIgnoreTimeScale, self.onStart, self.onUpdate, self.onComplete, self,true)
end
-- 计时开始--
function IntervalToDo:onStart()
    self.IsWork = true
end

-- 刷新--
function IntervalToDo:onUpdate(curCd)
    if(self.IsWork)then
        if(self.tempIntervalCount * self.intervalTime <= curCd)then
            if self.ToDo ~= nil and type(self.ToDo) == "function" then
                self.ToDo(self.Target, self.Params)
            end
            self.tempIntervalCount = self.tempIntervalCount + 1
        end
    end
end

--计时结束--
function IntervalToDo:onComplete()
    self.ToDo = nil
    self.Params = nil
    self.Target = nil
    self.IsWork = false
    self.intervalTime = nil
    self.tempIntervalCount = 0
    self.Timer = TimerManager.disposeTimer(self.Timer) 
end

function IntervalToDo:reset()
    self.tempIntervalCount = 1
    self.Timer:reset()
end

-- <param name="maxCd" type="float">执行总时间（-1，无限循环）</param>
-- <param name="intervalTime" type="float">间隔时间（0或nil ,每帧）</param>
-- <param name="toDo" type="function">间隔事件</param>
-- <param name="params" type="function">传入回调参数</param>
-- <param name="target" type="table">传入回调宿主</param>
function IntervalToDo:start(maxCd, intervalTime, toDo, params, target)
    self.ToDo = toDo or 0
    self.intervalTime = intervalTime or 0
    self.tempIntervalCount = 1
    self.Params = params
    self.Target = target
    self.Timer.Speed = 1
    if (maxCd < 0) then
        maxCd = math.huge
    end
    self.Timer:resetMax(maxCd)
    self.Timer:start()
end

return IntervalToDo

