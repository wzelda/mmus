-- ==============================================================================
-- 资源池
-- ==============================================================================

local GameObjectManager = class()
--C#特效对象实例
local EffectManager = CS.LPCFramework.EffectManager.Instance
--C# 对象缓存池
local GameObjectPool = CS.LPCFramework.GamePoolManager.Instance
--C# 资源管理器
local ResourceMgr = CS.LPCFramework.ResourceMgr.Instance

local GameObject = CS.UnityEngine.GameObject
-- 池的根节点
GameObjectManager.ActorRootObj = nil

GameObjectManager.AquariumFishesPoolName = "AquariumFishes"
GameObjectManager.FightFishesPoolName = "FightFishes"


GameObjectManager.EffectPoolName = "Effect"
GameObjectManager.UIEffPoolName = "UIEffect"
GameObjectManager.BulletPoolName = "Bullet"
--所有小的临时的都用other池子
GameObjectManager.OtherPoolName = "Other"

--永久保存的池子, 除非超出最大上限, 不然一直在池里
GameObjectManager.PermanentPoolName = "Permanent"
--Lua对象缓冲池
GameObjectManager.LuaObjPoolMap = nil

function GameObjectManager:ctor()
    -- 创建一个对象池根节点
    self.ActorRootObj = GameObject.Find("SpawnActors")
    if (self.ActorRootObj == nil) then
        self.ActorRootObj = GameObject("SpawnActors")
        GameObject.DontDestroyOnLoad(self.ActorRootObj)
    end

    -- 建立弱引用表
    self.gameObjectPools = setmetatable({}, {__mode = "k"})
    self.LuaObjPoolMap = setmetatable({}, {__mode = "k"})
end

local tremove, tinsert = table.remove, table.insert

--获取lua对象(lua对象的初始化方法必须由ctor转移到Init方法)
function GameObjectManager:LoadLuaObject(classBase, ...)
    --[[local luaObj = nil
    local isCache = false
    
    local pool = self.LuaObjPoolMap[classBase]
    if(pool and #pool > 0)then
        luaObj = tremove(pool)
        --Utils.DebugLog("LoadLuaObject %s",luaObj)
        
        isCache = true
    else
        luaObj = classBase.new()
        luaObj.classBaseKey = classBase
        --print("create new lua obj", classBase)
    end
    
    if(luaObj.Init)then
        luaObj:Init(...)
    else
        print(luaObj, "has no Init func")
    end
    return luaObj, isCache]]
    local luaObj = classBase.new()
    if (luaObj.Init) then
        luaObj:Init(...)
    end
    return luaObj
end
--回收lua对象（只回收设置类classBase的对象）
function GameObjectManager:RecycleLuaObject(luaObj)
    --[[if(luaObj and luaObj.classBaseKey)then
       local luaObjPool = self.LuaObjPoolMap[luaObj.classBaseKey]
       if(not luaObjPool)then
           luaObjPool = setmetatable( { }, { __mode = 'k' })
           self.LuaObjPoolMap[luaObj.classBaseKey] = luaObjPool
       else
           if #luaObjPool >= 10 then
               return
           end
       end
       --Utils.DebugLog("RecycleLuaObject %s", luaObj)
       tinsert(luaObjPool, luaObj)
    end]]
end

--加载特效
--特效ID（effectconfig 表中的ID）
--位置，旋转，uid 可不传，将用默认值
--useflip:使用翻转特效
--loadAsync:使用异步加载
function GameObjectManager:CreateEffect(effectId, pos, rot, cb,loadAsync, isAutoQuality, Quality, IsQualityEff)
    --local resfolder = Utils.GetQualityEffectPath(isAutoQuality, Quality, IsQualityEff, effLevel)

    local effectInfo = Configs.EffectMap[effectId]
    if (effectInfo and effectInfo.res ~= nil and effectInfo.res ~= "") then
        -- 想要用翻转的特效
        --[[if useflip then
            local realResname = string.format("%s%s_flip", resfolder, effectInfo.res)    
            if ResourceMgr:ContainInternalResurces(realResname) then     
                effectInfo.realResname = realResname
            else                
                effectInfo.realResname = string.format("%s%s", resfolder, effectInfo.res)
            end            
        else]]
        if (not effectInfo.path) then
            effectInfo.path = ConstantValue.EffectResFolder .. effectInfo.res
        end
        --end
        pos = pos or ConstantValue.V3Zero
        rot = rot or Quaternion.identity
        uid = uid or 0
        loadAsync = loadAsync or false
        EffectManager:CreateFx(effectInfo, pos, rot, cb, loadAsync)
    else
        if (cb) then
            cb(nil)
        end
    end
end

function GameObjectManager:CreateEffectForCustom(effectInfo, pos, rot, cb, loadAsync)
    pos = pos or ConstantValue.V3Zero
    rot = rot or Quaternion.identity
    loadAsync = loadAsync or false
    EffectManager:CreateFx(effectInfo, pos, rot, cb, loadAsync)
end

-- 缓冲池加载
function GameObjectManager:GetFromPool(poolName, resPath, cb, pos, loadAsync)
    pos = pos or ConstantValue.V3Zero
    loadAsync = loadAsync or false
    return GameObjectPool:GetFromPool(poolName, resPath, cb, pos, loadAsync)
end

function GameObjectManager:GetAvatarFromPool(poolName, resPath, cb, pos, loadAsync)
    pos = pos or ConstantValue.V3Zero
    loadAsync = loadAsync or false
    return GameObjectPool:GetAvatarFromPool(poolName, resPath, cb, pos, loadAsync)
end

function GameObjectManager:ReturnToPool(poolName, go)
    return GameObjectPool:ReturnToPool(poolName, go)
end

--加载UI
function GameObjectManager:LoadUIPkg(pkgPath)
    return ResourceMgr:LoadUIPkg(pkgPath, function() end)
end

--卸载固定资源（AnimatorController,Texture，Sprite，Shader，Material）
local UnloadAssetFunc = CS.UnityEngine.Resources.UnloadAsset
function GameObjectManager:UnloadAsset(asset)
    return UnloadAssetFunc(asset)
end

--[[
function GameObjectManager:HasFlipEffect(effectId)

    local resfolder = Utils.GetQualityEffectPath(true)

    local effectInfo = Configs.EffectMap[effectId]
    if(effectInfo)then
        local realResname = string.format("%s%s_flip", resfolder, effectInfo.res)            
        return ResourceMgr:ContainInternalResurces(realResname)
    else
        Utils.DebugError("没有特效 %s", effectId)
        return false
    end
end]]
--清除缓存
function GameObjectManager:ReleaseAllCache()
    EffectManager:ReleaseAllCache()
    --GameObjectPool:RemoveAllPool() --方法已被删除

    --local t = {}
    --table.insert(t,GameObjectManager.OtherPoolName)
    --GameObjectPool:RemoveAllPoolExceptPool(t)
end

function GameObjectManager:OnDestroy()
    self:ReleaseAllCache()
    self.poolRootObj = nil
    self.gameObjectPools = nil
    self.LuaObjPoolMap = nil
end

return GameObjectManager
