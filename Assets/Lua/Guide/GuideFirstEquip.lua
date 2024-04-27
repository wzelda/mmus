--[[ 
 * Descripttion: 处理第一件装备的引导类
 * version: 
 * Author: Mingo
 * Date: 2020-04-08 17:53:14
 * LastEditors: Mingo
 * LastEditTime: 2020-04-12 02:12:06
 ]]

GuideFirstEquip = class()

--当玩家获得新装备
function GuideFirstEquip:GetNewEquip(data)
    --local count = table.getn(PlayerData.Datas.EquipData.equipMap)
    --if count > 0 then
    --if count ==1 then
        return true
    --end
    --return false
end

--根据名字返回方法
function  GuideFirstEquip:GetFunction(fun_name)
    local temp = load(fun_name)
    return temp
end

return GuideFirstEquip