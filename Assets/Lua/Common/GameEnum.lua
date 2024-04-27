local GameEnum = {}

----------------------------------------------------------------------
VersionType = {
    Default = 0
}

----------------------------系统-----------------------------------------------
-- 所有属性
EActorAttribute = {
    InvalidStatType = 0, -- invalid
    HP = 1; -- 最大生命值
    ATK = 2; -- 攻击
    DEF = 3; -- 防御
    ACT = 4; -- 行动力
    CRIT = 5; -- 暴击率, 万分比
    CRIT_DMG = 6; -- 暴击伤害，万分比
    HIT = 7; -- 命中率，万分比
    DODGE = 8; -- 闪避率，万分比
    RESISTANCE = 9; -- 抗性，万分比
    TENACITY = 10; -- 韧性，万分比
    PUNCTURE = 11; -- 破击率，万分比
    BLOCK = 12; -- 格挡，万分比
    ATK_SPD = 13; -- 攻速，万分比
    BUFF_HIT = 14; -- 技能命中，万分比
    STRENGTH = 15; -- 强健
    HASTE = 16; -- 急速
    ELONGATION = 17; -- 延伸
    EXPANSION = 18; -- 扩大
    EXACERBATE = 19; -- 加剧
    INIT_ACT = 20; -- 行动力增长
    MOVE_SPD = 21; -- 移动速度
    NORMAL_DAMAGE = 22; -- 普通伤害加成，万分比
    NORMAL_DAMAGE_REDUCTION = 23; -- 普通伤害减免，万分比
    SKILL_DAMAGE = 24; -- 技能伤害加成，万分比
    SKILL_DAMAGE_REDUCTION = 25; -- 技能伤害减免，万分比
    DAMAGE = 26; -- 伤害加成，万分比
    DAMAGE_REDUCTION = 27; -- 伤害减免，万分比
    ANTI_CRIT = 28; -- 抗暴率，万分比
    ANTI_CRIT_LV = 29; -- 抗暴率等级
    TENACITY_LV = 30; -- 韧性率等级
    HIT_LV = 31; -- 命中率等级
    DODGE_LV = 32; -- 闪避率等级
    BLOCK_LV = 33; -- 格挡率等级
    PUNCTURE_LV = 34; -- 破击率等级
    CRIT_LV = 35; -- 暴击率等级
    CRIT_DMG_LV = 36; -- 暴击伤害等级
    BLOCK_NUM = 37; -- 格挡值
}

--系统功能类型，用于系统解锁
GameSystemType = {
    InvalidFuncID = 0; -- 无效的功能id
    FID_AQUARIUM = 1; -- 观赏馆
    FID_IMPROVE = 2; -- 进修
    FID_FISHING = 3; -- 钓鱼
    FID_BOATS = 4; -- 游艇
    FID_LIBRARY = 5; -- 成就、图鉴
    FID_SHIPTREASURE = 6; -- 沉船探宝
    FID_DOUBLEMONEY = 7; -- 双倍收益
    FID_MOVEAD = 8; -- 广告宝箱
    FID_SHIPFISH = 9; -- 远洋捕捞
    FID_LUNCH = 10; -- 吃饭时间
}

-- 游戏系统类型
GameUISystemType = {
    Error = 0;
    Battle = 1;
    PVP = 2;
    Tower = 3;
}

-- 系统开放前的表现方式
SystemLockMode = {
    Error = 0;
    LOCK_ICON = 1; --UI锁
    HIDE = 2; -- 隐藏
    ESPECIAL = 3; --自定义处理方式
}


--万分比属性
EAttrPerMap = {
    [EActorAttribute.CRIT] = true,  -- 暴击率
    [EActorAttribute.CRIT_DMG] = true,  -- 暴击伤害
    [EActorAttribute.HIT] = true,   -- 命中率
    [EActorAttribute.DODGE] = true, -- 闪避率
    [EActorAttribute.RESISTANCE] = true,    -- 抗性
    [EActorAttribute.TENACITY ] = true, -- 韧性
    [EActorAttribute.PUNCTURE] = true,  -- 破击率
    [EActorAttribute.BLOCK] = true, -- 格挡率
    [EActorAttribute.ATK_SPD] = true,   -- 攻击速度
    [EActorAttribute.BUFF_HIT] = true,   -- 技能命中
    [EActorAttribute.NORMAL_DAMAGE] = true, -- 普通伤害加成
    [EActorAttribute.NORMAL_DAMAGE_REDUCTION] = true,   -- 普通伤害减免
    [EActorAttribute.SKILL_DAMAGE] = true,  -- 技能伤害加成
    [EActorAttribute.SKILL_DAMAGE_REDUCTION] = true,    -- 技能伤害减免
    [EActorAttribute.DAMAGE] = true,      -- 伤害加成
    [EActorAttribute.DAMAGE_REDUCTION] = true,  -- 伤害减免
    [EActorAttribute.ANTI_CRIT] = true, -- 抗暴率
}

-- 需要特殊计算的最终属性
EFinalAttrMap = {
    [EActorAttribute.CRIT] = true,  -- 暴击率
    [EActorAttribute.CRIT_DMG] = true,  -- 暴击伤害
    [EActorAttribute.HIT] = true,   -- 命中率
    [EActorAttribute.DODGE] = true, -- 闪避率
    [EActorAttribute.TENACITY ] = true, -- 韧性
    [EActorAttribute.PUNCTURE] = true,  -- 破击率
    [EActorAttribute.BLOCK] = true, -- 格挡率
    [EActorAttribute.ANTI_CRIT] = true, -- 抗暴率
}

-- 登录状态
GameLoginState = {
    None = -1,
    Init = 0, -- 初始化
    InitSDK = 1, -- 初始化sdk
    ConnectLoginServer = 2, -- 登录服HTTP连接中
    ConnectLoginServerSuccess = 3,  --登录服HTTP登录成功
    InLogin = 4, -- 游戏服登陆中
    LoginSuccess = 5, -- 游戏服登录成功
    LoginGameServer = 6 --正在请求玩家数据
}

--UI 系统类型
EUIType = {
    Actor = 0, -- 主角
    Hero = 1, -- 战魂
    BattleMain = 2, -- 主战斗界面
    Backpack = 3, -- 背包
    Summon = 4, -- 召唤
    SoulFormation = 5, --战魂阵容
    HeroInfo = 6, --战魂信息
    HeroTeam = 7, --战魂队伍
}

OnlineBoxType = {
    InvalidOnlineBoxType = 0,-- 非法的在线宝箱类型
    OBT_SMALL = 1, -- 小宝箱
    OBT_BIG = 2, -- 大宝箱
    OBT_PRIZE = 3, -- 奖励宝箱
}

-- 聊天tab类型
ChatTabType = {
    TYPE_WORLD = 0, -- 世界
    TYPE_GUILD = 1, -- 部落
    TYPE_QIECUO = 2, -- 切磋
    TYPE_PRIVATE = 3 -- 私聊
}

-- 聊天频道
ChatType = {
    InvalidChatType = 0, -- 无效的
    WORLD = 1, -- 世界
    GUILD = 2, -- 公会
    BATTLE = 3, -- 战斗
    PRIVATE = 4 -- 私聊
}

-- 聊天内容
ChatContentType = {
    InvalidChatContentType = 0, -- 非法的聊天内容类型
    CCT_NORMAL = 1 -- 普通聊天，读取 cotent, params，跟之前一样
}

-- 聊天超链接类型
ChatLinkType = {
    NONE = -1,
    CHAT_EMOJI = 1, -- 聊天表情
    CHAT_AT = 2 -- @
}

-- 功能开发类型
FuncType = {
    Type_Invalid = 0, -- 无效的功能类型
    FT_CHALLENGE = 1, -- 挑战
    FT_HEISHI = 2 -- 黑市
}

-- 头像类型
EHeadComType = {
    --Trig = 1,
    Circle = 2,
    Side = 1,
    End = 3
}

-- 头像名称
EHeadFrameName = {
    Circle = "圆形",
    Side = "方形"
}

-- 货币类型
CurrencyTypeName = {
    Exp = {id = 1, etype = "exp"}, -- 用于升级玩家经验
    Gold = {id = 2, etype = "gold"}, -- 金币
    Diamond = {id = 3, etype = "diamond"}, -- 钻石
    PvpTicket = {id = 4, etype = "ticket"},-- 竞技场入场券
}

-- Tips相对方位
RelativeDir = {
    Up = 1,
    RightUp = 2,
    Right = 3,
    RightDown = 4,
    Down = 5,
    LeftDown = 6,
    Left = 7,
    LeftUp = 8,
    Middle = 9
}

-- 品质
Quality = {
    InvalidQuality = 0, -- 无效的
    DQ_B = 1, -- B
    DQ_A = 2, -- A
    DQ_S = 3, -- S
    DQ_SS = 4 -- SS
}

-- 装备类型
EquipPartType = {
    InvalidEquipPartType = 0, -- 非法的装备类型
    WU_QI = 1, -- 武器
    TOU_KUI = 2, -- 头盔
    YI_FU = 3, -- 衣服
    KU_ZI = 4, -- 裤子
    XIE_ZI = 5, -- 鞋子
    SHOU_TAO = 6, -- 手套
    SHI_PIN = 7 -- 饰品
}

--奖励类型
AmountType = {
    InvalidAmountType = 0,
    CURRENCY = 1, -- 货币，上方的id去货币表里面读取
    HERO = 2, -- 英雄，上方的id去英雄表里面读取
    EQUIP = 3, -- 装备
    USABLE_ITEM = 4, -- 可使用的道具
    GEM = 5, -- 宝石
}

-- 查看英雄信息类型
HeroInfoShowType = {
    TYPE_HERO_LIST = 0, -- 英雄列表(自己拥有，可左右切换，可操作)
    TYPE_COLLECTION = 1, -- 英雄图鉴(自己未获得的)HeroDataProto(职业标签不显示new)
    TYPE_SEE_HERO_INS = 2, -- 查看单个英雄 HeroProto（不可操作）(职业标签不显示new)
    TYPE_SEE_SINGLE_HERO = 3, -- 查看单个英雄 HeroProto（可操作）
    TYPE_SEE_MONSTER = 4, -- 查看怪物 MonsterLayoutProto（不可操作） (职业标签不显示new)  
    TYPE_SEE_FIGHT_HERO = 5, -- 查看战斗中英雄怪物 FightHeroProto（不可操作） (职业标签不显示new)  
    TYPE_SEE_SINGLE_DATA_HERO = 6, -- 查看单个配置英雄 HeroDataProto（0星满级）(职业标签不显示new) 
    TYPE_SEE_SINGLE_HERO_InTeam = 7, -- 查看单个英雄 HeroProto（可操作）
    TYPE_SEE_HERO_SIMULATION = 8, -- 模拟转职专用 HeroProto（data:当前的dataid，可模拟转职，不可培养）
    TYPE_SEE_HERO_SIMULATION_2 = 9, -- 模拟转职专用 HeroProto（data:当前的dataid，可模拟转职，不可培养, 只显示属性页签，其他不显示）
    TYPE_SEE_HERO_IN_CROSS = 11 -- 不可操作，可以切换职业（data:当前的dataid）
}

-- 英雄信息 tab类型
HeroTabType = {
    TYPE_NONE = -1, -- 无效
    TYPE_ATTRI = 0, -- 属性
    TYPE_ARMOR = 1, -- 武器
    TYPE_TALENT = 2,-- 天赋
    TYPE_SKIN = 3   -- 皮肤
}

-- 界面显示的属性及顺序
ShowAttributes = {
    EActorAttribute.HP, -- 最大生命
    EActorAttribute.ATK, -- 攻击
    EActorAttribute.DEF, -- 防御
    EActorAttribute.CRIT, -- 暴击率,万分比
    EActorAttribute.ACT, -- 行动力
}

UpStarShowAttributes = {
    EActorAttribute.HP, -- 最大生命
    EActorAttribute.ATK, -- 攻击
    EActorAttribute.DEF, -- 防御
    EActorAttribute.DAMAGE,
    EActorAttribute.DAMAGE_REDUCTION,
    EActorAttribute.HIT,
    EActorAttribute.DODGE,
    EActorAttribute.PUNCTURE,
    EActorAttribute.BLOCK,
    EActorAttribute.CRIT, -- 暴击率,万分比
    EActorAttribute.ANTI_CRIT,
    EActorAttribute.CRIT_DMG,
    EActorAttribute.TENACITY,
}

-- 职业类型
RaceType = {
    InvalidRaceType = 0,
    ZHAN_SHI = 1, -- 战士
    FA_SHI = 2, -- 法师
    GONG = 3, -- 游侠
    CI_KE = 4, -- 刺客
    ZHI_LIAO = 5, -- 牧师
    MU_TOU = 6 -- 木头
}

--出战战魂类型
TeamHeroType = {
    InvalidTeamHeroType = 0,
    THT_MAIN = 1, -- 主战战魂
    THT_ASSIST = 2, -- 助战战魂
}

--物品
UsableItemType = {
    InvalidUsableItemType = 0, -- 非法道具类型
    UIT_HP = 1, -- 加血包
    UIT_HERO_EXP = 2; -- 战魂加血包
    UIT_GIFT = 3; -- 奖励包
    UIT_RANDOM_GIFT = 4; -- 随机奖励包
    UIT_EQUIP_STAR_EXP = 5; -- 装备升星矿石
    UIT_GIFT_BY_DUNGEON = 6; -- 跟副本挂钩的奖励包
    UIT_RANDOM_EQUIP = 7; -- 装备随机包
    UIT_HERO_CHIP = 8; -- 战魂契约
    UIT_TIME_SPEED_UP = 9; --时间加速药水
    UIT_CHANGE_NAME = 10; --改名卡
}

-- 宝石种类
GemClass = {
    InvalidGemClass = 0; -- 非法的属性类型
    GC_ATK = 1; -- 攻击宝石
    GC_DEF = 2; -- 防御宝石
    GC_HP = 3; -- 生命宝石
    GC_CRIT = 4; -- 暴击宝石
    GC_ANTI_CRIT = 5; -- 抗暴宝石
    GC_CRIT_DMG = 6; -- 爆伤宝石
    GC_TENACITY = 7; -- 韧性宝石
    GC_PUNCTURE = 8; -- 破击宝石
    GC_BLOCK = 9; -- 格挡宝石
    GC_PASSIVE_SKILL = 10; -- 被动技能宝石
    GC_SKILL = 11; -- 主动技能宝石
}

-- 背包类型
BackpackType = {
    InvalidPackType = 0,
    Equip = 1,      -- 装备
    Contract = 2,   -- 契约
    Item = 3,      -- 用品
    Gem = 4,      -- 宝石
}

-- 邮件类型
MailType = {
    MT_NORMAL = 0 -- 普通邮件
}

-- 技能类型
EquipSkillType = {
    InvalidSkillType = 0;
    ST_ATTACK = 1, -- 基础技能，普通攻击技能
    ST_CD = 2, -- cd技能
    ST_ACT = 3, -- 蓄力技能，行动力满就释放
    ST_PASSIVE = 4, -- 被动技能
}
-- 任务tab类型
TaskTabType = {
    DailyActive = 0, -- 每日任务
    WeeklyActive = 1, -- 每周任务
    MainTask = 2 -- 主线
}
-- 任务类型
TaskType = {
    Error = 0,
    MainTask = 1, -- 主线
    BranchTask = 2, --分支
    DailyActive = 3, -- 每日任务
    WeeklyActive = 4, -- 每周任务
}
TaskTargetType={
    InvalidTaskTargetType = 0, -- 非法的任务达成条件
    TTT_LV = 1, -- 主角等级达
    TTT_POWER = 2, -- 战力到达
    TTT_EQUIP_STAR = 3, -- 装备星级达到
    TTT_HERO_LV = 4, -- 战魂等级到达
    TTT_HERO_STAR = 5, -- 战魂星级达到
    TTT_GEM_LV = 6, -- 战魂等级达到
    TTT_SERVER_DAY = 7, -- 开服N日达成
    TTT_USER_CREATE_DAY = 8, -- 创角N日达成
    TTT_ONLINE_TIME_DAY = 9, -- 当日在线时长达到N秒
    TTT_ONLINE_TIME = 10, -- 累计在线时长达到N秒
    TTT_TASK_DONE = 11, -- 完成任务
    TTT_KILLED_MONSTER_DAY = 12, -- 当日累计击杀小怪
    TTT_KILLED_BOSS_DAY = 13, -- 当日累计击杀boss
    TTT_KILLED_MONSTER = 14, -- 累计击杀小怪
    TTT_KILLED_BOSS = 15, -- 累计击杀boss
    TTT_DUNGEON = 16, -- 通关N层副本
}

QianDaoType = {
    InvalidQianDaoType = 0,
    QDT_NORMAL = 1, -- 普通签到
    QDT_ADVANCE = 2, -- 高级
    QDT_ZHI_ZUN = 3 -- 至尊
}

-- 广告类型
AdsAwardType = {
    InvalidAdsAwardType = 0, -- 非法的奖励类型
    OnlineBox = 1,--在线奖励
    GemDungeon = 2,--宝石副本
    Summon = 3,--抽卡
    BackpackAddSize = 4,--背包开格子
    OnhookReward = 5,--挂机奖励
    Sweep = 6,--扫荡

    SignInGetPrize = 12, -- 签到领奖
    SignInBuQian = 13, -- 补签
}

TipMsgType = {
    WAIT = 0,  --默认模式，如果有消息正在显示中，则加入等待队列
    COVER = 1, --覆盖模式，如果有消息正在显示中，则清除当前消息和队列中的消息，显示当前消息
}

--竞技场类型
PvpType = {
    SignlePvp = 1,
    Tianti = 2,
    Ryjjc = 3,
    Ryjs = 4,
    Shop = 5,
}

--竞技场打开
PvpShowType = {
    Main = 0, --默认主界面
    Result = 1, --结算界面
    Record = 2 --记录
}


-- 排行榜类型
RankType = {
	InvalidRankType = 0, -- 无效的
	RANK_DUNGEON = 1, -- 关卡
	RANK_ARENA = 2, -- 竞技场
	RANK_TOWER = 3, -- 爬塔
}

TeamType = {
    InvalidTeamType = 0;
    TT_DUNGEON = 1; -- 地牢队伍
    TT_GEM_BOSS = 2; -- 宝石副本队伍
}

GemType = {
    InvalidGemType = 0; -- 非法的宝石类型
    GT_CIRCLE = 1; -- 圆形
    GT_TRIANGLE = 2; -- 三角
    GT_RHOMB = 3; -- 菱形
    GT_HEXAGON = 4; -- 六角
}
return GameEnum
