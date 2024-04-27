local AchievementTab = UIManager.PanelFactory(UIInfo.AchievementUI)

local panel = AchievementTab
local achieveTaskList

function AchievementTab:OnOpen(arg)
    achieveTaskList = {}
    panel = self

    self.listCom = self.UI:GetChild("listCom")
    self.listCom.text = Localize("Achievement")
    self.list = self.listCom:GetChild("list")
    self.list:SetVirtual()
    self.progressBar = self.UI:GetChild("progressBar")
    self.boxBtn = self.UI:GetChild("boxBtn")
    self.btnTitleList = self.UI:GetChild("btnTitleList")
    self.totalProgressTip = self.UI:GetChild("totalProgressTip")
    self.totalProgressTip.text = Localize("TotalProgress").." "
    UIUtils.SetUIFitScreen(self.UI, true)
    local safeArea = UIUtils.ScreenSafeArea()
    self.list:SetSize(Screen.width/UIContentScaler.scaleFactor,safeArea.yMax/UIContentScaler.scaleFactor-self.list.y-UIConfig.BottomListHeight)
    local redot = ReddotManger:CreateRedDot(RedDotType.Normal,AnchorType.TopRight,self.boxBtn)
    redot:SetConditions(function ()
        return PlayerDatas.AchievementData:TitleAchieved()
    end)
    redot:SetEventListener(Event.GET_ACHIEVE_PRIZE,Event.GET_ACHIEVE_TITLE_PRIZE)
    self.boxRedot = redot
end

function AchievementTab.DoClose()
    UIManager.CloseUI(UIInfo.AchievementUI)
end

function AchievementTab:OnShow(...)
    self.list.itemRenderer = self.ItemRender
    self:RefreshTitleProgress()
    self:RefreshTitle()
    self:UpdateList()
end

-- 绑定事件
function AchievementTab:OnRegister()
    self.boxBtn.onClick:Set(function() self:OnClickBoxBtn() end)
    self.btnTitleList.onClick:Set(function() self:OnClickTitleBtn() end)

    EventDispatcher:Add(Event.GET_ACHIEVE_PRIZE, self.OnGetReward, self)
    EventDispatcher:Add(Event.GET_ACHIEVE_TITLE_PRIZE, self.OnGetReward, self)
    EventDispatcher:Add(Event.AD_ADDTIMES, self.UpdateList, self)
end

-- 解绑事件
function AchievementTab:OnUnRegister()
    self.list.itemRenderer = nil
    self.boxBtn.onClick:Clear()
    self.btnTitleList.onClick:Clear()
    EventDispatcher:Remove(Event.GET_ACHIEVE_PRIZE, self.OnGetReward, self)
    EventDispatcher:Remove(Event.GET_ACHIEVE_TITLE_PRIZE, self.OnGetReward, self)
    EventDispatcher:Remove(Event.AD_ADDTIMES, self.UpdateList, self)
end

function AchievementTab:OnClose()
    achieveTaskList = nil
    self.boxRedot:Destroy()
    self.boxRedot = nil
end

function AchievementTab:OnClickBoxBtn()
    UIManager.OpenPopupUI(UIInfo.ItemPopupUI, "AchieveTitlePrize")
end

function AchievementTab:OnClickTitleBtn()
    UIManager.OpenPopupUI(UIInfo.AchieveTitleUI)
end

function AchievementTab:OnGetReward(info)
    self:RefreshTitleProgress()
    self:RefreshTitle()
    self:UpdateList()
end

function AchievementTab.ItemRender(index, obj)
    local info = achieveTaskList[index + 1]
    local cfg = info.cfg

    obj.text = cfg.Name
    local taskProgress, taskTarget = PlayerDatas.TaskData:GetProgress(cfg.TaskId)
    local progressBar = obj:GetChild("progressBar")
    progressBar.max = 100
    progressBar.value = taskProgress / taskTarget * 100
    progressBar:GetChild("title").text = string.format("%s/%s", Utils.ResourceHandler(taskProgress), Utils.ResourceHandler(taskTarget))
    local getBtn = obj:GetChild("getBtn")
    getBtn.text = Localize("GetReward")
    local rewardLabel = getBtn:GetChild("rewardLabel")
    UIUtils.FillResBtn(rewardLabel, cfg.RewardType, cfg.Reward)
    local completed = PlayerDatas.AchievementData:IsComplete(cfg.ID)
    UIUtils.SetControllerIndex(getBtn:GetController("State_C"), completed and 0 or 1)
    getBtn.touchable = completed == true

    if completed then
        getBtn.onClick:Set(function ()
            local function playeff()
                UIUtils.MoneyEffect(cfg.RewardType, getBtn)
            end

            if cfg.Ad ~= 0 then
                AnalyticsManager.onADButtonShow("激励视频", "成就奖励_"..cfg.Name, "成就奖励")
                local multiple = 2
                local popinfo = {}
                popinfo.title = LocalizeExt("DoubleTitleRewardTips", {multiple})
                popinfo.cancelStr = string.format(Localize("GetReward3"), CommonUIUtils.ResRichtext(cfg.RewardType, cfg.Reward))
                popinfo.okInfo = {
                    multi = multiple,
                }
                popinfo.sureCallback = function ()
                    SDKManager:PlayAD(function ()
                        PlayerDatas.AchievementData:GetAchievePrize(cfg.ID, multiple)
                        EventDispatcher:Dispatch(Event.ITEMPOP_GETREWARD, CommonCostType.Diamond)
                    end,"成就奖励_"..cfg.Name, "成就奖励")
                end
                popinfo.cancelCallback = function ()
                    PlayerDatas.AchievementData:GetAchievePrize(cfg.ID)
                end
                popinfo.moneyEffect = {cfg.RewardType, cfg.RewardType}
                UIManager.OpenPopupUI(UIInfo.PopupUI, popinfo)
            else
                PlayerDatas.AchievementData:GetAchievePrize(cfg.ID)
                playeff()
            end
        end)
    end
end

function AchievementTab:RefreshTitleProgress()
    local nextCfg = PlayerDatas.AchievementData:NextTitle()
    if nextCfg then
        self.progressBar.max = nextCfg.Condition
        self.progressBar.value = PlayerDatas.AchievementData:AchieveNum()
    else
        -- 满级
        self.progressBar.max = 1
        self.progressBar.value = 1
    end
    self.progressBar:GetChild("title").text = string.format(
        "%s/%s",
        self.progressBar.value,
        self.progressBar.max
    )
end

function AchievementTab:RefreshTitle()
    local cfg = PlayerDatas.AchievementData:CurTitle()
    if nil == cfg then return end

    self.btnTitleList.text = string.format("[color=#fffef1,#E7FF77]%s", cfg.Name)
    UIUtils.LoadIcon(self.btnTitleList, cfg.Icon, true)
end

function AchievementTab:UpdateList()
    achieveTaskList = {}
    for i, v in ipairs(ConfigData.achievementConfig.AchievementTask) do
        if PlayerDatas.AchievementData:IsAchieveUnlock(v.ID)
        and not PlayerDatas.AchievementData:IsAchieveCollect(v.ID) then
            if PlayerDatas.AchievementData:IsComplete(v.ID) then
                table.insert(achieveTaskList, {cfg=v,complete=true})
                PlayerDatas.TaskData:ReportAchivementTaskComplete(v)
            else
                table.insert(achieveTaskList, {cfg=v,complete=false})
            end
        end
    end

    self.list.numItems = #achieveTaskList
end

return AchievementTab