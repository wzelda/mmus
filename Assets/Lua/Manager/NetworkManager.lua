----------------------------------------------------------------
-- 模块下的局部函数和变量等定义在此
----------------------------------------------------------------
local NetworkManager = { }


-- 协议错误显示格式
EMsgErrorType =
{
    NONE = 0,
    WAITING = 1,     -- 显示等待界面
    POPUPUI = 2,     -- 弹窗
}

local json = require "rapidjson"
local netHandle = require "Net.NetHandle"
local L2CNetworkManager = CS.LPCFramework.NetworkManager.Instance;
-- 登录凭证
local loginCredentials = { address = "", port = 0, token = "", key = "" }
-- 版本信息
NetworkManager.version = { platform = "dev", number = 0, }
-- 账户信息
NetworkManager.account = { id = "", passWord = "" }

NetworkManager.Token = "";
NetworkManager.loginIp = "509.lightpaw.com"
NetworkManager.loginPort = 8331
NetworkManager.loginHttpAddress = "http://192.168.0.5:7750/login"

NetworkManager.Key = nil
NetworkManager.Address = nil

local waitTimer = nil            -- 等待计时器
local waitSeconds = 15            -- 等待时间 秒

NetworkManager.isShowWaiting = nil                         -- 是否显示转圈等待界面
NetworkManager.errorShowType = EMsgErrorType.NONE            -- 错误显示类型


ReloginEventType =
{
    UNREAD_MAIL_COUNT = 1,
    CHAT_INFO = 2,
    RECENT_CONTACT_LIST = 3,
    FRIEND_LIST = 4,
    FRIEND_HAS_BOSS = 5,
}

NetworkManager.reloginEventList = {}

-- 验证客户端版本号
local function verifyClientVersion()

end

-- 下载更新包
local function downloadUpdatePack()

end

-- 解压缩更新包
local function unpackDownloadedPack()

end

-- 更新完毕，判断是否要重启游戏
local function onUpdated()

end

-- 网络状态
function NetworkManager.IsNetConnected()
    
    return netHandle.IsNetConnected()
end

-- 重连成功
function NetworkManager.ReconnectLoginSuccess()

    netHandle.ReconnectLoginSuccess()
end

function NetworkManager.ReLoginSuccess()
    NetworkManager.isShowWaiting = UIManager.ShowWaiting()
    netHandle.ReLoginSuccess()
end

function NetworkManager.IsReloginLoadSuccess()

    for k, event in pairs(NetworkManager.reloginEventList)do
        return false
    end

    return true
end

function NetworkManager.CheckReloginLoad()

    if NetworkManager.IsReloginLoadSuccess() then

        -- 登陆成功
        if nil ~= NetworkManager.checkTiemr then
            NetworkManager.checkTiemr:onComplete()
        end

        NetworkManager.ReLoginSuccess()
        EventDispatcher:Dispatch(Event.RefreshPanel)
        EventDispatcher:Dispatch(Event.RELOGIN_SUCCEED)
    end
end

function NetworkManager.CheckReloginLoadSuccess()
    if nil ~= NetworkManager.checkTiemr then
        NetworkManager.checkTiemr:onComplete()
    end
    NetworkManager.checkTiemr = TimerManager.intervalTodo(-1, 0.1, NetworkManager.CheckReloginLoad, nil, nil, true)
end

function NetworkManager.AddReloginEvent(event)

    if nil == NetworkManager.reloginEventList then

        NetworkManager.reloginEventList = {}
    end
    NetworkManager.reloginEventList[event] = true
end

function NetworkManager.RemoveReloginEvent(event)

    if nil == NetworkManager.reloginEventList then

        NetworkManager.reloginEventList = {}
    end
    NetworkManager.reloginEventList[event] = nil
end

-- 初始化
function NetworkManager.initialize()
    -- 初始化
    netHandle.initialize()
    --注册接收消息
    -- autogen.ReceiveProtoFunc = function(moduleId, msgId)
    --     EventDispatcher:Dispatch(Event.RECEIVE_MSG, moduleId, msgId)
    -- end
end

-- 销毁
function NetworkManager.onDestroy()
    -- 关闭网络连接
    netHandle.onDisconnect()
end
----------------------------------------------------------------------------------------
--------------------------------------HTTP-------------------------------------------
----------------------------------------------------------------------------------------
-- 隐藏等待
local function HideWating()

    if waitTimer then
        waitTimer:pause()
    end

    NetworkManager.isShowWaiting = UIManager.StopWaiting(NetworkManager.isShowWaiting)
end

local function ErrorTip(err)
    -- 隐藏等待
    HideWating()

    EventDispatcher:Dispatch(Event.NET_ERROR)
    -- UIManager.ShowWaiting(false)
    -- local popinfo = {}
    -- popinfo.content = err
    -- popinfo.title = "Net error"
    -- UIManager.OpenPopupUI(UIInfo.PopupUI, popinfo)
end

-- 错误返回
local errorCallBack = function(err, status)

    print(Time.time)
	Utils.DebugError("network error callback :"..err);

    if nil ~= NetworkManager.failedCallBack then

        NetworkManager.failedCallBack(err, status)
        NetworkManager.failedCallBack = nil
    else

        ErrorTip(err)
    end
end

-- 延时等待结束
local waitDelayEnd = function()
    NetworkManager.isShowWaiting = UIManager.ShowWaiting()
end

-- 延时显示等待
local function ShowWatingDelay()

    if not NetworkManager.isShowWaiting then

        return
    end

    --UIManager.ShowWaiting(true)
    if nil == waitTimer then
        waitTimer = TimerManager.newTimer(waitSeconds, false, true, nil, nil, waitDelayEnd)
    else
        waitTimer:reset()
    end

    waitTimer:start()
end

function NetworkManager.ShowWaiting()

    if not NetworkManager.isShowWaiting then
        return
    end

    NetworkManager.isShowWaiting = UIManager.ShowWaiting()
end

-- 发送http消息
-- <param name="url" type="string">url地址</param>
-- <param name="formOfBytes" type="string">参数数据（byte数组）</param>
-- <param name="successCallBack" type="string">url地址</param>
-- <param name="errorCallBack" type="string">url地址</param>
function NetworkManager.HttpPost(url, param, successCallBack, failedCallBack, showWait)

    NetworkManager.failedCallBack = failedCallBack

    L2CNetworkManager:HttpPost(url,param,successCallBack,errorCallBack);
end
----------------------------------------------------------------------------------------
--------------------------------------TCP-------------------------------------------
----------------------------------------------------------------------------------------
-- 收到TCP网络消息
-- <param name="msg" type="string">消息包体</param>
function NetworkManager.onReceiveMsg(msg)
    -- print("msg received. length", length)
    -- 隐藏等待
    --HideWating()

    local length = msg:len()
    if length == 1 then
        Utils.DebugError("enter net state:"..tostring(msg:byte(1, 1)));
        Event.dispatch(msg:byte(1, 1))
    else
        decode(msg, length)
        --Utils.DebugError(Time.realtimeSinceStartup)
    end
end

--客户端发送消息
function NetworkManager.SendMsg(msg)
    if not msg then return end

    -- 显示等待
    NetworkManager.ShowWaiting()

    CS.LPCFramework.NetworkManager.Instance:SendMessage(msg)
end

function NetworkManager.HttpPostJson(url, param, successCallback,failCallBack)
    --Utils.DebugError(Time.time)
    print(url, param)
    if(not failCallBack)then
        failCallBack = errorCallBack
    end
    L2CNetworkManager:HttpPostString(url, param, function(txt)
        local ok, obj = pcall(json.decode, txt)
        if not ok then
            failCallBack(url.." response is invalid json:"..txt)
        else
            successCallback(obj)
        end
    end, failCallBack, 5, 5)
end

function NetworkManager.HttpPostGet(url,successCallback,failCallBack,retryCount)
    --Utils.DebugError(Time.time)
    if(not failCallBack)then
        failCallBack = errorCallBack
    end
    L2CNetworkManager:HttpGetProtobuf(url,successCallback, failCallBack, retryCount)
end

function NetworkManager.HttpGetString(url,successCallback,failCallBack,retryCount, timeout)
    retryCount = retryCount or 5
    timeout = timeout or 5
    if not failCallBack then
        failCallBack = errorCallBack
    end
    L2CNetworkManager:HttpGetString(url, function (txt)
        local ok, obj = pcall(json.decode, txt)
        if not ok then
            failCallBack(url.." response is invalid json:"..txt)
        else
            successCallback(obj)
        end
    end, 
    failCallBack, retryCount, timeout)
end

-- app失焦
function NetworkManager.OnApplicationFocus(hasFocus)
    netHandle.OnApplicationFocus(hasFocus)
    EventDispatcher:Dispatch(Event.APPLICATION_FOCUS_CHANGE, hasFocus)
end


local function OnCfgOK()

    EventDispatcher:Remove(Event.CONFIG_OK, OnCfgOK)
    PlayerData.Datas.LoginData.C2SLoginGameServer()
end

function NetworkManager.ConnectDefault()
    --LoginData.C2SLoginGameServer(username)
    ConfigData:C2SReqCfgVersion()
    EventDispatcher:Add(Event.CONFIG_OK, OnCfgOK)
end

local function OnCfgOK2()
    EventDispatcher:Remove(Event.CONFIG_OK, OnCfgOK2)
    PlayerData.Datas.LoginData.NewC2SReconnectLoginMsg()
end

function NetworkManager.ReconnectAfterServerRestart()
    NetworkManager.ReconnectLoginSuccess()

    ConfigData:C2SReqCfgVersion()
    EventDispatcher:Add(Event.CONFIG_OK, OnCfgOK2)
end

return NetworkManager
