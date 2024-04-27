--[[ 
 * Descripttion: 
 * Author: Fish
 * Date: 2020-04-17 16:48:04
 ]]

 local json = require "rapidjson"
 local pb = require "lib.protobuf"
 local ConstValues = Utils.LoadConfig("Config.ConstValuesConfig")
 -- 服务器地址
 local serverUrl = "http://706.lightpaw.com:7748"

-- 玩家数据
local PlayerData = {}
PlayerData.id = nil --玩家ID(bytes)
PlayerData.id2Str = nil --玩家ID(string)
PlayerData.playerName = nil --玩家名字
PlayerData.actorLevel = nil
PlayerData.Datas = nil
PlayerData.DailyResetUnixTime = 0

local loadingServer = false
local loadServerSuccessCallback
local loadServerFailCallback

function PlayerData:ctor()
    self.Datas = {
        -- 登录信息
        FishData = ClassConfig.FishDataClass().new(),
        SeaData = ClassConfig.SeaDataClass().new(),
        AquariumData = ClassConfig.AquariumDataClass().new(),
        DecorationData = ClassConfig.DecorationDataClass().new(),
        BufferData = ClassConfig.BufferDataClass().new(),
        AdminData = ClassConfig.AdminDataClass().new(),
        AdvData = ClassConfig.AdvDataClass().new(),
        TaskData = ClassConfig.TaskDataClass().new(),
        FunctionOpenData = ClassConfig.FunctionOpenDataClass().new(),
        AchievementData = ClassConfig.AchievementDataClass().new(),
        FishShipData = ClassConfig.FishShipDataClass().new(),
    }

    self.baseIncome = tonumber(PlayerData.GetConstValue("BaseIncome") or 0)
    self.m_timer = TimerManager.newTimer(1, true, true, nil, nil, function()
        self:OnTimerTick()
    end)
    -- 定时上传服务器
    local function upload()
        print("upload data to server")
        self:Save(true)
    end
    self.uploadTimer = TimerManager.newTimer(60, true, true, nil, nil, upload)
    self.uploadTimer:start()
end

function LoadFromPB()
    local all = require "autogen.all"
    pb.register(Utils.UnGzipProto(all.text))
    all.text = nil

    local bytes = LuaUtils.LoadPlayerStore("PlayerData.data")
    if bytes == nil then
        return nil
    end

    return pb.decode("PlayerData", bytes)
end

function LoadFromJson()
    local bytes = LuaUtils.LoadPlayerStore("PlayerData.data")
    if (bytes == nil) then
        return nil
    end

    return json.decode(bytes)
end

function SaveToJson(data)
    local bytes = json.encode(data, {pretty=true})
    LuaUtils.SavePlayerStore("PlayerData.data", bytes)
end

function SaveToPB(data)
    local bytes = pb.encode("PlayerData", data)
    LuaUtils.SavePlayerStore("PlayerData.data", bytes)
end

local function onHttpResponse(data)
    if nil == data then return end

    print("server result:",data.result)
end

local function onLoadServerResponse(data)
    loadingServer = false

    local function failCallback()
        if loadServerFailCallback then
            loadServerFailCallback()
            loadServerFailCallback = nil
        end
    end

    if nil == data then
        failCallback()
        return
    end

    if data.result ~= 1 then
        Utils.DebugError("load from server fail:", data.err)
        failCallback()
        return
    end

    local ok, jsonobj = pcall(json.decode, data.data)
    if jsonobj then
        -- 测试期间只用本地数据
        -- local datatime = LocalData.getDataSaveTime()
        -- if datatime > jsonobj.dataSaveTime then
        --     PlayerData:Load()
        -- else
        --     PlayerData:updateData(jsonobj)
        -- end
        -- PlayerData:OnLoaded()
        if not PlayerData:Load() then
            PlayerData:CreateData()
        end

        if loadServerSuccessCallback then
            loadServerSuccessCallback()
            loadServerSuccessCallback = nil
        end
    else
        failCallback()
    end
end

local function doHttpGet(url, data, successCallback, failCallBack)
    print("id:",data.id)
    successCallback = successCallback or onHttpResponse
    -- 添加时间戳
    local ts = TimerManager.getCurrentClientTime()
    data["ts"] = tostring(ts)

    local keys = {}
    for k, v in pairs(data) do
        local key = string.format("%s=%s", k, v)
        table.insert(keys, key)
    end
    table.sort(keys)

    local urlParams = ""
    local isFirst = true
    for k, v in pairs(keys) do
        if isFirst then
            isFirst = false;
        else
            urlParams = string.format("%s&", urlParams)
        end
        urlParams = string.format("%s%s", urlParams, v)
    end

    local key = "709394"
    local vs = urlParams .. key
    local sign = FileUtils.HashToMD5Hex(tostring(vs))
    local fullUrl = string.format("%s?%s&sign=%s", url, urlParams, sign)
    -- print(fullUrl)
    NetworkManager.HttpGetString(fullUrl, successCallback, failCallBack)
end

function PlayerData:SaveToServer(data)
    if nil == data then return end

    local sdata = {}
    sdata.id = Utils.GetUniqueID()
    sdata.data = json.encode(data, {pretty=true})
    doHttpGet(serverUrl .. "/save", sdata)
end

function PlayerData:LoadFromServer(successCallback, failCallBack)
    if loadingServer then return end

    loadingServer = true
    loadServerSuccessCallback = successCallback
    loadServerFailCallback = failCallBack
    doHttpGet(serverUrl .. "/get", {id = Utils.GetUniqueID()}, onLoadServerResponse, failCallBack)
end

-- 加载数据
function PlayerData:Load()
    local data = LoadFromJson()
    if data ~= nil then
        PlayerData:updateData(data)
        self:OnLoaded()
        return true
    end

    return false
end

-- 保存数据
function PlayerData:Save(toServer)
    if nil == self.id then return end

    self.dataSaveTime = TimerManager.getCurrentClientTime()
    local data = {}
    data.dataSaveTime = self.dataSaveTime
    data.id = self.id
    data.createTime = self.createTime
    data.playerName = self.name
    data.deviceId = self.deviceId
    data.deviceModel = self.deviceModel
    
    data.coinNum = tostring(self.coinNum)
    data.diamondNum = self.diamondNum
    data.batchCount = self.batchCount
    data.doubleEndtime = self.doubleEndtime
    data.gotOfflineReward = self.gotOfflineReward
    data.bigGuideID = self.bigGuideID
    data.DailyResetUnixTime = self.DailyResetUnixTime

    self.Datas.FishData:Save(data)
    self.Datas.SeaData:Save(data)
    self.Datas.AquariumData:Save(data)
    self.Datas.DecorationData:Save(data)
    self.Datas.AdminData:Save(data)
    self.Datas.AdvData:Save(data)
    self.Datas.FunctionOpenData:Save(data)
    self.Datas.TaskData:Save(data)
    self.Datas.AchievementData:Save(data)
    self.Datas.FishShipData:Save(data)

    LocalData.saveUserAccount(self.id)
    SaveToJson(data)
    LocalData.saveDataSaveTime(self.dataSaveTime)
    if toServer then
        self:SaveToServer(data)
    end
end

function PlayerData:Reset()
    self:CreateData()
    self.incomeDirty = nil
    self.incomeCount = nil
    EventDispatcher:Dispatch(Event.RESET_PLAYERDATA)
end

function PlayerData.GetConstValue(key)
    local kv = ConstValues.ConstValuesByKey[key]
    return kv and kv.Value or nil
end

-- 新建玩家数据
function PlayerData:CreateData()
    local SystemInfo = CS.UnityEngine.SystemInfo

    self.id = LuaUtils.CreateUUID()
    self.createTime = os.time()
    self.deviceId = SystemInfo.deviceUniqueIdentifier
    self.deviceModel = SystemInfo.deviceModel
    
    self.coinNum = tonumber(PlayerData.GetConstValue("InitCoinNum"))
    self.diamondNum = tonumber(PlayerData.GetConstValue("InitDiamondNum"))
    self.batchCount = 1
    self.doubleEndtime = 0
    self.gotOfflineReward = nil
    self.bigGuideID = 0
    
    self.Datas.FishData:CreateData()
    self.Datas.SeaData:CreateData()
    self.Datas.AquariumData:CreateData()
    self.Datas.DecorationData:CreateData()
    self.Datas.BufferData:CreateData()
    self.Datas.AdminData:CreateData()
    self.Datas.AdvData:CreateData()
    self.Datas.FunctionOpenData:CreateData()
    self.Datas.TaskData:CreateData()
    self.Datas.AchievementData:CreateData()
    self.Datas.FishShipData:CreateData()
    self:Save()
    self:OnLoaded()
end

-- 更新数据
function PlayerData:updateData(data)
    self.id = data.id
    self.createTime = data.createTime
    self.playerName = data.name
    self.deviceId = data.deviceId
    self.deviceModel = data.deviceModel

    self.coinNum = tonumber(data.coinNum) or 0
    self.diamondNum = data.diamondNum or 0
    self.batchCount = data.batchCount or 1
    self.doubleEndtime = data.doubleEndtime or 0
    self.gotOfflineReward = data.gotOfflineReward
    self.bigGuideID = data.bigGuideID
    self.DailyResetUnixTime = data.DailyResetUnixTime or 0
    
    self.Datas.FishData:updateData(data)
    self.Datas.SeaData:updateData(data)
    self.Datas.AquariumData:updateData(data)
    self.Datas.DecorationData:updateData(data)
    self.Datas.BufferData:updateData(data)
    self.Datas.AdminData:updateData(data)
    self.Datas.AdvData:updateData(data)
    self.Datas.FunctionOpenData:updateData(data)
    self.Datas.TaskData:updateData(data)
    self.Datas.AchievementData:updateData(data)
    self.Datas.FishShipData:updateData(data)
end

function PlayerData:SwitchBatchCount()
    if self.batchCount == 1 then
        self.batchCount = 10
    --elseif self.batchCount == 10 then
    --    self.batchCount = 100
    else
        self.batchCount = 1
    end

    EventDispatcher:Dispatch(Event.BATCH_COUNT_CHANGE, self.batchCount)
end

function PlayerData:FoldBottemList(folded)
    self.bottomListFolded = folded
    EventDispatcher:Dispatch(Event.BOTTOM_LIST_FOLD, folded)
end

function PlayerData:ConsumeCoin(num)
    self.coinNum = self.coinNum - num
    EventDispatcher:Dispatch(Event.CURRENCY_CHANGED, self.coinNum)
end

function PlayerData:ConsumeDiamond(num)
    self.diamondNum = self.diamondNum - num
    EventDispatcher:Dispatch(Event.CURRENCY_CHANGED, self.diamondNum)
end

-- 收到金币奖励
function PlayerData:RewardCoin(num, playEffect)
    self.coinNum = self.coinNum + num
    EventDispatcher:Dispatch(Event.CURRENCY_CHANGED, self.coinNum)
    if playEffect ~= false then
        EventDispatcher:Dispatch(Event.PLAY_REWARD_EFFECT, CommonRewardType.Coin)
    end
    AudioManager.PlayEAXSound(105)
end

-- 收到钻石奖励
function PlayerData:RewardDiamond(num, playEffect)
    self.diamondNum = self.diamondNum + num
    EventDispatcher:Dispatch(Event.CURRENCY_CHANGED, self.diamondNum)
    if playEffect ~= false then
        EventDispatcher:Dispatch(Event.PLAY_REWARD_EFFECT, CommonRewardType.Diamond)
    end
    AudioManager.PlayEAXSound(107)
end

-- 收到货币
function PlayerData:RewardMoney(rewardType, num, playEffect)
    if rewardType == CommonRewardType.Coin then
        self:RewardCoin(num, playEffect)
    elseif rewardType == CommonRewardType.Diamond then
        self:RewardDiamond(num, playEffect)
    elseif rewardType == CommonRewardType.IncomeTimes then
        self:RewardCoin(self:GetRealCoinIncome() * num, playEffect)
    end
end

-- 消费货币
function PlayerData:Spend(costType, num)
    if not self:ResEnough(costType, num) then
        print("货币不足")
        return false
    end
    local success = false
    if costType == CommonCostType.Coin then
        self.coinNum = self.coinNum - num
        success = true
    elseif costType == CommonCostType.Diamond then
        self.diamondNum = self.diamondNum - num
        success = true
    end
    EventDispatcher:Dispatch(Event.CURRENCY_CHANGED)
    EventDispatcher:Dispatch(Event.CURRENCY_SPEND)
    return success
end

-- 兑换货币
function PlayerData:Exchange(costType, costNum, exchangeType, exchangeNum)
    if self:Spend(costType, costNum) then
        self:RewardMoney(exchangeType, exchangeNum)
    end
end

-- 定时器
function PlayerData:OnTimerTick()
    local realIncome = self:GetRealCoinIncome()
    self.coinNum = self.coinNum + realIncome
    self.Datas.AdminData:OnIncomeTimer(self)
    
    EventDispatcher:Dispatch(Event.CURRENCY_CHANGED, self.coinNum)
    EventDispatcher:Dispatch(Event.COIN_INCOME, realIncome)
end

function PlayerData:GetRealCoinIncome()
    if self.incomeDirty or self.incomeCount == nil then
        local incomeCount = self.baseIncome
        incomeCount = incomeCount + self.Datas.FishData:GetTotalIncome()
        incomeCount = incomeCount + self.Datas.AquariumData:GetTotalIncome()
        
        self.incomeCount = incomeCount
        self.incomeDirty = false
    end

    local factorFixed,factorTemp = self.Datas.BufferData:GetAllBufferFactor()
    -- TODO: 需要将广告增益单独显示在UI上
    return self.incomeCount * (1 + factorFixed) * (factorTemp or 1)
end

-- 保存离线时间
function PlayerData:SaveOfflineTime()
    -- 有奖励未领取时退出游戏，保留离线时间
    if self.gotOfflineReward then
        -- 减去在线这段时间
        local offtime = LocalData.getOfflineTime()
        offtime = offtime + TimerManager.getCurrentClientTime() - self.lastEnterTime
        LocalData.saveOfflineTime(offtime)
        return
    end

    LocalData.saveOfflineTime(TimerManager.getCurrentClientTime())
end

-- 计算离线奖励
function PlayerData:CalcOfflineReward()
    local offtime = LocalData.getOfflineTime()
    local clientTime = TimerManager.getCurrentClientTime()
    self.gotOfflineReward = nil
    if offtime > 100 and clientTime > offtime then
        -- 分钟
        local offdur = math.floor(clientTime - offtime)
        local offMinuts = offdur / 60
        local cfg = ConfigData:GetOfflineReward()
        if offMinuts >= cfg.Offtime then
            -- 上限
            if offMinuts > cfg.Duration then
                offMinuts = cfg.Duration
            end
            local reward = 0
            local rewardType
            for i, v in ipairs(cfg.RewardType) do
                rewardType = v
                -- 时长 x 速率 x 系数
                local rate = self:GetRealCoinIncome()
                reward = math.floor(offMinuts * 60 * rate * cfg.Coef)
            end
            local uiinfo = {}
            uiinfo.OfflineDur = offdur
            uiinfo.Reward = reward
            uiinfo.RewardType = rewardType
            UIManager.OpenUI(UIInfo.OfflineTimeUI, nil, nil, uiinfo)
            self.gotOfflineReward = true
        end
    end
end

-- 根据消耗类型获取是否充足
function PlayerData:ResEnough(costType, cost)
    if nil == cost then return false end

    if costType == CommonCostType.Coin then
        return self.coinNum >= cost
    elseif costType == CommonCostType.Diamond then
        return self.diamondNum >= cost
    end

    return false
end

-- 收益翻倍buff
function PlayerData:AddDoubleRewardBuff(dispatch)
    if self.doubleEndtime > TimerManager.getCurrentClientTime() then
        local buffCfg = ConfigData:GetBufferById(ConfigData:GetDoubleReward().Buffer)
        PlayerDatas.BufferData:ActivateAllBuffer(buffCfg, dispatch)
    end
end

-- 增加收益翻倍时间
function PlayerData:AddDoubleRewardTime(time)
    local cfg = ConfigData:GetDoubleReward()
    local curTime = TimerManager.getCurrentClientTime()
    if self.doubleEndtime < curTime then
        self.doubleEndtime = curTime
    end
    local addTime = self.doubleEndtime - curTime
    if cfg and addTime < cfg.MaxDur * 60 then
        -- 不超上限才增加
        addTime = addTime + time
    end
    self.doubleEndtime = curTime + addTime
end

function PlayerData:OnApplicationFocus(focus)
    if not focus then
        self:Save()
    end
end

function PlayerData:OnApplicationPause(pause)
    print("Application pause:",pause)
    if pause then
        self:SaveOfflineTime()
    else
        self.lastEnterTime = TimerManager.getCurrentClientTime()
        self:CalcOfflineReward()
    end
end

function PlayerData:DailyReset()
    self.DailyResetUnixTime = TimerManager.getClientTomorrowZeroTimestamp()
    self.Datas.FishData:DailyReset()
    self.Datas.AdvData:DailyReset()
end

function PlayerData:CheckDailyReset()
    if TimerManager.getCurrentClientTime() >= self.DailyResetUnixTime then
        self:DailyReset()
    end
    if self.m_resetTimer == nil then
        self.m_resetTimer = TimerManager.newTimer(self.DailyResetUnixTime - TimerManager.getCurrentClientTime(), true, true, nil, nil, function()
            self:DailyReset()
        end)
    else
        self.m_resetTimer:resetMax(self.DailyResetUnixTime - TimerManager.getCurrentClientTime())
    end
    self.m_resetTimer:start()
end

function PlayerData:OnLoaded()
    self.lastEnterTime = TimerManager.getCurrentClientTime()
    self.m_timer:start()
    self:CheckDailyReset()
    self:AddDoubleRewardBuff()
    self:Save(true)
end

function PlayerData:Clear()
    self:Save()
    self:SaveOfflineTime()
    TimerManager.disposeTimer(self.m_timer)
    TimerManager.disposeTimer(self.uploadTimer)
    self.m_timer = nil
    self.uploadTimer = nil
end

function PlayerData:IsPreLoadSuccess()
    return true
end

local amounttool = nil
function PlayerData.amounTool()
    if amounttool == nil then
        amounttool = ClassConfig.AmountToolsClass().new()
    end

    return amounttool
end

return PlayerData
