local RankingListPanel = UIManager.PanelFactory(UIInfo.RankingListUI)

local panel = nil

RankingListPanel.HidePrePanel = true
RankingListPanel.curRankType = nil
RankingListPanel.curState = nil
RankingListPanel.curUserList = nil

local function OnClosePanel()
    UIManager.CloseUI(UIInfo.RankingListUI)
end

local function StrLockInfo(funcType)
    local target = ConfigData:GetFuncOpenLevel(PlayerData.Datas.UserData.actorData.id, funcType)
    if target == nil then
        target = 999
    end
    local result = string.format('%d级解锁', target)
    return result
end

local function TabListOnChanged()
    local title, text = "", ""
    if panel.tab_C.selectedIndex == 0 then
        panel.curRankType = RankType.RANK_DUNGEON
        title = LocalizeExt("关卡排行榜")
        text = LocalizeExt("关卡进度")
    elseif panel.tab_C.selectedIndex == 1 then
        panel.curRankType = RankType.RANK_ARENA
        title = LocalizeExt("竞技场排行榜")
        text = LocalizeExt("积分")
    elseif panel.tab_C.selectedIndex == 2 then
        panel.curRankType = RankType.RANK_TOWER
        title = LocalizeExt("大秘境排行榜")
        text = LocalizeExt("层数")
    end

    panel.main.title = title
    panel.levelText.text = text

    PlayerData.Datas.RankingListData:NewC2SRankListMsg(panel.curRankType)
end

-- 打开玩家信息界面
function RankingListPanel:OnOpenPlayerInfoUI(data)
    UIManager.OpenUI(UIInfo.PlayerInfomationUI, nil, nil, data)
end

-- 更新排行榜列表
function RankingListPanel:UpdateRankingList(list)
    if list.t == RankType.RANK_DUNGEON then -- 关卡
        self:UpdateLevelRankList(list.user)
    elseif list.t == RankType.RANK_ARENA then -- 竞技场
        self:UpdatePvpRankList(list.user)
    elseif list.t == RankType.RANK_TOWER then -- 爬塔
        self:UpdateTowerRankList(list.user)
    end
end

-- 填充玩家基础信息
function RankingListPanel:FillBasicInfo(index, item, info, state)
    local state_C = item:GetController("state_C")
    local head = item:GetChild("head")
    local name = item:GetChild("nameLabel")
    local guild = item:GetChild("guildNameLabel")
    local levelName = item:GetChild("levelName")
    local levelLabel = item:GetChild("levelLabel")
    local infoLabel = item:GetChild("infoLabel")
    local infoBg = item:GetChild("infoBg")

    item.title = index
    state_C.selectedIndex = state
    name.text = info.basic.name
    guild.text = LocalizationMgr.getServerLocStr("")
    CommonUIUtils.FillPlayerHeadCom(head, info.basic)

    infoBg.onClick:Set(function()
        PlayerData.Datas.UserData:NewC2SUserViewMsg(info.basic.id)
    end)

    -- 英雄列表
    local tabHeroItem = {}
    for i = 1, 3 do
        local com = item:GetChild("hero_" .. i)
        if com then
            com.visible = false
        end
        table.insert(tabHeroItem, com)
    end

    if info.heroes then
        for i, heroInfo in ipairs(info.heroes) do
            local item = tabHeroItem[i]
            item.visible = true
            local data = {
                data_id = heroInfo.data_id,
                star = heroInfo.star,
                level = heroInfo.level,
            }
            CommonUIUtils.SetHeroBigHead(item, data)
        end
    end
    
    if state == 0 then -- 关卡
        local dungeonData = ConfigData:GetDungeonDataById(info.max_passed_dungeon_id)
        if self.curRankType == RankType.RANK_DUNGEON and dungeonData then
            levelName.text = string.format("[color=#C450EE]第%s章[/color]%s",
                NumberTranslatorTool.ToChinese(dungeonData.chapter_lv),
                LocalizationMgr.getServerLocStr(dungeonData.chapter_name))
            levelLabel.text = LocalizationMgr.getServerLocStr(dungeonData.name)
        end
    else -- 其他(竞技场，爬塔)
        if self.curRankType == RankType.RANK_ARENA then
            infoLabel.text = info.jjc_score
        elseif self.curRankType == RankType.RANK_TOWER then
            infoLabel.text = info.max_passed_tower_id
        end
    end
end

-- 填充自己的信息
function RankingListPanel:FillSelfLabelInfo()
    local selfInfo = nil
    local selfIndex = nil
    for i, userInfo in ipairs(self.curUserList) do
        if userInfo.basic.id == PlayerData.id then
            selfInfo = userInfo
            selfIndex = i
        end
    end

    local rank_C = self.selfRankLabel:GetController("rank_C")
    -- 有排名
    if selfIndex then
        rank_C.selectedIndex = selfIndex < 5 and selfIndex - 1 or 3
    else
        rank_C.selectedIndex = 4
    end

    if nil == selfInfo then
        selfInfo = PlayerData.Datas.UserData.FullPlayerBasicData(TeamType.TT_DUNGEON)
    end
    self:FillBasicInfo(selfIndex, self.selfRankLabel, selfInfo, self.curState)
    if self.curRankType == RankType.RANK_ARENA then
        self.selfRankLabel:GetChild("infoLabel").text = PlayerData.Datas.PvpData.selfScore
    elseif self.curRankType == RankType.RANK_TOWER then
        self.selfRankLabel:GetChild("infoLabel").text = PlayerData.Datas.TowerData.maxDoneLayerId
    end
end

local function RankItemRenderer(index, obj)
    local pos = index + 1
    local info = panel.curUserList[pos]
    local self_C = obj:GetController("self_C")
    local rank_C = obj:GetController("rank_C")
    self_C.selectedIndex = 0
    rank_C.selectedIndex = pos < 4 and pos - 1 or 3
    if info.basic.id == PlayerData.id then
        self_C.selectedIndex = 1
    end

    panel:FillBasicInfo(pos, obj, info, panel.curState)
end

-- 更新关卡排行列表
function RankingListPanel:UpdateLevelRankList(userList)
    self.curUserList = userList
    self.curState = 0
    self.rankList.numItems = #self.curUserList
    self:FillSelfLabelInfo()
end

-- 更新竞技场排行列表
function RankingListPanel:UpdatePvpRankList(userList)
    self.curUserList = userList
    self.curState = 1
    self.rankList.numItems = #self.curUserList
    self:FillSelfLabelInfo()
end

-- 更新爬塔排行列表
function RankingListPanel:UpdateTowerRankList(userList)
    self.curUserList = userList
    self.curState = 1
    self.rankList.numItems = #self.curUserList
    self:FillSelfLabelInfo()
end

-- 子类初始化UI控件
function RankingListPanel:OnOpen(rankType)
    panel = self

    self.curRankType = rankType
    self.bg = self.UI:GetChild("bg")
    self.main = self.UI:GetChild("main")
    self.rankText = self.main:GetChild("rankText")
    self.nameText = self.main:GetChild("playerInfoText")
    self.heroText = self.main:GetChild("heroText")
    self.levelText = self.main:GetChild("levelText")
    self.tabList = self.main:GetChild("tabList")
    self.tab_C = self.main:GetController("tab_C")
    self.rankList = self.main:GetChild("rankList")
    self.rankList:SetVirtual()
    self.rankList.itemRenderer = RankItemRenderer
    self.selfRankLabel = self.main:GetChild("selfRankLabel")

    self.levelBtn = self.tabList:GetChild("levelBtn")
    self.pvpBtn = self.tabList:GetChild("pvpBtn")
    self.pvpBtnLoack_C = self.pvpBtn:GetController("Lock_Unlock")
    UIManager:RegistLockFunc(GameSystemType.FID_JJC,
        self.pvpBtn,
        SystemLockMode.ESPECIAL,
        false,
        function()
            self.pvpBtnLoack_C.selectedIndex = 1
            self.pvpBtn.touchable = false
            self.pvpBtn:GetChild("lockInfo").text = StrLockInfo(GameSystemType.FID_JJC)
        end,
        function()
            if nil == self.pvpBtnLoack_C then
                return
            end
            self.pvpBtnLoack_C.selectedIndex = 0
            self.pvpBtn.touchable = true
        end
        )
    self.towerBtn = self.tabList:GetChild("towerBtn")
    self.towerBtnLoack_C = self.towerBtn:GetController("Lock_Unlock")
    self.towerBtn.touchable = true
    UIManager:RegistLockFunc(GameSystemType.FID_TOWER,
        self.towerBtn,
        SystemLockMode.ESPECIAL,
        false,
        function()
            self.towerBtnLoack_C.selectedIndex = 1
            self.towerBtn.touchable = false
            self.towerBtn:GetChild("lockInfo").text = StrLockInfo(GameSystemType.FID_JJC)
        end,
        function()
            if nil == self.towerBtnLoack_C then
                return
            end
            self.towerBtnLoack_C.selectedIndex = 0
            self.towerBtn.touchable = true
        end
        )
    self.closeBtn = self.main:GetChild("close")
    self.bg.icon = "UIImage/Backpack/ui_Backpack_img_BG1"
end

function RankingListPanel:OnShow(rankType)
    if rankType then
        self.curRankType = rankType
    end
    self.tab_C.selectedIndex = self.curRankType - 1
    TabListOnChanged()
end

-- 刷新文本
function RankingListPanel:RefreshText()
    self.rankText.text = LocalizeExt("名次")
    self.nameText.text = LocalizeExt("玩家")
    self.heroText.text = LocalizeExt("战魂")
    self.levelBtn.title = LocalizeExt("关卡")
    self.pvpBtn.title = LocalizeExt("竞技场")
    self.towerBtn.title = LocalizeExt("大秘境")
    self.selfRankLabel:GetChild("text").text = LocalizeExt("未上榜")
end

-- 绑定各类事件
function RankingListPanel:OnRegister()
    self.bg.onClick:Add(OnClosePanel)
    self.closeBtn.onClick:Add(OnClosePanel)
    self.tab_C.onChanged:Add(TabListOnChanged)

    EventDispatcher:Add(Event.UPDATE_RANKING_LIST, self.UpdateRankingList, self)
    EventDispatcher:Add(Event.USER_VIEW, self.OnOpenPlayerInfoUI, self)
end

-- 强制刷新,比如网络事件监听，切换语言包，断线重连等
function RankingListPanel:OnRefresh(...)
    self:RefreshText()
end

-- 解绑各类事件
function RankingListPanel:OnUnRegister()
    self.bg.onClick:Clear()
    self.closeBtn.onClick:Clear()
    self.tab_C.onChanged:Clear()

    EventDispatcher:Remove(Event.UPDATE_RANKING_LIST, self.UpdateRankingList, self)
    EventDispatcher:Remove(Event.USER_VIEW, self.OnOpenPlayerInfoUI, self)
end

-- 关闭
function RankingListPanel:OnClose()
    panel = nil
    self.curRankType = nil
    self.curUserList = nil
    self.curState = nil
    self.rankList.numItems = 0
    self.rankList.itemRenderer = nil
end

return RankingListPanel
--endregion