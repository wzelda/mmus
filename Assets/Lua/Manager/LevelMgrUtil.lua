local LevelMgrUtil = {}

-- LevelManager 的一些特殊逻辑放在这里，LevelManager不做热更因为第一个启动场景就用到了

function LevelMgrUtil.BefroreExistSceneLogic()
    if LevelManager ~= nil then
        if UIManager ~= nil then
            UIManager.CloseAll()
        end

        AudioManager.ClearAuidoEff()

        if LevelManager.CurrLevelConfig ~= nil then
            LevelManager.preLevelConfig = LevelManager.CurrLevelConfig
        end

        if LevelManager.CurrLevelLogic ~= nil then
            LevelManager.PreLevelLogic = LevelManager.CurrLevelLogic
        end
    end
end


function LevelMgrUtil.BeforeLoadSceneLogic(id)
    LevelManager.CurLevelType = LevelManager.CurrLevelConfig.Type
    if LevelManager.CurrLevelConfig.LogicScript ~= nil then

        if LevelManager.LevelLogicMap[id] == nil then 
                        
            LevelManager.LevelLogicMap[id] = require(LevelManager.CurrLevelConfig.LogicScript).new()
            
        end
        LevelManager.CurrLevelLogic = LevelManager.LevelLogicMap[id]
    end
    LevelManager.isCurSceneLoaded = false    
    LevelManager.isUIComplete = false
    LevelManager.isEnterScene = false    
end


function LevelMgrUtil.OnLoadBegin()
    CS.LPCFramework.LuaUtils.GC()
end


return LevelMgrUtil

