local VideoMgr = {}

VideoMgr.PlayVideoName = ""

VideoMgr.SkipCfgName = nil
VideoMgr.LabelCfgName = nil

VideoMgr.SkipCfg = nil
VideoMgr.LabelCfg = nil


local function OnStartVideo()    
    -- EventDispatcher:Dispatch(Event.VIDEO_START)
    --print("Video Start")
end

local function OnVideoPlay()

    --print("Video Play ID "..tostring(frameid))
    -- EventDispatcher:Dispatch(Event.VIDEO_UPDATE,frameid)
end

local function OnVideoEnd()    
    
    -- EventDispatcher:Dispatch(Event.VIDEO_END)
    
    VideoMgr.SkipCfg = nil
    VideoMgr.LabelCfg = nil

    if VideoMgr.SkipCfgName  ~= nil then  
        
        LuaPackage.UnLoad(VideoMgr.SkipCfgName)
        VideoMgr.SkipCfgName = nil

    end

    if VideoMgr.LabelCfgName  ~= nil then  
        
        LuaPackage.UnLoad(VideoMgr.LabelCfgName) 
        VideoMgr.LabelCfgName = nil

    end

end

function VideoMgr.Initialize()
    
    CS.LPCFramework.VideoCtrl.Instance.OnVideoBegin = OnStartVideo
    CS.LPCFramework.VideoCtrl.Instance.OnVideoPlay = OnVideoPlay
    CS.LPCFramework.VideoCtrl.Instance.OnVideoEnd = OnVideoEnd

end

function VideoMgr.Play(vname)
    
    CS.LPCFramework.VideoCtrl.Instance.OnVideoBegin = OnStartVideo
    CS.LPCFramework.VideoCtrl.Instance.OnVideoPlay = OnVideoPlay
    CS.LPCFramework.VideoCtrl.Instance.OnVideoEnd = OnVideoEnd

    VideoMgr.PlayVideoName = vname

    -- VideoMgr.SkipCfgName = string.format("Config.%sConfig",vname)
    -- VideoMgr.LabelCfgName = string.format("Config.%sLabelConfig",vname)

    -- VideoMgr.SkipCfg = LuaPackage.Load(VideoMgr.SkipCfgName)
    -- VideoMgr.LabelCfg = LuaPackage.Load(VideoMgr.LabelCfgName)

    -- UIManager.OpenUI(UIInfo.VideoPanel)
    CS.LPCFramework.VideoCtrl.Instance:PlayVideo(vname)
    
end

function VideoMgr.isPlaying()
    
    return CS.LPCFramework.VideoCtrl.Instance:isVideoPlaying()
end

function VideoMgr.GetCurrentFrameID()
    return CS.LPCFramework.VideoCtrl.Instance:GetCurrentFrameID()
end


function VideoMgr.GoToFrame(frameID)
    CS.LPCFramework.VideoCtrl.Instance:GoToFrame(frameID)
end

function VideoMgr.Stop()
    CS.LPCFramework.VideoCtrl.Instance:Stop()
end

function VideoMgr.Pause()
    CS.LPCFramework.VideoCtrl.Instance:Pause()
end


return VideoMgr
