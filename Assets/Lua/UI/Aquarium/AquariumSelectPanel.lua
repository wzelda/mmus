
-- 水族箱选择界面

local AquariumConfig = Utils.LoadConfig("Config.AquariumConfig")
local DependManager = require ("Manager.DependManager")
local DependsConfig = Utils.LoadConfig("Config.DependsConfig")

local AquariumSelectPanel = UIManager.PanelFactory(UIInfo.AquariumSelectUI)

AquariumSelectPanel.HidePrePanel = true

local aquariumData

local function itemRender(index, ui)
    local cfg = AquariumConfig.Aquariums[index + 1]

    ui:GetChild("title").text =  cfg.Name
    --ui:GetChild("icon").icon = "ui://Library/"..tostring(cfg.Icon)

    local switchBtn = ui:GetChild("Button_Switch")
    local stateCtrl = ui:GetController("State_C")
    local areaCtrl = ui:GetController("Area_C")

    areaCtrl.selectedIndex = index+1

    local data = aquariumData.aquariums[cfg.ID]
    if (data ~= nil) then
        -- 已解锁的观赏馆
        if (aquariumData.currentAquarium == cfg.ID) then
            -- 当前观赏馆
            stateCtrl.selectedIndex = 1
            ui:GetChild("Text_State").text = Localize("AquariumSelectCurrent")
        else
            switchBtn.text = Localize("切  换")
            stateCtrl.selectedIndex = 0
        end

        local bar = ui:GetChild("Bar")
        bar.value = aquariumData:GetProgress(data) * bar.max

        ui:GetChild("Label_Money").text = Utils.GetCountFormat(aquariumData:GetIncome(data))..Localize("UnitSeconds")
    else
        -- 未解锁的观赏馆

        -- 依赖条件判定
        local readyCount = 0
        local depends = DependManager.GetDepends(cfg.Depends)
        for i,v in ipairs(depends) do
            local depText = ui:GetChild("Text_Depend"..tostring(i))

            local ready = DependManager.CheckDependency(v)
            
            if depText then
                depText.text = v.title
                depText.grayed = not ready
            end

            if ready then
                readyCount = readyCount + 1
            end
        end
        
        if readyCount >= #depends then
            -- 解锁条件满足
            stateCtrl.selectedIndex = 3
            switchBtn.text = Localize("建  造")
        else
            -- 解锁条件不满足
            stateCtrl.selectedIndex = 2
        end
    end

    switchBtn.onClick:Set(function()
        local config = AquariumConfig.Aquariums[index + 1]
        PlayerData.Datas.AquariumData:OpenAquarium(config.ID, true)
        local aquarium = PlayerData.Datas.AquariumData:GetCurAquarium()
        -- 直接切场景的时候UI会停止渲染（场景中的主相机会被销毁），所以要先跳到Start场景，然后再加载另一个场景
        LevelManager.loadLevel(LevelType.Start, nil, function()
            LevelManager.loadLevel(LevelType.Aquarium, {config=config,sceneName=config.Scene,aquarium=aquarium,config=config})
            AquariumSelectPanel:CloaseWindow()
        end)
    end)
end

function AquariumSelectPanel:OnOpen()
    aquariumData = PlayerData.Datas.AquariumData

    local main = self.UI:GetChild("Main")
    self.closeBtn = main:GetChild("Button_Close")
    self.List = main:GetChild("List")
    self.titleTxt = main:GetChild("Text_Title")

    self.List.itemRenderer = itemRender
    self.List.numItems = #AquariumConfig.Aquariums

    self.titleTxt.text = Localize("AquariumSelectTitle")
end

function AquariumSelectPanel:TakePhoto()
end

function AquariumSelectPanel:OnRegister()
    self.closeBtn.onClick:Add(function() self:CloaseWindow() end)
end

function AquariumSelectPanel:CloaseWindow()
    UIManager.CloseUI(UIInfo.AquariumSelectUI)
    EventDispatcher:Dispatch(Event.SHOW_INCOME, 0,true)
end

function AquariumSelectPanel:OnUnRegister()
    self.closeBtn.onClick:Clear()
end

return AquariumSelectPanel