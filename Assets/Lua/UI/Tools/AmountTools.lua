-- 用于处理奖励消耗等解析通用方法
local AmountTool = class()
-- 判断消耗是否足够(CostProto),并且返回所有不够的数据
function AmountTool.IsCostEnough(costProto)
    local notEnoughTable = {}
    local amounts = costProto.amounts
    for i, amount in ipairs(amounts) do
        if (amount.type == AmountType.CURRENCY) then
            local curNum = PlayerData.Datas.CurrencyData:GetHaveCountById(amount.id)
            --Utils.DebugError("curnum is :"..curNum)
            --Utils.DebugError("amount is :"..amount.amount)
            if (curNum < amount.amount) then
                table.insert(notEnoughTable,amount)
            end
        end
    end

    return #notEnoughTable == 0, notEnoughTable
end

-- {type,id,value,icon }
function AmountTool.GetAmountInfos(costProto)
    --Utils.PrintProto(costProto)
    local amountInfoList = {}
    for i, amount in ipairs(costProto.amounts) do
        local amountTable = {['type'] = amount.type, id = amount.id, ['amount'] = amount.amount }      
        if (amount.type == AmountType.CURRENCY) then            
            amountTable.icon = UIInfo.ResourcesIcon.UIImgPre.. ConfigData:FindCurrencyTypeById(amount.id).icon
        end
        table.insert(amountInfoList, amountTable)
    end
    return amountInfoList
end



-- 获取道具信息 amount:AmountProto   
--此处都是配置表数据
function AmountTool.GetAmountInfo(amount)
    local amountItem = {}
    amountItem.id = amount.id
    amountItem.typeId = amount.type
    amountItem.subType = ""              -- 子类型（货币分类型）
    amountItem.num = amount.amount
    amountItem.star = 0
    amountItem.quality = 0
    amountItem.raceType = 0
    amountItem.icon = ""
    amountItem.midIcon = ""
    amountItem.bigIcon = ""
    amountItem.name = ""
    amountItem.config = nil
    amountItem.desc = ""

    if(amount.type == AmountType.CURRENCY)then      -- 货币
        local currency = ConfigData:FindCurrencyTypeById(amount.id)
        if currency then
            amountItem.name = currency.name
            amountItem.config = currency
            amountItem.desc = currency.desc
            amountItem.subType = currency.type
            amountItem.quality = 0
            local path = UIInfo.ResourcesIcon.UIImgPre
            amountItem.icon = path .. currency.icon
            amountItem.midIcon = path .. currency.median_icon
            amountItem.bigIcon = path .. currency.big_icon
        end
    elseif(amount.type == AmountType.HERO)then      -- 英雄
        local hero = ConfigData:GetHeroDataConfigById(amount.id)
        if hero then
            amountItem.icon = UIInfo.HeadIcon.UIImgPre .. hero.head
            amountItem.bigIcon = amountItem.icon
            amountItem.midIcon = amountItem.icon
            amountItem.name = hero.name
            amountItem.config = hero
            local speciesData = ConfigData:GetSpeciesConfigByType(hero.race)
            amountItem.raceType = speciesData.race_type
            amountItem.raceName = speciesData.show_name
            amountItem.quality = hero.quality
            amountItem.star = 0
            amountItem.level = 1
            amountItem.desc = hero.desc
        end
    elseif(amount.type == AmountType.EQUIP)then      -- 装备
        local equip = ConfigData:GetEquipDataById(amount.id)
        if equip then
            local icon = UIInfo.EquipIcon.UIImgPre .. equip.icon
            amountItem.icon = icon
            amountItem.bigIcon = icon
            amountItem.midIcon = icon
            amountItem.name = equip.name
            amountItem.config = equip
            amountItem.quality = equip.quality
            amountItem.desc = equip.desc
            amountItem.needLv = equip.need_level
        end
    elseif(amount.type == AmountType.USABLE_ITEM)then      -- 物品
        local item = ConfigData:GetUseItemDataConfigById(amount.id)
        if item then
            local icon = UIInfo.ItemIcon.UIImgPre .. item.icon
            amountItem.quality = item.quality
            amountItem.icon = icon
            amountItem.bigIcon = icon
            amountItem.midIcon = icon
            amountItem.name = item.name
            amountItem.config = item
            amountItem.desc = item.desc
            amountItem.usableItemType = item.type
        end
    elseif(amount.type == AmountType.GEM)then      -- 宝石
        local gem = ConfigData:GetGemDataById(amount.id)
        if gem then
            local icon = UIInfo.GemIcon.UIImgPre .. gem.icon
            amountItem.quality = 0
            amountItem.icon = icon
            amountItem.bigIcon = icon
            amountItem.midIcon = icon
            amountItem.name = gem.name
            amountItem.config = gem
            amountItem.desc = gem.desc
            amountItem.type = gem.type
        end
    end

    return amountItem
end

-- 排序顺序
local function GetSortIndex(id)
    local index = 20
    if id == CurrencyTypeName.Diamond.id then
        index = 0
    elseif id == CurrencyTypeName.Gold.id then
        index = 1
    elseif id == CurrencyTypeName.Exp.id then
        index = 2
    end

    return index
end

local function getSortNumber(p)
    if p.type == AmountType.CURRENCY then return GetSortIndex(p.id) + (p.type + 1) * 100000 end

    if(p.type == AmountType.HERO)then
        local heroCfg = ConfigData:GetHeroDataConfigById(p.id)
        return p.type * 1000 - heroCfg.order_id
    end

    if p.type == AmountType.EQUIP then
        local equipData = ConfigData:GetEquipDataById(p.id)
        return p.type * 100000 - equipData.quality * 1000 + equipData.part_type
    end

    return p.type * 100000
end


-- 物品排序
function AmountTool.SortAmount(a, b)
    if a == nil or b == nil then
        return false
    end

    local an = a.misc
    if not an or an == 0 then 
        an = getSortNumber(a)
        a.misc = an
    end

    local bn = b.misc
    if not bn or bn == 0 then
        bn = getSortNumber(b)
        b.misc = bn
    end

    return an < bn
end

function AmountTool.SelectAmount(amounts, amount)
    local has = false
    for i, a in ipairs(amounts)do
        if(a.type == amount.type and a.id == amount.id)then
            if(amount.type == AmountType.HERO)then 
                if(a.hero_quality == amount.hero_quality)then
                    a.amount = a.amount + amount.amount
                    has = true
                    return
                end
            elseif(amount.type == AmountType.EQUIP)then -- 装备
                if(a.equip_camp == amount.equip_camp)then
                    a.amount = a.amount + amount.amount
                    has = true
                    return
                end
            else
                a.amount = a.amount + amount.amount
                has = true
                return
            end
        end
    end
    if(not has)then
        local cloneAmount = {
            type = amount.type,
            id = amount.id,
            amount = amount.amount,
            misc = amount.misc,
            hero_quality = amount.hero_quality,
            equip_camp = amount.equip_camp,
        }
        table.insert(amounts, cloneAmount)
    end
end

--合并奖励
--prizes:PrizeProto[]
function AmountTool.MergePrize(prizes)
    local prize = {amounts = {}, hero_results = {}}
    if(prizes)then
        for i, p in ipairs(prizes)do
            for i, amount in ipairs(p.amounts)do
                AmountTool.SelectAmount(prize.amounts, amount)
            end
            if p.hero_results then
                for i, hr in ipairs(p.hero_results)do
                    table.insert(prize.hero_results, hr)
                end
            end
        end
    end
    return prize
end

return AmountTool
