--[[ 
 * Descripttion: 
 * version: 
 * Author: Mingo
 * Date: 2020-06-18 10:00:41
 * LastEditors: Mingo
 * LastEditTime: 2020-06-19 15:59:00
 ]]
 
local FilterWordManager = require "Manager.FilterWordManager"


local Panel = UIManager.PanelFactory(UIInfo.RenameCardUI)

local panel = nil
Panel.itemId = nil

local function OnClosePanel()
    UIManager.popupAnimTool():ClosePopupUIAnim(panel.UI, true, UIInfo.RenameCardUI)
end

-- 确认
local function OnClickSureBtn()
    local text = panel.content.text
    local len = Utils.GetStringLength(text)
    if len == 0 then
        UIManager.ShowMsg(LocalizeExt(20301))
        return
    elseif len < 4 then
        UIManager.ShowMsg(LocalizeExt(20302))
        return
    elseif len > 6 then
        UIManager.ShowMsg(LocalizeExt(20303))
        return
    else
        local has = FilterWordManager.CheckNameWordsHasFilter(text)
        if has then
            UIManager.ShowMsg(LocalizeExt(20300))
        else
            OnClosePanel()
            PlayerData.Datas.UserMiscData:NewC2SChangeNameMsg(text, panel.itemId)
        end
    end
end

-- 子类初始化UI控件
function Panel:OnOpen(itemId)
    panel = self
    self.itemId = itemId
    self.main = self.UI:GetChild("main")
    self.bg = self.UI:GetChild("bg")
    self.closeBtn = self.main:GetChild("cancleBtn")
    self.sureBtn = self.main:GetChild("sureBtn")
    self.content = self.main:GetChild("content")

    self.content.text = ""
    UIManager.popupAnimTool():ShowPopupUIAnim(self.UI)
end

function Panel:OnShow()

end

-- 刷新文本
function Panel:RefreshText()
    self.main.title = LocalizeExt("请输入新的名字")
    self.content.promptText = LocalizeExt("[color=#b2b2b2]名字长度不超过7个字")
    self.sureBtn.title = LocalizeExt("确认")
    self.closeBtn.title = LocalizeExt("取消")
end

-- 绑定各类事件
function Panel:OnRegister()
    self.closeBtn.onClick:Add(OnClosePanel)
    self.bg.onClick:Add(OnClosePanel)
    self.sureBtn.onClick:Add(OnClickSureBtn)
end

-- 强制刷新,比如网络事件监听，切换语言包，断线重连等
function Panel:OnRefresh(...)
    self:RefreshText()
end

-- 解绑各类事件
function Panel:OnUnRegister()
    self.closeBtn.onClick:Clear()
    self.bg.onClick:Clear()
    self.sureBtn.onClick:Clear()
end

-- 关闭
function Panel:OnClose()
    panel = nil
    self.itemId = nil
end

return Panel
--endregion