local CommonUIUtils = {}

CommonItemType = {
    Fish = 1,
    Decoration = 2,
    Currency = 3, -- 货币(通用)
    UsableItem = 4, -- 可使用的道具
}

-- 消耗类型
CommonCostType = {
    Free = 0,
    Coin = 1,
    Diamond = 2,
    AD = 4,
    CoinAD = 5,
    DiamondAD = 6
}

-- 奖励类型
CommonRewardType = {
    Coin = 1,
    Diamond = 2,
    IncomeTimes = 3,
}

FishStateEnum =
{
    None = 0,
    WaitToThrow = 1,
    Throw = 2,
    WaitFishBite = 3,
    FishBite = 4,
    Fight = 5,
    CriticalStrikeChance = 6,
    InAir = 7,
    ShowHunter = 8,
    PullBack = 9,
    PullUp = 10,
    Show = 11,
    Crit = 12,
    ShowGold = 13,
    HuntStart = 14,
    HunterJump = 15,
}

ClickEffectType =
{
    Normal = 0,
    Gold = 1,
    Bar = 2,
    CollectGold = 3,
    TouchWave = 4,
    PromptEffect = 5,
    DiamondEffect = 6,
    DmShanKuangEffect= 7,
    GoldShanKuangEffect =8,
    RewardTail =9,
    RewardBoom =10,
}

function CommonCostType.IsAD(t)
    return (t == CommonCostType.AD 
        or t == CommonCostType.CoinAD
        or t == CommonCostType.DiamondAD)
end

function CommonCostType.IsCoin(t)
    return (t == CommonCostType.Coin 
        or t == CommonCostType.CoinAD)
end

function CommonCostType.IsDiamond(t)
    return (t == CommonCostType.Diamond 
        or t == CommonCostType.DiamondAD)
end


function CommonUIUtils.SetCurrencyLabel(label, count, type)
    if type == CommonCostType.Coin then
        label.icon = ConstantValue.CoinIconURL
    elseif type == CommonCostType.Diamond then
        label.icon = ConstantValue.DiamondIconURL
    elseif type == CommonRewardType.IncomeTimes then
        label.icon = ConstantValue.CoinIconURL
        count = count * PlayerData:GetRealCoinIncome()
    end
    label.text = Utils.GetCountFormat(count)
end

--获取Item链接
function CommonUIUtils.GetItemAmountURL(amountInfo, comURLMap, hasNum)
    local type = nil
    if(amountInfo.typeId == AmountType.CURRENCY)then
        type = CommonItemType.Currency
    elseif(amountInfo.typeId == AmountType.EQUIP)then
        type = CommonItemType.Equip
    elseif(amountInfo.typeId == AmountType.HERO)then
        type = CommonItemType.Hero
    elseif(amountInfo.typeId == AmountType.USABLE_ITEM)then
        if amountInfo.usableItemType == UsableItemType.UIT_HERO_CHIP then
            type = CommonItemType.HeroPiece
        else
            type = CommonItemType.UsableItem
        end
    elseif(amountInfo.typeId == AmountType.GEM)then
        type = CommonItemType.Gem
    end

    local resMap = nil
    if(hasNum)then
        resMap = comURLMap or DefaultComLabelURLMap
    else
        resMap = comURLMap or DefaultComURLMap -- 临时
    end

    return resMap[type]
end

--设置通用奖励
--Obj:GComponent
--amountInfo: AmountTool.GetAmountInfo(AmountProto)
--hasNum:有无数量
--showTips：是否长按tips
function CommonUIUtils.RenderItemAmount(Obj, amountInfo, hasNum, scale, pivot,showTips,showLv)
    scale = scale or 1
    showLv = showLv or 0
    if scale ~= 1 then
        Obj:SetScale(scale,  scale)
        Obj:SetSize(scale * 280,  scale * 280)
		Obj:SetPivot(pivot.x, pivot.y)
    end

    local itemCom = nil
    if(hasNum)then
        -- itemCom = Obj:GetChild("Item_Label")
        itemCom = Obj
    else
        itemCom = Obj
    end

    if(amountInfo.typeId == AmountType.CURRENCY)then
        CommonUIUtils.SetCommonCurrency(itemCom, amountInfo)
    elseif(amountInfo.typeId == AmountType.HERO)then
        CommonUIUtils.SetCommonHero(itemCom, amountInfo,showLv)
    elseif(amountInfo.typeId == AmountType.EQUIP)then
        CommonUIUtils.SetEquipItem(itemCom, amountInfo)
    elseif(amountInfo.typeId == AmountType.USABLE_ITEM)then
        CommonUIUtils.SetCommonGoods(itemCom, amountInfo)
    elseif(amountInfo.typeId == AmountType.GEM)then
        CommonUIUtils.SetCommonGemItem(itemCom, amountInfo)
    end

    if showTips then
        UIManager.tipsTool():ShowItemTips(itemCom, amountInfo)
    end
    if(hasNum)then
        -- Obj:GetChild("Num_Label").text = "x" .. Utils.GetCountFormat(amountInfo.num)
    else
        Obj.title = ""
    end
end

--赋值通用奖励列表(不带数量)
--list：GList  默认不使用虚拟列表
--amounts：AmountProto[] 奖励数组
--comURLMap:<AmountType, string> 组件对应URl, map不全将使用DefaultComURLMap[CommonItemType.Currency]。不填写将使用默认的DefaultComURLMap，如有大小需求，使用scale缩放
--scale:组件在列表中缩放。comURLMap为nil时，使用通用组件
--isVirtual:是否虚拟列表，如果是虚拟列表关闭时一定要设置!!!!! list.itemRenderer = nil list.itemProvider = nil !!!!!。
function CommonUIUtils.SetCommonAmountList(list, amounts, comURLMap, scale, isVirtual)
    if(not list or not amounts)then
        Utils.DebugError("SetCommonAmountList 出错！list, amounts不正确")
        return
    end
    comURLMap = comURLMap or DefaultComURLMap

    if comURLMap == nil then
        scale = scale or 1
    end

    isVirtual = isVirtual or false
    if(isVirtual)then
        list:SetVirtual()
    end

    local pivot = CommonUIUtils.GetListAlign(list)

    local AmountTool = PlayerData.amounTool()
    if(isVirtual)then --虚拟列表
        local amountInfos = {}
        for i, amount in ipairs(amounts)do
            table.insert(amountInfos, AmountTool.GetAmountInfo(amount))
        end
        list.itemRenderer = function(index, obj)
            CommonUIUtils.RenderItemAmount(obj, amountInfos[index + 1], false, scale, pivot, true)
        end
        list.itemProvider = function(index)
            return CommonUIUtils.GetItemAmountURL(amountInfos[index + 1], comURLMap)
        end
        list.numItems = #amounts
    else
        list:RemoveChildrenToPool()
        for i, amount in ipairs(amounts)do
            local amountInfo = AmountTool.GetAmountInfo(amount)
            local itemCom = list:AddItemFromPool(CommonUIUtils.GetItemAmountURL(amountInfo, comURLMap))
            itemCom.onClick:Clear()
            CommonUIUtils.RenderItemAmount(itemCom, amountInfo, false, scale, pivot, true)
        end
    end
end

--赋值通用奖励列表(带数量)
--list：GList  默认不使用虚拟列表
--amounts：AmountProto[] 奖励数组
--comURLMap:<AmountType, string> 组件对应URl, map不全将使用DefaultComLabelURLMap[CommonItemType.Currency]。不填写将使用默认的DefaultComLabelURLMap，
--scale:组件在列表中缩放。
--isVirtual:是否虚拟列表，如果是虚拟列表关闭时一定要设置!!!!! list.itemRenderer = nil list.itemProvider = nil !!!!!。
function CommonUIUtils.SetCommonLabelAmountList(list, amounts, comURLMap, scale, isVirtual)
    if(not list or not amounts)then
        Utils.DebugError("SetCommonLabelAmountList 出错！list, amounts不正确")
        return
    end
    -- comURLMap = comURLMap or DefaultComLabelURLMap
    comURLMap = comURLMap or DefaultComURLMap -- 临时

    if comURLMap == nil then
        scale = scale or 1
    end

    isVirtual = isVirtual or false
    if(isVirtual)then
        list:SetVirtual()
    end

    local pivot = CommonUIUtils.GetListAlign(list)

    local AmountTool = PlayerData.amounTool()
    if(isVirtual)then --虚拟列表
        local amountInfos = {}
        for i, amount in ipairs(amounts)do
            table.insert(amountInfos, AmountTool.GetAmountInfo(amount))
        end
        list.itemRenderer = function(index, obj)
            CommonUIUtils.RenderItemAmount(obj, amountInfos[index + 1], true, scale, pivot, true)
        end
        list.itemProvider = function(index)
            return CommonUIUtils.GetItemAmountURL(amountInfos[index + 1], comURLMap, true)
        end
        list.numItems = #amounts
    else
        list:RemoveChildrenToPool()
        for i, amount in ipairs(amounts)do
            local amountInfo = AmountTool.GetAmountInfo(amount)
            local itemCom = list:AddItemFromPool(CommonUIUtils.GetItemAmountURL(amountInfo, comURLMap, true))
            itemCom.onClick:Clear()
            CommonUIUtils.RenderItemAmount(itemCom, amountInfo, true, scale, pivot, true)
        end
    end
end

function CommonUIUtils.GetListAlign(list)
    local x, y = 0,0
    --[[if(list.align == AlignType.Center)then
        x = 0.5
    end
    if(list.align == VertAlignType.Middle)then
        y = 0.5
    end]]
    return {x = x, y = y}
end

-- item 弹出tips
function CommonUIUtils.SetCommonItemTips(item, amountInfo)
    item.onClick:Clear()
    item.onTouchBegin:Clear()
    -- UIManager.tipsTool():ShowItemTips(item, amountInfo)
end

--填充英雄大头像
--heroBigCom : HeroCardItem_M_Label
--data : HeroProto or HeroDataProto
--isHeroData : bool 是否是配置数据
--otherRace : RaceType 显示其他职业
function CommonUIUtils.SetHeroBigHead(heroBigCom, data, isHeroData, otherRace)
    isHeroData = isHeroData or false
    local curHeroCfg = nil
    if (isHeroData) then
        curHeroCfg = data
    else
        if (data.configData) then
            curHeroCfg = data.configData
        else
            curHeroCfg = ConfigData:GetHeroDataConfigById(data.data_id or data.data)
        end
    end
    local heroName = curHeroCfg.name
    local heroLevel = (isHeroData and 0) or data.level
    local heroIcon = PlayerData.Datas.HeroData:GetHeroIconByHeroConfig(curHeroCfg)
    local locked = false
    if (not isHeroData) then
        locked = data.is_locked
    end
    heroBigCom.icon = UIInfo.HeadIcon.UIImgPre .. curHeroCfg.head
    heroBigCom:GetChild("Level").text = heroLevel
    heroBigCom:GetChild("star"):GetController("c1").selectedIndex = data.star
    -- heroBigCom:GetChild("icon"):GetController("quality_C").selectedIndex = data.quality
    heroBigCom:GetController("prop_C").selectedIndex = curHeroCfg.kind
    local upstarCtrl = heroBigCom:GetController("upStar_C")
    local canUpStar = PlayerData.Datas.HeroData:CanUpgradeStarHero(curHeroCfg.id)
    upstarCtrl.selectedIndex = 0
    if canUpStar then
        upstarCtrl.selectedIndex = 1
    end
end

--奖励英雄
function CommonUIUtils.SetCommonHero(item, heroAmount,showLv)
    item.icon = heroAmount.icon
    item:GetChild("Level").text = heroAmount.level
    item:GetChild("star"):GetController("c1").selectedIndex = heroAmount.star
    item:GetController("c2").selectedIndex = showLv
    item:GetController("c3").selectedIndex = showLv and heroAmount.star > 0
    item:GetController("prop_C").selectedIndex = heroAmount.config.kind
    -- item:GetChild("icon"):GetController("quality_C").selectedIndex = heroAmount.quality
end

-- 通用货币
function CommonUIUtils.SetCommonCurrency(item, currencyAmount, showTips)
    if nil == currencyAmount then
        return
    end
    item.icon = currencyAmount.icon
    local c = item:GetChild("icon"):GetController("quality_C")
    if c then
        c.selectedIndex = currencyAmount.quality
    end
    item.title = "x" .. Utils.GetCountFormat(currencyAmount.num)
    local num_C = item:GetController("c1")
    num_C.selectedIndex = currencyAmount.num > 1
    if showTips then
        -- UIManager.tipsTool():ShowItemTips(item, currencyAmount)
    end
end

-- 物品item goods：goodsProto(CommonItem_Goods)
function CommonUIUtils.SetCommonGoods(item, goods, showTips)
    if nil == goods then
        return
    end

    item.icon = goods.icon
    -- item:GetController("Quality").selectedIndex = goods.quality
    item.title = "x" .. Utils.GetCountFormat(goods.num)
    item:GetChild("icon"):GetController("quality_C").selectedIndex = goods.quality
    local num_C = item:GetController("c1")
    num_C.selectedIndex = goods.num > 1 and 0 or 1

    if showTips then
        -- UIManager.tipsTool():ShowItemTips(item, goods)
    end

    local item_C = item:GetController("Time")
    if item_C then
        item_C.selectedIndex = 0
    end

    if goods.config.type == UsableItemType.UIT_GIFT_BY_DUNGEON then
        item_C.selectedIndex = 1
        local timeNum = goods.config.gift_by_dungeon.min / 60
        timeNum = math.floor(timeNum) < timeNum and timeNum or math.floor(timeNum)
        item:GetChild("timeLabel").text = LocalizeExt(20008, {timeNum})
    end
end

-- 装备item  equip：equipProto(CommonItem_Equip)
function CommonUIUtils.SetEquipItem(item, equipAmount)
    if nil == equipAmount then
        return
    end

    local config = equipAmount.config
    item.icon = equipAmount.icon

    if config then
        local icon = item:GetChild("icon")
        if icon and icon.GetController then
            icon:GetController("quality_C").selectedIndex = config.quality
        end
        item.title = config.equip_power
        
        -- 宝石槽位
        local gemSlotList = config.gem_slot_list
        local gemSlot_C = item:GetController("c1")
        gemSlot_C.selectedIndex = 0
        if gemSlotList and #gemSlotList > 0 then
            gemSlot_C.selectedIndex = 1
            local gemList = item:GetChild("gemList")
            gemList:RemoveChildrenToPool()
            for idx, gem in ipairs(gemSlotList) do
                local gemItem = gemList:AddItemFromPool()
                local slot_C = gemItem:GetController("slot_C")
                slot_C.selectedIndex = gem.gem_type
            end
        end
    end
end

-- 装备
function CommonUIUtils.SetNewEquipItem(item, equip, showLock)
    -- 宝石槽位
    local gemSlotList = equip.equipData.gem_slot_list
    item.title = equip.equipData.equip_power
    item.icon = PlayerData.Datas.EquipData:GetEquipIcon(equip.equipData)
    item:GetChild("icon"):GetController("quality_C").selectedIndex = equip.equipData.quality
    item:GetController("new_C").selectedIndex = equip.viewed and 0 or 1
    local gemSlot_C = item:GetController("c1")
    gemSlot_C.selectedIndex = 0
    if gemSlotList and #gemSlotList > 0 then
        gemSlot_C.selectedIndex = 1
        local gemList = item:GetChild("gemList")
        gemList:RemoveChildrenToPool()
        for idx, gem in ipairs(gemSlotList) do
            local gemItem = gemList:AddItemFromPool()
            local slot_C = gemItem:GetController("slot_C")
            local gemStat_C = gemItem:GetController("state_C")
            gemStat_C.selectedIndex = 0
            if equip.gem_list and #equip.gem_list > 0 then
                for _, gemProto in ipairs(equip.gem_list) do
                    gemStat_C.selectedIndex = 0
                    if idx == gemProto.idx then
                        gemStat_C.selectedIndex = 1
                        gemItem.icon = PlayerData.Datas.GemData:GetGemIconById(gemProto.data_id)
                        break
                    end
                end
            end
            slot_C.selectedIndex = gem.gem_type
        end
    end

    showLock = showLock or true
    local lock_C = item:GetController("lock_C")
    lock_C.selectedIndex = 0
    if showLock then
        if equip.locked then
            lock_C.selectedIndex = 1
        end
    end
end

-- 道具
function CommonUIUtils.SetNewItem(com, item)
    com.title = item.count and item.count > 0 and "x" .. Utils.GetCountFormat(item.count) or ""
    com.icon = PlayerData.Datas.ItemData:GetItemIcon(item.itemData)
    com:GetChild("icon"):GetController("quality_C").selectedIndex = item.itemData.quality
    local num_C = com:GetController("c1")
    num_C.selectedIndex = item.count > 1 and 0 or 1
    local item_C = com:GetController("Time")
    if item_C then
        item_C.selectedIndex = 0
    end

    if item.itemData.type == UsableItemType.UIT_GIFT_BY_DUNGEON then
        item_C.selectedIndex = 1
        local timeNum = item.itemData.gift_by_dungeon.min / 60
        timeNum = math.floor(timeNum) < timeNum and timeNum or math.floor(timeNum)
        com:GetChild("timeLabel").text = LocalizeExt(20008, {timeNum})
    end
end

-- 契约
function CommonUIUtils.SetNewContractItem(com, itemInfo)
    com.title = itemInfo.count and itemInfo.count > 0 and "x" .. Utils.GetCountFormat(itemInfo.count) or ""
    com.icon = PlayerData.Datas.ItemData:GetItemIcon(itemInfo.itemData)
    com:GetChild("icon"):GetController("quality_C").selectedIndex = itemInfo.itemData.quality
    local num_C = com:GetController("c1")
    num_C.selectedIndex = itemInfo.count > 1 and 0 or 1
end

-- 宝石
function CommonUIUtils.SetCommonGemItem(com, gem)
    com:GetChild("Level").text = gem.config.level
    com.title = "x" .. Utils.GetCountFormat(gem.num)
    com.icon = gem.icon
    com:GetChild("icon"):GetController("quality_C").selectedIndex = gem.quality
    local num_C = com:GetController("num_C")
    if nil == num_C then
        num_C = com:GetController("c1")
    end
    if num_C then
        num_C.selectedIndex = gem.num > 1 and 0 or 1
    end
end

-- 宝石
function CommonUIUtils.SetGemItem(com, gem)
    com:GetChild("Level").text = gem.level
    com.title = "x" .. Utils.GetCountFormat(gem.count)
    com.icon = PlayerData.Datas.GemData:GetGemIconById(gem.data_id)
    com:GetChild("icon"):GetController("quality_C").selectedIndex = 0
    local num_C = com:GetController("num_C")
    if num_C then
        num_C.selectedIndex = gem.count > 1 and 0 or 1
    end
end

function CommonUIUtils.GetEquipQualitySelIndex(equipQuality)
    local index = 0
    if 0 == equipQuality then
        index = 0
    elseif 1 == equipQuality then
        index = 1
    elseif equipQuality < 4 then
        index = 2
    elseif equipQuality < 6 then
        index = 3
    elseif equipQuality < 8 then
        index = 4
    elseif equipQuality < 10 then
        index = 0
    else
        index = 0
    end

    return index
end

-- 红点显示
-- bShowNum：false:显示叹号, true:显示数字或...
-- num：数量
-- bCount：true:显示数字, false:显示...
-- bNoPlus：大于99是否显示99+， 默认显示99+
function CommonUIUtils.ShowRedPoint(itemRedPoint, bShowNum, num, bCount, bNoPlus)
    local ctrl = itemRedPoint:GetController("state_C")
    if bShowNum then
        if num > 99 then
            if bCount then
                ctrl.selectedIndex = 2
                if bNoPlus then
                    itemRedPoint.title = "99"
                else
                    itemRedPoint.title = "99+"
                end
            else
                ctrl.selectedIndex = 1
            end
        else
            if num < 0 then
                num = 0
            end
            ctrl.selectedIndex = 2
            itemRedPoint.title = tostring(num)
        end
    else
        ctrl.selectedIndex = 0
    end
end

-- 显示通用领取
-- prize:PrizeProto
-- prizeCb:显示完奖励回调
function CommonUIUtils.ShowGetPrize(prize, prizeCb)
    if prize == nil then
        return
    end

    --过滤英雄
    local showAmounts = {}
    if(prize.amounts)then
        for i, amount in ipairs(prize.amounts)do
            --if(amount.type ~= AmountType.HERO)then
                table.insert(showAmounts, amount)
            --end
        end
    end

    -- 展示通用奖励
    if(#showAmounts > 0)then
        UIManager.OpenUI(UIInfo.PrizeListUI, nil, nil, showAmounts, LocalizeExt(20014), nil, prizeCb)
    else
        if(prizeCb)then
            prizeCb()
        end
    end
end

--展示合并奖励
function CommonUIUtils.ShowCombinePrizeProto(combinePrize)
    local amounts = {}

    for _, amount in pairs(combinePrize.prize.amounts) do
        table.insert(amounts, amount)
    end

    -- 装备
    for _, equip in ipairs(combinePrize.equip_list) do
        table.insert(amounts, {type = AmountType.EQUIP, id = equip.data, amount = equip.count})
    end

    UIManager.OpenUI(UIInfo.PrizeListUI, nil, nil, amounts, LocalizeExt(20014))
end

-- Prize相加
-- prizeList:PrizeProto[]
-- return AmountProto[]
function CommonUIUtils.GetAmountsByPrizes(prizeList)
    local allPrize = {}

    if type(prizeList) ~= "table" then
        return allPrize
    end

    for _, prize in ipairs(prizeList) do
        for _, amountData in pairs(prize.amounts) do
            local finditem = false

            for _, v in pairs(allPrize) do
                if v.type == amountData.type and v.id == amountData.id then
                    v.amount = v.amount + amountData.amount
                    finditem = true
                    break
                end
            end

            if finditem == false then
                if amountData.type and amountData.id and amountData.amount then
                    local newitem = {}
                    newitem.type = amountData.type
                    newitem.id = amountData.id
                    newitem.amount = amountData.amount
                    table.insert(allPrize, newitem)
                end
            end
        end
    end

    return allPrize
end

-- 填充列表
-- list:GList
-- prize:PrizeProto
function CommonUIUtils.FillListByPrize(list, prize, scale)
    if list == nil or prize == nil or prize.amounts == nil then
        return
    end

    CommonUIUtils.SetCommonLabelAmountList(list, prize.amounts, nil, scale)
end

-- 填充列表
-- list:GList
-- prizeList:PrizeProto[]
function CommonUIUtils.FillListByPrizeList(list, prizeList)
    if list == nil or prizeList == nil then
        return
    end

    CommonUIUtils.FillListByPrize(list, CommonUIUtils.GetAmountsByPrizes(prizeList))
end

function CommonUIUtils.SetContentColorUbbByQuality(content, quality)
    if type(content) ~= "string" or type(quality) ~= "number" then
        return
    end

    local colorUbb = ""

    if quality == 1 then
        colorUbb = "[color=#30a6ff]"    -- 蓝色
    elseif quality == 2 then
        colorUbb = "[color=#c450ee]"    -- 紫色
    elseif quality == 3 then
        colorUbb = "[color=#ff9c00]"    -- 橙色
    elseif quality == 4 then
        colorUbb = "[color=#54FFA8]"    -- 绿色
    else
        colorUbb = "[color=#ffffff]"    -- 白色
    end

    return colorUbb .. content
end

function CommonUIUtils.CreateUIEff(slot, path, scaleFactor, pos, callback)
    if slot == nil or type(path) ~= "string" then
        return
    end

    local wrapper = GoWrapper()

    local function loadcb(gameObj)
        if gameObj then
            if(wrapper == nil or wrapper.isDisposed)then 
                GameObjectManager:ReturnToPool(GameObjectManager.UIEffPoolName, gameObj)
                return
            end
            gameObj.transform.position = Vector3.zero

            if pos ~= nil then
                gameObj.transform.position = pos
            end
            gameObj.transform.localRotation = Quaternion.identity
            gameObj.transform.localScale = Vector3.one * (scaleFactor or 100)
            wrapper:SetWrapTarget(gameObj)
            slot:SetNativeObject(wrapper)
            if(callback)then
                callback(gameObj)
            end
        end
    end
    GameObjectManager:GetFromPool(GameObjectManager.UIEffPoolName, path, loadcb)
    return wrapper
end

function CommonUIUtils.CreateStencilUIEff(slot, path, scaleFactor)
    local wrapper = CommonUIUtils.CreateUIEff(slot, path, scaleFactor)
    if(wrapper)then
        wrapper.supportStencil = true
    end
    return wrapper
end

function CommonUIUtils.ClearUIEff(wrapper, slot)
    if wrapper == nil then
        return nil, nil
    end

    if not Utils.unityTargetIsNil(wrapper.wrapTarget) then
        --GameObject.Destroy(wrapper.wrapTarget)
        GameObjectManager:ReturnToPool(GameObjectManager.UIEffPoolName, wrapper.wrapTarget)
        wrapper.wrapTarget = nil
        if slot then
            slot:SetNativeObject(nil)
            slot = nil
        end
    end
    wrapper:Dispose()

    return nil, nil
end

function CommonUIUtils.GetUIEffFromPool(path, scaleFactor)
    if type(path) ~= "string" then
        return
    end

    scaleFactor = scaleFactor or ConstantValue.FixUIScale
    local eff = nil

    local function loadcb(obj)
        if obj then
            local gameObj = CS.UnityEngine.GameObject.Instantiate(obj)
            gameObj:SetActive(true)
            gameObj.transform.position = Vector3.zero
            gameObj.transform.localRotation = Quaternion.identity
            gameObj.transform.localScale = Vector3.one * scaleFactor
            eff = gameObj
        end
    end

    GameObjectManager:GetFromPool(GameObjectManager.UIEffPoolName, path, loadcb)
    return eff
end

function CommonUIUtils.ReturnUIEffObjToPool(obj)
    if obj == nil or Utils.unityTargetIsNil(obj) then
        return
    end

    GameObjectManager:ReturnToPool(GameObjectManager.UIEffPoolName, obj)
end

-- 通用滑动条
function CommonUIUtils.SetSliderWithBtn(slider, addBtn, subBtn)
    if slider == nil or addBtn == nil or subBtn == nil then
        return
    end

    local newValue = nil
    addBtn.onClick:Add(
        function()
            newValue = slider.value + 1
            if newValue <= slider.max then
                slider.value = newValue
            end
        end
    )
    subBtn.onClick:Add(
        function()
            newValue = slider.value - 1
            if newValue >= 1 then
                slider.value = newValue
            end
        end
    )
end

-- com:GObject
function CommonUIUtils.SetComByVersionType(com)
    if com == nil then
        return
    end

    local version_C = com:GetController("version")

    if version_C == nil then
        return
    end

    local versionIndex = Utils:GetVersionType()
    if versionIndex == VersionType.ChinaIOS or versionIndex == VersionType.ZW then
        versionIndex = VersionType.China
    end
    if versionIndex < version_C.pageCount then
        version_C.selectedIndex = versionIndex
    else
        version_C.selectedIndex = version_C.pageCount - 1
    end
end

-- 设置UI背景 渠道类型
function CommonUIUtils.SetBGByVersionType(com)
    if com == nil then
        return
    end

    local version_C = com:GetController("version")
    if version_C == nil then
        return
    end

    local index = 0
    if LuaUtils.ChannelHappyFight or LuaUtils.ChannelHappyFightYYB then
        index = 0
    elseif LuaUtils.ChannelWaterHunter or LuaUtils.ChannelWaterHunterYYB then
        index = 2
    elseif LuaUtils.ChannelChinaChaosTown then
        index = 1
    end
    version_C.selectedIndex = index
end

-- 设置颜色
function CommonUIUtils.SetColorByQuality(label, quality)
    if label == nil then
        return
    end

    if quality == 4 then -- 紫
        label.color =  LuaUtils.GetColorByHex("#c450ee")
    elseif quality == 5 then -- 橙
        label.color =  LuaUtils.GetColorByHex("#ff9c00")
    else
        label.color = LuaUtils.GetColorByHex("#71faff")
    end
end

-- 鱼名字的颜色UBB
function CommonUIUtils.SetTextByQuality(textField, text, quality)
    if textField == nil then
        return
    end

    textField.UBBEnabled = true

    if quality == 4 then -- 紫
        textField.text = string.format("[color=#c450ee]%s[/color]", text)
    elseif quality == 5 then -- 橙
        textField.text = string.format("[color=#ff9c00]%s[/color]",text)
    else
        textField.text = string.format("[color=#71faff]%s[/color]",text)
    end
end

-- 道具UBB
function CommonUIUtils.SetGoodsTextColorUbbByQuality(text, quality)
    if type(quality) ~= "number" then
        return
    end

    local format = ""

    if quality == 1 then -- 蓝
        format = "[color=#7aeeff,#00b4ff]%s[/color]"
    elseif quality == 2 then -- 紫
        format = "[color=#ef90ff,#ae2ff0]%s[/color]"
    elseif quality == 3 then -- 橙
        format = "[color=#ffc949,#ff9c00]%s[/color]"
    elseif quality == 4 then -- 粉
        format = "[color=#ffc949,#ff9c00]%s[/color]"
    else
        format = "[color=#ffffff]%s[/color]"
    end

    return string.format(format, text)
end

-- 获取UI的中心屏幕坐标
function CommonUIUtils.GetUICenterPos(gObj)
    if gObj == nil then
        return Vector2.zero
    end

    local xy =
        gObj:LocalToRoot(Vector2(gObj.actualWidth * 0.5, gObj.actualHeight * 0.5))
        

    if (gObj.pivotX > 0 or gObj.pivotY > 0) and gObj.pivotAsAnchor then
        xy = xy - Vector2(gObj.actualWidth * gObj.pivotX, gObj.actualHeight * gObj.pivotY)
    end

    return xy
end

function CommonUIUtils.InScreen(gObj)
    local pos = CommonUIUtils.GetUICenterPos(gObj)
    if pos.y > GRoot.inst.height then
        return false
    else
        return true
    end
end

function CommonUIUtils.IsSourceOpen(systemInfo)
    local isFuncOpen = false
    if(systemInfo)then
        if(systemInfo.FuncType)then
            isFuncOpen = PlayerData.Datas.UserData:IsFunctionOpened(systemInfo.FuncType)
        else
            isFuncOpen = true
        end
        if(isFuncOpen and type(systemInfo.CanOpenFunc) == "function" )then
            isFuncOpen = systemInfo.CanOpenFunc()
        end
    end
    return isFuncOpen
end

--Amount是否有来源
function CommonUIUtils.HasSource(amountType, amountId)
    local soruceListStr = nil
    local amount = {type = amountType, id = amountId, amount = 0, misc = 0, hero_quality = 0, equip_camp = 0}
    local amountInfo = PlayerData.amounTool().GetAmountInfo(amount)
    if(amountInfo.config)then
        soruceListStr = amountInfo.config.source
    end
    if(soruceListStr)then
        local ss = {}
        for i, sourceId in ipairs(soruceListStr)do
            local systemInfo = Configs.SourceConfig()[sourceId]
            if(CommonUIUtils.IsSourceOpen(systemInfo))then
                table.insert(ss, sourceId)
            end
        end
        return #ss > 0
    else
        return false
    end
end

-- 获取属性图标和名字
function CommonUIUtils.GetPropIconAndName(propType)
    local icon, name = nil
    if ConfigData.allAttrMap[propType] then
        icon = UIInfo.Common.UIImgPre .. ConfigData.allAttrMap[propType].icon
        name = LocalizationMgr.getServerLocStr(ConfigData.allAttrMap[propType].name)
    end
    return icon, name
end

-- 填充装备描述信息
-- com:需要填充的组建(URL:ui://7qlz78q8fzkd38)
-- equip:(EquipProto)当前填充的装备信息
-- compareEquip:(EquipProto)对比的装备信息
-- isView:是否为预览状态
function CommonUIUtils.FillEquipInfo(com, equip, compareEquip, isView, viewSlotData, viewSlotDataMap)
    local EquipData = PlayerData.Datas.EquipData
    local UserData = PlayerData.Datas.UserData
    local equipData = equip.equipData
    local attrDetailsCom = com:GetChild("attrDetails")

    -- 装备信息描述
    local partName = com:GetChild("partName")
    local equipName = attrDetailsCom:GetChild("equipName")
    local part_C = com:GetController("part_C")
    local text1 = com:GetChild("text1")
    local colorStr = "#FFFFFF"
    local equipPower = attrDetailsCom:GetChild("equipPower")
    local quality_C = com:GetController("quality_C")
    local curPower = equipData.equip_power
    local slotStar_C = com:GetChild("slotStar"):GetController("c1")
    local slotData = UserData.actorEquipsSlotMap[equipData.part_type]
    local partClass = attrDetailsCom:GetChild("partClass")
    local specialStat = attrDetailsCom:GetChild("specialStat")
    if isView then
        slotData = viewSlotData
    end
    slotStar_C.selectedIndex = slotData.star
    partName.text = LocalizeExt(EquipData:GetEquipPartTypeName(equipData.part_type))
    equipName.text = CommonUIUtils.SetContentColorUbbByQuality(LocalizationMgr.getServerLocStr(equipData.name), equipData.quality)
    part_C.selectedIndex = equipData.part_type
    text1.text = LocalizeExt("已装备")
    partClass.text = string.format("(%s)", LocalizationMgr.getServerLocStr(equipData.class))
    if PlayerData.actorLevel < equipData.need_level then
        colorStr = "#FF2929"
    end
    equipPower.text = curPower
    specialStat.text = ""
    if equipData.part_type == EquipPartType.WU_QI then
        specialStat.text = LocalizationMgr.getServerLocStr(equipData.weapon_desc)
    end
    quality_C.selectedIndex = equipData.quality
    CommonUIUtils.SetNewEquipItem(attrDetailsCom:GetChild("equipItem"), equip)

    -- 装备锁定
    local lockBtn = attrDetailsCom:GetChild("lockBtn")
    lockBtn.selected = equip.locked
    lockBtn.onClick:Clear()
    lockBtn.onClick:Add(
        function()
            EquipData:NewC2SLockMsg(equip.id, lockBtn.selected)
            equip.locked = lockBtn.selected
            CommonUIUtils.SetNewEquipItem(attrDetailsCom:GetChild("equipItem"), equip)
        end
    )

    -- 属性
    local attrlist = attrDetailsCom:GetChild("attrList")
    attrlist:RemoveChildrenToPool()
    local equipStat = ClassConfig.HeroPropClass().new()
    local equipSpecialStat = ClassConfig.HeroPropClass().new()
    equipStat:Init(equip.base_stat)
    equipSpecialStat:Init(equip.random_stat)
    local attrMap = equipStat.attrMap
    local specialAttrMap = equipSpecialStat.attrMap
    local curProp = nil
    local compEquipStat = nil
    local compAttrMap = nil
    local compProp = nil
    local compEquipSpecialStat = nil
    local compSpecialAttrMap = nil
    local compSpecialProp = nil

    if not isView then
        if compareEquip then
            compEquipStat = ClassConfig.HeroPropClass().new()
            compEquipStat:Init(compareEquip.base_stat)
            compAttrMap = compEquipStat.attrMap

            compEquipSpecialStat = ClassConfig.HeroPropClass().new()
            compEquipSpecialStat:Init(compareEquip.random_stat)
            compSpecialAttrMap = compEquipSpecialStat.attrMap
        end
    end

    local statFunc = function(prop, propType, isSpecialStat)
        if prop.value <= 0 then
            return
        end
        local item = attrlist:AddItemFromPool()
            local icon, name = CommonUIUtils.GetPropIconAndName(propType)
            local colorStr2 = "#FFFFFF"
            item.icon = icon
            item:GetChild("attrName").text = name
            local areaTitle = item:GetChild("areaTitle")
--[[             if isView then
                local minProp = ConfigData:GetEquipMinAndMinStat(equip).attrMap[propType]
                local maxProp = ConfigData:GetEquipMinAndMaxStat(equip).attrMap[propType]
                areaTitle.text = string.format("[color=#9C9C9C][%s-%s]", minProp.showValue, maxProp.showValue)
                -- 当前值大于等于最大值的95%，算作优良数值，用黄色显示
                if prop.value >= maxProp.value * 0.95 then
                    colorStr2 = "#FF9500"
                end
            end ]]
            item.title = string.format("[color=%s]+%s" , colorStr2, prop.showValue)

            -- 装备属性对比
            if compareEquip then
                local state_C = item:GetController("state_C")
                local curValue = prop.value
                if not isSpecialStat then
                    compProp = compAttrMap[propType]
                    if compProp then
                        local compValue = compProp.value

                        state_C.selectedIndex = 0
                        if compValue > 0 then
                            if compValue < curValue then
                                state_C.selectedIndex = 1
                            elseif compValue > curValue then
                                state_C.selectedIndex = 2
                            end
                        end
                    end
                else
                    compSpecialProp = compSpecialAttrMap[propType]
                    if compSpecialProp then
                        local state_C = item:GetController("state_C")
                        local compValue = compSpecialProp.value

                        state_C.selectedIndex = 0
                        if compValue > 0 then
                            if compValue < curValue then
                                state_C.selectedIndex = 1
                            elseif compValue > curValue then
                                state_C.selectedIndex = 2
                            end
                        end
                    end
                end
            end
    end

    -- 固有属性
    for propType, attr in pairs(attrMap) do
        if equipData.part_type == EquipPartType.WU_QI then
            --[[ if propType ~= EActorAttribute.ATK and attr.oriValue > 0 then
                local icon, name = CommonUIUtils.GetPropIconAndName(propType)
                local showValue = nil
                local value = math.max(0, attr.oriValue)
                local per = math.max(0, attr.oriPer)
                value = value * (1 + per / 10000)
                if EAttrPerMap[propType] then
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
                specialStat.text = string.format("特性:+%s%s", showValue, LocalizationMgr.getServerLocStr(attr.name))
            else ]]if propType == EActorAttribute.ATK then
                statFunc(attrMap[propType], propType)
            end
        else
            statFunc(attrMap[propType], propType)
        end
    end

    -- 随机属性
    for _, attrCfg in ipairs(ConfigData.equipShowAttributes) do
        curProp = specialAttrMap[attrCfg.type]
        if curProp then
            statFunc(curProp, attrCfg.type, true)
        end
    end
    attrlist:ResizeToFit(#ConfigData.actorShowAttributes)

    -- 宝石
    local gemText = attrDetailsCom:GetChild("gemText")
    local gemList = attrDetailsCom:GetChild("gemList")
    gemList:RemoveChildrenToPool()
    local gemSlotList = equipData.gem_slot_list
    local GemData = PlayerData.Datas.GemData
    if gemSlotList and #gemSlotList > 0 then
        gemList.height = 97
        gemList.visible = true
        gemText.text = LocalizeExt("宝石镶嵌：")
        for idx, gemSlotCfg in ipairs(gemSlotList) do
            local gem = gemList:AddItemFromPool()
            local gemLockText = gem:GetChild("title2")
            local gemSlot_C = gem:GetController("state_C")  -- 槽位状态
            local hasGem = false -- 当前槽位有宝石
            local hasSkillActive = false -- 宝石有技能生效
            local hasReplace = false -- 有可替换宝石
            if gemLockText then
                gemLockText.text = string.format("%s星解锁", gemSlotCfg.star)
            end
            gemSlot_C.selectedIndex = 0
            gem.onClick:Clear()
            gem:GetController("slotType_C").selectedIndex = gemSlotCfg.gem_type -- 槽位类型
            -- 槽位已激活
            if slotData.star >= gemSlotCfg.star then
                gemSlot_C.selectedIndex = 1
                -- 有镶嵌宝石
                if equip.gem_list and #equip.gem_list > 0 then
                    if not isView then
                        gemSlot_C.selectedIndex = 2
                    end
                    for _, gemData in ipairs(equip.gem_list) do
                        -- 已装备
                        if idx == gemData.idx then
                            -- 宝石信息详情
                            gem.onClick:Add(
                                function()
                                    UIManager.OpenUI(UIInfo.GemInfoUI, nil, nil, gemSlotList, equip.gem_list, slotData)
                                end
                            )

                            local gemCfgData = ConfigData:GetGemDataById(gemData.data_id)
                            gemSlot_C.selectedIndex = 3
                            if not isView then
                                for dataId, gemProto in pairs(GemData.gemMap) do
                                    -- 可替换
                                    if gemProto.gemData.type == gemSlotCfg.gem_type and gemProto.gemData.level > gemCfgData.level then
                                        gemSlot_C.selectedIndex = 6
                                        hasReplace = true
                                        break
                                    end
                                end

                                if gemCfgData.skills and #gemCfgData.skills > 0 then
                                    for _, gemSkillId in ipairs(gemCfgData.skills) do
                                        for _, equipSkillId in ipairs(equipData.skills) do
                                            -- 宝石技能生效
                                            if equipSkillId == gemSkillId then
                                                hasSkillActive = true                                        
                                                break
                                            end
                                        end

                                        if not hasSkillActive then
                                            gemSlot_C.selectedIndex = 4
                                            if hasReplace then
                                                gemSlot_C.selectedIndex = 5
                                            end
                                        end
                                    end
                                end
                            end
                            
                            gem.title = "Lv" .. ConfigData:GetGemDataById(gemData.data_id).level
                            gem.icon = GemData:GetGemIconById(gemData.data_id)
                            hasGem = true
                            break
                        end
                    end

                    if not hasGem and not isView then
                        gemSlot_C.selectedIndex = 1
                        -- 当前槽位未装备
                        for dataId, gemProto in pairs(GemData.gemMap) do
                            -- 有宝石
                            if gemProto.gemData.type == gemSlotCfg.gem_type then
                                gemSlot_C.selectedIndex = 2
                                break                           
                            end
                        end
                    end
                else -- 无镶嵌宝石
                    gemSlot_C.selectedIndex = 1
                    if not isView then
                        for dataId, gemProto in pairs(GemData.gemMap) do
                            -- 有宝石
                            if gemProto.gemData.type == gemSlotCfg.gem_type then
                                gemSlot_C.selectedIndex = 2
                                break
                            end
                        end
                    end
                end
            end
        end
    else
        gemList.height = 0
        gemList.visible = false
        gemText.text = " "
    end

    -- 技能
    local skillName = attrDetailsCom:GetChild("skillName")
    local skillList = attrDetailsCom:GetChild("skillList")

    skillName.text = ""
    skillList:RemoveChildrenToPool()
    if equip.skill_id then
        local skillData = ConfigData:GetSkillDataById(equip.skill_id)
        if skillData then
            skillName.text = LocalizationMgr.getServerLocStr(skillData.name)
            skillList:AddItemFromPool().title = LocalizationMgr.getServerLocStr(skillData.desc)
        end
    end
    skillList:ResizeToFit(1)

    -- 套装
    local suitName = attrDetailsCom:GetChild("suitName")
    local suitList = attrDetailsCom:GetChild("suitList")
    local slotMap = nil
    if viewSlotDataMap then
        slotMap = viewSlotDataMap
    else
        slotMap = UserData.actorEquipsSlotMap
    end
    local actorSuitCount = UserData:GetPlayerSuitCount(slotMap, equipData.suit)
    local profitCount = 0
    suitName.text = ""

    suitList:RemoveChildrenToPool()
    if equipData.suit then
        local suitData = ConfigData:GetEquipSuitDataById(equipData.suit)
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

    -- 显示长度适配
    attrDetailsCom.height = attrlist.height + gemText.height + skillName.height + skillList.height + suitName.height + suitList.height + 325
end

-- 进度条百分比RGB颜色
function CommonUIUtils.SetProgressBarColorRGB(bar, max, value)
    local bar1 = bar:GetChild("bar")
    local colorStr = "#00CC33"
    if max and value and max > 0 then
        local per = value / max * 100
        -- Utils.DebugError("百分比", per)
        if per <= 10 then -- 红色
            colorStr = "#D90218"
        elseif per <= 30 then -- 橙色
            colorStr = "#FF6701"
        elseif per <= 60 then -- 黄色
            colorStr = "#FFCB3D"
        elseif per <= 100 then -- 绿色
            colorStr = "#00CC33"
        end
    end
    -- Utils.DebugError("颜色", colorStr)
    bar1.color = CS.LPCFramework.LuaUtils.GetColorByHex(colorStr)
end

-- 设置技能图标
function CommonUIUtils.SetSkillIcon(skillCom, skill_id)
    local skillcfg = ConfigData:GetSkillConfig(skill_id)
    local iconCom = skillCom:GetChild("icon")
    if skillcfg then
        iconCom.icon = skillcfg.icon
    else
        iconCom.icon = ""
    end
end

--新的不要删除
--bossHead:Label_BosslHead
function CommonUIUtils.SetMonsterCom(bossHead, monsterProto)
    local headCom = bossHead:GetChild("BossHead")
    local monsterData = ConfigData:GetMonsterDataById(monsterProto.data_id)
    -- local iconCom = headCom:GetChild("icon")
    headCom.icon = UIInfo.HeadIcon.UIImgPre .. monsterData.icon
    headCom:GetChild("Level").text = monsterProto.level
    headCom:GetChild("star").visible = false
    -- iconCom:GetController("quality_C").selectedIndex = monsterData.quality
end

-- 填充角色属性内容
function CommonUIUtils.FillActorAttribute(item, propType, actorProp, actorStat)
    local UserData = PlayerData.Datas.UserData
    local icon, name = CommonUIUtils.GetPropIconAndName(propType)
    item.icon = icon
    local showValue = actorProp.showValue
    if EAttrPerMap[propType] and EFinalAttrMap[propType] then
        showValue = string.format("%.2f%%", actorStat:CalculateFinalPropValue(propType, actorProp.value) * 100)
    end
    item.title = showValue
    item:GetChild("attrName").text = LocalizeExt(name) .. "："
end

-- 填充英雄属性内容
function CommonUIUtils.FillHeroAttribute(item, propType, prop)
    local icon, name = CommonUIUtils.GetPropIconAndName(propType)
    if name == nil or name == "" then
        return false
    end
    item.icon = icon
    item.title = prop.showValue
    item:GetChild("attrName").text = name .. "："

    if propType == EActorAttribute.CRIT_DAM_VALUE then
        item.title = string.format("%d", math.floor(prop.value * 100)) .. "%"
    else
        item.title = prop.showValue
    end
    return true
end

-- 填充玩家头像框信息(Label_PlayerMiniHead)
function CommonUIUtils.FillPlayerHeadCom(com, basicInfo)
    com.title = "Lv." .. basicInfo.level
    com.icon = UIInfo.HeadIcon.UIImgPre .. "ui_icon_PlayerAvatar0" .. basicInfo.head
end


------------------------------------------------钓鱼项目---------------------------------------------------

-- 从池中生成模型--
-- <param name="poolName" type="gObject">对象池</param>
-- <param name="slot" type="gObject">父对象</param>
-- <param name="path" type="string">路径</param>
-- <param name="callback" type="string">回调 传入生成的goWrapper</param>
function CommonUIUtils.CreateUIModelFromPool(poolName,path,slot, callback,scale,modelScale,modelRotation)
    if slot == nil then
        return
    end
    scale = scale and scale*100 or 100
    local loadcb = function(gameobject)
        if gameobject == nil then
            return nil
        end
        gameobject.transform.localPosition = Vector3.zero
        gameobject.transform.localRotation = Quaternion.identity
        if type(modelScale) == "number" then
            modelScale = modelScale and modelScale or 1
            gameobject.transform.localScale = Vector3.one * modelScale
        elseif nil ~= modelScale then
            gameobject.transform.localScale = modelScale
        else
            gameobject.transform.localScale = Vector3.one
        end
        if modelRotation then
            gameobject.transform.localRotation = modelRotation
        end
        -- local meshRender = gameobject:GetComponentInChildren(typeof(UnityEngine.SkinnedMeshRenderer))
        -- if meshRender then
        --     gameobject.transform.localPosition = gameobject.transform.localPosition - meshRender.bounds.center
        -- end
        gameobject:SetActive(true)
        local goWrapper = GoWrapper(gameobject)
        goWrapper.scale = Vector2.one * scale
        if slot.displayObject ~= nil then
            CommonUIUtils.ReturnUIModelToPool(slot.displayObject)
        end
    
        -- 设置父对象
        if slot ~= nil then
            slot:SetNativeObject(goWrapper)
        end

        if callback and type(callback) == "function" then
            callback(goWrapper)
        end
    end
    GameObjectManager:GetFromPool(poolName, path, loadcb)
end
-- UI对象回池--
function CommonUIUtils.ReturnUIModelToPool(goWrapper,poolName)
    if goWrapper and goWrapper.wrapTarget ~= nil then
        -- 先把wrapTarget回池
        GameObjectManager:ReturnToPool(poolName, goWrapper.wrapTarget)
        goWrapper.wrapTarget = nil
        -- 有owner调用owner的SetNativeObject方法
        if goWrapper.gOwner and goWrapper.gOwner.SetNativeObject then
            goWrapper.gOwner:SetNativeObject(nil)
        else
            -- 否则调用dispose销毁这个GoWrapper
            goWrapper:Dispose()
        end
    end
end

-- 钱币资源的富文本
function CommonUIUtils.ResRichtext(resType, count)
    if nil == resType or nil == count then return "" end

    local image = ""
    if resType == CommonCostType.Coin then
        image = ConstantValue.CoinIconURL
    elseif resType == CommonCostType.Diamond then
        image = ConstantValue.DiamondIconURL
    end
    return string.format("<img src='%s'/>%s", image, count)
end

return CommonUIUtils
