-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

local TiredPopupUI = UIManager.PanelFactory(UIInfo.TiredPopupUI)

local panel = nil

TiredPopupUI.showPopupAnim = nil
TiredPopupUI.closePopupAnim = nil

-- 关闭
function TiredPopupUI:CloseFunc()
    self.closePopupAnim = UIManager.popupAnimTool():ClosePopupUIAnim(self.UI, true, UIInfo.TiredPopupUI)
end

-- 显示界面
function TiredPopupUI:Init(content, title)
    self.titleLabel.text = title or LocalizeExt(20037)
    self.contentLabel.text = content
end

-- 子类初始化UI控件
function TiredPopupUI:OnOpen(content, title)
    self.showPopupAnim = UIManager.popupAnimTool():ShowPopupUIAnim(self.UI, true)
    self.UI.sortingOrder = UISortOrder.PopupUI
    panel = self.UI
    self.titleLabel = self.UI:GetChild("Text_01")
    self.contentLabel = self.UI:GetChild("Text_02")
    self.bgCom = self.UI:GetChild("bg")
    self.confirmBtn = self.UI:GetChild("confirmBtn")

    -- 默认状态
    self:Init(content, title)
end

-- 子类绑定各种事件
function TiredPopupUI:OnRegister()
    self.confirmBtn.onClick:Add(function() self:CloseFunc() end)
    self.bgCom.onClick:Add(function() self:CloseFunc() end)
end

function TiredPopupUI:OnShow()
    
end

-- 强制刷新,比如网络事件监听，切换语言包，断线重连等
function TiredPopupUI:OnRefresh(...)
end

-- 解绑各类事件
function TiredPopupUI:OnUnRegister()
    self.confirmBtn.onClick:Clear()
    self.bgCom.onClick:Clear()
end

-- 关闭
function TiredPopupUI:OnClose()
    panel = nil
    --停止动画（防止中间动画还未播放完，就打开或者关闭）
    if(self.showPopupAnim)then
        self.showPopupAnim:Stop()
    end
    if(self.closePopupAnim)then
        self.closePopupAnim:Stop()
    end
    self.showPopupAnim = nil
    self.closePopupAnim = nil
end

return TiredPopupUI

--endregion
