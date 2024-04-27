-- 网络连接状态 
local NetStat = {
    None = 0,
    -- 连接中
    Connecting = 1,
    -- 连接上
    Connected = 2,
    -- 必须重新走登录流程
    MUST_RELOGIN = 3,
    -- 必须重新发起连接, 成功之后显示主城界面
    MUST_RECONNECT = 4,
    -- 客户端强制退出连接
    FROCE_CLOSED = 5,
}

-- 网络处理
local NetHandle = { }
-- 连接成功回调
local connectedInvoke = nil
-- 当前连接状态
local curStat = NetStat.None
-- 连接超时计时器
local connectTimeOutTime = nil
-- 重连次数，超过则返回登录
local reConnectCount = 0

--被封号（不能重连）
local isDisAccount = false

local connectingTime = nil

local inRestartingServer = false    -- 服务器重启中
local reconnectedLogin = false      -- 已重连服务器

local reconnectingCheckTime = nil
local connectingWaiting = nil

local function CloseWait()
    UIManager.StopWaiting(connectingWaiting)
    connectingWaiting = nil
end

local function ChangeNetState(state)
    local have = false

    if NetStat then
        for _, v in pairs(NetStat) do
            if v == state then
                have = true
                break
            end
        end
    end

    if not have then
        return
    end

    curStat = state

--[[     -- 引导
    if CompulsiveGuideManager.isUnderWay then
        GRoot.inst.touchable = state == NetStat.Connected
    end ]]
end

-- 正在连接
local function connecting()
    ChangeNetState(NetStat.Connecting)

    connectingWaiting = UIManager.ShowWaiting("connecting")
    
    -- 更新登录状态
    if nil ~= PlayerData and nil ~= PlayerData.Datas.LoginData then
        if UIManager.reConnectTimeStamp == nil then
            UIManager.reConnectTimeStamp = os.time()
        end
        
        PlayerData.Datas.LoginData:SetLoginState(false)
    end
    
    connectingTime = CS.UnityEngine.Time.realtimeSinceStartup
    if reconnectingCheckTime == nil then
        reconnectingCheckTime = connectingTime
    end
end
Event.addListener(Event.CONNECTING, connecting)

-- 多次重连未果，返回登录
local function reConnectFailure()
    
    if not reconnectedLogin and inRestartingServer then
        return
    end
    
    -- 断开连接
    NetHandle.onDisconnect()

    local retitle = LocalizeExt(20037)
    local recontent = LocalizeExt(20085)

    local OkFunc = function ()
        
        LevelManager.GoToLoginScene()
    end
    
    UIManager.StopWaiting(connectingWaiting)
    connectingWaiting = nil
    
    UIManager.OpenPopupUI(UIInfo.PopupUI, recontent, retitle, 1, OkFunc, nil, nil)
    EventDispatcher:Dispatch(Event.LOGIN_FAIL)
end
Event.addListener(Event.MUST_RELOGIN, reConnectFailure)

-- 必须重新连接
local function reConnect()
    if(isDisAccount)then --已被封号
        return
    end
    
    if LevelManager.CurrLevelConfig.Type == LevelType.Start then
        
        CloseWait()
        
        local cb = function()
            
            PlayerData.Datas.LoginData.C2SUserServerInfo()
        end

        local content = LocalizeExt(21028)      -- 服务器连接失败，请重新选择服务器进入游戏
        local title = LocalizeExt(20037)        -- 提示
        EventDispatcher:Dispatch(Event.LOGIN_COLSEWAIT)
        UIManager.OpenPopupUI(UIInfo.PopupUI, content, title, 1, cb)

        return
    end
    
    NetHandle.onDisconnect()
    ChangeNetState(NetStat.MUST_RECONNECT)
    reConnectCount = reConnectCount + 1
    -- 尝试重连次数大于3次
    if reConnectCount > 3 then
        Utils.DebugError ("多次重连失败！！")
        -- 重连失败弹框提示重新登录
        reConnectFailure()
        -- 返回
        return
    end

    -- 弹框提示是否需要发起重连，是的话发起重连，否的话回到登录
    local retitle = LocalizeExt(20037)
    local recontent = LocalizeExt(20086)
    local notitle = LocalizeExt(20087)
    local yestitle = LocalizeExt(20088)
    
    local OkFunc = function ()
        NetworkManager.ReconnectAfterServerRestart()
    end

    local NoFunc = function ()
            
        LevelManager.GoToLoginScene()
    end
    EventDispatcher:Dispatch(Event.LOGIN_COLSEWAIT)
    CloseWait()
    
    if reconnectingCheckTime ~= nil and CS.UnityEngine.Time.realtimeSinceStartup - reconnectingCheckTime > 7200 then
        --超过7200秒则直接返回登录
        UIManager.OpenPopupUI(UIInfo.PopupUI, recontent, retitle, 1,NoFunc, nil, nil,notitle)
    else
        UIManager.OpenPopupUI(UIInfo.PopupUI, recontent, retitle, 1,NoFunc, nil, nil,notitle)
        --UIManager.OpenPopupUI(UIInfo.PopupUI, recontent, retitle, 3, OkFunc, NoFunc, nil,yestitle,notitle)    
    end
end

Event.addListener(Event.MUST_RECONNECT, reConnect)

-- 已连接
local function connected()
    UIManager.reConnectTimeStamp = nil
    reconnectingCheckTime = nil
    Event.dispatch(Event.NET_SIGNAL_CLOSE)

    -- 连接结束时需要关闭菊花   
    CloseWait()

    -- 置连接状态
    ChangeNetState(NetStat.Connected)
    inRestartingServer = false
    
    -- 清连接次数
    reConnectCount = 0

    -- 连接成功回调
    if nil ~= connectedInvoke then
        print("tcp连接成功！！！")
        Utils.DebugError("tcp连接成功！！！")
        connectedInvoke()
        -- 清空
        connectedInvoke = nil
    end
end
Event.addListener(Event.CONNECTED, connected)

-- 重新登陆
local function ReconnectLogin()
    
    NetworkManager.ReconnectAfterServerRestart()
end

function NetHandle.ReconnectLoginSuccess()
    
    --inRestartingServer = false
end

function NetHandle.ReLoginSuccess()
    
    NetHandle.ReconnectLoginSuccess()
    reconnectedLogin = true
    inRestartingServer = false
end

-- 初始化
function NetHandle.initialize()
  
end

-- 请求认证登陆--
-- <param name="ip" type="string">ip地址</param>
-- <param name="port" type="number">端口</param>
-- <param name="token" type="string">认证登陆信息</param>
-- <param name="key" type="string">认证登陆信息</param>
-- <param name="callBack" type="function">登录完成回调</param>
function NetHandle.connect(ip, port, token, key, callBack)
    -- 网络不可达
    --if not CS.LPCFramework.NetworkManager.Instance.NetAvailable then
    --    
    --    reConnect()
    --
    --    return
    --end

    -- 成功回调
    connectedInvoke = callBack

    -- 断开连接
    CS.LPCFramework.NetworkManager.Instance:OnDisconnect()
    -- 重新连接
    
    CS.LPCFramework.NetworkManager.Instance:Connect(ip, port, token, key)

    print(string.format("第%d次尝试连接", reConnectCount))
end

-- 发送消息
-- <param name="msg" type="string">消息包体</param>
function NetHandle.sendMsg(msg)    
    CS.LPCFramework.NetworkManager.Instance:SendMessage(msg)
end

-- 主动断开连接
function NetHandle.onDisconnect()
    Utils.DebugError("*******NetHandle.onDisconnect******")
    
    -- 更新登录状态
    if nil ~= PlayerData and nil ~= PlayerData.Datas.LoginData then
        PlayerData.Datas.LoginData:SetLoginState(false)
    end

    -- 重置状态
    ChangeNetState(NetStat.MUST_RECONNECT)
    -- 断开连接
    CS.LPCFramework.NetworkManager.Instance:OnDisconnect()
end

-- app失焦
function NetHandle.OnApplicationFocus(hasFocus)
    -- todo
    print("hasFocus:", hasFocus, "curStat:", curStat)
    -- 当获取到焦点，并且之前已登录过，进行一次服务器时间同步
    
    if hasFocus then
        
        if curStat == NetStat.MUST_RECONNECT then
            
            Utils.DebugError("Send Must RECONNECT")

            NetworkManager.ReconnectAfterServerRestart()

        end
    end

end

-- 获取网络状态
function NetHandle.IsNetConnected()
    
    return curStat == NetStat.Connected
end

return NetHandle
