-- Jeremy UIPanel
-- 2017-11-27

local unpack = unpack or table.unpack

local function HandleMapOperate()
    local currPanel = UIManager.GetTopOpenUI()
    local f = currPanel and currPanel.PanelInfo and currPanel.PanelInfo.CanOperateMap 
end

-- 注意，所有的逻辑 外部驱动 必须通过事件机制来驱动刷新，外部逻辑不允许存任何UI引用
-- 关闭时必须移除事件，打开时需要从PlayerData中取数据来进行刷新
-- 关闭UI时 切记将注册到C#的 lua回调清空，否则lua虚拟机 无法正常dispose，会造成内存泄漏
local function PanelFactory(panelInfo)
    local Panel = {}
    -- UI数据
    Panel.PanelInfo = panelInfo
    -- FairyGUI 包资源ID
    Panel.PackageId = nil

    -- FairyGUI 实例出来的UI
    Panel.UI = nil

    -- 渲染顺序
    Panel.SortingOrder = nil

    -- 是否打开
    Panel.IsOpen = false

    -- 是否显示
    Panel.IsShow = false

    -- 是否隐藏掉之前的panel
    Panel.HidePrePanel = false

    -- tab支持，默认是没有
    Panel.Tabs = nil
    Panel.curTab = nil
    Panel.IsRegisted = nil
    Panel.parentPanel = nil

    -- region 父类方法，不可重写区域
    Panel.Open = function(self, ...)
        if (self.PanelInfo == nil) then
            return false
        end

        if not self.PanelInfo.DontPlayUIOpenSound then
            AudioManager.PlayEAXSound("ui_open")
        end

        self.IsOpen = true
        self:OnOpen(...)
        self:OnRegister()
        self.IsRegisted = true
        self:OnRefresh(...)
        self:ShowWith(...)
        return true
    end

    -- 用来给页签使用的Open功能，打开而不显示
    Panel.OpenWithoutShow = function(self, ...)
        if (self.PanelInfo == nil) then
            return false
        end

        self.IsOpen = true
        self:OnOpen(...)
        self:OnRefresh()
        return true
    end

    --加进来的也是一个panel
    Panel.AddTab = function(self, panelinfo, parent, cb, ...)
        if self.Tabs == nil then
            self.Tabs = {}
        end
        if parent == nil then
            parent = self.UI
        end
        -- tab名为脚本路径
        local tabName = panelinfo.UILogic
        --延迟Open的调用，比如玩家从来没点过某一个页签，那就省了一些开销
        local panel = LuaPackage.Load(panelinfo.UILogic)
        self.Tabs[tabName] = panel

        panel:LoadAsChild(panelinfo, self, parent, cb, ...)

        return panel
    end

    Panel.LoadAsChild = function(self, panelinfo, parentPanel, parent, cb, ...)
        if panelinfo.UIPackagePath then
            local args = {...}
            self.loadOperation = UIManager.CreateFairyCom(
                panelinfo.UIPackagePath, panelinfo.UIName, panelinfo.UIComName, panelinfo.IsFullScreen,
                function (ui, packagePath)
                    self.loadOperation = nil
                    self.UI = ui
                    self.PackageId = packagePath
                    self.UI.visible = false
                    if panelinfo.ChildIndex then
                        parent:AddChildAt(self.UI, panelinfo.ChildIndex)
                    else
                        parent:AddChild(self.UI)
                    end
                    self.parentPanel = parentPanel
                    self:OpenWithoutShow(unpack(args))
                    if cb then
                        cb(ui, packagePath)
                    end
                end
            )
        else
            self.UI = parent
            self.parentPanel = parentPanel
            self:OpenWithoutShow(...)
            if cb then
                cb()
            end
        end
    end

    Panel.GetTab = function(self, panelinfo)
        if self.Tabs == nil or panelinfo == nil then
            return nil
        end
        return self.Tabs[panelinfo.UILogic]
    end

    Panel.SetActiveTab = function(self, panelinfo, ...)
        local tabName = panelinfo.UILogic
        --允许切换到空状态
        if self.Tabs == nil then
            return false
        end
        local tab = self.Tabs[tabName]
        if nil == tab or nil == tab.UI then return end
        
        EventDispatcher:Dispatch(Event.OPENED_TAB, panelinfo.UIComName)
        if tab == self.curTab then
            if tab then
                tab:OnRegister()
                tab.IsRegisted = true
                tab:ShowWith(...)
            end
            return true
        end
        if self.curTab then
            if self.curTab.IsRegisted then
                self.curTab:OnUnRegister()
                self.curTab.IsRegisted = false
            end
            self.curTab:Hide()
        end
        self.curTab = tab
        if tab then
            tab:OnRegister()
            tab.IsRegisted = true
            tab:ShowWith(...)
        end
    end

    Panel.OpenTab = function(self, panelinfo, ...)
        if panelinfo == nil then
            return
        end
        local args = {...}
        local tab = self:GetTab(panelinfo)
        if tab then
            self:SetActiveTab(panelinfo, ...)
        else
            tab = self:AddTab(panelinfo, nil, function ()
                self:SetActiveTab(panelinfo, unpack(args))
            end, ...)
        end

        return tab
    end

    Panel.HideTab = function(self, panelinfo, ...)
        local tab = self.Tabs[panelinfo.UILogic]
        if tab then
            if tab.IsRegisted then
                tab:OnUnRegister()
                tab.IsRegisted = false
            end
            tab:Hide(...)
        end
        if tab == self.curTab then
            self.curTab = nil
        end
    end

    Panel.Refresh = function(self, ...)
        self:OnRefresh(...)
        if self.Tabs then
            for k, v in pairs(self.Tabs) do 
                v:OnRefresh(...)
            end
        end
    end

    Panel.TouchEnable = function(self, _enable)
        self.UI.touchable = _enable
    end

    Panel.sortingOrder = function(self, _order)
        self.UI.sortingOrder = _order
    end

    Panel.Show = function(self)
        self.IsShow = true
        if self.UI ~= nil and (not Utils.uITargetIsNil(self.UI)) then
            self.UI.visible = true
            self.UI.touchable = true
            self:OnShow(unpack(self.args))
            HandleMapOperate()

            if self.RefreshText ~= nil then
                self:RefreshText()
            end
        end

        if self.curTab then
            self.curTab:OnRegister()
            self.curTab.IsRegisted = true
            self.curTab:Show()
            if self.curTab.RefreshText ~= nil then
                self.curTab:RefreshText()
            end
        end
    end

    Panel.ShowWith = function(self, ...)
        self.args = {...}
        self:Show()
    end

    Panel.Update = function(self)
        self:OnUpdate()
        if self.curTab and self.curTab.OnUpdate then
            self.curTab:OnUpdate()
        end
    end

    Panel.fixedUpdate = function(self)
        self:OnFixedUpdate()
    end

    Panel.Reset = function(self)
        self:OnReset()
    end

    Panel.Hide = function(self, ...)
        self.IsShow = false
        if (self.UI ~= nil and (not Utils.uITargetIsNil(self.UI))) then
            self.UI.visible = false
            self.UI.touchable = false
        end
        if self.curTab then
            if self.curTab.IsRegisted then
                self.curTab:OnUnRegister()
                self.curTab.IsRegisted = false
            end
            self.curTab:Hide(...)
        end
        self:OnHide(...)
        HandleMapOperate()
    end

    Panel.Close = function(self)
        self.IsOpen = false
        if self.IsRegisted then
            self:OnUnRegister()
            self.IsRegisted = false
        end
        self:Hide()
        self:OnClose()
        if self.Tabs then
            for k, v in pairs(self.Tabs) do
                v:Close()
            end
        end
        if self.curTab then
            self.curTab = nil
        end
        if self.parentPanel then
            if self.parentPanel.curTab == self then
                self.parentPanel.curTab = nil
            end
            self.parentPanel = nil
        end
        HandleMapOperate()
    end

    Panel.OnPreLoad = function(self)
    end

    -- 子类初始化UI控件
    Panel.OnOpen = function(self)
    end

    -- 子类绑定各种事件
    Panel.OnRegister = function(self)
    end

    Panel.OnShow = function(self)
    end

    Panel.OnHide = function(self)
    end

    -- 强制刷新,比如网络事件监听，切换语言包，断线重连等
    Panel.OnRefresh = function(self, ...)
    end

    Panel.OnUpdate = function(self)
    end

    Panel.OnFixedUpdate = function(self)
    end

    Panel.OnReset = function(self)
    end

    -- 解绑各类事件
    Panel.OnUnRegister = function(self)
    end

    -- 关闭
    Panel.OnClose = function(self)
    end

    return Panel
end

return PanelFactory
