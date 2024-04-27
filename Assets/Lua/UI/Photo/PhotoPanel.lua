
local PhotoPanel = UIManager.PanelFactory(UIInfo.PhotoUI)

PhotoPanel.HidePrePanel = true

function PhotoPanel:OnOpen()
    local main = self.UI:GetChild("main")
    self.closeBtn = main:GetChild("Button_Zoom")
    self.photoBtn = main:GetChild("Button_Photo")
end

function PhotoPanel:TakePhoto()
end

function PhotoPanel:OnRegister()
    self.closeBtn.onClick:Add(function() self:ClosePanel()  end)
    self.photoBtn.onClick:Add(function() self:TakePhoto() end)
end

function PhotoPanel:OnUnRegister()
    self.closeBtn.onClick:Clear()
    self.photoBtn.onClick:Clear()
end

function PhotoPanel:ClosePanel()
    UIManager.CloseUI(UIInfo.PhotoUI)
    EventDispatcher:Dispatch(Event.SHOW_INCOME, 0,true)
end

return PhotoPanel