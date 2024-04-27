if CS.LPCFramework.LuaVMManager.m_luaJit or CS.LPCFramework.LuaVMManager.m_luaJit == false then
    print("23123")
    local jit = require("jit")
    jit.off()
    jit.flush()
end

local serpent = require "lib.serpent"
function _G.printt(t, depth)
    CS.UnityEngine.Debug.Log(serpent.block(t, {maxlevel=depth, nocode=true}))
end

InitModule = nil
GlobalModule = nil
PlayerPrefs = CS.UnityEngine.PlayerPrefs

-- Lua 逻辑入口
----------------------------------------------------------
local remoteDebug = PlayerPrefs.GetString("RemoteDebug")

if remoteDebug ~= nil and remoteDebug ~= "" then
    local split = string.find(remoteDebug, ":")
    local host,port
    if split then
        host = string.sub(remoteDebug, 0, split - 1)
        port = tonumber(string.sub(remoteDebug, split + 1))
    else
        host = remoteDebug
        port = 8818
    end
    print("luapanda remote "..host..":"..tostring(port))
    require("lib.LuaPanda").start(host, port)
    CS.LPCFramework.ResourceMgr.showResourceLog = true
elseif CS.UnityEngine.Application.isEditor then
    print("luapanda localhost")
    require("lib.LuaPanda").start("127.0.0.1", 8818)
    CS.LPCFramework.ResourceMgr.showResourceLog = true
end

GlobalManager = { }
GlobalManager.isRunning = false

function initialize()
    InitModule =  require "Common.InitModules"
    
    GlobalModule = require "Common.GlobalModules"
    
    GlobalManager.isRunning = true
    
    GlobalModule.LoadUtils()
    GlobalModule.LoadModule()
    --CS.UnityEngine.Application.runInBackground = ConstantValue.IsInUnityEditor
    
    InitModule.LoadModule()
end

function update()
    if TimerManager then
        TimerManager.update()        
    end

    if UIManager then
        UIManager.update()
    end
end

function fixedUpdate()
    if TimerManager then
        TimerManager.fixedUpdate()
    end

    if UIManager then
        UIManager.fixedUpdate()
    end
end

function lateUpdate()
    --local deltaTime = Time.deltaTime
end

function onReceiveMsg(msg)
    if NetworkManager then
        NetworkManager.onReceiveMsg(msg)
    end
end

function onAppFocus()
    if NetworkManager then
        NetworkManager.OnApplicationFocus(true)
    end
    if UIManager then
        UIManager.OnApplicationFocus(true)
    end
    if PlayerData then
        PlayerData:OnApplicationFocus(true)
    end
end

function onAppUnFocus()
    if NetworkManager then
        NetworkManager.OnApplicationFocus(false)
    end
    if UIManager then
        UIManager.OnApplicationFocus(false)
    end
    if PlayerData then
        PlayerData:OnApplicationFocus(false)
    end
end

function onAppPause()
    if PlayerData then
        PlayerData:OnApplicationPause(true)
    end
end

function onAppUnPause()
    if PlayerData then
        PlayerData:OnApplicationPause(false)
    end
end

function onLuaDestroy()    
    
    GlobalManager.isRunning = false
    -- GlobalManager.ReleaseBg()

    if PlayerData then
        PlayerData:Clear()
    end

    if AnalyticsManager ~= nil then
        AnalyticsManager.onDestroy()
    end
    
    if EventDispatcher ~= nil then
        EventDispatcher:Clear()
    end
    if LocalizationMgr ~= nil then
        LocalizationMgr.onDestroy()
    end

    if LevelManager ~= nil then
        LevelManager.onDestroy()
    end

    if UIManager ~= nil then
        UIManager.onDestroy()
    end

    if SDKManager ~= nil then
        SDKManager:onDestroy()
    end
end