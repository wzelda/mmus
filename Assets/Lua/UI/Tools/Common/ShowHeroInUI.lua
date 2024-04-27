
local ShowHeroInUI = class()
ShowHeroInUI.RenderImage = nil
ShowHeroInUI.holder = nil
ShowHeroInUI.BaseGo = nil
ShowHeroInUI.heroPosTrans = nil
ShowHeroInUI.curGo = nil --当前的展示物体

function ShowHeroInUI:ctor(holder, bg1, bg2)
    self.holder = holder
    self.holder.visible = false
    GameObjectManager:GetFromPool(GameObjectManager.OtherPoolName, Configs.EffectPathCfg().ShowHeroPath , function(go)
        if(self.BaseGo)then
            GameObjectManager:ReturnToPool(GameObjectManager.OtherPoolName, go)
            return
        end
    
        self.BaseGo = go
        local trans = go.transform
        trans.position = Vector3(0, 10000, 0)
        self.heroPosTrans = trans:Find("HeroPos")
        local camera = trans:Find("Camera"):GetComponent(typeof(CS.UnityEngine.Camera))
        self.RenderImage = CS.LPCFramework.RenderImage(holder, camera)
        if(bg1)then
            if(bg2)then
                self:SetBackground2(bg1, bg2)
            else
                self:SetBackground(bg1)
            end
        end
    end)
end

function ShowHeroInUI:SetBackground(bg1)
    if(self.RenderImage)then
        self.RenderImage:SetBackground(bg1)
    end
end
function ShowHeroInUI:SetBackground2(bg1, bg2)
    if(self.RenderImage)then
        self.RenderImage:SetBackground(bg1, bg2)
    end
end
--
function ShowHeroInUI:OnShow(go, startPos, startRot, startScale)
    if(self.heroPosTrans)then
        self.curGo = go
        local t = go.transform
        t.parent = self.heroPosTrans
        t.localPosition = startPos or ConstantValue.V3Zero
        t.localEulerAngles = startRot or ConstantValue.V3Zero
        t.localScale = startScale or ConstantValue.V3One
        self.st = TimerManager.waitTodo(0.2,1,function() self.holder.visible = true end, nil, nil, true)
    end
end

function ShowHeroInUI:OnHide()
    self.holder.visible = false
end

function ShowHeroInUI:Close()
    self.holder.visible = false
    self.holder = nil
    TimerManager.disposeTimer(self.st)
    self.st = nil
    if(self.RenderImage)then
        self.RenderImage:Dispose()
    end
    self.RenderImage = nil
    if(not Utils.unityTargetIsNil(self.curGo))then
        self.curGo = nil
    end
    self.curGo = nil
    if(self.BaseGo)then
        GameObjectManager:ReturnToPool(GameObjectManager.OtherPoolName, self.BaseGo)
    end
    self.BaseGo = nil
end

return ShowHeroInUI