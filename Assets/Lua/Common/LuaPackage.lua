--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

LuaPackage = {}


function LuaPackage.Load(luapath)
    if luapath == nil then    
       return    
    end

    return require(luapath)
end

function LuaPackage.UnLoad(luapath)
    if nil == luapath then
        return
    end

    package.loaded[luapath] = nil
    _G[luapath] = nil    
end


--endregion
