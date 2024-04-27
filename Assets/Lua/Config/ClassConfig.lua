--通用类定义
ClassConfig = {}

----------------------------------------------------------------------------------
function ClassConfig.EventDispatchClass()
    return require "Event.EventDispatcher"
end

----------------------------------UI----------------------------------------------
--data
function ClassConfig.PlayerDataClass()
    return require "Data.PlayerData"
end

function ClassConfig.FishDataClass()
    return require "Data.FishData"
end

function ClassConfig.SeaDataClass()
    return require "Data.SeaData"
end

function ClassConfig.AquariumDataClass()
    return require "Data.AquariumData"
end

function ClassConfig.DecorationDataClass()
    return require "Data.DecorationData"
end

function ClassConfig.BufferDataClass()
    return require "Data.BufferData"
end

function ClassConfig.AdminDataClass()
    return require "Data.AdminData"
end

function ClassConfig.AdvDataClass()
    return require "Data.AdvData"
end

function ClassConfig.TaskDataClass()
    return require "Data.TaskData"
end

function ClassConfig.FunctionOpenDataClass()
    return require "Data.FunctionOpenData"
end

function ClassConfig.AchievementDataClass()
    return require "Data.AchievementData"
end

function ClassConfig.FishShipDataClass()
    return require "Data.FishShipData"
end

function ClassConfig.ConfigDataClass()
    return require "Config.ConfigData"
end

function ClassConfig.MainBottomUIClass()
    return require "UI.Main.MainBottomUI"
end
function ClassConfig.MainTopUIClass()
    return require "UI.Main.MainTopUI"
end
function ClassConfig.IncomeUIClass()
    return require "UI.Main.IncomeUI"
end
--Tool
function ClassConfig.UITopBarClass()
    return require "UI.Tools.UITopBar"
end
function ClassConfig.TipsToolClass()
    return require "UI.Tools.TipsTool"
end
function ClassConfig.PopupAnimItemClass()
    return require "UI.Tools.PopupAnim.PopupAnimItem"
end

-----------------------------------战斗----------------------------------------

-----------以下是行为树AI----------

return ClassConfig
--endregion
