-- 提示
local Tips = { }

-- 消息管理
local Msgs = { }
-- 消息池
Msgs.Pool = { }
-- 时间
local time = 1
-- 计时器
local timer = nil
-- 正在计时
local isPlaying = false
-- view管理
local TipsView = { }
-- view池
TipsView.Pool = { }
-- 使用中
TipsView.InUse = { }

-- 正在弹出的一条内容
local lastContent = nil
-- 战斗中tips开关
local needShowExceptBattle = false

local  function OnExit()
    Tips.clear()
end
EventDispatcher:Add(Event.SCENE_EXIT,OnExit);

local  function OnEnter()
    if needShowExceptBattle then
        return
    end
    needShowExceptBattle = false
    if 0 ~= #Msgs.Pool then
        local msg = Msgs.getFromPool()
        if nil ~= msg then
            Tips.show(msg)
        end
    end
end
EventDispatcher:Add(Event.SCENE_ENTER,OnEnter);

-- 获取消息
function Msgs.getFromPool()
    if #Msgs.Pool > 0 then
        local msg = Msgs.Pool[1]
        table.remove(Msgs.Pool, 1)
        return msg
    end
    return nil
end

-- 进入消息池
function Msgs.enterToPool(msg)
    table.insert(Msgs.Pool, msg)
end

-- 获取view
function TipsView.getFromPool(_cb)
    local view = nil
    if #TipsView.Pool > 0 then
        view = TipsView.Pool[1]
        view.Root.sortingOrder = UISortOrder.MsgTips
        table.remove(TipsView.Pool, 1)
        table.insert(TipsView.InUse, view)
        if _cb then
            _cb(view)
        end
    else
        UIManager.CreateFairyCom(UIInfo.TipsUI.UIPackagePath, UIInfo.TipsUI.UIName, UIInfo.TipsUI.UIComName , true, function(ui, pkgId)
            view = {}
            local child = ui:GetChild("Component_Main")
            ui.sortingOrder = UISortOrder.MsgTips
            ui.touchable = false;
            view.Root = ui
            view.PkgId = pkgId
            view.Effect = ui:GetTransition("Effect_T")
            view.Content = child:GetChild("Text_Content")
            table.insert(TipsView.InUse, view)
            if _cb then
                _cb(view)
            end
        end)
    end
    
end

-- 返回池view
function TipsView.backToPool(view)
    view.Root.sortingOrder = UISortOrder.MsgTips - 1
    view.Root.visible = false
    table.insert(TipsView.Pool, view)
    local index = nil
    for i , v in ipairs(TipsView.InUse) do
        if view == v then
            index = i
            break
        end
    end
    if nil ~= index then
        table.remove(TipsView.InUse, index)
    end
end

-- 计时开始
local function timerStart()
    isPlaying = true
end

-- 计时结束
local function timerComplete()
    isPlaying = false
    local msg = Msgs.getFromPool()
    if nil ~= msg then
        Tips.show(msg)
    end
end

-- 是否在需要缓存的界面
local function IsNeedPool()
    return UIManager.controllerIsOpen(UIManager.ControllerName.PreBattle)
    or UIManager.controllerIsOpen(UIManager.ControllerName.PveChapterMain)
end

--需要缓存显示的tips
function Tips.showInPool(msg)
    if not IsNeedPool()  then
        Tips.show(msg)
    else
        if nil == timer then
            timer = TimerManager.newTimer(time, false, false, timerStart, nil, timerComplete)
        end
        needShowExceptBattle = true
        -- 和正在弹出内容相同则return
        if nil ~= lastContent and lastContent == msg then
            return
        else
            Msgs.enterToPool(msg)
        end
    end
end

-- 显示
-- content 表示显示文本内容
function Tips.show(content,showType)
    local msg = content
    if nil == timer then
        timer = TimerManager.newTimer(time, false, true, timerStart, nil, timerComplete)
    end
    if showType ~= TipMsgType.COVER then
        if not isPlaying then
            lastContent = msg

            timer:reset()
            timer:start()
            TipsView.getFromPool(function(view)
                view.Root.visible = true
                view.Content.text = msg
                view.Effect:Play( function() TipsView.backToPool(view) end)
            end)
        else
            -- 和正在弹出内容相同则return
            if nil ~= lastContent and lastContent == msg then
                return
            else
                Msgs.enterToPool(msg)
            end
        end
    else 
        if isPlaying then
            Msgs.Pool={}        
            Tips.clear()
        end
        Tips.show(content)
    end
end

-- 清除
function Tips.clear()
    for _, v in pairs(TipsView.InUse) do
        v.Effect:Stop()
        UIManager.DisposeFairyCom(v.PkgId,v.Root)
    end
    for _, v in pairs(TipsView.Pool) do
        v.Effect:Stop()
        UIManager.DisposeFairyCom(v.PkgId,v.Root)
    end
    TipsView.Pool = { }
    TipsView.InUse = { }
    Msgs.Pool = { }
end

-- 销毁
function Tips.destroy()
    EventDispatcher:Remove(Event.SCENE_ENTER,OnExit);
    EventDispatcher:Remove(Event.SCENE_ENTER,OnEnter);
    Tips.clear()
end

return Tips

