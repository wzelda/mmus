
local PlayerPrefs = CS.UnityEngine.PlayerPrefs

local LocalizationMgr = {}

local currentLanguage = nil

-- 语言
LanguageType = {
    Invalid = 0; -- 无效语言
    Arabic = 1; -- 阿拉伯
    Chinese = 2; -- 简体中文
    ChineseTraditional = 3; -- 繁体中文
    Czech = 4; -- 捷克
    Danish = 5; -- 丹麦
    Dutch = 6; -- 荷兰
    English = 7; -- 英语
    Finnish = 8; -- 芬兰
    French = 9; -- 法语
    German = 10; -- 德语
    Hebrew = 11; -- 希伯来语
    Indonesian = 12; -- 印度尼西亚语
    Italian = 13; -- 意大利语
    Japanese = 14; -- 日语
    Korean = 15; -- 韩语
    Polish = 16; -- 波兰语
    Portuguese = 17; -- 葡萄牙语
    Russian = 18; -- 俄语
    Spanish = 19; -- 西班牙语
    Swedish = 20; -- 瑞典语
    Turkish = 21; -- 土耳其语
}

ELoczationType =
{
    AR = {                                  -- 阿拉伯                   
        name = "AR",
        showName = "阿拉伯语",
        resFile = "UI_ENG",
        langType = LanguageType.Arabic,
    },
    CN = {                               --简体中文
        name = "CN",
        showName = "简体中文",
        resFile = "UI_CN",
        langType = LanguageType.Chinese,      --服务器语言ID
    },
    ENG = {
        name = "ENG",
        showName = "English",
        resFile = "UI_ENG",
        langType = LanguageType.English,
    },

    TW = {                               --繁体中文
        name = "TW",
        showName = "繁體中文",
        resFile = "UI_ENG",
        langType = LanguageType.ChineseTraditional,
    },
    CS = {                                 --捷克
        name = "CS",
        showName = "捷克语",
        resFile = "UI_ENG",
        langType = LanguageType.Czech,
    },
    DA = {                              --丹麦
        name = "DA",
        showName = "丹麦语",
        resFile = "UI_ENG",
        langType = LanguageType.Danish,
    },
    NL = {                              -- 荷兰
        name = "NL",
        showName = "荷兰语",
        resFile = "UI_ENG",
        langType = LanguageType.Dutch,
    },
    FI = {                              -- 芬兰
        name = "FI",
        showName = "芬兰语",
        resFile = "UI_ENG",
        langType = LanguageType.Finnish,
    },
    FR = {                              -- 法语
        name = "FR",
        showName = "法语",
        resFile = "UI_ENG",
        langType = LanguageType.French,
    },
    DE = {                              -- 德语
        name = "DE",
        showName = "德语",
        resFile = "UI_ENG",
        langType = LanguageType.German,
    },
    IW = {                              -- 希伯来语
        name = "IW",
        showName = "希伯来语",
        resFile = "UI_ENG",
        langType = LanguageType.Hebrew,
    },
    ID = {                              --印度尼西亚语
        name = "ID",
        showName = "印度尼西亚语",
        resFile = "UI_ENG",
        langType = LanguageType.Indonesian,
    },
    IT = {                              -- 意大利语
        name = "IT",
        showName = "意大利语",
        resFile = "UI_ENG",
        langType = LanguageType.Italian,
    },
    JA = {                              -- 日语
        name = "JA",
        showName = "日语",
        resFile = "UI_ENG",
        langType = LanguageType.Japanese,
    },
    KO = {                              -- 韩语
        name = "KO",
        showName = "한국어",
        resFile = "UI_ENG",
        langType = LanguageType.Korean,
    },
    PL = {                              -- 波兰语
        name = "PL",
        showName = "波兰语",
        resFile = "UI_ENG",
        langType = LanguageType.Polish,
    },
    PT = {                              -- 葡萄牙语
        name = "PT",
        showName = "葡萄牙语",
        resFile = "UI_ENG",
        langType = LanguageType.Portuguese,
    },
    RU = {                              -- 俄语
        name = "RU",
        showName = "俄语",
        resFile = "UI_ENG",
        langType = LanguageType.Russian,
    },
    CA = {                              -- 西班牙语
        name = "CA",
        showName = "西班牙语",
        resFile = "UI_ENG",
        langType = LanguageType.Spanish,
    },
    SV = {                              -- 瑞典语
        name = "SV",
        showName = "瑞典语",
        resFile = "UI_ENG",
        langType = LanguageType.Swedish,
    },
    TR = {                              -- 土耳其语
        name = "TR",
        showName = "土耳其语",
        resFile = "UI_ENG",
        langType = LanguageType.Turkish,
    },
}

-- 语言显示顺序
LanguageShowOrder = {
    LanguageType.English,                -- 英语   
    LanguageType.Chinese,                -- 简体中文
    --LanguageType.ChineseTraditional,     -- 繁体中文
    --LanguageType.French,                 -- 法语
    --LanguageType.German,                 -- 德语
    --LanguageType.Japanese,               -- 日语
    --LanguageType.Italian,                -- 意大利语
    --LanguageType.Spanish,                -- 西班牙语
    --LanguageType.Portuguese,             -- 葡萄牙语
    --LanguageType.Russian,                -- 俄语  
    --LanguageType.Arabic,                 -- 阿拉伯
    --LanguageType.Indonesian,             -- 印度尼西亚语 
    --LanguageType.Czech,                  -- 捷克
    --LanguageType.Danish,                 -- 丹麦
    --LanguageType.Dutch,                  -- 荷兰
    --LanguageType.Finnish,                -- 芬兰        
    --LanguageType.Hebrew,                 -- 希伯来语      
    --LanguageType.Korean,                 -- 韩语
    --LanguageType.Polish,                 -- 波兰语  
    --LanguageType.Swedish,                -- 瑞典语
    --LanguageType.Turkish,                -- 土耳其语
}

LocalizationMgr.LocType = nil
LocalizationMgr.ShowLocID = false

local curlang = nil

--初始化
function LocalizationMgr.initialize()
    -- LocalizationMgr.LocType = ELoczationType.ZH_CN
    local langName = PlayerPrefs.GetString("SavedLang") 
    --if langName == "ZH_CN" then langName = "CN" end  
    local langType = ELoczationType[langName]
    if nil ~= langType then      
        LocalizationMgr.SetLanguage(langType)
    else        
        --Utils.DebugError(Application.systemLanguage)
        -- 国内版本 默认中文
        local verType = Utils:GetVersionType()
        if verType == VersionType.China or VersionType.TapTap == verType or verType == VersionType.ChinaIOS or verType == VersionType.ZW then
            LocalizationMgr.SetLanguage(ELoczationType.CN)
        elseif verType == VersionType.TW or verType == VersionType.TWIOS then
            LocalizationMgr.SetLanguage(ELoczationType.TW)
        elseif verType == VersionType.LB or verType == VersionType.LBIOS then
            LocalizationMgr.SetLanguage(ELoczationType.ENG)
        elseif verType == VersionType.MF or verType == VersionType.MFIOS then
            LocalizationMgr.SetLanguage(ELoczationType.KO)
        elseif SystemLanguage.Chinese == Application.systemLanguage or
            SystemLanguage.ChineseSimplified == Application.systemLanguage then
            LocalizationMgr.SetLanguage(ELoczationType.CN)
        elseif SystemLanguage.English == Application.systemLanguage then
            LocalizationMgr.SetLanguage(ELoczationType.ENG)
        else
            LocalizationMgr.SetLanguage(ELoczationType.ENG) --大佬说默认英语
        end
    end
end

function LocalizationMgr.SetLanguage(_loctype)    
    if _loctype ~= nil then
        if LocalizationMgr.LocType ~= _loctype then            
            LocalizationMgr.LocType = _loctype
            
            local newLanguage = require ("Config.Localization.".._loctype.name)
            if not newLanguage then
                print("!!!!!!!!!1 没有找到语言文件: ".._loctype)
                return
            end
            
            currentLanguage = newLanguage
            curlang = _loctype
            -- 设置UIPackage的语言(还没有翻译文件，暂时先注释)
            --CS.LPCFramework.LuaUtils.SetLanguage(ConstantValue.FairyLannuageFolder..LocalizationMgr.LocType.resFile)
            -- 设置缓存中组件的语言
            --刷新当前页面的组件
            EventDispatcher:Dispatch(Event.RefreshLoc)

            -- TODO 根据语言切换字体

            -- 保存语言设置
            PlayerPrefs.SetString("SavedLang", _loctype.name)

            -- 同步服务器
            if nil ~= PlayerData and nil ~= PlayerData.Datas.ChatData then
                PlayerData.Datas.ChatData:NewC2SSetLanguageMsg(_loctype.langType)
            end
        end
    end
end

local lpeg = require "lpeg"
local C,R,P,Ct, Cs = lpeg.C, lpeg.R, lpeg.P, lpeg.Ct, lpeg.Cs
local digit = R('09')

local serverStr = C(digit^1) * P('=') * Ct(C(digit^1) * ('|' * C(digit^1))^0)
local gsub = string.gsub


local lastParam = {}

local function bigsup (input, input1, input2)
    -- print("input to bigsup: " .. input .. ", " .. input1 .. ", " .. input2)
    local index = tonumber(input) + 1
        
    -- for k, v in ipairs(lastParam) do print(k..": "..v) end
    
    if index <= #lastParam then
        local num = tonumber(lastParam[index])
        if not num then
            Utils.DebugError("参数竟然不是数字!!! ")
            return input1
        elseif num > 1 then
            return input2
        else
            return input1
        end
    else
        Utils.DebugError("多语言提供的参数不够!!! ")
        return input1
    end
end

local function sup (input)
    local index = tonumber(input) + 1
    if index <= #lastParam then
        return Utils.ResourceHandler(tonumber(lastParam[index]))
    else
        Utils.DebugError("多语言提供的参数不够!!! ")
        return "?"
    end
end

function LocalizationMgr.GetCurrLanguageType()
    if curlang ~= nil then
        return curlang
    end
end

local serverBigSub = Cs(((P"{{" * C(digit^1) * P'|' * C((1-P'|') ^ 1) * P'|' * C((1-P'}}') ^ 1) *  P"}}")/bigsup + (P'{'*C(digit^1)*P'}')/sup + 1)^0)


local function Localize(key)
    return currentLanguage[key] or key
end

_G.Localize = Localize

-- key num 20000+  client excel
function _G.LocalizeExt(key,specialParams)
    local mainStr = Localize(key)
    if specialParams and #specialParams > 0 then
        lastParam = specialParams
        local result = serverBigSub:match(mainStr)
        lastParam = nil
        return result
    else
        return mainStr
    end
end

function LocalizationMgr.getServerLocStr(key)
    if not key then
        return ""
    end
        
    local match,match1 = serverStr:match(key)
    if not match then
        return Localize(key)
    end
    
    local mainStr = Localize(match)
    lastParam = match1
    local result = serverBigSub:match(mainStr)
    lastParam = nil
    return result
end

function LocalizationMgr.GetParamLoc(desc,newParams)
    for word in string.gmatch(desc, "{{%d+|%w+|%w+}}") do

        local tabStr = {}
        --Utils.DebugError(word)
        if word ~= nil then
                    
            for detail in string.gmatch(word,"%w+") do
                        
                --Utils.DebugError(detail)
                table.insert(tabStr, detail)
            end

            if #tabStr ~= 3 then
                        
                Utils.DebugError("Locazation Fail! " .. desc)
                break
            end

            local index = tonumber(tabStr[1])

            if (index + 1) > #newParams or (index + 1) < 1 then
                        
                Utils.DebugError("Locazation Fail! " .. desc)
                break
            end
                    
            if newParams[index + 1] == nil then
                        
                Utils.DebugError("Locazation Fail! " .. desc)
                break
            end

            local paramnum = tonumber(newParams[index + 1])
            if paramnum == nil then
                        
                Utils.DebugError("Locazation Fail! " .. desc)
                break
            end

            local show = "";

            --Utils.DebugError("paramnum : " .. tostring(paramnum))

            if paramnum > 1 then show = tabStr[3] 
            else show = tabStr[2] end
               
            desc = string.gsub(desc, word, string.format("%s", show))

        end                    
    end   

    return desc
 end


--获取随机库
function LocalizationMgr.GetRandomNameConfig()
    local verType = Utils.GetVersionType()
    if verType == VersionType.TWIOS or verType == VersionType.TW then
        return require "Config.RandomNameTradConfig"
    elseif verType == VersionType.LB or verType == VersionType.LBIOS then
        return require "Config.RandomNameEngConfig"
    elseif verType == VersionType.MF or verType == VersionType.MFIOS then
        return require "Config.RandomNameKorConfig"
    end

    return require "Config.RandomNameConfig"
end

-- 销毁
function LocalizationMgr.onDestroy() 
end

return LocalizationMgr
--endregion
