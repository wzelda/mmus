--[[ 
 * Descripttion: 数字显示方式转换工具
 * version: 
 * Author: Mingo
 * Date: 2020-04-30 17:58:05
 * LastEditors: Mingo
 * LastEditTime: 2020-05-04 11:38:46
]]


local NumberTranslatorTool = {}

local ChineseMap={
    '一','二','三','四','五','六','七','八','九'
}

local function GetChinesePart(result,part)

    local k = math.modf(part/1000)
    local b = math.modf((part - k*1000)/100)
    local s = math.modf((part - k*1000 -b*100)/10)
    local g = part%10

    if k == nil or k == 0 then 
        if result ~= nil and string.sub( result,-3)~='零' then
            result = result..'零'
        end
    else
        local temp = ChineseMap[k]..'千'
        result = result and result..temp or temp
    end
    
    if (b==nil or b==0) then 
        if result~=nil and string.sub( result,-3)~='零' then
            result=result..'零'
        end
    else
        local temp = ChineseMap[b]..'百'
        result = result and result..temp or temp
    end

    if (s==nil or s==0) then 
        if result~=nil and string.sub( result,-3)~='零' then
            result=result..'零'
        end
    else
        local temp = result==nil and s==1 and '十' or ChineseMap[s]..'十' --这里比较特殊
        result = result and result..temp or temp
    end

    if (g==nil or g==0) then 
        
    else
        local temp = ChineseMap[g]
        result = result and result..temp or temp
    end
    return result
end

-- 阿拉伯数字转中文数字(当前支持千万)
function NumberTranslatorTool.ToChinese(value)
    if type(value) ~= "number" then
        return '数据不合法'
    end

    local w = math.modf(value / 10000) 
    local g = value % 10000
    
    local result = nil

    if w~=nil and w>0 then
        result = GetChinesePart(result,w)..'万'
    end

    local result = GetChinesePart(result,g)
    
    return result
end





return NumberTranslatorTool