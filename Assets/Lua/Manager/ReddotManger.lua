local ReddotManger = {}

RedDotType =
{
    Normal = 0,
    Fish = 1, -- 钓鱼
    FishItemBtn = 2, -- 钓鱼列表组员按钮
    Aquarium = 3, -- 观赏馆
    AquariumItemBtn = 4, -- 观赏馆列表组员按钮
    Study = 5, -- 进修界面
    Task = 6, -- 成就任务
    NewFishMap = 7, -- 下一个钓鱼场景可以解锁
    BuildNewAquarium = 8, -- 可以修建新的观赏馆
    FishShip = 9, -- 远洋捕捞红点
    xxx = 200,
}

AnchorType =
{
    Center = {AlignType.Center,VertAlignType.Middle},-- 中间
    TopLeft = {AlignType.Left,VertAlignType.Top},-- 左上
    TopRight = {AlignType.Right,VertAlignType.Top},-- 右上
    BottomLeft = {AlignType.Left,VertAlignType.Bottom},-- 左下
    BottomRight = {AlignType.Right,VertAlignType.Bottom},-- 右下
}

-- 根据具体红点类型 可以定制红点形势  默认使用Normal路径的红点
ReddotManger.RedDotComPaths =
{
    [RedDotType.Normal] = "RedDotComponent",
    [RedDotType.xxx] = "RedDotComponent",
}

ReddotManger.EffectComPaths =
{
    [RedDotType.Normal] = "Prefabs/Particle/waibao/UI/Eff_UI_tixingkuosankuang.prefab",
    [RedDotType.FishItemBtn] = "Prefabs/Particle/waibao/UI/Eff_UI_tixingkuosankuang.prefab",
    [RedDotType.xxx] = "Prefabs/Particle/waibao/UI/EFF_UI_anniukuosan.prefab",
}

-- 需要暂时屏蔽的红点类型
ReddotManger.DisableRedDots =
{
    [RedDotType.xxx] =  true;
}

ReddotManger.RedDotPool = {}
-- 整体管理红点是否显示
ReddotManger.ShowRedDot = true

local function RedDotClass()
    local t = {}
    t.Events = {}
    t.FuncConditions = {}
    t.BoolConditions = {}
    function t:Create(redDotType,anchorType,com,offsetX,offsetY)
        if redDotType == nil or anchorType == nil or com == nil then
            Utils.DebugWarning("Create RedDot Failed ",redDotType,anchorType,com)
            return
        end
        offsetX = offsetX or 0
        offsetY = offsetY or 0
        self.redDotType = redDotType
        self.redDotComName = ReddotManger.RedDotComPaths[self.redDotType] or ReddotManger.RedDotComPaths[RedDotType.Normal]
        UIManager.CreateFairyCom("UI/Library/Library", "Library", self.redDotComName, false, function(ui, pkgId)
            self.dot = ui
            self.PkgId = pkgId
            com:AddChild(self.dot)

            local alignX,alignY = unpack(anchorType)
            if alignX == AlignType.Left then
                self.dot.x = 0 + offsetX - ui.initWidth
            elseif alignX == AlignType.Center then
                ui:AddRelation(com, RelationType.Center_Center)
                self.dot.x = com.initWidth*0.5 + offsetX - ui.initWidth
            else
                ui:AddRelation(com, RelationType.Right_Center)
                self.dot.x = com.initWidth + offsetX - ui.initWidth
            end
            
            if alignY == VertAlignType.Top then
                self.dot.y = 0 + offsetY - ui.initHeight *0.5
            elseif alignY == VertAlignType.Center then
                self.dot.y = com.initHeight*0.5 + offsetY - ui.initHeight *0.5
            else
                self.dot.y = com.initHeight + offsetY - ui.initHeight *0.5
            end

            self:Refresh()
        end)
        -- self.dot
    end

    function t:CreateEffect(redDotType,anchorType,com,scale,offsetX,offsetY)
        if redDotType == nil or anchorType == nil or com == nil then
            Utils.DebugWarning("Create RedDot Failed ",redDotType,anchorType,com)
            return
        end
        offsetX = offsetX or 0
        offsetY = offsetY or 0
        scale = scale or 1
        self.redDotType = redDotType
        self.redDotComName = ReddotManger.EffectComPaths[self.redDotType] or ReddotManger.EffectComPaths[RedDotType.Normal]
        local graph = GGraph()
        com:AddChild(graph)
        local function callBack(wrap_)
            self.effect = wrap_
            local alignX,alignY = unpack(anchorType)
            if alignX == AlignType.Left then
                self.effect.x = 0 + offsetX
            elseif alignX == AlignType.Center then
                self.effect.x = com.initWidth * 0.5 + offsetX
            else
                self.effect.x = com.initWidth + offsetX
            end
            
            if alignY == VertAlignType.Top then
                self.effect.y = 0 + offsetY
            elseif alignY == VertAlignType.Middle then
                self.effect.y = com.initHeight*0.5 + offsetY
            else
                self.effect.y = com.initHeight + offsetY
            end

            self:Refresh()
        end
        CommonUIUtils.CreateUIModelFromPool(GameObjectManager.UIEffPoolName,ReddotManger.EffectComPaths[self.redDotType],graph,callBack, scale)
    end

    function t:Refresh()
        local ui = self.effect or self.dot
        if ui then
            self.Show = true
            for i, v in ipairs(self.FuncConditions) do
                if not v() then
                    self.Show = false
                    break
                end
            end
            if self.Show then
                for i, v in ipairs(self.BoolConditions) do
                    if not v then
                        self.Show = false
                        break
                    end
                end
            end
            ui.visible = self.Show and ReddotManger.ShowRedDot and not ReddotManger.DisableRedDots[self.redDotType]
        end
    end
    -- 设置红点判断的条件(可传多个,可传入判断方法和bool值)
    function t:SetConditions(...)
        self.FuncConditions = {}
        self.BoolConditions = {}
        for k , v in pairs({...}) do
            if type(v) == "function" then
                table.insert( self.FuncConditions, v)
            end
            if type(v) == "boolean" then
                table.insert( self.BoolConditions, v)
            end
        end
        -- 如果实例已经存在 直接根据条件刷新
        if self.dot or  self.effect then
            self:Refresh()
        end
    end
    -- 设置红点监听的事件 当这个事件发生时 刷新红点(可传多个)
    function t:SetEventListener(...)
        for k , v in pairs({...}) do
            if v == nil then
                Utils.DebugWarning("RedDot.AddEventListener trans a useless 'event'")
                return
            end
            if self.Events[v] == nil then
                EventDispatcher:Add(v, self.Refresh, self)
            end
            self.Events[v] = v
        end
    end

    function t:Destroy()
        for k, v in ipairs(self.Events) do
            EventDispatcher:Remove(v, self.Refresh, self)
        end
        self.Events ={}
       
        self.FuncConditions ={}
        self.BoolConditions ={}
        if self.effect then
            CommonUIUtils.ReturnUIModelToPool(self.effect,GameObjectManager.UIEffPoolName)
            self.effect = nil
        end
        if  self.dot then
            UIManager.DisposeFairyCom(self.PkgId, self.dot)
            self.dot = nil
        end
    end

    return t
end
-- redDotType 红点类型 方便定位具体红点
-- anchorType对齐类型 左上 右上 左下 右下 中间
-- com 红点的关联的按钮
-- offsetX,offsetY 根据具体情况进行偏移调整 默认可以不传
function ReddotManger:CreateRedDot(redDotType,anchorType,com,offsetX,offsetY)
    local redDot = nil
    if self.RedDotPool[com] == nil then
        redDot = RedDotClass()
        redDot:Create(redDotType,anchorType,com,offsetX,offsetY)
        self.RedDotPool[com] = redDot
    else
        redDot = self.RedDotPool[com]
    end
    return redDot
end

-- 创建特效类的红点
function ReddotManger:CreateEffect(redDotType,anchorType,com,offsetX,offsetY)
    local redDot = nil
    if self.RedDotPool[com] == nil then
        redDot = RedDotClass()
        redDot:CreateEffect(redDotType,anchorType,com,offsetX,offsetY)
        self.RedDotPool[com] = redDot
    else
        redDot = self.RedDotPool[com]
    end
    return redDot
end

-- function ReddotManger:ClearRedDot(redDotType)

-- end

return ReddotManger