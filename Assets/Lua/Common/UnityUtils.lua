--Unity接口相关
local UnityUtils = {}

local UnityEngine = CS.UnityEngine
local Vector3 = UnityEngine.Vector3
local Mathf = CS.UnityEngine.Mathf

--近似值
function UnityUtils.Approximately(v1, v2)
    return Mathf.Approximately(v1, v2)
end

function UnityUtils.ApproximatelyV3(pos1, pos2)
    return Mathf.Approximately(pos1.x, pos2.x) and Mathf.Approximately(pos1.y, pos2.y) and Mathf.Approximately(pos1.z, pos2.z)
end

-- 计算两个点的距离
function UnityUtils.BetweenPos3(pos1, pos2)
    local deltaX = pos1.x - pos2.x
    local deltaY = pos1.y - pos2.y
    local deltaZ = pos1.z - pos2.z
    return math.sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ)
end
-- 计算两个点的距离(忽略Y轴)
function UnityUtils.BetweenHPos3(pos1, pos2)
    local deltaX = pos1.x - pos2.x
    local deltaZ = pos1.z - pos2.z
    return math.sqrt(deltaX * deltaX + deltaZ * deltaZ)
end

-- 距离平方，不做开跟运算
function UnityUtils.BetweenHPos3Sqrt(pos1, pos2)
    local deltaX = pos1.x - pos2.x
    local deltaZ = pos1.z - pos2.z
    return deltaX * deltaX + deltaZ * deltaZ
end

function UnityUtils.BetweenPos2(pos1, pos2)
    local deltaX = pos1.x - pos2.x
    local deltaY = pos1.y - pos2.y
    return math.sqrt(deltaX * deltaX + deltaY * deltaY)
end

-- 取中点
function UnityUtils.CenterPos3(pos1, pos2)
    return {x = (pos1.x + pos2.x) / 2, y = (pos1.y + pos2.y) / 2, z = (pos1.z + pos2.z) / 2}
end

-- 获取y轴向角度--
function UnityUtils.horizontalAngle(direction)
    return UnityEngine.Mathf.Atan2(direction.x, direction.z) * UnityEngine.Mathf.Rad2Deg
end

-- 获取z轴向角度--
function UnityUtils.Vector2Angle(direction)
    return UnityEngine.Mathf.Atan2(direction.y, direction.x) * UnityEngine.Mathf.Rad2Deg
end

UnityUtils.tempGO = nil
-- 根据Y轴角度获取向量
function UnityUtils.horizontalVector(angle)
    local a = UnityEngine.Mathf.PI / 180 * angle
    return Vector3(UnityEngine.Mathf.Cos(a), 0, UnityEngine.Mathf.Sin(a))
end

-- 计算两向量夹角--
function UnityUtils.angleAroundAxis(direA, direB, axis)
    direA = direA - Vector3.Project(direA, axis)
    direB = direB - Vector3.Project(direB, axis)
    local angle = Vector3.Angle(direA, direB)

    local factor = 1
    if Vector3.Dot(axis, Vector3.Cross(direA, direB)) < 0 then
        factor = -1
    end

    return angle * factor
end

-----------------------------查找---------------------------

--return transform[]
function UnityUtils.FindChildByTag(trans, tag)
    local r = {}
    for i = 0, trans.childCount - 1 do
        local t = trans:GetChild(i)
        if(t.tag == tag)then
            table.insert(r, t)
        end
    end
    return r
end

-------------------------------寻路-----------------------------------

--设置渲染层级
function UnityUtils.SetSortingLayer(transform, layername)
    if transform ~= nil and layername ~= nil and layername ~= "" then
        CS.LPCFramework.UnityUtils.SetSortingLayer(transform, layername)
    end
end

--设置物体layer层级
function UnityUtils.SetLayer(go, layerid)
    CS.LPCFramework.UnityUtils.SetLayerRecursively(go, layerid)
end

--设置UI粒子缩放（UI粒子缩放一定是Local模式）
function UnityUtils.SetUIScale(UIEff, scale)
    local psList = UIEff:GetComponentsInChildren(typeof(CS.UnityEngine.ParticleSystem))
    local psOldScale = {}
    for i = 0, psList.Length - 1 do
        local oldScale = psList[i].transform.localScale
        psOldScale[psList[i]:GetInstanceID()] = oldScale
        psList[i].transform.localScale = oldScale * scale
    end
    return psOldScale
end

--还原UI粒子缩放
function UnityUtils.ResetUIScale(UIEff, psOldScale)
    if UIEff ~= nil and UnityUtils.unityTargetIsNil(UIEff) ~= nil then
        local psList = UIEff:GetComponentsInChildren(typeof(CS.UnityEngine.ParticleSystem))
        for i = 0, psList.Length - 1 do
            local oldScale = psOldScale[psList[i]:GetInstanceID()]
            psList[i].transform.localScale = oldScale
        end
    end
end

function UnityUtils.ClearTrail(go)
    CS.LPCFramework.UnityUtils.ClearTrail(go)
end

return UnityUtils
