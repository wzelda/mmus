--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

--这个UI逻辑热更后不热启动，下次启动再刷新

local HotUpdate = {}--UIManager.PanelFactory(UIInfo.LoginUI)

local json = require "rapidjson"

local panel = nil

local UpdateMgr = CS.LPCFramework.UpdateMgr.Instance
local VersionMgr = CS.LPCFramework.VersionMgr
local BGDownloadMgr = CS.LPCFramework.BGDownloadMgr.Instance

local ClientVersion = {branch = "loc",targetname = "dev",cloudver = "1",scriptver = "1",resourcever = "0"}

local msgBoxStateEnum = 
{
    GetVersionFail = 1,-- 最新的版本号
    GetVersionFileSizeFail = 2,-- 最新的版本zip包大小   
    ConfirmDownLoad = 3, -- 确认下载
    NeedDownNewApp = 4, --需要下载最新的App
    DownLoadFail = 5, --下载失败
    SkipBigVersion = 6, -- 跳过大版本用旧版本登录
}

local msgBoxState = 0

local function parseClientVersion()
    -- 解析manifest文件
    --local manifest = CS.LPCFramework.ResourceMgr.LoadLocal("UnityCloudBuildManifest.json")
    --if manifest ~= nil then
    --    local decodedInfo = json.decode(manifest.text)
    --    if decodedInfo ~= nil then      
    --        ClientVersion.branch = decodedInfo.scmBranch
    --        ClientVersion.targetname = decodedInfo.cloudBuildTargetName      
    --        ClientVersion.cloudver = decodedInfo.buildNumber
    --    end
    --end
end

local reqCount = 0
local maxReqCount = 5

local function GetCountFormat2(count)
    
    if type(count) ~= "number" then
        return ""
    end

    if count >= 1000000 then  
        local t1,t2 = math.modf(count / 1000000)
        t2 = math.floor(t2*1000)
        return string.format("%d.%dm",t1,t2)
    elseif count >= 1000 then     
        local t1,t2 = math.modf(count / 1000)   
        t2 = math.floor(t2*1000)
        return string.format("%d.%dk",t1,t2)
    else
        return tostring(count) .. "b"
    end

    return tostring(count)
end


local function OnUpdateDownLoadData(percent,fileNum,maxNum)   
    panel.downLoadTip.visible = true
    
    --if hasdownloadlen == nil then hasdownloadlen = 0 end
    --if downspeed == nil then downspeed = 0 end

    if HotUpdateMgr.HideUpdateMsg == false then
        
        --if percent == 1 then
        --    panel.downLoadTip.text = string.format(LocalizeExt(20474),hasdownloadlen)
        --else
        --    panel.downLoadTip.text = string.format(LocalizeExt(20475),hasdownloadlen,downspeed)
        --end

        panel.downLoadTip.text = string.format(LocalizeExt(20474), math.floor(percent).."%".."("..fileNum.."/"..maxNum..")")
        
    else
        

        panel.downLoadTip.visible = false

    end
    --Utils.DebugError("OnUpdateDownLoadData percent = "..percent)
    if percent > panel.processbar.value then
        panel.processbar.value = percent
    end

end

local function OnUpdateUnZipProcess(percent)    
    panel.downLoadTip.visible = false
    panel.InfoTip.visible = false
    panel.downLoadTip.visible = false

    if HotUpdateMgr.HideUpdateMsg == false then

        panel.InfoTip.text = LocalizeExt(20476)
        panel.downLoadTip.text = LocalizeExt(20477)

    else
        
        panel.InfoTip.visible = false
        panel.downLoadTip.visible = false

    end
   --Utils.DebugError("OnUpdateUnZipProcess percent = "..percent)
    if percent > panel.processbar.value then
        panel.processbar.value = percent
    end
end

local function OnUpdateResult(updatesuc,msg)
    if not updatesuc then
        panel.waiting.visible = false
        --GraphicManager:SetLoadingEffect(false)
        panel.InfoTip.visible = false
        panel.msgbox.visible = true
        panel.msglabel.text = LocalizeExt(20478)..msg
        panel.msgCtrl.selectedIndex = 1
        msgBoxState = msgBoxStateEnum.DownLoadFail
        return
    end
    Utils.DebugError("ReBooting Game...")
    panel.InfoTip.text = "ReBooting Game..."
    
    TimerManager.waitTodo(1, 1,
            function() --OnUpdateFiniGetCoreDownloadFileInfo()
                EventDispatcher:Dispatch(Event.HotUpdateComplete)
                --LevelManager.loadScene(LevelType.Start)
                --重载脚本
                CS.LPCFramework.Launcher.S:ReStartLuaEnv()

            end)
end

local function OnUpdateComplete()
    panel.InfoTip.text = LocalizeExt(20479)

    UpdateMgr.hasUpdateToNew = true
    TimerManager.waitTodo(1, 1, 
    function() --OnUpdateFinish()
    EventDispatcher:Dispatch(Event.HotUpdateComplete) 
    --LevelManager.loadScene(LevelType.Start)
        
        if UpdateMgr.NeedReloadRes == true then
            
            CS.LPCFramework.Launcher.S:ReStartLuaEnv()

        else
            
            OnUpdateFinish()

        end

    end)    
    --Utils.DebugError("Back To Login")
    --
    
end


local confirmClick = nil

local function MsgBoxConfirmClick()    
    if msgBoxState == msgBoxStateEnum.GetVersionFail
    or msgBoxState == msgBoxStateEnum.GetVersionFileSizeFail then        
        --CS.LPCFramework.LuaUtils.QuitGame()
        print("get version fail")
    elseif msgBoxState == msgBoxStateEnum.ConfirmDownLoad then
        --UpdateMgr:BeginDownloadTask()
        --UpdateMgr:CheckUpdate(OnUpdateDownLoadData,OnUpdateUnZipProcess,OnUpdateResult)
        --改成BGDownloadMgr下载核心文件
        BGDownloadMgr:StartCoreDownload(OnUpdateDownLoadData,OnUpdateUnZipProcess,OnUpdateResult)
        panel.msgbox.visible = false
        panel.waiting.visible = true

        --GraphicManager:SetLoadingEffect(true)

        panel.processbar.visible = true
        HotUpdateMgr.HideUpdateMsg = false;

        if HotUpdateMgr.HideUpdateMsg == false then

            panel.InfoTip.text = LocalizeExt(20480) 
        else
            
            panel.InfoTip.visible = false

        end
    elseif msgBoxState == msgBoxStateEnum.NeedDownNewApp then        
        --CS.LPCFramework.LuaUtils.QuitGame()
        print("need down load app")
    elseif msgBoxState == msgBoxStateEnum.DownLoadFail then        
        --CS.LPCFramework.LuaUtils.QuitGame()    
        print("down load fail")
    elseif msgBoxState == msgBoxStateEnum.SkipBigVersion then  
        if confirmClick ~= true then      
            confirmClick = true
            UpdateMgr:UpdateCompleteNoRefreshVersion()
            OnUpdateComplete()
        end
    end
end

-- 下载 文件信息成功回调
local function OnVersionInfoUpdate(checksuc,filesize)
    --Utils.DebugLog(checksuc)
    if checksuc then
        
        local fileM = filesize / 1000000

        if fileM <= 10 then
            
            HotUpdateMgr.HideUpdateMsg = true

        end


        if HotUpdateMgr.HideUpdateMsg == false then
            
            -- 检测到有文件需要下载了。弹框让用户选择是否在 不在wifi 下下载 
            panel.msgbox.visible = true
            local sizestr = GetCountFormat2(filesize)
            panel.msglabel.text = string.format(LocalizeExt(20481), sizestr)
            panel.msgCtrl.selectedIndex = 1
            msgBoxState = msgBoxStateEnum.ConfirmDownLoad

        else
            panel.msgbox.visible = false
			msgBoxState = msgBoxStateEnum.ConfirmDownLoad
			MsgBoxConfirmClick()
        end
    else
        --TimerManager.waitTodo(1, 1, function() panel:VersionCheck() end)
        TimerManager.waitTodo(1, 1, function() panel:StartCoreDownload() end)
    end
end


-- 版本号检测回调
local function CheckVersionCallback(checksuc)
    
    if checksuc then    -- 检测到版本号             
        reqCount = 0    --重用这个变量

        if UpdateMgr.readServerScriptVersionID ~= VersionMgr.AppVersion then
            -- 检测到程序版本变化了，提示去appstore下载最新版本
            --[[panel.msgbox.visible = true
            panel.msglabel.text = LocalizeExt("当前客户端版本过低,请去lightpaw下载最新版本")
            panel.msgCtrl.selectedIndex = 1
            msgBoxState = msgBoxStateEnum.NeedDownNewApp--]] -- 正式功能，先注掉


            -- 测试版 可以跳过大版本进游戏
            panel.msgbox.visible = true
            panel.msglabel.text = string.format("当前客户端版本过低,需要下载新版本，(测试阶段)点击确定可以跳过进入游戏，还请去lightpaw下载新版本")
            panel.msgCtrl.selectedIndex = 1
            msgBoxState = msgBoxStateEnum.SkipBigVersion

        else
            panel:VersionCheck()
        end
    else
        TimerManager.waitTodo(1, 1, function() panel:ReqVersionFile() end)
    end
end


local function MsgBoxCancelClick()
    if msgBoxState == msgBoxStateEnum.GetVersionFail 
    or msgBoxState == msgBoxStateEnum.GetVersionFileSizeFail 
    or msgBoxState == msgBoxStateEnum.ConfirmDownLoad 
    or msgBoxState == msgBoxStateEnum.NeedDownNewApp 
    or msgBoxState == msgBoxStateEnum.DownLoadFail 
    or msgBoxState == msgBoxStateEnum.SkipBigVersion
    then
        --CS.LPCFramework.LuaUtils.QuitGame()
    end
end



function HotUpdate:VersionCheck()
    self.waiting.visible = true  
    --GraphicManager:SetLoadingEffect(true)      
    self.msgbox.visible = false
    self.InfoTip.visible = true
	
	if HotUpdateMgr.HideUpdateMsg == false then

	    self.InfoTip.text = LocalizeExt(20482) 
	else
		
		self.InfoTip.visible = false
	end
    reqCount = reqCount + 1
    if reqCount >= maxReqCount then
        self.waiting.visible = false
        --GraphicManager:SetLoadingEffect(false)
        self.InfoTip.visible = false
        self.msgbox.visible = true
        self.msglabel.text = LocalizeExt(20483)
        self.msgCtrl.selectedIndex = 1
        msgBoxState = msgBoxStateEnum.GetVersionFileSizeFail

    else
        UpdateMgr:LocalVersionCheck(OnVersionInfoUpdate,OnUpdateComplete)
    end
end


function HotUpdate:StartCoreDownload()
    self.waiting.visible = true
    GraphicManager:SetLoadingEffect(true)
    self.InfoTip.visible = false
    self.InfoTip.text = LocalizeExt(20484)
    --Utils.DebugError("版本检测中")
    
    reqCount = reqCount + 1
    if reqCount >= maxReqCount then
        self.waiting.visible = false
        GraphicManager:SetLoadingEffect(false)
        self.InfoTip.visible = false

        self.msgbox.visible = true
        self.msglabel.text = LocalizeExt(20483)
        self.msgCtrl.selectedIndex = 1
        msgBoxState = msgBoxStateEnum.GetVersionFail
    else
        --获取核心下载的文件信息
        BGDownloadMgr:GetCoreDownloadFileInfo(OnVersionInfoUpdate)
    end
    
end


function HotUpdate:ReqVersionFile()    
    self.waiting.visible = true
    --GraphicManager:SetLoadingEffect(true)
    self.InfoTip.visible = true
    self.InfoTip.text = LocalizeExt(20484) 
    --Utils.DebugError("版本检测中")
    reqCount = reqCount + 1
    if reqCount >= maxReqCount then
        self.waiting.visible = false
        --GraphicManager:SetLoadingEffect(false)
        self.InfoTip.visible = false
        self.msgbox.visible = true
        self.msglabel.text = LocalizeExt(20483)
        self.msgCtrl.selectedIndex = 1
        msgBoxState = msgBoxStateEnum.GetVersionFail

    else
        UpdateMgr:CheckVersion(CheckVersionCallback)
    end
end

-- 子类初始化UI控件
function HotUpdate:OnOpen()    
    panel = self   
    reqCount = 0     
    -- 中部描述
    self.InfoTip = self.UI:GetChild("InfoTip")     
    self.InfoTip.visible = false   
    -- 进度条
    self.processbar = self.UI:GetChild("processBar")
    self.processbar.visible = true--not Utils:GetShieldVal()
    self.processbar.visible = false
    panel.processbar.value = 0
    -- 下载进度描述
    self.downLoadTip = self.UI:GetChild("downLoadTip")
    self.downLoadTip.visible = false            

    --self.bgloader = self.UI:GetChild("bg")
    --self.bgloader.url = UIInfo.LoadingUI.UIImgPre .. "ui_loading_BGimg_00"
    
    self.waiting = self.UI:GetChild("Waiting")
    self.waiting.visible = false
    self.holder = self.waiting:GetChild("Holder")
    -- 创建特效
    self:CreateEffect()

    self.msgbox = self.UI:GetChild("MsgBox")
    self.msgbox.visible = false

    self.msgCtrl =  self.msgbox:GetController("Tab")
    self.msgCtrl.selectedIndex = 0
    self.msglabel = self.msgbox:GetChild("Text_02")
    self.msgtoplabel = self.msgbox:GetChild("Text_01")

    --self.CloseBtn1 = self.msgbox:GetChild("Closed_Btn")
    self.CloseBtn2 = self.msgbox:GetChild("Cancel_Btn")
    self.ConfirmBtn1 = self.msgbox:GetChild("Sure1_Btn")
    self.ConfirmBtn2 = self.msgbox:GetChild("Sure2_Btn")

    Utils.DebugError("HotUpdate:OnOpen")
    -- test version
    self.label_version = self.UI:GetChild("Version")
    self.label_version.text = ""
    --parseClientVersion()
    --if (ClientVersion ~= nil) then       
    --    self.label_version.text = string.format("ver:%s.%s.%s.%s.%s.%s",ClientVersion.branch,ClientVersion.targetname,ClientVersion.cloudver,VersionMgr.AppVersion,VersionMgr.CurUsedResVersion,VersionMgr.ArtSvnVer)
    --else
        -- never happen
    --end        

    self.waiting.visible = true
    self.InfoTip.visible = false
    self.InfoTip.text = LocalizeExt(20484) 

    if CS.LPCFramework.LuaUtils.IsInUnityEditor() then
        HotUpdateMgr.OpenHotUpdate = true
    else
        HotUpdateMgr.OpenHotUpdate = true
    end

    if HotUpdateMgr.OpenHotUpdate == true then
        
        --if UpdateMgr.hasUpdateToNew == true then
        --    
        --    HotUpdateMgr.OpenHotUpdate = false
        --
        --end

        if BGDownloadMgr.CoreDownloadVal >= 100 then
            HotUpdateMgr.OpenHotUpdate = false
        end
    end
    
    if CS.LPCFramework.LuaUtils.GetDeviceType() == "android" then
        
        if VersionMgr.AndroidChannel == CS.LPCFramework.AndroidPackageChannel.Banshu then
            
            HotUpdateMgr.HideUpdateMsg = true

        else
            
            HotUpdateMgr.HideUpdateMsg = false

        end

    else

        HotUpdateMgr.HideUpdateMsg = false

    end

    Utils.DebugError("HotUpdate:OnOpen OpenHotUpdate")
    if HotUpdateMgr.OpenHotUpdate == true then        
        TimerManager.waitTodo(1, 1, function() self:StartCoreDownload() end) -- 加个一秒延迟
    else        
        UpdateMgr:UpdateComplete()
        OnUpdateComplete()
    end
end

function HotUpdate:OnHotUpdateComplete()
    HotUpdateMgr.CloseUI()     
end

-- 创建特效
function HotUpdate:CreateEffect()
    
    --GraphicManager:OpenLoadingEffect()
    
end

function HotUpdate:ClearEffect()
        
    --if nil ~= self.goEffect and not Utils.unityTargetIsNil(self.goEffect) then       
    --    GameObject.Destroy(self.goEffect)
    --    self.goEffect = nil
    --end
end


-- 子类绑定各种事件
function HotUpdate:OnRegister()                 
    EventDispatcher:Add(Event.HotUpdateComplete, self.OnHotUpdateComplete, self)
    --self.CloseBtn1.onClick:Add(MsgBoxCancelClick)
    self.CloseBtn2.onClick:Add(MsgBoxCancelClick)
    self.ConfirmBtn1.onClick:Add(MsgBoxConfirmClick)
    self.ConfirmBtn2.onClick:Add(MsgBoxConfirmClick)
end

-- 强制刷新,比如网络事件监听，切换语言包，断线重连等
function HotUpdate:OnRefresh(...)
    self:OnRefreshText()
end

function HotUpdate:OnRefreshText()
    self.msgtoplabel.text = LocalizeExt(20037)
    self.ConfirmBtn1.title = LocalizeExt(20355)
    self.ConfirmBtn2.title = LocalizeExt(20355)
    self.CloseBtn2.title = LocalizeExt(20047)
end

function HotUpdate:OnUpdate()
end

-- 解绑各类事件
function HotUpdate:OnUnRegister()                
    EventDispatcher:Remove(Event.HotUpdateComplete, self.OnHotUpdateComplete, self)
    --self.bgloader.url = ""
    --self.CloseBtn1.onClick:Clear() 
    self.CloseBtn2.onClick:Clear() 
    self.ConfirmBtn1.onClick:Clear() 
    self.ConfirmBtn2.onClick:Clear()     
end
-- 关闭
function HotUpdate:OnClose()
    
    self:ClearEffect()
    panel = nil    
end



return HotUpdate
--endregion
