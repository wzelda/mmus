--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local FilterWordManager = class()
local FilterConfig = nil
local FilterNameConfig = nil


local function CheckAndReplaceWords(words)
    if FilterConfig and FilterConfig[words] ~= nil then
        return true
    end
    return false;
end

local function CheckAndReplaceNameWords(words)
    if FilterNameConfig and FilterNameConfig[words] ~= nil then
        return true
    end
    return false;
end

--常规屏蔽
function FilterWordManager.FilterWords(words)
    if LocalizationMgr.GetCurrLanguageType() ~= ELoczationType.CN then
        return words
    end
    LuaUtils.FilterFunc = CheckAndReplaceWords

    if LuaUtils.FilterWords then
        return LuaUtils.FilterWords(words)
    end
    return words
end

--名字屏蔽
function FilterWordManager.FilterNameWords(words)
    if LocalizationMgr.GetCurrLanguageType() ~= ELoczationType.CN then
        return words
    end
    LuaUtils.FilterFunc = CheckAndReplaceNameWords

    if LuaUtils.FilterWords then
        return LuaUtils.FilterWords(words)
    end
    return words
end 

--检查是否有屏蔽字
function FilterWordManager.CheckWordsHasFilter(words)
    if LocalizationMgr.GetCurrLanguageType() ~= ELoczationType.CN then
        return false
    end
    if LuaUtils.FilterWords then
        LuaUtils.FilterFunc = CheckAndReplaceWords
        return LuaUtils.CheckWordsHasFilter(words)
    end
    return false
end


--检查名字是否有屏蔽字
function FilterWordManager.CheckNameWordsHasFilter(words)
    if LocalizationMgr.GetCurrLanguageType() ~= ELoczationType.CN then
        return false
    end
    if LuaUtils.FilterWords then
        LuaUtils.FilterFunc = CheckAndReplaceNameWords
        return LuaUtils.CheckWordsHasFilter(words)
    end
    return false
end

function FilterWordManager:ctor()
    if LocalizationMgr.GetCurrLanguageType() ~= ELoczationType.CN then
        return
    end
    if nil == FilterConfig then
        FilterConfig = require "Config.FilterWordsConfig"
    end

    if nil == FilterNameConfig then
        FilterNameConfig = require "Config.FilterNameWordsConfig"
    end
    --LuaUtils.FilterFunc = CheckAndReplaceWords
    --self:CreateTree()
    --Utils.DebugError(LuaUtils.CheckWordsHasFilter("123123"))
   -- Utils.DebugError(self:CheckReplaceSentence("123"))
end


local function filter_english_chars(s)
    
    local ss = {}    
    local index = {}
    local k = 1
    while true do
        if k > #s then break end
        local c = string.byte(s,k)
        if not c then break end
        if c<192 then
            -- 大写字母           -- 小写字母
            if (c>= 65 and c<=90) or (c>=97 and c<=122) then
                table.insert(ss, string.char(c))
                table.insert(index,k)
            end            
            k = k + 1
        elseif c<224 then
            k = k + 2
        elseif c<240 then
            k = k + 3
        elseif c<248 then
            k = k + 4
        elseif c<252 then
            k = k + 5
        elseif c<254 then
            k = k + 6
        end
    end
    return table.concat(ss),index

end


local function filter_chinese_chars(s)
    local ss = {}
    local index = {}
    local index2 = {}
    local k = 1
    while true do
        if k > #s then break end
        local c = string.byte(s,k)
        if not c then break end
        if c<192 then
            k = k + 1
        elseif c<224 then
            k = k + 2
        elseif c<240 then
            -- 中文
            if c>=228 and c<=233 then
                local c1 = string.byte(s,k+1)
                local c2 = string.byte(s,k+2)
                if c1 and c2 then
                    local a1,a2,a3,a4 = 128,191,128,191
                    if c == 228 then a1 = 184
                    elseif c == 233 then a2,a4 = 190,c1 ~= 190 and 191 or 165
                    end
                    if c1>=a1 and c1<=a2 and c2>=a3 and c2<=a4 then
                        table.insert(ss, string.char(c,c1,c2))                          
                        table.insert(index,k)
                        table.insert(index,k + 1)
                        table.insert(index,k + 2)
                    end
                end
            end
            k = k + 3
        elseif c<248 then
            k = k + 4
        elseif c<252 then
            k = k + 5
        elseif c<254 then
            k = k + 6
        end
    end

    local newstr = table.concat(ss)

    return newstr,index
end

local function filter_spec_chars(s)
    local ss = {}
    local index = {}
    local k = 1
    while true do
        if k > #s then break end
        local c = string.byte(s,k)
        if not c then break end
        if c<192 then
            -- 数字                 -- 大写字母           -- 小写字母
            if (c>=48 and c<=57) or (c>= 65 and c<=90) or (c>=97 and c<=122) then
                table.insert(ss, string.char(c))
                table.insert(index,k)
            end
            k = k + 1
        elseif c<224 then
            k = k + 2
        elseif c<240 then
            -- 中文
            if c>=228 and c<=233 then
                local c1 = string.byte(s,k+1)
                local c2 = string.byte(s,k+2)
                if c1 and c2 then
                    local a1,a2,a3,a4 = 128,191,128,191
                    if c == 228 then a1 = 184
                    elseif c == 233 then a2,a4 = 190,c1 ~= 190 and 191 or 165
                    end
                    if c1>=a1 and c1<=a2 and c2>=a3 and c2<=a4 then
                        table.insert(ss, string.char(c,c1,c2))
                        table.insert(index,k)
                        table.insert(index,k + 1)
                        table.insert(index,k + 2)
                    end
                end
            end
            k = k + 3
        elseif c<248 then
            k = k + 4
        elseif c<252 then
            k = k + 5
        elseif c<254 then
            k = k + 6
        end
    end
    return table.concat(ss),index
end

--字符串转换为字符数组
function FilterWordManager:GetCharArray(str, isExcludeLineFeed)
    return str
end

-- 返回:字符串长度(中文占一个字节),一般用于字符替换，比如一个汉字替换为一个*
local function stringLen_1(str)
    if nil == str then
        return 0
    end

    local _, count = string.gsub(str, "[^\128-\193]", "")
    return count
end



-- 将字符串中敏感字用*替换返回
function FilterWordManager:ReplaceWarningWords2(text)
    
    return text

    --[[if nil == text then
        return ""
    end

    if type(text) ~= "string" then
        return ""
    end
    

    --Utils.DebugError("before :"..text)

    local checkstr,index = filter_english_chars(text)
    
    local checkstr2,index2,index22 = filter_chinese_chars(text)

    local checkstr3 = string.lower(checkstr)

    Utils.DebugError("check :"..checkstr)

    Utils.DebugError("check3 :"..checkstr3)

    --Utils.DebugError("check 2 :"..checkstr2)


    local id1, id2
    
    local resetIndex = {}
    
    for k, v in ipairs(FilterConfig) do 
        --Utils.DebugError(v)      
        id1, id2 = string.find(checkstr3, v)
        if nil ~= id1 then
            if string.sub(checkstr3, id1, id2) == v then
                --return true
                
                for kk = id1,id2 do 
                    

                    --Utils.DebugError(index[kk])

                    table.insert(resetIndex,index[kk])

                end
            end
        end

        id1, id2 = string.find(checkstr2, v)
        if nil ~= id1 then
            if string.sub(checkstr2, id1, id2) == v then
                
                --Utils.DebugError("v is "..tostring(v))

                --Utils.DebugError(tostring(id1) .. " : " ..tostring(id2))
                
                for kk = id1,id2 do 
                    

                    --Utils.DebugError(index2[kk])

                    table.insert(resetIndex,index2[kk])

                end


                --local count = 1
                --Utils.DebugError("**********************")
                --
                --for kk ,vv in ipairs(index2) do
                --    
                --    
                --    Utils.DebugError("vv is :"..tostring(vv))
                --       
                --    count = count + 1
                --    
                --    Utils.DebugError(count)
                --    
                --end
            end
        end

    end


    
    local ss = {}
    
    local k = 1
    while true do
        if k > #text then break end
        local c = string.byte(text,k)
        if not c then break end
        if c<192 then
            -- 数字                 -- 大写字母           -- 小写字母
            if (c>=48 and c<=57) or (c>= 65 and c<=90) or (c>=97 and c<=122) then
                
                local reset = false
                for id,num in ipairs(resetIndex) do
                    
                    if num == k then
                        
                        reset = true
                        break

                    end

                end
                
                if reset then
                    
                    table.insert(ss, "*")

                else
                    
                    table.insert(ss, string.char(c))

                end

                
                
            else
                
                table.insert(ss, string.char(c))

            end
            k = k + 1
        elseif c<224 then

            for i = k,k + 2 do 
                
                if i > #text then break end
                local c = string.byte(text,i)
                table.insert(ss, string.char(c))
            end
            
            k = k + 2
        elseif c<240 then
            -- 中文
            if c>=228 and c<=233 then
                local c1 = string.byte(text,k+1)
                local c2 = string.byte(text,k+2)
                if c1 and c2 then
                    local a1,a2,a3,a4 = 128,191,128,191
                    if c == 228 then a1 = 184
                    elseif c == 233 then a2,a4 = 190,c1 ~= 190 and 191 or 165
                    end
                    if c1>=a1 and c1<=a2 and c2>=a3 and c2<=a4 then
                          
                        
                        
                        local reset1 = false
                        local reset2 = false
                        local reset3 = false
                        for id,num in ipairs(resetIndex) do
                    
                            if num == k then
                        
                                reset1 = true
                                                                
                            end

                            if num == k + 1 then
                                
                                reset2 = true

                            end

                            if num == k + 2 then
                                
                                reset3 = true

                            end

                        end
                
                        if reset1 and reset2 and reset3 then
                    
                            table.insert(ss, "*")

                        else
                    
                            table.insert(ss, string.char(c,c1,c2))  

                        end
                                                
                                                                                            
                    end
                end
            else
                
                for i = k,k + 2 do 
                
                    if i > #text then break end
                    local c = string.byte(text,i)
                    table.insert(ss, string.char(c))
                end

            end
            k = k + 3
        elseif c<248 then

            for i = k,k + 4 do 
                
                if i > #text then break end
                local c = string.byte(text,i)
                table.insert(ss, string.char(c))
            end
            
            k = k + 4

        elseif c<252 then
            for i = k,k + 5 do 
                
                if i > #text then break end
                local c = string.byte(text,i)
                table.insert(ss, string.char(c))
            end
            k = k + 5
        elseif c<254 then
            for i = k,k + 6 do 
                
                if i > #text then break end
                local c = string.byte(text,i)
                table.insert(ss, string.char(c))
            end

            k = k + 6
        end
    end

    return table.concat(ss)
    ]]
end

-- 字符串中是否含有敏感字
function FilterWordManager:HasWarningWords2(text)
    
    return false
    --[[if nil == text then
        return false
    end

    if type(text) ~= "string" then
        return false
    end
    
    --Utils.DebugError("before :"..text)

    local checkstr = filter_spec_chars(text)
    
    local checkstr2 = filter_chinese_chars(text)

    --Utils.DebugError("check :"..checkstr)

    local checkstr3 = string.lower(checkstr)

    --Utils.DebugError("check3 :"..checkstr3)

    --Utils.DebugError("check 2 :"..checkstr2)

    local id1, id2
    for k, v in pairs(FilterConfig) do 
        --Utils.DebugError(v)      
        id1, id2 = string.find(checkstr3, v)
        if nil ~= id1 then
            if string.sub(checkstr3, id1, id2) == v then
                return true
            end
        end

        id1, id2 = string.find(checkstr2, v)
        if nil ~= id1 then
            if string.sub(checkstr2, id1, id2) == v then
                return true
            end
        end

    end

    
    return false
    

    --if nil == chars then
    --    return false
    --end
    --
    --local index = 1
    --local node = self.rootNode
    --local word = {}
    --
    --while #chars >= index do
    --    
    --    if chars[index] ~= ' ' then
    --        node = self:FindNode(node, chars[index])
    --    end
    --
    --    if node == nil then
    --        index = index - #word
    --        node = self.rootNode
    --        word = {}
    --    elseif node.flag == 1 then
    --        return true
    --    else
    --        table.insert(word,index)
    --    end
    --    index = index + 1
    --end
    --
    --return false]]
end

return FilterWordManager


--endregion
