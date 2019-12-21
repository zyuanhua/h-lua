-- 物品系统

--[[
    每个英雄最大支持使用6件物品
    支持满背包合成
    物品存在重量，背包有负重，超过负重即使存在合成关系，也会被暂时禁止合成

    主动指玩家需要手动触发的技能
    被动指英雄不需要主动使用而是在满足特定条件后（如攻击成功时）自动触发的技能
    属性有三种叠加： 线性 | 非线性 | 不叠加
    属性的叠加不仅限于几率也有可能是持续时间，伤害等等
    -线性：直接叠加，如：100伤害的物品，持有2件时，造成伤害将提升为200
    -非线性：一般几率的计算为33%左右的叠加效益，如：30%几率的物品，持有两件时，触发几率将提升为42.9%左右
    -不叠加：数量不影响几率，如：30%几率的物品，持有100件也为30%
    *物品不说明的属性不涉及叠加规定，默认不叠加
]]

local hitem = {

    PRIVATE_TRIGGER = {},

    DEFAULT_SKILL_ITEM_SLOT = hSys.getObjId('AInv'), -- 默认物品栏技能（英雄6格那个）默认全部认定这个技能为物品栏，如有需要自行更改
    DEFAULT_SKILL_ITEM_SEPARATE = hslk_global.skill_item_separate, -- 默认拆分物品技能

}

-- 删除物品，可延时
hitem.del = function(it, during)
    if (during <= 0 and it ~= nil) then
        cj.SetWidgetLife(it, 1.00)
        cj.RemoveItem(it)
    else
        htime.setTimeout(during, function(t, td)
            htime.delDialog(td)
            htime.delTimer(t)
            cj.SetWidgetLife(it, 1.00)
            cj.RemoveItem(it)
            hRuntime.item[it] = nil
        end)
    end
end

--[[
    创建物品
    bean = {
        itemId = 'I001', --物品ID
        charges = 1, --物品可使用次数（可选，默认为1）
        whichUnit = nil, --哪个单位（可选）
        whichUnitPosition = nil, --哪个单位的位置（可选，填单位）
        x = nil, --哪个坐标X（可选）
        y = nil, --哪个坐标Y（可选）
        whichLoc = nil, --哪个点（可选，不推荐）
        during = 0, --持续时间（可选，创建给单位要注意powerUp物品的问题）
    }
    !单位模式下，during持续时间是无效的
]]
hitem.create = function(bean)
    if (bean.itemId == nil) then
        print("htime create -it-id")
        return
    end
    local charges = bean.charges or 1
    local during = bean.during or 0
    -- 优先级 坐标 > 单位 > 点
    local it
    local type
    if (bean.x ~= nil and bean.y ~= nil) then
        it = cj.CreateItem(hSys.getObjId(bean.itemId), bean.x, bean.y)
        type = "coordinate"
    elseif (bean.whichUnitPosition ~= nil) then
        it = cj.CreateItem(hSys.getObjId(bean.itemId), cj.getUnitX(bean.whichUnit), cj.getUnitY(bean.whichUnit))
        type = "position"
    elseif (bean.whichUnit ~= nil) then
        it = cj.CreateItem(hSys.getObjId(bean.itemId), cj.getUnitX(bean.whichUnit), cj.getUnitY(bean.whichUnit))
        type = "unit"
    elseif (bean.whichLoc ~= nil) then
        it = cj.CreateItem(hSys.getObjId(bean.itemId), cj.GetLocationX(bean.whichLoc), cj.GetLocationY(bean.whichLoc))
        type = "location"
    else
        print("htime create -site")
        return
    end
    cj.SetItemCharges(it, charges)
    if (during > 0) then
        if (type == "unit") then
            local overlie = hitem.getOverlie(bean.itemId)
            --todo here 检测重量,没空间就丢在地上
            cj.UnitAddItem(bean.whichUnit, it)
            --触发获得物品
            hevent.triggerEvent({
                triggerKey = heventKeyMap.itemGet,
                triggerUnit = bean.whichUnit,
                triggerItem = it,
            })
        else
            htime.setTimeout(during, function(t, td)
                htime.delDialog(td)
                htime.delTimer(t)
                hitem.del(it, 0)
            end)
        end
    end
    return it
end

-- 获取物品ID字符串
hitem.getId = function(it)
    return hSys.getObjChar(cj.GetItemTypeId(it))
end

-- 获取物品SLK数据集
hitem.getSlk = function(itOrId)
    local slk
    local itId
    if (type(itOrId == "string")) then
        itId = itOrId
    else
        itId = hitem.getId(itOrId)
    end
    if (hslk_global.itemsKV[itId] ~= nil) then
        slk = hslk_global.itemsKV[itId]
    else
        print("itemsKV need register id:" .. itId)
    end
    return slk
end
-- 获取物品的图标路径
hitem.getAvatar = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.Art
    else
        return ""
    end
end
-- 获取物品的模型路径
hitem.getAvatar = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.file
    else
        return ""
    end
end
-- 获取物品的分类
hitem.getClass = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.class
    else
        return "Permanent"
    end
end
-- 获取物品所需的金币
hitem.getGoldCost = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.goldcost
    else
        return 0
    end
end
-- 获取物品所需的木头
hitem.getLumberCost = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.lumbercost
    else
        return 0
    end
end
-- 获取物品是否可以使用
hitem.getIsUsable = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.usable == 1
    else
        return false
    end
end
-- 获取物品是否自动使用
hitem.getIsPowerUp = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.powerup == 1
    else
        return false
    end
end
-- 获取物品是否可卖
hitem.getIsSellAble = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.sellable == 1
    else
        return false
    end
end
-- 获取物品的影子ID（实现神符满格购物的关键）
hitem.getShadowId = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.shadowID
    else
        return nil
    end
end
-- 获取物品的回调函数
hitem.getTriggerCall = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.triggerCall
    else
        return nil
    end
end
-- 获取物品的最大叠加数(默认是1个,此系统以使用次数作为数量使用)
hitem.getOverlie = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.overlie
    else
        return 1
    end
end

-- 获取物品的使用次数
hitem.getCharges = function(it)
    if (it ~= nil) then
        return cj.GetItemCharges(it)
    else
        return 0
    end
end
-- 获取某单位身上某种物品的使用总次数
hitem.getTotalCharges = function(itemId, whichUnit)
    local charges = 0
    local it
    for i = 0, 5, 1 do
        it = cj.UnitItemInSlot(whichUnit, i)
        if (it ~= nil and cj.GetItemTypeId(it) == itemId) then
            charges = charges + hitem.getCharges(it)
        end
    end
    return charges
end

-- 获取某单位身上空格物品栏数量
hitem.getEmptySlot = function(whichUnit)
    local qty = cj.UnitInventorySize(whichUnit)
    local it
    for i = 0, 5, 1 do
        it = cj.UnitItemInSlot(whichUnit, i)
        if (it ~= nil) then
            qty = qty - 1
        end
    end
    return qty
end

-- 设置单位拥有拆分物品的技能
hitem.setAllowSeparate = function(whichUnit)
    --物品拆分
    cj.UnitAddAbility(whichUnit, hitem.DEFAULT_SKILL_ITEM_SEPARATE)
    cj.UnitMakeAbilityPermanent(whichUnit, true, hitem.DEFAULT_SKILL_ITEM_SEPARATE)
    cj.SetUnitAbilityLevel(whichUnit, hitem.DEFAULT_SKILL_ITEM_SEPARATE, 1)
end

-- 使一个单位的所有物品给另一个单位
hitem.give = function(origin, target)
    if (origin == nil or target == nil) then
        return
    end
    for i = 0, 5, 1 do
        local it = cj.UnitItemInSlot(origin, i)
        if (it ~= nil) then
            hitem.create({
                itemId = cj.GetItemTypeId(it),
                charges = cj.GetItemCharges(it),
                whichUnit = target,
            })
        end
        hitem.del(it, 0)
    end
end

-- 复制一个单位的所有物品给另一个单位
hitem.copy = function(origin, target)
    if (origin == nil or target == nil) then
        return
    end
    for i = 0, 5, 1 do
        local it = cj.UnitItemInSlot(origin, i)
        if (it ~= nil) then
            hitem.create({
                itemId = cj.GetItemTypeId(it),
                charges = cj.GetItemCharges(it),
                whichUnit = target,
            })
        end
    end
end

-- 令一个单位把物品全部仍在地上
hitem.drop = function(origin)
    if (origin == nil) then
        return
    end
    for i = 0, 5, 1 do
        local it = cj.nitItemInSlot(origin, i)
        if (it ~= nil) then
            hitem.create({
                itemId = cj.GetItemTypeId(it),
                charges = cj.GetItemCharges(it),
                x = cj.GetUnitX(origin),
                x = cj.GetUnitY(origin),
            })
            htime.del(it, 0)
        end
    end
end

-- 注册初始化
hitem.registerAll = function(whichUnit)
    if (hRuntime.item[whichUnit] == nil) then
        hRuntime.item[whichUnit] = {}
    end
    if (hRuntime.item[whichUnit].init == nil) then
        hRuntime.item[whichUnit].init = true
    end
    cj.TriggerRegisterUnitEvent(hitem.PRIVATE_TRIGGER.pickup, whichUnit, EVENT_UNIT_PICKUP_ITEM)
    cj.TriggerRegisterUnitEvent(hitem.PRIVATE_TRIGGER.drop, whichUnit, EVENT_UNIT_DROP_ITEM)
    cj.TriggerRegisterUnitEvent(hitem.PRIVATE_TRIGGER.pawn, whichUnit, EVENT_UNIT_PAWN_ITEM)
    cj.TriggerRegisterUnitEvent(hitem.PRIVATE_TRIGGER.separate, whichUnit, EVENT_UNIT_SPELL_EFFECT)
    cj.TriggerRegisterUnitEvent(hitem.PRIVATE_TRIGGER.use, whichUnit, EVENT_UNIT_USE_ITEM)
end

-- 初始化(已内部调用)
hitem.init = function()
    hitem.PRIVATE_TRIGGER = {
        pickup = cj.CreateTrigger(),
        drop = cj.CreateTrigger(),
        pawn = cj.CreateTrigger(),
        separate = cj.CreateTrigger(),
        use = cj.CreateTrigger(),
    }
    --获取物品
    cj.TriggerAddAction(hitem.PRIVATE_TRIGGER.pickup, function()
        local u = cj.GetTriggerUnit()
        local it = cj.GetManipulatedItem()
        local itId = cj.GetItemTypeId(it)
        local charges = cj.GetItemCharges(it)
        local shadowItId = hitem.getShadowId(itId)
        if (shadowItId == nil) then
            if (hitem.getIsPowerUp() == false) then
                --原生的自动使用物品,触发一下 onItemUse 事件即可
                local call = hitem.getTriggerCall()
                if (call ~= nil and type(call) == 'function') then
                    call(u, it, itId, charges)
                end
                hevent.triggerEvent({
                    triggerKey = heventKeyMap.itemUsed,
                    triggerUnit = u,
                    triggerItem = it,
                })
            else
                --这里删除重建是为了实现地上物品的过期重置
                hitem.del(it, 0)
                hitem.create({
                    itemId = itId,
                    whichUnit = u,
                    charges = charges,
                    during = 0,
                })
            end
        else
            --这里删除重建是为了实现地上物品的过期重置
            hitem.del(it, 0)
            --这里是实现神符满格的关键
            hitem.create({
                itemId = shadowItId,
                whichUnit = u,
                charges = charges,
                during = 0,
            })
        end
    end)
    --丢弃物品
    cj.TriggerAddAction(hitem.PRIVATE_TRIGGER.drop, function()

    end)
    --抵押物品
    cj.TriggerAddAction(hitem.PRIVATE_TRIGGER.pawn, function()

    end)
    --使用物品
    cj.TriggerAddAction(hitem.PRIVATE_TRIGGER.use, function()

    end)
    --拆分物品
    cj.TriggerAddAction(hitem.PRIVATE_TRIGGER.separate, function()

    end)
end

return hitem
