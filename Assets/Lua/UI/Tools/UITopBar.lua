-- 系统顶部栏
local UITopBar = class()
UITopBar.uiType = nil
UITopBar.topUICom = nil
UITopBar.backFunc = nil
UITopBar.helpFunc = nil
UITopBar.mainPanel = nil
UITopBar.PlayerDataInfoCom = nil
UITopBar.userIconPkg = nil
UITopBar.stopRefreshCurrency = nil
UITopBar.currencyTab = {}
UITopBar.bShow = false

local EffJinbiHS = "JinbiHS"
local EffShuiDiHS = "ShuiDiHS"

-- 填充顶部资源栏(根据需求手动添加)
function UITopBar:FillTopUIResIcon()
    local currencyID = {}
    self.currencyTab = {}
    if self.uiType == EUIType.Actor then
        table.insert(currencyID, CurrencyTypeName.Diamond.id)
        table.insert(currencyID, CurrencyTypeName.Gold.id)
    elseif self.uiType == EUIType.Backpack then
        table.insert(currencyID, CurrencyTypeName.Diamond.id)
        table.insert(currencyID, CurrencyTypeName.Gold.id)
        -- table.insert(currencyID, CurrencyTypeName.Exp.id)
    elseif self.uiType == EUIType.BattleMain then
        table.insert(currencyID, CurrencyTypeName.Diamond.id)
        table.insert(currencyID, CurrencyTypeName.Gold.id)
        -- table.insert(currencyID, CurrencyTypeName.Exp.id)
    elseif self.uiType == EUIType.SoulFormation then
        table.insert(currencyID, CurrencyTypeName.Diamond.id)
        table.insert(currencyID, CurrencyTypeName.Gold.id)
        -- table.insert(currencyID, CurrencyTypeName.Exp.id)
    elseif self.uiType == EUIType.Summon then
        table.insert(currencyID, CurrencyTypeName.Diamond.id)
    elseif self.uiType == EUIType.SoulBattle then
        table.insert(currencyID, CurrencyTypeName.Diamond.id)
        table.insert(currencyID, CurrencyTypeName.Gold.id)
        -- table.insert(currencyID, CurrencyTypeName.Exp.id)
    end
    self.resList:RemoveChildrenToPool()
    for _, id in ipairs(currencyID) do
        local item = self.resList:AddItemFromPool()
        self.currencyTab[id] = item
        item:GetController("type_C").selectedIndex = id
    end
end

-- 根据货币id打开对应界面
function UITopBar:OpenUIFromCurrencyId(id)
    if id == CurrencyTypeName.Diamond.id then
        -- UIManager.ShowMsg("打开充值")
        -- UIManager.OpenUI(UIInfo.RechargeUI, nil, nil, RechargeTab.Recharge)
    elseif id == CurrencyTypeName.Gold.id then
        -- UIManager.ShowMsg("打开金币来源")
        -- UIManager.ShowSourcePopup(AmountType.CURRENCY, id)
    elseif id == CurrencyTypeName.Exp.id then
        -- UIManager.ShowMsg("打开经验来源")
        -- UIManager.ShowSourcePopup(AmountType.CURRENCY, id)
    end
end

-- 邮件
function UITopBar:OpenMailUI()
    --UIManager.ShowMsg("打开邮件")
    UIManager.OpenUI(UIInfo.MailUI)
end

-- 设置
function UITopBar:OpenSettingUI()
    UIManager.OpenUI(UIInfo.GameSettingsUI)
end

-- 刷新货币数量
function UITopBar:RefreshCurrency()
    local currencyData = PlayerData.Datas.CurrencyData

    if self.stopRefreshCurrency then
        return
    end

    for id, item in pairs(self.currencyTab) do
        item.title = tostring(Utils.GetCountFormat(currencyData:GetHaveCountById(id)))
    end
end

-- 刷新货币数量
function UITopBar:RefreshCurrency2(id, num)
    if self.uiType ~= EUIType.Actor then
        return
    end

    -- 临时只判断金币 水滴， 后续修改 num =（CurrencyData:GetTempCurrencyNum(id)）
    --[[local currencyData = PlayerData.Datas.CurrencyData
    if id == CurrencyTypeName.Gold.id then
        self.gold.title = tostring(Utils.GetCountFormat(currencyData:GetGoldNum() - num))
    end]]
end

-- 未读邮件提醒
function UITopBar:UnreadMailTip()
    --[[local count = PlayerData.Datas.MailData.unreadMailCount
    local bRed = count > 0
    self.mailBtn:GetController("TipsNew").selectedIndex = bRed and 1 or 0
    CommonUIUtils.ShowRedPoint(self.mailBtn:GetChild("red"), bRed, true, count, true)]]
end

-- 奖励特效
function UITopBar:ShowPrizeEffects(amounts)
    if nil ~= self.mainPanel and self.mainPanel.IsShow then
        UIManager.tipsTool():ShowResEffect(true, amounts, self, self.resEffecIndex)
    end
end

-- 货币刷新前
function UITopBar:BeforeUpdateCurrencyCount(type)
    if type ~= self.uiType then
        return
    end

    self:SetRefreshCurrency(true)

    local currencyData = PlayerData.Datas.CurrencyData
    self.preGoldNum = currencyData:GetGoldNum()
    self.preDiamondNum = currencyData:GetDiamondNum()
    self.preWaterNum = currencyData:GetWaterNum()
    self.preGuildGoldNum = currencyData:GetGuildGoldNum()

    self.prePlayerLevel = PlayerData.actorLevel

    self.resEffecIndex = self.resEffecIndex + 1
    local tab = {}
    tab[CurrencyTypeName.Gold.id] = {
        Num = currencyData:GetGoldNum(), currencyBtn = self.gold
    }
    tab[CurrencyTypeName.Diamond.id] = {
        Num = currencyData:GetDiamondNum(),
        currencyBtn = self.diamond
    }

    self.tabPreCurrencyNum[self.resEffecIndex] = tab
end

-- 货币刷新
function UITopBar:AfterUpdateCurrencyCount()
    for id, btn in pairs(self.currencyTab) do
        btn:GetTransition("t0"):Stop()
        btn.scale = Vector2.one
    end
    self:SetRefreshCurrency(false)
    self:RefreshCurrency()
    self.tabPreCurrencyNum = {}
end

-- 货币tips功能
function UITopBar:RegisterTips()
    for id, item in pairs(self.currencyTab) do
        local tipsBtn = item:GetChild("tipsBtn")
        UIManager.tipsTool():AddCurrencyTips(tipsBtn, id)
    end
end


function UITopBar:SetUIType(uiType)
    self.uiType = uiType
    self:RefreshText()
    --self:CreateCurrencyEffect()
end

function UITopBar:SetRefreshCurrency(stop)
    self.stopRefreshCurrency = stop
end

function UITopBar:RefreshText()

end

local function GetEffectName(id)
    local path = nil
    if id == CurrencyTypeName.Gold.id then
        path = Configs.EffectPathCfg().UIMainIcon2
    elseif id == CurrencyTypeName.Diamond.id then
        path = Configs.EffectPathCfg().UIMainIcon3
    elseif id == EffShuiDiHS then
        path = Configs.EffectPathCfg().UIHuiShouJZ
    elseif id == EffJinbiHS then
        path = Configs.EffectPathCfg().UIHuiShouJZH
    end

    return path
end

-- 特效
function UITopBar:CreateCurrencyEffect()
    for id, item in pairs(self.currencyTab) do
        if item.displayObject.gameObject.activeSelf then
            self:CreateEffects(item:GetChild("Holder"), id)
        end
    end
end

function UITopBar:CreateEffects(holder, id, scale)
    if nil ~= self.tabShowEffects[id] then
        return
    end

    local loadcb = function(_gameobject)
        if not self.bShow then
            GameObjectManager:ReturnToPool(GameObjectManager.UIEffPoolName, _gameobject)
            return
        end

        _gameobject:SetActive(true)
        _gameobject.transform.position = Vector3.zero
        _gameobject.transform.localScale = scale or Vector3(108, 108, 108)
        --gameobj.transform:Rotate(Vector3.up, 20)

        local goWrapper = GoWrapper(_gameobject)
        goWrapper.supportStencil = true
        holder:SetNativeObject(goWrapper)

        self.tabShowEffects[id] = {go = _gameobject, wrapper = goWrapper}
    end

    local resPath = GetEffectName(id)
    GameObjectManager:GetFromPool(GameObjectManager.UIEffPoolName, resPath, loadcb)
end

function UITopBar:ClearEffectById(id)
    local eff = self.tabShowEffects[id]
    if nil ~= eff then
        eff.wrapper.wrapTarget = nil
        eff.wrapper:Dispose()
        eff.wrapper = nil
        if eff.go ~= nil and not Utils.unityTargetIsNil(eff.go) then
            GameObjectManager:ReturnToPool(GameObjectManager.UIEffPoolName, eff.go)
        end
        eff.go = nil
        self.tabShowEffects[id] = nil
    end
end

function UITopBar:ClearEffects()
    for i, v in pairs(self.tabShowEffects) do
        if v.go ~= nil and not Utils.unityTargetIsNil(v.go) then
            GameObjectManager:ReturnToPool(GameObjectManager.UIEffPoolName, v.go)
        end
        v.go = nil
        v.wrapper.wrapTarget = nil
        v.wrapper:Dispose()
        v.wrapper = nil
    end
    self.tabShowEffects = {}
end

function UITopBar:RefreshRedPoint(count)
    if count==nil then
        self.mailBtn:GetChild("redPoint").visible = PlayerData.Datas.MailData:GetUnReadMailCount() > 0
    else
        self.mailBtn:GetChild("redPoint").visible = count > 0
    end
end

-- 参数（EUIType , top组件， 返回回调）
function UITopBar:OnOpen(uiType, topUICom, backFunc, mainPanel, helpFunc)
    self.uiType = uiType
    self.topUICom = topUICom
    self.backFunc = backFunc
    self.mainPanel = mainPanel
    self.helpFunc = helpFunc

    self.resList = topUICom:GetChild("resList")
    self:FillTopUIResIcon()

    self.mailBtn = self.topUICom:GetChild("mailBtn")
    PlayerData.Datas.MailData:NewC2SUnreadMailCountMsg()

    self.settingBtn = self.topUICom:GetChild("settingBtn")

    -- self:RegisterTips()

    self.bShow = true
    self.tabPreCurrencyNum = {}
    self.tabShowEffects = {}
    self.resEffecIndex = 0
end

function UITopBar:RegisterCurrency(currencyCom, currencyId)

    if self.currencyMap==nil then
        self.currencyMap = {}
    end
    
    local addBtn = currencyCom:GetChild("icon")
    if(addBtn)then
        addBtn.onClick:Clear()
        addBtn.onClick:Add(function()
            self:OpenUIFromCurrencyId(currencyId)
        end)
        self.currencyMap[currencyId] = addBtn
    end
end

function UITopBar:RegisterAllCurrency()
    for currencyId, currencyCom in pairs(self.currencyTab)do
        self:RegisterCurrency(currencyCom, currencyId)
    end
end

function UITopBar:UnRegisterAllCurrency()
    for currencyId, currencyCom in pairs(self.currencyTab)do
        self.currencyMap[currencyId].onClick:Clear()
    end
end


function UITopBar:OnRegister()
    self:RegisterAllCurrency()
    self.mailBtn.onClick:Add(function() self:OpenMailUI() end)
    self.settingBtn.onClick:Add(function() self:OpenSettingUI() end)

    EventDispatcher:Add(Event.CURRENCY_CHANGED, self.RefreshCurrency, self)
    EventDispatcher:Add(Event.CURRENCY_CHANGED_HERO_AUTO_UPGRADE, self.RefreshCurrency2, self)
    EventDispatcher:Add(Event.UPDATE_MAIL_RED_PROMPT,self.RefreshRedPoint,self)
    EventDispatcher:Add(Event.UNREAD_MAIL_COUNT, self.RefreshRedPoint,self)
end

function UITopBar:OnShow()
    self.bShow = true
end

function UITopBar:OnHide()
    self.bShow = false

    self:ClearEffectById(EffJinbiHS)
    self:ClearEffectById(EffShuiDiHS)
end

function UITopBar:OnRefresh(...)
    self:RefreshText()
    self:RefreshCurrency()

    -- 邮件红点
    self:UnreadMailTip()
end

function UITopBar:OnUpdate()
end

function UITopBar:OnFixedUpdate()
end

function UITopBar:OnUnRegister()
    self.mailBtn.onClick:Clear()
    self.settingBtn.onClick:Clear()
    -- self.resList:RemoveChildrenToPool()

    self:UnRegisterAllCurrency()

    EventDispatcher:Remove(Event.CURRENCY_CHANGED, self.RefreshCurrency, self)
    EventDispatcher:Remove(Event.CURRENCY_CHANGED_HERO_AUTO_UPGRADE, self.RefreshCurrency2, self)
    EventDispatcher:Remove(Event.UPDATE_MAIL_RED_PROMPT,self.RefreshRedPoint,self)
    EventDispatcher:Remove(Event.UNREAD_MAIL_COUNT, self.RefreshRedPoint,self)

--[[     EventDispatcher:Remove(Event.UNREAD_MAIL_COUNT, self.UnreadMailTip, self)
    EventDispatcher:Remove(Event.NEW_MAIL_NOTIFY, self.UnreadMailTip, self)
    EventDispatcher:Remove(Event.UPDATE_MAIL_STATE, self.UnreadMailTip, self)
    EventDispatcher:Remove(Event.UPDATE_MAIL_RED_PROMPT, self.UnreadMailTip, self)
    EventDispatcher:Remove(Event.BEFORE_UPDATE_CURRENCY_NUM, self.BeforeUpdateCurrencyCount, self)
    EventDispatcher:Remove(Event.AFTER_UPDATE_CURRENCY_NUM, self.AfterUpdateCurrencyCount, self)
    EventDispatcher:Remove(Event.SHOW_PRIZE_EFFECT, self.ShowPrizeEffects, self) ]]
end

function UITopBar:OnClose()
    self.updateCurrencyTimer = TimerManager.disposeTimer(self.updateCurrencyTimer)
    self:ClearEffects()

    self.uiType = nil
    self.topUICom = nil
    self.backFunc = nil
    self.helpFunc = nil
    self.mainPanel = nil
    self.mailBtn = nil
    self.settingBtn = nil
    self.tabPreCurrencyNum = nil
    self.stopRefreshCurrency = nil
    self.currencyTab = {}
    self.bShow = false
end

return UITopBar
