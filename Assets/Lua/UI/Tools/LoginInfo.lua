--查看登陆信息
local LoginInfo = class()
LoginInfo.view = nil
LoginInfo.viewPkgId = nil
LoginInfo.loginAddressLabel = nil
LoginInfo.loginTimeCostLabel = nil
LoginInfo.protoPraseCostLabel = nil
function LoginInfo:OnShow()
    if(not self.view)then
        self.view,self.viewPkgId = UIManager.CreateFairyCom(UIInfo.GmOrderUI.UIPackagePath,UIInfo.GmOrderUI.UIName,"LoginInfo")
        self.loginAddressLabel = self.view:GetChild("ServerAddress")
        self.loginTimeCostLabel = self.view:GetChild("LoginTimeCost")
        self.getUserTimeCostLabel = self.view:GetChild("GetUserInfoTimeCost")
        self.protoPraseCostLabel = self.view:GetChild("ProtoPraseTimeCost")

        local bg = self.view:GetChild("Bg")
        bg.onClick:Add(function() 
            self.view.visible = false
         end)
        self.view.sortingOrder = 901
    end
    self.view.visible = true
    local loginData = PlayerData.Datas.LoginData
    local serverConfig = Utils.GetData("SetServerConfig")
    self.loginAddressLabel.text = string.format("%s:%s", serverConfig.ip, serverConfig.port)
    local t1 = loginData.reciveLoginTime - loginData.sendLoginTime
    local t2 = loginData.getPlayerDataTime - loginData.reciveLoginTime
    local t3 = loginData.prasePlayerDataTime - loginData.getPlayerDataTime
    self.loginTimeCostLabel.text = string.format("%.3f s", t1)
    self.getUserTimeCostLabel.text = string.format("%.3f s", t2)
    self.protoPraseCostLabel.text = string.format("%.3f s", t3)
end

function LoginInfo:OnClose()
    UIManager.DisposeFairyCom(self.viewPkgId,self.view)
end

return LoginInfo