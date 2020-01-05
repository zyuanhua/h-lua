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
    TYPE = {
        COORDINATE = "coordinate",
        POSITION = "position",
        UNIT = "unit",
        LOCATION = "location"
    },
    DEFAULT_SKILL_ITEM_SLOT = hSys.getObjId("AInv"), -- 默认物品栏技能（英雄6格那个）默认全部认定这个技能为物品栏，如有需要自行更改
    DEFAULT_SKILL_ITEM_SEPARATE = hslk_global.skill_item_separate -- 默认拆分物品技能
}

-- 删除物品，可延时
hitem.del = function(it, during)
    if (during <= 0 and it ~= nil) then
        cj.SetWidgetLife(it, 1.00)
        cj.RemoveItem(it)
        hRuntime.item[it] = nil
    else
        htime.setTimeout(
            during,
            function(t, td)
                htime.delDialog(td)
                htime.delTimer(t)
                cj.SetWidgetLife(it, 1.00)
                cj.RemoveItem(it)
                hRuntime.item[it] = nil
            end
        )
    end
end

-- 获取物品ID字符串
hitem.getId = function(it)
    return hSys.getObjChar(cj.GetItemTypeId(it))
end

-- 获取物品SLK数据集
hitem.getSlk = function(itOrId)
    local slk
    local itId
    if (itOrId == nil) then
        print_err("itOrId is nil")
        return nil
    end
    if (type(itOrId) == "string") then
        itId = itOrId
    elseif (type(itOrId) == "number") then
        itId = hSys.getObjChar(itOrId)
    else
        itId = hitem.getId(itOrId)
    end
    if (hslk_global.itemsKV[itId] ~= nil) then
        slk = hslk_global.itemsKV[itId]
    end
    return slk
end
-- 获取物品的图标路径
hitem.getArt = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.Art
    else
        return ""
    end
end
-- 获取物品的模型路径
hitem.getFile = function(itOrId)
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
-- 获取物品是否使用后自动消失
hitem.getIsPerishable = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.perishable == 1
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
    local itId
    if (type(itOrId == "string")) then
        itId = itOrId
    else
        itId = hitem.getId(itOrId)
    end
    return hslk_global.itemsShadowKV[itId]
end
-- 获取物品的真实ID（实现神符满格购物的关键）
hitem.getFaceId = function(itOrId)
    local itId
    if (type(itOrId == "string")) then
        itId = itOrId
    else
        itId = hitem.getId(itOrId)
    end
    return hslk_global.itemsFaceKV[itId]
end
-- 获取物品的回调函数
hitem.getTriggerCall = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.TRIGGER_CALL
    else
        return nil
    end
end
-- 获取物品的最大叠加数(默认是1个,此系统以使用次数作为数量使用)
hitem.getOverlie = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.OVERLIE or 1
    else
        return 1
    end
end
-- 获取物品的重量（默认为0）
hitem.getWeight = function(itOrId, charges)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        if (charges == nil and type(itOrId) == "userdata") then
            --如果没有传次数，这里会直接获取物品的次数，请注意
            charges = hitem.getCharges(itOrId)
        end
        return (slk.WEIGHT or 0) * charges
    else
        return 0
    end
end
-- 获取物品的属性加成
hitem.getAttribute = function(itOrId)
    local slk = hitem.getSlk(itOrId)
    if (slk ~= nil) then
        return slk.ATTRIBUTE or {}
    else
        return {}
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
-- 设置物品的使用次数
hitem.setCharges = function(it, charges)
    if (it ~= nil and charges > 0) then
        cj.SetItemCharges(it, charges)
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

-- 使得单位拥有拆分物品的技能
hitem.setAllowSeparate = function(whichUnit)
    --物品拆分
    cj.UnitAddAbility(whichUnit, hitem.DEFAULT_SKILL_ITEM_SEPARATE)
    cj.UnitMakeAbilityPermanent(whichUnit, true, hitem.DEFAULT_SKILL_ITEM_SEPARATE)
    cj.SetUnitAbilityLevel(whichUnit, hitem.DEFAULT_SKILL_ITEM_SEPARATE, 1)
end

-- 附加单位获得物品后的属性
hitem.addAttribute = function(whichUnit, itId, charges)
    local weight = hitem.getWeight(itId, charges)
    local attr = hitem.getAttribute(itId)
    for k, v in pairs(attr) do
        if (v > 0) then
            attr[k] = "+" .. (v * charges)
        elseif (v < 0) then
            attr[k] = v * charges
        end
    end
    attr.weight_current = "+" .. weight
    print_r(attr)
    hattr.set(whichUnit, 0, attr)
end
-- 削减单位获得物品后的属性
hitem.subAttribute = function(whichUnit, itId, charges)
    local weight = hitem.getWeight(itId, charges)
    local attr = hitem.getAttribute(itId)
    for k, v in pairs(attr) do
        if (v > 0) then
            attr[k] = "-" .. (v * charges)
        elseif (v < 0) then
            attr[k] = "+" .. math.abs(v * charges)
        end
    end
    attr.weight_current = "-" .. weight
    print_r(attr)
    hattr.set(whichUnit, 0, attr)
end

--[[
 1 检查单位的负重是否可以承受新的物品
 2 可以承受的话，物品是否有叠加，不能叠加检查是否还有多余的格子
 3 物品数量是否支持合成
 4 根据情况执行原物品叠加、合成等操作
]]
hitem.detector = function(whichUnit, it)
    if (whichUnit == nil or it == nil) then
        print_err("detector params nil")
    end
    local newWeight = hattr.get(whichUnit, "weight_current") + hitem.getWeight(it)
    --1
    if (newWeight > hattr.get(whichUnit, "weight")) then
        local exWeight = newWeight - hattr.get(whichUnit, "weight")
        htextTag.style(
            htextTag.create2Unit(whichUnit, "负重超出" .. exWeight .. "kg", 8.00, "ffffff", 1, 1.1, 50.00),
            "scale",
            0,
            0.05
        )
        --触发超重事件
        hevent.triggerEvent(
            {
                triggerKey = heventKeyMap.itemOverWeight,
                triggerUnit = whichUnit,
                triggerItem = it,
                value = exWeight
            }
        )
        hRuntime.item[it].type = hitem.TYPE.COORDINATE
        return false
    end
    local overlie = hitem.getOverlie(it)
    local isFullSlot = false
    if (overlie > 1) then
        local isOverlieOver = false
        --可能可叠加的情况，先检查单位的各个物品是否还有叠加空位
        local tempIt
        local currentItId = cj.GetItemTypeId(it)
        local currentCharges = hitem.getCharges(it)
        for si = 0, 5, 1 do
            tempIt = cj.UnitItemInSlot(whichUnit, si)
            if (tempIt ~= nil and currentItId == cj.GetItemTypeId(tempIt)) then
                --如果第i格物品和获得的一致
                --如果有极限值,并且原有的物品未达上限
                local tempCharges = hitem.getCharges(tempIt)
                if (tempCharges < overlie) then
                    if ((currentCharges + tempCharges) <= overlie) then
                        --条件：如果旧物品足以容纳所有的新物品个数
                        --使旧物品使用次数增加，新物品删掉
                        cj.SetItemCharges(tempIt, currentCharges + tempCharges)
                        hitem.del(it, 0)
                        isOverlieOver = true
                        hitem.addAttribute(whichUnit, currentItId, currentCharges)
                        break
                    else
                        --否则，如果使用次数大于极限值,旧物品次数满载，新物品数量减少
                        cj.SetItemCharges(tempIt, overlie)
                        cj.SetItemCharges(it, currentCharges - (overlie - tempCharges))
                        hitem.addAttribute(whichUnit, currentItId, overlie - tempCharges)
                    end
                end
            end
        end
        --如果叠加已经全部消化，这里就把物品it设置为null
        if (isOverlieOver == true) then
            it = nil
        end
    end
    --如果物品还在~~
    if (it ~= nil) then
        --检查物品是否自动使用，不做处理（这种情况不应该存在，一般不会为自动物品构建shadow）
        if (hitem.getIsPowerUp(it) == true) then
            return true
        end
        --检查身上是否还有格子
        if (hitem.getEmptySlot(whichUnit) > 0) then
            --都满足了，把物品给单位
            hRuntime.item[it].type = hitem.TYPE.UNIT
            cj.UnitAddItem(whichUnit, it)
            --触发获得物品
            hevent.triggerEvent(
                {
                    triggerKey = heventKeyMap.itemGet,
                    triggerUnit = whichUnit,
                    triggerItem = it
                }
            )
            local currentItId = cj.GetItemTypeId(it)
            local currentCharges = hitem.getCharges(it)
            hitem.addAttribute(whichUnit, currentItId, currentCharges)
            it = nil
        else
            isFullSlot = true
        end
    end
    if (isFullSlot == true) then
        --todo 满格了，检查是否可以合成（合成就相当于跳过了满格，所以之前的满格是个标志位，等待合成无效才会触发满格事件）
        if (false) then
            --7物品合成检测，如果真的有合成，把满格的标志位设置为false
            isFullSlot = false
        end
    else
        --todo 没有满格，也检查身上的物品是否可以合成
        if (false) then
        --6物品合成检测
        end
    end
    if (isFullSlot) then
        --触发满格事件
        hevent.triggerEvent(
            {
                triggerKey = heventKeyMap.itemOverWeight,
                triggerUnit = whichUnit,
                triggerItem = it
            }
        )
        hRuntime.item[it].type = hitem.TYPE.COORDINATE
        return false
    end
    return true
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
        slotIndex = 0-5, -- 如果创建给单位，可以同时设置物品栏的位置（可选）
    }
    !单位模式下，during持续时间是无效的
]]
hitem.create = function(bean)
    if (bean.itemId == nil) then
        print_err("hitem create -it-id")
        return
    end
    if (bean.charges == nil) then
        bean.charges = 1
    end
    if (bean.charges < 1) then
        return
    end
    local charges = bean.charges
    local during = bean.during or 0
    -- 优先级 坐标 > 单位 > 点
    local it
    local type
    if (bean.x ~= nil and bean.y ~= nil) then
        it = cj.CreateItem(hSys.getObjId(bean.itemId), bean.x, bean.y)
        type = hitem.TYPE.COORDINATE
    elseif (bean.whichUnitPosition ~= nil) then
        it = cj.CreateItem(hSys.getObjId(bean.itemId), cj.GetUnitX(bean.whichUnit), cj.GetUnitY(bean.whichUnit))
        type = hitem.TYPE.POSITION
    elseif (bean.whichUnit ~= nil) then
        it = cj.CreateItem(hSys.getObjId(bean.itemId), cj.GetUnitX(bean.whichUnit), cj.GetUnitY(bean.whichUnit))
        type = hitem.TYPE.UNIT
    elseif (bean.whichLoc ~= nil) then
        it = cj.CreateItem(hSys.getObjId(bean.itemId), cj.GetLocationX(bean.whichLoc), cj.GetLocationY(bean.whichLoc))
        type = hitem.TYPE.LOCATION
    else
        print_err("hitem create -site")
        return
    end
    cj.SetItemCharges(it, charges)
    hRuntime.item[it] = {
        itemId = bean.itemId,
        during = bean.during,
        type = type
    }
    if (type == "unit") then
        hitem.detector(bean.whichUnit, it)
        if (bean.slotIndex ~= nil and bean.slotIndex >= 0 and bean.slotIndex <= 5) then
            cj.UnitDropItemSlot(bean.whichUnit, it, bean.slotIndex)
        end
    else
        if (during > 0) then
            htime.setTimeout(
                during,
                function(t, td)
                    htime.delDialog(td)
                    htime.delTimer(t)
                    hitem.del(it, 0)
                end
            )
        end
    end
    return it
end

-- 使一个单位的所有物品给另一个单位
hitem.give = function(origin, target)
    if (origin == nil or target == nil) then
        return
    end
    for i = 0, 5, 1 do
        local it = cj.UnitItemInSlot(origin, i)
        if (it ~= nil) then
            hitem.create(
                {
                    itemId = hitem.getId(it),
                    charges = hitem.getCharges(it),
                    whichUnit = target
                }
            )
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
            hitem.create(
                {
                    itemId = hitem.getId(it),
                    charges = hitem.getCharges(it),
                    whichUnit = target,
                    slotIndex = i
                }
            )
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
            hitem.create(
                {
                    itemId = hitem.getId(it),
                    charges = hitem.getCharges(it),
                    x = cj.GetUnitX(origin),
                    x = cj.GetUnitY(origin)
                }
            )
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
        use = cj.CreateTrigger()
    }
    --获取物品
    cj.TriggerAddAction(
        hitem.PRIVATE_TRIGGER.pickup,
        function()
            local it = cj.GetManipulatedItem()
            local itId = hSys.getObjChar(cj.GetItemTypeId(it))
            if (hslk_global.itemsKV[itId] == nil) then
                -- 排除掉没有注册的物品。例如框架内自带的一些物品
                return
            end
            if (hRuntime.item[it] ~= nil and hRuntime.item[it].type == hitem.TYPE.UNIT) then
                -- 排除掉runtime内已创建给unit的物品
                return
            end
            local u = cj.GetTriggerUnit()
            local charges = cj.GetItemCharges(it)
            local shadowItId = hitem.getShadowId(itId)
            if (shadowItId == nil) then
                if (hitem.getIsPowerUp(itId) == true) then
                    --检测是否有回调动作
                    local call = hitem.getTriggerCall(itId)
                    if (call ~= nil and type(call) == "function") then
                        call(u, it, itId, charges)
                    end
                    --触发使用物品事件
                    hevent.triggerEvent(
                        {
                            triggerKey = heventKeyMap.itemUsed,
                            triggerUnit = u,
                            triggerItem = it
                        }
                    )
                else
                    --这里删除重建是为了实现地上物品的过期重置
                    hitem.del(it, 0)
                    hitem.create(
                        {
                            itemId = itId,
                            whichUnit = u,
                            charges = charges,
                            during = 0
                        }
                    )
                end
            else
                --注意，系统内此处先获得了face物品，此物品100%是PowerUp的
                --这里删除重建是为了实现地上物品的过期重置
                hitem.del(it, 0)
                --这里是实现神符满格的关键
                hitem.create(
                    {
                        itemId = shadowItId,
                        whichUnit = u,
                        charges = charges,
                        during = 0
                    }
                )
            end
        end
    )
    --丢弃物品
    cj.TriggerAddAction(
        hitem.PRIVATE_TRIGGER.drop,
        function()
            local u = cj.GetTriggerUnit()
            local it = cj.GetManipulatedItem()
            local itId = hSys.getObjChar(cj.GetItemTypeId(it))
            local faceId = hitem.getFaceId(itId)
            local orderId = cj.OrderId("dropitem")
            local charges = cj.GetItemCharges(it)
            if (cj.GetUnitCurrentOrder(u) == orderId) then
                if (faceId == nil) then
                    hRuntime.item[it].type = hitem.TYPE.COORDINATE
                else
                    htime.setTimeout(
                        0,
                        function(t, td)
                            htime.delDialog(td)
                            htime.delTimer(t)
                            local x = cj.GetItemX(it)
                            local y = cj.GetItemX(it)
                            hitem.del(it, 0)
                            --这里是实现表面物品的关键
                            hitem.create(
                                {
                                    itemId = faceId,
                                    x = x,
                                    y = y,
                                    charges = charges,
                                    during = 0
                                }
                            )
                        end
                    )
                end
                hitem.subAttribute(u, itId, charges)
            end
        end
    )
    --抵押物品
    --[[
        抵押物品的原理，首先默认是设定：物品售卖为50%，也就是地图的默认设置
        根据玩家的sellRatio，额外的减少或增加玩家的收入
        从而实现玩家的售卖率提升，至于物品的价格是根据slk获取
        所以如果无法获取slk的属性时，此方法自动无效
    ]]
    cj.TriggerAddAction(
        hitem.PRIVATE_TRIGGER.pawn,
        function()
            local u = cj.GetTriggerUnit()
            local it = cj.GetManipulatedItem()
            local goldcost = hitem.getGoldCost(it)
            local lumbercost = hitem.getLumberCost(it)
            if (goldcost == 0 and lumbercost == 0) then
                return
            end
            local p = cj.GetOwningPlayer(u)
            local sellRatio = hplayer.getSellRatio(u)
            if (sellRatio ~= 50) then
                if (sellRatio < 0) then
                    sellRatio = 0
                elseif (sellRatio > 1000) then
                    sellRatio = 1000
                end
                local tempRatio = sellRatio - 50.0
                local tempGold = math.floor(goldcost * tempRatio * 0.01)
                local tempLumber = math.floor(lumbercost * tempRatio * 0.01)
                if (goldcost ~= 0 and tempGold ~= 0) then
                    hplayer.addGold(p, tempGold)
                end
                if (lumbercost ~= 0 and tempLumber ~= 0) then
                    hplayer.addLumber(p, tempLumber)
                end
            end
        end
    )
    --使用物品
    cj.TriggerAddAction(
        hitem.PRIVATE_TRIGGER.use,
        function()
            local u = cj.GetTriggerUnit()
            local it = cj.GetManipulatedItem()
            local itId = cj.GetItemTypeId(it)
            --检测是否使用后自动消失，如果不是，次数补回1
            if (hitem.getIsPerishable(itId) == false) then
                hitem.setCharges(it, hitem.getCharges(it) + 1)
            end
            --检测是否有回调动作
            local call = hitem.getTriggerCall(itId)
            if (call ~= nil and type(call) == "function") then
                call(u, it, itId, charges)
            end
            --触发使用物品事件
            hevent.triggerEvent(
                {
                    triggerKey = heventKeyMap.itemUsed,
                    triggerUnit = u,
                    triggerItem = it
                }
            )
        end
    )
    --拆分物品
    cj.TriggerAddAction(
        hitem.PRIVATE_TRIGGER.separate,
        function()
            local u = cj.GetTriggerUnit()
            local it = cj.GetManipulatedItem()
            if (it ~= nil and cj.GetSpellAbilityId() == hitem.DEFAULT_SKILL_ITEM_SEPARATE) then
            end
        end
    )
end

return hitem
