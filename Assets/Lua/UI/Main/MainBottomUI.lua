
local FishList = require "UI.Main.FishList"
local AquariumShowList = require "UI.Main.AquariumShowList"

local MainBottomUI = class()
local panel = MainBottomUI
local tabFunction = {
    [0] = "ShowAquariumTab",
    [1] = "ShowManageTab",
    [2] = "ShowFishingTab",
    [3] = "ShowBoatTab",
    [4] = "ShowLibraryTab"
}

function MainBottomUI:ctor(parent, parentPanel)
    UIManager.CreateFairyCom(UIInfo.MainBottomUI.UIPackagePath, UIInfo.MainBottomUI.UIName, UIInfo.MainBottomUI.UIComName, false, function(ui, pkgId)
        self.UI = ui
        self.PackageId = pkgId
        ui.sortingOrder = 2
        parent:AddChild(ui, 1)
        self.parentPanel = parentPanel
        self:OnOpen()
    end)
end

function MainBottomUI:NewBuff(config)
    UIManager.ShowMsg(config.BufferDesc,TipMsgType.COVER)
end

function MainBottomUI:HandleUIOpen(uiname)
    -- 打开一些UI时关闭列表
    if uiname == UIInfo.EarthUI.UIComName then
        self.currentListStatus = self.labelControl.selectedIndex
        self.labelControl.selectedIndex = 0
    end
end

function MainBottomUI:HandleUIClose(uiname)
    -- 关闭特殊UI时的处理
    if uiname == UIInfo.EarthUI.UIComName then
        if self.tabIndex == 1 or self.tabIndex == 4 then
            self.labelControl.selectedIndex = 0
        else
            self.labelControl.selectedIndex = self.currentListStatus
        end
    end
end

function MainBottomUI:RefreshFishUnlock()
    -- todo 根据具体位置显示
    local index = PlayerData.Datas.SeaData:GetFishOpenCount(self.ID)
    if index <= self.listProgress.numChildren then
        local btn = self.listProgress:GetChildAt(index -1)
        local effect = btn:GetTransition("Effect")
        if effect then
            effect:Play(function()
                btn:GetController("State_C").selectedIndex = 1
            end)
        end
        UIManager.ShowEffect(ClickEffectType.Bar,btn:LocalToRoot(btn.size / 2), UISortOrder.ClickEffect,Vector3(-0.5,0,0),1.3)
    end
end

local function FishListCanDoSomething()
    return PlayerData.Datas.FishData:CanDoSomething()
end

local function AquariumCanDoSomething()
    return PlayerData.Datas.AquariumData:CanDoSomething()
end

-- 进修红点
local function StudyCanDoSomething()
    return PlayerData.Datas.AdminData:Red()
end

-- 主线任务红点
local function MainTaskRed()
    return PlayerData.Datas.TaskData:MainTaskRed()
end

-- 成就红点
local function AchieveRed()
    return PlayerDatas.AchievementData:Red()
end

function MainBottomUI:OnOpen()
    panel = self
    self.tabs = {}
    self.EffectWrap = {}
    -- 分辨率适配
    local safeArea = UIUtils.ScreenSafeArea()
    self.UI:SetSize(safeArea.width / UIContentScaler.scaleFactor,  self.UI.height)
    self.UI:SetXY(safeArea.x, self.UI.parent.height - self.UI.height)
    self.UI:AddRelation(self.UI.parent, RelationType.Width)
    self.UI:AddRelation(self.UI.parent, RelationType.Bottom_Bottom)
    
    self.tabList = self.UI:GetChild("List_Tab")
    UIConfig.BottomListHeight=self.tabList.height
    self.tabBtns = self.tabList:GetChildren()
    for index = 0, self.tabList.numChildren - 1 do
        self.tabBtns[index].text = Localize("Maintab"..index)
    end
    self.FishRedDot = ReddotManger:CreateRedDot(RedDotType.Fish,{AlignType.Center, VertAlignType.Top},self.tabBtns[2], 74)
    self.FishRedDot:SetConditions(FishListCanDoSomething)
    self.FishRedDot:SetEventListener(Event.CURRENCY_CHANGED,Event.FISH_GROWUP,Event.FISH_LEVELUP,Event.AQUARIUM_LEVELUP_DECORATION,Event.LOADING_COMPLETE)

    self.AquariumRedDot = ReddotManger:CreateRedDot(RedDotType.Aquarium,{AlignType.Center, VertAlignType.Top},self.tabBtns[0], 74)
    self.AquariumRedDot:SetConditions(AquariumCanDoSomething)
    self.AquariumRedDot:SetEventListener(Event.CURRENCY_CHANGED,Event.AQUARIUM_SHOW_ITEM)

    self.StudyRedDot = ReddotManger:CreateRedDot(RedDotType.Study,{AlignType.Center, VertAlignType.Top},self.tabBtns[1], 74)
    self.StudyRedDot:SetConditions(StudyCanDoSomething)
    self.StudyRedDot:SetEventListener(Event.CURRENCY_CHANGED,Event.ADMIN_TRAIN_SUCCESS,Event.OPEN_FUNC)

    self.TaskRedDot = ReddotManger:CreateRedDot(RedDotType.Task,{AlignType.Center, VertAlignType.Top},self.tabBtns[4], 74)
    self.TaskRedDot:SetConditions(AchieveRed)
    self.TaskRedDot:SetEventListener(Event.GET_ACHIEVE_TITLE_PRIZE,Event.GET_ACHIEVE_PRIZE,Event.OPEN_FUNC)

    self.tabControl= self.UI:GetController("Tab_C")
    self.listControl= self.UI:GetController("State_C")
    self.List = self.UI:GetChild("List"):GetChild("List")
    self.labelControl = self.UI:GetController("Label_C")
    local componentTitle = self.UI:GetChild("Component_Title")
    self.listTitle = componentTitle:GetChild("title") -- 列表标题
    self.listProgress = componentTitle:GetChild("List") -- 完成进度
    self.buttonMul = componentTitle:GetChild("Button_Count") -- 投入倍率
    self.titleControl = componentTitle:GetController("State_C")

    self.taskBar = self.UI:GetChild("mainTaskCom")
    self.toMainTaskBtn = self.taskBar:GetChild("Button_Received")
    self.UI:GetChild("n66"):GetChild("n8").text = Localize("Task")
    self.UI:GetChild("n60"):GetChild("n8").text = Localize("Task")

    self.tabList.foldInvisibleItems = true
    -- 临时隐藏游艇页签
    self.tabList:GetChildAt(3).visible = false
    self.parentPanel:AddTab(UIInfo.AquariumShowList, self.List)

    self.List:SetVirtual()

    local bottomHeightFold = self.tabList.height + componentTitle.height
    local bottomHeightUnfold = self.List.height + bottomHeightFold
    -- 展开和收起列表的场景可视高度(以像素为单位)
    UIUtils.ViewHeightFold = Screen.height - bottomHeightFold * UIContentScaler.scaleFactor
    UIUtils.ViewHeightUnfold = Screen.height - bottomHeightUnfold * UIContentScaler.scaleFactor

    -- 默认页面
    self:ShowTab(ConstantValue.DefaultPage or 2)

    self.buttonMul.onClick:Add(function()
        PlayerData:SwitchBatchCount()
    end)
    self.tabList.onClickItem:Set(function()
        self:ShowTab(self.tabList.selectedIndex)
    end)

    PlayerData:FoldBottemList(self.listControl.selectedIndex ~= 0)
    self.listControl.onChanged:Add(function()
        PlayerData:FoldBottemList(self.listControl.selectedIndex ~= 0)
        AudioManager.PlayEAXSound(103)
    end)

    -- 引导
    CommonUIObjectManager:Add(UIKey.MaintaskBtn,self.taskBar)
    CommonUIObjectManager:Add(UIKey.MultiSpeedBtn,self.buttonMul)
    CommonUIObjectManager:Add(UIKey.AquariumTabBtn,self.tabList:GetChildAt(0))
    CommonUIObjectManager:Add(UIKey.ImproveTabBtn,self.tabList:GetChildAt(1))
    CommonUIObjectManager:Add(UIKey.AchievementTabBtn,self.tabList:GetChildAt(4))
    self:CheckTabGuide()
    -- self:CheckListGuide()
    -- 降序防止引导手指被遮住
    self.List.childrenRenderOrder = CS.FairyGUI.ChildrenRenderOrder.Descent
    
    self:UpdateMainTask()
    EventDispatcher:Add(Event.BATCH_COUNT_CHANGE, self.UpdateBatchCount, self)
    EventDispatcher:Add(Event.CURRENCY_CHANGED, self.OnMoneyChange, self)
    EventDispatcher:Add(Event.FISH_GROWUP, self.UpdateAllList, self)
    EventDispatcher:Add(Event.FISH_LEVELUP, self.UpdateAllList, self)
    EventDispatcher:Add(Event.ADD_BUFFER, self.NewBuff, self)
    EventDispatcher:Add(Event.OPENED_TAB, self.HandleUIOpen, self)
    EventDispatcher:Add(Event.CLOSED_TAB, self.HandleUIClose, self)
    EventDispatcher:Add(Event.ADD_FISH_EFFECT, self.RefreshFishUnlock, self)
    EventDispatcher:Add(Event.LOADING_COMPLETE, self.OnLevelLoadComplete, self)
    EventDispatcher:Add(Event.ACHIEVE_TAB_OPEN, self.ChangeTabToLibrary, self)
    EventDispatcher:Add(Event.GET_MAIN_TASK_PRIZE, self.OnGetMainTaskPrize, self)
end

function MainBottomUI:UpdateAllList()
    if self.tabControl.selectedIndex == 0 then
        AquariumShowList.UpdateList(PlayerData.Datas.AquariumData:GetCurAquarium())
    elseif self.tabControl.selectedIndex == 2 then
        FishList.UpdateList(self.List, PlayerData.Datas.SeaData)
    end
end

-- 主线任务
function MainBottomUI:UpdateMainTask()
    local taskData = PlayerDatas.TaskData
    local curTask = taskData:GetCurMainTask()
    if curTask then
        self.taskBar.visible = true
        CommonUIUtils.SetCurrencyLabel(self.taskBar:GetChild("moneyLabel"), curTask.Reward, curTask.RewardType)
        local finish, progress, total = taskData:GetTaskInfo(curTask.TaskId)
        if finish then
            taskData:ReportMainTaskComplete(curTask)
        end
        self.taskBar:GetChild("title").text = curTask.Name
        self.taskBar.onClick:Set(function ()
            EventDispatcher:Dispatch(Event.CG_CLICK_BTN, UIKey.MaintaskBtn)
            if finish then
                taskData:GetMainTaskPrize(curTask.ID)
                UIUtils.MoneyEffect(curTask.RewardType, self.taskBar)
            else
                UIManager.OpenPopupUI(UIInfo.MainTaskUI, curTask)
            end
        end)

        local effectSlot = self.taskBar:GetChild("EffectGraph")
        effectSlot.visible = finish
        if finish then
            self.toMainTaskBtn:GetChild("Text_Received").text = Localize("GetReward2")
            --没有进度条了
            if nil == self.EffectWrap[effectSlot] then
                local function effectCallback(wrap)
                    self.EffectWrap[effectSlot] = wrap
                end  
                CommonUIUtils.CreateUIModelFromPool(
                    GameObjectManager.UIEffPoolName ,
                    "Prefabs/Particle/waibao/UI/Eff_UI_jiesuokuosan.prefab",
                    effectSlot, effectCallback,nil, Vector3(1.8,1.5, 1)
                
                )
            end
        else
            self.toMainTaskBtn:GetChild("Text_Received").text = Localize("Look")
        end
    else
        self.taskBar.visible = false
    end
end

function MainBottomUI:OnGetMainTaskPrize(info)
    if info then
        PlayerData:RewardMoney(info.RewardType, info.Reward)
    end
    self:UpdateMainTask()
end

function MainBottomUI:ShowTab(index)
    if (self.tabIndex == index) then return end

    self:HideOtherTab(index)
    MainBottomUI[tabFunction[index]](self)
    
    -- 强制引导事件
    if index == 0 then
        EventDispatcher:Dispatch(Event.CG_CLICK_BTN, UIKey.AquariumTabBtn)
    elseif index == 1 then
        EventDispatcher:Dispatch(Event.CG_CLICK_BTN, UIKey.ImproveTabBtn)
    elseif index == 4 then
        EventDispatcher:Dispatch(Event.CG_CLICK_BTN, UIKey.AchievementTabBtn)
    end
end

function MainBottomUI:OpenBottomTab(index, tabInfo, ...)
    local tab = UIManager.OpenTab(UIInfo.MainUI, tabInfo, ...)
    self.tabs[index] = tab
end

function MainBottomUI:HideOtherTab(index)
    local mainUI = UIManager.GetUI(UIInfo.MainUI.UIComName)
    for idx, tab in pairs(self.tabs) do
        if idx ~= index then
            mainUI:HideTab(tab.PanelInfo)
        end
    end
    if mainUI.curTab then
        -- FIX：在海域切换界面切到观赏馆界面时，海域切换界面不关闭
        mainUI:HideTab(mainUI.curTab.PanelInfo)
    end
end

function MainBottomUI:OnMoneyChange(num)
    self:UpdateAllList()
    self:CheckTabGuide()
    self:UpdateMainTask()
end

-- 新手引导
function MainBottomUI:CheckTabGuide()
    local function checkTab(funcID)
        if not PlayerDatas.FunctionOpenData:IsFunctionOpened(funcID)
        and PlayerDatas.FunctionOpenData:ReadyUnlockById(funcID)
        then
            return true
        end
        return false
    end
    local function playTabGuide(tab, ok)
        local tabEffectSlot = tab:GetChild("EffectGraph")
        tabEffectSlot.visible = ok and not tab.selected
        if ok and nil == self.EffectWrap[tabEffectSlot] then
            local function effectCallback(wrap)
                self.EffectWrap[tabEffectSlot] = wrap
                wrap.y = wrap.y-14
            end
            CommonUIUtils.CreateUIModelFromPool(
                GameObjectManager.UIEffPoolName ,
                "Prefabs/Particle/waibao/UI/Eff_UI_6biankuosankuang.prefab",
                tabEffectSlot, effectCallback
            )
        end
    end

    local tab = self.tabList:GetChildAt(0)
    playTabGuide(tab, checkTab(GameSystemType.FID_AQUARIUM))
    tab = self.tabList:GetChildAt(1)
    playTabGuide(tab, checkTab(GameSystemType.FID_IMPROVE))
end

function MainBottomUI:CheckListGuide()
    if self.listControl.selectedIndex ~= 0 or self.List.numItems == 0 then
        return
    end

    local item = self.List:GetChildAt(0)
    if not self.List:IsChildInView(item) then return end

    local btn = item:GetChild("Button_Buy")
    local fishOpenCount = PlayerDatas.SeaData:GetFishOpenCount(PlayerDatas.SeaData.currentSea)
    local needShow = false
    if fishOpenCount > 0 then
        -- 首个已解锁未达4级
        local bar = item:GetChild("Bar")
        if bar.value < 4 then
            print("第一项等级：",bar.value)
            needShow = true
        end
    else
        -- 未解锁
        print("未解锁")
        needShow = true
    end
    if needShow then
        WeakGuideManager:Show(btn, nil, self.UI)
    end
end

-- 显示解锁界面
function MainBottomUI:TryOpenFunc(func, callback, failCallback)
    if PlayerDatas.FunctionOpenData:IsFunctionOpened(func) then
        callback()
        EventDispatcher:Dispatch(Event.OPEN_FUNC, func, true)
        EventDispatcher:Dispatch(Event.SHOW_INCOME, self.tabIndex,true)
        return true
    else
        self.labelControl.selectedIndex = 0
        self:OpenBottomTab(self.tabIndex, UIInfo.FuncLockUI, func, callback)
        if failCallback then
            failCallback()
        end
        if UIManager.loadingPanel then
            UIManager.CloseUI(UIInfo.LoadingUI)
        end
        EventDispatcher:Dispatch(Event.OPEN_FUNC, func, false)
        EventDispatcher:Dispatch(Event.SHOW_INCOME, self.tabIndex, false)
    end
end

-- 观赏馆界面
function MainBottomUI:ShowAquariumTab()
    WeakGuideManager:Hide()
    self.tabIndex = 0

    self:TryOpenFunc(GameSystemType.FID_AQUARIUM, function()
        self.tabControl.selectedIndex = 0
        self.labelControl.selectedIndex = 1

        local data,config = PlayerData.Datas.AquariumData:GetCurAquarium()

        if config then
            self:OpenBottomTab(0, UIInfo.AquariumShowList, self.List, data, config)

            self.listTitle.text = config.Name
            self.titleControl.selectedIndex = 0
            self:UpdateBatchCount(PlayerData.batchCount)
            
            LevelManager.loadLevel(LevelType.Aquarium, {config=config, sceneName=config.Scene, loadingPanel=UIManager.GetUI(UIInfo.LoadingUI.UIComName)})
        else
            UIManager.OpenUI(UIInfo.AquariumSelectUI)
        end

        self:CheckTabGuide()
    end,
    function()
        LevelManager.loadLevel(LevelType.Start)
    end)
end

-- 管理界面
function MainBottomUI:ShowManageTab()
    self.tabIndex = 1
    self:TryOpenFunc(GameSystemType.FID_IMPROVE, function()
        self.labelControl.selectedIndex = 0
        self:OpenBottomTab(1, UIInfo.ImproveUI)
        LevelManager.loadLevel(LevelType.Start)
        self:CheckTabGuide()
    end,
    function()
        LevelManager.loadLevel(LevelType.Start)
    end)
end

-- 钓鱼界面
function MainBottomUI:ShowFishingTab()
    self.tabIndex = 2
    self:TryOpenFunc(GameSystemType.FID_FISHING, function()
        self.tabControl.selectedIndex = 2
        self.labelControl.selectedIndex = 1
        EventDispatcher:Dispatch(Event.MAIN_TAB_OPEN, self.tabIndex, true)

        self.List.visible = true
        self.List.touchable = true
        FishList.UpdateList(self.List, PlayerData.Datas.SeaData)
        local data,config = PlayerData.Datas.SeaData:GetCurSea()
        self.listTitle.text = config.Name
        self.titleControl.selectedIndex = 1
        self.ID = data.ID
        self.openNum = PlayerData.Datas.SeaData:GetFishOpenCount(data.ID)
        local function itemRender(index, obj)
            obj:GetController("State_C").selectedIndex = (index + 1) <= self.openNum and 1 or 0
        end
        self.listProgress.itemRenderer = itemRender
        self.listProgress.numItems = #config.Products

        self:UpdateBatchCount(PlayerData.batchCount)
        LevelManager.loadLevel(LevelType.Fishing, {seaId = data.ID, loadingPanel=UIManager.GetUI(UIInfo.LoadingUI.UIComName)})
    end)
end

function MainBottomUI:OnLevelLoadComplete()
    if self.tabIndex == 0 then
        local data,config = PlayerData.Datas.AquariumData:GetCurAquarium()
        self.listTitle.text = config.Name
        AquariumShowList.UpdateList(data)
    elseif self.tabIndex == 2 then
        local data,config = PlayerData.Datas.SeaData:GetCurSea()
        self.listTitle.text = config.Name
        local openNum = PlayerData.Datas.SeaData:GetFishOpenCount(data.ID)
        local function itemRender(index, obj)
            obj:GetController("State_C").selectedIndex = (index + 1) <= openNum and 1 or 0
        end
        self.listProgress.itemRenderer = itemRender
        self.listProgress.numItems = #config.Products
    end
end

-- 游艇界面
function MainBottomUI:ShowBoatTab()
    self.tabIndex = 3
    self:TryOpenFunc(GameSystemType.FID_BOATS, function()
        EventDispatcher:Dispatch(Event.MAIN_TAB_OPEN, self.tabIndex, true)
        UIManager.ShowMsg(Localize("Developping"),TipMsgType.WAIT)
        LevelManager.loadLevel(LevelType.Start)
        -- self.tabControl.selectedIndex = 3
        -- self.labelControl.selectedIndex = 0
    end,
    function()
        LevelManager.loadLevel(LevelType.Start)
    end)
end

-- 成就、图鉴界面
function MainBottomUI:ShowLibraryTab()
    self.tabIndex = 4
    self:TryOpenFunc(GameSystemType.FID_LIBRARY, function()
        self.labelControl.selectedIndex = 0
        EventDispatcher:Dispatch(Event.MAIN_TAB_OPEN, self.tabIndex, true)
        self:OpenBottomTab(self.tabIndex, UIInfo.AchievementUI)
        LevelManager.loadLevel(LevelType.Start)
    end,
    function()
        LevelManager.loadLevel(LevelType.Start)
    end)
end

function MainBottomUI:UpdateBatchCount(batchCount)
    self.buttonMul.text = string.format("X%d", batchCount)
    self:UpdateAllList()
end


function MainBottomUI:ChangeTabToLibrary()
    self.tabControl.selectedIndex = 4
    self:ShowLibraryTab()
end

function MainBottomUI:Close()
    self.tabs = nil
    self.List.onClickItem:Clear()
    self.buttonMul.onClick:Clear()
    self.FishRedDot:Destroy()
    self.FishRedDot = nil
    self.AquariumRedDot:Destroy()
    self.AquariumRedDot = nil
    self.StudyRedDot:Destroy()
    self.StudyRedDot = nil
    self.TaskRedDot:Destroy()
    self.TaskRedDot = nil
    for k, v in pairs(self.EffectWrap) do
        CommonUIUtils.ReturnUIModelToPool(v,GameObjectManager.UIEffPoolName)
    end
    self.EffectWrap = nil
    
    EventDispatcher:Remove(Event.BATCH_COUNT_CHANGE, self.UpdateBatchCount, self)
    EventDispatcher:Remove(Event.CURRENCY_CHANGED, self.OnMoneyChange, self)
    EventDispatcher:Remove(Event.FISH_GROWUP, self.UpdateAllList, self)
    EventDispatcher:Remove(Event.FISH_LEVELUP, self.UpdateAllList, self)
    EventDispatcher:Remove(Event.ADD_BUFFER, self.NewBuff, self)
    EventDispatcher:Remove(Event.OPENED_TAB, self.HandleUIOpen, self)
    EventDispatcher:Remove(Event.CLOSED_TAB, self.HandleUIClose, self)
    EventDispatcher:Remove(Event.ADD_FISH_EFFECT, self.RefreshFishUnlock, self)
    EventDispatcher:Remove(Event.LOADING_COMPLETE, self.OnLevelLoadComplete, self)
    EventDispatcher:Remove(Event.ACHIEVE_TAB_OPEN, self.ChangeTabToLibrary, self)
    EventDispatcher:Remove(Event.GET_MAIN_TASK_PRIZE, self.OnGetMainTaskPrize, self)
end

return MainBottomUI