local FunctionOpenConfig = require "Config.FunctionOpenConfig"
local FunctionUnlockUI = UIManager.PanelFactory(UIInfo.FuncLockUI)

local panel = FunctionUnlockUI

local FuncIndexMap = {
    [GameSystemType.FID_LIBRARY] = 0,
    [GameSystemType.FID_IMPROVE] = 1,
    [GameSystemType.FID_AQUARIUM] = 2,
    [GameSystemType.FID_BOATS] = 3
}
local FuncImg = {
    [GameSystemType.FID_LIBRARY] = "ui://FunctionLock/成就@3x",
    [GameSystemType.FID_IMPROVE] = "ui://FunctionLock/进修@3x",
    [GameSystemType.FID_AQUARIUM] = "ui://FunctionLock/观赏馆@3x",
    [GameSystemType.FID_BOATS] = "ui://FunctionLock/游艇码头@3x"
}

function FunctionUnlockUI:OnOpen()
    self.SortingOrder = UISortOrder.FuncLock
    self.UI.sortingOrder = UISortOrder.FuncLock
    panel = self

    local window = self.UI:GetChild("Window")
    window:GetChild("tips_Text").text = Localize("FunctionLockTips")
    self.State_C = window:GetController("State_C")
    self.funcTitle = window:GetChild("icon_Title")
    self.buttonUnlock = window:GetChild("Button_Lock")
    self.textCost = self.buttonUnlock:GetChild("TextCost")
    self.numtxt = self.buttonUnlock:GetChild("numtxt")
    self.costType_C = self.buttonUnlock:GetController("Type_C")
    self.buttonUnlock.title = Localize("Unlock")
end

function FunctionUnlockUI:OnShow(funcID, unlockCallback)
    local func = FunctionOpenConfig.FunctionsByID[funcID]
    self.func = func
    self.unlockCallback = unlockCallback
    self.State_C.selectedIndex = FuncIndexMap[funcID]
    UIUtils.LangIcon(self.funcTitle, FuncImg[funcID])
    if func.IncomeSpeed ~= 0 then
        UIUtils.SetControllerIndex(self.costType_C, 1)
        self.numtxt.text = string.format(Localize("FuncUnlockIncome"), Utils.ResourceHandler(func.IncomeSpeed))
    else
        UIUtils.SetControllerIndex(self.costType_C, 0)
        CommonUIUtils.SetCurrencyLabel(self.textCost, func.UnlockCost, func.UnlockType)
    end

    self.buttonUnlock.grayed = not PlayerDatas.FunctionOpenData:ReadyUnlockFunc(func)
end

function FunctionUnlockUI:Unlock()
    if PlayerDatas.FunctionOpenData:ReadyUnlockFunc(self.func) then
        PlayerDatas.FunctionOpenData:OpenFunctionConsume(self.func)
        self.unlockCallback()
        self:Close()
        EventDispatcher:Dispatch(Event.OPEN_FUNC, self.func.ID, true)
        EventDispatcher:Dispatch(Event.SHOW_INCOME,self.func.ID-1,true)
        AudioManager.PlayEAXSound(1000)
    end
end

function FunctionUnlockUI:OnCurrencyChange()
    self.buttonUnlock.grayed = not PlayerDatas.FunctionOpenData:ReadyUnlockFunc(self.func)
end

-- 绑定事件
function FunctionUnlockUI:OnRegister()
    self.buttonUnlock.onClick:Add(function() self:Unlock() end)
    EventDispatcher:Add(Event.CURRENCY_CHANGED, self.OnCurrencyChange, self)
end

-- 解绑事件
function FunctionUnlockUI:OnUnRegister()
    self.buttonUnlock.onClick:Clear()
    EventDispatcher:Remove(Event.CURRENCY_CHANGED, self.OnCurrencyChange, self)
end

function FunctionUnlockUI:OnHide()
    if self.parentPanel and self.parentPanel.curTab == self then
        self.parentPanel.curTab = nil
    end
end

function FunctionUnlockUI:RenewTrainList()
end

return FunctionUnlockUI