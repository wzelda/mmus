--通用对话框
local Dialog = {}
Dialog.View = nil
Dialog.Pkg = nil

Dialog.titleLabel = nil
Dialog.contentLabel = nil
Dialog.OkCb = nil
Dialog.CancelCb = nil

Dialog.closeSortingOrder = -10
Dialog.showSortingOrder = 850

function Dialog:Init()
    self.View,self.PkgId = UIManager.CreateFairyCom(UIInfo.DialogUI.UIPackagePath, UIInfo.DialogUI.UIName, UIInfo.DialogUI.UIComName);
    self.titleLabel = self.View:GetChild("Label_Title")
    self.contentLabel =  self.View:GetChild("Label_Content")
    local OkFunc = function()
        if(self.OkCb ~= nil)then
            self.OkCb()
        end
        self.View.visible = false
        self.View.sortingOrder = self.scloseSortingOrder
    end
    self.OkBtn = self.View:GetChild("Button_Ok")
    self.OkBtn.onClick:Add(OkFunc)
    local CancelFunc = function()
        if(self.CancelCb ~= nil)then
            self.CancelCb()
        end
        self.View.visible = false
        self.View.sortingOrder = self.scloseSortingOrder
    end
    self.CancelBtn = self.View:GetChild("Button_Cancel")
    self.CancelBtn.onClick:Add(CancelFunc)
end


function Dialog:Show(title,content,OkCallback,CancelCallback)
     self.titleLabel.text = title
     self.contentLabel.text = content
     self.OkCb = OkCallback
     self.CancelCb = CancelCallback
     self.View.visible = true
     self.View.sortingOrder = self.showSortingOrder
end

function Dialog:destroy()
    self.OkCb = nil
    self.CancelCb = nil
    self.OkBtn.onClick:Clear()
    self.CancelBtn.onClick:Clear()
    UIManager.DisposeFairyCom(self.PkgId, self.View)
end
return Dialog;