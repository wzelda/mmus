local GuideConfig = require "Config.CompulsiveGuideConfig"
CGID = {
    CG1_FAKE_BATTLE = 1, -- 首场战斗
    CG10_FORMATION = 10, -- 引导上阵和获得英雄 build id:1001
    CG11_GET_HERO = 11, -- 猩猩游侠
    CG15_REC_HANGUP_AWARD_1 = 15, -- 第一次领取挂机奖励
    CG17_HERO_UPGRADE = 17, -- 英雄升级
    CG18_EQUIP = 18, -- 引导穿装备
    CG19_FIGHT_2 = 19, -- 第二场战斗 1002
    CG20_SUMMON_1 = 20, -- 第一次高抽
    CG21_SUMMON_2 = 21, -- 第二次高抽
    CG22_CHANGE_JOB = 22, -- 转职
    CG23_FORMATION = 23, -- 转职后进布阵
    CG25_FIGHT_BOSS = 25, -- 打沙龙boss
    CG26_DRAGON_AND_FOG = 26, -- 沙龙飞走
    CG27_COLLECT_TASK_PRIZE = 27, -- 第一次领取主线任务奖励
    CG28_SUMMON_3 = 28, -- 第三次高抽(第一次十连抽)
    CG29_GOGOGO = 29, -- 村长出来装逼说一句话
    CG30_BATTLE_SPEED_UP = 30, -- 引导战斗加速 1101
    CG31_FORMATION = 31, -- 引导上阵狮子游侠
    CG40_HERO_PROMOTE = 40, -- 解锁英雄圣像
    CG41_AFTER_HERO_PROMOTE = 41, -- 进阶后
    CG50_GUILD = 50, -- 解锁部落
    CG60_CHALLENGE = 60, -- 解锁试炼
    CG62_COLLECT_TASK_PRIZE = 62, -- 第二次领取主线任务奖励
    CG65_PVP = 65, -- 引导竞技场+改名
    CG70_BLACK_MARKET = 70, -- 黑市引导
    CG80_GUILD_ENTRUST = 80, -- 解锁悬赏
    CG90_LEADER_SPRING = 90, -- 解锁领袖之泉
    CG100_DESERT_EXPLORE = 100, -- 解锁沙漠探索
    CG110_ALL_RANKING = 110, -- 解锁纪念丰碑
    CG120_FIRST_LOSE = 120, -- 首次推图失败
    CG121_FIRST_LOSE = 121, -- 首次推图失败
    CG170_FIRE_DRAGON_NEST = 170, -- 引导火龙
    CG180_ICE_DRAGON_NEST = 180, -- 引导冰龙
    CG190_SAND_DRAGON_NEST = 190, -- 引导沙龙
    CG200_WIND_DRAGON_NEST = 200, -- 引导风龙
    CG240_DRAGON_BOSS = 240, -- 引导龙boss
    CG250_ZQDN = 250, -- 战术实验室
    CG270_BATTLE_SKIP = 270, -- 竞技场跳过战斗
    CG280_FAST_IDLE = 280, -- 快速挂机
    CG290_KFJJC = 290, -- 天梯
    CG300_CAMP_DUNGEON = 300, -- 阵营试炼
    CG_TALENT = 310 -- 天赋
}

-- 通过某关键点
-- guideType:GuideRecordType
local function IsPass(guideType)
    if PlayerData == nil then
        return true
    end

    return PlayerData.Datas.GuideData:IsPass(guideType)
end

-- 建筑是否尚未解锁
-- buildId:客户端建筑id
local function IsLock(buildId)
    if buildId == nil then
        return true
    end

    return not PlayerData.Datas.BuildData:IsBuildUnlock(buildId)
end

-- 背包里有狮子
local m_cg31HeroInfo = nil
local function CG31Condition()
    for _, heroInfo in pairs(PlayerData.Datas.HeroData.heroMap) do
        if heroInfo.configData.race == ServerSpeciesType.SHI_ZI then
            m_cg31HeroInfo = heroInfo
            return true
        end
    end

    return false
end

-- 理论上IsFinish和IsPass不用共存,用开启顺序保护
local function CanNotOpen()
    return {
        [CGID.CG10_FORMATION] = IsPass(GuideRecordType.GT_BUILD_CHALLENGE_1),
        [CGID.CG15_REC_HANGUP_AWARD_1] = IsPass(GuideRecordType.GT_COLLECT_GUA_PRIZE_1),
        [CGID.CG17_HERO_UPGRADE] = IsPass(GuideRecordType.GT_OWNER_HERO_LEVEL),
        [CGID.CG18_EQUIP] = IsPass(GuideRecordType.GT_ONE_KEY_WEAR_EQUIP),
        [CGID.CG19_FIGHT_2] = IsPass(GuideRecordType.GT_BUILD_CHALLENGE_2),
        [CGID.CG20_SUMMON_1] = IsPass(GuideRecordType.GT_ADVANCE_RANDOM_CARD_1) or
            IsLock(CompulsiveGuideManager.Config.TavernBuildServerId),
        [CGID.CG21_SUMMON_2] = IsPass(GuideRecordType.GT_ADVANCE_RANDOM_CARD_2) or
            IsLock(CompulsiveGuideManager.Config.TavernBuildServerId),
        [CGID.CG22_CHANGE_JOB] = IsPass(GuideRecordType.GT_FIRST_TRANS_RACE),
        [CGID.CG23_FORMATION] = false,
        [CGID.CG25_FIGHT_BOSS] = IsPass(GuideRecordType.GT_BUILD_CHALLENGE_4),
        [CGID.CG26_DRAGON_AND_FOG] = not CompulsiveGuideManager:IsFinish(CGID.CG25_FIGHT_BOSS),
        [CGID.CG27_COLLECT_TASK_PRIZE] = IsPass(GuideRecordType.GT_FIRST_COLLECT_ACHIEVE_TASK_PRIZE) or
            not CompulsiveGuideManager:IsFinish(CGID.CG26_DRAGON_AND_FOG),
        [CGID.CG28_SUMMON_3] = not CompulsiveGuideManager:IsFinish(CGID.CG27_COLLECT_TASK_PRIZE),
        [CGID.CG29_GOGOGO] = not CompulsiveGuideManager:IsFinish(CGID.CG28_SUMMON_3),
        [CGID.CG30_BATTLE_SPEED_UP] = not CompulsiveGuideManager:IsFinish(CGID.CG26_DRAGON_AND_FOG),
        [CGID.CG31_FORMATION] = PlayerData.Datas.BuildData.isAllPass or
            (PlayerData.Datas.BuildData.newBuildData and PlayerData.Datas.BuildData.newBuildData.id ~= 1101) or
            not CG31Condition(),
        [CGID.CG40_HERO_PROMOTE] = IsLock(CompulsiveGuideManager.Config.HeroPromoteBuildId),
        [CGID.CG41_AFTER_HERO_PROMOTE] = not CompulsiveGuideManager:IsFinish(CGID.CG40_HERO_PROMOTE),
        [CGID.CG50_GUILD] = IsLock(CompulsiveGuideManager.Config.GuildBuildId) or
            not PlayerData.Datas.UserData:IsFunctionOpened(FuncType.FT_GUILD),
        [CGID.CG60_CHALLENGE] = IsLock(CompulsiveGuideManager.Config.TowerServerId),
        [CGID.CG62_COLLECT_TASK_PRIZE] = PlayerData.Datas.BuildData.isAllPass or
            (PlayerData.Datas.BuildData.newBuildData and PlayerData.Datas.BuildData.newBuildData.id ~= 1201),
        [CGID.CG65_PVP] = IsLock(CompulsiveGuideManager.Config.PvpBuildId) or IsPass(GuideRecordType.GT_CHANGE_NAME),
        [CGID.CG70_BLACK_MARKET] = IsLock(CompulsiveGuideManager.Config.ShopBuildId),
        [CGID.CG80_GUILD_ENTRUST] = IsLock(CompulsiveGuideManager.Config.GuildEntraustBuildId),
        [CGID.CG90_LEADER_SPRING] = IsLock(CompulsiveGuideManager.Config.LeaderSpringBuildId),
        [CGID.CG100_DESERT_EXPLORE] = IsLock(CompulsiveGuideManager.Config.DesertExploreBuildId),
        [CGID.CG110_ALL_RANKING] = IsLock(CompulsiveGuideManager.Config.RankingBuildId),
        [CGID.CG120_FIRST_LOSE] = PlayerData.Datas.BuildData.isAllPass or
            (PlayerData.Datas.BuildData.newBuildData and PlayerData.Datas.BuildData.newBuildData.id >= 1201),
        [CGID.CG121_FIRST_LOSE] = not CompulsiveGuideManager:IsFinish(CGID.CG120_FIRST_LOSE),
        [CGID.CG170_FIRE_DRAGON_NEST] = IsLock(CompulsiveGuideManager.Config.FireDragonBuildSeverId),
        [CGID.CG180_ICE_DRAGON_NEST] = IsLock(CompulsiveGuideManager.Config.IceDragonBuildSeverId),
        [CGID.CG190_SAND_DRAGON_NEST] = IsLock(CompulsiveGuideManager.Config.SandDragonBuildSeverId),
        [CGID.CG200_WIND_DRAGON_NEST] = IsLock(CompulsiveGuideManager.Config.WindDragonBuildSeverId),
        [CGID.CG240_DRAGON_BOSS] = PlayerData.Datas.DragonBossData.dragonBossStatus ~= DragonBossStatus.Open,
        [CGID.CG250_ZQDN] = IsLock(CompulsiveGuideManager.Config.ZqdnBuildSeverId),
        [CGID.CG270_BATTLE_SKIP] = false,
        [CGID.CG280_FAST_IDLE] = not PlayerData.Datas.UserData:IsFunctionOpened(FuncType.FT_FAST_COLLECT_BUILD_PRIZE) or
            IsPass(GuideRecordType.GT_FIRST_FAST_COLLECT_BUILD_PRIZE),
        [CGID.CG290_KFJJC] = IsLock(CompulsiveGuideManager.Config.KfjjcSeverId),
        [CGID.CG300_CAMP_DUNGEON] = PlayerData.Datas.BuildData.isAllPass or
        (PlayerData.Datas.BuildData.newBuildData and PlayerData.Datas.BuildData.newBuildData.id ~= 2436),
        [CGID.CG_TALENT] = not PlayerData.Datas.UserData:IsFunctionOpened(FuncType.FT_TALENT),
    }
end
-- 黑名单
local m_blacklist = {
    [CGID.CG121_FIRST_LOSE] = true
}
CompulsiveGuideManager = {}
CompulsiveGuideManager.Config = {
    CG10HeiBaoDataId = 2054, -- 黑豹id
    CG10WuguiDataId = 1032, -- 乌龟法师配置id
    CG11HeroDataId = 3013, -- 猩猩游侠配置id
    TavernBuildServerId = 101, -- 酒馆
    ShopBuildId = 110, -- 黑市
    TowerServerId = 120, -- 试炼
    HeroPromoteBuildId = 130, -- 英雄圣像
    GuildBuildId = 140, -- 部落
    PvpBuildId = 150, -- 竞技场
    GuildEntraustBuildId = 160, -- 悬赏
    RankingBuildId = 170, -- 纪念丰碑
    DesertExploreBuildId = 180, -- 沙漠探索
    LeaderSpringBuildId = 190, -- 领袖之泉
    KfjjcSeverId = 507, -- 天梯
    ZqdnBuildSeverId = 508, -- 战术实验室
    FireDragonBuildSeverId = 701, -- 火龙
    IceDragonBuildSeverId = 704, -- 冰龙
    SandDragonBuildSeverId = 703, -- 沙龙
    WindDragonBuildSeverId = 702 -- 风龙
}
-- 当打开这些界面时,尝试隐藏引导(只比较name不是安全的做法)
CompulsiveGuideManager.needHideGuideUIs = {
    [UIInfo.GameSettingsUI.UIComName] = true,
    [UIInfo.ServerListUI.UIComName] = true,
    [UIInfo.PrizeListUI.UIComName] = true,
    [UIInfo.LoadingUI.UIComName] = true,
    [UIInfo.PopupUI.UIComName] = true,
    [UIInfo.CDKUI.UIComName] = true
}
-- 表示新手引导正在进行中
CompulsiveGuideManager.isUnderWay = false
-- 新手引导UI
local m_mainUI = nil
-- 剧情组件
local m_dialogCom = nil
local m_dialog_T = nil
local m_dialogPos_C = nil
local m_dialogLoader = nil
-- 跳转下一步的点击区域
local m_nextStepBtn = nil
-- 玩家设置按钮
local m_settingBtn = nil
-- 加速球
local m_downloadBtn = nil
local m_downloadBtn_C = nil
-- 假按钮
local m_fakeBtn = nil
-- 黑边控制器
local m_blackEdge_C = nil
-- 布阵组件
local m_formationCom = nil
-- 手指动画组件
local m_fingerCom = nil
-- 手指tips
local m_fingerTipsLabel = nil
-- 解释性组件
local m_explainCom = nil
-- 解释性文本+bg
local m_explainText = nil
local m_explainTextBg = nil
local m_dialogBg = nil
local m_highlightCom = nil
local m_explainTargetCom = nil
local m_explainTargetPreXy = nil
local m_explainTargetParent = nil
-- 操作多个组件(必须是主组件的child,再自己用个空graph搭配使用)
local explainTargetComs = nil
local explainTargetComsParent = nil
-- 命名组件
local m_renameCom = nil
local m_renameBtn = nil
local m_input = nil
local m_randomBtn = nil
local m_randomConfig = nil
-- 手指类型
local m_finger_C = nil
-- 手指动画
local m_finger_T = nil
-- 手指特效
local m_fingerEffWrapper = nil
-- 焦距特效
local m_focusEffWrapper = nil
-- 当前引导唯一标识id
local m_currId = 0
-- 当前引导步骤id
local m_currStep = 0
-- 列表
local m_targetList = nil
-- 是否处于延时过程中
local m_inDelay = false
-- 当前目标组件
local m_currTargetCom = nil
-- 当前建筑id
local m_currBuildId = nil
-- 升级面板的可见性
local m_upgradeUIVisible = nil
-- 当前引导时npc id
local m_currNpcId = nil
-- 镜头聚焦回调
local m_focusCB = nil

-- 析构UI组件并返回nil
local function DisposeUI(ui)
    if not Utils.uITargetIsNil(ui) then
        ui:Dispose()
    end

    return nil
end

-- 清除UI事件(默认点击事件)
-- obj:GObject
-- eventType:string
local function ClearUIEvent(obj, eventType)
    if not Utils.uITargetIsNil(obj) then
        if eventType == nil then
            obj.onClick:Clear()
        else
            if obj[eventType] then
                obj[eventType]:Clear()
            end
        end
    end
end

-- 错误/报错处理:结束当前引导
local function ErrorHandle(log)
    if type(log) == "string" then
        Utils.DebugWarning(log)
    end

    CompulsiveGuideManager:Finish(m_currId)
end

-- 获取当前配置
local function GetCurrConfig(id, step)
    id = id or m_currId
    step = step or m_currStep

    if GuideConfig == nil or GuideConfig[id] == nil then
        return nil
    end

    return GuideConfig[id][step]
end

local function fingerTweenCallBack()
    if m_fingerEffWrapper then
        m_fingerEffWrapper.visible = false
        m_fingerEffWrapper.visible = true
    end
end

-- 手指动画
local function FingerTween()
    if m_fingerCom == nil or m_finger_T == nil then
        return Utils.DebugWarning("手指组件或动画丢失")
    end

    if not m_finger_T.playing then
        m_finger_T:Play(-1, 0)
    end

    m_finger_T:SetHook("trigger", fingerTweenCallBack)
    m_focusEffWrapper.visible = false
    m_focusEffWrapper.visible = true
end

-- 显示手指
local function ShowFinger(xy)
    if m_mainUI.visible == false then
        return
    end

    if m_fingerCom == nil then
        return Utils.DebugWarning("手指组件丢失")
    end

    if xy == nil then
        m_fingerCom.xy = m_mainUI.mask.gOwner.xy
    else
        m_fingerCom.xy = xy
    end

    m_fingerCom.visible = true
    FingerTween()

    -- 边缘处理 0:↖ 1:↗ 2:↙ 3:↘
    if m_fingerCom.y <= GRoot.inst.height - m_fingerCom.height then
        if m_fingerCom.x <= GRoot.inst.width - m_fingerCom.width then
            m_finger_C.selectedIndex = 0
        else
            m_finger_C.selectedIndex = 1
        end
    else
        if m_fingerCom.x <= GRoot.inst.width - m_fingerCom.width then
            m_finger_C.selectedIndex = 2
        else
            m_finger_C.selectedIndex = 3
        end
    end
end

-- 设置手指偏移
local function SetFingerOffset(x, y)
    m_fingerCom.x = m_fingerCom.x + x
    m_fingerCom.y = m_fingerCom.y + y
end

-- 隐藏手指
local function HideFinger()
    if not Utils.uITargetIsNil(m_fingerCom) then
        m_finger_T:Stop()
        m_fingerCom.visible = false
    end
end

-- 处理目标组件
local function JustDoIt()
    CompulsiveGuideManager:NextPage()
end

-- 获取目标组件的中心位置
local function GetObjCenterPosByCom(gObj)
    if gObj == nil then
        return Vector2.zero
    end

    local xy =
        gObj:LocalToRoot(-GRoot.inst.xy / UIContentScaler.scaleFactor) +
        Vector2(gObj.actualWidth * 0.5, gObj.actualHeight * 0.5)

    if (gObj.pivotX > 0 or gObj.pivotY > 0) and gObj.pivotAsAnchor then
        xy = xy - Vector2(gObj.actualWidth * gObj.pivotX, gObj.actualHeight * gObj.pivotY)
    end

    return xy
end

-- 根据目标组件设置当前组件的的大小和位置
-- gObj必须是中心锚点
local function SetSizeAndXyByCom(gObj, targetCom)
    if gObj == nil or targetCom == nil then
        return
    end

    -- 设置大小
    gObj.size = Vector2(targetCom.actualWidth, targetCom.actualHeight)
    -- 设置位置
    gObj.xy = GetObjCenterPosByCom(targetCom)
end

-- 只比较ComName是不保险的
local function ComparePanelInfo(panelInfo)
    local panel = UIManager.GetCurUI()

    if panel == nil then
        return false, nil
    end

    if type(panelInfo) ~= "table" then
        return false, panel
    end

    for k, v in pairs(panel.PanelInfo) do
        if v ~= panelInfo[k] then
            return false, panel
        end
    end

    return true, panel
end

-- 过滤特殊界面
local function IsSpecialPanel()
    if UIManager == nil or UIManager.GetCurUI == nil then
        return false
    end

    local currPanel = UIManager.GetCurUI()

    if currPanel == nil or currPanel.PanelInfo == nil then
        return false
    end

    return CompulsiveGuideManager.needHideGuideUIs[currPanel.PanelInfo.UIComName]
end

-- 根据当前配置获取UI
-- key:config.uiInfoKey
local function GetCurrUIByConfig(key)
    if IsSpecialPanel() then
        return
    end

    if key == nil or key == "" then
        return ErrorHandle("config.uiInfoKey is nil")
    end

    -- 特殊界面
    if CompulsiveGuideManager.needHideGuideUIs[UIInfo[key]] then
        return
    end

    local result, currPanel = ComparePanelInfo(UIInfo[key])

    if not result then
        local content = "expected ui is " .. key

        if currPanel and currPanel.PanelInfo then
            content =
                content ..
                ",but get component name is " ..
                    currPanel.PanelInfo.UIComName .. "(" .. m_currId .. "-" .. m_currStep .. ")"
        end

        return ErrorHandle(content)
    end

    local ui = currPanel.UI

    if ui == nil then
        return ErrorHandle("target component is nil")
    end

    return ui
end

-- parentCom:主组件
-- path:路径
-- errorHandle:是否需要错误处理
local function GetComByPath(parentCom, path, errorHandle)
    if parentCom == nil or parentCom.asCom == nil or type(path) ~= "string" then
        return nil
    end

    local pathTable = Utils.stringSplit(path, "/")
    local targetCom = parentCom

    for k, v in pairs(pathTable) do
        targetCom = targetCom:GetChild(v)

        if nil == targetCom then
            if errorHandle then
                return ErrorHandle("target component is nil, path:" .. v)
            else
                return nil
            end
        end
    end

    return targetCom
end

-- 处理列表的滑动
local function HandleListTouchEff(list)
    m_targetList = list

    if "userdata" ~= type(m_targetList) then
        return Utils.DebugWarning("list type is wrong:" .. type(m_targetList))
    end

    -- 禁止滑动
    if m_targetList.scrollPane then
        m_targetList.scrollPane.touchEffect = false
    end
end

-- 处理目标控件
-- isIgnoreClick:忽略点击
local function HandleTargetCom(targetCom, isIgnoreClick)
    m_currTargetCom = targetCom

    if targetCom then
        targetCom.onPositionChanged:Set(
            function()
                CompulsiveGuideManager:UpdateState()
            end
        )
    end

    if isIgnoreClick then
        return
    end

    local currId, currStep = m_currId, m_currStep

    if m_currTargetCom then
        m_currTargetCom.onClick:Add(
            function()
                if not CompulsiveGuideManager:IsCurrIdAndStep(currId, currStep) then
                    return
                end

                if m_currTargetCom then
                    m_currTargetCom.onPositionChanged:Clear()
                end

                JustDoIt()
            end
        )
    end
end

-- 自动对齐功能
-- mask:遮罩
local function AutoAlign(mask)
    if m_mainUI.visible == false then
        return
    end

    if nil == mask then
        return ErrorHandle("mask is nil")
    end

    local config = GetCurrConfig()

    if nil == config then
        return ErrorHandle("current config is nil:" .. m_currId .. "-" .. m_currStep)
    end

    -- 匹配期望UI
    local targetCom = GetCurrUIByConfig(config.uiInfoKey)

    if config.path == "" then
        return
    end

    targetCom = GetComByPath(targetCom, config.path, true)

    -- 是否为列表内的Item
    if config.itemIndex and type(config.itemIndex) == "number" and config.itemIndex > 0 then
        HandleListTouchEff(targetCom)
        targetCom = targetCom:GetChildAt(config.itemIndex - 1)

        if nil == targetCom then
            return ErrorHandle("没有找到序号为" .. config.itemIndex .. "的item")
        end

        if config.itemPath and config.itemPath ~= "" then
            local pathTable = Utils.stringSplit(config.itemPath, "/")

            if pathTable then
                for k, v in pairs(pathTable) do
                    targetCom = targetCom:GetChild(v)
                end
            end

            if nil == targetCom then
                return ErrorHandle("没有找到路径为" .. config.itemPath .. "的item")
            end
        end
    end

    mask.gOwner:SetShape("rect")
    SetSizeAndXyByCom(mask.gOwner, targetCom)
    -- 下一关自动跳过(除29-0)
    -- print(m_currId .. "-" .. m_currStep,(config.uiInfoKey == "MainUI" and config.path == "NextLevel"))
    HandleTargetCom(
        targetCom,
        (config.uiInfoKey == "MainUI" and config.path == "NextLevel" and
            not CompulsiveGuideManager:IsCurrIdAndStep(CGID.CG29_GOGOGO, 0)) or
            config.isIgnoreClick
    )
    Utils.DebugLog("Compulsive Guide Auto Aligning! " .. m_currId .. "-" .. m_currStep)
end

-- 点击建筑成功
local function OnClickBuild()
    EventDispatcher:Remove(Event.BUILD_CLICK, OnClickBuild)

    if CompulsiveGuideManager:IsCurrIdAndStep(CGID.CG100_DESERT_EXPLORE, 0) then
        return
    end

    local panel = UIManager.GetCurUI()

    if panel and panel.PanelInfo and panel.PanelInfo.UILogic == "UI.ToolsWindow.LevelInfoPanel" then
        return
    end

    if CompulsiveGuideManager.isUnderWay then
        JustDoIt()
    end
end

-- 引导点击建筑
local function GuideClickBuild(pos)
    if m_mainUI then
        m_focusCB = nil
        m_fakeBtn.xy = pos
        m_fakeBtn.size = Vector2(300, 300)
        m_fakeBtn.onClick:Set(
            function()
                MapManager.OpenCameraFocusOnBuild(m_currBuildId)
            end
        )
        m_fakeBtn.visible = true
        ShowFinger(m_fakeBtn.xy)

        if
            CompulsiveGuideManager:IsCurrIdAndStep(CGID.CG60_CHALLENGE, 0) or
                CompulsiveGuideManager:IsCurrIdAndStep(CGID.CG300_CAMP_DUNGEON, 0)
         then
            SetFingerOffset(-60, 0)
        end

        EventDispatcher:Add(Event.BUILD_CLICK, OnClickBuild)
    end
end

-- 关闭主界面引导按钮可见性
local function CloseMainBtnsVisible()
    if m_settingBtn then
        m_settingBtn.visible = false
    end

    if m_downloadBtn then
        m_downloadBtn.visible = false
    end
end

local function CreateView(name, isFull, touchable)
    local view = UIManager.CreateFairyCom("UI/CompulsiveGuide/CompulsiveGuide", "CompulsiveGuide", name, isFull)
    view.sortingOrder = UISortOrder.NewGuide
    view.visible = false
    view.touchable = touchable
    return view
end

local function InputReqFocus()
    if m_input then
        m_input:RequestFocus()
        Stage.inst:OpenKeyboard(m_input.text, false, false, false, false, nil, m_input.keyboardType, m_input.hideInput)
    end
end

local function TryInitBaseCom()
    if m_fingerCom == nil then
        m_fingerCom = CreateView("Component_Finger", false, false)
        m_fingerCom.sortingOrder = UISortOrder.NewGuide + 2
        m_fingerTipsLabel = m_fingerCom:GetChild("Label_FingerTips")
        m_fingerTipsLabel.sortingOrder = UISortOrder.NewGuide + 2
        m_fingerTipsLabel.touchable = false

        m_finger_C = m_fingerCom:GetController("Type_C")
        m_finger_T = m_fingerCom:GetTransition("Tween_T")
        m_fingerEffWrapper =
            CommonUIUtils.CreateUIEff(m_fingerCom:GetChild("holder_1"), Configs.EffectPathCfg().UIYinDaoQuan, 3)
        m_focusEffWrapper =
            CommonUIUtils.CreateUIEff(m_fingerCom:GetChild("holder_2"), Configs.EffectPathCfg().UIJuJiao, 3)
    end

    if m_mainUI == nil then
        m_mainUI = CreateView("CompulsiveMain", true, true)
        m_dialogCom = m_mainUI:GetChild("Component_Dialog")
        m_dialog_T = m_dialogCom:GetTransition("Left")
        m_dialogLoader = m_dialogCom:GetChild("icon")
        m_dialogPos_C = m_dialogCom:GetController("Pos_C")
        m_nextStepBtn = m_mainUI:GetChild("Button_NextStep")
        m_nextStepBtn.sound = ""
        m_settingBtn = m_mainUI:GetChild("Button_Setting")
        m_downloadBtn = m_mainUI:GetChild("Button_Download")
        m_downloadBtn_C = m_downloadBtn:GetController("button")
        m_fakeBtn = m_mainUI:GetChild("Button_Fake")
        m_explainTextBg = m_mainUI:GetChild("Graph_ExplainTextBg")
        m_dialogBg = m_mainUI:GetChild("Graph_DialogBg")
        m_highlightCom = m_mainUI:GetChild("Component_Highlight")
        m_renameCom = m_mainUI:GetChild("Component_Rename")
        m_blackEdge_C = m_mainUI:GetController("BlackEdge_C")
    end
end

-- 设置布阵组件可见性
local function SetFormationCom(visible, xy)
    if type(visible) == "boolean" then
        if visible and xy then
            if m_formationCom == nil then
                m_formationCom = CreateView("Component_FormationLine", false, false)
            end

            m_formationCom.xy = xy
            m_formationCom.visible = true
        else
            m_formationCom = DisposeUI(m_formationCom)
        end
    end
end

-- 解释性组件
local function TryGetAndSetExplainCom(index)
    if type(index) ~= "number" or index < 1 then
        return
    end

    if m_explainCom == nil then
        m_explainCom = CreateView("Label_Explain", false, false)
        m_explainCom:Center()
        -- IphoneX
        m_explainCom.x = m_explainCom.x - GRoot.inst.x / UIContentScaler.scaleFactor
        m_explainCom:GetController("Type_C").selectedIndex = index
        m_explainCom.icon = "UIImage/CompulsiveGuide/ui_guide_" .. index

        for index = 0, m_explainCom:GetChildren().Length - 1 do
            local child = m_explainCom:GetChildAt(index)

            if child and child.text then
                child.text = LocalizeExt(child.text)
            end
        end
    end
end

-- 解释性组件
local function TryDisposeExplainCom()
    if not Utils.uITargetIsNil(m_explainCom) then
        m_explainCom.icon = ""
    end

    m_explainCom = DisposeUI(m_explainCom)
end

-- 设置主界面按钮(玩家设置按钮,下载球)
local function SetMainUIBtns()
    if not CompulsiveGuideManager.isUnderWay or m_settingBtn == nil or m_downloadBtn == nil then
        return
    end

    local main = UIManager.GetUI(UIInfo.MainUI.UIComName)

    if main == nil or main.UI == nil then
        return
    end

    local function CheckBtn(myBtn, path)
        if myBtn == nil or type(path) ~= "string" then
            return
        end

        local targetBtn = GetComByPath(main.UI, path, false)

        if targetBtn then
            myBtn.visible = targetBtn.visible
            SetSizeAndXyByCom(myBtn, targetBtn)
            targetBtn.onPositionChanged:Set(
                function()
                    SetSizeAndXyByCom(myBtn, targetBtn)
                end
            )
            myBtn.onClick:Set(
                function()
                    targetBtn.onPositionChanged:Clear()
                    targetBtn.onClick:Call()
                end
            )

            if path == "Button_Download" and m_downloadBtn_C then
                m_downloadBtn_C.onChanged:Set(
                    function()
                        targetBtn:GetController("button").selectedIndex = m_downloadBtn_C.selectedIndex
                    end
                )
            end
        end
    end

    CheckBtn(m_settingBtn, "PlayerItem_Comp/PlayerIcon_Btn")
    CheckBtn(m_downloadBtn, "Button_Download")
end

-- 根据外部传入的UI组件修改当前遮罩的位置
local function ResetMaskByOtherUI(ui, isIgnoreClick)
    if ui == nil then
        return ErrorHandle(m_currId .. "-" .. m_currStep .. ":reset mask by ui, but ui is nil")
    end

    SetSizeAndXyByCom(m_mainUI.mask.gOwner, ui)
    HandleTargetCom(ui, isIgnoreClick)
    -- 显示手指
    ShowFinger()
end

-- 尝试操作战斗暂停
local function TrySetBattleState(flag)
    if BattleManager.curBattle then
        BattleManager.curBattle:Pause(flag)
    end
end

local hasDoGragonBossOneStep = false

-- 在处理完配置后,定制引导逻辑
function CompulsiveGuideManager:LateCustLogic()
    local currPanel = UIManager.GetCurUI()
    Utils.DebugLog("LateCustLogic " .. tostring(m_currId) .. " " .. tostring(m_currStep))

    if ComparePanelInfo(UIInfo.BattleUI) then
        if m_currId == CGID.CG1_FAKE_BATTLE then
            if m_currStep == 1 or m_currStep == 3 or m_currStep == 6 then
                BattleManager.curBattle:DoContinue()
            elseif m_currStep == 4 then
                -- ?
                -- GRoot.inst.touchable = false
                -- m_dialog_T:Play(
                --     1,
                --     0,
                --     function()
                --         GRoot.inst.touchable = true
                --     end
                -- )
            end
        end
    elseif ComparePanelInfo(UIInfo.Formation) then
        if self:IsCurrIdAndStep(CGID.CG10_FORMATION, 2) then
            -- 黑豹刺客
            currPanel.dragToFormation = false
            currPanel:BindHeroDistStance(self.Config.CG10HeiBaoDataId, 1)
        elseif self:IsCurrIdAndStep(CGID.CG10_FORMATION, 3) then
            -- if m_currTargetCom then
            --     SetFormationCom(true, GetObjCenterPosByCom(m_currTargetCom))
            --     HideFinger()
            -- end
            -- 乌龟法师
            currPanel.dragToFormation = false
            currPanel:BindHeroDistStance(self.Config.CG10WuguiDataId, 2)
        elseif self:IsCurrIdAndStep(CGID.CG19_FIGHT_2, 2) then
            --     -- 点击黑豹模型
            --     m_fakeBtn.xy = currPanel:GetStanceGoFairyPos(1)
            --     m_fakeBtn.size = Vector2(200, 200)
            --     m_fakeBtn.onClick:Set(
            --         function()
            --             currPanel:OpenHeroInfo(self.Config.CG10HeiBaoDataId)
            --             JustDoIt()
            --         end
            --     )
            --     m_fakeBtn.visible = true
            --     ShowFinger(m_fakeBtn.xy)
            -- 猩猩游侠
            currPanel.dragToFormation = false
            currPanel:BindHeroDistStance(self.Config.CG11HeroDataId, 3)
        elseif self:IsCurrIdAndStep(CGID.CG23_FORMATION, 1) then
            currPanel.dragToFormation = false
        elseif self:IsCurrIdAndStep(CGID.CG31_FORMATION, 0) then
            currPanel.dragToFormation = false
            if m_cg31HeroInfo then
                ResetMaskByOtherUI(currPanel:GetCardObjByHeroId(m_cg31HeroInfo.id))
            end
        elseif self:IsCurrIdAndStep(CGID.CG31_FORMATION, 1) then
            currPanel.dragToFormation = false
            local targetUI = currPanel:GetNextCanEquipHeroUICard()

            -- 能上找一个上 不能上跳过
            if targetUI == nil then
                self:SkipToStep(2)
            else
                ResetMaskByOtherUI(targetUI)
            end
        end
    elseif ComparePanelInfo(UIInfo.HeroInfoUI) then
        if self:IsCurrIdAndStep(CGID.CG17_HERO_UPGRADE, 2) then
            -- 不是一级跳级
            if
                currPanel.curHeroId and PlayerData.Datas.HeroData.heroMap[currPanel.curHeroId] and
                    PlayerData.Datas.HeroData.heroMap[currPanel.curHeroId].level ~= 1
             then
                self:SkipToStep(3)
            end
        end
    elseif ComparePanelInfo(UIInfo.HeroListUI) then
        if
            self:IsCurrIdAndStep(CGID.CG17_HERO_UPGRADE, 1) or self:IsCurrIdAndStep(CGID.CG18_EQUIP, 2) or
                self:IsCurrIdAndStep(CGID.CG22_CHANGE_JOB, 3)
         then
            -- 点击黑豹UI
            HideFinger()
            GRoot.inst.touchable = false
            TimerManager.waitTodo(
                0.2,
                1,
                function()
                    GRoot.inst.touchable = true
                    ResetMaskByOtherUI(currPanel:GetCardObjByHeroId(self.Config.CG10HeiBaoDataId))
                end
            )
        end
    elseif ComparePanelInfo(UIInfo.HeroPromote) then
        if m_currId == CGID.CG40_HERO_PROMOTE then
            if m_currStep == 1 then
                -- 获取最高等级小黑豹
                ResetMaskByOtherUI(currPanel:GetHighestLevelHeiBaoUI())
            elseif m_currStep == 4 or m_currStep == 5 then
                -- 获取小黑豹
                ResetMaskByOtherUI(currPanel:GetHeiBaoUI())
            end
        end
    elseif ComparePanelInfo(UIInfo.MainUI) then
        if
            self:IsCurrIdAndStep(CGID.CG27_COLLECT_TASK_PRIZE, 0) or
                self:IsCurrIdAndStep(CGID.CG62_COLLECT_TASK_PRIZE, 0)
         then
            -- 获取领取按钮
            ResetMaskByOtherUI(currPanel:GetGuideCom())
         elseif self:IsCurrIdAndStep(CGID.CG_TALENT, 1) then
            -- 打开某英雄详情
            UIManager.OpenUI(UIInfo.HeroListUI)
            local heroListUI = UIManager.GetUI(UIInfo.HeroListUI.UIComName)

            if heroListUI then
                heroListUI.cardList:GetChildAt(0).onClick:Call()
                self:NextPage()
            end
        end
    elseif ComparePanelInfo(UIInfo.TaskHeroSelectUI) then
        if self:IsCurrIdAndStep(CGID.CG80_GUILD_ENTRUST, 1) then
            self:NextPage()
        end
    elseif self:IsCurrIdAndStep(CGID.CG26_DRAGON_AND_FOG, 0) then
        self:Save(m_currId)
    elseif self:IsCurrIdAndStep(CGID.CG240_DRAGON_BOSS, 0) then
        if (not hasDoGragonBossOneStep) then
            hasDoGragonBossOneStep = true
            -- 龙boss定制
            if m_blackEdge_C then
                EventDispatcher:Dispatch(Event.PLAY_TRANSITION, true, true)
                m_blackEdge_C.selectedIndex = 1
            end

            m_dialogCom.visible = false
            m_nextStepBtn.onClick:Clear()
            TimerManager.waitTodo(
                4,
                1,
                function()
                    if m_dialogCom then
                        m_dialogCom.visible = true
                    end

                    if m_nextStepBtn then
                        m_nextStepBtn.onClick:Set(JustDoIt)
                    end
                end
            )
        end
    elseif self:IsCurrIdAndStep(CGID.CG240_DRAGON_BOSS, 1) then
        HideFinger()

        if m_mainUI then
            if m_blackEdge_C then
                m_blackEdge_C.selectedIndex = 3
            end

            local closeTween = m_mainUI:GetTransition("Close")

            local function cb()
                JustDoIt()
                EventDispatcher:Dispatch(Event.PLAY_TRANSITION, false, true)
            end

            if closeTween then
                closeTween:Play(cb)
            else
                cb()
            end
        end
    end
end

-- 预处理一些组件的状态,在Reset/Show时调用
local function PreHandle()
    if not Utils.uITargetIsNil(m_targetList) then
        if m_targetList.scrollPane then
            m_targetList.scrollPane.touchEffect = true
        end
    end

    m_targetList = nil
    ClearUIEvent(m_nextStepBtn)

    if not Utils.uITargetIsNil(m_fakeBtn) then
        m_fakeBtn.onClick:Clear()
        m_fakeBtn.visible = false
    end

    m_currTargetCom = nil
    -- SetFormationCom(false)
    HideFinger()
    m_currBuildId = nil

    if m_mainUI and m_mainUI.mask then
        m_mainUI.mask.visible = false

        if m_mainUI.mask.gOwner then
            m_mainUI.mask.gOwner.size = Vector2.zero
        end
    end

    if not Utils.uITargetIsNil(m_fingerTipsLabel) then
        m_fingerTipsLabel.visible = false
    end

    if not Utils.uITargetIsNil(m_renameCom) then
        m_renameCom.visible = false
    end

    m_explainText = DisposeUI(m_explainText)

    if not Utils.uITargetIsNil(m_explainTargetCom) then
        m_explainTargetCom.touchable = true

        if m_explainTargetParent then
            m_explainTargetCom.sortingOrder = 0
            m_explainTargetParent:AddChild(m_explainTargetCom)
            m_explainTargetCom.xy = m_explainTargetPreXy
        end
    end

    m_explainTargetParent = nil
    m_explainTargetCom = nil
    m_explainTargetPreXy = nil

    if explainTargetComs and not Utils.uITargetIsNil(explainTargetComsParent) then
        for _, child in pairs(explainTargetComs) do
            child.touchable = true
            child.sortingOrder = 0
            explainTargetComsParent:AddChild(child)
        end
    end

    explainTargetComs = nil
    explainTargetComsParent = nil

    if m_blackEdge_C then
        m_blackEdge_C.selectedIndex = 0
    end

    -- Stage.inst.onClick:Remove(InputReqFocus)
end

local function HandleExplainTargetComs(nameList)
    m_mainUI.mask.gOwner.size = Vector2.zero
    explainTargetComs = {}
    explainTargetComsParent = m_currTargetCom.parent

    for _, v in pairs(nameList) do
        local child = explainTargetComsParent:GetChild(v)

        if child then
            child.touchable = false
            table.insert(explainTargetComs, child)
            GRoot.inst:AddChild(child).sortingOrder = UISortOrder.NewGuide + 1
        end
    end
end

-- 解释性文本
local function TryGetAndSetExplainText(content, isListItem)
    if m_mainUI == nil or m_mainUI.mask == nil or type(content) ~= "string" then
        return
    end

    -- 定制控件
    if CompulsiveGuideManager:IsCurrIdAndStep(CGID.CG290_KFJJC, 2) then
        HideFinger()
    else
        -- 挖
        AutoAlign(m_mainUI.mask)
    end

    if m_currTargetCom then
        if isListItem then
        else
            -- 高亮且不显示mask
            m_explainTargetCom = m_currTargetCom
            m_explainTargetCom.onPositionChanged:Clear()
            m_explainTargetPreXy = m_explainTargetCom.xy
            m_explainTargetCom.touchable = false

            if CompulsiveGuideManager:IsCurrIdAndStep(CGID.CG50_GUILD, 4) then
                -- 特殊处理(未选中的页签)
                m_mainUI.mask.gOwner.width = m_mainUI.mask.gOwner.width - 46
                m_mainUI.mask.gOwner.x = m_mainUI.mask.gOwner.x + 23
            elseif CompulsiveGuideManager:IsCurrIdAndStep(CGID.CG250_ZQDN, 5) then
                -- 战术实验室的按钮介绍
                HandleExplainTargetComs(
                    {
                        "Shop_Btn",
                        "Rank_Btn",
                        "Record_Btn"
                    }
                )
            else
                m_mainUI.mask.gOwner.size = Vector2.zero
                m_explainTargetParent = m_currTargetCom.parent
                m_explainTargetCom.xy = m_explainTargetCom:LocalToRoot(-GRoot.inst.xy / UIContentScaler.scaleFactor)
                GRoot.inst:AddChild(m_explainTargetCom).sortingOrder = UISortOrder.NewGuide + 1
            end
        end
    end

    m_explainText = DisposeUI(m_explainText)
    local formatId = nil

    -- 样式处理 1:↖ 2:↗ 3:↙ 4:↘
    if m_mainUI.mask.gOwner.y <= GRoot.inst.height * 0.5 then
        if m_mainUI.mask.gOwner.x <= GRoot.inst.width * 0.5 then
            formatId = 1
        else
            formatId = 2
        end
    else
        if m_mainUI.mask.gOwner.x <= GRoot.inst.width * 0.5 then
            formatId = 3
        else
            formatId = 4
        end
    end

    m_explainText = CreateView("Label_ExplainText_" .. formatId, false, false)
    m_explainText.sortingOrder = UISortOrder.NewGuide + 2

    if m_explainText == nil then
        Utils.DebugWarning("explain text is nil, format id is " .. formatId)
        return
    end

    local text = m_explainText:GetChild("title")
    text.width = text.initWidth
    m_explainText.title = content
    text.width = text.textWidth
    text.height = text.textHeight
    m_explainText.xy = m_mainUI.mask.gOwner.xy

    if m_currTargetCom then
        local heightImg = m_explainText:GetChild("Image_Line_Height")
        heightImg.height = m_currTargetCom.actualHeight * 0.5 + 40 + text.height
    end

    m_explainText.visible = true
end

-- 显示并设置重命名组件
function CompulsiveGuideManager:ShowAndSetRenameCom()
    if m_renameCom == nil then
        return
    end

    local FilterWordManager = require "Manager.FilterWordManager"
    
    m_renameCom:GetChild("StaticTop").text = LocalizeExt(25250)
    local tipsText = m_renameCom:GetChild("StaticTop2")
    tipsText.text = LocalizeExt(25251)
    m_renameBtn = m_renameCom:GetChild("btn_ResetName")
    m_renameBtn.title = LocalizeExt(20046)
    m_input = m_renameCom:GetChild("EnterAccount_Label")
    m_input.text = ""
    m_input.promptText = string.format("[color=#999999]%s[/color]", LocalizeExt(20308))
    -- m_input:RequestFocus()
    -- m_input.touchable = false
    local minLength, maxLength = Utils:GetNameLength()
    m_input.onFocusOut:Set(
        function()
            local len = Utils.GetStringLength(m_input.text)
            if len == 0 then
                -- 玩家名不能为空
                tipsText.text = string.format("[color=#FF0000]%s", LocalizeExt(20586))
            elseif len < minLength then
                -- 名字太短
                tipsText.text = string.format("[color=#FF0000]%s", LocalizeExt(20302))
            elseif len > maxLength then
                -- 名字太长
                tipsText.text = string.format("[color=#FF0000]%s", LocalizeExt(20303))
            elseif FilterWordManager.CheckNameWordsHasFilter(m_input.text) then
                -- 含有敏感内容或非法字符
                tipsText.text = string.format("[color=#FF0000]%s", LocalizeExt(20300))
            else
                tipsText.text = LocalizeExt(25251)
            end
        end
    )
    m_renameBtn.onClick:Set(
        function()
            local len = Utils.GetStringLength(m_input.text)

            if len == 0 or len < minLength or len > maxLength or FilterWordManager.CheckNameWordsHasFilter(m_input.text) then
                m_input.onFocusOut:Call()
            else
                -- Stage.inst.onClick:Remove(InputReqFocus)
                PlayerData.Datas.UserMiscData:RequestSetGuideNameMsg(m_input.text)
            end
        end
    )
    m_randomBtn = m_renameCom:GetChild("randomBtn")
    m_randomBtn.onClick:Set(
        function()
            if m_randomConfig == nil then
                m_randomConfig = LocalizationMgr.GetRandomNameConfig()
            end

            m_input.text =
                m_randomConfig.name[math.random(1, #m_randomConfig.name)] ..
                m_randomConfig.animal[math.random(1, #m_randomConfig.animal)] ..
                    m_randomConfig.job[math.random(1, #m_randomConfig.job)]
            m_input.onFocusOut:Call()
        end
    )
    CommonUIUtils.SetComByVersionType(m_renameCom)
    m_renameCom.visible = true
    -- 什么都别干,老老实实改名
    CloseMainBtnsVisible()
end

-- 铁匠铺定制
function CompulsiveGuideManager:TrySetSmithyUI()
    if m_dialogCom == nil then
        return
    end

    local isSmithy, panel = ComparePanelInfo(UIInfo.SmithyUI)

    if isSmithy then
        panel:SetTipsVisible(not m_dialogCom.visible)
    end
end

-- 更新控件状态(显隐/位置等)
function CompulsiveGuideManager:UpdateState()
    if m_mainUI == nil or m_currId == 0 then
        return
    end

    if m_upgradeUIVisible then
        self:Hide()
        return
    end

    local config = GetCurrConfig()

    if nil == config then
        return ErrorHandle("UpdateState:current config is nil:" .. m_currId .. "-" .. m_currStep)
    end

    -- 是否是主界面
    if ComparePanelInfo(UIInfo.MainUI) then
        SetMainUIBtns()
    else
        CloseMainBtnsVisible()
    end

    -- 是否有对话
    m_dialogCom.visible = config.dialogId > 0
    m_dialogBg.visible = m_dialogCom.visible
    m_mainUI.mask.visible = false
    m_highlightCom.visible = false
    self:TrySetSmithyUI()

    if m_dialogCom.visible then
        -- npc名
        m_dialogCom.title = "[color=#ffdd00,#fdc824]" .. LocalizeExt(config.npcId)

        -- 图
        if self:IsCurrIdAndStep(CGID.CG1_FAKE_BATTLE, 4) then
            m_dialogCom.icon = "UIImage/CompulsiveGuide/25236_2"
        elseif config.npcId == 20932 then
            m_dialogCom.icon = ""
        else
            m_dialogCom.icon = "UIImage/CompulsiveGuide/" .. config.npcId
        end

        -- 内容
        m_dialogCom:GetChild("Text_Content").text = LocalizeExt(config.dialogId)

        if self:IsCurrIdAndStep(CGID.CG29_GOGOGO, 0) then
            m_dialogLoader.image.graphics.flip = FlipType.Horizontal
            m_dialog_T = m_dialogCom:GetTransition("Right")
            m_dialogPos_C.selectedIndex = 1
        else
            m_dialogLoader.image.graphics.flip = FlipType.None
            m_dialog_T = m_dialogCom:GetTransition("Left")
            m_dialogPos_C.selectedIndex = 0
        end

        -- 是否播放人物动画
        if m_currNpcId ~= config.npcId then
            GRoot.inst.touchable = false
            m_dialog_T:Play(
                function()
                    GRoot.inst.touchable = true
                end
            )
        end

        m_currNpcId = config.npcId
    else
        m_currNpcId = nil
    end

    -- 是否有手指tips
    if m_fingerTipsLabel and type(config.fingerTipsId) == "number" and config.fingerTipsId > 0 then
        local text = m_fingerTipsLabel:GetChild("title")
        text.width = text.initWidth
        m_fingerTipsLabel.title = LocalizeExt(config.fingerTipsId)
        text.width = text.textWidth
        text.height = text.textHeight
        m_fingerTipsLabel.size = text.size + Vector2(80, 16)
        m_fingerTipsLabel.visible = true
    end

    -- 是否有解释性组件
    if type(config.explainComIndex) == "number" and config.explainComIndex > 0 then
        TryGetAndSetExplainCom(config.explainComIndex)
    else
        TryDisposeExplainCom()
    end

    -- 是否有解释性text
    if type(config.explainText) == "number" and config.explainText > 0 then
        TryGetAndSetExplainText(LocalizeExt(config.explainText), config.itemIndex > 0)
    else
        m_explainText = DisposeUI(m_explainText)
    end

    -- 解释性text Bg
    if m_explainTextBg then
        m_explainTextBg.visible = m_explainText
    end

    if self:IsCurrIdAndStep(CGID.CG65_PVP, 1) then
        -- 改过名就不改了
        if PlayerData.Datas.UserMiscData.changeNameTimes and PlayerData.Datas.UserMiscData.changeNameTimes > 0 then
            self:SkipToStep(2)
        else
            -- 改名
            -- Stage.inst.onClick:Set(InputReqFocus)
            m_explainTextBg.visible = true
            self:ShowAndSetRenameCom()
        end
    elseif config.showNothing then
        -- 不显示任何组件,等待消息/事件回调
        self:Hide()
    elseif m_dialogCom.visible and config.path == "" then
        -- 对话&建筑(无UI挖洞)
        if type(config.buildId) == "number" and config.buildId > 0 then
            -- 建筑
            if not config.showFingerInDialog then
                -- 无手指,只移动
                m_nextStepBtn.onClick:Set(JustDoIt)
                MapManager.NewGuideFocusOnBuild(config.buildId)
            else
                -- 剧情背景
                if m_dialogBg and m_dialogBg.visible then
                    m_dialogBg.visible = false
                end

                -- 有手指,限制点击
                m_nextStepBtn.onClick:Set(FingerTween)
                HideFinger()
                m_mainUI.mask.visible = false
                m_currBuildId = config.buildId

                if m_focusCB == nil then
                    m_focusCB = GuideClickBuild
                    MapManager.NewGuideFocusOnBuild(config.buildId, GuideClickBuild)
                end
            end
        else
            m_nextStepBtn.onClick:Set(JustDoIt)
        end
    elseif m_explainCom then
        -- 解释性组件,点击跳转下一步
        m_explainCom.visible = true
        m_nextStepBtn.onClick:Set(JustDoIt)
    elseif m_explainText then
        -- 解释性文本
        m_mainUI.mask.visible = true
        m_nextStepBtn.onClick:Set(JustDoIt)
    else
        -- 常规
        m_mainUI.mask.visible = true
        m_nextStepBtn.onClick:Set(FingerTween)
        AutoAlign(m_mainUI.mask)
        ShowFinger()

        -- 高亮组件
        -- if m_dialogCom and m_highlightCom and m_dialogCom.visible then
        --     m_highlightCom.visible = true
        -- end

        -- 剧情背景
        if m_dialogBg and m_dialogBg.visible then
            m_dialogBg.visible = false
        end
    end

    -- 设置引导进度
    if config.progress then
        PlayerData.Datas.UserMiscData:C2SSetGuideProgressProto(config.progress)
    end

    self:LateCustLogic()
end

function CompulsiveGuideManager:SpecialNextPageHandler()
end

-- 下一页
function CompulsiveGuideManager:NextPage()
    if not CompulsiveGuideManager.isUnderWay or m_mainUI == nil then
        return
    end

    if GetCurrConfig(m_currId, m_currStep + 1) then
        self:SpecialNextPageHandler()
        m_currStep = m_currStep + 1
        self:Show()
    else
        self:Finish(m_currId)
    end
end

function CompulsiveGuideManager:Start(id, index)
    if Utils.GetShieldVal() then
        m_blacklist[CGID.CG110_ALL_RANKING] = true
        m_blacklist[CGID.CG65_PVP] = true
    end
    if self.isUnderWay or self:IsFinish(id) or CanNotOpen()[id] or m_blacklist[id] then
        return
    end

    self.isUnderWay = true
    MapManager.SetMapTouchEnable(false)
    MapManager.SetLockMapScale(true)
    MapManager.SetLockMapMove(true)
    TryInitBaseCom()
    m_currId = id

    if index and type(index) == "number" and index > m_currStep then
        m_currStep = index
    else
        m_currStep = 0
    end

    self:Show()
    Utils.DebugLog("Guide Start:" .. m_currId .. "-" .. m_currStep)
end

-- 完成该章节
-- id:新手引导Id
function CompulsiveGuideManager:Finish(id)
    local config = GetCurrConfig()
    self:Save(id)
    self:Reset()

    if id == CGID.CG1_FAKE_BATTLE then
        if BattleManager.curBattle then
            BattleManager.curBattle:DoContinue()
        end
    elseif id == CGID.CG10_FORMATION or id == CGID.CG30_BATTLE_SPEED_UP or id == CGID.CG270_BATTLE_SKIP then
        TrySetBattleState(false)
    elseif id == CGID.CG11_GET_HERO then
        -- 打开单抽获取猩猩游侠
        for _, hero in pairs(PlayerData.Datas.HeroData.heroMap) do
            if hero.data == self.Config.CG11HeroDataId then
                UIManager.OpenUI(
                    UIInfo.RandomCardUI,
                    nil,
                    nil,
                    SummonTab.ShowHero,
                    {{id = hero.id, data_id = hero.data, auto_disbandment = false}}
                )
                break
            end
        end
    elseif id == CGID.CG18_EQUIP or id == CGID.CG22_CHANGE_JOB then
        UIManager.CloseUI(UIInfo.HeroListUI)
    elseif id == CGID.CG26_DRAGON_AND_FOG then
        -- 移动镜头+解锁迷雾
        MapManager.showNextChapter = true
        MapManager.PlayNewChapterAni()
    --MapManager.InitBuildCfg()
    --MapManager.RefreshMapStatus()
    --MapManager.NewGuideFocusOnBuild(1101)
    end

    -- 处理连接
    if config and type(config.relay) == "table" and type(config.relay[1]) == "number" then
        local step = 0

        if config.relay[2] and type(config.relay[2]) == "number" then
            step = config.relay[2]
        end

        self:Start(config.relay[1], step)
    else
        self:Handle()
    end
    --这里记录引导
    local verType = Utils.GetVersionType()
    if verType == VersionType.TWIOS or verType == VersionType.TW then
        Utils.RecordCheckPoint(RecordEventType.GuideDoneEvent, tostring(id))
    elseif verType == VersionType.LB or verType == VersionType.LBIOS then
        Utils.AFSubmitUserData(AFEventType.TUTORIAL_COMPLETION, AFEventParamType.TUTORIAL_ID, tostring(id))

        local key = string.format("%s;%s", 
                                FBParamName.ContentID, 
                                FBParamName.Success)
        local param = string.format("%s;%s", 
                                tostring(id), 
                                "1")
        Utils.FBLogEvent(FBEventName.CompletedTutorial, key, param)
    elseif verType == VersionType.MF or verType == VersionType.MFIOS then
        Utils.MFLogEventMF(MFLogEventId.CompletedTutorial)
        Utils.MFLogEventCustom(AFEventType.TUTORIAL_COMPLETION, AFEventParamType.TUTORIAL_ID, tostring(id), 1)
        local key = string.format("%s;%s", 
                        FBParamName.ContentID, 
                        FBParamName.Success)
        local param = string.format("%s;%s", 
                        tostring(id), 
                        "1")
         Utils.MFLogEventCustom(FBEventName.CompletedTutorial, key, param, 2)
    end
end

-- 保存该章节(关键步骤)
-- id:新手引导Id
function CompulsiveGuideManager:Save(_id)
    local id = _id or m_currId

    if
        id == nil or
            (PlayerData.Datas.UserMiscData and PlayerData.Datas.UserMiscData.ClientSetting and
                PlayerData.Datas.UserMiscData.ClientSetting[id])
     then
        return
    end

    PlayerData.Datas.UserMiscData:RequestClientSetting(id, 1)

    if nil == PlayerData.Datas.UserMiscData.ClientSetting then
        PlayerData.Datas.UserMiscData.ClientSetting = {}
    end

    PlayerData.Datas.UserMiscData.ClientSetting[id] = 1
end

-- 操作开关(UI显隐+地图操作)
local function LockOperate(islock)
    if type(islock) ~= "boolean" then
        return
    end

    -- 状态锁
    m_inDelay = islock
    -- UI触摸
    GRoot.inst.touchable = not islock

    if islock then
        CompulsiveGuideManager:Hide()
    else
        -- 尝试重新显示界面
        if m_mainUI and not m_mainUI.visible and not IsSpecialPanel() then
            local config = GetCurrConfig()

            if config and ComparePanelInfo(UIInfo[config.uiInfoKey]) then
                m_mainUI.visible = true
            end
        end

        CompulsiveGuideManager:UpdateState()
    end
end

-- 显示UI
function CompulsiveGuideManager:Show()
    if m_mainUI == nil or m_inDelay then
        return
    end

    PreHandle()
    local config = GetCurrConfig()
    local transDuration = 0

    -- 动效
    if config and config.transitionName ~= "" and type(config.transitionName) == "string" then
        local ui = GetCurrUIByConfig(config.uiInfoKey)

        if ui then
            if type(config.transitionPath) == "string" and config.transitionPath ~= "" then
                ui = GetComByPath(ui, config.transitionPath, true)
            end

            local targetTrans = ui:GetTransition(config.transitionName)

            if targetTrans and targetTrans.playing then
                transDuration = targetTrans.totalDuration
                LockOperate(true)
                targetTrans:SetCallBack(
                    function()
                        LockOperate(false)

                        if targetTrans then
                            targetTrans:ClearCallBack()
                        end
                    end
                )
                return
            else
                LockOperate(false)
            end
        end
    end

    -- 无延迟/无动效,列表默认+0.3s防穿帮
    if config and config.itemIndex and config.itemIndex > 0 and config.delay == 0 then
        if config.delay == nil then
            config.delay = 0
        end

        config.delay = config.delay + 0.3
    end

    if config and type(config.delay) == "number" and config.delay > transDuration then
        LockOperate(true)
        TimerManager.waitTodo(
            config.delay,
            1,
            function()
                LockOperate(false)
            end
        )
    else
        LockOperate(false)
    end
end

-- 隐藏UI
function CompulsiveGuideManager:Hide()
    HideFinger()

    if m_mainUI then
        m_mainUI.visible = false
    end
end

-- 是否完成某引导
function CompulsiveGuideManager:IsFinish(id)
    return PlayerData.Datas.UserMiscData and PlayerData.Datas.UserMiscData.ClientSetting[id]
end

-- 检测+开启+前定制(开启顺序有意义)
function CompulsiveGuideManager:Handle()
    local currPanel = UIManager.GetCurUI()

    if ComparePanelInfo(UIInfo.BattleUI) then
        self:Start(CGID.CG30_BATTLE_SPEED_UP)
    elseif ComparePanelInfo(UIInfo.ExploreUI) then
        if self:IsCurrIdAndStep(CGID.CG100_DESERT_EXPLORE, 0) then
            self:NextPage()
        end
    elseif ComparePanelInfo(UIInfo.Formation) then
        local currConfig = GetCurrConfig()

        if
            currConfig and currConfig.uiInfoKey and currConfig.uiInfoKey == "MainUI" and currConfig.path and
                currConfig.path == "NextLevel"
         then
            self:NextPage()
        end

        if not self.isUnderWay then
            -- 能上狮子
            local targetHero = nil

            for _, heroInfo in pairs(PlayerData.Datas.HeroData.heroMap) do
                if heroInfo.configData.race == ServerSpeciesType.SHI_ZI then
                    targetHero = heroInfo
                    break
                end
            end

            if targetHero and not currPanel:CheckSameHero(targetHero) then
                self:Start(CGID.CG31_FORMATION)
            end
        end
    elseif ComparePanelInfo(UIInfo.HeroPromote) then
        self:Start(CGID.CG41_AFTER_HERO_PROMOTE)
    elseif ComparePanelInfo(UIInfo.LevelInfoUI) then
        -- 关卡界面
        if CompulsiveGuideManager.isUnderWay then
            local nextConfig = GetCurrConfig(m_currId, m_currStep + 1)

            if nextConfig and nextConfig.uiInfoKey == "LevelInfoUI" then
                JustDoIt()
            end
        end
    elseif ComparePanelInfo(UIInfo.MainUI) then
        -- self:Start(CGID.CG170_FIRE_DRAGON_NEST)
        -- self:Start(CGID.CG180_ICE_DRAGON_NEST)
        -- self:Start(CGID.CG190_SAND_DRAGON_NEST)
        -- self:Start(CGID.CG200_WIND_DRAGON_NEST)
        -- self:Start(CGID.CG240_DRAGON_BOSS)
        -- self:Start(CGID.CG250_ZQDN)
        -- self:Start(CGID.CG280_FAST_IDLE)
        -- self:Start(CGID.CG290_KFJJC)

        if self:IsFinish(CGID.CG10_FORMATION) then
            self:Start(CGID.CG11_GET_HERO)
            self:Start(CGID.CG15_REC_HANGUP_AWARD_1)
            self:Start(CGID.CG17_HERO_UPGRADE)
            self:Start(CGID.CG18_EQUIP)
            self:Start(CGID.CG19_FIGHT_2)
            self:Start(CGID.CG20_SUMMON_1)
            self:Start(CGID.CG21_SUMMON_2)
            self:Start(CGID.CG22_CHANGE_JOB)
            self:Start(CGID.CG23_FORMATION)
            self:Start(CGID.CG25_FIGHT_BOSS)
            self:Start(CGID.CG26_DRAGON_AND_FOG)

            if self:IsFinish(CGID.CG26_DRAGON_AND_FOG) then
                self:Start(CGID.CG29_GOGOGO)
                self:Start(CGID.CG40_HERO_PROMOTE)
                self:Start(CGID.CG50_GUILD)
                self:Start(CGID.CG60_CHALLENGE)
                self:Start(CGID.CG65_PVP)
                self:Start(CGID.CG70_BLACK_MARKET)
                self:Start(CGID.CG80_GUILD_ENTRUST)
                self:Start(CGID.CG90_LEADER_SPRING)
                self:Start(CGID.CG100_DESERT_EXPLORE)
                self:Start(CGID.CG110_ALL_RANKING)
                self:Start(CGID.CG300_CAMP_DUNGEON)
                self:Start(CGID.CG_TALENT)
            end
        end
    elseif ComparePanelInfo(UIInfo.HeroListUI) then
        self:Start(CGID.CG121_FIRST_LOSE)
    elseif ComparePanelInfo(UIInfo.RandomCardUI) then
        if self:IsCurrIdAndStep(CGID.CG28_SUMMON_3, 2) then
            self:NextPage()
        end
    elseif ComparePanelInfo(UIInfo.RandomCardNotice) then
        if self:IsFinish(CGID.CG26_DRAGON_AND_FOG) then
            self:Start(CGID.CG28_SUMMON_3)
        end
    end
end

function CompulsiveGuideManager:OnUIOpened(comName)
    if comName == "Login" then
        self:Reset()
        return
    end

    if self.needHideGuideUIs[comName] then
        self:Hide()
        return
    end

    self:Handle()
end

-- 跳跃关闭存在问题
function CompulsiveGuideManager:OnUIClosed(comName)
    if self.needHideGuideUIs[comName] and self.isUnderWay then
        self:Show()
    end

    self:Handle()
end

-- 匹配当前id和step
function CompulsiveGuideManager:IsCurrIdAndStep(id, step)
    return m_currId == id and m_currStep == step
end

function CompulsiveGuideManager:GetCurrId()
    return m_currId
end

function CompulsiveGuideManager:Reset()
    PreHandle()
    m_currId = 0
    m_currStep = 0
    m_inDelay = false
    TryDisposeExplainCom()
    MapManager.SetMapTouchEnable(true)
    MapManager.SetLockMapScale(false)
    MapManager.SetLockMapMove(false)
    self.isUnderWay = false
    self:Hide()
end

-- 当进入启动界面
local function onEnterBootup()
    if CompulsiveGuideManager and LevelManager.CurLevelType == LevelType.Start then
        CompulsiveGuideManager:Reset()
    end
end

-- 弹窗动画开始
function CompulsiveGuideManager:OnPopupAniStart()
    HideFinger()
    LockOperate(true)
end

-- 弹窗动画结束
function CompulsiveGuideManager:OnPopupAniComplete()
    self:UpdateState()
    LockOperate(false)
end

-- 上阵英雄成功(弃用)
function CompulsiveGuideManager:OnEquipHero(hero1Id, hero2StanceId)
    if
        (hero2StanceId == 1 and self:IsCurrIdAndStep(CGID.CG10_FORMATION, 2)) or
            (hero2StanceId == 2 and self:IsCurrIdAndStep(CGID.CG10_FORMATION, 3)) or
            (hero2StanceId == 3 and self:IsCurrIdAndStep(CGID.CG19_FIGHT_2, 2)) or
            (hero2StanceId == 4 and self:IsCurrIdAndStep(CGID.CG23_FORMATION, 1))
     then
        self:NextPage()
    end
end

-- 战前准备结束
function CompulsiveGuideManager:OnBattleReady()
    if self:IsCurrIdAndStep(CGID.CG10_FORMATION, 5) or self:IsCurrIdAndStep(CGID.CG30_BATTLE_SPEED_UP, 0) then
        TrySetBattleState(true)
        self:NextPage()
    end
end

-- 关闭单抽UI
function CompulsiveGuideManager:CloseOneCardUI()
    if ComparePanelInfo(UIInfo.RandomCardUI) then
        self:Start(CGID.CG21_SUMMON_2, 1)

        if self:IsFinish(CGID.CG21_SUMMON_2) and not self:IsFinish(CGID.CG22_CHANGE_JOB) then
            UIManager.CloseUI(UIInfo.RandomCardUI)
        end
    end
end

-- 跳转页数
function CompulsiveGuideManager:SkipToStep(step)
    if type(step) ~= "number" or GetCurrConfig(m_currId, step) == nil then
        return
    end

    m_currStep = step
    self:Show()
end

-- 英雄升级成功
function CompulsiveGuideManager:UpdateHeroSuccess(level)
    if ComparePanelInfo(UIInfo.HeroInfoUI) then
        if m_currId == CGID.CG17_HERO_UPGRADE then
            if level < 5 then
                self:SkipToStep(3)
            end
        end
    end
end

-- 玩家升级界面状态变更(显隐)
function CompulsiveGuideManager:UpgradeUIOnChanged(visible)
    m_upgradeUIVisible = visible

    if visible then
        self:Hide()
    else
        if self.isUnderWay then
            self:Show()
        end

        self:Handle()
    end
end

-- 龙出场表现结束
function CompulsiveGuideManager:OnDragonShowEnd()
    self:Start(CGID.CG1_FAKE_BATTLE)
    self:Save(CGID.CG1_FAKE_BATTLE)
end

-- 继续第一个引导
function CompulsiveGuideManager:FakeBattleGuideNextPage()
    if m_currId == CGID.CG1_FAKE_BATTLE then
        self:NextPage()
    end
end

-- 解锁地图动画播放开始
function CompulsiveGuideManager:UnlockMapTweenOnStart()
    if m_mainUI and self.isUnderWay then
        GRoot.inst.touchable = false
        self:Hide()
    end
end

-- 解锁地图动画播放完成
function CompulsiveGuideManager:UnlockMapTweenOnComplete()
    self:Start(CGID.CG62_COLLECT_TASK_PRIZE)
end

-- GM完成当前引导
function CompulsiveGuideManager:GMFinishCurrGuide()
    if m_currId == CGID.CG1_FAKE_BATTLE then
        BattleManager.curBattle:Exit()
    end

    self:Finish(m_currId)
end

-- GM完成所有引导
function CompulsiveGuideManager:GMFinishAllGuide()
    if m_currId == CGID.CG1_FAKE_BATTLE then
        BattleManager.curBattle:Exit()
    end

    for _, id in pairs(CGID) do
        self:Save(id)
    end

    self:OnDestroy()
end

function CompulsiveGuideManager:ReloginSuccess()
    if self.isUnderWay and CanNotOpen()[m_currId] then
        self:NextPage()
    end
end

function CompulsiveGuideManager:SetDownloadVisible(visible)
    if type(visible) ~= "boolean" or not self.isUnderWay or m_mainUI == nil or m_downloadBtn == nil then
        return
    end

    m_downloadBtn.visible = visible
end

local function OnSuccess(texture)
    --    Utils.DebugLog("preload success", texture)
end

local function OnFail(error)
    --    Utils.DebugLog(error)
end

function CompulsiveGuideManager:Preload()
    CS.LPCFramework.TextureManager.GetTexture("UIImage/CompulsiveGuide/20528", OnSuccess, OnFail)
end

-- 初始化
function CompulsiveGuideManager:Init()
    EventDispatcher:Add(Event.LOADING_COMPLETE, onEnterBootup)
    -- EventDispatcher:Add(Event.FORMATION_EQUIP_HERO_CHANGE, self.OnEquipHero, self)
    EventDispatcher:Add(Event.BATTLE_PREANIM_BEFORE_READY, self.OnBattleReady, self)
    EventDispatcher:Add(Event.SHOWED_UI, self.OnUIOpened, self)
    EventDispatcher:Add(Event.OPENED_UI, self.OnUIOpened, self)
    EventDispatcher:Add(Event.CLOSED_UI, self.OnUIClosed, self)
    EventDispatcher:Add(Event.POPUP_ANIMATION_START, self.OnPopupAniStart, self)
    EventDispatcher:Add(Event.POPUP_ANIMATION_COMPLETE, self.OnPopupAniComplete, self)
    EventDispatcher:Add(Event.ON_ONE_CARD_UI_HIDE, self.CloseOneCardUI, self)
    EventDispatcher:Add(Event.UPGRADE_HERO_SUCCESS, self.UpdateHeroSuccess, self)
    EventDispatcher:Add(Event.REFRESH_BUILD_STATE, self.Handle, self)
    EventDispatcher:Add(Event.UPGRADE_UI_STATE_ON_CHANGED, self.UpgradeUIOnChanged, self)
    EventDispatcher:Add(Event.RELOGIN_SUCCEED, self.ReloginSuccess, self)
    EventDispatcher:Add(Event.SET_DOWNLOAD_UI_VISIBLE, self.SetDownloadVisible, self)
    EventDispatcher:Add(Event.START_INIT_SETTING, self.Preload, self)
    EventDispatcher:Add(Event.BATTLE_GUIDE_DRAGON_SHOW_OK, self.OnDragonShowEnd, self)
    EventDispatcher:Add(Event.BATTLE_GUIDE_DRAGON_ATTACK, self.FakeBattleGuideNextPage, self)
    EventDispatcher:Add(Event.BATTLE_GUIDE_3_ROUND_START, self.FakeBattleGuideNextPage, self)
    EventDispatcher:Add(Event.BATTLE_GUIDE_DRAGON_FLY_OVER, self.FakeBattleGuideNextPage, self)
    EventDispatcher:Add(Event.UNLOCK_MAP_TWEEN_ON_COMPLETE, self.UnlockMapTweenOnComplete, self)
end

-- 销毁
function CompulsiveGuideManager:OnDestroy()
    if CommonUIUtils then
        m_fingerEffWrapper = CommonUIUtils.ClearUIEff(m_fingerEffWrapper)
        m_focusEffWrapper = CommonUIUtils.ClearUIEff(m_focusEffWrapper)
    end

    m_fingerCom = DisposeUI(m_fingerCom)
    m_fingerTipsLabel = nil
    self:Reset()
    ClearUIEvent(m_nextStepBtn)
    m_nextStepBtn = nil
    ClearUIEvent(m_settingBtn)
    m_settingBtn = nil
    ClearUIEvent(m_downloadBtn)
    m_downloadBtn = nil
    ClearUIEvent(m_downloadBtn_C, "onChanged")
    m_downloadBtn_C = nil
    m_fakeBtn = nil
    m_dialogCom = nil
    m_dialog_T = nil
    m_dialogPos_C = nil

    if not Utils.uITargetIsNil(m_dialogLoader) then
        m_dialogLoader.icon = ""
    end

    m_dialogLoader = nil
    m_explainCom = DisposeUI(m_explainCom)
    m_explainText = DisposeUI(m_explainText)
    m_explainTextBg = nil
    m_dialogBg = nil
    m_highlightCom = nil
    ClearUIEvent(m_renameBtn)
    m_renameBtn = nil
    ClearUIEvent(m_randomBtn)
    m_randomBtn = nil
    m_randomConfig = nil
    ClearUIEvent(m_input, "onFocusOut")
    m_input = nil
    m_renameCom = nil
    m_blackEdge_C = nil
    m_mainUI = DisposeUI(m_mainUI)
    m_currBuildId = nil
    m_upgradeUIVisible = nil
    m_currNpcId = nil
    m_focusCB = nil
    EventDispatcher:Remove(Event.LOADING_COMPLETE, onEnterBootup)
    -- EventDispatcher:Remove(Event.FORMATION_EQUIP_HERO_CHANGE, self.OnEquipHero, self)
    EventDispatcher:Remove(Event.BATTLE_PREANIM_BEFORE_READY, self.OnBattleReady, self)
    EventDispatcher:Remove(Event.SHOWED_UI, self.OnUIOpened, self)
    EventDispatcher:Remove(Event.OPENED_UI, self.OnUIOpened, self)
    EventDispatcher:Remove(Event.CLOSED_UI, self.OnUIClosed, self)
    EventDispatcher:Remove(Event.POPUP_ANIMATION_START, self.OnPopupAniStart, self)
    EventDispatcher:Remove(Event.POPUP_ANIMATION_COMPLETE, self.OnPopupAniComplete, self)
    EventDispatcher:Remove(Event.ON_ONE_CARD_UI_HIDE, self.CloseOneCardUI, self)
    EventDispatcher:Remove(Event.UPGRADE_HERO_SUCCESS, self.UpdateHeroSuccess, self)
    EventDispatcher:Remove(Event.REFRESH_BUILD_STATE, self.Handle, self)
    EventDispatcher:Remove(Event.UPGRADE_UI_STATE_ON_CHANGED, self.UpgradeUIOnChanged, self)
    EventDispatcher:Remove(Event.RELOGIN_SUCCEED, self.ReloginSuccess, self)
    EventDispatcher:Remove(Event.SET_DOWNLOAD_UI_VISIBLE, self.SetDownloadVisible, self)
    EventDispatcher:Remove(Event.START_INIT_SETTING, self.Preload, self)
    EventDispatcher:Remove(Event.BATTLE_GUIDE_DRAGON_SHOW_OK, self.OnDragonShowEnd, self)
    EventDispatcher:Remove(Event.BATTLE_GUIDE_DRAGON_ATTACK, self.FakeBattleGuideNextPage, self)
    EventDispatcher:Remove(Event.BATTLE_GUIDE_3_ROUND_START, self.FakeBattleGuideNextPage, self)
    EventDispatcher:Remove(Event.BATTLE_GUIDE_DRAGON_FLY_OVER, self.FakeBattleGuideNextPage, self)
    EventDispatcher:Remove(Event.UNLOCK_MAP_TWEEN_ON_COMPLETE, self.UnlockMapTweenOnComplete, self)
end

-- LocalizeExt(20501)
-- LocalizeExt(20502)
-- LocalizeExt(20590)
-- LocalizeExt(20597)
-- LocalizeExt(20600)
-- LocalizeExt(20601)
-- LocalizeExt(25264)
-- LocalizeExt(25265)

return CompulsiveGuideManager
