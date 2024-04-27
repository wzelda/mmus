--[[
    引导遮罩页面
    author:{Mingo}
    time:2020-04-07 12:09:21
]]

local GuideLayer = {} --UIManager.PanelFactory(UIInfo.GuideLayer)
local panel = nil

local focus = nil
local hidePos = Vector2(-1000,-1000)

-- 引导的遮罩页面
local maskLayer = nil

-- 当前是否正在显示引导内容
local isShow = false

RepeatShaderTool = CS.RepeatUIShaderTool

local layerParent = nil


--初始化引导遮罩层
function GuideLayer:InitLayer(callback)
    if maskLayer==nil then
        UIManager.CreateFairyCom(
            UIInfo.GuideLayer.UIPackagePath,
            UIInfo.GuideLayer.UIName,
            UIInfo.GuideLayer.UIComName,
            true,
            function (ui)
                maskLayer = ui
                layerParent = maskLayer.parent
                maskLayer.sortingOrder = UISortOrder.NewGuide
                maskLayer.touchable = true
                maskLayer.visible = false

                self.finger = UIPackage.CreateObject(UIInfo.GuideLayer.UIName, "Component_WeakGuideFinger")
                self.finger.sortingOrder = UISortOrder.NewGuide
                self.finger.touchable = false
                self.finger.visible = false
                GRoot.inst:AddChild(self.finger)
                self.focus = maskLayer:GetChild("window")
                self.focus.xy = hidePos
                local bg=maskLayer:GetChild("bg")
                self.effectRoot = maskLayer:GetChild("clickEffect")
                bg.onClick:Add(function() self:ClickQuickTip() end)

                if callback then
                    callback()
                end
            end
        )
    else
        if callback then
            callback()
        end
    end
end

-- 获取引导提示特效
function GuideLayer:GetFocusEffect(effectName)
    if self.currentEffect==nil then
        local function effectCallback(wrap)
            self.currentEffect = wrap
        end  
        CommonUIUtils.CreateUIModelFromPool(
            GameObjectManager.UIEffPoolName ,
            effectName,
            self.effectRoot, effectCallback
        )
    end
end

local function GetObjShowCenter(obj)
    local result = Vector2(obj.width/2,obj.height/2) 
    return result
end

local currentStepConfig = nil
local tipConfig = nil

-- 显示引导页面
function GuideLayer:DoGuideStep(config,tip)
    currentStepConfig = config
    tipConfig = tip
    if currentStepConfig.eventBegin ~= "" and currentStepConfig.eventBegin~= nil then
        EventDispatcher:Add(currentStepConfig.eventBegin,self.Show,self)
    else
        self:Show()
    end
end

local function onClickAnyUI()
    if currentStepConfig.mask ~= false then return end
    GuideLayer:Hide()
end

function GuideLayer:ClearEvents()
    if currentStepConfig then 
        EventDispatcher:Remove(currentStepConfig.eventBegin,self.Show,self)
        EventDispatcher:Remove(currentStepConfig.eventEnd,self.GuideEndEvent,self)
    end
    EventDispatcher:Remove(Event.CG_CLICK_BTN,self.OnClickGuideBtn,self)
    EventDispatcher:Remove(Event.OPENED_TAB,self.Hide,self)
    EventDispatcher:Remove(Event.OPENED_UI,self.Hide,self)
    Stage.inst.onTouchMove:Remove(onClickAnyUI)
end

function GuideLayer:AddWeakEvt()
    EventDispatcher:Add(Event.OPENED_TAB,self.Hide,self)
    EventDispatcher:Add(Event.OPENED_UI,self.Hide,self)
    Stage.inst.onTouchMove:Add(onClickAnyUI)
end

function GuideLayer:SetFoucs()
    local tip = currentStepConfig.tips[1]
    local targetKey = tip.param01
    local targetObj = nil
    if type(tip.param02) == 'number' then
        targetObj = CommonUIObjectManager:Get(targetKey):GetChildAt(tip.param02)
    else
        targetObj = CommonUIObjectManager:Get(targetKey)
    end
    if nil == targetObj or Utils.uITargetInactive(targetObj) then
        Utils.DebugError("未配置引导按钮或按钮不可见")
        self:Hide()
        return
    end

    if self.timer then
        self.timer:onComplete()
    end
    self.timer = TimerManager.intervalTodo(-1,0.1,
        function()
            self.focus.xy = targetObj:LocalToRoot(GetObjShowCenter(targetObj))
            self.focus.y = self.focus.y - GRoot.inst.y
            if not tip.hideFinger then
                self.finger.visible = true
                self.finger.xy = self.focus.xy
                self.finger.rotation = 0
                if not CommonUIUtils.InScreen(self.finger) then
                    self.finger.rotation = 180
                end
            end

            self.focus.width = targetObj.width
            self.focus.height = targetObj.height
            -- 滑动区域
            if tipConfig.param03 then
                self.focus.xy = self.focus.xy + 0.5 * tipConfig.param03
                self.focus.width = self.focus.width + math.abs(tipConfig.param03.x)
                self.focus.height = self.focus.height + math.abs(tipConfig.param03.y)
            end
        end,
        nil, nil, true
    )

    self:GetFocusEffect("Eff_UI_tishidianji")
    targetObj:AddChild(self.effectRoot)
    self.effectRoot.xy = GetObjShowCenter(targetObj)
    
    EventDispatcher:Add(currentStepConfig.eventEnd,self.GuideEndEvent,self)
    EventDispatcher:Add(Event.CG_CLICK_BTN,self.OnClickGuideBtn,self)
end

function GuideLayer:Show()
    if currentStepConfig.mask then --弱引导不可以暂停战斗
        GuideManager:SetPause(true)
    end
    isShow = true
    if currentStepConfig.eventBegin ~= "" then
        EventDispatcher:Remove(currentStepConfig.eventBegin,self.Show,self)
    end
    self:InitLayer(function ()
        if currentStepConfig.mask then
            maskLayer.visible = true
        elseif maskLayer then
            maskLayer.visible = false
            self:AddWeakEvt()
        end
    
        TimerManager.waitTodo(
            currentStepConfig.delayTime,
            1,
            function ()
                -- print("延迟开始SetFoucs:",currentStepConfig.stepId)
                self:SetFoucs()  
            end,
            nil,nil,true
        )
    end)
end

-- 点击了引导配置按钮
function GuideLayer:OnClickGuideBtn(key)
    if key == tipConfig.param01 then
        self:Hide()
    end
end

function GuideLayer:ClickQuickTip()
    --TimerManager.waitTodo(1,1,function()
        
    --end)
end

function GuideLayer:GuideEndEvent(...)
    local isEnd = true
    if currentStepConfig.endFunc and currentStepConfig.endFunc ~= "" then
        isEnd = currentStepConfig.endFunc(...) == true
    end
    if isEnd then
        self:Hide()
    end
end


-- 关闭引导页面
function GuideLayer:Hide()
    isShow = false
    self:Despose()
    EventDispatcher:Dispatch(Event.GUIDE_STEP_OVER)
end

function GuideLayer:GMHide()
    if(currentStepConfig~=nil) then
        EventDispatcher:Remove(currentStepConfig.eventEnd,self.GuideEndEvent,self)
    end
    self:Despose()
end

function GuideLayer:Despose()
    GuideManager:SetPause(false)
    self:ClearEvents()
    isShow = false
    if self.timer then
        self.timer:onComplete()
        self.timer = nil
    end
    if maskLayer then
        layerParent:AddChild(maskLayer)
        maskLayer:AddChild(self.effectRoot)
        self.effectRoot.xy = hidePos
        maskLayer.visible = false
    end
    if self.finger then
        self.finger.xy = hidePos
        self.finger.visible = false
    end

    if self.currentEffect then
        CommonUIUtils.ReturnUIModelToPool(self.currentEffect,GameObjectManager.UIEffPoolName)
        self.currentEffect = nil
    end
end

return GuideLayer