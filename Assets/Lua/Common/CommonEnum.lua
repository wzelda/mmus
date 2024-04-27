-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成

-- Common 常用的枚举

ELoczationType =
{
    AR = {                                  -- 阿拉伯                   
        name = "AR",
        showName = "阿拉伯语",
        resFile = "UI_ENG",
        langType = LanguageType.Arabic,
    },
    ZH_CN = {                               --简体中文
        name = "ZH_CN",
        showName = "中文",
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
        showName = "繁体中文",
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
        showName = "韩语",
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

-- 协议错误显示格式
EMsgErrorType = 
{
    NONE = 0,
    WAITING = 1,     -- 显示等待界面
    POPUPUI = 2,     -- 弹窗
}

-- endregion
