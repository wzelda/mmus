--[[
	@desc:行为树
    author:better
    time:2020-05-14 21:37:00
]]
local BehaviorTaskFactory = {}

local function bindCall(target, func)
    if target[func] then
        return function(...) target[func](...) end
    end
end

function BehaviorTaskFactory.BindActionTask(taskName, CSAction)
    local action = (require ("BehaviorTree.Action." .. taskName)).new()
    action:OnAwake(CSAction)
    CSAction:BindLua(
        bindCall(action, "OnStart"),
        bindCall(action, "OnUpdate"),
        bindCall(action, "OnLateUpdate"),
        bindCall(action, "OnFixedUpdate"),
        bindCall(action, "OnEnd"),
        bindCall(action, "OnPause"),
        bindCall(action, "OnConditionalAbort"),
        bindCall(action, "GetPriority"),
        bindCall(action, "GetUtility"),
        bindCall(action, "OnBehaviorRestart"),
        bindCall(action, "OnBehaviorComplete"),
        bindCall(action, "OnReset"),
        bindCall(action, "OnDrawGizmos")
    )
end

function BehaviorTaskFactory.BindConditionTask(taskName, CSCondition)
    local action = (require ("BehaviorTree.Conditional." .. taskName)).new()
    action:OnAwake(CSCondition)
    CSCondition:BindLua(
        bindCall(action, "OnStart"),
        bindCall(action, "OnUpdate"),
        bindCall(action, "OnLateUpdate"),
        bindCall(action, "OnFixedUpdate"),
        bindCall(action, "OnEnd"),
        bindCall(action, "OnPause"),
        bindCall(action, "OnConditionalAbort"),
        bindCall(action, "GetPriority"),
        bindCall(action, "GetUtility"),
        bindCall(action, "OnBehaviorRestart"),
        bindCall(action, "OnBehaviorComplete"),
        bindCall(action, "OnReset"),
        bindCall(action, "OnDrawGizmos")
    )
end

CS.LPCFramework.LuaAction.CreateAction = BehaviorTaskFactory.BindActionTask
CS.LPCFramework.LuaCondition.CreateCondition = BehaviorTaskFactory.BindConditionTask
return BehaviorTaskFactory