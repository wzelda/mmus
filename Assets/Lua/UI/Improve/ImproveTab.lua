local ImproveTab = UIManager.PanelFactory(UIInfo.ImproveUI)

local panel = ImproveTab
local trainingList = nil
local effIdx
local locklist = false
local cdBreakItem

function ImproveTab:OnOpen(arg)
    panel = self

    self.list = self.UI:GetChild("List")
    self.list:SetVirtual()
    self.breakNum = self.UI:GetChild("titleLab")
    -- self.allTrainBtn = self.UI:GetChild("allTrainBtn")
    -- self.allTrainBtn.text = Localize("OneKeyTrain")
    UIUtils.SetUIFitScreen(self.UI, true)
    local safeArea = UIUtils.ScreenSafeArea()
    self.list:SetSize(Screen.width/UIContentScaler.scaleFactor,safeArea.yMax/UIContentScaler.scaleFactor-self.list.y-UIConfig.BottomListHeight)
end

local function updateBreakNum()
    panel.breakNum.text = LocalizeExt('ImproveBreakNum', {PlayerDatas.AdminData:GetBreakNum()})
end

-- 计算增加收益
local function calcAddIncome(trainId)
    local trainCfg = ConfigData:GetAdminTrain(trainId)
    local buffcfg = ConfigData:GetBufferById(trainCfg and trainCfg.Buffer)
    if nil == buffcfg then return 0 end

    local allfactor = buffcfg.Factor
    local itemcfg
    local addincome = 0
    if buffcfg.ItemType == 0 then
        itemcfg = PlayerDatas.FishData:GetFish(buffcfg.ItemID)
        if itemcfg then
            addincome = PlayerDatas.FishData:GetIncomeBase(itemcfg) * allfactor
        end
    elseif buffcfg.ItemType == 1 then
        itemcfg = ConfigData:GetAquarShowItem(buffcfg.ItemID)
        if itemcfg then
            addincome = PlayerDatas.AquariumData:GetIncomeBase(itemcfg) * allfactor
        end
    end

    return addincome
end

function ImproveTab:OnShow(...)
    self:RenewTrainList()
    updateBreakNum()
end

local function listItemRenderer(index, fobj)
    local techCfg = trainingList[index + 1]
    local techInfo = PlayerDatas.AdminData.techInfoList[techCfg.ID]
    local cfg = PlayerDatas.AdminData:GetCurTrain(techCfg.ID)
    if nil == cfg then return end

    local obj = fobj:GetChild('itemLabel')
    obj.xy = Vector2.zero
    obj.text = cfg.Name
    UIUtils.LoadIcon(obj, techCfg.Icon, true, UIInfo.ImproveUI.UIName)
    local clickAction = 'doTrain'
    local trainBtn = obj:GetChild("trainBtn")
    local btnStat = trainBtn:GetController("State_C")
    local btnType_C = trainBtn:GetController("type_C")
    local freeTitle = trainBtn:GetChild("freeTitle")
    trainBtn:GetChild("costLabel").text = Utils.ResourceHandler(cfg.Cost)
    if cfg.Ad == 1 then
        -- 广告+突破
        local cdText = trainBtn:GetChild("cdText")
        trainBtn.touchable = true
        UIUtils.SetControllerIndex(btnStat, 2)
        UIUtils.SetControllerIndex(btnType_C, 0)
        if techInfo.Ready then
            UIUtils.SetControllerIndex(btnType_C, 2)
            freeTitle.text = Localize("DoBreak")
        elseif techInfo.Cd > 0 then
            clickAction = 'clearCd'
            UIUtils.SetControllerIndex(btnType_C, 1)
            freeTitle.text = Localize("AdBreak")
            cdBreakItem = cdText
            if panel.breakTimer == nil then
                panel.breakTimer = TimerManager.newTimer(0, false, true, nil,
                    function (t, f)
                        if cdBreakItem then
                            cdBreakItem.text = Utils.secondConversion(f, true)
                        end
                    end, 
                    function ()
                        clickAction = 'doTrain'
                        freeTitle.text = Localize("DoBreak")
                        UIUtils.SetControllerIndex(btnStat, 2)
                        UIUtils.SetControllerIndex(btnType_C, 0)
                    end
                )
            end
            panel.breakTimer:start(techInfo.Cd)
        elseif PlayerDatas.AdminData:IsBreakCd() then
            -- 其他突破中
            clickAction = nil
            trainBtn.touchable = false
            UIUtils.SetControllerIndex(btnStat, 3)
            trainBtn:GetChild('otherBreak').text = Localize("OtherBreaking")
        else
            if techCfg.BreakCd ~= 0 then
                clickAction = 'tickTrain'
            end
            freeTitle.text = Localize("Break")
            local cdtxt = techCfg.BreakCd ~= 0 and Utils.secondConversion(techCfg.BreakCd, true) or '00:00'
            cdText.text = string.format(Localize('BreakAfter'), cdtxt)
        end
    else
        UIUtils.SetControllerIndex(btnStat, 0)
        trainBtn.text = Localize("DoTrain")
        trainBtn.touchable = PlayerData:ResEnough(cfg.CostType, cfg.Cost)
        if not trainBtn.touchable then
            UIUtils.SetControllerIndex(btnStat, 1)
        end
    end

    local trainCount = #techCfg.Trains
    local curProgress = techInfo and techInfo.Index or 0
    local progressList = obj:GetChild("List")
    progressList.numItems = trainCount
    for index = 0, trainCount - 1 do
        local pitem = progressList:GetChildAt(index)
        UIUtils.SetControllerIndex(pitem:GetController('State_C'), index < curProgress and 1 or 0)
    end

    if cfg.Ad == 1 then
        AnalyticsManager.onADButtonShow("激励视频", "免费进修_"..cfg.Name, "免费进修")
    end
    trainBtn.onClick:Set(function ()
        local function doTrain()
            PlayerDatas.AdminData:Train(techCfg.ID)
            if cfg.Ad == 1 then
                locklist = true
                effIdx = index
                local uiinfo = {}
                uiinfo.trainCfg = cfg
                uiinfo.techCfg = techCfg
                UIManager.OpenUI(UIInfo.ImproveBreakUI, nil, nil, uiinfo)
            else
                panel:FlyEffect(trainBtn)
            end
        end
        if clickAction == 'clearCd' then
            local popinfo = {}
            popinfo.title = Localize("AdBreakTips")
            -- popinfo.cancelStr = string.format(Localize("GetReward3"), CommonUIUtils.ResRichtext(cfg.RewardType, cfg.Reward))
            popinfo.okInfo = {index = 1}
            popinfo.sureCallback = function ()
                PlayerDatas.AdminData:ClearBreakCd(doTrain)
            end
            -- popinfo.moneyEffect = {cfg.RewardType, cfg.RewardType}
            UIManager.OpenPopupUI(UIInfo.PopupUI, popinfo)
        elseif clickAction == 'tickTrain' then
            PlayerDatas.AdminData:TickTechBreak(techCfg.ID)
        else
            doTrain()
        end
    end)
end

function ImproveTab:OnBreakOver(btn, rot, trainId)
    updateBreakNum()
    self:FlyEffect(btn, rot)
    self:IncomeTips(trainId)

    if effIdx then
        local childIdx = self.list:ItemIndexToChildIndex(effIdx)
        effIdx = nil
        if childIdx >= self.list.numChildren then return end
        
        local fobj = self.list:GetChildAt(childIdx)
        fobj:GetTransition('Effect_T1'):Play(function ()
            locklist = false
            self:RenewTrainList()
            if childIdx < self.list.numChildren then
                fobj = self.list:GetChildAt(childIdx)
                fobj:GetTransition('Effect_T2'):Play()
            end
        end)
    end
end

function ImproveTab:OnTrained(id, trainId)
    if PlayerDatas.AdminData:TechFinished(id) then return end
    self:RenewTrainList()
    if not locklist then
        self:IncomeTips(trainId)
    end
end

function ImproveTab:IncomeTips(trainId)
    EventDispatcher:Dispatch(Event.ADMIN_ADD_INCOME, calcAddIncome(trainId))
end

-- 绑定事件
function ImproveTab:OnRegister()
    self.list.itemRenderer = listItemRenderer
    -- self.allTrainBtn.onClick:Set(function ()
    --     for _, v in pairs(trainingList) do
    --         PlayerDatas.AdminData:Train(v.ID)
    --     end
    -- end)

    EventDispatcher:Add(Event.ADMIN_TRAIN_SUCCESS, self.OnTrained, self)
    EventDispatcher:Add(Event.CURRENCY_CHANGED, self.RenewTrainList, self)
    EventDispatcher:Add(Event.ADMIN_CLOSE_BREAKUI, self.OnBreakOver, self)
    EventDispatcher:Add(Event.ADMIN_TECHBREAK_READY, self.RenewTrainList, self)
end

-- 解绑事件
function ImproveTab:OnUnRegister()
    self.list.itemRenderer = nil
    -- self.allTrainBtn.onClick:Clear()
    EventDispatcher:Remove(Event.ADMIN_TRAIN_SUCCESS, self.OnTrained, self)
    EventDispatcher:Remove(Event.CURRENCY_CHANGED, self.RenewTrainList, self)
    EventDispatcher:Remove(Event.ADMIN_CLOSE_BREAKUI, self.OnBreakOver, self)
    EventDispatcher:Remove(Event.ADMIN_TECHBREAK_READY, self.RenewTrainList, self)
end

function ImproveTab:OnClose()
    trainingList = nil
    if self.breakTimer then
        TimerManager.disposeTimer(self.breakTimer)
        self.breakTimer = nil
    end
end

function ImproveTab:OnHide()
    EventDispatcher:Dispatch(Event.CLOSED_TAB, UIInfo.ImproveUI.UIComName)
end

function ImproveTab:RenewTrainList()
    if locklist then return end

    local adminData = PlayerDatas.AdminData
    trainingList = {}
    for i, v in ipairs(ConfigData.adminConfig.Technology) do
        if not adminData:TechFinished(v.ID) and adminData:TechUnlocked(v.ID) then
            table.insert(trainingList, v)
            PlayerDatas.AdminData:UpdateTech(v.ID)
        end
    end
    self.list.numItems = #trainingList
end

-- 飞行特效
function ImproveTab:FlyEffect(btn, rot)
    local offset = Vector2(-1,6)
    local m_startpos
    if btn then
        m_startpos = btn:LocalToRoot(0.5*btn.size)
    else
        m_startpos = UIUtils.ScreenResolution * 0.5
    end
    local mainui = UIManager.GetUI(UIInfo.MainUI.UIComName).MainTopUI
    local target = mainui and mainui.Text_Desc
    local m_targetpos = target and target:LocalToRoot(0.5*target.size) or m_startpos
    local angle = UIUtils.calcAngle(m_targetpos - m_startpos, Vector2.down)
    local scale = 2
    local xOffset = nil == rot and 0.5 * scale or -0.5 * scale
    local yOffset = -5 * scale
    local extraInfo = {}
    extraInfo.startpos = m_startpos
    extraInfo.targetpos = m_targetpos
    extraInfo.rotation = rot and rot or Vector3(0,180,0)
    extraInfo.evt = Event.ADMIN_EFF_END

    -- m_startpos = m_startpos + (m_targetpos -m_startpos).normalized*200
    UIManager.ShowEffect(
        ClickEffectType.RewardTail,m_startpos,UISortOrder.ClickEffect,
        Vector3(xOffset,yOffset,0),scale,extraInfo
    )
end

return ImproveTab