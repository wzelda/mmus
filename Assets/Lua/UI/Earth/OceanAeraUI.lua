local OceanAeraUI = UIManager.PanelFactory(UIInfo.OceanAeraUI)

local panel = OceanAeraUI
local seaId
local DependsConfig = Utils.LoadConfig("Config.DependsConfig")

function OceanAeraUI:OnOpen(arg)
    panel = self

    self:sortingOrder(UISortOrder.PopupUI)
    self.window = self.UI:GetChild("frame")
    self.baseWindow = self.window:GetChild("baseWindow")
    self.closeBtn = self.baseWindow:GetChild("closeBtn")
    self.goBtn = self.window:GetChild("goBtn")
    self.incomeLabel = self.window:GetChild("incomeLabel")
    self.condition1 = self.window:GetChild("condition1")
    self.condition2 = self.window:GetChild("condition2")
    self.window:GetChild("unlockTxt").text = Localize("UnlockRequire")
end

function OceanAeraUI.DoClose()
    UIManager.ClosePopupUI(UIInfo.OceanAeraUI)
end

function OceanAeraUI:OnShow(arg)
    self.incomeLabel.text = "X10"
    local order = 0
    seaId, order = PlayerDatas.SeaData:GetNextSea()
    self.goBtn.text = Localize("EnterSea")
    UIUtils.SetControllerIndex(self.window:GetController('Area_C'), order)
    local cfg = ConfigData.seaConfig.SeasByID[seaId]
    if cfg then
        self.baseWindow.text = cfg.Name
        self.goBtn.enabled = DependManager.PassedDepend(cfg.Depends)
        local depends = DependManager.GetDepends(cfg.Depends)
        for i, v in ipairs(depends) do
            local conditionTxt = self["condition" .. i]
            if conditionTxt then
                UIUtils.SetControllerIndex(conditionTxt:GetController("c1"), DependManager.CheckDependency(v) and 1 or 0)
                conditionTxt.text = v.title
            end
        end
    end
end

-- 绑定事件
function OceanAeraUI:OnRegister()
    self.closeBtn.onClick:Add(self.DoClose)
    self.goBtn.onClick:Add(function () self:OpenSea() end)
end

-- 解绑事件
function OceanAeraUI:OnUnRegister()
    self.closeBtn.onClick:Clear()
    self.goBtn.onClick:Clear()
end

function OceanAeraUI:OnClose()
end

function OceanAeraUI:OpenSea()
    if seaId and seaId ~= PlayerDatas.SeaData.currentSea then
        -- 直接切场景的时候UI会停止渲染（场景中的主相机会被销毁），所以要先跳到Start场景，然后再加载另一个场景
        LevelManager.loadLevel(LevelType.Start, nil, function()
            LevelManager.loadLevel(LevelType.Fishing, {seaId = seaId})
            PlayerDatas.SeaData:OpenSea(seaId)
            AudioManager.PlayEAXSound(1009)
        end)
    end
    self.DoClose()
end

return OceanAeraUI