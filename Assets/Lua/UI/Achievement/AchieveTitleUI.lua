local AchieveTitleUI = UIManager.PanelFactory(UIInfo.AchieveTitleUI)

local panel = AchieveTitleUI

function AchieveTitleUI:OnOpen(arg)
    panel = self

    self.window = self.UI:GetChild("window")
    self.window.text = Localize("AchieveTitle")
    self.closeBtn = self.window:GetChild("Button_Close")
    self.list = self.window:GetChild("List")
    self.list:SetVirtual()
    self.curTip = self.window:GetChild("curTip")
end

function AchieveTitleUI.DoClose()
    UIManager.ClosePopupUI(UIInfo.AchieveTitleUI)
end

function AchieveTitleUI:OnShow(...)
    self.list.itemRenderer = self.ItemRender
    self.list.numItems = #ConfigData.achievementConfig.AchievementTitle
end

-- 绑定事件
function AchieveTitleUI:OnRegister()
    self.closeBtn.onClick:Set(self.DoClose)
end

-- 解绑事件
function AchieveTitleUI:OnUnRegister()
    self.closeBtn.onClick:Clear()
end

function AchieveTitleUI:OnClose()
    self.list.itemRenderer = nil
end

function AchieveTitleUI.ItemRender(index, obj)
    local cfg = ConfigData.achievementConfig.AchievementTitle[index + 1]
    obj:GetChild("curTip").text = Localize("Current")
    obj.text = string.format("[color=#fffef1,#E7FF77]%s", cfg.Name)
    UIUtils.LoadIcon(obj, cfg.Icon, true)
    local desc
    if cfg.Condition == 0 then
        desc = Localize("DefaultAchieveTitle")
    else
        desc = LocalizeExt("AchieveTitleCondition", {cfg.Condition})
    end
    obj:GetChild("descTxt").text = desc
    UIUtils.SetControllerIndex(obj:GetController("Status_C"), cfg.ID == PlayerDatas.AchievementData.achieveTitleId and 1 or 0)
end

return AchieveTitleUI