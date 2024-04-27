-- 场景控制脚本
local LevelLogic = class()

function LevelLogic:ctor()
end

function LevelLogic:load(data, callback)
    if data and data.sceneName then
        self:loadScene(data.sceneName, callback, data.loadingPanel)
    end
    self.data = data
end

function LevelLogic:LoadSceneImp(sceneName, callback, loadingPanel)
    local function loadFunc()
        local asyncOperation = ResourceMgr:LoadSceneAdditive(sceneName, function(scene)
            self.scene = scene
            LuaUtils.SwitchActiveScene(scene)
            callback()
            EventDispatcher:Dispatch(Event.LOADING_COMPLETE, scene)
        end)
    
        if loadingPanel then
            loadingPanel:AddAsyncOperation(asyncOperation)
        end
    end

    if self.scene ~= nil then
        ResourceMgr:UnloadScene(self.scene, loadFunc)
    else
        loadFunc()
    end
end

function LevelLogic:loadScene(sceneName, callback, loadingPanel)
    if self.sceneName == sceneName then
        LuaUtils.SwitchActiveScene(self.scene)
        callback()
        return
    end

    if loadingPanel ~= nil then
        self:LoadSceneImp(sceneName, callback, loadingPanel)
    else
        UIManager.OpenUI(UIInfo.LoadingUI, nil, nil):next(
            function(loadingPanel_)
                self:LoadSceneImp(sceneName, callback, loadingPanel_)
            end
        )
    end
    self.sceneName = sceneName
end

function LevelLogic:reload(...)
    self:load(...)
end

-- 退出场景
function LevelLogic:unload()
    if self.scene ~= nil then
        ResourceMgr:UnloadScene(self.scene)
        self.scene = nil
    end
    self.data = nil
    self.sceneName = nil
end

return LevelLogic
