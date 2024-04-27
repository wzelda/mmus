local GMOrder = UIManager.PanelFactory(UIInfo.GmOrderUI)

local buttonItem = "ui://GMTools/Button_GMOrder"
local inputItem = "ui://GMTools/Component_GMOrder"

local view
local menu
local closeBtn
local tabList
local menuList

local PlayerPrefs = CS.UnityEngine.PlayerPrefs

local gmdata = {
    OrderList = {
        {
            Tab = "基础功能",
            CMD = {
                {
                    HasInput = true,
                    DefaultInput = 1000000,
                    Desc = "加金币",
                    Action = function(self, input)
                        PlayerData:RewardCoin(tonumber(input))
                        EventDispatcher:Dispatch(Event.DEFAULT_MONEY_EFFECT, CommonRewardType.Coin)
                    end
                },
                {
                    HasInput = true,
                    DefaultInput = 10000,
                    Desc = "加钻石",
                    Action = function(self, input)
                        PlayerData:RewardDiamond(tonumber(input))
                        EventDispatcher:Dispatch(Event.DEFAULT_MONEY_EFFECT, CommonRewardType.Diamond)
                    end
                },
                {
                    Desc = "解锁全部功能",
                    Action = function(self)
                        PlayerDatas.FunctionOpenData:GMUnlockAll()
                    end
                },
                {
                    Desc = "每日重置",
                    Action = function(self)
                        PlayerData:DailyReset()
                    end
                },
                {
                    Desc = "重置游戏存档",
                    Action = function(self)
                        PlayerData:Reset()
                    end
                },
                {
                    Desc = "清除用户设定数据",
                    Action = function(self)
                        PlayerPrefs.DeleteAll()
                    end
                },
                {
                    Desc = "开启Log",
                    Action = function()
                        ConstantValue.ForceLog = true
                        CS.UnityEngine.Debug.unityLogger.filterLogType = CS.UnityEngine.LogType.Log
                        CS.UnityEngine.Debug.unityLogger.logEnabled = true
                        CS.Reporter.SetVisible()
                        UIManager.CloseUI(UIInfo.GmOrderUI)
                    end
                },
                {
                    HasInput = true,
                    DefaultInput = PlayerPrefs.GetString("RemoteDebug") or "",
                    Desc = "远程调试地址",
                    Action = function(self, input)
                        PlayerPrefs.SetString("RemoteDebug", input)
                    end
                }
            }
        },
        {
            Tab = "观赏馆",
            CMD = {
                {
                    Desc = "解锁观赏馆全部展示项目",
                    Action = function()
                        PlayerData.Datas.AquariumData:GMOpenAllShowItems()
                    end
                },
                {
                    Desc = "关闭展示项目",
                    HasInput = true,
                    DefaultInput = 1,
                    Action = function(self, input)
                        PlayerData.Datas.AquariumData:GMClosePrevItems(tonumber(input)) 
                    end
                },
                {
                    Desc = "解锁全部观赏馆",
                    Action = function()
                        PlayerData.Datas.AquariumData:GMOpenAllAquariums()
                    end
                },
                {
                    Desc = "开启观赏馆拖拽控制",
                    Action = function()
                        PlayerData.Datas.AquariumData:GMEnableDrag(true)
                    end
                },
                {
                    Desc = "关闭观赏馆拖拽控制",
                    Action = function()
                        PlayerData.Datas.AquariumData:GMEnableDrag(false)
                    end
                },
            }
        },
        {
            Tab = "钓鱼",
            CMD = {
                {
                    Desc = "快进鱼儿解锁计时(秒)",
                    HasInput = true,
                    DefaultInput = 15 * 60,
                    Action = function(self, input)
                        PlayerData.Datas.FishData:SkipUnlockTime(tonumber(input))
                    end
                },
                {
                    Desc = "重置鱼儿解锁计时",
                    Action = function()
                        PlayerData.Datas.FishData:ResetUnlockTime()
                    end
                },
                {
                    Desc = "解锁全部鱼类",
                    Action = function()
                        PlayerData.Datas.SeaData:GMUnlockAllFish()
                    end
                },
                {
                    Desc = "解锁全部海域",
                    Action = function()
                        PlayerData.Datas.SeaData:GMUnlockAllSea()
                    end
                },
                {
                    Desc = "解锁下一个鱼种",
                    Action = function(self, input)
                        PlayerData.Datas.SeaData:GMUnlockNextFish(1) 
                    end
                },
                {
                    Desc = "解锁多个鱼种",
                    HasInput = true,
                    DefaultInput = 1,
                    Action = function(self, input)
                        PlayerData.Datas.SeaData:GMUnlockNextFish(tonumber(input)) 
                    end
                },
                {
                    Desc = "撤销当前海域鱼种",
                    HasInput = true,
                    DefaultInput = 1,
                    Action = function(self, input)
                        PlayerData.Datas.SeaData:GMLockPrevFish(tonumber(input)) 
                    end
                }
            }
        },
        {
            Tab = "引导",
            CMD = {
                {
                    Desc = "关闭所有引导",
                    Action = function(self)
                        GuideManager:GMFinishAllGuide()
                    end
                },
                {
                    Desc = "跳过当前引导",
                    Action = function(self)
                        GuideManager:GMFinishCurrGuide()
                    end
                }
            }
        }
    }
}

-- gm数据
local function gmData()
    return gmdata
end
-- 当前页签页
local currPages = 0

local errorTriggle = function()
    local errorNum = CS.LPCFramework.LogManager.Instance:GetErrorNum()

    --[[
    if errorNum > 0 then
        if errBG ~= nil then
            errBG.visible = true
        end
        if errTex ~= nil then
            errTex.visible = true
            errTex.text = errorNum
        end
    else
        if errBG ~= nil then
            errBG.visible = false
        end
        if errTex ~= nil then
            errTex.visible = false
        end
    end]]
end

-- 处理gm
local function handleGm(tab, data, input)
    if data.Action then
        AnalyticsManager.blockReport = true
        local ok,error = pcall(data.Action, data, input)
        AnalyticsManager.blockReport = nil
        if not ok then
            CS.UnityEngine.Debug.LogError(error)
        end
    else
        if input == nil then
            gmData().C2SGmProto(data.CMD)
        else
            gmData().C2SGmProto(data.CMD .. " " .. input)
        end
    end
end

-- 菜单列表
local function MenuListRenderer(index, obj)
    local tab = gmData().OrderList[currPages]
    local data = tab.CMD[index + 1]

    if data.HasInput then
        local btn = obj:GetChild("Button_Order")
        local inputTextField = obj:GetChild("Text_Title")
        -- 描述
        btn.title = data.Desc
        -- 默认文本内容
        inputTextField.text = data.DefaultInput
        btn.onClick:Set(
            function()
                handleGm(tab, data, inputTextField.text)
                btn.title = data.Desc
            end
        )
    else
        -- 描述
        obj.title = data.Desc
        obj.onClick:Set(
            function()
                handleGm(tab, data, nil)
                obj.title = data.Desc
            end
        )
    end
end

local function MenuListProvider(index)
    if gmData().OrderList[currPages].CMD[index + 1].HasInput then
        return inputItem
    else
        return buttonItem
    end
end

-- 页签列表
local function TabListRenderer(index, obj)
    local data = gmData().OrderList[index + 1]
    obj.title = data.Tab
    obj.onClick:Set(
        function()
            currPages = index + 1
            menuList.numItems = 0
            menuList.itemRenderer = MenuListRenderer
            menuList.itemProvider = MenuListProvider
            menuList.numItems = #data.CMD
        end
    )
end

local loadstring = _G.loadstring or _G.load

-- 命令行输入Lua指令
function GMOrder:SubmitCommand()
    local luastr = self.txtInput.text
    local func,err = loadstring(luastr)
    if func then
        xpcall(func,function(e) CS.UnityEngine.Debug.LogError(e) end)
    else
        CS.UnityEngine.Debug.LogError(err)
    end
    
    PlayerPrefs.SetString("GM_LAST_INPUT", luastr)
end

function GMOrder:OnOpen()
    UIUtils.SetUIFitScreen(self.UI, true)
    view = self.UI
    menu = view:GetChild("Component_GM")
    closeBtn = view:GetChild("Button_Close")
    tabList = menu:GetChild("List_Main")
    menuList = menu:GetChild("List_Title")
    self.btnExec = view:GetChild("Button_Exec")
    self.txtInput = view:GetChild("Text_input")

    view.sortingOrder = UISortOrder.GM

    tabList.defaultItem = buttonItem
    menuList.defaultItem = buttonItem

    tabList:SetVirtual()
    menuList:SetVirtual()

    errorTriggle()
    CS.LPCFramework.LogManager.Instance.ErrorTriggle = errorTriggle
    
    tabList.itemRenderer = TabListRenderer
    tabList.numItems = #gmData().OrderList

    -- 默认显示第一页
    if gmData().OrderList[1] ~= nil then
        currPages = 1
        menuList.itemRenderer = MenuListRenderer
        menuList.itemProvider = MenuListProvider
        
        menuList.numItems = #gmData().OrderList[1].CMD
    end

    closeBtn.onClick:Add(function()
        UIManager.CloseUI(UIInfo.GmOrderUI)
    end)
    self.btnExec.onClick:Add(function()
        self:SubmitCommand()
    end)
    self.txtInput.onSubmit:Add(function()
        self:SubmitCommand()
    end)

    self.txtInput.text = PlayerPrefs.GetString("GM_LAST_INPUT")
end

function GMOrder:OnClose()
    tabList.itemRenderer = nil
    menuList.itemRenderer = nil
    menuList.itemProvider = nil
end

return GMOrder
