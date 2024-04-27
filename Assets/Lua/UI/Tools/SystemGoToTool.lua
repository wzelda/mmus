--来源跳转工具->SystemGoToPanel
local SystemGoToTool = {}

local ToPanel = function(systemInfo)
    if(systemInfo.UILogic == UIInfo.MainUI)then --进入主界面打开相机（其他界面）
        UIManager.CloseAll()
    end
    if(systemInfo.UIParam)then
        UIManager.OpenUI(systemInfo.UILogic, nil, nil, unpack(systemInfo.UIParam))
    else
        UIManager.OpenUI(systemInfo.UILogic)
    end
    if(systemInfo.UILogic == UIInfo.MainUI)then --打开主线关卡
    end
end

--功能解锁
--systemInfo :SourceConfig
function SystemGoToTool:GoTo(systemInfo)
    local isFuncOpen = false
    if(systemInfo.FuncType)then
        isFuncOpen = PlayerData.Datas.UserData:IsFunctionOpened(systemInfo.FuncType)
    else
        isFuncOpen = true
    end
    if(isFuncOpen and type(systemInfo.CanOpenFunc) == "function" )then
        isFuncOpen = systemInfo.CanOpenFunc()
    end
    if(isFuncOpen)then
        UIManager.CloseUI(UIInfo.SystemGoToUI)
        if(systemInfo.ShowName == 20693)then   -- "沙漠探索"
            PlayerData.Datas.ExploreData.TryOpenExplore()
        else
            ToPanel(systemInfo) 
        end
    else
        UIManager.ShowMsg(string.format(LocalizeExt(21513), LocalizeExt(systemInfo.ShowName)))
    end
end

--[[
--查找建筑的ID
function SystemGoToTool:FindBuildid(buildType, param)
    if(buildType == nil or buildType == BuildType.InvalidBuildType or param == nil)then
        return -1
    else
        for i, buildData in ipairs(ConfigData.config.build_datas)do
            if(buildData.build_type == buildType)then
                if(buildType == BuildType.FUNC_OPEN)then
                    if(buildData.func_build_data.func_type == param)then
                        return buildData.id
                    end
                elseif(buildType == BuildType.ALLIANCE)then
                    if(buildData.alliance_build_data.race == param)then
                        return buildData.id
                    end
                elseif(buildType == BuildType.DRAGON)then
                    if(buildData.dragon_build_data.dragon_type == param)then
                        return buildData.id
                    end
                end
            end
        end
        return -2
    end
end ]]
return SystemGoToTool