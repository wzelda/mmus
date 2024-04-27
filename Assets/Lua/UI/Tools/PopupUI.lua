-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local PopupUI = UIManager.PanelFactory(UIInfo.PopupUI)
PopupUI.SureCallBack = nil
PopupUI.CancelCallBack = nil
PopupUI.CloseCallBack = nil

local panel = PopupUI
local closeSortingOrder = -10
local m_touchMove_X
local m_touchBegion_X

function PopupUI:SetButtonText(okStr, cancelStr)
    self.sureBtn.title = okStr
    self.cancelBtn.title = cancelStr
end

-- 显示界面
function PopupUI:Init( title, btnNum, sureCallback, cancelCallback, closeCalBack, okStr, cancelStr)
    self.titleLabel.text = title
    self.SureCallBack = sureCallback
    self.CancelCallBack = cancelCallback
    self.CloseCallBack = closeCalBack

    okStr = okStr or LocalizeExt("Sure")
    cancelStr = cancelStr or LocalizeExt("Cancel")
    self:SetButtonText(okStr, cancelStr)
end

local function OnTouchMoveBegin()
    m_touchBegion_X = Input.mousePosition.x
end

local function OnTouchMoveFunc()
    local model = panel.modelWrap.wrapTarget
    if nil == model then return end

    local rotTransform = model and model.gameObject.transform
    m_touchMove_X = Input.mousePosition.x
    if m_touchMove_X - m_touchBegion_X > 0 then
        if model then
            rotTransform:Rotate(
                rotTransform.up,
                -10
            )
        end
    else
        if model then
            rotTransform:Rotate(
                rotTransform.up,
                10
            )
        end
    end
    m_touchBegion_X = Input.mousePosition.x
end

-- 显示额外信息
function PopupUI:SetState(param)
    if type(param) ~= "table" then return end

    if param.itemIcon then
        UIUtils.LoadIcon(self.itemIcon, param.itemIcon)
    end
    local function modelCallback(wrap)
        -- 加大Z轴，否则模型颜色不对，fairygui的bug
        local wrapTranform = wrap.wrapTarget.transform
        wrapTranform.localPosition = wrapTranform.localPosition + Vector3(0,0,3)
        self.modelWrap = wrap
        self.window.onTouchMove:Set(OnTouchMoveFunc)
        self.window.onTouchBegin:Set(OnTouchMoveBegin)
    end
    if param.modelPath then
        CommonUIUtils.CreateUIModelFromPool(
            GameObjectManager.UIEffPoolName,param.modelPath,self.modelSlot, 
            modelCallback, nil, param.modelScale, Quaternion.Euler(0, param.modelRot, 0)
        )
    end
    -- 复杂的确定按钮
    if param.okInfo then
        local state_C = self.sureBtn:GetController("State_C")
        if param.okInfo.multi then
            UIUtils.SetControllerIndex(state_C, 1)
            self.sureBtn:GetChild("Text_Mult").text = LocalizeExt("ADReward", {param.okInfo.multi})
        end
        if param.okInfo.adReward and param.okInfo.adRewardType then
            UIUtils.SetControllerIndex(state_C, 2)
            CommonUIUtils.SetCurrencyLabel(self.sureBtn:GetChild("Label_Money"), param.okInfo.adReward, param.okInfo.adRewardType)
        end
        if param.okInfo.index then
            UIUtils.SetControllerIndex(state_C, param.okInfo.index)
            if param.okInfo.multi == nil then
                self.sureBtn:GetChild("Text_Mult").text = param.okStr or LocalizeExt("Sure")
            end
        end
    end
    if param.cancelInfo then
        local state_C = self.cancelBtn:GetController("State_C")
        if param.okInfo.index then
            UIUtils.SetControllerIndex(state_C, param.cancelInfo.index)
        end
    end
    self.moneyEffect = param.moneyEffect
end

-- 子类初始化UI控件
function PopupUI:OnOpen(param)
    panel = self
    local  title, btnNum, sureCallback, cancelCallback, closeCalBack, okStr, cancelStr, canntClose
    if type(param) == "table" then
        self.data = param.data
         title, btnNum, sureCallback, cancelCallback, closeCalBack, okStr, cancelStr, canntClose =
             param.title, param.btnNum, param.sureCallback,
            param.cancelCallback, param.closeCalBack, param.okStr,
            param.cancelStr, param.canntClose
    end

    self.UI.sortingOrder = UISortOrder.PopupUI
    self.hasSubUIShow = canntClose
    self.bgCom = self.UI:GetChild("Bg")
    self.window = self.UI:GetChild("Window")
    self.titleLabel = self.window:GetChild("title")
    self.closeButton = self.window:GetChild("closeButton")
    self.sureBtn = self.window:GetChild("Button_2")
    self.cancelBtn = self.window:GetChild("Button_1")
    self.itemIcon = self.window:GetChild("itemIcon")
    self.modelSlot = self.window:GetChild("modelSlot")

    -- CommonUIObjectManager:Add(UIKey.PopupConfirmBtn_1,self.sureBtn)

    -- 默认状态
    self:Init( title, btnNum, sureCallback, cancelCallback, closeCalBack, okStr, cancelStr)
    self:SetState(param)

    EventDispatcher:Dispatch(Event.OPEN_POPUPUI)
end

-- 子类绑定各种事件
function PopupUI:OnRegister()
    -- 关闭
    local CloseFunc = function()
        if(self.CloseCallBack ~= nil)then
            self.CloseCallBack()
        end
        -- 按钮事件
        self.SureCallBack = nil
        self.CancelCallBack = nil
        self.CloseCallBack = nil
        UIManager.ClosePopupUI(UIInfo.PopupUI)
    end

    -- 确定
    local SureFunc = function()
        if(self.SureCallBack ~= nil)then
            self.SureCallBack()
        end
        if self.moneyEffect and self.moneyEffect[1] then
            UIUtils.MoneyEffect(self.moneyEffect[1], self.sureBtn)
        end
        CloseFunc()
    end

    -- 取消
    local CancelFunc = function()
        if(self.CancelCallBack ~= nil)then
            self.CancelCallBack()
        end
        if self.moneyEffect and self.moneyEffect[2] then
            UIUtils.MoneyEffect(self.moneyEffect[2], self.cancelBtn)
        end
        CloseFunc()
    end

    self.sureBtn.onClick:Set(SureFunc)
    self.cancelBtn.onClick:Set(CancelFunc)
    self.bgCom.onClick:Set(CloseFunc)
    self.closeButton.onClick:Set(CloseFunc)

    -- EventDispatcher:Add(Event.UPDATE_POPUP_UI_TIP, self.UpdateContent, self)
end

function PopupUI:OnShow()
    
end

function PopupUI:OnHide()
    --UIManager.tipsTool():ClosePopupUIAnim(self.UI, true, UIInfo.PopupUI)
end

-- 强制刷新,比如网络事件监听，切换语言包，断线重连等
function PopupUI:OnRefresh(...)
end

-- 解绑各类事件
function PopupUI:OnUnRegister()
    
    self.sureBtn.onClick:Clear()
    self.cancelBtn.onClick:Clear()
    self.bgCom.onClick:Clear()
    self.closeButton.onClick:Clear()

    -- EventDispatcher:Remove(Event.UPDATE_POPUP_UI_TIP, self.UpdateContent, self)
end

-- 关闭
function PopupUI:OnClose()

    self.SureCallBack = nil
    self.CancelCallBack = nil
    self.CloseCallBack = nil
    if self.modelWrap then
        CommonUIUtils.ReturnUIModelToPool(self.modelWrap,GameObjectManager.UIEffPoolName)
        self.modelWrap = nil
    end

    EventDispatcher:Dispatch(Event.CLOSE_POPUPUI)
end

return PopupUI

--endregion
