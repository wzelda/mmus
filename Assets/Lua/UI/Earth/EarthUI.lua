local EarthUI = UIManager.PanelFactory(UIInfo.EarthUI)

local panel = EarthUI
local seasConfig
local firstSeaId
local seconSeaId

function EarthUI:OnOpen(arg)
    panel = self
    seasConfig = ConfigData.seaConfig.SeasByID
    local seaCfgArr = ConfigData.seaConfig.Seas

    self.points = {}
    self.frames = {}
    self.redots = {}
    for index, v in ipairs(seaCfgArr) do
        local seaId = v.ID
        local point = self.UI:GetChild("point"..index)
        local frame = self.UI:GetChild("frame"..index)
        if point and frame then
            UIUtils.SetControllerIndex(frame:GetController('Area_C'), index)
            self.points[seaId] = point
            self.frames[seaId] = frame
            point.onClick:Set(function () self:OpenSeaInfoWindow(seaId) end)
            frame.onClick:Set(function () self:OpenSeaInfoWindow(seaId) end)

            local redot = ReddotManger:CreateRedDot(RedDotType.Normal,AnchorType.TopRight,frame)
            redot:SetConditions(function ()
                return not PlayerDatas.SeaData:SeaUnlocked(seaId) and DependManager.PassedDepend(v.Depends)
            end)
            redot:SetEventListener(Event.SEA_UNLOCK)
            self.redots[seaId] = redot
        end
    end

    -- 首个海域
    firstSeaId = seaCfgArr[1].ID
    CommonUIObjectManager:Add(UIKey.FirstSeaBtn, self.frames[firstSeaId])
    seconSeaId = seaCfgArr[2].ID
    CommonUIObjectManager:Add(UIKey.SecondSeaBtn, self.frames[seconSeaId])
end

function EarthUI:DoClose()
    if self.UI.visible then
        UIManager.HideTab(UIInfo.MainUI, UIInfo.EarthUI)
        EventDispatcher:Dispatch(Event.CLOSED_TAB, UIInfo.EarthUI.UIComName)
    end
end

function EarthUI:OnShow(...)
    local nextSeaId = PlayerDatas.SeaData:GetNextSea()
    for k, v in pairs(seasConfig) do
        local point = self.points[k]
        local frame = self.frames[k]
        if nextSeaId and k > nextSeaId then
            point.visible = false
            frame.visible = false
        else
            point.visible = true
            frame.visible = true
            local unlock = PlayerDatas.SeaData:SeaUnlocked(k)
            self:UpdateSea(k)
            point.onClick:Set(function () self:OpenSeaInfoWindow(k) end)
            frame.onClick:Set(function () self:OpenSeaInfoWindow(k) end)
            -- 选中当前
            if k == PlayerDatas.SeaData.currentSea then
                UIUtils.SetControllerIndex(frame:GetController("c1"), 1)
            else
                UIUtils.SetControllerIndex(frame:GetController("c1"), unlock and 0 or 2)
            end
        end
        self.redots[k]:Refresh()
    end
end

local function CalcSeaIncome(seaId)
    local seaCfg = seasConfig[seaId]
    if nil == seaCfg then return end

    local income = 0
    for k, v in pairs(seaCfg.Products) do
        local fishIncome = PlayerDatas.FishData:GetFishIncomeById(ConfigData.seaConfig.ProductsByID[v].ItemID)
        income = income + fishIncome
    end
    return income
end

function EarthUI:UpdateSea(id)
    local cfg = seasConfig[id]
    local point = self.points[id]
    local frame = self.frames[id]
    frame.text = cfg.Name
    frame:GetChild("prizeLabel").text = string.format("%s%s", Utils.GetCountFormat(CalcSeaIncome(id)), Localize("UnitSeconds"))
    local unlock = PlayerDatas.SeaData:SeaUnlocked(id)
    if not unlock then
        UIUtils.SetControllerIndex(point:GetController("button"), 2)
        UIUtils.SetControllerIndex(frame:GetController("c1"), 2)
    end
end

function EarthUI:OpenSeaInfoWindow(seaId)
    local unlock = PlayerDatas.SeaData:SeaUnlocked(seaId)
    if not unlock then
        UIUtils.SetControllerIndex(self.points[seaId]:GetController("button"), 2)
        UIManager.OpenPopupUI(UIInfo.OceanAeraUI, seaId)
    else
        self:OpenSea(seaId)
        EventDispatcher:Dispatch(Event.SHOW_INCOME, 0,true)
    end
end

function EarthUI:OpenSea(seaId)
    if seaId and seaId ~= PlayerDatas.SeaData.currentSea then
        LevelManager.loadLevel(LevelType.Start, nil, function()
            LevelManager.loadLevel(LevelType.Fishing, {seaId = seaId})
            PlayerDatas.SeaData:OpenSea(seaId)
            AudioManager.PlayEAXSound(1009)
        end)
    end
    if firstSeaId == seaId then
        EventDispatcher:Dispatch(Event.CG_CLICK_BTN, UIKey.FirstSeaBtn)
    end
    self:DoClose()
end

function EarthUI:SelectSea(seaId)
    for id, v in pairs(seasConfig) do
        local point = self.points[id]
        local frame = self.frames[id]
        point.selected = id == seaId
        UIUtils.SetControllerIndex(frame:GetController("c1"), id == seaId and 1 or 2)
        if not PlayerDatas.SeaData:SeaUnlocked(id) then
            UIUtils.SetControllerIndex(point:GetController("button"), 2)
        end
    end
end

-- 绑定事件
function EarthUI:OnRegister()
    EventDispatcher:Add(Event.MAIN_TAB_OPEN, self.DoClose, self)
    EventDispatcher:Add(Event.SEA_UNLOCK, self.DoClose, self)
    EventDispatcher:Add(Event.MAIN_UI_RETURN, self.DoClose, self)
end

-- 解绑事件
function EarthUI:OnUnRegister()
    EventDispatcher:Remove(Event.MAIN_TAB_OPEN, self.DoClose, self)
    EventDispatcher:Remove(Event.SEA_UNLOCK, self.DoClose, self)
    EventDispatcher:Remove(Event.MAIN_UI_RETURN, self.DoClose, self)
end

function EarthUI:OnClose()
    for k, v in pairs(self.redots) do
        v:Destroy()
    end
    self.redots = nil
end

return EarthUI