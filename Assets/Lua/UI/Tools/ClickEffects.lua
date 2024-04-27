-- 提示
local clickEffects = { }

clickEffects.Effects = {}
clickEffects.Graphs = {}
clickEffects.EffectPaths =
{
    [ClickEffectType.Normal] = "",
    [ClickEffectType.Gold] = "Prefabs/Particle/waibao/UI/EFF_UI_jinbidiaoluo.prefab",
    [ClickEffectType.Bar] = "Prefabs/Particle/waibao/UI/EFF_UI_nengliangtiao2.prefab",
    [ClickEffectType.CollectGold] = "Prefabs/Particle/waibao/UI/EFF_UI_jinbishouji.prefab",
    [ClickEffectType.TouchWave] = "Prefabs/Particle/waibao/UI/Eff_UI_dianji.prefab",
    [ClickEffectType.PromptEffect] = "Prefabs/Particle/waibao/UI/Eff_UI_anniukuosanchixu.prefab",
    [ClickEffectType.DiamondEffect] = "Prefabs/Particle/waibao/UI/Eff_UI_zuanshishouji.prefab",
    [ClickEffectType.GoldShanKuangEffect] = "Prefabs/Particle/waibao/UI/EFF_UI_jinbishanguang.prefab",
    [ClickEffectType.DmShanKuangEffect] = "Prefabs/Particle/waibao/UI/EFF_UI_jinbishanguang.prefab",
    [ClickEffectType.RewardTail] = "Prefabs/Particle/waibao/UI/Eff_UI_shouyituowei.prefab",
}
-- 显示
function clickEffects:ShowEffect(effectType,xy,sortingOrder, offset, scale, extraInfo)
    sortingOrder = sortingOrder or UISortOrder.ClickEffect
    if self.EffectPaths[effectType] == nil then
        return
    end
    local wrap = self.Effects[effectType]
    local function handleExtraInfo()
        if extraInfo then
            local wrap = self.Effects[effectType]
            if extraInfo.rotation then
                wrap.wrapTarget.transform.rotation = Quaternion.Euler(extraInfo.rotation)
            else
                wrap.wrapTarget.transform.rotation = Quaternion.identity
            end
            if extraInfo.startpos and extraInfo.targetpos then
                local graph = self.Graphs[effectType]
                local dur = extraInfo.movedur or 1
                graph.xy = extraInfo.startpos
                graph:TweenMove(extraInfo.targetpos,dur):OnComplete(function ()
                    wrap.visible = false
                    if extraInfo.cb then
                        extraInfo.cb(extraInfo.obj)
                    end
                    if extraInfo.evt then
                        EventDispatcher:Dispatch(extraInfo.evt)
                    end
                end)
            end
        end
    end

    if wrap == nil then
        local graph = GGraph()
        graph.sortingOrder = sortingOrder
        self.Graphs[effectType] = graph
        GRoot.inst:AddChild(graph)
        local function callBack(wrap_)
            self.Effects[effectType] = wrap_
            wrap_.renderingOrder = sortingOrder
            wrap_:SetPositionOffset(xy, offset or Vector3.zero)
            handleExtraInfo()
        end
        CommonUIUtils.CreateUIModelFromPool(GameObjectManager.UIEffPoolName,self.EffectPaths[effectType],graph,callBack, nil, scale)
    else
        wrap:SetPositionOffset(xy, offset or Vector3.zero)
        wrap.visible = false
        wrap.visible = true
        handleExtraInfo()
    end
end

function clickEffects:HideEffect(effectType,xy)
    if self.Effects[effectType] then
        self.Effects[effectType].visible = false
    end
end

-- 销毁
function clickEffects:destroy()
    for k , v in pairs(self.Effects) do
        CommonUIUtils.ReturnUIModelToPool(v,GameObjectManager.UIEffPoolName)
    end
    self.Effects = {}
    for k , v in pairs(self.Graphs) do
        v:Dispose()
    end
    self.Graphs = {}
end

return clickEffects

