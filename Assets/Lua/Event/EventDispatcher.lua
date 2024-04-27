--事件的派发器
local EventDispatcher = class()
 
-- 默认调用函数
local function PreInvoke(EventName, Func, Object, UserData, ...)
    if Object then
        Func(Object, ...);
    else
        Func(...);
    end
end
 
function EventDispatcher:ctor()
    -- 对象成员初始化
    self.mPreInvokeFunc = PreInvoke;
    self.mEventTable = {};
end
 
-- 添加
function EventDispatcher:Add(EventName, Func, Object, UserData)
    if nil == EventName or nil == Func then return end

    assert(Func);
    self.mEventTable[EventName] = self.mEventTable[EventName] or { };
    local Event = self.mEventTable[EventName];
    if not Object then
        Object = "_StaticFunc";
    end
    Event[Object] = Event[Object] or { };
    local ObjectEvent = Event[Object];
    ObjectEvent[Func] = UserData or true;
end
 
-- 设置调用前回调
--function EventDispatcher:SetDispatchHook(HookFunc)
--    self.mPreInvokeFunc = HookFunc;
--end
 
-- 派发
function EventDispatcher:Dispatch(EventName, ...)    
    assert(EventName);
    local Event = self.mEventTable[EventName];
	if(Event== nil)then
		return;
	end
    for Object, ObjectFunc in pairs(Event) do
        if Object == "_StaticFunc" then
            for Func, UserData in pairs(ObjectFunc) do
                self.mPreInvokeFunc(EventName, Func, nil, UserData, ...);
            end
        else
            for Func, UserData in pairs(ObjectFunc) do
                self.mPreInvokeFunc(EventName, Func, Object, UserData, ...);
            end
        end
    end

end
 
-- 回调是否存在
function EventDispatcher:Exist(EventName)
    assert(EventName);
    local Event = self.mEventTable[EventName];
    if not Event then
        return false;
    end
    -- 需要遍历下map, 可能有事件名存在, 但是没有任何回调的
    for Object, ObjectFunc in pairs(Event) do
        for Func, _ in pairs(ObjectFunc) do
            -- 居然有一个
            return true;
        end
    end
    return false
end

function EventDispatcher:RemoveAll(EventName)
    self.mEventTable[EventName] = nil
end
 
-- 清除
function EventDispatcher:Remove(EventName, Func, Object)
    if nil == EventName or nil == Func then return end

    assert(Func)
    local Event = self.mEventTable[EventName];
    if not Event then
        return
    end
    if not Object then
        Object = "_StaticFunc";
    end
    local ObjectEvent = Event[Object];
    if not ObjectEvent then
        return;
    end
    ObjectEvent[Func] = nil;
end
 
-- 清除对象的所有回调
function EventDispatcher:RemoveObjectAllFunc(EventName, Object)
    assert(Object);
    local Event = self.mEventTable[EventName];
    if not Event then
        return;
    end
    Event[Object] = nil;
end

function EventDispatcher:Clear()
	self.mPreInvokeFunc = nil;
	self.mEventTable = {};
end

return EventDispatcher;