--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local AdsManager = {}

local callback = nil
local Advertisements = nil
local SdkdsGDPRUtils = nil
local bNewLBAds = false
local bAgreed = true

function AdsManager.Init(accept)

    Utils.DebugError("-----------AdsManager.Init")

    local verType = Utils:GetVersionType()
    if FBManager.bLogEvent and (verType == VersionType.LB or verType == VersionType.LBIOS) then

        local function cb(isAgreed)
            Utils.DebugError("isAgreed = "..tostring(isAgreed))
            bAgreed = isAgreed
            if not isAgreed then
                Application.Quit();
            end
        end
        
        bNewLBAds = true
        SdkdsGDPRUtils = CS.LPCFramework.SdkdsGDPRUtils.Instance
        SdkdsGDPRUtils:Init(cb)
        local bOptOutOfAds = Utils.GetData("SavedOptOutOfAds")
        if nil ~= bOptOutOfAds and true == bOptOutOfAds then
            
            Utils.SaveData("SavedOptOutOfAds", "")
            SdkdsGDPRUtils:setGDPRAgreedAdStayInformed(not bOptOutOfAds)
        end
        SdkdsGDPRUtils:showGDPRDialog("SdkdsGDPRUtils")

        Advertisements = CS.LPCFramework.AdmobManager.Instance
        Advertisements:RegisterAdEvents()
        Advertisements:RequestRewardedVideoAd()
        return
    end

    bAgreed = true

    pcall(function()
        if nil == Advertisements then

            if nil ~= CS.Advertisements then
                Advertisements = CS.Advertisements.Instance
            end
        end

        if nil == Advertisements then
            return
        end

        local bTrue = LuaUtils.ContainMethod(Advertisements, "Initialize")
        if not bTrue then
            Advertisements = nil
            return
        end

        if nil == Advertisements then
            return
        end

        if nil == accept then
            accept = true
        end

        if Advertisements:UserConsentWasSet() then

            Advertisements:Initialize();
            --if consent was set, display buttons for ads
        else
            Advertisements:SetUserConsent(bAgreed);
            Advertisements:Initialize();
        end

    end)

end

local function CompleteCallback(completed, advertiser)
    pcall(function()
        Utils.DebugError("Closed rewarded from: " .. tostring(advertiser) .. " -> Completed " .. tostring(completed));
        if nil ~= callback then
            Utils.DebugError("callback = ")
            local id = completed and 0 or 1
            callback(id)
            callback = nil
        end
    end)

end

function AdsManager.UpdateReloadCD()
    if nil == Advertisements then
        return
    end

    if bNewLBAds then
        return
    end

    local cd = ConfigData:KoreaAdDuration()
    Utils.DebugLog("KoreaAdDuration cd = "..tostring(cd))
    if nil == cd  or 0 == cd then
        cd = 120
    end
    Advertisements:UpdateReloadCD(cd)
end

-- 显示广告
function AdsManager.ShowRewardVideo(cb)
    pcall(function()
        if nil == Advertisements then
            return
        end
        callback = cb

        if bNewLBAds then
            Advertisements:ShowRewardedVideo(CompleteCallback);
        else
            if (Advertisements:IsRewardVideoAvailable()) then

                Advertisements:ShowRewardedVideo(CompleteCallback);
            else
                if nil ~= callback then
                    callback(1)
                    callback = nil
                end
            end
        end
    end)

end

function AdsManager.Destory()

    callback = nil
end

return AdsManager
--endregion
