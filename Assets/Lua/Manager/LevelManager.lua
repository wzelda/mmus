local LevelManager = {}

LevelType = {
    Start = "LevelLogic.StartLevelLogic",
    Aquarium = "LevelLogic.AquariumLevelLogic",
    Fishing = "LevelLogic.FishingLevelLogic"
}

-- 所有的场景逻辑
local LevelLogics = {}

local CurLevelLogic = nil

-- 初始化
function LevelManager.initialize()
    if not SDKManager:NeedLogin() then
        LevelManager.loadLevel(LevelType.Start)
    else
        print("waiting for login")
    end
end

function LevelManager.loadLevel(type, params, callback)
    local levelLogic = LevelLogics[type]
    if levelLogic ~= nil then
        levelLogic:reload(params, function()
            if CurLevelLogic and CurLevelLogic ~= levelLogic and CurLevelLogic.onDeactive then
                CurLevelLogic:onDeactive()
            end
            CurLevelLogic = levelLogic

            if callback then
                callback()
            end
        end)
        return
    end

    levelLogic = require(type).new()

    levelLogic:load(params, function()
        LevelLogics[type] = levelLogic
        if CurLevelLogic and CurLevelLogic.onDeactive then
            CurLevelLogic:onDeactive()
        end
        CurLevelLogic = levelLogic
        if callback then
            callback(levelLogic)
        end
    end)
end

function LevelManager.unloadAll()
    for k,v in pairs(LevelLogics) do
        v:unload()
    end
    CurLevelLogic = nil
end

-- 销毁--
function LevelManager.onDestroy()
    LevelManager.unloadAll()
end

return LevelManager
