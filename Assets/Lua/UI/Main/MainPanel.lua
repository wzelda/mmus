
local MainPanel = UIManager.PanelFactory(UIInfo.MainUI)

function MainPanel:OnOpen(loadingTask)
    local parent = self.UI.parent
    self.UI.size = parent.size
    self.UI:AddRelation(parent, RelationType.Size)
    self.MainBottomUI = ClassConfig.MainBottomUIClass().new(self.UI, self)
    self.MainTopUI = ClassConfig.MainTopUIClass().new(self.UI, self)
    self.IncomeUI = ClassConfig.IncomeUIClass().new(self.UI, self.MainBottomUI)
    self.sceneHandle = {}
    loadingTask:setLocalProgress(1)
    loadingTask.isDone = true  
end

function MainPanel:OnShow()
    EventDispatcher:Dispatch(Event.MAIN_UI_SHOW)
end

function MainPanel:OnHide()
    EventDispatcher:Dispatch(Event.MAIN_UI_HIDE)
end

-- 调整UI层级
function MainPanel:AdjustTabOrder()
    self.UI:AddChild(self.MainTopUI.UI)
    self.UI:AddChild(self.MainBottomUI.UI)
end

function MainPanel:OnUpdate()
    self.MainTopUI:OnUpdate()
end

function MainPanel:OnRegister()
    -- self.UI.onClick:Set(function() WeakGuideManager:Hide() end)
end

function MainPanel:OnUnRegister()
end

function MainPanel:OnClose()
    self.MainTopUI:Close()
    self.MainBottomUI:Close()
    self.IncomeUI:Dispose()
end

return MainPanel