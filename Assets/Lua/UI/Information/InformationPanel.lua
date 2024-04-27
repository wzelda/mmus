local InformationPanel = UIManager.PanelFactory(UIInfo.InformationUI)

local panel = InformationPanel
local selidx = 0

function InformationPanel:OnOpen(arg)
    panel = self

    self.bg = self.UI:GetChild("Bg")
    self.window = self.UI:GetChild("Window")
    self.closeBtn = self.window:GetChild("Button_Close")
    self.icon = self.window:GetChild("icon")
    self.bgmBtn = self.window:GetChild("Button_1")
    self.eaxBtn = self.window:GetChild("Button_2")
    self.shakeBtn = self.window:GetChild("Button_3")
    self.qualityTxt1 = self.window:GetChild("Text_Super")
    self.qualityTxt2 = self.window:GetChild("Text_High")
    self.qualityTxt3 = self.window:GetChild("Text_Power")
    self.title = self.window:GetChild("title")
    self.title.text = Localize("PlayerInformation")
    self.playerId = self.window:GetChild("Text_Title_2")
    self.playerName = self.window:GetChild("Text_Desc")
    self.version = self.window:GetChild("Text_Num")
    self.State_C = self.window:GetController("State_C")
    -- 画质
    for index = 1, 3 do
        self["qualityBtn" .. index] = self.window:GetChild("Toggle_" .. index)
        local btnTxt = self["qualityTxt" .. index]
        btnTxt.text = Localize("GameQuality" .. index)
        if index == QualityMgr.CurDeviceQuality and LocalizationMgr.GetCurrLanguageType().name == "CN" then
            btnTxt.text  = string.format("%s(%s)", btnTxt.text, Localize("Recommend"))
        end
    end
end

function InformationPanel:OnShow(...)
    self.version.text = Application.version
    self.playerId.text = string.format("%s%s", Localize("Account"), PlayerData.id)
    self.playerName.text = PlayerData.playerName
    self.eaxBtn.selected = AudioManager.GetAudioEffectVolume() == 0
    self.bgmBtn.selected = AudioManager.GetAudioMusicVolume() == 0
    self.shakeBtn.selected = not AudioManager.IsVibrate()
    UIUtils.SetControllerIndex(self.State_C, QualityMgr.GetUserQuaility() - 1)
    selidx = panel.State_C.selectedIndex
end

function InformationPanel:OnUpdate()
end

function InformationPanel.DoClose()
    UIManager.ClosePopupUI(UIInfo.InformationUI)
end

local function onClickEAX()
    AudioManager.SetAudioEffectVolume(panel.eaxBtn.selected and 0 or 1)
end

local function onClickBgm()
    AudioManager.SetAudioMusicVolume(panel.bgmBtn.selected and 0 or 1)
end

-- 震动开关
local function onClickShake()
    AudioManager.EnableVibrate(not panel.shakeBtn.selected)
end

-- 画质
local function onClickQuality(level)
    if level == selidx + 1 then
        return 
    end

    local sureCallback = function ()
        QualityMgr.SaveUserQuaility(level)
        selidx = panel.State_C.selectedIndex
    end
    local cancelCallback = function ()
        panel.State_C.selectedIndex = selidx
    end

    if level < QualityMgr.CurDeviceQuality then
        local popinfo = {}
        popinfo.title = Localize("SetHighGraphicTip")
        popinfo.sureCallback = sureCallback
        popinfo.cancelCallback = cancelCallback
        UIManager.OpenPopupUI(UIInfo.PopupUI, popinfo)
    elseif level == 3 then
        local popinfo = {}
        popinfo.title = Localize("SetGreenGraphicTip")
        popinfo.sureCallback = sureCallback
        popinfo.cancelCallback = cancelCallback
        UIManager.OpenPopupUI(UIInfo.PopupUI, popinfo)
    else
        sureCallback()
    end
end

-- 绑定事件
function InformationPanel:OnRegister()
    self.closeBtn.onClick:Set(self.DoClose)
    self.bg.onClick:Set(self.DoClose)
    self.eaxBtn.onClick:Set(onClickEAX)
    self.bgmBtn.onClick:Set(onClickBgm)
    self.shakeBtn.onClick:Set(onClickShake)
    for index = 1, 3 do
        self["qualityBtn" .. index].onClick:Set(function () onClickQuality(index) end)
    end
end

-- 解绑事件
function InformationPanel:OnUnRegister()
    self.closeBtn.onClick:Clear()
    self.bg.onClick:Clear()
    self.eaxBtn.onClick:Clear()
    self.bgmBtn.onClick:Clear()
    self.shakeBtn.onClick:Clear()
    for index = 1, 3 do
        self["qualityBtn" .. index].onClick:Clear()
    end
end

function InformationPanel:OnClose()
end

return InformationPanel