local HotUpdateMgr = {}

local UpdateMgr = CS.LPCFramework.UpdateMgr.Instance

-- 热更新的UI，此逻辑不做修改，进游戏优先显示的UI，做成单包，减少任何其他包的require

-- 是否开启热更新
HotUpdateMgr.OpenHotUpdate = false

HotUpdateMgr.HideUpdateMsg = false

local updateUI = nil
local updatePkgId = nil

function HotUpdateMgr.DoUpdate(version,UpdateReqCb, UpdatePassCb )
    Utils.DebugError("server version :"..version)
    local versions = LuaUtils.SplitString(version, ".")
    
    if versions.Length < 2 then
        UIManager.ShowMsg(LocalizeExt("Server Versions error: "..versions[0]))
        return
    end
    ----获取当前客户端版本
    --CS.LPCFramework.BGDownloadMgr.Instance:GetClientVersion()

    if CS.LPCFramework.BGDownloadMgr.Instance.ClientVerion ~= tonumber(versions[0]) then
        --大版本不对 无法登陆
        UIManager.OpenPopupUI(UIInfo.PopupUI, LocalizeExt(25044), LocalizeExt(25043), 2, Utils.GotoDownloadNewVersion, nil)
        --UIManager.ShowMsg(LocalizeExt("Client Version error: "..CS.LPCFramework.BGDownloadMgr.Instance.ClientVerion))
        return
    end

    CS.LPCFramework.BGDownloadMgr.Instance:InitVersion(tonumber(versions[0]),tonumber(versions[1]), tonumber(versions[2]), 1)
    
    if CS.LPCFramework.BGDownloadMgr.Instance:CheckCoreVersion(tonumber(versions[1])) then
        local initSettingCB = function()
            UpdatePassCb(tonumber(versions[0]),tonumber(versions[1]))
            EventDispatcher:Dispatch(Event.START_INIT_SETTING)
        end
            --登陆成功 初始化后台下载 客户端版本 资源版本 默认HQ
            CS.LPCFramework.BGDownloadMgr.Instance:InitSetting(tonumber(versions[0]),tonumber(versions[2]), 1, initSettingCB)
    else
        --执行下载逻辑
        EventDispatcher:Dispatch(Event.LOGIN_STOP)
        UpdateReqCb()
    end
end

function HotUpdateMgr.OpenUI()
    --VersionMgr.m_sUpdateServerURL = "http://509.lightpaw.com:9001/rsync/animal2018/"

    --[[if CS.LPCFramework.LuaUtils.GetDeviceType() == "android" then
        
        if VersionMgr.AndroidChannel == CS.LPCFramework.AndroidPackageChannel.Banshu then
            
            VersionMgr.m_sUpdateServerURL = "http://dev.lightpaw.cn/animal/stable/"

        else
            
            VersionMgr.m_sUpdateServerURL = "http://509.lightpaw.com:9001/rsync/animal2018/"

        end

    else

        VersionMgr.m_sUpdateServerURL = "http://509.lightpaw.com:9001/rsync/animal2018/"

    end]]
   
   -- VersionMgr.UpdateResFolder = "UpdateZip/"
    --VersionMgr.VersionFileName = "version.info"
    --UpdateMgr:Initialize()
    
    -- 因为是单包，所有更新用到的组件都在HotUpdate包里
    updatePkgId = ResourceMgr:LoadUIPkg("UI/HotUpdate/HotUpdate", function()
        updateUI = require("UI.HotUpdate.HotUpdate")
        updateUI.UI = UIPackage.CreateObject("HotUpdate","HotUpdate")
        GRoot.inst:AddChild(updateUI.UI)
        updateUI.UI.fairyBatching = true
        updateUI.UI.sortingOrder = UISortOrder.UpgradePanel
    
        Utils.SetUIFitScreen(updateUI.UI)
    
        updateUI:OnOpen()
        updateUI:OnRegister()
    end)

end

function HotUpdateMgr.CloseUI()
    
    if (updateUI ~= nil) then    
        updateUI:OnUnRegister()    
        updateUI:OnClose()
       
        ResourceMgr:ClearFairyGuiCacheObject(updateUI.UI,true)
        ResourceMgr:UnLoadFairyPackage(updatePkgId,true) 
    end
    --ResourceMgr:UnLoadFairyPackage(commonPkgId) 
    updateUI = nil
end


return HotUpdateMgr