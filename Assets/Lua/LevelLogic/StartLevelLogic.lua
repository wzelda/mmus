local url = require("socket.url")

local StartLevelLogic = class()

local preloadUIPackages = {
    UIInfo.Library.UIPackagePath,
    UIInfo.GuideLayer.UIPackagePath,
    UIInfo.StoryPanel.UIPackagePath,
    UIInfo.FuncLockUI.UIPackagePath,
    UIInfo.EarthUI.UIPackagePath,
}

local function PreloadUIPackages(pkgs, loadingTask, callback)
    local function LoadPkg(idx)
        UIManager.LoadUIPackage(pkgs[idx], function()
            loadingTask:setLocalProgress((idx-1) / #pkgs)
            if idx < #pkgs then
                LoadPkg(idx + 1)
            else
                callback()
            end
        end)
    end

    LoadPkg(1)
end

local function onDeepLinkActivated(urlstr)
    local appurl = url.parse(urlstr)
    if appurl.scheme:find("^lpidlefishing") ~= nil then
        for _,v in ipairs(Utils.stringSplit(appurl.query, "&")) do
            local kv = Utils.stringSplit(v, "=")
            if kv[1] == "LaunchMode" then
                PlayerPrefs.SetString("LaunchMode", kv[2] )
                if kv[2] == "gmkaiqi" then
                    UIUtils.ShowGMButton()
                end
            end
        end
    end
end

-- 进入场景
function StartLevelLogic:load(param, callback)
    self.scene = SceneManager.GetActiveScene()
    GlobalModule.OnHotUpdate()

    UIManager.OpenUI(UIInfo.LoadingUI, nil, nil):next(
        function(loadingPanel)
            CS.LPCFramework.Launcher.Instance:SendMessage("HideSplash")
            local loadingTask = loadingPanel:AddCustomTask(0.3, 3)

            PreloadUIPackages(preloadUIPackages, loadingTask, function()
                -- 显示GM按钮

                if Application.absoluteURL and Application.absoluteURL ~= "" then
                    onDeepLinkActivated(Application.absoluteURL)
                end

                if CS.UnityEngine.Application.isEditor or PlayerPrefs.GetString("LaunchMode") == "gmkaiqi" then
                    UIUtils.ShowGMButton()
                end

                Application.deepLinkActivated("+", onDeepLinkActivated)

                --取消默认点击声音
                local resPath = "ui://Library/Button_Click01"
                FUIConfig.buttonSound = UIPackage.GetItemAssetByURL(resPath)
                
                loadingTask.isDone = true
                loadingTask = loadingPanel:AddCustomTask(0.4, 3)
                loadingTask:setLocalProgress(0.5)

                local function onDataLoaded()
                    EventDispatcher:Dispatch(Event.PLAYER_INITED)
                    AnalyticsManager.onPlayerLoaded()
                    -- 离线奖励
                    PlayerData:CalcOfflineReward()
                    -- 打开场景界面
                    UIManager.OpenUI(UIInfo.MainUI, nil, nil, loadingTask):next(function ()
                        -- 强制引导
                        GuideManager:initialize()
                        EventDispatcher:Dispatch(Event.CG_ENTER_MAINUI)
                    end)
                end

                AnalyticsManager.onModuleConvertion(2, "start_login", "success")

                --PlayerData:LoadFromServer(onDataLoaded, function ()
                if not PlayerData:Load() then
                    PlayerData:CreateData()
                    AnalyticsManager.onModuleConvertion(4, "get_the_role", "success")
                end
                onDataLoaded()
                --end)
            end
        )
    end)

    callback()
end

function StartLevelLogic:reload(data, callback)
    LuaUtils.SwitchActiveScene(self.scene)
    callback()
    self:PlayBgMusic()
end

-- 退出场景
function StartLevelLogic:unload()
end

function StartLevelLogic:PlayBgMusic()
    local _, curSeaCfg = PlayerDatas.SeaData:GetCurSea()
    if curSeaCfg then
        AudioManager.PlayerBgAudio(curSeaCfg.Audio)
    end
    AudioManager.PlayerLoopEAX(50)
end

return StartLevelLogic