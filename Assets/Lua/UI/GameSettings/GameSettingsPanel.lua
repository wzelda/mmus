--[[
	@desc:设置界面
    author:better
    time:2020-06-20 14:43:53
]]
local GameSettingsPanel = UIManager.PanelFactory(UIInfo.GameSettingsUI)

local function CloseFunc()
    UIManager.CloseUI(UIInfo.GameSettingsUI)
end

function GameSettingsPanel:OnOpen()
    self.bgBtn = self.UI:GetChild("n0")
    local mainCom = self.UI:GetChild("n1")
    self.closeBtn = mainCom:GetChild("n21")
    self.subBtn_EAX = mainCom:GetChild("subBtn_EAX")
    self.addOneBtn_EAX = mainCom:GetChild("addOneBtn_EAX")
    self.slider_EAX = mainCom:GetChild("slider_EAX")
    self.subBtn_BGM = mainCom:GetChild("subBtn_BGM")
    self.addOneBtn_BGM = mainCom:GetChild("addOneBtn_BGM")
    self.slider_BGM = mainCom:GetChild("slider_BGM")
    --当前值
    self.slider_EAX.max = 100
    self.slider_EAX.value = AudioManager.GetAudioEffectVolume() * 100
    self.slider_BGM.max = 100
    self.slider_BGM.value = AudioManager.GetAudioMusicVolume() * 100
end

function GameSettingsPanel:EAXBtnValue(isSub)
    local change = 5
    if(isSub)then
        change = -5
    end
    self.slider_EAX.value = math.min(math.max(0, self.slider_EAX.value + change), 100)
    self:ChangeEAXValue()
end

function GameSettingsPanel:BGMBtnValue(isSub)
    local change = 5
    if(isSub)then
        change = -5
    end
    self.slider_BGM.value = math.min(math.max(0, self.slider_BGM.value + change), 100)
    self:ChangeBGMValue()
end

function GameSettingsPanel:ChangeEAXValue()
    local curValue =  self.slider_EAX.value * 0.01
    AudioManager.SetAudioEffectVolume(curValue)
end

function GameSettingsPanel:ChangeBGMValue()
    local curValue = self.slider_BGM.value * 0.01
    AudioManager.SetAudioMusicVolume(curValue)
end

function GameSettingsPanel:OnRegister()
    self.bgBtn.onClick:Add(CloseFunc)
    self.closeBtn.onClick:Add(CloseFunc)
    self.subBtn_EAX.onClick:Add(function() self:EAXBtnValue(true) end)
    self.addOneBtn_EAX.onClick:Add(function() self:EAXBtnValue(false) end)
    self.slider_EAX.onChanged:Add(function() self:ChangeEAXValue() end)
    self.subBtn_BGM.onClick:Add(function() self:BGMBtnValue(true) end)
    self.addOneBtn_BGM.onClick:Add(function() self:BGMBtnValue(false) end)
    self.slider_BGM.onChanged:Add(function() self:ChangeBGMValue() end)
end

function GameSettingsPanel:OnUnRegister()
    self.bgBtn.onClick:Clear()
    self.closeBtn.onClick:Clear()
    self.subBtn_EAX.onClick:Clear()
    self.addOneBtn_EAX.onClick:Clear()
    self.slider_EAX.onChanged:Clear()
    self.subBtn_BGM.onClick:Clear()
    self.addOneBtn_BGM.onClick:Clear()
    self.slider_BGM.onChanged:Clear()
end

function GameSettingsPanel:OnClose()
end

return GameSettingsPanel
