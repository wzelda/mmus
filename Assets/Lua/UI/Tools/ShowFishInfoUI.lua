local ShowFishInfoUI = UIManager.PanelFactory(UIInfo.ShowFishInfoUI)
ShowFishInfoUI.CloseCallBack = nil

local panel = ShowFishInfoUI
local m_touchMove_X
local m_touchBegion_X

-- 显示界面
function ShowFishInfoUI:Init(content, title, closeCalBack)
    self.titleLabel.text = title or self.data.Name
    self.contentLabel.text = content or self.data.Desc
    self.CloseCallBack = closeCalBack
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
function ShowFishInfoUI:SetState(param)
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
        local modelScale = param.modelScale or 10
        local modelRot = param.modelRot or 90
        CommonUIUtils.CreateUIModelFromPool(
            GameObjectManager.UIEffPoolName,param.modelPath,self.modelSlot, 
            modelCallback, nil, modelScale, Quaternion.Euler(0, modelRot, 0)
        )
    end
end

-- 子类初始化UI控件
function ShowFishInfoUI:OnOpen(param)
    panel = self

    if nil == param or nil == param.data then
        Utils.DebugError("缺少展示数据")
        return
    end

    local content, title, closeCalBack
    if type(param) == "table" then
        self.data = param.data
        content, title, closeCalBack =
            param.content, param.title, param.closeCalBack
    end

    self.UI.sortingOrder = UISortOrder.PopupUI
    self.bgCom = self.UI:GetChild("Bg")
    self.window = self.UI:GetChild("Window")
    self.titleLabel = self.window:GetChild("title")
    self.contentLabel = self.window:GetChild("Desc_Text")
    self.closeButton = self.window:GetChild("closeButton")
    self.itemIcon = self.window:GetChild("itemIcon")
    self.modelSlot = self.window:GetChild("modelSlot")

    self:Init(content, title, closeCalBack)
    self:SetState(param)
end

-- 子类绑定各种事件
function ShowFishInfoUI:OnRegister()
    -- 关闭
    local CloseFunc = function()
        if(self.CloseCallBack ~= nil)then
            self.CloseCallBack()
        end
        -- 按钮事件
        self.CloseCallBack = nil
        UIManager.ClosePopupUI(UIInfo.ShowFishInfoUI)
    end
    self.bgCom.onClick:Set(CloseFunc)
    self.closeButton.onClick:Set(CloseFunc)
end

function ShowFishInfoUI:OnShow()
end

-- 解绑各类事件
function ShowFishInfoUI:OnUnRegister()
    self.bgCom.onClick:Clear()
    self.closeButton.onClick:Clear()
end

-- 关闭
function ShowFishInfoUI:OnClose()
    self.CloseCallBack = nil
    if self.modelWrap then
        CommonUIUtils.ReturnUIModelToPool(self.modelWrap,GameObjectManager.UIEffPoolName)
        self.modelWrap = nil
    end
end

return ShowFishInfoUI