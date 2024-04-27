-- 强制等待界面

local Waiting = class()

function Waiting:Init()
    self.waitingItems = {}

    UIManager.CreateFairyCom(UIInfo.WaitingUI.UIPackagePath, UIInfo.WaitingUI.UIName, UIInfo.WaitingUI.UIComName, true, function(ui, pkgId)
        self.View = ui
        self.PkgId = pkgId
        self.View.visible = false
        self.View.sortingOrder = UISortOrder.Waiting
    end)
end

function Waiting:Show(hit)
    hit = hit or debug.traceback("WaitItem")
    local item = {hit=hit}
    self.waitingItems[item] = item

    if (self.View.visible == false) then
        self.View.visible = true
    end

    return item
end

function Waiting:Stop(item)
    if item == nil then
        return
    end
    
    self.waitingItems[item] = nil
    if Utils.TableIsEmpty(self.waitingItems) then
        self.View.visible = false
    end
end

function Waiting:Close()
    UIManager.DisposeFairyCom(self.PkgId, self.View)
end

return Waiting

