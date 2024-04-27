-- Jeremy UIManager
-- 2017-11-27
-- 制作UI时要注意，严禁交叉引用

local deferred = require "lib.deferred"

local unpack = unpack or table.unpack

local UIManager = {}
UIPanelFactory = "UI.Core.PanelFactory"
-- 所有的FairyGUI包
local UIPackageRef = nil
--UIManager.Panels= nil
local Stack = nil
--popUI
local curveStack = nil
-- 临时隐藏的界面
local TempHidePanelMap = nil
local PanelFactory = nil

--tips
UIManager.tips = nil
--gmOrder
UIManager.gmOrder = nil
-- 等待界面
UIManager.waiting = nil
--升级界面
UIManager.upgradeUI = nil
-- 各类点击特效
UIManager.clickEffectsUI = nil
-- UI分辨率
UIManager.UIResolution = CS.UnityEngine.Vector2(1920, 1080)
-- 屏幕分辨率
UIManager.ScreenResolution = CS.UnityEngine.Vector2(0, 0)
-- 舞台缩放系数
UIManager.StageScaleFactor = 1
-- UI缩放系数
UIManager.RootScaleFactor = 1

-- 重连时间戳
UIManager.reConnectTimeStamp = nil
-- loading界面是否处于打开状态
UIManager.loadingPanel = nil
-- 主界面自动打开队列
local m_autoOpenQueue = nil

-- 添加一个UI包
local function AddUIPackage(pkgPath, cb)
    return ResourceMgr:LoadUIPkg(pkgPath, function(uipkgid)
        if uipkgid ~= nil then
            local pkgrefcount = UIPackageRef[uipkgid]
            if pkgrefcount ~= nil then
                UIPackageRef[uipkgid] = UIPackageRef[uipkgid] + 1
            else
                UIPackageRef[uipkgid] = 1
            end
        else
            Utils.DebugFatal("load package fail: " .. pkgPath)
        end
        if cb then
            cb(uipkgid)
        end
    end)
end

-- 移除一个UI包
local function RemUIPackage(pkgid, forcedispose)
    if UIPackageRef[pkgid] ~= nil then
        UIPackageRef[pkgid] = UIPackageRef[pkgid] - 1
        if UIPackageRef[pkgid] <= 0 then
            UIPackageRef[pkgid] = 0
            ResourceMgr:UnLoadFairyPackage(pkgid, forcedispose)
        end
    end
end

local function HidePrePanel(panel)
    if panel ~= nil then
        if panel.HidePrePanel then
            local prepanelid = (#Stack) - 1
            local prePanel = Stack[prepanelid]
            if prePanel ~= nil then
                prePanel:Hide()
            end
        end
    end
end

local function HideAllPrePanel()
    for i = #(Stack), 1, -1 do
        if Stack[i].UI and Stack[i].UI.visible then
            Stack[i]:Hide()
        end
    end
end

local function ShowPrePanel(panelid)
    if Stack[panelid] ~= nil then
        local prepanelid = panelid - 1
        local prePanel = Stack[prepanelid]

        if Stack[panelid].HidePrePanel then
            if prePanel ~= nil then

                prePanel:Show()
            -- 打开界面
            --EventDispatcher:Dispatch(Event.OPENED_UI, prePanel.PanelInfo.UIComName)
            end
        end
    end
end

-- 刷新loc事件
local function RefreshLoc()
    for i = (#(Stack)), 1, -1 do
        if Stack[i].UI ~= nil then
            if Stack[i].RefreshText then
                Stack[i]:RefreshText()
            end

            if Stack[i].OnRefresh then
                Stack[i]:OnRefresh()
            end
        end
    end
end

local function RefreshPanel()
    for i = (#(Stack)), 1, -1 do
        if Stack[i].UI ~= nil and Stack[i].RefreshPanel ~= nil then
            Stack[i]:RefreshPanel()
        end
    end
end

-- 重新排列所有ui的渲染层级，自定义层级的不排列
local function SortStackOrder()
    local len = #Stack
    for i = len, 1, -1 do
        if Stack[i].UI and nil == Stack[i].SortingOrder then
            Stack[i].UI.sortingOrder = i * 10
        end
    end
end

local function OnAndroidEscape()
    -- 菊花
    if UIManager.waiting and UIManager.waiting.View.visible then
        return
    end

    local panel = UIManager.GetTopOpenUI()

    if nil == panel or not panel.IsShow then
        return
    end

    -- 不能退出的界面
    if panel.PanelInfo.CantClose == true then
        return
    end

    -- 有子界面显示的
    if panel.hasSubUIShow then
        EventDispatcher:Dispatch(Event.ESCAPE_CLOSE_UI)
        return
    end

    -- 特殊关闭逻辑

    -- 主界面
    if panel.PanelInfo.UILogic == UIInfo.MainUI.UILogic then
        UIManager.OpenPopupUI(
            UIInfo.PopupUI,
            LocalizeExt(25785),
            nil,
            2,
            function()
                LuaUtils.QuitGame()
            end
        )
        return
    end

    UIManager.CloseUI(panel.PanelInfo)
end

local function OnAndroidHome()
end

-- 点击事件处理
local function OnTouchDown(touchPos)
    local param = {touchPos=touchPos}
    EventDispatcher:Dispatch(Event.STAGE_ON_TOUCH_BEGIN, param)
    if not param.handled then
        if not Stage.isTouchOnUI then
            UIManager.ShowEffect(ClickEffectType.TouchWave, 
                Vector2(touchPos.x / UIContentScaler.scaleFactor, (Screen.height - touchPos.y) / UIContentScaler.scaleFactor),
                nil, nil, 0.4
            )
        end
    end
end

local function OnTouchPress(touchPos)
    EventDispatcher:Dispatch(Event.STAGE_ON_TOUCH_MOVE, touchPos)
end

-- 初始化
-- 常驻内存UI包，分辨率等
function UIManager.initialize()
    UIPackageRef = setmetatable({}, {__mode = "k"})
    Stack = setmetatable({}, {__mode = "k"})
    curveStack = setmetatable({}, {__mode = "k"})
    TempHidePanelMap = setmetatable({}, {__mode = "k"})

    EventDispatcher:Add(Event.RefreshLoc, RefreshLoc)
    EventDispatcher:Add(Event.RefreshPanel, RefreshPanel)

    CS.LPCFramework.EasyTouchManager.Instance.OnAndroidEscape = OnAndroidEscape
    CS.LPCFramework.EasyTouchManager.Instance.OnAndroidHome = OnAndroidHome
    CS.LPCFramework.EasyTouchManager.Instance:AddCallBack(OnTouchDown,OnTouchPress,nil)
end

local tipstool = nil
local buyCurrencytool = nil
local popupAnimtool = nil

function UIManager.tipsTool()
    if tipstool == nil then
        tipstool = ClassConfig.TipsToolClass().new()
    end

    return tipstool
end

function UIManager.buyCurrencyTool()
    if buyCurrencytool == nil then
        buyCurrencytool = require "UI.Tools.BuyCurrencyTool"
    end

    return buyCurrencytool
end

function UIManager.popupAnimTool()
    if popupAnimtool == nil then
        popupAnimtool = require "UI.Tools.PopupAnim.PopupAnimTool"
    end

    return popupAnimtool
end

function UIManager.PanelFactory(panelinfo)
    if panelinfo == nil then
        return
    end

    if PanelFactory == nil then
        PanelFactory = LuaPackage.Load(UIPanelFactory)
    end

    local panel = UIManager.GetUI(panelinfo.UIComName)
    if panel ~= nil then
        return panel
    end
    return PanelFactory(panelinfo)
end

-- 打开一个UI
-- TODO 现在所有的UI都是加入到Stack里的，需要考虑支持不放入Stack里
function UIManager.OpenUI(panelinfo, parent, index, ...)
    -- 采用promise模式包装异步调用
    local d = deferred.new()

    local panel = UIManager.GetUI(panelinfo.UIComName)

    -- 如果UI已经打开了，那么不会重新执行打开逻辑
    if panel ~= nil and panel.IsOpen then
        UIManager.ResetPanelSortOrder(panel)
        panel:ShowWith(...)
        panel:Refresh(...)
        EventDispatcher:Dispatch(Event.SHOWED_UI, panelinfo.UIComName)

        d:resolve(panel)
        return d
    end
    
    if panel == nil then
        panel = LuaPackage.Load(panelinfo.UILogic)
        table.insert(Stack, panel)
    elseif panel.loadOperation then
        return
    end

    local args = {...}
    panel.loadOperation = UIManager.CreateFairyCom(panelinfo.UIPackagePath, panelinfo.UIName, panelinfo.UIComName, panelinfo.IsFullScreen, function(ui, pkgId)
        panel.loadOperation = nil
        if panel.Open == nil then
            -- 异步调用，检查UI是否被Close掉
            UIManager.DisposeFairyCom(pkgId, ui, panelinfo.DisposeUI or false)
            return
        end

        panel.UI = ui
        panel.PackageId = pkgId

        -- 弹窗面板
        if panelinfo.PopupAnim then
            panel.SortingOrder = UISortOrder.PopupUI
            panel.showPopupAnim = UIManager.popupAnimTool():ShowPopupUIAnim(ui, true)
            AudioManager.PlayEAXSound(104)
        end
        
        if panel.SortingOrder ~= nil then
            panel:sortingOrder(panel.SortingOrder)
        end
        SortStackOrder()
        
        HidePrePanel(panel)

        if panelinfo.HideAllPrePanel then
            HideAllPrePanel()
        end

        panel:Open(unpack(args))

        --panel.UI.visible = true
        
        -- 打开界面
        EventDispatcher:Dispatch(Event.OPENED_UI, panelinfo.UIComName)
        d:resolve(panel)
    end)

    return d
end

-- 打开一个已经打开的UI时，将此UI放到最前面
function UIManager.ResetPanelSortOrder(panel)
    if panel ~= nil and panel.UI ~= nil then
        for i = (#(Stack)), 1, -1 do
            if Stack[i] == panel then
                table.remove(Stack, i)
                UIManager.RemovewPreTempHidePanel(panel.PanelInfo.UIComName)
                break
            end
        end
        table.insert(Stack, panel)

        SortStackOrder()
        HidePrePanel(panel)
    end
end

-- 关闭一个UI(有可能是关闭中间的UI)
function UIManager.CloseUI(panelinfo)
    local panel = UIManager.GetUI(panelinfo.UIComName)
    if panel == nil or panel.Reset == nil or not panel.IsOpen then
        -- 已关闭
        return
    end

    --停止动画（防止中间动画还未播放完，就打开或者关闭）
    if panel.showPopupAnim then
        panel.showPopupAnim:Stop()
        panel.showPopupAnim = nil
    end
    if panel.closePopupAnim then
        panel.closePopupAnim:Stop()
        panel.closePopupAnim = nil
    end

    if panelinfo.NeedCache ~= true then
        panel:Reset() -- 只有管理器关闭时重置
        panel:Close()
    else
        panel:Hide()
    end

    for i = (#(Stack)), 1, -1 do
        if Stack[i] == nil or Stack[i].PanelInfo.UIComName == panelinfo.UIComName then
            ShowPrePanel(i)
            --Stack[i] = nil
            table.remove(Stack, i)
            UIManager.RemovewPreTempHidePanel(panelinfo.UIComName)
            break
        end
    end

    if panelinfo.NeedCache ~= true then
        local dispose = panelinfo.DisposeUI or false
        UIManager.DisposeFairyCom(panel.PackageId, panel.UI, dispose)

        Utils.ClearTableRef(panel)
        LuaPackage.UnLoad(panelinfo.UILogic)

        panel.UI = nil
        panel = nil
    end

    -- 关闭界面
    EventDispatcher:Dispatch(Event.CLOSED_UI, panelinfo.UIComName)
    UIManager:HandleMainPanelQueueAction()
end

--关闭当前页面
function UIManager.CloseCurUI()
    local curPanel = Stack[#(Stack)]
    if (curPanel) then
        UIManager.CloseUI(curPanel.PanelInfo)
    end
end

-- 设置某个UI显示或隐藏
function UIManager.SetUIVisible(panelInfo, bVisible, ...)
    if nil == panelInfo or type(panelInfo) ~= "table" then
        return
    end

    local panel = UIManager.GetUI(panelInfo.UIComName)
    if nil ~= panel then
        if bVisible then
            panel:ShowWith(...)
        else
            panel:Hide(...)
        end
    end
end

-- 设置当前UI显示或隐藏
function UIManager.SetCurUIVisible(bVisible, ...)
    local panel = UIManager.GetCurUI()
    if nil ~= panel then
        if bVisible then
            panel:ShowWith(...)
        else
            panel:Hide(...)
        end
    end
end

function UIManager.HideAllPanel()
    for i = (#(Stack)), 1, -1 do
        if Stack[i].UI ~= nil and Stack[i].UI.visible then
            Stack[i]:Hide()
        end
    end
end

-- 隐藏显示的界面
function UIManager.HideVisiblePanels(panelName)
    if nil == panelName then
        local cureUI = UIManager.GetCurUI()
        if nil ~= cureUI then
            panelName = cureUI.PanelInfo.UIComName
        end
    end

    if nil == panelName then
        return
    end

    if nil == TempHidePanelMap[panelName] then
        TempHidePanelMap[panelName] = {}
    end

    local panel = nil
    for i = (#Stack - 1), 1, -1 do
        panel = Stack[i]
        if panel.UI ~= nil and panel.UI.visible and panelName ~= panel.PanelInfo.UIComName then
            panel:Hide()
            TempHidePanelMap[panelName][panel.PanelInfo.UIComName] = true
        end
    end
end

-- 显示之前隐藏的界面
function UIManager.ShowPreTempHidePanels(panelName)
    if nil == panelName then
        local cureUI = UIManager.GetCurUI()
        if nil ~= cureUI then
            panelName = cureUI.PanelInfo.UIComName
        end
    end

    if nil == panelName then
        return
    end

    if nil == TempHidePanelMap[panelName] then
        return
    end

    for name, v in pairs(TempHidePanelMap[panelName]) do
        local panel = UIManager.GetUI(name)
        if nil ~= panel then
            panel:Show()
        end
    end

    TempHidePanelMap[panelName] = {}
end

-- 移除
function UIManager.RemovewPreTempHidePanel(panelName)
    for i, v in pairs(TempHidePanelMap) do
        if v[panelName] then
            v[panelName] = nil
        end
    end
end

--关闭所有
function UIManager.CloseAll(_forcedispose)
    if (tipstool) then
        tipstool:ClosePopup()
    end

    Utils.ClearTable(TempHidePanelMap)

    if Stack then
        for i = (#(Stack)), 1, -1 do
            local panel = Stack[i]
            if (panel) then
                panel:Close()
                --panel.UI:Dispose()
                --RemUIPackage(panel.PackageId)
                if _forcedispose then
                    UIManager.DisposeFairyCom(panel.PackageId, panel.UI, true)
                else
                    local dispose = panel.PanelInfo.DisposeUI or false
                    UIManager.DisposeFairyCom(panel.PackageId, panel.UI, dispose)
                end
                panel.UI = nil
                table.remove(Stack, i)
            end
        end
    end
end

--获取当前页面
function UIManager.GetCurUI()
    if Stack then
        local curPanel = Stack[#(Stack)]
        if (curPanel) then
            return curPanel
        end
    end
    return nil
end

-- 获取当前置顶的面板
function UIManager.GetTopOpenUI()
    if Stack then
        for i = #Stack, 1, -1 do
            local panel = Stack[i]

            if panel and panel.IsOpen then
                return panel
            end
        end
    end

    return nil
end

-- 获取指定界面--
function UIManager.GetUI(panelname)
    if panelname == nil then
        return nil
    end

    for i = 1, #(Stack) do
        if Stack[i].PanelInfo ~= nil and Stack[i].PanelInfo.UIComName == panelname then
            return Stack[i]
        end
    end

    return nil

    --return UIManager.Panels[panelname]
end

-- 获取UI组件
function UIManager.GetUIByName(uiName)
    local panel = nil
    for k, v in pairs(UIInfo) do
        if v.UIName == uiName then
            panel = UIManager.GetUI(v.UIComName)
            break
        end
    end

    return panel
end

-- 更新
function UIManager.update()
    if Stack ~= nil then
        for i = #(Stack),1,-1 do
            if Stack[i].PanelInfo ~= nil then
                if Stack[i] ~= nil and Stack[i].IsShow then
                    Stack[i]:Update()
                end
            end
        end
    end

    if tipstool then
        tipstool:Update()
    end
end

-- fix更新
function UIManager.fixedUpdate()
    if Stack ~= nil then
        for i = 1, #(Stack) do
            if Stack[i].PanelInfo ~= nil then
                if Stack[i] ~= nil and Stack[i].IsShow then
                    Stack[i]:fixedUpdate()
                end
            end
        end
    end
end

function UIManager.OnApplicationFocus(focus)
    if not focus then
        -- 后台运行时
        --UIManager.CloseUI(UIInfo.OfflineTimeUI)
    end
end

-- 创建一个FairyGUI的 UI组件对象
-- packagePath UI资源包 路径
-- fileName UI包名称
-- comName 当前包里的控件名
-- isFullScreen 是否要全屏
-- parent 父节点
-- index 在父节点的索引
function UIManager.CreateFairyCom(packagePath, fileName, comName, isFullScreen, cb)
    return AddUIPackage(packagePath, function()
        --local ui = UIPackage.CreateObject(fileName, comName)
        local ui = UIPackage.CreateObject(fileName, comName)
        GRoot.inst:AddChild(ui)
        -- 批处理
        ui.fairyBatching = true
        --ui.visible = true
        -- 设置全屏适应
        if isFullScreen or nil == isFullScreen then
            UIUtils.SetUIFitScreen(ui)
        end
        cb(ui, packagePath)
    end)
end

function UIManager.DisposeFairyCom(pkgId, ui, dispose)
    local forcedispose = dispose or false

    if pkgId ~= nil then
        RemUIPackage(pkgId, forcedispose)
    end

    if ui ~= nil then
        ui:Dispose()
    end
end

UIManager.LoadUIPackage = AddUIPackage

function UIManager.TryUnloadUIPackage(pkgid)
    if pkgid ~= nil then
        RemUIPackage(pkgid, false)
    end
end

-- 是否碰到了非自己空白无事件监听的UI
function UIManager.isTouchUIEmptySpaceOrChild(panel)
    if panel.UI == nil then
        return false
    end

    if Stage.isTouchOnUI then
        local obj = GRoot.inst.touchTarget

        if obj == nil then
            return false
        end

        if obj == panel.UI then
            return false
        else
            return true
        end
    else
        return false
    end
end

-- 显示Gm指令
function UIManager.ShowGmOrder()
    if nil == UIManager.gmOrder then
        UIManager.gmOrder = require(UIInfo.GmOrderUI.UILogic)
    end
    UIManager.gmOrder.show()
end

-- 显示
-- content 表示显示文本内容
function UIManager.ShowMsg(content,showType)
    if nil == UIManager.tips then
        UIManager.tips = require(UIInfo.TipsUI.UILogic)
    end
    UIManager.tips.show(content,showType)
end

function UIManager.ShowEffect(effectType,xy,sortingOrder,offset, scale, extraInfo)
    if nil == UIManager.clickEffectsUI then
        UIManager.clickEffectsUI = require("UI.Tools.ClickEffects")
    end
    UIManager.clickEffectsUI:ShowEffect(effectType,xy,sortingOrder,offset,scale,extraInfo)
end

function UIManager.HideEffect(effectType,xy)
    if nil == UIManager.clickEffectsUI then
        UIManager.clickEffectsUI = require("UI.Tools.ClickEffects")
    end
    UIManager.clickEffectsUI:HideEffect(effectType,xy)
end

function UIManager.OpenPopupUI(panelinfo, ...)
    local panel = UIManager.GetUI(panelinfo.UIComName)
    if (panel) then
        UIManager.CloseUI(panelinfo)
    end
    UIManager.OpenUI(panelinfo, nil, nil, ...)
end

function UIManager.ClosePopupUI(panelinfo)
    local panel = UIManager.GetUI(panelinfo.UIComName)
    if nil == panel then return end

    if panelinfo.PopupAnim then
        panel.closePopupAnim = UIManager.popupAnimTool():ClosePopupUIAnim(panel.UI, true, panelinfo)
    else
        UIManager.CloseUI(panelinfo)
    end
end

function UIManager.OpenTab(parentinfo, tabInfo, ...)
    local panel = UIManager.GetUI(parentinfo.UIComName)
    if panel then
        return panel:OpenTab(tabInfo, ...)
    end
end

function UIManager.HideTab(parentinfo, tabInfo, ...)
    local panel = UIManager.GetUI(parentinfo.UIComName)
    if panel then
        return panel:HideTab(tabInfo, ...)
    end
end

-- 打开曲面UI，这里只做工具弹框使用
function UIManager.OpenCurveUI(panelinfo, ...)
    local curvePanel = UIManager.GetCurveUI(panelinfo.UIComName)
    if curvePanel == nil then
        curvePanel = LuaPackage.Load(panelinfo.UILogic)
        table.insert(curveStack, curvePanel)
    end
    -- 如果UI已经打开了，那么不会重新执行打开逻辑
    if curvePanel.IsOpen then
        curvePanel:Refresh(...)
        return
    end
    local paramT = {paramCount = select("#", ...), ...}
    local callBack = function(UI, pkgId, uiPainter, curveUIGO)
        curvePanel.UI, curvePanel.PackageId, curvePanel.uiPainter, curvePanel.curveUIGO =
            UI,
            pkgId,
            uiPainter,
            curveUIGO
        local index = (#curveStack)
        curvePanel.UI.sortingOrder = index * 1001
        curvePanel:Open(unpack(paramT, 1, paramT.paramCount))
    end
    UIManager.CreateCurveUI(panelinfo, callBack)
end

function UIManager.CloseCurveUI(panelinfo)
    local curvePanel = UIManager.GetCurveUI(panelinfo.UIComName)
    if curvePanel == nil then
        return
    end
    curvePanel:Reset() -- 只有管理器关闭时重置
    curvePanel:Close()
    for i = (#(curveStack)), 1, -1 do
        if curveStack[i] == nil or curveStack[i].PanelInfo.UIComName == panelinfo.UIComName then
            table.remove(curveStack, i)
            break
        end
    end

    UIManager.DisposeCurveUI(curvePanel)
    Utils.ClearTableRef(curvePanel)
    LuaPackage.UnLoad(panelinfo.UILogic)
    curvePanel.UI = nil
    curvePanel = nil
end

function UIManager.GetCurveUI(panelname)
    local curvePanel = nil
    for i = 1, #(curveStack) do
        if curveStack[i].PanelInfo ~= nil and curveStack[i].PanelInfo.UIComName == panelname then
            curvePanel = curveStack[i]
            break
        end
    end
    return curvePanel
end

-- 是否有弹窗
function UIManager.HasPopup()
    if Stack then
        for i = #Stack, 1, -1 do
            local panel = Stack[i]

            if panel and panel.IsOpen and panel.PanelInfo.PopupAnim then
                return true
            end
        end
    end

    return false
end

-- 显示等待界面
function UIManager.ShowWaiting(hit)
    if nil == UIManager.waiting then
        UIManager.waiting = require(UIInfo.WaitingUI.UILogic)
        UIManager.waiting:Init()
    end

    return UIManager.waiting:Show(hit)
end

-- 停止等待
function UIManager.StopWaiting(item)
    if UIManager.waiting then
        UIManager.waiting:Stop(item)
    end
end

-- 清除tips
function UIManager.ClearTips()
    if (UIManager.tips) then
        UIManager.tips.clear()
    end
end

-- 新增主界面自动打开的界面(限时礼包 关卡排行 大秘境提示)
-- uiInfo:UIInfo
-- param1, param2:参数,可扩展
function UIManager:AddMainPanelQueueAction(action)
    Utils.DebugError("AddMainPanelQueueAction")
    if type(action) ~= "function" then
        return
    end

    if m_autoOpenQueue == nil then
        m_autoOpenQueue = {}
    end

    table.insert(m_autoOpenQueue, action)
    self:HandleMainPanelQueueAction()
end

-- MainPanel OnShow时调用
function UIManager:HandleMainPanelQueueAction()
    if m_autoOpenQueue == nil or #m_autoOpenQueue == 0 then
        return
    end

    local currPanel = self.GetTopOpenUI()

    if nil == currPanel or currPanel.PanelInfo.UIComName ~= UIInfo.MainUI.UIComName then
        return
    end

    if m_autoOpenQueue[1] and type(m_autoOpenQueue[1]) == "function" then
        m_autoOpenQueue[1]()
        table.remove(m_autoOpenQueue, 1)
    end
end

local systemGoToTool = nil
function UIManager.systemGoToTool()
    if systemGoToTool == nil then
        systemGoToTool = require "UI.Tools.SystemGoToTool"
    end

    return systemGoToTool
end

-- 销毁
function UIManager.onDestroy()
    if (UIManager.clickEffectsUI) then
        UIManager.clickEffectsUI:destroy()
    end

    UIManager.CloseAll(true)
    ResourceMgr:ClearFairyCache()
    UIManager.Panels = nil
    Stack = nil
    curveStack = nil
    TempHidePanelMap = nil
    Stage.inst:RemoveEventListeners()

    UIUtils.Dispose()
    if (UIManager.gmOrder) then
        UIManager.gmOrder.destroy()
    end

    if (UIManager.tips) then
        UIManager.tips.destroy()
    end

    if (tipstool) then
        tipstool:Close()
    end

    if (UIManager.waiting) then
        UIManager.waiting:Close()
    end

    if UIManager.FuncLock then
        UIManager.FuncLock:Destroy()
        UIManager.UnlockPanel = nil
    end

    if UIManager.UnlockPanel then
        UIManager.UnlockPanel:Destroy()
        UIManager.UnlockPanel = nil
    end

    if (buyCurrencytool) then
        buyCurrencytool:Close()
    end
    buyCurrencytool = nil

    EventDispatcher:Remove(Event.RefreshLoc, RefreshLoc)
    EventDispatcher:Remove(Event.RefreshPanel, RefreshPanel)

    m_autoOpenQueue = nil
end

return UIManager
