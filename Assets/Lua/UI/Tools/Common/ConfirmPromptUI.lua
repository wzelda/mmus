--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

-- 购买确认界面
local ConfirmPromptUI = class()
local panel = nil

function ConfirmPromptUI:ctor(ui)
    
    panel = self
    self.UI = ui
    self.imgBG = ui:GetChild("bg")
    self.textTipsTitle = ui:GetChild("TipsTitle_Label")
    self.textTipsDesc = ui:GetChild("TipsInfo_01_Label")
    self.textTipsDesc2 = ui:GetChild("TipsInfo_02_Label")
    self.textTipsNum = ui:GetChild("TipsInfo_04_Label")
    self.textTipsOnce = ui:GetChild("TipsInfo_05_Label")
    self.textTipsState = ui:GetChild("TipsInfo_06_Label")
    self.iconAmount = ui:GetChild("Icon")

    self.stateCtrl = ui:GetController("Status")

    self.btnConfirm = ui:GetChild("Confirm_Btn")
    self.btnClosed = ui:GetChild("Closed_Btn")

    self.stateBtnConfirmCtrl = self.btnConfirm:GetController("Tab")
    self.bgColorBtnConfirmCtrl = self.btnConfirm:GetController("Colour")
    self.comCost = self.btnConfirm:GetChild("Cost_Label")

    self.itemCom = ui:GetChild("Item")

    -- 关闭
    local OnClickClose = function()
        
        if nil ~= self.cancelCB then
            self.cancelCB()
            self.cancelCB = nil
        end
        --self.UI.visible = false
        UIManager.popupAnimTool():ClosePopupUIAnim( self.UI)
    end
    
    -- 点击确认
    local OnClickConfirm = function()
        
        if not self.haveEnoughMoney then
            
            local name = LocalizeExt(self.costCurrency.name)
            UIManager.ShowMsg(string.format(LocalizeExt(20214), name))
            return
        end

        OnClickClose()
        if nil ~= self.confirmCB then
            self.confirmCB()
            self.confirmCB = nil
        end
    end

    self.imgBG.onClick:Clear()
    self.btnClosed.onClick:Clear()
    self.btnConfirm.onClick:Clear()
    self.imgBG.onClick:Add(OnClickClose)
    self.btnClosed.onClick:Add(OnClickClose)
    self.btnConfirm.onClick:Add(OnClickConfirm)

    self.textTipsTitle.text = ""
    self.textTipsDesc.text = ""
    self.textTipsNum.text = ""
    self.textTipsOnce.text = ""
    self.textTipsState.text = ""

    self.UI.visible = false
end

-- 显示界面 selIndex(控制器状态0：购买提示 1：刷新 2：只购买一次提示)
function ConfirmPromptUI:Show(strTitle, strDesc, selIndex, amountInfo, costAmount, conformCb, cancelCb, strBtnTitle, btnBgColorIndex)
    
    --self.UI.visible = true
    if not self.UI.visible then
        UIManager.popupAnimTool():ShowPopupUIAnim(self.UI)
    end
    self.textTipsTitle.text = strTitle
    
    self.stateCtrl.selectedIndex = selIndex or 0

    local text = ""
    if 0 == selIndex then
        text = LocalizeExt(20260)
    elseif 1 == selIndex then
        text = LocalizeExt(20622)
    elseif 2 == selIndex or 5 == selIndex then
        text = LocalizeExt(20260)
        self.textTipsOnce.text = LocalizeExt(20654)
    end

    if nil ~= amountInfo then
        
        self.textTipsNum.visible = true
        self.iconAmount.visible = true
        self.textTipsNum.text = tostring(amountInfo.num)
        self.iconAmount.url = amountInfo.icon

        self.textTipsDesc.visible = true
        self.textTipsDesc2.visible = false
        self.textTipsDesc.text = strDesc
        self.itemCom.visible = true
        -- CommonUIUtils.SetCommonItemAndNum(self.itemCom, amountInfo, true)
    else
        self.textTipsNum.visible = false
        self.iconAmount.visible = false
        self.textTipsDesc.visible = false
        self.textTipsDesc2.visible = true
        self.textTipsDesc2.text = strDesc
        self.itemCom.visible = false
    end

    self.haveEnoughMoney = true
    if nil ~= costAmount and costAmount.type == AmountType.CURRENCY then
        self.costCurrency = ConfigData:FindCurrencyTypeById(costAmount.id)
        if nil ~= self.costCurrency then
            
            self.stateBtnConfirmCtrl.selectedIndex = 1
            self.comCost.icon = UIInfo.ResourcesIcon.UIImgPre..self.costCurrency.icon
            self.comCost.title = Utils.GetCountFormat2(costAmount.amount)

            local haveCount = PlayerData.Datas.CurrencyData:GetHaveCountById(costAmount.id)
            if haveCount >= costAmount.amount then
                
                self.haveEnoughMoney = true
                self.comCost:GetController("button_t").selectedIndex = 0
            else
                self.haveEnoughMoney = false
                self.comCost:GetController("button_t").selectedIndex = 1
            end
        end
    else
        self.stateBtnConfirmCtrl.selectedIndex = 0
        text = LocalizeExt(20259)
    end
    
    -- 按钮挑剔
    if nil ~= strBtnTitle then
        self.btnConfirm.title = strBtnTitle
    else
        self.btnConfirm.title = text
    end

    -- 按钮颜色
    if nil ~= btnBgColorIndex then
        self.bgColorBtnConfirmCtrl.selectedIndex = btnBgColorIndex
    end

    self.confirmCB = conformCb
    self.cancelCB = cancelCb
end

function ConfirmPromptUI:UpdateState(selIndex)
    
    self.stateCtrl.selectedIndex = selIndex or 0
end

function ConfirmPromptUI:SetTextLineSpacing(lineSpacing)
    
    local tf = self.textTipsDesc.textFormat
    tf.lineSpacing = lineSpacing
    self.textTipsDesc.textFormat = tf
end

-- 隐藏界面
function ConfirmPromptUI:Hide()
    UIManager.popupAnimTool():ClosePopupUIAnim(self.UI)
    --self.UI.visible = false
end

-- 是否显示
function ConfirmPromptUI:IsVisible()
    return self.UI.visible
end

function ConfirmPromptUI:Close()
    
    self.imgBG.onClick:Clear()
    self.btnClosed.onClick:Clear()
    self.btnConfirm.onClick:Clear()

    self.UI = nil
    self.confirmCB = nil
    self.cancelCB = nil

    self.textTipsTitle = nil
    self.textTipsInfo = nil
    self.btnConfirm = nil
    self.btnClosed = nil
    self.haveEnoughMoney = nil
    self.costCurrency = nil
    panel = nil
end

return ConfirmPromptUI
--endregion
