--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

-- 购买确认界面
local ConfirmBuyUI = UIManager.PanelFactory(UIInfo.ConfirmBuyUI)
ConfirmBuyUI.SureCallBack = nil
ConfirmBuyUI.CancelCallBack = nil
ConfirmBuyUI.showPopupAnim = nil
ConfirmBuyUI.closePopupAnim = nil

function ConfirmBuyUI:Init(strTitle, strDesc, selIndex, costAmount, sureCb, cancelCb, sureTitle, cancelTitle, isResetStone, amountProto)
    
    -- self.textTipsTitle.text = ""
    -- self.textTipsDesc.text = ""
    -- self.textTipsDown.text = ""

    -- self.textTipsTitle.text = strTitle
    -- self.textTipsDesc.text = strDesc
    -- self.comCost.visible = true
    self.haveEnoughMoney = true
    if nil ~= costAmount and costAmount.type == AmountType.Currency then
        self.costCurrency = ConfigData:FindCurrencyTypeById(costAmount.id)
        if nil ~= self.costCurrency then           
            
            -- 英雄重置石消耗
            if isResetStone then
                -- self.stateBtnConfirmCtrl.selectedIndex = 2
                -- self.haveCtrl.selectedIndex = 1
                -- self.comCost.visible = false
                local costNum = tonumber(Utils.GetCountFormat2(costAmount.amount))
                local haveCount = tonumber(PlayerData.Datas.CurrencyData:GetHaveCountById(costAmount.id))
                -- self.resetCost.icon = UIInfo.Icon.UIImgPre..self.costCurrency.icon
                -- self.resetCost.title = "/"..costNum

                if costNum <= haveCount then
                    -- self.haveLabel.text = Utils.GetCountFormat2(haveCount)
                else
                    -- self.haveLabel.text ="[color=#FF0000]"..Utils.GetCountFormat2(haveCount)
                end
            else
                -- self.stateBtnConfirmCtrl.selectedIndex = 0
                -- self.haveCtrl.selectedIndex = 0
                -- self.comCost.visible = true
                -- self.comCost.icon = UIInfo.Icon.UIImgPre..self.costCurrency.icon
                -- self.comCost.title = Utils.GetCountFormat2(costAmount.amount)
            end

            local haveCount = PlayerData.Datas.CurrencyData:GetHaveCountById(costAmount.id)
            if haveCount >= costAmount.amount then
                
                self.haveEnoughMoney = true
                -- self.comCost:GetController("button_t").selectedIndex = 0
            else
                self.haveEnoughMoney = false
                -- self.comCost:GetController("button_t").selectedIndex = 1
            end
        end
    else
        -- self.haveCtrl.selectedIndex = 0
        -- self.stateBtnConfirmCtrl.selectedIndex = 1
        -- self.textConfirm.text = string.format("[size=60]%s[/size]", LocalizeExt(20259))
    end
    
    if nil ~= sureTitle then
        self.adBtn.title = sureTitle
    else
        -- self.textConfirm.text = LocalizeExt(20046)
    end

    if nil ~= cancelTitle then
        self.btnConfirm.title = cancelTitle
    else
        -- self.btnCancel.title = LocalizeExt(20047)
    end
    
    self.stateCtrl.selectedIndex = selIndex or 0

    if self.stateCtrl.selectedIndex == 4 then
        -- self.fade_T:Play()
    end

    if self.stateCtrl.selectedIndex == 0 or self.stateCtrl.selectedIndex == 1 then
        -- self.adBtn.title = sureTitle or LocalizeExt(20144)
--[[
        if type(sureCb) == "function" then
            self.adBtn.onClick:Set(
                function()
                    self.btnConfirm.onClick:Call()
                end
            )
        end
        ]]

        if amountProto then
            CommonUIUtils.SetCommonLabelAmountList(self.prizeList, {amountProto})
            local amountInfo = PlayerData.amounTool().GetAmountInfo(amountProto)
            self.prizeNameText.text = CommonUIUtils.SetContentColorUbbByQuality(LocalizationMgr.getServerLocStr(amountInfo.name), amountInfo.quality)
            -- self.prizeDescText.text = LocalizationMgr.getServerLocStr(amountInfo.desc)
        end
    end

    self.SureCallBack = sureCb
    self.CancelCallBack = cancelCb
end

function ConfirmBuyUI:UpdateCDTip(str)
    
    -- self.textTipsDown.text = str
end

-- 显示界面 
function ConfirmBuyUI:OnOpen(strTitle, strDesc, selIndex, costAmount, sureCb, cancelCb, sureTitle, cancelTitle, isResetStone, amountProto)
    
    self.showPopupAnim = UIManager.popupAnimTool():ShowPopupUIAnim(self.UI)
    local ui = self.UI
    -- self.imgBG = ui:GetChild("bg")

    self.stateCtrl = ui:GetController("State")
    -- self.fade_T = ui:GetTransition("fade_T")
    -- self.textTipsTitle = ui:GetChild("TipsTitle_Label")
    -- self.textTipsDesc = ui:GetChild("TipsInfo_Label")   
    -- self.textTipsDown = ui:GetChild("TipsInfo_Label_2")
    
    self.btnConfirm = ui:GetChild("Confirm_Btn")
    -- self.btnCancel = ui:GetChild("Cancel_Btn")
    -- self.btnClosed = ui:GetChild("Closed_Btn")
    self.adBtn = ui:GetChild("adBtn")
    self.adBtn.title = string.format(LocalizeExt(25851),2)
    self.prizeList = ui:GetChild("prizeList")
    self.prizeNameText = ui:GetChild("prizeNameText")
    -- self.prizeDescText = ui:GetChild("prizeDescText")
    -- self.textConfirm = self.btnConfirm:GetChild("Text")
    -- self.resetCost = self.btnConfirm:GetChild("Reset_Label")
    -- self.haveLabel = self.resetCost:GetChild("title2")
    -- self.haveCtrl = self.btnConfirm:GetController("Have")
    
    -- self.stateBtnConfirmCtrl = self.btnConfirm:GetController("tab")
    -- self.comCost = self.btnConfirm:GetChild("Cost_Label")

    local slota = ui:GetChild("slot_a")
    local slotb = ui:GetChild("slot_b")
    self.effecta = CommonUIUtils.CreateUIEff(slota,"UIEffects/Effect_UI_qiandao1",290)
    self.effectb = CommonUIUtils.CreateUIEff(slotb,"UIEffects/Effect_UI_qiandao2b",1800)


    self:Init(strTitle, strDesc, selIndex, costAmount, sureCb, cancelCb, sureTitle, cancelTitle, isResetStone, amountProto)
end

function ConfirmBuyUI:OnRegister()

    -- 关闭
    local OnClickClose = function()
        self.closePopupAnim = UIManager.popupAnimTool():ClosePopupUIAnim(self.UI, true, UIInfo.ConfirmBuyUI)
    end
    
    -- 确认
    local OnClickConfirm = function()
        if not self.haveEnoughMoney then
            local name = LocalizeExt(self.costCurrency.name)
            UIManager.ShowMsg(string.format(LocalizeExt(20214), name))
        else
            if nil ~= self.SureCallBack then
                self.SureCallBack()
            end
            OnClickClose()
        end
    end

    -- 取消
    local OnClickCancel = function()
        if nil ~= self.CancelCallBack then
            self.CancelCallBack()
        end
        OnClickClose()
    end

    -- self.imgBG.onClick:Add(OnClickClose)
    -- self.btnClosed.onClick:Add(OnClickClose)
    self.btnConfirm.onClick:Add(OnClickCancel)
    self.adBtn.onClick:Add(OnClickConfirm)
    -- self.btnCancel.onClick:Add(OnClickCancel)
    
    -- EventDispatcher:Add(Event.UPDATE_BUY_TIMES_CD, self.UpdateCDTip, self)
end

function ConfirmBuyUI:OnShow()
    
end

function ConfirmBuyUI:Hide()

end

-- 强制刷新,比如网络事件监听，切换语言包，断线重连等
function ConfirmBuyUI:OnRefresh(...)

end

-- 解绑各类事件
function ConfirmBuyUI:OnUnRegister()

    -- self.imgBG.onClick:Clear()
    -- self.btnClosed.onClick:Clear()
    self.btnConfirm.onClick:Clear()
    -- self.btnCancel.onClick:Clear()
    self.adBtn.onClick:Clear()
    
    -- EventDispatcher:Remove(Event.UPDATE_BUY_TIMES_CD, self.UpdateCDTip, self)
end

function ConfirmBuyUI:OnClose()

    self.SureCallBack = nil
    self.CancelCallBack = nil
    --停止动画（防止中间动画还未播放完，就打开或者关闭）
    if(self.showPopupAnim)then
        self.showPopupAnim:Stop()
    end
    if(self.closePopupAnim)then
        self.closePopupAnim:Stop()
    end
    self.showPopupAnim = nil
    self.closePopupAnim = nil

    CommonUIUtils.ClearUIEff(self.effecta)
    self.effecta = nil
    CommonUIUtils.ClearUIEff(self.effectb)
    self.effectb = nil

end

return ConfirmBuyUI
--endregion
