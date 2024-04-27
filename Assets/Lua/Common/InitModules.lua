-- 初始化的模块，里面的代码不能做热更


-- 一些全局的模块与全局变量，进入到lua逻辑时 初始化一次
--频繁使用的 C#
UnityEngine = CS.UnityEngine
Vector4 = UnityEngine.Vector4
Vector3 = UnityEngine.Vector3
Vector2 = UnityEngine.Vector2
GameObject  = CS.UnityEngine.GameObject
Object = CS.UnityEngine.Object
Transform   = CS.UnityEngine.Transform
Quaternion = UnityEngine.Quaternion
LayerMask =  UnityEngine.LayerMask
Screen = CS.UnityEngine.Screen
Time = CS.UnityEngine.Time
Input = CS.UnityEngine.Input
SystemLanguage = CS.UnityEngine.SystemLanguage
Application = CS.UnityEngine.Application
RuntimePlatform = CS.UnityEngine.RuntimePlatform
SceneManager = CS.UnityEngine.SceneManagement.SceneManager

KeyCode = CS.UnityEngine.KeyCode
Mathf = CS.UnityEngine.Mathf
GraphicManager = CS.LPCFramework.GraphicManager.Instance
ResourceMgr = CS.LPCFramework.ResourceMgr.Instance
LuaUtils = CS.LPCFramework.LuaUtils
AudioState = CS.LPCFramework.AudioState
AudioGroupId = CS.LPCFramework.GroupId
GameCenterManager = CS.GameCenterManager.Instance
VersionMgr = CS.LPCFramework.VersionMgr
Bitwise = CS.BitwiseUtilities
FileUtils = CS.LPCFramework.FileUtils

-----------------------------------------自定义工具类---------------------------------
require "Common.LuaPackage"
require "Common.LuaClass"
require "UI.Core.FairyGUI"

TimerManager = require "Manager.TimerManager"

LevelManager = nil

HotUpdateMgr = nil

Event = require 'Event.Event'
EventDispatcher = (require 'Event.EventDispatcher').new()

local InitModules = {}

function InitModules.LoadModule()   
    
    --LuaUtils.doDispatchFunc = function(eventId,value)
    --    EventDispatcher:Dispatch(eventId,value)
    --end
    --
    AnalyticsManager = require("Manager.AnalyticsManager")
    LevelManager = require "Manager.LevelManager"    
    HotUpdateMgr = require "Manager.HotUpdateMgr"
    AnalyticsManager.initialize()
    LevelManager.initialize() 
end


return InitModules

