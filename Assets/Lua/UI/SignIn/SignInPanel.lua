--[[ 
 * Descripttion: 
 * version: 
 * Author: Mingo
 * Date: 2020-05-28 21:27:04
 * LastEditors: Mingo
 * LastEditTime: 2020-06-21 14:22:07
 ]]
local _C = UIManager.PanelFactory(UIInfo.SignIn)
local panel = nil
_C.HidePrePanel = false
local m_signInData = nil

local function BackBtnOnClick()
    UIManager.CloseUI(UIInfo.SignIn)
end

local function TabItemOnClick()
    -- 刷新主界面
    _C:RefreshUI()
end

local function DescBtnOnClick()
    UIManager.OpenUI(UIInfo.DirectionUI, nil, nil, 21314)
end

local function BuyBtnOnClick()
    -- MonthQianDaoDataProto
    local config = m_signInData:GetConfigById(_C.tabList.selectedIndex + 1)

    if config.need_buy_month_card ~= 0 and not PlayerData.Datas.MonthCardData:IsActive(config.need_buy_month_card) then
        UIManager.ShowMsg(LocalizeExt(25623))
    else
        PlayerData.Datas.RechargeData:RequestOrder(config.product_id)
    end
end

-- 创建可领取特效
local function CreateItemEffect(slot)
    local path = "UIEffects/Effect_UI_qiandao1"
    local effect = CommonUIUtils.CreateUIEff(slot,path,160)
    table.insert(panel.effects,effect)
    return effect
end

local function ClearAllEffects()
    for _,effect in ipairs(panel.effects) do
        CommonUIUtils.ClearUIEff(effect)
        effect = nil
    end
end

--临时的战魂奖励处理
local function TempHeroEffect(obj,amountInfo)
    if amountInfo.typeId == AmountType.HERO then
        local path = "UIEffects/Effect_UI_wukongtishi"
        local effect = CommonUIUtils.CreateUIEff(obj:GetChild("slot"),path,2000)
        table.insert(panel.effects,effect)
    end
end

local function TempHeroCheck(type)
    if type == AmountType.HERO then
        return false
    end
    return true
end



local function ListItemRenderer(index, obj)
    local config = m_signInData:GetConfigById(1)

    if config == nil then
        return
    end

    local amount = config.qian_dao_list[index + 1].prize.amounts[1]
    local amountInfo = AmountTool.GetAmountInfo(amount)
    local loader = obj:GetChild("loader")
    loader.url = CommonUIUtils.GetItemAmountURL(amountInfo, DefaultComURLMap)
    CommonUIUtils.RenderItemAmount(loader.component, amountInfo, true, nil, Vector2.zero, TempHeroCheck(amountInfo.typeId),1)
    obj:GetChild("DayText").text = string.format(LocalizeExt(20719), index + 1)
    -- 0:已领 1:补签 2:可领 3:不可领
    local state_C = obj:GetController("state_C")
    local qianDaoType, day = 1, index + 1

    if m_signInData:HasCollected(qianDaoType, day) then
        state_C.selectedIndex = 0
    elseif m_signInData:CanBuQian(qianDaoType, day) then
        state_C.selectedIndex = 1
        obj:GetChild("buqianText").text = LocalizeExt(20734)
        TempHeroEffect(obj,amountInfo)
    elseif m_signInData:CanCollect(qianDaoType, day) then
        state_C.selectedIndex = 2
        CreateItemEffect(obj:GetChild("slot"))
        TempHeroEffect(obj,amountInfo)
    else
        state_C.selectedIndex = 3
        TempHeroEffect(obj,amountInfo)
    end
    -- list:GetChildAt(0):GetController("State_C").selectedIndex = state_C.selectedIndex <= 1 and 1 or 0
end

local function ListOnClickItem(context)
    local obj = context.data
    local day = _C.list:ChildIndexToItemIndex(_C.list:GetChildIndex(obj)) + 1
    local qianDaoType = 1
    -- MonthQianDaoDataProto
    local config = m_signInData:GetConfigById(qianDaoType)
    -- QianDaoDataProto
    local itemConfig = config.qian_dao_list[day]
    -- 0:已领 1:补签 2:可领 3:不可领
    local state_C = obj:GetController("state_C")

    if state_C.selectedIndex == 1 then
        if Utils.CanWatchAd() and itemConfig.can_ad_bu_qian then
            UIManager.OpenPopupUI(
                UIInfo.ConfirmBuyUI,
                LocalizeExt(20037),
                LocalizeExt(25627),
                0,
                nil,
                function()
                    PlayerData.Datas.AdData:WatchAd(
                        AdsAwardType.SignInBuQian,
                        {
                            config.id,
                            day
                        }
                    )
                end,
                --function()
                --    m_signInData:C2SCollectProto(config.id, day)
                --end
                nil,
                LocalizeExt("看广告补签"),
                LocalizeExt("取消"),
                nil,
                itemConfig.prize.amounts[1]
            )
        else
            UIManager.ShowMsg("不允许补签，请检查显示逻辑")
            --[[
            local cost = m_signInData:GetCurrBuQianCost(qianDaoType)

            if cost then
                UIManager.OpenPopupUI(
                    UIInfo.ConfirmBuyUI,
                    LocalizeExt(20037),
                    LocalizeExt(25627),
                    nil,
                    cost.amounts[1],
                    function()
                        m_signInData:C2SBuQianProto(config.id, day)
                    end,
                    nil,
                    string.format(LocalizeExt("看广告补签")),
                    LocalizeExt("取消")
                )
            end
            ]]
        end
    elseif state_C.selectedIndex == 2 then
        if Utils.CanWatchAd() and itemConfig.can_ad_prize_double then
            UIManager.OpenPopupUI(
                UIInfo.ConfirmBuyUI,
                LocalizeExt(20037),
                LocalizeExt(25627),
                0,
                nil,
                function()
                    PlayerData.Datas.AdData:WatchAd(
                        AdsAwardType.SignInGetPrize,
                        {
                            config.id,
                            day
                        }
                    )
                end,
                function()
                    m_signInData:C2SCollectProto(config.id, day)
                end,
                string.format(LocalizeExt(25784), 2),
                LocalizeExt(20235),
                nil,
                itemConfig.prize.amounts[1]
            )
        else
            m_signInData:C2SCollectProto(config.id, day)
        end
    elseif state_C.selectedIndex == 3 and not TempHeroCheck(itemConfig.prize.amounts[1].type) then
        UIManager.OpenUI(UIInfo.HeroRecommendUI,nil,nil,itemConfig.prize.amounts[1].id)
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CD
------------------------------------------------------------------------------------------------------------------------------------------------------------------
local checkTable = {}

function _C:UpdateCd()
    if checkTable[self.tabList.selectedIndex] ~= nil then
        return
    end
    if _C and _C.IsOpen and m_signInData.currData then
        local data = m_signInData:GetDataById(self.tabList.selectedIndex + 1)
        -- MonthQianDaoDataProto
        local config = nil

        if data then
            config = data.data
        end

        if config and data and data.end_time then
            local cd = data.end_time - TimerManager.currentTime

            if cd <= 0 then
                checkTable[self.tabList.selectedIndex] = 0
                self:RefreshUI()
            else
                self.leftDaysText.text = string.format(LocalizeExt(25626), Utils.GetLeftTime(cd))
            end
        end
    end
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------
function _C:GoToTargetPage(qianDaoType)
    if type(qianDaoType) ~= "number" then
        return
    end

    for i = 0, self.tabList.numItems - 1 do
        local tab = self.tabList:GetChildAt(i)

        if tab.data == qianDaoType then
            tab.onClick:Call()
            break
        end
    end
end

-- 初始化一些配置
function _C:InitUIByConfig()
    self.tabList:RemoveChildrenToPool()

    -- config:MonthQianDaoDataProto
    for k, config in ipairs(m_signInData:GetAllConfigs()) do
        --local tab = self.tabList:AddItemFromPool()
        --tab.title = LocalizationMgr.getServerLocStr(config.name)
        --tab.data = config.type
        --local redCom = tab:GetChild("redPoint")
        --redCom.visible = false
    end

    self.tabList.selectedIndex = 0
end

function _C:RefreshUI()
    -- MonthQianDaoDataProto
    local config = m_signInData:GetConfigById(1)

    if config == nil then
        return
    end
    ClearAllEffects()

    -- self.nameText.text = LocalizationMgr.getServerLocStr(config.desc)
    -- self.descText.text = LocalizationMgr.getServerLocStr(config.detail_desc)
    self.list.numItems = #config.qian_dao_list
    self.descText.text = string.format(LocalizeExt(25850), m_signInData:GetSignedDays(config.type))

    -- 0:免费 1:未购买 2:已购买
    if #config.product_id == 0 then
        self.state_C.selectedIndex = 0
    elseif not m_signInData:HasBought(config.type) then
        self.state_C.selectedIndex = 1
        self.buyTipsText.text = LocalizeExt(25623)
        self.buyBtn.title = PlayerData.Datas.RechargeData:GetPriceStr(config.product_id)
    else
        self.state_C.selectedIndex = 2
        self:UpdateCd()
    end

    -- 红点
    for i = 0, self.tabList.numItems - 1 do
        local tab = self.tabList:GetChildAt(i)
        tab:GetChild("redPoint").visible = m_signInData:GetRedDotById(tab.data) > 0
    end
end

function _C:OnRefresh()
    self.topBarTool:OnRefresh()
    self:RefreshUI()
end

-- qianDaoType:QianDaoType
function _C:OnOpen(qianDaoType)
    panel = self
    self.effects = {}
    m_signInData = PlayerData.Datas.SignInData
    self.topBarTool = ClassConfig.UITopBarClass().new()
    self.topBarTool:OnOpen(EUIType.SignIn, self.UI:GetChild("topCom"), BackBtnOnClick, self, DescBtnOnClick)
    self.tabList = self.UI:GetChild("tabList")

    self.main = self.UI:GetChild("main")
    self.state_C = self.main:GetController("state_C")
    self.nameText = self.main:GetChild("nameText")
    self.descText = self.main:GetChild("descText")
    self.buyBtn = self.main:GetChild("buyBtn")
    self.buyTipsText = self.main:GetChild("buyTipsText")
    self.leftDaysText = self.main:GetChild("leftDaysText")
    self.closeBtn = self.UI:GetChild("closeBtn")
    self.list = self.main:GetChild("list")
    self.list:SetVirtual()

    if not self.endTimer then
        self.endTimer = TimerManager.intervalTodo(-1, 1, self.UpdateCd, nil, self, true)
    end

    self:InitUIByConfig()
    self:UpdateCd()
    self:GoToTargetPage(qianDaoType)
    EventDispatcher:Dispatch(Event.SHOW_FIETER_UI)
end

function _C:OnCollectOK()
    UIManager.CloseUI(UIInfo.ConfirmBuyUI)
    _C:RefreshUI()
end

-- 子类绑定各种事件
function _C:OnRegister()
    self.topBarTool:OnRegister()
    self.tabList.onClickItem:Set(TabItemOnClick)

    self.buyBtn.onClick:Set(BuyBtnOnClick)
    self.closeBtn.onClick:Set(BackBtnOnClick)
    self.list.itemRenderer = ListItemRenderer
    self.list.onClickItem:Set(ListOnClickItem)

    EventDispatcher:Add(Event.SIGN_IN_NOTIFY, self.RefreshUI, self)
    EventDispatcher:Add(Event.SIGN_IN_BUY_SUCCESS, self.RefreshUI, self)
    EventDispatcher:Add(Event.SIGN_IN_BU_QIAN_SUCCESS, self.RefreshUI, self)
    EventDispatcher:Add(Event.SIGN_IN_COLLECT_SUCCESS, self.OnCollectOK, self)
    -- EventDispatcher:Add(Event.UPDATE_MONTH_CARD, self.RefreshUI, self)
end

function _C:OnUnRegister()
    self.topBarTool:OnUnRegister()
    self.tabList.onClickItem:Clear()

    self.buyBtn.onClick:Clear()

    self.list.numItems = 0
    self.list.itemRenderer = nil
    self.list.onClickItem:Clear()

    EventDispatcher:Remove(Event.SIGN_IN_NOTIFY, self.RefreshUI, self)
    EventDispatcher:Remove(Event.SIGN_IN_BUY_SUCCESS, self.RefreshUI, self)
    EventDispatcher:Remove(Event.SIGN_IN_BU_QIAN_SUCCESS, self.RefreshUI, self)
    EventDispatcher:Remove(Event.SIGN_IN_COLLECT_SUCCESS, self.OnCollectOK, self)
    -- EventDispatcher:Remove(Event.UPDATE_MONTH_CARD, self.RefreshUI, self)
end

function _C:OnClose()
    EventDispatcher:Dispatch(Event.CLOSE_FIETER_UI)
    -- self.topBarTool:OnClose()
    -- Utils.ClearTableRef(self.topBarTool)
    self.topBarTool = nil

    for i = 0, self.tabList.numItems - 1 do
        self.tabList:GetChildAt(i).data = nil
    end

    ClearAllEffects()

    if self.endTimer then
        self.endTimer:onComplete()
        self.endTimer = nil
    end

    m_signInData = nil
end

return _C
