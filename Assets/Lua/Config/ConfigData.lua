--服务器下发的数据配置
local ConfigData = {}
ConfigData.vsn = nil --新的配置版本
ConfigData.config = nil
ConfigData.GlobalData = nil
ConfigData.LastMem = nil
ConfigData.actorMap = nil
ConfigData.headConfigMap = nil
ConfigData.currencyTypeMap = nil
ConfigData.equipDataMap = nil
ConfigData.equipSuitDataMap = nil
ConfigData.equipSlotStarDataMap = nil
ConfigData.equipEchoDataMap = nil
ConfigData.gemDataMap = nil
ConfigData.gemLvDataMap = nil
ConfigData.allAttrMap = nil
ConfigData.showAttributes = nil
ConfigData.monsterMap = nil
ConfigData.dungeonMap = nil
ConfigData.skillMap = nil
ConfigData.actorInitStatMap = nil
ConfigData.actorLvTotalStatMap = nil
ConfigData.summonDataMap = nil
ConfigData.heroDataConfig = nil
ConfigData.skillConfig = nil
ConfigData.skillCondConfig = nil
ConfigData.heroSpeciesConfig = nil
ConfigData.levelConfigs = nil
ConfigData.starConfigs = nil
ConfigData.heroQualityConfig = nil
ConfigData.actorShowAttributes = nil    -- 主角显示属性
ConfigData.heroShowAttributes = nil     -- 战魂显示属性
ConfigData.monstherShowAttributes = nil -- 怪物显示属性
ConfigData.mainShowAttributes = nil     -- 主角面显示属性
ConfigData.equipShowAttributes = nil    -- 装备显示属性
ConfigData.useItemDataMap = nil    -- 道具
ConfigData.taskDataMap = nil            -- 任务配置
ConfigData.OnlineBoxMap = nil --在线宝箱配置
ConfigData.FuncOpenMap = nil --功能开启配置
ConfigData.GemBossMap = nil --宝石副本
ConfigData.GemBossDropMap = nil --宝石副本掉落配置
ConfigData.StoryDatas = nil --剧情对话配置
ConfigData.towerMap = nil --爬塔配置
ConfigData.fishConfig = Utils.LoadConfig("Config.FishConfig") --鱼配置
ConfigData.seaConfig = Utils.LoadConfig("Config.SeaConfig") --海域配置
ConfigData.miscConfig = Utils.LoadConfig("Config.MiscConfig") --杂项配置
ConfigData.adminConfig = Utils.LoadConfig("Config.AdminConfig") --管理配置
ConfigData.bufferConfig = Utils.LoadConfig("Config.BufferConfig") --Buffer配置
ConfigData.taskConfig = Utils.LoadConfig("Config.TaskConfig") --任务配置
ConfigData.achievementConfig = Utils.LoadConfig("Config.AchievementConfig") --成就配置
ConfigData.mainTaskConfig = Utils.LoadConfig("Config.MainTaskConfig") --主线任务配置
ConfigData.guideStoryConfig = Utils.LoadConfig("Config.GuideStoryConfig")
ConfigData.aquariumConfig = Utils.LoadConfig("Config.AquariumConfig")

pb = require "lib.protobuf"

function ConfigData:ctor()
    --EventDispatcher:Add(Event.LOGIN_SUCCEED,self.C2SGetConfig,self)
end
-------------------------------- 需要登陆时初始化的数据 ---------------------------------------------
-- 属性相关（所有）
local function GetStatTypeDesc()
    ConfigData.allAttrMap = {}
    for _, v in ipairs(ConfigData.config.stat_type_desc_datas) do
        ConfigData.allAttrMap[v.type] = {
            ["type"] = v.type,
            ["name"] = v.name,
            ["desc"] = v.desc,
            ["icon"] = v.icon,
            ["actorShow"] = v.show,
            ["heroShow"] = v.hero_show,
            ["monsterShow"] = v.monster_show,
            ["mainShow"] = v.main_show,
            ["equipShow"] = v.equip_show,
        }
    end
end

-- 需要显示的属性
local function NeedShowAttribute()
    ConfigData.actorShowAttributes = {}
    ConfigData.heroShowAttributes = {}
    ConfigData.monstherShowAttributes = {}
    ConfigData.mainShowAttributes = {}
    ConfigData.equipShowAttributes = {}
    for attrType, attrCfg in pairs(ConfigData.allAttrMap) do
        if attrCfg.actorShow then
            table.insert(ConfigData.actorShowAttributes, attrCfg)
        end

        if attrCfg.heroShow then
            table.insert(ConfigData.heroShowAttributes, attrCfg)
        end

        if attrCfg.monsterShow then
            table.insert(ConfigData.monstherShowAttributes, attrCfg)
        end

        if attrCfg.mainShow then
            table.insert(ConfigData.mainShowAttributes, attrCfg)
        end

        if attrCfg.equipShow then
            table.insert(ConfigData.equipShowAttributes, attrCfg)
        end
    end
end

----------------------------------------- Server ----------------------------------------------------------

-- 备用方案
local function LoadLocalConfig()
    local config = ResourceMgr:LoadLua("LocalConfig",false,false,false)
    local t1 = Time.realtimeSinceStartup
    --local unzipbytes = LuaUtils.Decompress(config)

    local cfg = pb.decode("shared_Config", config)

    local t2 = Time.realtimeSinceStartup
    Utils.DebugLog("Config 解析时间1 %s", tostring(Time.realtimeSinceStartup - t1))
    ConfigData.config = cfg
    Utils.DebugLog("readconfig--0")
    GetStatTypeDesc()
    Utils.DebugLog("readconfig--1")
    NeedShowAttribute()
    Utils.DebugLog("readconfig--2")
    Utils.DebugLog("Config 解析时间2 %s", tostring(Time.realtimeSinceStartup - t2))
    EventDispatcher:Dispatch(Event.CONFIG_OK)
end

local savedCfgID = nil

----------------------------------------- Server End --------------------------------------------------------

-- --------------------------------------------------------------钓鱼配置

-- Buffer
function ConfigData:GetBufferById(id)
    return self.bufferConfig.BuffersByID[id]
end

-- 双倍奖励
function ConfigData:GetDoubleReward()
    return self.miscConfig.DoubleRewardByID[1]
end

-- 离线奖励
function ConfigData:GetOfflineReward()
    return self.miscConfig.OfflineRewardByID[1]
end

-- 吃饭奖励时长
function ConfigData:GetPeriodRewardDur()
    return self.miscConfig.PeriodRewardByID[1].RewardDur
end

-- 吃饭奖励配置
function ConfigData:GetPeriodReward()
    return self.miscConfig.PeriodRewardByID[1]
end

-- 沉船探宝
function ConfigData:GetShipTreasure()
    return self.miscConfig.ShipTreasureByID
end

-- 管理营销头衔
function ConfigData:GetAdminMarketTitle(id)
    return self.adminConfig.AdminMarketTitleByID[id]
end

-- 管理营销加速冷却
function ConfigData:GetAdminMarketCd(times)
    return self.adminConfig.AdminMarketCdByID[times - 1]
end

-- 进修
function ConfigData:GetAdminTrain(id)
    return self.adminConfig.AdminTrainByID[id]
end

-- 进修科技
function ConfigData:GetTech(id)
    return self.adminConfig.TechnologyByID[id]
end

-- 任务
function ConfigData:GetTask(id)
    return self.taskConfig.TaskByID[id]
end

-- 成就任务
function ConfigData:GetAchieveTask(id)
    return self.achievementConfig.AchievementTaskByID[id]
end

-- 称号
function ConfigData:GetAchieveTitle(id)
    return self.achievementConfig.AchievementTitleByID[id]
end

-- 主线任务
function ConfigData:GetMainTask(id)
    return self.mainTaskConfig.MainTaskByID[id]
end

function ConfigData:GetAquarShowItem(id)
    return self.aquariumConfig.ShowItemsByID[id]
end

-- --------------------------------------------------------------

--查找主角
function ConfigData:FindActorById(id)
    if self.config then
        if nil == self.actorMap then
            self.actorMap = {}
            for _, actor in ipairs(self.config.actor_datas) do
                self.actorMap[actor.id] = actor
            end
        end
        return self.actorMap[id]
    end
    return nil
end

-- 根据id查找头像数据
function ConfigData:GetHeadDataById(id)
    if self.config then
        if nil == self.headConfigMapMap then
            self.headConfigMap = {}
            for _, config in ipairs(self.config.head_datas) do
                self.headConfigMap[config.id] = config
            end
        end

        return self.headConfigMap[id]
    end

    return nil
end

-- 获取玩家头像图标
function ConfigData:GetHeadIcon()
    local headCfg = self:GetHeadDataById(PlayerData.Datas.UserMiscData.headID)
    local icon = UIInfo.HeadIcon.UIImgPre .. "ui_icon_UserAvatar0" .. headCfg.head_icon
    return icon
end

-- 根据id查找货币数据(客户端表格)
-- id:CurrencyTypeProto
function ConfigData:FindCurrencyTypeById(id)
    if self.config then
        if nil == self.currencyTypeMap then
            self.currencyTypeMap = {}
            for _, config in ipairs(self.config.currencyTypes) do
                self.currencyTypeMap[config.id] = config
            end
        end

        return self.currencyTypeMap[id]
    end

    return nil
end

-- 获取主角升级经验
-- level:ActorLevelDataProto
function ConfigData:GetActorUpGradeExpConfigByLevel(actorId, level)
    if self.config then
        for _, config in ipairs(self.config.actor_level_datas) do
            if config.level == level and config.actor_id == actorId then
                return config.upgrade_exp
            end
        end
    end

	return 0
end

-- 获取主角初始属性
-- id:ActorDataProto
function ConfigData:GetActorInitAttribute(id)
    if self.config then
        if nil == self.actorInitStatMap then
            self.actorInitStatMap = {}
            for _, config in ipairs(self.config.actor_datas) do
                self.actorInitStatMap[config.id] = config.init_stat
            end
        end

        return self.actorInitStatMap[id]
    end

	return nil
end

-- 获取主角等级总属性
function ConfigData:GetActorLevelTotalAttribute(level)
    if self.config then
        if nil == self.actorLvTotalStatMap then
            self.actorLvTotalStatMap = {}
            for _, config in ipairs(self.config.actor_level_datas) do
                self.actorLvTotalStatMap[config.level] = config.upgrade_stat
            end
        end

        return self.actorLvTotalStatMap[level]
    end

    return nil
end

-- 获取装备数据
-- id:EquipDataProto
function ConfigData:GetEquipDataById(id)
    if self.config then
        if nil == self.equipDataMap then
            self.equipDataMap = {}
            for _, equipInfo in ipairs(self.config.equip_datas) do
                self.equipDataMap[equipInfo.id] = equipInfo
            end
        end

        return self.equipDataMap[id]
    end

    return nil
end

--查找角色
-- HeroDataProto
function ConfigData:GetHeroDataConfigById(id)
    if(self.config == nil)then return nil end

    if self.heroDataConfig == nil then
        self.heroDataConfig = {}

        -- shared_HeroDataProto
        for _, config in ipairs(self.config.hero_datas) do
            self.heroDataConfig[config.id] = config
        end
    end

	return self.heroDataConfig[id]
end

-- 英雄物种数据
function ConfigData:GetSpeciesConfigByType(speciesType)
    if(self.config == nil)then return nil end

    if self.heroSpeciesConfig == nil then
        self.heroSpeciesConfig = {}

        -- HeroSpeciesDataProto
        for _, config in ipairs(self.config.race_datas) do
            self.heroSpeciesConfig[config.race_type] = config
        end
    end

	return self.heroSpeciesConfig[speciesType]
end

-- 获取装备套装数据
-- level:EquipSuitDataProto
function ConfigData:GetEquipSuitDataById(id)
    if self.config then
        if nil == self.equipSuitDataMap then
            self.equipSuitDataMap = {}
            for _, cfg in ipairs(self.config.equip_suit_datas) do
                self.equipSuitDataMap[cfg.id] = cfg
            end
        end

        return self.equipSuitDataMap[id]
    end

    return nil
end

-- 获取装备槽位升星数据
-- id:EquipSlotStarDataProto
function ConfigData:GetEquipSlotStarDataById(id)
    if self.config then
        if nil == self.equipSlotStarDataMap then
            self.equipSlotStarDataMap = {}
            for _, cfg in ipairs(self.config.equip_slot_star_datas) do
                self.equipSlotStarDataMap[cfg.id] = cfg
            end
        end

        return self.equipSlotStarDataMap[id]
    end

    return nil
end

-- 获取装备共鸣数据
-- star:EquipEchoDataProto
function ConfigData:GetEquipEchoDataByStar(star)
    if self.config then
        if nil == self.equipEchoDataMap then
            self.equipEchoDataMap = {}
            for _, cfg in ipairs(self.config.equip_echo_datas) do
                self.equipEchoDataMap[cfg.star] = cfg
            end
        end
        
        return self.equipEchoDataMap[star]
    end
    
    return nil
end

-- 获取宝石数据
-- id:GemDataProto
function ConfigData:GetGemDataById(id)
    if self.config then
        if nil == self.gemDataMap then
            self.gemDataMap = {}
            for _, cfg in ipairs(self.config.gem_datas) do
                self.gemDataMap[cfg.id] = cfg
            end
        end
        
        return self.gemDataMap[id]
    end
    
    return nil
end

-- 计算装备最大属性
function ConfigData:GetEquipMinAndMaxStat(equip)
    local totalStat = ClassConfig.HeroPropClass().new()
    -- 初始最大属性
    local initStat = equip.equipData.max_stat
    totalStat:Init(initStat)

    return totalStat
end

-- 计算装备最小属性
function ConfigData:GetEquipMinAndMinStat(equip)
    local totalStat = ClassConfig.HeroPropClass().new()
    -- 初始属性
    local initStat = equip.equipData.min_stat
    totalStat:Init(initStat)

    return totalStat
end

-- 获取攻速描述
function ConfigData:GetAKTSpeedLevelDataBySpeed(atkSpeed)
    if self.config and atkSpeed then
        local cfgData = self.config.attack_speed_level_datas
        if atkSpeed >= cfgData[#cfgData].min_atk_spd_level then
            return LocalizationMgr.getServerLocStr(cfgData[#cfgData].desc)
        end

        for _, cfg in ipairs(cfgData) do
            if atkSpeed >= cfg.min_atk_spd_level and atkSpeed <= cfg.max_atk_spd_level then
                return LocalizationMgr.getServerLocStr(cfg.desc)
            end
        end
    end

    return ""
end

-- 获取装备背包格子上限
function ConfigData:GetEquipDepotMaxSize()
    if self.config then
        return self.config.equip_misc.depot_size
    end

    return 0
end

-- 获取道具背包格子上限
function ConfigData:GetItemDepotSize()
    if self.config then
        return self.config.item_misc.depot_size
    end

    return 0
end

-- 查找英雄等级数据
-- level:HeroLevelDataProto
function ConfigData:GetHeroLevelConfigByLevel(heroId, level)
    if(self.config == nil)then return nil end

    if self.levelConfigs == nil then
        self.levelConfigs = {}

        for _, config in ipairs(self.config.hero_level_datas) do
            if self.levelConfigs[config.hero_id] == nil then
                self.levelConfigs[config.hero_id] = {}
            end
            self.levelConfigs[config.hero_id][config.level] = config
        end
    end

	return self.levelConfigs[heroId][level]
end

--查找英雄星级数据
function ConfigData:GetHeroStarConfig(hero_id, star)
    if(self.config == nil)then return nil end

    for _, config in ipairs(self.config.hero_star_datas) do
        if config.hero_id == hero_id and config.star == star then
            return config
        end
    end
end

-- 根据品质获取配置
function ConfigData:GetConfigByQuality(quality)
    if self.config == nil then return nil end

    if self.heroQualityConfig == nil then
        self.heroQualityConfig = {}

        -- HeroQualityDataProto
        for _, config in ipairs(self.config.quality_datas) do
            self.heroQualityConfig[config.quality] = config
        end
    end

	return self.heroQualityConfig[quality]
end

-- 根据品质获取等级限制
function ConfigData:GetLevelLimitByQuality(quality)
    local config = self:GetConfigByQuality(quality)

    if config then
        return config.level_limit
    end

    return 0
end

function ConfigData:GetSkillConfig(skill_id)
    if self.config then
        if nil == self.skillConfig then
            self.skillConfig = {}
            for _, v in ipairs(self.config.skill_datas) do
                self.skillConfig[v.id] = v
            end
        end

        return self.skillConfig[skill_id]
    end

    return nil
end

function ConfigData:GetSkillCondConfig(condId)
    if self.config then
        if nil == self.skillCondConfig then
            self.skillCondConfig = {}
            for _, v in ipairs(self.config.skill_condition_datas) do
                self.skillCondConfig[v.id] = v
            end
        end

        return self.skillCondConfig[condId]
    end

    return nil
end
--查找怪物数据
function ConfigData:GetMonsterDataById(id)
    if(self.config)then
        if(not self.monsterMap)then
            self.monsterMap = {}
            for i, monster in ipairs(self.config.monster_datas)do
                self.monsterMap[monster.id] = monster
            end
        end
        return self.monsterMap[id]
    end
    return nil
end

--查找地牢数据
function ConfigData:GetDungeonDataById(id)
    if(self.config)then
        if(not self.dungeonMap)then
            self.dungeonMap = {}
            for i, dungeon in ipairs(self.config.dungeon_datas)do
                self.dungeonMap[dungeon.id] = dungeon
            end
        end
        return self.dungeonMap[id]
    end
    return nil
end

--查找技能配置数据
function ConfigData:GetSkillDataById(id)
    if(self.config)then
        if(not self.skillMap)then
            self.skillMap = {}
            for i, skillData in ipairs(self.config.skill_datas)do
                self.skillMap[skillData.id] = skillData
            end
        end
        return self.skillMap[id]
    end
    return nil
end

-- 根据id查找召唤数据
function ConfigData:GetSummonDataConfigById(id)
    if self.config then
        if nil == self.summonDataMap then
            self.summonDataMap = {}
            for _, cfg in ipairs(self.config.summon_datas) do
                self.summonDataMap[cfg.id] = cfg
            end
        end

        return self.summonDataMap[id]
    end

    return nil
end

--初始化本地道具配置信息
function ConfigData:InitUseItemConfigs()
    self.useItemDataMap = {}
    for i, itemData in ipairs(self.config.usable_item_datas)do
        self.useItemDataMap[itemData.id] = itemData
    end
end

--所有道具配置
function ConfigData:GetUseItemConfigs()
    if(not self.useItemDataMap)then
        self:InitUseItemConfigs()
    end
    return self.useItemDataMap
end


--道具 useItemDataMap
function ConfigData:GetUseItemDataConfigById(id)
    if(not self.useItemDataMap)then
        self:InitUseItemConfigs()
    end
    return self.useItemDataMap[id]
end

-- 初始化本地任务配置数据
function ConfigData:InitTaskDataConfig()
    self.taskDataMap = {}
    for i,itemData in ipairs(self.config.task_datas) do
        self.taskDataMap[itemData.id] = itemData
    end
end

-- 获取任务配置
function ConfigData:GetTaskDataById(id)
    if not self.taskDataMap then
        ConfigData:InitTaskDataConfig()
    end
    return self.taskDataMap[id]
end

-- 每日活跃度奖励
function ConfigData:GetDailyActiveDegreePrizeDatas()
    return self.config.task_active_degree_datas
end

-- 每周活跃度奖励
function ConfigData:GetWeeklyActiveDegreePrizeDatas()
    return self.config.weekly_active_degree_prize_datas
end

-- 成就进度奖励
function ConfigData:GetAchieveTaskProgressPrizeDatas()
    return self.config.achieve_task_progress_prize_datas
end


-- 获取邮件配置信息
function ConfigData:GetMailDataById(id)
    if self.config == nil then
        return nil
    end

    if self.mailDatasConfig == nil then
        self.mailDatasConfig = {}

        -- MailDataProto
        for _, config in ipairs(self.config.mail_datas) do
            self.mailDatasConfig[config.id] = config
        end
    end

    return self.mailDatasConfig[id]
end

-- 邮件期限
function ConfigData:GetMailDuration()
    return self.config.mail_misc.expire_duration;
end

-- vip邀请邮件
function ConfigData:GeVipMailRechargeAmount()
    return self.config.mail_misc.vip_invite_mail_need_recharge_amount;
end

-- 签到列表
function ConfigData:GetSignInList()

    local data_id = PlayerData.Datas.SignInData.SignInInfo.data_id
    return self.config.month_qian_dao_datas[data_id].qian_dao_list
end

-- 全勤奖励
function ConfigData:GetQuanQinPrize()

    local data_id = PlayerData.Datas.SignInData.SignInInfo.data_id
--    Utils.DebugError("全勤奖励")
    return self.config.month_qian_dao_datas[data_id].quan_qin_prize_list
end

-- 补签消耗
function ConfigData:GetBuQianCost()

--    Utils.DebugError("补签数据")
--    Utils.PrintProto(self.config.bu_qian_cost_datas)
    local buqianTimes = PlayerData.Datas.SignInData.SignInInfo.bu_qian_times
    for k, v in ipairs(self.config.bu_qian_cost_datas) do

        if buqianTimes < v.times then

            return v.cost.amounts[1]
        end
    end
end


-- 最低的世界聊天等级
function ConfigData:GetMinWorldChatLevel()

    return self.config.misc.min_world_chat_level
end

-- 用于加载场景前每次执行
function ConfigData:IsLoadSuccess()

end

-- 得到功能开启所需的等级要求
function ConfigData:GetFuncOpenLevel(actor,key)
    if(not self.FuncOpenMap)then
        self.FuncOpenMap = {}
        self.FuncOpenMap[1] = {}
        self.FuncOpenMap[2] = {}

        for i, levelData in ipairs(self.config.actor_level_datas)do
            if levelData.func_open~=nil then
                for _,value in ipairs(levelData.func_open) do
                    self.FuncOpenMap[levelData.actor_id][value] = levelData.level
                end
            end
        end
    end
    return self.FuncOpenMap[actor][key]
end


-- ------------------------------------------------------宝石副本相关配置
-- 初始化宝石副本配置数据
function ConfigData:InitGemBossData()
    self.GemBossMap = {}
    for i,levelData in ipairs(self.config.gem_boss_datas) do
        self.GemBossMap[levelData.id] = levelData 
    end
end


--根据boss的id返回boss数据
function ConfigData:GetGemBossDataById(id)
    if(not self.GemBossMap) then
       self:InitGemBossData() 
    end
    return self.GemBossMap[id]
end

-- 根据当前时间返回当前的boss数据
function ConfigData:GetGemBossDataByDate()
    if(not self.GemBossMap) then
        self:InitGemBossData() 
    end

    local weekDay = tonumber(TimerManager.getCurrentWeekendTime())
    for _,boss in pairs(self.GemBossMap) do

        for _,day in ipairs(boss.open_weekday) do
            if day == weekDay then
                return boss         
            end
        end
    end
    return nil
end


function ConfigData:GetGemBossDropDatas()
    return self.config.gem_boss_drop_datas[#self.config.gem_boss_drop_datas]
end

-- --------------------------------------------------------------宝石副本End

-- 根据当前排名获得奖励信息
function ConfigData:GetPvpReward(currentRank)
    for _,group in ipairs(self.config.jjc_daily_prize_datas) do
        if currentRank >= group.min_rank and currentRank <= group.max_rank then
            return group.prize
        end
    end
    return nil
end

-- 获取竞技场每日免费次数
function ConfigData:GetPvpFreeTime()
    return self.config.jjc_misc.free_times;
end



-- 获取扫荡的配置
function ConfigData:GetDungeonSweepConfig()
    return self.config.dungeon_sweep_data
end


-- 根据id获取故事剧情对话配置
function ConfigData:GetStoryConfigById(id)
    return self.guideStoryConfig.GuideStoryByID[id]
end

-- 根据id获取爬塔数据
-- id:TowerDataProto
function ConfigData:GetTowerDataById(id)
    if nil == self.towerMap then
        self.towerMap = {}
        for _, cfg in ipairs(self.config.tower_datas) do
            self.towerMap[cfg.id] = cfg
        end
    end

    return self.towerMap[id]
end

function ConfigData:Clear()
    self.vsn = nil
    self.config = nil
    self.actorMap = nil
    self.GlobalData = nil
    self.LastMem = nil
    self.headConfigMap = nil
    self.currencyTypeMap = nil
    self.equipDataMap = nil
    self.equipSuitDataMap = nil
    self.equipSlotStarDataMap = nil
    self.equipEchoDataMap = nil
    self.gemDataMap = nil
    self.gemLvDataMap = nil
    self.heroLevelMap = nil
    self.allAttrMap = nil
    self.showAttributes = nil
    self.monsterMap = nil
    self.dungeonMap = nil
    self.skillMap = nil
    self.actorInitStatMap = nil
    self.actorLvTotalStatMap = nil
    self.summonDataMap = nil
    self.heroDataConfig = nil
    self.skillConfig = nil
    self.skillCondConfig = nil
    self.heroSpeciesConfig = nil
    self.levelConfigs = nil
    self.starConfigs = nil
    self.heroQualityConfig = nil
    self.actorShowAttributes = nil
    self.heroShowAttributes = nil
    self.monstherShowAttributes = nil
    self.mainShowAttributes = nil
    self.equipShowAttributes = nil
    self.taskDataMap = nil
    self.OnlineBoxMap = nil
    self.FuncOpenMap = nil
    self.GemBossMap = nil
    self.GemBossDropMap = nil
    self.StoryDatas = nil
    self.towerMap = nil
end

return ConfigData
