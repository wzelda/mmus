
-- 依赖关系逻辑

local DependsConfig = Utils.LoadConfig("Config.DependsConfig")

local DependManager = {}

-- 条件判定方法集合，这样写法是为了避免写一坨if else
local DependFuncs = {
    FishLv = function(id, level)
        -- 鱼达到指定等级
        return PlayerData.Datas.FishData:OwnedFish(tonumber(id), tonumber(level))
    end,
    FishGrow = function(id, growth)
        -- 鱼达到指定等级
        return PlayerData.Datas.FishData:OwnedFishGrowth(tonumber(id), tonumber(growth))
    end,
    DecorationLv = function(id, level)
        -- 装饰物达到指定等级
        return PlayerData.Datas.DecorationData:OwnedDecoration(tonumber(id), tonumber(level))
    end,
    FinishedSea = function(id)
        -- 解锁海域全部任务
        return PlayerData.Datas.SeaData:FinishedSea(tonumber(id))
    end,
    FinishedAquarium = function(id)
        -- 完成观赏馆建设
        return PlayerData.Datas.AquariumData:FinishedAquarium(tonumber(id))
    end
}

-- 获取依赖条件
function DependManager.GetDepends(dependID)
    local dep = DependsConfig.DependsByID[dependID]

    local ret = {}
    
    if dep ~= nil then
        for i=1,4 do 
            if dep["API"..tostring(i)] ~= "" then
                table.insert(ret, {
                    api = dep["API"..tostring(i)],
                    title = dep["Title"..tostring(i)],
                    params = dep["Params"..tostring(i)]
                })
            else
                break
            end
        end
    elseif dependID ~= 0 then
        Utils.DebugWarning("Invalid depend ID " .. tostring(dependID))
    end

    return ret
end

local unpack = unpack or table.unpack

-- 检测依赖条件是否成立
function DependManager.CheckDependency(dep)
    return DependFuncs[dep.api](unpack(dep.params))
end

-- 检测依赖是否成立
function DependManager.PassedDepend(dependID)
    if dependID == 0 then return true end
    
    local ret = DependManager.GetDepends(dependID)
    for k, dep in pairs(ret) do
        if not DependManager.CheckDependency(dep) then
            return false
        end
    end

    return true
end

return DependManager

