local WeakGuideManager = {}
local m_currUIInfo = nil
local m_fingerCom = nil
-- 手指类型
local m_finger_C = nil
local m_finger_T = nil
local m_fingerEffWrapper = nil
local m_panelUI
local m_created

local function TryInitBaseCom(callback)
    if not m_created and m_fingerCom == nil then
        m_created = true
        UIManager.CreateFairyCom(
            "UI/Guide/Guide",
            "Guide",
            "Component_WeakGuideFinger",
            false, function (ui)
                m_fingerCom = ui
                m_fingerCom.sortingOrder = UISortOrder.NewGuide
                m_fingerCom.visible = false
                m_fingerCom.touchable = false
                m_finger_C = m_fingerCom:GetController("Type_C")
                m_finger_T = m_fingerCom:GetTransition("Tween_T")
                -- m_fingerEffWrapper =
                --     CommonUIUtils.CreateUIEff(m_fingerCom:GetChild("holder"), Configs.EffectPathCfg().UIYinDaoQuan, 3)
            
                if callback then
                    callback()
                end
            end
        )
    else
        if callback then
            callback()
        end
    end
end

-- 析构UI组件并返回nil
local function DisposeUI(ui)
    if not Utils.uITargetIsNil(ui) then
        ui:Dispose()
    end

    return nil
end

-- 获取目标组件的中心位置
local function GetObjCenterPosByCom(gObj)
    if gObj == nil then
        return Vector2.zero
    end

    local xy =
        gObj:LocalToRoot(Vector2.zero) - m_panelUI:LocalToRoot(Vector2.zero) +
        Vector2(gObj.actualWidth * 0.5, gObj.actualHeight * 0.5)

    if (gObj.pivotX > 0 or gObj.pivotY > 0) and gObj.pivotAsAnchor then
        xy = xy - Vector2(gObj.actualWidth * gObj.pivotX, gObj.actualHeight * gObj.pivotY)
    end

    return xy
end

local function GetObjLocalCenter(gObj)
    if gObj == nil then
        return Vector2.zero
    end

    local xy = Vector2(gObj.actualWidth * 0.5, gObj.actualHeight * 0.5)

    if (gObj.pivotX > 0 or gObj.pivotY > 0) and gObj.pivotAsAnchor then
        xy = xy - Vector2(gObj.actualWidth * gObj.pivotX, gObj.actualHeight * gObj.pivotY)
    end

    return xy
end

local function fingerTweenCallBack()
    if m_fingerEffWrapper then
        m_fingerEffWrapper.visible = false
        m_fingerEffWrapper.visible = true
    end
end

function WeakGuideManager:OnUIOpened(comName)
    if m_currUIInfo and m_currUIInfo.UIName ~= comName then
        self:Hide()
    end
end

-- 显示弱引导
-- uiObj:控件
-- uiInfo:界面
function WeakGuideManager:Show(uiObj, uiInfo, panelUI)
    if uiObj == nil then
        return
    end

    m_currUIInfo = uiInfo
    if uiInfo then
        local panel = UIManager.GetUI(uiInfo.UIComName)
        if panel then
            panelUI = panel.UI
        end
    end

    if nil == panelUI then return end

    m_panelUI = panelUI
    TryInitBaseCom(function ()
        if m_fingerCom == nil then
            return Utils.DebugWarning("弱引导手指组件丢失")
        end
    
        m_fingerCom.xy = GetObjCenterPosByCom(uiObj)
        m_fingerCom.visible = true
        if m_finger_T then
            m_finger_T:Play(-1, 0)
            m_finger_T:SetHook("trigger", fingerTweenCallBack)
        end
        m_fingerCom = panelUI:AddChild(m_fingerCom)
    
        if m_finger_C == nil then
            return Utils.DebugWarning("弱引导手指组件控制器丢失")
        end
    
        -- 边缘处理 0:↖ 1:↗ 2:↙ 3:↘
        if m_fingerCom.y <= GRoot.inst.height - m_fingerCom.height then
            if m_fingerCom.x <= GRoot.inst.width - m_fingerCom.width then
                m_finger_C.selectedIndex = 0
            else
                m_finger_C.selectedIndex = 1
            end
        else
            if m_fingerCom.x <= GRoot.inst.width - m_fingerCom.width then
                m_finger_C.selectedIndex = 2
            else
                m_finger_C.selectedIndex = 3
            end
        end
    end)
end

-- 在某个组件上显示引导
function WeakGuideManager:ShowHang(uiObj, uiInfo)
    if uiObj == nil then
        return
    end

    m_currUIInfo = uiInfo
    TryInitBaseCom(function ()
        if m_fingerCom == nil then
            return Utils.DebugWarning("弱引导手指组件丢失")
        end
    
        m_fingerCom.xy = GetObjLocalCenter(uiObj)
        m_fingerCom.visible = true
        m_fingerCom = uiObj:AddChild(m_fingerCom)
    end)
end

-- 隐藏弱引导
function WeakGuideManager:Hide()
    if not Utils.uITargetIsNil(m_fingerCom) and m_fingerCom.visible then
        m_fingerCom.visible = false
        m_fingerCom = GRoot.inst:AddChild(m_fingerCom)
    end
end

function WeakGuideManager:Init()
    EventDispatcher:Add(Event.SHOWED_UI, self.OnUIOpened, self)
    EventDispatcher:Add(Event.OPENED_UI, self.OnUIOpened, self)
    EventDispatcher:Add(Event.OPENED_TAB, self.OnUIOpened, self)
end

function WeakGuideManager:OnDestroy()
    m_currUIInfo = nil
    m_fingerCom = DisposeUI(m_fingerCom)
    m_finger_C = nil
    m_finger_T = nil

    if m_fingerEffWrapper and CommonUIUtils then
        m_fingerEffWrapper = CommonUIUtils.ClearUIEff(m_fingerEffWrapper)
    end

    EventDispatcher:Remove(Event.SHOWED_UI, self.OnUIOpened, self)
    EventDispatcher:Remove(Event.OPENED_UI, self.OnUIOpened, self)
    EventDispatcher:Remove(Event.OPENED_TAB, self.OnUIOpened, self)
end

return WeakGuideManager
