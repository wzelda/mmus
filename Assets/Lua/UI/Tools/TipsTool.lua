
-- 小弹框工具
local TipsTool = class()

-- tips类型
TipsType = 
{
    TYPE_NONE = -1,
    TYPE_TOP_BAR = 0,               -- 顶部栏资源tip
    TYPE_HERO_SKILL = 1,            -- 英雄技能tip
    TYPE_PRIZE_ITEM = 2,            -- 奖励、物品tip
    TYPE_BEAST_TIP = 3,             -- 神兽tips
    TYPE_EQUIP_TIP = 4,             -- 装备tips
    TYPE_TEXT_ONLY = 6,             -- 纯文字tips(天梯积分)
    TYPE_CRIRIS = 7,                -- 动物危机tips
}


TipsTool.blurFilter = nil
TipsTool.curPopup = nil
TipsTool.closeCallBack = nil

local closeFunction = nil
local tipsShowSortingOrder = 600

--点击滑动相关
TipsTool.timeinterval = nil
TipsTool.touchbeginpos  = nil
TipsTool.touchendpos = nil
TipsTool.clickcheckmaxdis = 5
TipsTool.clickDeltaTime = 0.25

TipsTool.tabCurShowTips = nil
TipsTool.curShowTipsUI = nil
TipsTool.curShowTipsPkg = nil
TipsTool.tipEndCallback = nil
TipsTool.tipsTimer = nil
TipsTool.tweenerTips = nil
TipsTool.curTipsType = TipsType.TYPE_NONE
local m_touchBeginEvents = nil
local m_lpgs = nil

function TipsTool:ctor()
    self.blurFilter = BlurFilter();
    self.blurFilter.blurSize = 0.02;
    self.timeinterval = UnityEngine.Time.realtimeSinceStartup
    local touchBeginFunc = function(context)
        self.touchbeginpos = context.inputEvent.position
        self.timeinterval = UnityEngine.Time.realtimeSinceStartup
    end
    local touchMoveFunc = function()
    end
    local touchEndFunc = function(context)
        self.touchendpos = context.inputEvent.position
        local time = UnityEngine.Time.realtimeSinceStartup
         if (time - self.timeinterval) < self.clickDeltaTime and Vector2.Distance(self.touchbeginpos, self.touchendpos) <= self.clickcheckmaxdis then
            self:CheckPopup(content)
        end
    end
    Stage.inst.onTouchBegin:AddCapture(touchBeginFunc);
    Stage.inst.onTouchMove:AddCapture(touchMoveFunc);
    Stage.inst.onTouchEnd:AddCapture(touchEndFunc);
    m_touchBeginEvents = {}
    m_lpgs = {}

    --EventDispatcher:Add(Event.REMOVE_CUR_TIPS, self.RemoveCurTips, self)
    EventDispatcher:Add(Event.OPENED_UI, self.CancelLpgs, self)
end

function TipsTool:CancelLpgs()
    if m_lpgs and #m_lpgs > 0 then
        for _, v in ipairs(m_lpgs) do
            v:Cancel()
        end
    end
end

function TipsTool:GetTipsPos(sourceCom, tipsUI, posType)
-- 设置顶部资源tips位置
        
    local curPos = self:GetRelativePos(sourceCom, tipsUI, posType)
    curPos = sourceCom:LocalToRoot(curPos)
    curPos = GRoot.inst:RootToLocal(curPos)
    if curPos.x < 0 then
        
        if posType == RelativeDir.LeftUp then
            
            return self:GetTipsPos(sourceCom, tipsUI, RelativeDir.RightUp)
        end
    end

    if curPos.y < 0 then
        
        if posType == RelativeDir.LeftUp then
            
            return self:GetTipsPos(sourceCom, tipsUI, RelativeDir.LeftDown)
        elseif posType == RelativeDir.RightUp then
            
            return self:GetTipsPos(sourceCom, tipsUI, RelativeDir.RightDown)
        end
    end
    
    return curPos, posType
end

-- 设置通用tips位置
function TipsTool:SetTipsPosition(sourceCom, newItemTips, addOffsetX)
    local posX1 = nil
    local posX2 = nil
    posX1 = 47
    posX2 = newItemTips.width
    if nil == addOffsetX then
        addOffsetX = 0
    end
    --轴心先归0
    local oldPivotX = sourceCom.pivotX
    local oldPivotY = sourceCom.pivotY
    sourceCom:SetPivot(0, 0)

    local sourceComItemPos = sourceCom:LocalToGlobal(Vector2.zero)
    local xy = ConstantValue.V2One 
    local offestX = 0
    local offestY = 0
    --Tips位置
    local sourcComCenterX = sourceComItemPos.x + sourceCom.actualWidth / 2
    local sourcComCenterY = sourceComItemPos.y + sourceCom.actualHeight / 2 - 60

    if(sourcComCenterX <= Screen.width / 2 and sourcComCenterY <= Screen.height / 2)then        --右下
        newItemTips:GetController("Status").selectedIndex = 0
        xy = sourceCom:LocalToRoot(Vector2(sourceCom.width / 2, sourceCom.height))
        offestX = -posX1
    elseif(sourcComCenterX > Screen.width / 2 and sourcComCenterY <= Screen.height / 2)then    --左下
        newItemTips:GetController("Status").selectedIndex = 1
        xy = sourceCom:LocalToRoot(Vector2(sourceCom.width / 2, sourceCom.height))
        offestX = -posX2 - addOffsetX
    elseif(sourcComCenterX <= Screen.width / 2 and sourcComCenterY > Screen.height / 2)then    --右上
        newItemTips:GetController("Status").selectedIndex = 2
        xy = sourceCom:LocalToRoot(Vector2(sourceCom.width / 2, 0))
        offestX = -posX1
        offestY = -newItemTips.height
    elseif(sourcComCenterX > Screen.width / 2 and sourcComCenterY > Screen.height / 2)then    --左上
        newItemTips:GetController("Status").selectedIndex = 3
        xy = sourceCom:LocalToRoot(Vector2(sourceCom.width / 2, 0))
        offestX = -posX2 - addOffsetX
        offestY = -newItemTips.height
    end

    newItemTips.xy = Vector2(xy.x + offestX, xy.y + offestY)
    newItemTips.xy = newItemTips.xy - UIUtils.PhoneXOffest
    --轴心还原
    sourceCom.pivotX = oldPivotX
    sourceCom.pivotY = oldPivotY
end

-- 展示用Tips创建(所有公共tips，都存放于Common中)
-- 弹出货币说明
function TipsTool:AddCurrencyTips(sourceCom, currencyId, posOffest)
    local initFunc = function(tipsUI)
        tipsUI:GetController("Status").selectedIndex = 2
        local title = tipsUI:GetChild("Itemtitle_Label")
        local content = tipsUI:GetChild("Itemdescription_Label")

        local currencyTypeData =  PlayerData.Datas.CurrencyData:GetCurrencyTypeById(currencyId)
        if currencyTypeData then
            title.text = LocalizationMgr.getServerLocStr(currencyTypeData.name)
            content.text = LocalizationMgr.getServerLocStr(currencyTypeData.desc)
        end

        local pos = self:GetTipsPos(sourceCom, tipsUI, RelativeDir.LeftDown)
        pos = pos + Vector2(-170, 20)
        if(posOffest)then
            pos = pos + posOffest
        end
        tipsUI.xy = pos
    end

    local closeFunc = function(itemTips)
        
        --itemTips:GetChild("Itemdescription_Label").text = ""
    end
    self:CreateTipsOnPress(sourceCom, "Item_Tips", initFunc, closeFunc, nil, RelativeDir.LeftDown, TipsType.TYPE_TOP_BAR)   
    self:RemoveCurTips(TipsType.TYPE_TOP_BAR)    
end

-- 纯文字tips
function TipsTool:AddTextOnlyTips(sourceCom, desc, offset)
    local initFunc = function(tipsUI)
        if type(desc) == "string" then
            tipsUI.title = desc
        end
        
        self:SetTipsPosition(sourceCom, tipsUI)
        tipsUI.xy = tipsUI.xy + Vector2(-50, 20)

        if offset then
            tipsUI.xy = tipsUI.xy + offset
        end
    end

    self:CreateTipsOnPress(sourceCom, "Label_TextOnlyTips", initFunc, nil, nil, RelativeDir.LeftUp, TipsType.TYPE_TEXT_ONLY)
    self:RemoveCurTips(TipsType.TYPE_TEXT_ONLY)   
end

-- 物品tips
-- name/desc:定制的名字和描述)
-- heroCamp:穿戴该装备的英雄阵营
function TipsTool:ShowItemTips(sourceCom, amountInfo, name, desc, heroCamp)
    local initFunc = function(itemTips)
        local comItem = itemTips:GetChild("Item_Comp")
        local textName = itemTips:GetChild("Name_Label")
        local textCount = itemTips:GetChild("Count_Label")
        local textDesc = itemTips:GetChild("Desc_Label")

        if textDesc then
            if type(desc) == "string" then
                textDesc.text = desc
            else
                textDesc.text = LocalizationMgr.getServerLocStr(amountInfo.desc)
            end
        end

        local count = ""
        if textCount then
            textCount.text = ""
        end

        if amountInfo.typeId == AmountType.CURRENCY then      -- 货币
            itemTips:GetChild("text1").text = LocalizeExt("描述：")
            if amountInfo.id ~= CurrencyTypeName.Exp.id then
                count = PlayerData.Datas.CurrencyData:GetHaveCountById(amountInfo.id)
                textCount.text = string.format(LocalizeExt(20672), Utils.GetCountFormat(count))
            end

            if type(name) == "string" then
                textName.text = CommonUIUtils.SetContentColorUbbByQuality(amountInfo.name, amountInfo.quality)
            else
                textName.text = CommonUIUtils.SetContentColorUbbByQuality(LocalizationMgr.getServerLocStr(amountInfo.name), amountInfo.quality)
            end
            CommonUIUtils.SetCommonCurrency(comItem, amountInfo)
        elseif amountInfo.typeId == AmountType.HERO then      -- 英雄
            local isOwn = PlayerData.Datas.HeroData:IsOwn(amountInfo.id)
            if isOwn then
                textCount.text = LocalizeExt(20269)
            else
                textCount.text = ""
            end
            CommonUIUtils.SetHeroTextNameByQuality(textName, name, amountInfo.quality)
            CommonUIUtils.SetCommonHero(comItem, amountInfo)
        elseif amountInfo.typeId == AmountType.EQUIP then      -- 装备
            -- 基础信息
            itemTips:GetChild("equipPower").text = amountInfo.config.equip_power
            itemTips:GetChild("partClass").text = string.format("(%s)", LocalizationMgr.getServerLocStr(amountInfo.config.class))
            itemTips:GetChild("qualityLabel"):GetController("c1").selectedIndex = amountInfo.quality

            -- 属性
            local listAttri = itemTips:GetChild("MainAttrList")
            local specialStat = itemTips:GetChild("specialStat")
            specialStat.text = ""
            if amountInfo.config.part_type == EquipPartType.WU_QI then
                specialStat.text = LocalizationMgr.getServerLocStr(amountInfo.config.weapon_desc)
            end
            listAttri:RemoveChildrenToPool()
            local value, showValue = nil
            local showStats = {}
            for k, stat in ipairs(amountInfo.config.max_stat.stats) do
                if amountInfo.config.part_type ~= EquipPartType.WU_QI then
                    table.insert(showStats, stat)
                else
                    if stat.type == EActorAttribute.ATK then
                        table.insert(showStats, stat)
--[[                     else
                        local icon, name = CommonUIUtils.GetPropIconAndName(stat.type)
                        local showValue = nil
                        local value = math.max(0, stat.value)
                        local per = math.max(0, stat.per)
                        value = value * (1 + per / 10000)
                        if EAttrPerMap[stat.type] then
                            showValue = string.format("%s%%", math.floor(value * 0.01))
                        else
                            if value > 0 or (value == 0 and per == 0)then
                                showValue = math.floor(value)
                            elseif per > 0 then
                                showValue = string.format("%s%%", math.floor(per * 0.01))
                            else
                                showValue = "0%"
                            end
                        end
                        specialStat.text = string.format("特性:+%s%s", showValue, name) ]]
                    end
                end
            end
            
            for k, stat in ipairs(showStats) do
                local item = listAttri:AddItemFromPool()
                value, showValue = ClassConfig.HeroPropClass():GetPropValue(stat.type, stat.value, stat.per)
                local icon, name = CommonUIUtils.GetPropIconAndName(stat.type)
                item.icon = icon
                item.title = name
                item:GetChild("Text_Value").text = "+" .. showValue
            end
            listAttri:ResizeToFit(#showStats)
            local hasSkill = amountInfo.quality > Quality.DQ_A
            local skill_C = itemTips:GetController("skill_C")
            if hasSkill and amountInfo.config.part_type == EquipPartType.WU_QI
            or amountInfo.config.part_type == EquipPartType.SHI_PIN then
                skill_C.selectedIndex = 0
            else
                skill_C.selectedIndex = 1
            end
            -- 技能描述
            itemTips:GetChild("skillText").text = LocalizeExt("随机获得技能")

            -- 套装
            local suitName = itemTips:GetChild("suitName")
            local suitList = itemTips:GetChild("suitList")
            local actorSuitCount = PlayerData.Datas.UserData:GetPlayerSuitCount(PlayerData.Datas.UserData.actorEquipsSlotMap, amountInfo.config.suit)
            local profitCount = 0
            suitName.text = ""
        
            suitList:RemoveChildrenToPool()
            if amountInfo.config.suit then
                local suitData = ConfigData:GetEquipSuitDataById(amountInfo.config.suit)
                if suitData then
                    local profits = suitData.profits
                    local suitMaxPieces = 0
                    for i, profit in ipairs(profits) do
                        local suitItem = suitList:AddItemFromPool()
                        local state_C = suitItem:GetController("color_C")
                        suitMaxPieces = profit.pieces
                        suitItem.title = LocalizationMgr.getServerLocStr(profit.desc)
                        profitCount = profitCount + 1
                        state_C.selectedIndex = 2
                        if profit.pieces <= actorSuitCount then
                            state_C.selectedIndex = 1
                        end
                    end
                    suitName.text = string.format("%s(%s/%s)", LocalizationMgr.getServerLocStr(suitData.name), actorSuitCount, suitMaxPieces)
                end
            end
            suitList:ResizeToFit(profitCount)

            textName.text = CommonUIUtils.SetContentColorUbbByQuality(LocalizationMgr.getServerLocStr(amountInfo.name), amountInfo.quality)
            CommonUIUtils.SetEquipItem(comItem, amountInfo)
        elseif amountInfo.typeId == AmountType.USABLE_ITEM then
            local itemInfo = PlayerData.Datas.ItemData.itemMap[amountInfo.id]
            if(itemInfo)then
                count = itemInfo.count
            else
                count = 0
            end
            textCount.text = string.format(LocalizeExt(20673), count)
            itemTips:GetChild("text1").text = LocalizeExt("描述：")

            local nameStr = nil
            if type(name) == "string" then
                nameStr = amountInfo.name
            else
                nameStr = LocalizationMgr.getServerLocStr(amountInfo.name)
            end

            textName.text = CommonUIUtils.SetContentColorUbbByQuality(nameStr, amountInfo.quality)
            CommonUIUtils.SetCommonGoods(comItem, amountInfo)
            if amountInfo.usableItemType == UsableItemType.UIT_HERO_CHIP then
                itemTips:GetChild("qualityLabel"):GetController("c1").selectedIndex = amountInfo.quality
            end
        elseif amountInfo.typeId == AmountType.GEM then
            local gemInfo = PlayerData.Datas.GemData.gemMap[amountInfo.id]
            if gemInfo then
                count = gemInfo.count
            else
                count = 0
            end
            textCount.text = string.format(LocalizeExt(20672), Utils.GetCountFormat(count))
            textName.text = CommonUIUtils.SetContentColorUbbByQuality(LocalizationMgr.getServerLocStr(amountInfo.name), amountInfo.quality)

            itemTips:GetChild("text1").text = LocalizeExt("描述：")
            CommonUIUtils.SetCommonGemItem(comItem, amountInfo)
        end
        self:SetTipsPosition(sourceCom, itemTips, -75)
    end

    local closeFunc = function(itemTips)        
        --itemTips:GetChild("Itemdescription_Label").text = ""
    end

    local resUrl = nil

    if amountInfo.typeId == AmountType.EQUIP then
        resUrl = "EquipTips_Comp"
    elseif amountInfo.typeId == AmountType.USABLE_ITEM then
        if amountInfo.usableItemType == UsableItemType.UIT_HERO_CHIP then
            resUrl = "HeroPiecesTips"
        else
            resUrl = "NewItemTips_Comp"
        end
    elseif amountInfo.typeId == AmountType.CURRENCY then
        resUrl = "NewItemTips_Comp"
    elseif amountInfo.typeId == AmountType.GEM then
        resUrl = "NewItemTips_Comp"
    else
        resUrl = "NewItemTips_Comp"
    end
    self:CreateTipsOnPress(sourceCom, resUrl, initFunc, closeFunc, nil, 0, TipsType.TYPE_PRIZE_ITEM)   
    self:RemoveCurTips(TipsType.TYPE_PRIZE_ITEM)
end

function TipsTool:GetSpellDesc(desc, params, locked, normalStrColor)
    desc = Localize(desc)
    --Utils.DebugError("GetSpellDesc desc = "..tostring(desc))
    local strDesc = ""
    local str1 = ""
    local strColor = ""
    if locked then
        strColor = "#C4C4C4"
    else
        strColor = normalStrColor or "#75FC4C"
    end

    if nil ~= params then
        
        local newParams = {}
        for k, v in ipairs(params) do
            
            newParams[k] = v
        end
        --Utils.DebugError("GetSpellDesc newParams = "..Utils.serialize(newParams))

        -- {%d:1}
        local tabStr = {}
        for w in string.gmatch(desc, "{%d:1}") do
            
            local str = w
            table.insert(tabStr, str)                    
        end

        for k, str in ipairs(tabStr) do
            
            str1 = string.sub(str, 2, 2)
            local index = tonumber(str1) + 1
            if nil ~= newParams[index] then
                newParams[index] = newParams[index] * 0.01
            else
                newParams[index] = 0
            end
            desc = string.gsub(desc, string.format("{%s:1}", str1), "{"..str1.."}%%")
        end
        --Utils.DebugError("1 desc = "..tostring(desc))    
        -- {%d:2}
        tabStr = {}
        for w in string.gmatch(desc, "{%d:2}") do
            
            local str = w
            table.insert(tabStr, str)
        end
        for k, str in ipairs(tabStr) do
            
            str1 = string.sub(str, 2, 2)
            local index = tonumber(str1) + 1
            if nil ~= newParams[index] then
                newParams[index] = newParams[index] * 0.01
            else
                newParams[index] = 0
            end
            desc = string.gsub(desc, string.format("{%s:2}", str1), "{"..str1.."}")
        end
        --Utils.DebugError("2 desc = "..tostring(desc))
        -- {0}%%
        tabStr = {}
        for w in string.gmatch(desc, "{%d}%%%%") do
            local str = string.sub(w, 1, 3)
            table.insert(tabStr, str)
        end
        for k, str in ipairs(tabStr) do
            desc = string.gsub(desc,  string.format("%s", str.."%%%%"), string.format("[color=%s]%s[/color]", strColor, str.."%%"))
        end
        --Utils.DebugError("2 desc = "..tostring(desc))
        -- {0}%
        tabStr = {}
        for w in string.gmatch(desc, "{%d}%%") do           
            local str = string.sub(w, 1, 3)
            table.insert(tabStr, str)
        end

        for k, str in ipairs(tabStr) do
            desc = string.gsub(desc,  string.format("%s", str.."%%"), string.format("[color=%s]%s[/color]", strColor, str.."%%"))
        end
        --Utils.DebugError("3 desc = "..tostring(desc))    
        --{0}
        for w in string.gmatch(desc, "{%d}") do
            
            desc = string.gsub(desc, w, string.format("[color=%s]%s%%[/color]", strColor, w))
        end

        --Utils.DebugError("4 desc = "..tostring(desc))    
                              
        desc = LocalizationMgr.GetParamLoc(desc,newParams)

        --Utils.DebugError("5 desc = "..tostring(desc)) 
        strDesc = LuaUtils.CSFormat(desc,unpack(newParams))  

    end

    return strDesc
end

-- spellCfg:shared_SpellDataProto[]
function TipsTool:ShowSpellTips(sourceCom, skillId)
    local initFunc = function(obj)
        local onlyDesc_C = obj:GetController("OnlyDesc_C")
        obj.title = ""
        -- local titleText = obj:GetChild("title")
        local currConfig = ConfigData:GetSkillConfig(skillId)
        -- titleText.text = LocalizationMgr.getServerLocStr(currConfig.name)
        local currStateLabel = obj:GetChild("currStateLabel")
        currStateLabel.title = LocalizationMgr.getServerLocStr(currConfig.name)
        local descText = currStateLabel:GetChild("descText")
        descText.text = LocalizationMgr.getServerLocStr(currConfig.desc)
        self:SetTipsPosition(sourceCom, obj, 0)
    end

    self:CreateTipsOnPress(sourceCom, "HeroSkillTips", initFunc, nil, nil, nil, TipsType.TYPE_HERO_SKILL)   
    -- self:RemoveCurTips(TipsType.TYPE_HERO_SKILL)
end

--普通点击弹出tips，有点击事件的长按弹出tips
function TipsTool:CreateTipsOnPress(sourceCom, targetComName, startCallback, endCallback, pos, posType, tipsType)
    local function realCallBack()
        local tipsCB = function(tipsUI,tipsBg)
            if startCallback then
                startCallback(tipsUI, tipsBg, posType)
            end
        end
        
        UIManager.tipsTool():CreateTipsUIOnPress("UI/Common/Common", "Common", targetComName, sourceCom, true, tipsCB, endCallback, tipsType)
    end

    local function touchCb()
        if sourceCom.onClick.isEmpty then
            realCallBack()
        end
    end

    local function pressCb()
        if not sourceCom.onClick.isEmpty then
            realCallBack()
        end
    end

    sourceCom.onTouchBegin:Set(touchCb)
    table.insert(m_touchBeginEvents, sourceCom.onTouchBegin)
    local lpg = LongPressGesture(sourceCom)
    lpg.trigger = 0.3
    lpg.once = true
    lpg.onAction:Set(pressCb)
    table.insert(m_lpgs, lpg)
end

-- 创建一个公用弹框
function TipsTool:CreateTipsUIOnPress(pkgPath, fileName, tipsUIName, sourceCom, isBlank, startCallback, endCallback, tipsType)
    local curPanel = UIManager.GetCurUI()
    if (not curPanel or not curPanel.UI) then
        UIManager.ShowMsg(LocalizeExt(21376))
    end
    self:ClosePopup()
    
    -- 移除上一个tips
    self:RemoveLastTips()

    -- 创建tips
    local tipsUI, pkgId = UIManager.CreateFairyCom(pkgPath, fileName, tipsUIName, false, curPanel.UI);
    tipsUI.alpha = 1
    tipsUI.visible = true
    tipsUI.sortingOrder = curPanel.UI.sortingOrder
    self.curShowTipsUI = tipsUI
    self.curShowTipsPkg = pkgId
    self.tipEndCallback = endCallback
    self.curTipsType = tipsType

    -- 添加消失方法
    local clickBg = function()
        
        sourceCom.onRollOut:Clear()
        sourceCom.onTouchEnd:Clear()
        --sourceCom.onRemovedFromStage:Clear()
        
        if nil ~= self.curShowTipsUI then
            local func = function()
                local endCB = function()
                    if endCallback then
                        endCallback(self.curShowTipsUI)
                    end

                    if not Utils.uITargetIsNil(self.curShowTipsUI) then
                        self.curShowTipsUI.visible = false
                        UIManager.DisposeFairyCom(self.curShowTipsPkg, self.curShowTipsUI)
                        self.curShowTipsPkg = nil
                        self.curShowTipsUI = nil
                    end
                end
                self.tweenerTips = self.curShowTipsUI:TweenFade(0, 0.2)
                self.tweenerTips:OnComplete(endCB)
                self.tipsTimer = nil
            end

            self.tipsTimer = TimerManager.waitTodo(2, 1, func, nil, nil, true)
        end
    end

    local removeCB = function()
        
        sourceCom.onRollOut:Clear()
        sourceCom.onTouchEnd:Clear()
        sourceCom.onRemovedFromStage:Clear()

        self:RemoveLastTips()
    end
    sourceCom.onRollOut:Clear()
    sourceCom.onRollOut:Add(clickBg)
    sourceCom.onTouchEnd:Clear()
    sourceCom.onTouchEnd:Add(clickBg)
    sourceCom.onRemovedFromStage:Clear()
    sourceCom.onRemovedFromStage:Add(removeCB)

    tipsUI.scale = Vector2.one * 0.95
    tipsUI:TweenScale(Vector2(1, 1), 0.1)
    if (startCallback) then
        startCallback(tipsUI)
    end
    return tipsUI
end

-- 移除当前tips
function TipsTool:RemoveCurTips(tipType)
    
    if self.curTipsType == tipType then
        
        self:RemoveLastTips()
    end
end

-- 移除tips
function TipsTool:RemoveLastTips()
    
    if nil ~= self.curShowTipsUI then
        if self.tipEndCallback then
            self.tipEndCallback(self.curShowTipsUI)
        end
        self.curShowTipsUI.visible = false
        UIManager.DisposeFairyCom(self.curShowTipsPkg, self.curShowTipsUI)        
    end

    if nil ~= self.tipsTimer then
        self.tipsTimer = TimerManager.disposeTimer(self.tipsTimer)
    end

    if nil ~= self.tweenerTips then
        self.tweenerTips:Kill(false)
    end
    self.curShowTipsUI = nil
    self.tipEndCallback = nil
    self.tipsTimer = nil
    self.tweenerTips = nil
    self.curTipsType = TipsType.TYPE_NONE
end

-- 获取相对方位坐标
function TipsTool:GetRelativePos(sourceCom, targetCom, dir)
    local pos = Vector2.zero
    if (dir == RelativeDir.Up) then
        pos = Vector2((sourceCom.actualWidth - targetCom.width) / 2, - targetCom.height)
    elseif (dir == RelativeDir.RightUp) then
        pos = Vector2(sourceCom.actualWidth / 2 - 80,  - targetCom.height)
    elseif (dir == RelativeDir.Right) then
        pos = Vector2(sourceCom.actualWidth, (sourceCom.actualHeight - targetCom.height / 2))
    elseif (dir == RelativeDir.RightDown) then
        pos = Vector2(sourceCom.actualWidth / 2 - 80, sourceCom.actualHeight)
    elseif (dir == RelativeDir.Down) then
        pos = Vector2((sourceCom.actualWidth - targetCom.width) / 2, sourceCom.actualHeight)
    elseif (dir == RelativeDir.LeftDown) then
        pos = Vector2((sourceCom.actualWidth - targetCom.width) - (sourceCom.actualWidth / 2 - 80), sourceCom.actualHeight)
    elseif (dir == RelativeDir.Left) then
        pos = Vector2(- targetCom.width, (sourceCom.actualHeight - targetCom.height) / 2)
    elseif (dir == RelativeDir.LeftUp) then
        pos = Vector2((sourceCom.actualWidth - targetCom.width) - (sourceCom.actualWidth / 2 - 80), - targetCom.height)
    end
    return pos
end

-- 显示错误提示
function TipsTool:ShowErrorCode(moduleID, msgId, errorId)
    
    EventDispatcher:Dispatch(Event.NET_ERROR)
    local key = string.format("%s-%s-%s", tostring(moduleID), tostring(msgId), tostring(errorId))
    --Utils.DebugError(key)
    local strTip = LocalizationMgr.getServerLocStr(Configs.ErrorConfig()[key])
    if nil == strTip or string.len(strTip) == 0 then
        UIManager.OpenPopupUI(UIInfo.PopupUI, key, LocalizeExt(20037), 1)
        return
    end
    UIManager.OpenPopupUI(UIInfo.PopupUI, strTip, LocalizeExt(20037), 1)
end

-- 显示飘字错误提示
function TipsTool:ShowErrorMsg(moduleID, msgId, errorId)
    
    EventDispatcher:Dispatch(Event.NET_ERROR)
    local key = string.format("%s-%s-%s", tostring(moduleID), tostring(msgId), tostring(errorId))
    --Utils.DebugError(key)
    local strTip = LocalizationMgr.getServerLocStr(Configs.ErrorConfig()[key])
    if nil == strTip or string.len(strTip) == 0 then
        UIManager.ShowMsg(key)
        return
    end

    UIManager.ShowMsg(strTip)
end

-- 显示资源特效
function TipsTool:ShowResEffect(bShow, amounts, topBar, index)
    
    if bShow then
        if nil == self.resEffectUI then
            self.resEffectUI = require(UIInfo.ResourcesEffectUI.UILogic)
            self.resEffectUI:OnOpen()
        end
    end

    if self.resEffectUI then
        self.resEffectUI:OnShow(bShow, amounts, topBar, index)
    end
end

function TipsTool:Update()
    
    
end

function TipsTool:Close()
    
    if closeFunction then
        closeFunction()
    end
    closeFunction = nil

    if self.resEffectUI then
        self.resEffectUI:OnClose()
        self.resEffectUI = nil
    end

    if nil ~= self.curShowTipsUI then
        self.curShowTipsUI.visible = false
        UIManager.DisposeFairyCom(self.curShowTipsPkg, self.curShowTipsUI)       
    end
    self.endCallback = nil
    if nil ~= self.tipsTimer then                
        TimerManager.disposeTimer(self.tipsTimer)
        self.tipsTimer = nil
    end

    if nil ~= self.tweenerTips then
        self.tweenerTips:Kill(false)
        self.tweenerTips = nil
    end

    for _, v in pairs(m_touchBeginEvents) do
        if v and not v.isEmpty then
            v:Clear()
        end
    end

    m_touchBeginEvents = nil
    
    for _, v in pairs(m_lpgs) do
        if v then
            v:Dispose()
        end
    end

    m_lpgs = nil

    EventDispatcher:Remove(Event.REMOVE_CUR_TIPS, self.RemoveCurTips, self)
    EventDispatcher:Remove(Event.OPENED_UI, self.CancelLpgs, self)
end

-- 监听点击空白事件
function TipsTool:CheckPopup(context)
   if (self.curPopup)then
		local mc = Stage.inst.touchTarget
		local handled = false;
		while (mc ~= Stage.inst and mc ~= nil) do
			if (mc.gOwner ~= nil)then
				if (self.curPopup == mc.gOwner)then
                    handled = true
					break;
				end
			end
			mc = mc.parent;
		end
        if(not handled)then
            self:ClosePopup();
        end
    end
end

function TipsTool:ClosePopup()
    --self.curPanel.UI:AddChild(self.curPopup)
    if(self.curPanel)then
        if(self.closeCallBack)then
            self.closeCallBack()
        end
        self.curPanel = nil
        self.curPopup = nil
        self.closeCallBack = nil
    end
end

return TipsTool