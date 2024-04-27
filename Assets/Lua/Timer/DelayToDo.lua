--延时类--
local DelayToDo = class()
    DelayToDo.IsWork = false
    DelayToDo.Timer = nil
    DelayToDo.Params = nil
    DelayToDo.Target = nil
    DelayToDo.ToDo = nil
	
   function DelayToDo:ctor(isIgnoreTimeScale)
        if nil == isIgnoreTimeScale then
            isIgnoreTimeScale = false
        end

        self.Timer = TimerManager.newTimer(0, false, isIgnoreTimeScale, self.onStart, nil, self.onComplete, self)  
    end
    --计时开始--
    function DelayToDo:onStart()
        self.IsWork = true
    end
    --计时结束--
    function DelayToDo:onComplete()
        if self.ToDo ~= nil and type(self.ToDo) == "function" then
            self.ToDo(self.Target, self.Params)
        end 
        
        self.ToDo = nil
        self.Params = nil
        self.Target = nil
        self.IsWork = false
        TimerManager.disposeTimer(self.Timer) 
        self.Timer = nil
    end
 
    function DelayToDo:start(maxCd, speedRate, toDo, params, target)  
        self.ToDo = toDo
        self.Params = params
        self.Target = target
        self.Timer.Speed = speedRate

        self.Timer:addCd(maxCd - self.Timer.MaxCd)
        self.Timer:start()
    end

 return DelayToDo

