local IncomeUI = class()
-- view管理
local IncomeUIView = { }
-- view池
IncomeUIView.Pool = { }
-- 使用中
IncomeUIView.InUse = { }


local isShow

local needShow=true

local isFirst=true
-- local  function OnExit()
--     IncomeUI.Close()
-- end
-- EventDispatcher:Add(Event.SCENE_EXIT,OnExit);

-- local  function OnEnter()
--     if needShowExceptBattle then
--         return
--     end
--     needShowExceptBattle = false
--     IncomeUI.OnOpen()
-- end
-- 获取view
function IncomeUIView.getFromPool(_cb)
    local view = nil
    if #IncomeUIView.Pool > 0 then
        view = IncomeUIView.Pool[1]
        table.remove(IncomeUIView.Pool, 1)
        table.insert(IncomeUIView.InUse, view)
        if _cb then
            _cb(view)
        end
    else
        UIManager.CreateFairyCom(UIInfo.IncomeUI.UIPackagePath, UIInfo.IncomeUI.UIName, UIInfo.IncomeUI.UIComName , false, function(ui, pkgId)
            view = {}
            local child = ui:GetChild("Component_Income")
            ui.touchable = false;
            view.Root = ui
            view.PkgId = pkgId
            view.Effect = ui:GetTransition("Effect_X")
            view.Content = child:GetChild("Content")
            --view.Icon = child:GetChild("icon")
            table.insert(IncomeUIView.InUse, view)
            if _cb then
                _cb(view)
            end
        end)
    end
    
end

-- 返回池view
function IncomeUIView.backToPool(view)
    view.Root.visible = false
    table.insert(IncomeUIView.Pool, view)
    local index = nil
    for i , v in ipairs(IncomeUIView.InUse) do
        if view == v then
            index = i
            break
        end
    end
    if nil ~= index then
        table.remove(IncomeUIView.InUse, index)
    end
end

-- function IncomeUI:RefreshCurrency(coin)
--     if coin then
--         self.coinLabel.text = Utils.GetCountFormat(coin)
--     end
-- end

-- function IncomeUI:OnCoinIncome(coin)
--     self:RefreshCurrency(PlayerData.coinNum)
--     self:RefreshIncomeSpeed()
-- end

-- function IncomeUI:OnCurrencyChange(coin)
--     self:RefreshCurrency(PlayerData.coinNum)
-- end

-- function IncomeUI:RefreshIncomeSpeed()
--     self.Content.text = Utils.GetCountFormat(PlayerData:GetRealCoinIncome()) .. Localize("UnitSeconds")
-- end


function IncomeUI:ctor(parent, bottomUI)
    self:OnTabOpen(bottomUI.tabIndex)
    EventDispatcher:Add(Event.SHOW_INCOME, self.OnTabOpen, self)
    
end

function IncomeUI:Dispose()
    EventDispatcher:Remove(Event.SHOW_INCOME, self.OnTabOpen, self)
    self.clear()
end

function IncomeUI:OnTabOpen(tabIndex,flag)
    if flag then
        if tabIndex == 0 or tabIndex == 2 or tabIndex == 3 then
            self:Show(true)
        else
            self:Show(false)
        end
    else
        if isFirst then
            self:Show(true)
        else
            self:Show(false)
        end
    end    
end

local function onIncomeCoin(num)
    IncomeUIView.getFromPool(function(view)
        --第一次不显示，加载Ui会有延迟
        if isFirst then
            IncomeUIView.backToPool(view)
            isFirst = false
            return
        end
        --降低飘字频率
        if needShow then
            needShow=false
        else
            IncomeUIView.backToPool(view)
            needShow=true
            return
        end
        
        if not isShow  then
            IncomeUIView.backToPool(view)
            return
        end

        local safeArea = UIUtils.ScreenSafeArea()
        view.Root:SetXY((Screen.width/2/UIContentScaler.scaleFactor), (safeArea.height/3/UIContentScaler.scaleFactor))

        view.Root.visible = true
        view.Content.text = '+'..Utils.GetCountFormat(num) 
        view.Effect:Play( function() IncomeUIView.backToPool(view) end)
    end)
end


function IncomeUI:Show(isshow)
    if isshow   then
        if isShow then
            return
        end
        
        EventDispatcher:Add(Event.COIN_INCOME, onIncomeCoin)
    else
        EventDispatcher:Remove(Event.COIN_INCOME, onIncomeCoin)
        IncomeUI.clear()
    end
    isShow = isshow
end
 
    -- self.coinLabel.onClick:Add(function() self:OnCoinLabelClick() end)
    -- EventDispatcher:Add(Event.COIN_INCOME, self.OnCoinIncome, self)
    -- EventDispatcher:Add(Event.CURRENCY_CHANGED, self.OnCurrencyChange, self)
    -- EventDispatcher:Add(Event.FISH_LEVELUP, self.RefreshIncomeSpeed, self)
    -- EventDispatcher:Add(Event.FISH_GROWUP, self.RefreshIncomeSpeed, self)
    -- EventDispatcher:Add(Event.ADD_BUFFER, self.RefreshIncomeSpeed, self)
    -- EventDispatcher:Add(Event.AD_GET_DOUBLE_MONEY, self.RefreshDoubleMoney, self)
    -- self:RefreshCurrency(PlayerData.coinNum)
    -- self:RefreshIncomeSpeed()
   




function IncomeUI:OnCoinLabelClick()
end

function IncomeUI:Close()
    self.coinLabel.onClick:Clear()
    TimerManager.disposeTimer(self.doubleMoneyTimer)
    self.doubleMoneyTimer = nil
    -- for k, v in pairs(self.EffectWrap) do
    --     CommonUIUtils.ReturnUIModelToPool(v,GameObjectManager.UIEffPoolName)
    -- end
    -- EventDispatcher:Remove(Event.COIN_INCOME, self.OnCoinIncome, self)
    -- EventDispatcher:Remove(Event.CURRENCY_CHANGED, self.OnCurrencyChange, self)
    -- EventDispatcher:Remove(Event.FISH_LEVELUP, self.RefreshIncomeSpeed, self)
    -- -- EventDispatcher:Remove(Event.FISH_GROWUP, self.RefreshIncomeSpeed, self)
    -- EventDispatcher:Remove(Event.AD_GET_DOUBLE_MONEY, self.RefreshDoubleMoney, self)
    -- EventDispatcher:Remove(Event.ADD_BUFFER, self.RefreshIncomeSpeed, self)
   
end


--清除
function IncomeUI.clear()
    for _, v in pairs(IncomeUIView.InUse) do
        --v.Effect:Stop()
        UIManager.DisposeFairyCom(v.PkgId,v.Root)
    end
    for _, v in pairs(IncomeUIView.Pool) do
        --v.Effect:Stop()
        UIManager.DisposeFairyCom(v.PkgId,v.Root)
    end
    IncomeUIView.Pool = { }
    IncomeUIView.InUse = { }
end

-- -- 销毁
-- function IncomeUI.destroy()
--     EventDispatcher:Remove(Event.SCENE_ENTER,OnExit);
--     EventDispatcher:Remove(Event.SCENE_ENTER,OnEnter);
--     IncomeUI.clear()
-- end


return IncomeUI