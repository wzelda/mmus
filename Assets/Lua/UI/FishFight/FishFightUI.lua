local FishFightUI = UIManager.PanelFactory(UIInfo.FishFightUI)

FishFightUI.HidePrePanel = true

FishFightUI.BallWaitSpeed = 50
FishFightUI.BallThrowSpeed = 2500
FishFightUI.NoPowerSpeed = 50
FishFightUI.AddPowerSpeed = 500
FishFightUI.BallPullSpeed = 150
FishFightUI.NeedleSpeed = 40
FishFightUI.MinAreaAngle = -33
FishFightUI.MaxAreaAngle = 33
FishFightUI.MinNeedleAngle = -46
FishFightUI.MaxNeedleAngle = 46
FishFightUI.BiteShakeX = 20
FishFightUI.BiteShakeY = 8
FishFightUI.ShakeMaxTime = 1.5
FishFightUI.ShakeTime = 0
FishFightUI.HalfAreaAngle = FishFightUI.MaxNeedleAngle -  FishFightUI.MaxAreaAngle
FishFightUI.MinAngle = FishFightUI.MinAreaAngle - FishFightUI.HalfAreaAngle
FishFightUI.MaxAngle = FishFightUI.MaxAreaAngle + FishFightUI.HalfAreaAngle
FishFightUI.State = FishStateEnum.None
FishFightUI.Touching = false
FishFightUI.randomAngle = nil
FishFightUI.yMoveNeed = 15;
FishFightUI.xAreaRequire = 15;

function FishFightUI:GetPercent()
    return math.floor(100 * (1 - (self.percent or 1)))
end

function FishFightUI:CloseUI(ingroe)
    local duration = TimerManager.getCurrentClientTime() - self.startTime

    if not ingroe then
        PlayerData.Datas.FishData:GiveUpFishing(self.itemFish.productConfig.ID)
        if PlayerData.Datas.FishData.GiveUpTimes >= 2 then
            local multiple = 2
            local popinfo = {}
            popinfo.title = Localize("GiveUpTips")
            popinfo.okStr = Localize("UnlockRightNow")
            popinfo.cancelStr = Localize("GiveUp")
            popinfo.okInfo = {index = 1}
            popinfo.sureCallback = function ()
                SDKManager:PlayAD(function()
                    AnalyticsManager.onEndPlay("手动钓鱼", self.itemFish.productConfig.ID, 0, "成功", 100, self.critDamageCount, duration)
                    UIManager.CloseUI(UIInfo.FishFightUI)
                    EventDispatcher:Dispatch(Event.FISH_FIGHT_END)
                    
                    AnalyticsManager.onADButtonShow("激励视频", "新的发现_鱼种", "新的发现")
                    UIManager.OpenUI(UIInfo.ItemPopupUI, nil, nil, "FishReward", self.itemFish, function(ad)
                        if self.itemFish.productConfig.EnableAD and ad then
                            SDKManager:PlayAD(function()
                                PlayerData.Datas.FishData:DiscoverFishReward(self.itemFish.productConfig, true)
                                EventDispatcher:Dispatch(Event.ADD_FISH_EFFECT)
                                EventDispatcher:Dispatch(Event.ITEMPOP_GETREWARD, self.itemFish.productConfig.RewardType == CommonRewardType.Diamond and 2 or 1)
                            end, "新的发现_鱼种", "新的发现")
                        else
                            PlayerData.Datas.FishData:DiscoverFishReward(self.itemFish.productConfig)
                            EventDispatcher:Dispatch(Event.ADD_FISH_EFFECT)
                            EventDispatcher:Dispatch(Event.ITEMPOP_GETREWARD, self.itemFish.productConfig.RewardType == CommonRewardType.Diamond and 2 or 1)
                        end
                    end)
                    PlayerData.Datas.FishData:AddFish(self.itemFish.productConfig.ID)
                end, "手动钓鱼_直接解锁", "手动钓鱼")
            end
            popinfo.cancelCallback = function ()
                AnalyticsManager.onEndPlay("手动钓鱼", self.itemFish.productConfig.ID, 0, "退出", self:GetPercent(), self.critDamageCount, duration)
                UIManager.CloseUI(UIInfo.FishFightUI)
                EventDispatcher:Dispatch(Event.FISH_FIGHT_END)
            end
            AnalyticsManager.onADButtonShow("激励视频", "手动钓鱼_直接解锁", "手动钓鱼")
            UIManager.OpenPopupUI(UIInfo.PopupUI, popinfo)
        else
            AnalyticsManager.onEndPlay("手动钓鱼", self.itemFish.productConfig.ID, 0, "退出", self:GetPercent(), self.critDamageCount, duration)
            UIManager.CloseUI(UIInfo.FishFightUI)
            EventDispatcher:Dispatch(Event.FISH_FIGHT_END)
        end
    else
        AnalyticsManager.onEndPlay("手动钓鱼", self.itemFish.productConfig.ID, 0, "成功", 100, self.critDamageCount, duration)
        UIManager.CloseUI(UIInfo.FishFightUI)
        EventDispatcher:Dispatch(Event.FISH_FIGHT_END)
    end
    EventDispatcher:Dispatch(Event.SHOW_INCOME, 0,true)
end


function FishFightUI:ShowPromptEffect()
    UIManager.ShowEffect(ClickEffectType.PromptEffect,self.CtrlBtn:LocalToRoot(self.CtrlBtn.size / 2), UISortOrder.ClickEffect)
end

function FishFightUI:HidePromptEffect(effectType,xy)
    UIManager.HideEffect(ClickEffectType.PromptEffect)
end

function FishFightUI:WaitThrow()
    self.State_C.selectedIndex = 0
    if self.randomAngle == nil then
        self.randomAngle = math.random( FishFightUI.MinAreaAngle,FishFightUI.MaxAreaAngle )
    end
    self.AreaCom.rotation = self.randomAngle
    self.MinSelectAngle = self.randomAngle - FishFightUI.HalfAreaAngle
    self.MaxSelectAngle = self.randomAngle + FishFightUI.HalfAreaAngle
    self.NeedleAngle = 0
    self.BallAngle = 0
    self.IsTurnRight = true
    self.BallComponent.visible = true
    self.State = FishStateEnum.WaitToThrow
end

function FishFightUI:Throw()
    self.State_C.selectedIndex = 1
    self.BallComponent.alpha = 0.5
    self.CtrlBtn.alpha = 0.5
    self.CtrlBtn.touchable = false
    self.State = FishStateEnum.Throw
    -- self.Button_Return.visible = false
    self:HidePromptEffect()
    EventDispatcher:Dispatch(Event.FISH_THROW)
end

function FishFightUI:WaitBite()
    self.State = FishStateEnum.WaitFishBite
end

function FishFightUI:FishBite()
    self.BallComponent.alpha = 0.5
    self.CtrlBtn.alpha = 0.5
    self.CtrlBtn.touchable = true
    self.ShakeTime = 0
    self.State = FishStateEnum.FishBite
end

local function TouchBegin()
    if  FishFightUI.State  == FishStateEnum.Fight or FishFightUI.State  == FishStateEnum.InAir then
        EventDispatcher:Dispatch(Event.FISH_PLAYER_TOUCHBEGIN)
        UIManager.HideEffect(ClickEffectType.PromptEffect)
        FishFightUI.CtrlBtn.title = ""
        FishFightUI.Touching = true;
    end
end

function FishFightUI:Fight()
    self.State_C.selectedIndex = 1
    self.BallComponent.alpha = 1
    self.CtrlBtn.alpha = 1
    self.CtrlBtn.touchable = true
    self:ResetBtnPos()
    -- self.HpBar.visible = true
    -- self.HpBar.max = 10000
    self:ShowPromptEffect()
    self.CtrlBtn.title = Localize("PlayerFish")
    if FishFightUI.Touching  then
        TouchBegin()
    end
    
    self.State = FishStateEnum.Fight
end

function FishFightUI:InAir()
    self.State_C.selectedIndex = 1
    -- self.HpBar.visible = false
    self.CtrlBtn.touchable = true
    self.BallComponent.alpha = 1
    self.CtrlBtn.alpha = 1
    EventDispatcher:Remove(Event.FISH_STAGE_TOUCH,self.UpdateTouchPos,self)
    self.State = FishStateEnum.InAir
end

function FishFightUI:CriticalStrikeChance()
    self.State_C.selectedIndex = 2
    -- self.HpBar.visible = false
    self.Critted = false
    self.CtrlBtn.touchable = false
    self.startTouchPos = nil
    self.lastTouchPos = nil
    EventDispatcher:Dispatch(Event.FISH_PLAYER_TOUCHEND)
    EventDispatcher:Add(Event.FISH_STAGE_TOUCH,self.UpdateTouchPos,self)
    FishFightUI.Touching = false;
    self.State = FishStateEnum.CriticalStrikeChance
end

function FishFightUI:PullBack()
    self.State_C.selectedIndex = 1
    self.ShakeTime = 0
    -- self.HpBar.visible = false
    self.State = FishStateEnum.PullBack
end

function FishFightUI:PullUp()
    self.State_C.selectedIndex = 1
    self.BallComponent.visible = false
    self:HidePromptEffect()
    self.Effect_Scale:Play()
    self.Effect_Shark:Play()
    FishFightUI.State = FishStateEnum.PullUp
end

function FishFightUI:SwicthState(type)
    self.State = type
    if  self.State == FishStateEnum.WaitToThrow then
        self:WaitThrow()
    elseif FishStateEnum.WaitFishBite ==  self.State then
        self:WaitBite()
    elseif FishStateEnum.FishBite ==  self.State then
        self:FishBite()
        self:ShowSpeedLine(true)
    elseif FishStateEnum.Fight ==  self.State then
        self:Fight()
    elseif FishStateEnum.CriticalStrikeChance ==  self.State then
        self:CriticalStrikeChance()
    elseif FishStateEnum.Crit ==  self.State then
        self:ShowSpeedLine(true)
    elseif FishStateEnum.InAir ==  self.State then
        self:InAir()
    elseif FishStateEnum.PullBack ==  self.State then
        self:PullBack()
    elseif FishStateEnum.PullUp ==  self.State then
        self:PullUp()
    elseif FishStateEnum.HunterJump ==  self.State then
        self.Effect_Warn:Play()
    elseif FishStateEnum.Show ==  self.State then
        self:CloseUI(true)
    end
end

function FishFightUI:ResetBtnPos()
    self.CtrlBtn.x = self.CtrlInitX
    self.CtrlBtn.y = self.CtrlInitY
    self.BallComponent.x = self.CtrlInitX
    self.BallComponent.y = self.CtrlInitY
end

function FishFightUI:ShowTip(content)
    self.TipText.text = content
    self.Effect_Tip:Play()
end

function FishFightUI:ShowSpeedLine(_oneShoot)
    if self.Wrap == nil then
        local function callBack(wrap_)
            self.Wrap= wrap_
        end
        CommonUIUtils.CreateUIModelFromPool(GameObjectManager.UIEffPoolName,"Prefabs/Particle/waibao/XY/Eff_Fishing_suduxian.prefab",self.Graph,callBack, nil,25)
    else
        self.Wrap.visible = true
    end
    if _oneShoot then
        if self.timer == nil then
            self.timer = TimerManager.newTimer( 1.2, false, true, nil,nil,function()
                self:HideSpeedLine()
            end)
        else
            self.timer:resetMax(1.2)
        end
        self.timer:start()
    end
end

function FishFightUI:HideSpeedLine()
    if self.Wrap then
        self.Wrap.visible = false
    end
end

function FishFightUI:OnOpen(randomAngle,itemFish, playConfig, levelLogic)
    EventDispatcher:Dispatch(Event.SHOW_INCOME, self.tabIndex,false)
    self.randomAngle = randomAngle
    self.playConfig = playConfig
    self.itemFish = itemFish
    --self.UI.sortingOrder = UISortOrder.FishFightUI
    self.Effect_Shark = self.UI:GetTransition("Effect_Shark")
    self.Window = self.UI:GetChild("n1")
    self.BallComponent = self.Window:GetChild("BallComponent")
    self.GoodText = self.UI:GetChild("n2"):GetChild("text")
    self.Effect_Good = self.UI:GetTransition("Effect_Good")
    self.CtrlBtn = self.Window:GetChild("CtrlBtn")
    self.BallBg = self.Window:GetChild("BallBg")
    self.AreaCom = self.Window:GetChild("AreaCom")
    self.AreaEffect = self.AreaCom:GetTransition("Effect")
    self.AreaController = self.AreaCom:GetController("State_C")
    self.Needle = self.Window:GetChild("Needle")
    self.CircleCom = self.Window:GetChild("CircleCom")
    self.HpBar = self.Window:GetChild("HpBar")
    self.State_C = self.Window:GetController("State_C")
    self.Effect_Scale = self.Window:GetTransition("Effect_Scale")
    self.Button_Return = self.Window:GetChild("Button_Return")
    self.Effect_Tip = self.Window:GetTransition("Effect_Tip")
    self.Effect_Warn = self.Window:GetTransition("Effect_Warn")
    self.TipText = self.Window:GetChild("Tip"):GetChild("text")
    self.warnText = self.Window:GetChild("warnTip"):GetChild("n2"):GetChild("Text")
    self.warnTitle = self.Window:GetChild("warnTip"):GetChild("n2"):GetChild("title")
    self.Graph = self.Window:GetChild("Graph")
    self.warnText.text = Localize("KillTheHunter")
    self.warnTitle.text = "[color=#ffffff,#e6c251]"..Localize("KillTheHunter")
    self.Button_Return.visible = true
    -- self.DamageCom = self.Window:GetChild("DamageCom")
    -- self.DamageText = self.DamageCom:GetChild("text")
    -- self.DamageEffect = self.DamageCom:GetTransition("Effect")
    -- self.HpBar.visible = false
    -- self.DamageCom.visible = false
    self.CtrlInitX = self.CtrlBtn.x
    self.CtrlInitY = self.CtrlBtn.y
    self.CriticalMaxX = self.CircleCom.x + self.CircleCom.width*0.5
    self.CriticalMinX = self.CircleCom.x - self.CircleCom.width*0.5
    self.CriticalMaxY = self.CircleCom.y + self.CircleCom.height*0.5
    self.CriticalMinY = self.CircleCom.y - self.CircleCom.height*0.5
    self:ShowPromptEffect()
    self:WaitThrow()

    self.startTime = TimerManager.getCurrentClientTime()

    -- 引导
    CommonUIObjectManager:Add(UIKey.FishCtrlBtn, self.CtrlBtn)
end

function  FishFightUI:EventAllocation(type)
    self:SwicthState(type)
end

function  FishFightUI:UpdateHp(value, transform)
    self.percent = value / self.playConfig.Hp
end

function  FishFightUI:CritDamage(value, transform)
    self.DamageCom.visible = true
    self.DamageText.text = value
    self.DamageCom.xy = LuaUtils.WorldToScreenPoint(transform.gameObject)
    self.DamageEffect:Play()
    self.critDamageCount = self.critDamageCount + 1
end

local function CtrlBtnClick()
    local angle = FishFightUI.NeedleAngle
    if  FishFightUI.State == FishStateEnum.WaitToThrow then
        if FishFightUI.NeedleAngle >= FishFightUI.MinSelectAngle and FishFightUI.NeedleAngle <= FishFightUI.MaxSelectAngle then
            FishFightUI:Throw()
            FishFightUI.GoodText.text = Localize("Good")
            FishFightUI.Effect_Good:Play()
            -- FishFightUI:ShowTip(Localize("Good"))
        else
            FishFightUI:ShowTip(Localize("Bad"))
        end
        FishFightUI:SetAreaColor()
    end
end

local function TouchEnd()
    if  FishFightUI.State  == FishStateEnum.Fight or FishFightUI.State  == FishStateEnum.InAir then
        EventDispatcher:Dispatch(Event.FISH_PLAYER_TOUCHEND)
        FishFightUI:ShowPromptEffect()
        FishFightUI.CtrlBtn.title = Localize("PlayerFish")
        FishFightUI.Touching = false;
    end
end

-- 子类绑定各种事件
function FishFightUI:OnRegister()

    EventDispatcher:Add(Event.FISH_CALL_UI, self.EventAllocation, self)
    EventDispatcher:Add(Event.FISH_STAGE_TOUCH,self.CheckTouchState,self)
    EventDispatcher:Add(Event.APPLICATION_FOCUS_CHANGE,self.FocusChange,self)
    EventDispatcher:Add(Event.FISH_UPDATE_HP, self.UpdateHp, self)
    self.Button_Return.onClick:Add(function()
        self:CloseUI()
    end)
    self.CtrlBtn.onClick:Add(CtrlBtnClick)
    self.CtrlBtn.onTouchBegin:Add(TouchBegin)
    self.CtrlBtn.onTouchEnd:Add(TouchEnd)
end

function FishFightUI:OnShow()
    
end

function FishFightUI:OnHide()
end

-- 强制刷新,比如网络事件监听，切换语言包，断线重连等
function FishFightUI:OnRefresh(...)
end


function FishFightUI:CheckTouchState(_bool)
    if _bool then
        TouchEnd()
    end
end

-- 解绑各类事件
function FishFightUI:OnUnRegister()
    self.CtrlBtn.onClick:Clear()
    self.CtrlBtn.onTouchBegin:Clear()
    self.CtrlBtn.onTouchEnd:Clear()
    self.Button_Return.onClick:Clear()
    EventDispatcher:Remove(Event.FISH_CALL_UI, self.EventAllocation, self)
    EventDispatcher:Remove(Event.FISH_STAGE_TOUCH,self.CheckTouchState,self)
    EventDispatcher:Remove(Event.APPLICATION_FOCUS_CHANGE,self.FocusChange,self)
    EventDispatcher:Remove(Event.FISH_UPDATE_HP, self.UpdateHp, self)
end

function FishFightUI:UpdateNeedleAngle()
    self.Needle.rotation = self.NeedleAngle
end
function FishFightUI:UpdateBallAngle()
    self.BallComponent.rotation = self.BallAngle
end

function FishFightUI:SetAreaColor()
    self.AreaEffect:Play()
end

function FishFightUI:WaitThrowUpdate()
    if self.IsTurnRight then
        if self.NeedleAngle >= self.MaxAngle then
            self.IsTurnRight = false
        else
            self.NeedleAngle = self.NeedleAngle + self.NeedleSpeed * TimerManager.fixedDeltaTime
        end
    else
        if self.NeedleAngle <= self.MinAngle then
            self.IsTurnRight = true
        else
            self.NeedleAngle = self.NeedleAngle - self.NeedleSpeed * TimerManager.fixedDeltaTime
        end
    end
    if self.BallAngle >= 360 then
        self.BallAngle = 0
    end
    self.BallAngle  = self.BallAngle  + self.BallWaitSpeed * TimerManager.deltaTime
    self:UpdateNeedleAngle()
    self:UpdateBallAngle()
end

function FishFightUI:ThrowUpdate()
    if self.BallAngle <= -360 then
        self.BallAngle = 0
    end
    self.BallAngle  = self.BallAngle  - self.BallThrowSpeed * TimerManager.deltaTime
    self:UpdateBallAngle()
end

function FishFightUI:WaitBiteUpdate()
    if self.BallAngle >= 360 then
        self.BallAngle = 0
    end
    self.BallAngle  = self.BallAngle  + self.BallWaitSpeed * TimerManager.deltaTime
    self:UpdateBallAngle()
end

function FishFightUI:Shake()
    if self.ShakeTime >= self.ShakeMaxTime then
        return
    end
    self.ShakeTime = self.ShakeTime + TimerManager.deltaTime
    self.CtrlX = math.random( - self.BiteShakeX, self.BiteShakeX)
    self.CtrlY = math.random( - self.BiteShakeY, self.BiteShakeY)
    self.CtrlX = self.CtrlInitX + self.CtrlX
    self.CtrlY = self.CtrlInitY + self.CtrlY
    self.CtrlBtn.x = self.CtrlX
    self.CtrlBtn.y = self.CtrlY
    self.BallComponent.x = self.CtrlX
    self.BallComponent.y = self.CtrlY
end

function FishFightUI:FightUpdate()
    if FishFightUI.Touching then
        if self.BallAngle >= 360 then
            self.BallAngle = 0
        end
        self.BallAngle  = self.BallAngle  + self.AddPowerSpeed * TimerManager.deltaTime
    else
        if self.BallAngle <= -360 then
            self.BallAngle = 0
        end
        self.BallAngle  = self.BallAngle  - self.NoPowerSpeed * TimerManager.deltaTime
    end
    self:UpdateBallAngle()
end

function FishFightUI:UpdateTouchPos(pos)
    if self.startTouchPos == nil then
        self.startTouchPos = pos
    end
    self.lastTouchPos = pos
    if self.yMoveNeed and self.lastTouchPos.y - self.startTouchPos.y >= self.yMoveNeed 
    and self.lastTouchPos.x - self.startTouchPos.x > - self.xAreaRequire
    and self.lastTouchPos.x - self.startTouchPos.x < self.xAreaRequire then
        self.Critted = true
        EventDispatcher:Dispatch(Event.FISH_CRIT_SUCCESS)
        EventDispatcher:Dispatch(Event.CG_CRIT_SUCCESS)
        self.BallComponent.alpha = 0.5
        self.CtrlBtn.alpha = 0.5
    end
end

function FishFightUI:CheckTouchState(pos)
    if not FishFightUI.Touching and self.State == FishStateEnum.Fight then
        local xy = self.CtrlBtn.xy
        local size = xy + self.CtrlBtn.size
        local touchPos = Vector2(pos.x / UIContentScaler.scaleFactor, (Screen.height - pos.y) / UIContentScaler.scaleFactor)
        if touchPos.x >= xy.x and touchPos.x <= size.x and touchPos.y >= xy.y and touchPos.y <= size.y then
            TouchBegin()
        end
    end
end

function FishFightUI:CriticalChanceUpdate()
    if not self.Critted and self.CtrlBtn.x >= self.CriticalMinX and self.CtrlBtn.x <= self.CriticalMaxX
    and self.CtrlBtn.y >= self.CriticalMinY and self.CtrlBtn.y <= self.CriticalMaxY then
        -- 抽他
        self.Critted = true
        EventDispatcher:Dispatch(Event.FISH_CRIT_SUCCESS)
        self.CtrlBtn.touchable = false
        self.BallComponent.alpha = 0.5
        self.CtrlBtn.alpha = 0.5
        self:ResetBtnPos()
    end
end

function FishFightUI:PullBackUpdate()
    -- if self.Touching then
        if self.BallAngle >= 360 then
            self.BallAngle = 0
        end
        self.BallAngle  = self.BallAngle  + self.AddPowerSpeed * TimerManager.deltaTime
    -- else
    --     if self.BallAngle <= -360 then
    --         self.BallAngle = 0
    --     end
    --     self.BallAngle  = self.BallAngle  - self.NoPowerSpeed * TimerManager.deltaTime
    -- end
    self:UpdateBallAngle()
end

function FishFightUI:BarUpdate(tranform,value,criticalValue)

end

function FishFightUI:OnUpdate()
    if  self.State == FishStateEnum.WaitToThrow then
        self:WaitThrowUpdate()
    elseif FishStateEnum.Throw ==  self.State then
        self:ThrowUpdate()
    elseif FishStateEnum.WaitFishBite ==  self.State then
        self:WaitBiteUpdate()
    elseif FishStateEnum.FishBite ==  self.State then
        self:Shake()
    elseif FishStateEnum.Fight ==  self.State then
        self:FightUpdate()
    elseif FishStateEnum.CriticalStrikeChance ==  self.State then
        -- self:CriticalChanceUpdate()
    elseif FishStateEnum.InAir ==  self.State then
        self:FightUpdate()
    elseif FishStateEnum.PullBack ==  self.State then
        self:Shake()
        self:PullBackUpdate()
    end
end

-- 关闭
function FishFightUI:OnClose()
    UIManager.HideEffect(ClickEffectType.PromptEffect)
    if self.timer then
        self.timer= TimerManager.disposeTimer(self.timer) 
    end
end

return FishFightUI