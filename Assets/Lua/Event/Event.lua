
-------------------------------------------------------------------------
------------------------------EventListener------------------------------
-------------------------------------------------------------------------

local Event = { }
 
------------------------------- 网络状态（不能动） -------------------------------

Event.CONNECTING = 1
Event.CONNECTED = 2
Event.MUST_RELOGIN = 3
Event.MUST_RECONNECT = 4
Event.RECEIVE_MSG = 6 -- 收到消息
Event.NET_ERROR = 7 -- 错误消息返回
Event.LOGIN_COLSEWAIT = 8 -- 仅在登录的时候收到网络事件隐藏Wait
Event.Net_IN_CONNECT = 9
Event.LOGIN_STOP = 10
Event.HTTP_LOGIN_SUCCESS = 11 --玩家账号登录成功
Event.TCP_CONNECT_SUCCESS = 12 --游戏服服务器登录成功
Event.APPLICATION_FOCUS_CHANGE = 13 --游戏焦点变化

------------------------------- 热更新模块（不能动） -------------------------------
Event.HotUpdateComplete = 306
Event.START_INIT_SETTING = 307

-------------------------------------------------------------------------------

Event.SELECT_SERVER = 400

------------------------------- 辅助模块(900 - 1999) ---------------------------

-- UI 加载辅助
Event.UILoadComplete = 900
-- 打开界面
Event.OPENED_UI = 901
-- 关闭界面
Event.CLOSED_UI = 902
-- 界面OnShow
Event.SHOWED_UI = 903
-- 打开tab
Event.OPENED_TAB = 904
-- 关闭tab
Event.CLOSED_TAB = 905

-- 1. 加载相关(1000 - 1099)
Event.SCENE_ENTER = 1000
Event.SCENE_EXIT= 1001
-- loading中
Event.LOADING_UPDATE = 1002
-- loading结束
Event.LOADING_COMPLETE = 1003
-- 菊花关闭
Event.SYNC_CLOSE = 1004
-- 网络新号关闭
Event.NET_SIGNAL_CLOSE = 1005
-- GM
Event.GM_REQ_CMD_LIST_SUCCESS = 1006
-- 2. 屏幕交互(1100 - 1199)
Event.STAGE_ON_CLICK = 1100
Event.STAGE_ON_TOUCH_BEGIN = 1101
Event.STAGE_ON_TOUCH_MOVE = 1102
Event.STAGE_ON_TOUCH_END = 1103

-- 相机裁剪gmtype
Event.CameraClipHero = 1150
Event.CameraClipScreen = 1151

-- UI 通用
Event.RefreshLoc = 1201
Event.RefreshPanel = 1202

-- 功能解锁
Event.OPEN_FUNC = 1203
Event.OPEN_FUNC_AFTER_UI = 1204
Event.OPEN_FUNC_ENTER_UI = 1205
Event.UNLOCK_FUNC = 0

Event.ENTER_DUNGEONPANEL = 1210
-- 弹窗动画开始
Event.POPUP_ANIMATION_START = 1211
-- 弹窗动画结束
Event.POPUP_ANIMATION_COMPLETE = 1212
-- 版本号变化
Event.CV_CHANGED = 1300
-- escape
Event.ESCAPE_CLOSE_UI = 1301

Event.PLAY_TRANSITION = 1301

Event.OPEN_BATTLE_PAGE = 1404 --打开战斗页面
Event.CLOSE_BATTLE_TAB = 1414 --关闭战斗页面


--打开通用提示框
Event.OPEN_POPUPUI = 1451
--关闭通用提示框
Event.CLOSE_POPUPUI = 1452
--关闭通用奖励页面
Event.CLOSE_PRIZE_PANEL = 1453

Event.SystemInitOver = 1500 -- 游戏初始化结束，主界面打开

-- 完成引导的单个步骤
Event.GUIDE_STEP_OVER = 1501

------------------------------- Misc(4500 - 5999) -----------------------------
-- 资源下载进度球
Event.UPDATE_DOWNLOAD_PROGRESS = 4500
Event.UPDATE_DOWNLOAD_SPEED = 4501
Event.SET_DOWNLOAD_UI_VISIBLE = 4502
Event.ACHIEVE_TASK_COLLECT_PRIZE_EFF = 4503
Event.UPDATE_TASK_LIST = 4504

-- 创建角色
Event.CREATE_ROLE = 5004
-- 创建角色成功
Event.CREATE_ROLE_SUCCEED = 5005
-- 货币变化
Event.CURRENCY_CHANGED = 5006
-- 消费货币
Event.CURRENCY_SPEND = 5007
-- 武器获得
Event.EQUIP_OBTIAN = 5009
-- 批量升级
Event.BATCH_COUNT_CHANGE = 5010
-- 钻石变化
Event.DIAMOND_GOT = 5038
-- 获得金币
Event.COIN_INCOME = 5011
-- 获得新buffer
Event.ADD_BUFFER = 5012
-- 播放货币特效
Event.PLAY_REWARD_EFFECT = 5013
-- 循环收益
Event.SHOW_INCOME = 5014
-- 钱不够还点
Event.LACK_MONEY = 0
-- 默认获取收益特效
Event.DEFAULT_MONEY_EFFECT = 0

-- 主界面Tab页切换
Event.MAIN_TAB_OPEN = 5100
Event.BOTTOM_LIST_FOLD = 5101
Event.MAIN_UI_SHOW = 5102
Event.MAIN_UI_HIDE = 5103
Event.ACHIEVE_TAB_OPEN = 5105

-- 主界面点击返回按钮
Event.MAIN_UI_RETURN = 5104

-- 重置游戏数据
Event.RESET_PLAYERDATA = 0
Event.PLAYER_INITED = 0

------------------ 主界面弹框模糊背景(5601 -- 5699) --------------
Event.SHOW_FIETER_UI = 5601
Event.CLOSE_FIETER_UI = 5602
Event.SHOW_EQUIP_UPSTAR_FILTER_UI = 5603
Event.CLOSE_EQUIP_UPSTAR_FILTER_UI = 5604

-- 更新装备new标志
Event.UPDATE_EQUIP_NEW = 5605
Event.UPDATE_EQUIP_LOCK_STATE = 5606
Event.UPDATE_EQUIP_DEPOT_SIZE = 5607

------------------------------- 观赏馆(8001-8099) -------------------------------

-- 观赏馆
Event.AQUARIUM_SHOW_ITEM = 8001
Event.AQUARIUM_LEVELUP_DECORATION = 8002
Event.DECORATION_GROWUP = 8003
Event.AQUARIUM_UNLOCK = 8004 -- 解锁场馆
Event.AQUARIUM_SWITCH = 8004 -- 切换场馆

------------------------------- 钓鱼主场景(8101-8199) -------------------------------

-- 钓鱼
Event.FISH_LEVELUP = 8101
Event.FISH_GROWUP = 8102
Event.FISH_THROW = 8103
Event.FISH_CALL_UI = 8104
Event.FISH_PLAYER_TOUCHBEGIN = 8105
Event.FISH_PLAYER_TOUCHEND = 8106
Event.FISH_CRIT_SUCCESS = 8107
Event.FISH_UPDATE_HP = 8108
Event.FISH_CRITDAMAGE = 8109
Event.FISH_UNLOCK = 8110
Event.FISH_FIGHT_END = 8111
Event.FISH_STAGE_CLICK = 8112
Event.FISH_CREATE_NORMALBOX = 8113
Event.FISH_CREATE_ADBOX = 8114
Event.FISH_STAGE_TOUCH = 8115
Event.FISH_UNLOCK_SUCCESS = 8116
Event.FISH_FISH_END = 8117
Event.FISH_RESULT = 8118
Event.ADD_FISH_EFFECT = 8119
Event.ITEMPOP_GETREWARD = 8120
------------------------------- 管理(8200-8299) -------------------------------

-- 进修
Event.ADMIN_TRAIN_SUCCESS = 8200
-- 获取收益特效到位
Event.ADMIN_EFF_END = 0
Event.ADMIN_CLOSE_BREAKUI = 0
Event.ADMIN_TECHBREAK_READY = 0
-- 进修增加提示
Event.ADMIN_ADD_INCOME = 0

-----------------------------End----------------------------------------------

------------------------------- 广告(8300-8399) -------------------------------

-- 吃饭时间
Event.AD_LUNCH_SHOW = 8300
-- 获得吃饭时间奖励
Event.AD_GET_LUNCH_REWARD = 8301
-- 收益翻倍
Event.AD_GET_DOUBLE_MONEY = 8302
Event.AD_ADDTIMES = 0

-----------------------------End----------------------------------------------

------------------------------- 主线任务+成就(8400-8499) -------------------------------

----- 成就(8400-8449)
-- 领取成就奖励
Event.GET_ACHIEVE_PRIZE = 8400
-- 领取称号奖励
Event.GET_ACHIEVE_TITLE_PRIZE = 8401
-- 称号升级
Event.UPGRADE_ACHIEVE_TITLE = 8402

----- 主线任务(8450-8499)
-- 领取主线任务奖励
Event.GET_MAIN_TASK_PRIZE = 8450
------------------------------- 远洋捕捞(8500-8599) -------------------------------
Event.SHIPFISH_GETREWAD = 8500
Event.SHIPFISH_CD_CLEAR= 8501
-----------------------------End----------------------------------------------

------------------------------- 海域 -------------------------------

-- 解锁
Event.SEA_UNLOCK = 0
Event.SEA_SWITCH = 0

-----------------------------End----------------------------------------------

-------------------------- 引导功能--------------------------------------------

-- 点击引导按钮
Event.CG_CLICK_BTN = 0
Event.CG_ENTER_MAINUI = 0
Event.CG_CANCRIT = 0
Event.CG_CRIT_SUCCESS = 0
-----------------------------End----------------------------------------------

local eventName = { }

for k, v in pairs(Event) do
    eventName[v] = k
end



function Event.addListener(etype, func)
    Utils.DebugLog("registering listener", eventName[etype])
    if etype == nil or func == nil then
        return
    end

    local a = Event[etype]
    if not a then
        a = { }
        Event[etype] = a;
    end
    table.insert(a, 1, func)
end  
  
function Event.removeListener(etype, func)
    local a = Event[etype]
    if (a == nil) then
        return
    end
    for k, v in pairs(a) do
        if (v == func) then
            a[k] = nil
        end
    end
end  

function Event.dispatch(etype, ...)
    -- print("dispatching event", eventName[etype], " thread id ", CS.System.Threading.Thread.CurrentThread.ManagedThreadId)
    local a = Event[etype]
    if not a then
        return
    end
    for k, v in pairs(a) do
        v(...)
    end
end

function Event:dispatchFunction(etype)
    return function()
        Event.dispatch(etype)
    end
end

function Event.clear(etype)
    local a = Event[etype]
    if not a then
        return
    end
    Event[etype] = nil
end  

function Event.clearAll()
    for k, v in pairs(Event) do
        Event[k] = nil
    end
end

function Event.printAllEvent()
    for k, v in pairs(Event) do
        print("##################### All Events:", k, v)
    end
end

------------------------------- 事件自动编号 -------------------------------

-- 预留99个固定编号
local index = 100
for k, v in pairs(Event) do
    if type(v) == "number" then
        Event[k] = index
        index = index + 1
    end
end

------------------------------- 事件自动编号End -----------------------------

return Event
