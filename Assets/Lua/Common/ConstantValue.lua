--[[ 
 * Descripttion: 
 * version: 
 * Author: Mingo
 * Date: 2020-04-01 14:05:17
 * LastEditors: Mingo
 * LastEditTime: 2020-06-17 15:29:56
 ]]
-- 常量
local ConstantValue = {}
ConstantValue.IsInUnityEditor = true
ConstantValue.DebugMode = true
ConstantValue.LogTrack = true

--是否全输出日志（false:只输出Error和FATAL级别的日志）
ConstantValue.ForceLog = true
--战斗日志
ConstantValue.IsBattleLog = false
-- 启动默认首页
ConstantValue.DefaultPage = 2

--点击事件判断时间
ConstantValue.ClickTime = 0.25
ConstantValue.ClickDeltaDis = 10
--战斗中点击事件判断时间
ConstantValue.BattleClickTime = 0.3

--布阵展示模型缩放和角度

--Fairy多语言文件目录
ConstantValue.FairyLannuageFolder = "UI/Languages/"

ConstantValue.FixUIScale = 100

--特效资源目录
ConstantValue.EffectResFolder = "Effects/"
--掉落资源目录
ConstantValue.PropResFolder = "Prefab/Props/"
--音效资源目录
ConstantValue.AudioResFolder = "Audio/"
--行为树资源目录
ConstantValue.BehaviorTreeResFolder = "BehaviorTree/"

--特效

-- 金币icon
ConstantValue.CoinIconURL = "ui://Library/金币"
-- 钻石icon
ConstantValue.DiamondIconURL = "ui://Library/钱"

-------------------------战斗相关固定数值----------------------------
ConstantValue.V3Zero = Vector3.zero
ConstantValue.V3One = Vector3.one
ConstantValue.V2Zero = Vector2.zero
ConstantValue.V2One = Vector2.one
ConstantValue.V3Forward = Vector3.forward
ConstantValue.V3Up = Vector3.up
ConstantValue.defaultLayer = LayerMask.NameToLayer("Default")

function ConstantValue.initialize()
    ConstantValue.IsInUnityEditor = Application.isEditor
end

return ConstantValue