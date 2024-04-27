--客户端配置表
local Configs = {}

function Configs.LevelConfig( )
    return require "Config.LevelConfig"
end

function Configs:ErrorConfig()
    return require "Config.ErrorCodeConfig"
end

--来源
function Configs.SourceConfig()
    return require "Config.SourceConfig"
end

return Configs
