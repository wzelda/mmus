--[[
	@desc:Lua层行为树Action基类
    author:better
    time:2020-04-15 10:46:32
]]
local BaseBehaviorAction = class()
BaseBehaviorAction.CSharpAction = nil
BaseBehaviorAction.actor = nil
BaseBehaviorAction.sceneObjMgr = nil
BaseBehaviorAction.behaviorTree = nil

-- OnAwake is called once when the behavior tree is enabled. Think of it as a constructor
function BaseBehaviorAction:OnAwake(CSharpAction)
    self.CSharpAction = CSharpAction
    self.sceneObjMgr = BattleManager.curBattle.sceneObjManager
    self.behaviorTree = self.CSharpAction.Owner
    local sharedInt = self.behaviorTree:GetVariable(BehaviorDefine.ActorIdName)
    if (sharedInt ~= nil) then
        self.actor = self.sceneObjMgr:FindActor(sharedInt.Value)
        if (not self.actor) then
            Utils.DebugError("行为树节点未找到绑定角色：%s", sharedInt.Value, self.behaviorTree.name)
        end
    else
        Utils.DebugError("行为树未定义变量ActorId")
    end
end

-- OnStart is called immediately before execution. It is used to setup any variables that need to be reset from the previous run
function BaseBehaviorAction:OnStart()
end

-- OnUpdate runs the actual task
function BaseBehaviorAction:OnUpdate()
    return BehaviorTaskStatus.Success
end

-- OnLateUpdate gets called during Unity's LateUpdate callback
function BaseBehaviorAction:OnLateUpdate()
end

-- OnFixedUpdate gets called during Unity's FixedUpdate callback
function BaseBehaviorAction:OnFixedUpdate()
end

-- OnEnd is called after execution on a success or failure
function BaseBehaviorAction:OnEnd()
end

-- OnPause is called when the behavior is paused and resumed
function BaseBehaviorAction:OnPause(paused)
end

-- OnConditionalAbort is called when the task is aborted from a conditional abort
function BaseBehaviorAction:OnConditionalAbort()
end

-- Allows for the tasks to be arranged in a priority
function BaseBehaviorAction:GetPriority()
    return 0
end

-- Allows for the tasks to be executed according to Utility AI Theory
function BaseBehaviorAction:GetUtility()
    return 0
end

-- OnBehaviorRestart is called after the behavior tree restarts
function BaseBehaviorAction:OnBehaviorRestart()
end

-- OnBehaviorComplete is called after the behavior tree finishes executing
function BaseBehaviorAction:OnBehaviorComplete()
    self.CSharpAction = nil
    self.sceneObjMgr = nil
    self.behaviorTree = nil
    self.actor = nil
end

-- OnReset is called by the inspector to reset the public properties
function BaseBehaviorAction:OnReset()
end

-- Allow OnDrawGizmos to be called from the tasks
function BaseBehaviorAction:OnDrawGizmos()
end

return BaseBehaviorAction
