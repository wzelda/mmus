local SDKManager = class()

SdkType = {
    None = 0,
    TradEN = 1, --Trad海外
    TradCN = 2, --Trad国内
}

-- local rewardAdVId_IOS = "945475589";
-- local rewardAdVId_Android = "945475592";

local AppId
local AdUnitID

SDKManager.IsEnable = false
SDKManager.Tag = nil
SDKManager.ADPlayDoneCB = nil

function SDKManager:IsTrad()
    return self.Tag == SdkType.TradCN or self.Tag == SdkType.TradEN
end

function SDKManager:LoadRewardAD()
    -- if self.loadingADHandler then
    --     print("正在加载")
    --     return
    -- end
    -- AnalyticsManager.onADRequest("激励视频", self.ritId)
    -- self.loadingADHandler = function(code, message)
    --     AnalyticsManager.onADSend("激励视频", self.ritId, tostring(code))
    --     self.loadingADHandler = nil
    --     if self.queuedRequest then
    --         self.queuedRequest.action()
    --         self.queuedRequest = UIManager.StopWaiting(self.queuedRequest)
    --     end
    -- end
    -- self.currentSDK:LoadRewardAdV(self.ritId, PlayerData.id, self.loadingADHandler)
end

function SDKManager:NeedLogin()
    -- 是否需要登录
    return self.Tag == SdkType.TradCN
end

function SDKManager:ctor()
    self.IsEnable = Utils.IsSdkEnable()
    if not self.IsEnable then
        return
    end

    -- if Application.platform == RuntimePlatform.Android then
    --     self.ritId = tonumber(rewardAdVId_Android)
    -- elseif Application.platform == RuntimePlatform.IPhonePlayer then
    --     self.ritId = tonumber(rewardAdVId_IOS)
    -- else
    --     self.ritId = tonumber(rewardAdVId_Android)
    -- end

    -- local lgFactory = CS.LightGameFactory
    -- self.currentSDK = lgFactory.GetInstance()

    -- EventDispatcher:Add(Event.PLAYER_INITED, function()
    --     self:LoadRewardAD()
    -- end)

    local tagfile = UnityEngine.Resources.Load("sdkTag")
    if not Utils.unityTargetIsNil(tagfile) then
        self.Tag = tonumber(tagfile.text)
    end
    print("sdk tag="..tostring(self.Tag))
    if LuaUtils.GetDeviceType() == "android" then
        if self.Tag == SdkType.TradEN then
            AppId = "C29975F096B6EC3636CEAE9BFE7C4B60"
            AdUnitID = "351BBBB4FCCC9D6184EE32DD44D3F2DF"
        elseif self.Tag == SdkType.TradCN then
            AppId = "69F67290E8D8D2B66284B753626E2DA"
            AdUnitID = "1DDB16AE78F549C4A484C1AEC9BDCDB1"
        end
    else
        if self.Tag == SdkType.TradEN then
            AppId = "79897DBEB73E27B87F823275CEE98801"
            AdUnitID = "59F2B80F90A600D4D4E3C747BB17C5BD"
        elseif self.Tag == SdkType.TradCN then
            AppId = "79897DBEB73E27B87F823275CEE98801"
            AdUnitID = "59F2B80F90A600D4D4E3C747BB17C5BD"
        end
    end

    if self:IsTrad() then
        CS.TradPlus.InitializeSdk(AppId)
        CS.TradPlus.LoadRewardedVideoPluginsForAdUnits(AdUnitID)
        CS.TradPlus.RequestRewardedVideo(AdUnitID, true)
        CS.TradPlus.HasRewardedVideo(AdUnitID)

        CS.TradPlusManager.OnRewardedVideoAdLoaded("+", function(tpAdInfo)
            print("SDKManager:OnRewardedVideoAdLoaded\n" .. tpAdInfo)
        end)

        CS.TradPlusManager.OnRewardedVideoAdFailed("+", function(adUnitId, errorMsg)
            print("SDKManager:OnRewardedVideoAdFailed\n" .. adUnitId .. "\n" .. errorMsg)
            UIManager.ShowMsg(Localize("ADLoadError"))
            CS.TradPlus.HasRewardedVideo(AdUnitID)
        end)

        CS.TradPlusManager.OnRewardedVideoAdImpression("+", function(tpAdInfo)
            print("SDKManager:OnRewardedVideoAdImpression\n" .. tpAdInfo)
            -- 广告显示, 按照时机测试结果, 是在广告关闭后第一个调用, 而不是在广告弹出后调用
        end)

        CS.TradPlusManager.OnRewardedVideoAdClicked("+", function(tpAdInfo)
            print("SDKManager:OnRewardedVideoAdClicked\n" .. tpAdInfo) 
        end)

        CS.TradPlusManager.OnRewardedVideoAdClosed("+", function(tpAdInfo)
            print("SDKManager:OnRewardedVideoAdClosed\n" .. tpAdInfo)
        -- Reward 后触发, 自动加载的情况下, 后续会进加载逻辑
        AudioManager.SetAudioEffectVolume(AudioManager.GetAudioEffectVolume())
        AudioManager.SetAudioEffectVolume(AudioManager.GetAudioMusicVolume())
        end)

        CS.TradPlusManager.OnRewardedVideoAdReward("+", function(tpAdInfo)
            print("SDKManager:OnRewardedVideoAdReward\n" .. tpAdInfo)
            if SDKManager.ADPlayDoneCB then
                SDKManager.ADPlayDoneCB()
                SDKManager.ADPlayDoneCB = nil
            end
        end)
        CS.TradPlusManager.OnRewardedVideoAdVideoError("+", function(tpAdInfo, errorMsg)
            print("SDKManager:OnRewardedVideoAdVideoError\n" .. tpAdInfo .. "\n" .. errorMsg)
            UIManager.ShowMsg(Localize("ADPlayError"))
        end)

        if self.Tag == SdkType.TradCN then
            self.bridge = CS.LPCFramework.TaptapBridge.Instance
            self.bridge.OnLogined = function (msg)
                if msg == "1" then
                    LevelManager.loadLevel(LevelType.Start)
                end
            end
            self.bridge:Login()
        end
    end
end

function SDKManager:onDestroy()
    if self.bridge then
        self.bridge:OnDestroy()
    end
end

--播放广告
--completeFunc: 广告播放结束以后的回调
--verifyFunc: 广告播放验证完成以后的回调
--showFunc: 广告开始播放时的回调
--clickFunc: 玩家点击广告时的回调
--errorFunc: 广告播放错误的回调
--closeFunc: 广告页面关闭的回调
function SDKManager:PlayAD(completeFunc, ad_position, ad_position_type)
    if not self.IsEnable then
        if completeFunc then
            completeFunc()
        end
        return
    end

    -- AnalyticsManager.onADButtonClick("激励视频", ad_position, ad_position_type)

    -- local function showRewardAD()
    --     self.result = nil
    --     self.currentSDK:ShowRewardAd(
    --         function(state, code)
    --             local function replayMusic()
    --                 AudioManager.SetAudioEffectVolume(AudioManager.GetAudioEffectVolume())
    --                 AudioManager.SetAudioMusicVolume(AudioManager.GetAudioMusicVolume())
    --             end

    --             if state == 1 then      --开始播放
    --                 AnalyticsManager.onADShow("激励视频", ad_position, ad_position_type, nil, 0, ad_position)
    --                 AudioManager.SetAudioEffectVolume(0, false)
    --                 AudioManager.SetAudioMusicVolume(0, false)
    --             elseif state == 2 then  --video Bar Click
    --             elseif state == 3 then  --视频关闭
    --                 -- 点击计数
    --                 PlayerDatas.AdvData:AddClickCount()
    --                 replayMusic()
    --                 AnalyticsManager.onADShowEnd("激励视频", ad_position, ad_position_type, nil, self.result and "成功" or "失败")
    --                 -- 播放完成后加载广告
    --                 self:LoadRewardAD()
    --                 if completeFunc~=nil and self.result then completeFunc() end
    --             elseif state == 4 then  --播放完成
    --                 --if completeFunc~=nil then completeFunc() end
    --                 replayMusic()
    --                 self.result = true
    --             elseif state == 5 then  --Error 播放错误
    --                 UIManager.ShowMsg(Localize("LoadAdFail"))
    --                 self.result = false
    --                 self:LoadRewardAD()
    --             elseif state == 6 then  --认证完成
    --                 if verifyFunc~=nil then verifyFunc() end
    --             else
    --                 Utils.DebugError(string.format("广告返回参数："+state))
    --             end
    --         end)
    -- end

    -- -- 如果已经在等待了，就直接返回吧
    -- if self.queuedRequest ~= nil then
    --     return
    -- end

    -- -- 如果正在加载广告，就显示Waiting
    -- if self.loadingADHandler then
    --     self.queuedRequest = UIManager.ShowWaiting()
    --     self.queuedRequest.action = showRewardAD
    -- else
    --     -- 广告已加载，直接播放
    --     showRewardAD()
    -- end

    SDKManager.ADPlayDoneCB = completeFunc
    if self:IsTrad() then
        if CS.TradPlus.HasRewardedVideo(AdUnitID) then
            -- AnalyticsManager.onADShow("激励视频", ad_position, ad_position_type, nil, 0, ad_position)
            AudioManager.SetAudioEffectVolume(0, false)
            AudioManager.SetAudioMusicVolume(0, false)
            CS.TradPlus.ShowRewardedVideo(AdUnitID)
        else
            UIManager.ShowMsg(Localize("ADLoading"))
        end
    end
end

return SDKManager
