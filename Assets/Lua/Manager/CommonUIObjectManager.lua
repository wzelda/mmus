local CommonUIObjectManager = {}

UIKey={
    FirstSeaBtn = 0,--首个海域前往按钮
    AquariumTabBtn = 0,--观赏馆页签
    ImproveTabBtn = 0,--管理页签
    AchievementTabBtn = 0, --成就页签
    FishCtrlBtn = 0, --钓鱼按钮
    FistFishBtn = 0, --列表第一条鱼
    MaintaskBtn = 0, --主线任务
    MultiSpeedBtn = 0,--加速
    EarthBtn = 0,--切换海域
    SecondSeaBtn = 0,--第二个海域前往按钮
    BuildAquaBtn = 0,--建造观赏馆

    PopupConfirmBtn_1 = 0,--通用提示框的单独的确定按钮
}

local index = 1
for k, v in pairs(UIKey) do
    if type(v) == "number" then
        UIKey[k] = index
        index = index + 1
    end
end

--已注册的用于引导操作的物体
local commonObjectRegedit = {}

function CommonUIObjectManager:Add(key,obj)
    commonObjectRegedit[key] = obj
    -- if obj and obj.onClick then
    --     obj.onClick:Add(function ()
    --         EventDispatcher:Dispatch(Event.CG_CLICK_BTN, key)
    --     end)
    -- end
end

function CommonUIObjectManager:Get(key)
    local result = commonObjectRegedit[key]
    return result
end

return CommonUIObjectManager