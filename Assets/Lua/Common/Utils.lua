local Utils = {}

-------------------------------------------------------------资源目录---------------------------------------------------------
function Utils.getQualityFolder()
    if QualityMgr.CurDeviceQuality == DeviceQuality.Low then
        return "Low/"
    elseif QualityMgr.CurDeviceQuality == DeviceQuality.Mid then
        return "Low/"
    else
        return "High/"
    end
end

function Utils.GetQualityEffectPath(isAutoQuality, Quality, IsQualityEff, effLevel)
    if (isAutoQuality == nil) then
        isAutoQuality = true --默认自动
    end
    local resfolder = "Low/"
    if (isAutoQuality) then
        if QualityMgr.CurDeviceQuality == DeviceQuality.High then
            resfolder = "High/"
        elseif QualityMgr.CurDeviceQuality == DeviceQuality.Mid then
            resfolder = "Low/"
        else
            resfolder = "Low/"
        end
    else
        if (Quality == DeviceQuality.High) then
            resfolder = "High/"
        elseif Quality == DeviceQuality.Mid then
            resfolder = "Low/"
        else
            resfolder = "Low/"
        end
    end
    if (IsQualityEff) then
        if (effLevel == QualityEffLevel.A) then
            resfolder = resfolder .. "QualityEffects/A/"
        elseif (effLevel == QualityEffLevel.S) then
            resfolder = resfolder .. "QualityEffects/S/"
        elseif (effLevel == QualityEffLevel.SS) then
            resfolder = resfolder .. "QualityEffects/SS/"
        end
    else
        resfolder = "High/Effects/"
    end
    return resfolder
end

------------------------------------------时间----------------------------------------------------------------
-- 秒数倒计时转换(24小时, hh:mm:ss)
function Utils.secondConversion(second, hideHour)
    if type(second) ~= "number" then
        return
    end

    if second < 0 then
        second = 0
    end

    local d = math.floor(second / 86400)
    local h = math.floor((second % 86400) / 3600)
    local m = math.floor(second % 3600 / 60)
    local s = math.floor(second % 60)

    if h < 10 then
        h = "0" .. h
    end

    if m < 10 then
        m = "0" .. m
    end

    if s < 10 then
        s = "0" .. s
    end

    if d > 0 then
        if LocalizationMgr.GetCurrLanguageType() == ELoczationType.ENG then
            return string.format("%s %s", LocalizeExt(20009, {d}), LocalizeExt(20008, {h}))
        end
        return string.format("%s%s", LocalizeExt(20009, {d}), LocalizeExt(20008, {h}))
    end

    if hideHour then
        return m .. ":" .. s
    else
        return h .. ":" .. m .. ":" .. s
    end
end

function Utils.secondFuzzyConversion2(second)
    if type(second) ~= "number" or second < 0 then
        return ""
    end

    local param = nil
    local str = ""

    if second < 60 then
        param = {}
        table.insert(param, second)
        str = LocalizeExt(20006, param)
    elseif second < 3600 then
        param = {}
        table.insert(param, math.floor(second / 60))
        str = LocalizeExt(20007, param)
    else
        param = {}
        table.insert(param, math.floor(second / 3600))
        str = LocalizeExt(20008, param)
    end

    return str
end

-- 获取时间转换(N分钟前,N小时前,N天前,N周前,N月前,N年)
function Utils.GetTimeConversion(second)
    local param = nil
    local str = ""
    if second < 60 then
        param = {}
        table.insert(param, 1)
        str = LocalizeExt(20000, param)
    elseif second < 3600 then
        param = {}
        table.insert(param, math.floor(second / 60))
        str = LocalizeExt(20000, param)
    elseif second < 86400 then
        param = {}
        table.insert(param, math.floor(second / 3600))
        str = LocalizeExt(20001, param)
    elseif second < 604800 then
        param = {}
        table.insert(param, math.floor(second / 86400))
        str = LocalizeExt(20002, param)
    elseif second < 2592000 then
        param = {}
        table.insert(param, math.floor(second / 604800))
        str = LocalizeExt(20003, param)
    elseif second < 31536000 then
        param = {}
        table.insert(param, math.floor(second / 2592000))
        str = LocalizeExt(20004, param)
    else
        param = {}
        table.insert(param, math.floor(second / 31536000))
        str = LocalizeExt(20005, param)
    end

    return str
end

-- 秒数倒计时转换 >=1天显示天 >=1小时显示小时 其余显示分
function Utils.GetLeftTime(second)
    if type(second) ~= "number" then
        return
    end
    local params = {}
    local d = math.floor(second / 86400)
    if d > 0 then
        table.insert(params, d)
        return LocalizeExt(20009, params)
    else
        local h = math.floor((second % 86400) / 3600)
        if h > 0 then
            table.insert(params, h)
            return LocalizeExt(20008, params)
        else
            local m = math.floor(second % 3600 / 60)
            table.insert(params, m)
            return LocalizeExt(20007, params)
        end
    end
end
-- unixTime 时间戳
function Utils.FormatUnixTime2Date(unixTime)
    local tb = {}
    tb.year = tonumber(os.date("%Y", unixTime))
    tb.month = tonumber(os.date("%m", unixTime))
    tb.day = tonumber(os.date("%d", unixTime))
    tb.hour = tonumber(os.date("%H", unixTime))
    tb.minute = tonumber(os.date("%M", unixTime))
    tb.second = tonumber(os.date("%S", unixTime))
    return tb
end

-- 获取日期
function Utils.GetDateString(unixTime, curTime)
    local curYear = tonumber(os.date("%Y", curTime)) -- 年
    local curDay = tonumber(os.date("%j", curTime)) -- 1年第几天
    local year = tonumber(os.date("%Y", unixTime))
    local day = tonumber(os.date("%j", unixTime))

    -- 同年
    if year == curYear then
        -- 跨年
        -- 今天
        if day == curDay then
            return os.date("%H:%M", unixTime)
        elseif (day + 1) == curDay then -- 昨天
            return string.format(LocalizeExt(21616), os.date("%H:%M", unixTime))
        end
    elseif year + 1 == curYear then
        -- x年第一天0:00:00
        local time = os.time({year = curYear, month = 1, day = 1, hour = 0, min = 0, sec = 0})
        -- 昨天
        if curTime - time < 86400 then
            return string.format(LocalizeExt(21616), os.date("%H:%M", unixTime))
        end
    end

    return os.date("%Y-%m-%d %H:%M", unixTime)
end
---------------------------------------------------------------字符串-------------------------------------------------------------------------------
-- 参数:待分割的字符串,分割字符
-- 返回:子串表.(含有空串)
function Utils.stringSplit(str, split_char)
    local sub_str_tab = {}
    while (true) do
        local pos = string.find(str, split_char)
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str
            break
        end
        local sub_str = string.sub(str, 1, pos - 1)
        sub_str_tab[#sub_str_tab + 1] = sub_str
        str = string.sub(str, pos + 1, #str)
    end

    return sub_str_tab
end

-- 返回:制定长度字符串，和截取后的字符(中文占二个字符)---- 正确性待测,反正含中文计算是对的
function Utils.stringSub(str, startLen, endLen)
    local calcLen = 0
    local startId, endId = -1, -1
    local curByte, byteCount
    for i = 1, #str do
        byteCount = 1
        curByte = string.byte(str, i)
        if curByte > 0 and curByte <= 127 then
            byteCount = 1
        elseif curByte >= 192 and curByte < 223 then
            byteCount = 2
        elseif curByte >= 224 and curByte < 239 then
            byteCount = 3
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4
        end
        calcLen = calcLen + 1

        -- 判断如果为汉字,lua里默认就是三个字符，蛋疼
        if byteCount ~= 1 then
            calcLen = calcLen - 1

            if startId == -1 and (calcLen == startLen or calcLen + 1 == startLen or calcLen + 2 == startLen) then
                startId = i
            end
            if endId == -1 and (calcLen == endLen or calcLen + 1 == endLen or calcLen + 2 == endLen) then
                endId = i + 2
            end
        else
            if startId == -1 and calcLen == startLen then
                startId = i
            end
            if endId == -1 and calcLen == endLen then
                endId = i
            end
        end

        i = i + byteCount - 1
    end
    if startId == -1 then
        startId = 1
    end
    if endId == -1 then
        endId = #str
    end
    return string.sub(str, startId, endId)
end

-- 获取字符串字符长度 中文2 其他1
function Utils.GetStringLength(srcString)
    if srcString == nil then
        return 0
    end

    local len = 0
    local text = string.gmatch(srcString, "([%z\1-\127\194-\244][\128-\191]*)")
    for uchar in text do
        if #uchar ~= 1 then
            len = len + 1
        else
            len = len + 1
        end
    end

    return len
end

-- 去除首尾空白符
function Utils.Trim(s)
    return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

------------------------------------------------------------Table操作---------------------------------------------------------------

-- 判断table是否为空
function Utils.TableIsEmpty(t)
    return t == nil or next(t) == nil
end

-- 获得key值不规律的table的长度
function Utils.GetTableLength(table)
    if table == nil or type(table) ~= "table" then
        return 0
    end

    local count = 0

    for k, v in pairs(table) do
        if v ~= nil then
            count = count + 1
        end
    end

    return count
end
-- 清空table中数据
function Utils.ClearTable(table)
    if type(table) ~= "table" then
        return
    end
    for k, v in pairs(table) do
        table[k] = nil
    end
end

-- 判断table是否存在value
function Utils.isContainsValue(_table, _value)
    if type(_table) ~= "table" or _value == nil then
        return false
    end

    for k, v in pairs(_table) do
        if _value == v then
            return true
        end
    end

    return false
end
function Utils.RemoveItem(list, item)
    if (list and item) then
        local keys = {}
        for i, v in ipairs(list) do
            if (v == item) then
                table.insert(keys, i)
            end
        end
        for i, key in ipairs(keys) do
            table.remove(list, key)
        end
    end
end


function Utils.IndexOfItem(list, item)
    for i, v in ipairs(list) do
        if (v == item) then
            return i
        end
    end
end

function Utils.ConcatList(list, rangeList)
    if(list == nil or rangeList == nil)then
        return
    end
    for i, d in ipairs(rangeList) do
        table.insert(list, d)
    end
end
-- 深拷贝--
function Utils.deepCopy(obj)
    local inTable = {}
    local function Func(obj)
        if type(obj) ~= "table" then
            -- 判断表中是否有表
            return obj
        end
        local newTable = {}
        -- 定义一个新表
        inTable[obj] = newTable
        -- 若表中有表，则先把表给inTable，再用newTable去接收内嵌的表
        for k, v in pairs(obj) do
            -- 把旧表的key和Value赋给新表
            newTable[Func(k)] = Func(v)
        end
        return setmetatable(newTable, getmetatable(obj))
        -- 赋值元表
    end
    return Func(obj)
    -- 若表中有表，则把内嵌的表也复制了
end

--lua 转 string
function Utils.serialize(obj, level)
    level = level or 1
    local lua = ""
    local t = type(obj)
    if t == "number" then
        lua = lua .. obj
    elseif t == "boolean" then
        lua = lua .. tostring(obj)
    elseif t == "string" then
        lua = lua .. string.format("%q", obj)
    elseif t == "table" then
        local newLevel = level + 1
        lua = lua .. "{\n"
        for k, v in pairs(obj) do
            if (type(obj) ~= "function") then
                lua = lua .. Utils.AddTabSpace(newLevel) .. "[" .. Utils.serialize(k) .. "]=" .. Utils.serialize(v, newLevel) .. ",\n"
            end
        end
        local metatable = getmetatable(obj)
        if metatable ~= nil and type(metatable.__index) == "table" then
            for k, v in pairs(metatable.__index) do
                if (type(obj) ~= "function") then
                    lua = lua .. Utils.AddTabSpace(newLevel) .. "[" .. Utils.serialize(k) .. "]=" .. Utils.serialize(v, newLevel) .. ",\n"
                end
            end
        end
        lua = lua .. Utils.AddTabSpace(level) .. "}"
    elseif t == "nil" then
        return "nil"
    else
        -- error("can not serialize a " .. t .. " type.")
    end
    return lua
end

-- string 转 table
function Utils.unserialize(lua)
    local t = type(lua)
    if t == "nil" or lua == "" then
        return nil
    elseif t == "number" or t == "string" or t == "boolean" then
        lua = tostring(lua)
    else
        error("can not unserialize a " .. t .. " type.")
    end
    lua = "return " .. lua
    local func
    if loadstring then
        func = loadstring(lua)
    else
        func = load(lua)
    end
    if func == nil then
        return nil
    end
    return func()
end

-- 输出proto数据
function Utils.PrintProto(messageProto)
    if (ConstantValue.ForceLog and ConstantValue.DebugMode) then
        Utils.DebugLog(Utils.ParseProto(messageProto))
    end
end
-- proto 转string
function Utils.ParseProto(messageProto, level)
    return messageProto
end
-- 检测fgui对象是否被销毁（uiObject类型）
function Utils.uITargetIsNil(uiTarget)
    if nil == uiTarget or nil == uiTarget.displayObject or uiTarget.displayObject.isDisposed or uiTarget.displayObject.gameObject:Equals(nil) then
        return true
    else
        return false
    end
end

-- 检测fgui对象是否没显示（判断原生对象以及父物体）
function Utils.uITargetInactive(uiTarget)
    if nil == uiTarget or not uiTarget.visible or nil == uiTarget.displayObject
    or nil == uiTarget.displayObject.gameObject or not uiTarget.displayObject.gameObject.activeInHierarchy
    then
        return true
    else
        return false
    end
end

-- 检测unity对象是否被销毁(monoBehaviour类型)
function Utils.unityTargetIsNil(unityTarget)
    if nil == unityTarget or (CS.LPCFramework.LuaUtils.IsNil(unityTarget)) then
        return true
    else
        return false
    end
end
-- 清除从CS传过来的所有引用
function Utils.ClearTableCSRef(table)
    if type(table) ~= "table" then
        return
    end

    for k, v in pairs(table) do
        if v ~= nil then
            if type(v) == "table" then
                -- Utils.DebugError(" Clear Table :" .. tostring(v))
                Utils.ClearTableCSRef(v)
            else
                -- Utils.DebugError("type is ".. tostring (type(table[k])))
                if (type(table[k]) == "userdata") then
                    -- Utils.DebugError(" Clear Table Value :" .. tostring(table[k]))
                    table[k] = nil
                end
            end
        end
    end
end

-- 清除Table下所有引用
function Utils.ClearTableRef(table)
    if type(table) ~= "table" then
        return
    end

    for k, v in pairs(table) do
        if v ~= nil then
            if type(v) == "table" then
                -- Utils.DebugError(" Clear Table :" .. tostring(v))
                Utils.ClearTableCSRef(v)
            else
                -- Utils.DebugError("type is ".. tostring (type(table[k])))
                -- Utils.DebugError(" Clear Table Value :" .. tostring(table[k]))
                table[k] = nil
            end
        end
    end
end

-- 最小数值和最大数值指定返回值的范围。
function Utils.Clamp(v, minValue, maxValue)  
    if v < minValue then
        return minValue
    end
    if( v > maxValue) then
        return maxValue
    end
    return v 
end

-- 获取随机数组
function Utils.GetRandomSequence(minValue, maxValue, n)
    -- 随机总数组
    local sequence = {}
    -- 取到的不重复数字的数组长度
    local output = {}
    local index = 0
    for i = minValue, maxValue do
        index = index + 1
        sequence[index] = i
    end

    local endV = index
    local num = nil

    for i = 1, n do
        --随机一个数，每随机一次，随机区间-1
        num = math.random(1, endV)
        output[i] = sequence[num]
        --将区间最后一个数赋值到取到数上
        sequence[num] = sequence[endV]
        endV = endV - 1
    end
    return output
end

-- 打乱table数组
function Utils.GetRandomTable(arr)
    local tmp, index
    for i = 1, #arr - 1 do
        index = math.random(i, #arr)
        if i ~= index then
            tmp = arr[index]
            arr[index] = arr[i]
            arr[i] = tmp
        end
    end

    return arr
end
--------------------------------------------------------------日志----------------------------------------------------------------------------

Utils.tabSpace0 = ""
Utils.tabSpace1 = "    "
Utils.tabSpace2 = "        "
Utils.tabSpace3 = "            "
-- 添加空格
function Utils.AddTabSpace(level)
    local key = string.format("tabSpace%s", level)
    if (Utils[key]) then
        return Utils[key]
    else
        local tsTable = {}
        for i = 1, level do
            table.insert(tsTable, Utils.tabSpace1)
        end
        return table.concat(tsTable)
    end
end

function Utils.DebugLog(...)
    Utils.LogHandle("LOG", ...)
end

function Utils.DebugWarning(...)
    Utils.LogHandle("WARNING", ...)
end

function Utils.DebugError(...)
    Utils.LogHandle("ERROR", ...)
end

function Utils.DebugFatal(...)
    Utils.LogHandle("FATAL", ...)
end

-- 利用正则表达式对format的格式符%容错处理
function Utils.CheckFormat(str)
    -- 找出字符串中间%不对的情况（如“%q”,"%","%%%"）,这里自动补一个%转义
    str =
        string.gsub(
        str,
        "%%+[^sdfxX]",
        function(a)
            local num1, num2 = math.modf(string.len(a) / 2)
            if (num2 == 0) then
                a = "%" .. a
            end
            return a
        end
    )
    -- 判断字符串最后的%是否非法（最后连续%个数为奇数）,这里自动补一个%转义
    str =
        string.gsub(
        str,
        "%%+$",
        function(a)
            local num1, num2 = math.modf(string.len(a) / 2)
            if (num2 ~= 0) then
                a = "%" .. a
            end
            return a
        end
    )
    return str
end

function Utils.LogHandle(logType, commonOut, ...)
    local isImportanceInfo = (logType == "ERROR" or logType == "FATAL") and ConstantValue.DebugMode
    if (ConstantValue.ForceLog or isImportanceInfo) then
        local argsTable = {...}
        local output = ""
        if type(commonOut) == "string" then
            commonOut = Utils.CheckFormat(commonOut)
            local formatOut = commonOut
            if (#argsTable > 1) then
                formatOut = string.format(commonOut, ...)
            end
            if commonOut ~= formatOut then
                output = formatOut
            else
                --不含format格式符号（如“%s,%d”）,则追加
                output = commonOut
                local count = select("#", ...)
                for i = 1, count do
                    output = string.format("%s\t%s", output, tostring(argsTable[i]))
                end
            end
        else
            output = tostring(commonOut)
        end
        local format = ""
        local pushLogToServer = false
        local pushLogToScreen = false
        if logType == "LOG" then
            format = "<color=#009900>[Log] %s </color>"
            pushLogToScreen = false
        elseif logType == "WARNING" then
            format = "<color=#ffff00>[Warning] %s </color>"
            pushLogToScreen = false
        elseif logType == "ERROR" then
            format = "<color=#cc3300>[Error] %s </color>"
            pushLogToScreen = ConstantValue.DebugMode
        elseif logType == "FATAL" then
            format = "<color=#990000>[Fatal] %s </color>"
            pushLogToServer = true
            pushLogToScreen = ConstantValue.DebugMode
        end
        local logStr = string.format(format, output)
        if ConstantValue.DebugMode then
            -- 只有当编译的版本是Debug版本时, print函数才能将调试信息输出
            local stackStr = debug.traceback()
            if (ConstantValue.LogTrack) then
                logStr = logStr .. "\n" .. stackStr
            end
            print(logStr)
        end
        if (ConstantValue.DebugMode and pushLogToScreen) then
            CS.LPCFramework.LogManager.Instance:OutputToScreen(logStr, "", 5)
        end
        if pushLogToServer then
        -- DataTrunk.PlayerInfo.MiscData.C2SClientLogProto(type, output)
        end
    end
end

--------------------------------------------------------数字显示格式-----------------------------------------------------------
-- 资源显示处理
-- count : int 资源数量
function Utils.ResourceHandler(count)
    if type(count) ~= "number" then
        return
    end

    local handleDecimal = function (num)
        -- 改为了保留一位小数,无小数不显示
        -- return string.format("%.2f", num)
        return math.floor(num * 10) * 0.1
    end

    if count > 1000 then
        local trillion = 10^12
        -- 超大数字以多个字母结尾
        local zz = trillion * 10^78
        local zzz = zz * 10^78
        local ZZ = zzz * 10^78
        if count > ZZ * 1000 then
            for index = 26, 1, -1 do
                local bigNum = ZZ * 1000^index
                if count >= bigNum then
                    local ascii = 64 + index
                    return handleDecimal(count / bigNum) .. string.char(ascii, ascii, ascii)
                end
            end
        elseif count > zzz * 1000 then
            for index = 26, 1, -1 do
                local bigNum = zzz * 1000^index
                if count >= bigNum then
                    local ascii = 64 + index
                    return handleDecimal(count / bigNum) .. string.char(ascii, ascii)
                end
            end
        elseif count > zz * 1000 then
            for index = 26, 1, -1 do
                local bigNum = zz * 1000^index
                if count >= bigNum then
                    local ascii = 96 + index
                    return handleDecimal(count / bigNum) .. string.char(ascii, ascii, ascii)
                end
            end
        elseif count > trillion * 1000 then
            for index = 26, 1, -1 do
                local bigNum = trillion * 1000^index
                if count >= bigNum then
                    local ascii = 96 + index
                    return handleDecimal(count / bigNum) .. string.char(ascii, ascii)
                end
            end
        elseif count > trillion then
            return handleDecimal(count / trillion) .. "T"
        elseif count > 1000000000 then
            return handleDecimal(count / 1000000000) .. "B"
        elseif count > 1000000 then
            return handleDecimal(count / 1000000) .. "M"
        else
            return handleDecimal(count / 1000) .. "K"
        end
    else
        return tostring(math.floor(count))
    end
end

function Utils.GetCountFormat(count)
    return Utils.ResourceHandler(count)
end

-- 数量缩写 百万 万
function Utils.GetCountFormat2(count)
    if type(count) ~= "number" then
        return ""
    end

    if count >= 1000000 then
        return math.floor(count / 1000000) .. "m"
    elseif count >= 10000 then
        return math.floor(count / 1000) .. "k"
    end

    return tostring(math.floor(count))
end

-- 保留n位小数
function Utils.SetDecimal(num, place)
    if type(num) ~= "number" or type(place) ~= "number" then
        return
    end

    local dec = 1 / place
    return num - num % dec
end

-------------------------------------------------------------版本相关----------------------------------------------------------------------------------
local serverTag = nil
function Utils.GetServerTag(defaultTag)
    if serverTag == nil then
        serverTag = CS.LPCFramework.BGDownloadMgr.GetTag()
    end
    return serverTag
end

-- 获取当前的大版本号
-- to do : Kimi
function Utils.GetCurrBigVersionNum()
    return CS.LPCFramework.BGDownloadMgr.Instance.ClientVerion
end

function Utils.GetCurrCoreResVersion()
    return CS.LPCFramework.BGDownloadMgr.Instance._clientPackageCoreVersion
end

-- 获取系统语言类型
function Utils.GetSystemLanguage()
    local sLanguage = Application.systemLanguage
    local langType = LanguageType.English

    if SystemLanguage.Arabic == sLanguage then
        langType = LanguageType.Arabic
    elseif SystemLanguage.Chinese == sLanguage then
        langType = LanguageType.Chinese
    elseif SystemLanguage.Czech == sLanguage then
        langType = LanguageType.Czech
    elseif SystemLanguage.Danish == sLanguage then
        langType = LanguageType.Danish
    elseif SystemLanguage.Dutch == sLanguage then
        langType = LanguageType.Dutch
    elseif SystemLanguage.English == sLanguage then
        langType = LanguageType.English
    elseif SystemLanguage.Finnish == sLanguage then
        langType = LanguageType.Finnish
    elseif SystemLanguage.French == sLanguage then
        langType = LanguageType.French
    elseif SystemLanguage.German == sLanguage then
        langType = LanguageType.German
    elseif SystemLanguage.Hebrew == sLanguage then
        langType = LanguageType.Hebrew
    elseif SystemLanguage.Indonesian == sLanguage then
        langType = LanguageType.Indonesian
    elseif SystemLanguage.Italian == sLanguage then
        langType = LanguageType.Italian
    elseif SystemLanguage.Japanese == sLanguage then
        langType = LanguageType.Japanese
    elseif SystemLanguage.Korean == sLanguage then
        langType = LanguageType.Korean
    elseif SystemLanguage.Polish == sLanguage then
        langType = LanguageType.Polish
    elseif SystemLanguage.Portuguese == sLanguage then
        langType = LanguageType.Portuguese
    elseif SystemLanguage.Russian == sLanguage then
        langType = LanguageType.Russian
    elseif SystemLanguage.Spanish == sLanguage then
        langType = LanguageType.Spanish
    elseif SystemLanguage.Swedish == sLanguage then
        langType = LanguageType.Swedish
    elseif SystemLanguage.Turkish == sLanguage then
        langType = LanguageType.Turkish
    elseif SystemLanguage.ChineseSimplified == sLanguage then
        langType = LanguageType.Chinese
    elseif SystemLanguage.ChineseTraditional == sLanguage then
        langType = LanguageType.ChineseTraditional
    end

    return langType
end

-- 获取当前语言类型(ELoczationType)
function Utils.GetCurrLanguageType()
    return ELoczationType[Utils.GetData("SavedLang")]
end

local m_currVersionType = nil
-- type:VersionType
function Utils:SetVersionType(type)
    if type == -1 then
        m_currVersionType = nil
        return
    end

    local has = false

    for k, v in pairs(VersionType) do
        if v == type then
            has = true
            break
        end
    end

    if not has then
        return
    end

    m_currVersionType = type
end

function Utils:GetVersionType()
    if m_currVersionType then
        return m_currVersionType
    end

    return VersionType.Default
end

function Utils.GetProductName()
    return "Diablo"
end

-- 是否是海外版本
function Utils:IsOverseasVersion()
    return LuaUtils.ChannelWaterHunterTW or LuaUtils.ChannelWaterHunterLB or LuaUtils.ChannelWaterHunterMF
end

function Utils.GetOSType()
    if LuaUtils.GetDeviceType() == "ios" then
        return "1"
    end
    return "0"
end

-- 设备id
function Utils.GetDeviceID()
    if LuaUtils.bWatchTTAd then
        return CS.LPCFramework.PushMessageTool.Instance:GeDeviceID()
    else
        return UnityEngine.SystemInfo.deviceUniqueIdentifier
    end
end

-- 唯一id
function Utils.GetUniqueID()
    return LuaUtils.GetUniqueID()
end

-- 打开链接
function Utils.OpenForum(url)
    local deviceType = CS.LPCFramework.LuaUtils.GetDeviceType()
    if deviceType == "android" then
        if Utils.CanOpenInternalUrl() then
            CS.LPCFramework.PushMessageTool.Instance:OpenUrl(url)
        else
            Application.OpenURL(url)
        end
    elseif deviceType == "ios" then
        Application.OpenURL(url)
    end
end

--部分需要战斗中加速的时间shader，展示不需要
--isInShowHero:只有再战斗开始播放的时候才是false
function Utils.SetShaderTimerDynamic(isInShowHero)
    local hasVal = CS.LPCFramework.GraphicManager.isInShowHero
    if(hasVal ~= nil)then
        CS.LPCFramework.GraphicManager.isInShowHero = isInShowHero
    end
end

function Utils.SetLayer(go, layerid)
    CS.LPCFramework.LuaUtils.SetLayerRecursively(go, layerid)
end

-- 是否开启Sdk
function Utils.IsSdkEnable()
    if not Application.isEditor then
        return true
    end

    return false
end

-- 是否可以看广告
local bCanWatchAd = nil
function Utils.CanWatchAd()

    if nil ~= bCanWatchAd then
        return bCanWatchAd
    end
    
    local verType = Utils.GetVersionType()
    bCanWatchAd = true
    return bCanWatchAd
end

function Utils.LoadConfig(path)
    if nil == LocalizationMgr then return end

    local lang = LocalizationMgr.GetCurrLanguageType().name
    if lang == "CN" then
        return require(path)
    end
    local idx = string.find(path, "%.")
    if idx then
        path = string.format("%s%s%s", path:sub(1, idx), lang, path:sub(idx))
        return require(path)
    end
end

function Utils.IsCN()
    return SDKManager.Tag == SdkType.TradCN
end

-- TT穿山甲 ad app id
function Utils.GetTTADAppId()

    local appId = ""
    if LuaUtils.GetDeviceType() == "ios" then
        if LuaUtils.ChannelHappyFight then
            -- 欢乐大作战
            appId = "5031992"
        elseif LuaUtils.ChannelWaterHunterFake00 then
            --fake 00
            appId = "5031992"
        elseif LuaUtils.ChannelWaterHunter then
            -- 猎水部落
            appId = "5030921"
        elseif LuaUtils.ChannelChinaChaosTown then
            -- 混乱小镇
            appId = "5031992"
        end
    else
        if LuaUtils.ChannelHappyFight then
            -- 欢乐大作战
            appId = "5030925"
        elseif LuaUtils.ChannelWaterHunter then
            -- 猎水部落
            appId = "5031960"
        elseif LuaUtils.ChannelHappyFightYYB then
            -- 欢乐大作战 应用宝
            appId = "5030921"
        elseif LuaUtils.ChannelWaterHunterYYB then
            -- 猎水部落 应用宝
            appId = "5030921"
        elseif LuaUtils.ChannelAnimalsCity then
            -- 反斗动物城
            appId = "5036613"
        elseif LuaUtils.ChannelChinaChaosTown then
            -- 混乱小镇
            appId = "5055782"
        elseif LuaUtils.ChannelAnimalsFight then
            -- 动物大乱斗
            appId = "5037296"
        end
    end


    return appId
end

-- TT穿山甲 ad CodeId
function Utils.GetTTADCodeId()

    local codeId = ""
    if LuaUtils.GetDeviceType() == "ios" then
        if LuaUtils.ChannelHappyFight then
            -- 欢乐大作战
            codeId = "931992368"
        elseif LuaUtils.ChannelWaterHunterFake00 then
            -- fake00
            codeId = "931992368"
        elseif LuaUtils.ChannelWaterHunter then
            -- 猎水部落
            codeId = "930921189"
        elseif LuaUtils.ChannelChinaChaosTown then
            -- 混乱小镇
            codeId = "931992368"
        end
    else
        if LuaUtils.ChannelHappyFight then
            -- 欢乐大作战
            codeId = "930925051"
        elseif LuaUtils.ChannelWaterHunter then
            -- 猎水部落
            codeId = "931960077"
        elseif LuaUtils.ChannelHappyFightYYB then
            -- 欢乐大作战 应用宝
            codeId = "930921189"
        elseif LuaUtils.ChannelWaterHunterYYB then
            -- 猎水部落 应用宝
            codeId = "930921189"
        elseif LuaUtils.ChannelAnimalsCity then
            -- 反斗动物城
            codeId = "936613768"
        elseif LuaUtils.ChannelChinaChaosTown then
            -- 混乱小镇
            codeId = "945099627"
        elseif LuaUtils.ChannelAnimalsFight then
            -- 动物大乱斗
            codeId = "937296365"
        end
    end

    return codeId
end

function Utils.GetAppName()
    
    if LuaUtils.ChannelHappyFight or LuaUtils.ChannelHappyFightYYB then
        return "欢乐大作战"
    elseif LuaUtils.ChannelWaterHunterFake00 then
        return "猎水部落"
    elseif LuaUtils.ChannelWaterHunter or LuaUtils.ChannelWaterHunterYYB then
        return "猎水部落"
    elseif LuaUtils.ChannelAnimalsCity then
        return "反斗动物城"
    elseif LuaUtils.ChannelAnimalsFight then
        return "动物大乱斗"
    elseif LuaUtils.ChannelWaterHunterTW or LuaUtils.ChannelWaterHunterTWGrade then
        return "獵水部落"
    elseif LuaUtils.ChannelWaterHunterLB then
        return "The King's Army:Idle RPG"
    elseif LuaUtils.ChannelWaterHunterMF or LuaUtils.ChannelWaterHunterMFOneStore then
        return "주트라이브"
    elseif LuaUtils.ChannelWaterHunterSW then
        return "(日本) 獵水部落"
    elseif LuaUtils.ChannelChinaChaosTown then
        return "混乱小镇"
    end
    
    return "The King's Army:Idle RPG"
end

return Utils

