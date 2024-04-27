--[[ 
 * Descripttion: 
 * version: 
 * Author: Mingo
 * Date: 2020-06-09 18:47:28
 * LastEditors: Mingo
 * LastEditTime: 2020-06-13 19:28:27
]]

local ItemBuyPanel = UIManager.PanelFactory(UIInfo.ItemBuyPanel)
local panel = nil


local function SetNumber(arg)
    local num = 0
    if type(arg) ~= "number" then
        num = arg.sender.value
    else
        num = arg
    end

    if num > panel.slider.max then
        num = panel.slider.max
    elseif num<panel.slider.min then
        num = panel.slider.min
    end

    panel.number = num
    panel.slider.value = num
    panel.cost.title = math.ceil(panel.costConfig.amount * num)
end

local function Subtract()
    SetNumber(panel.number - 1)
end


local function Add()
    SetNumber(panel.number + 1)    
end

local function Buy()
    panel.buyFunc(panel.number)
end


function ItemBuyPanel:OnOpen(prize,costConfig,buyFunc)
    panel = self

    self.prize = prize
    self.itemConifg = ConfigData:FindCurrencyTypeById(prize.id)
    self.costConfig = costConfig
    self.buyFunc = buyFunc

    local com = self.UI:GetChild("com")
    self.closeBtn = com:GetChild("closeBtn")
    self.loader = com:GetChild("loader")
    self.itemName = com:GetChild("itemName")
    self.hasNum = com:GetChild("hasNum")
    self.descLabel = com:GetChild("descLabel")
    self.subBtn = com:GetChild("subBtn")
    self.addBtn = com:GetChild("addBtn")
    self.slider = com:GetChild("slider")
    self.buyBtn = com:GetChild("buyBtn")
    self.cost = self.buyBtn:GetChild("cost")
    SetNumber(1)

    self:RefreshUI()
end

function ItemBuyPanel:RefreshUI()

    SetNumber(self.slider.value)
    local amountInfo = AmountTool.GetAmountInfo(self.prize)
    self.loader.url = CommonUIUtils.GetItemAmountURL(amountInfo, DefaultComURLMap,false)
    CommonUIUtils.RenderItemAmount(self.loader.component, amountInfo, false, nil, Vector2.zero, false)

    self.itemName.text = LocalizationMgr.getServerLocStr(self.itemConifg.name)
    self.descLabel.text = LocalizationMgr.getServerLocStr(self.itemConifg.desc) 
    self.hasNum.text = PlayerData.Datas.CurrencyData:GetHaveCountById(self.prize.id)
end

function ItemBuyPanel:OnRegister()
    self.closeBtn.onClick:Add(function() UIManager.CloseUI(UIInfo.ItemBuyPanel) end)
    self.subBtn.onClick:Add(Subtract)
    self.addBtn.onClick:Add(Add)
    self.buyBtn.onClick:Add(Buy)
    self.slider.onChanged:Add(SetNumber)

    EventDispatcher:Add(Event.BUY_CHALLENGE_TIMES,self.RefreshUI,self)
end

function ItemBuyPanel:OnUnRegister()
    self.closeBtn.onClick:Clear()
    self.subBtn.onClick:Clear()
    self.addBtn.onClick:Clear()
    self.buyBtn.onClick:Clear()
    self.slider.onChanged:Clear()
    
    EventDispatcher:Remove(Event.BUY_CHALLENGE_TIMES,self.RefreshUI,self)
end

function ItemBuyPanel:OnClose()
    
end

return ItemBuyPanel
