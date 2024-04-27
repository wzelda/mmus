local MainTaskUI = UIManager.PanelFactory(UIInfo.MainTaskUI)

local panel = MainTaskUI

function MainTaskUI:OnOpen(arg)
    panel = self

    self.window = self.UI:GetChild("Window")
    self.closeBtn = self.window:GetChild("closeButton")
    self.progressBar = self.window:GetChild("progressBar")
    self.title = self.window:GetChild("Text_Title")
    self.desc = self.window:GetChild("Desc_Text")
    self.name = self.window:GetChild("Desc")
    self.rewardLabel = self.window:GetChild("n17")

    self.window:GetChild("n16").text = Localize("Reward")
    self.window.text = Localize("Tips")
    self.title.text = Localize("Task")
end

function MainTaskUI.DoClose()
    UIManager.ClosePopupUI(UIInfo.MainTaskUI)
end

function MainTaskUI:OnShow(curTask)
    self.desc.text = curTask.Desc
    local finish, progress, total = PlayerDatas.TaskData:GetTaskInfo(curTask.TaskId)
    self.progressBar.max = total
    self.progressBar.value = progress
    self.name.text = string.format("%s  (%s/%s)", curTask.Name, progress, total)
    CommonUIUtils.SetCurrencyLabel(self.rewardLabel, curTask.Reward, curTask.RewardType)
end

-- 绑定事件
function MainTaskUI:OnRegister()
    self.closeBtn.onClick:Set(self.DoClose)
end

-- 解绑事件
function MainTaskUI:OnUnRegister()
    self.closeBtn.onClick:Clear()
end

function MainTaskUI:OnClose()
end

return MainTaskUI