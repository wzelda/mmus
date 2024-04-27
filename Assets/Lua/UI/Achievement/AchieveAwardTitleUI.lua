local AchieveAwardTitleUI = UIManager.PanelFactory(UIInfo.AchieveAwardTitleUI)

local panel = AchieveAwardTitleUI

function AchieveAwardTitleUI:OnOpen(arg)
    panel = self

    self.bg = self.UI:GetChild("Bg")
    self.window = self.UI:GetChild("window")
    self.EffectGraph = self.window:GetChild("EffectGraph")
end

function AchieveAwardTitleUI.DoClose()
    UIManager.CloseUI(UIInfo.AchieveAwardTitleUI)
end

function AchieveAwardTitleUI:OnShow(...)
    local cfg = PlayerDatas.AchievementData:CurTitle()
    if cfg then
        self.window.text = string.format("[color=#fffef1,#E7FF77]%s", cfg.Name)
        UIUtils.SetControllerIndex(self.window:GetController("Title_C"), cfg.ID)
        UIUtils.LoadIcon(self.window, cfg.Icon, true)
    end

    local function effectCallback(wrap)
        self.EffectWrap = wrap
    end  
    CommonUIUtils.CreateUIModelFromPool(
        GameObjectManager.UIEffPoolName ,
        "Prefabs/Particle/waibao/UI/EFF_UI_faxianguangxiao.prefab",
        self.EffectGraph, effectCallback
    )
end

-- 绑定事件
function AchieveAwardTitleUI:OnRegister()
    self.bg.onClick:Set(self.DoClose)
end

-- 解绑事件
function AchieveAwardTitleUI:OnUnRegister()
    self.bg.onClick:Clear()
end

function AchieveAwardTitleUI:OnClose()
    if self.EffectWrap then
        CommonUIUtils.ReturnUIModelToPool(self.EffectWrap,GameObjectManager.UIEffPoolName)
        self.EffectWrap = nil
    end
end

return AchieveAwardTitleUI