--region *.lua
--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local PrizesListPanel = UIManager.PanelFactory(UIInfo.PrizeListUI)
PrizesListPanel.confirmCallback = nil
PrizesListPanel.closeCallback = nil

local panel = nil
local bAddPlace = false
local m_wrapper = nil

-- 关闭界面
local function OnClickClose()
    
    if nil ~= panel.closeCallback then
        panel.closeCallback()
    end

    UIManager.popupAnimTool():ClosePopupUIAnim( panel.UI, true, UIInfo.PrizeListUI)
end

-- 点击收取奖励
local function OnClickCollectedPrize()
    if nil ~= panel.confirmCallback then
        
        panel.confirmCallback()
    end
    UIManager.popupAnimTool():ClosePopupUIAnim( panel.UI, true, UIInfo.PrizeListUI)
end

-- 创建特效
function PrizesListPanel:CreateEffects(holder, resPath)
    m_wrapper = CommonUIUtils.CreateUIEff(holder, resPath, 150)
end

local sortFunc = require "UI.Tools.AmountTools".SortAmount

-- 显示奖励界面
function PrizesListPanel:ShowMsg(amounts, title, confirmCb, closeCb)
    
    title = title or LocalizeExt(20779)
    self.textTitle.text = string.format("[color=#fffca4,#ffbf6d]%s[/color]", title)
    self.confirmCallback = confirmCb
    self.closeCallback = closeCb
    
    local strNum, strUnit = nil
    table.sort(amounts, sortFunc)
    self.amountsList = amounts

    bAddPlace = false
    local count = #self.amountsList
    if count > 7 then

        self.listPrizes.scrollPane.bouncebackEffect = true
    else
        self.listPrizes.scrollPane.bouncebackEffect = false
    end
    self.listPrizes.scrollPane.percX = 0
    CommonUIUtils.SetCommonLabelAmountList(self.listPrizes, amounts)
end

function PrizesListPanel:OnOpen(amounts, title, confirmCb, closeCb)
    panel = self
    self.comBoxGiftTips = self.UI
    self.gldBG = self.comBoxGiftTips:GetChild("bg")
    self.textTitle = self.comBoxGiftTips:GetChild("Title")
    self.textTips = self.comBoxGiftTips:GetChild("Tip_Label")
    self.holder = self.comBoxGiftTips:GetChild("Holder")    
    self.comItemList = self.comBoxGiftTips:GetChild("ItemList_Label")
    self.listPrizes = self.comItemList:GetChild("NewItemList")
    self.textTips.text = LocalizeExt(20671)

    -- 创建特效
    self:CreateEffects(self.holder, "UIEffects/Eff_ui_tongyongjiesuo")
    self:ShowMsg(amounts, title, confirmCb, closeCb)

    -- AudioManager.PlaySound(AudioState.Play, Configs.AudioConfig().UI_PrizeList_Open)
    UIManager.popupAnimTool():ShowPopupUIAnim(self.UI)
end

-- 子类绑定各种事件
function PrizesListPanel:OnRegister()

    self.gldBG.onClick:Add(OnClickClose)
end

function PrizesListPanel:OnShow()
    
end

function PrizesListPanel:OnHide()
    
end

-- 强制刷新,比如网络事件监听，切换语言包，断线重连等
function PrizesListPanel:OnRefresh(...)
    
end

-- 解绑各类事件
function PrizesListPanel:OnUnRegister()
    
    self.gldBG.onClick:Clear()

    self.listPrizes.numItems = 0
    self.listPrizes.itemProvider = nil
    self.listPrizes.itemRenderer = nil
end

-- 关闭
function PrizesListPanel:OnClose()
    m_wrapper = CommonUIUtils.ClearUIEff(m_wrapper)
    self.confirmCallback = nil
    self.closeCallback = nil
    self.comBoxGiftTips = nil
    self.gldBG = nil
    self.textTitle = nil
    self.listPrizes = nil
    self.amountsList = nil

    panel = nil

    EventDispatcher:Dispatch(Event.CLOSE_PRIZE_PANEL)
end

return PrizesListPanel
--endregion
