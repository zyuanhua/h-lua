-- 物品系统

--[[
    物品分为（item_type）
    1、永久型物品 forever
    2、消耗型物品 consume
    3、瞬逝型 moment

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

    default_skill_item_slot = hSys.getObjId('AInv'), -- 默认物品栏技能（英雄6格那个）hjass默认全部认定这个技能为物品栏，如有需要自行更改
    default_skill_item_separate = hslk_global.skill_item_separate, -- 默认拆分物品技能
    typeMap = {
        forever = 'forever',
        consume = 'consume',
        moment = 'moment',
    }

}

-- 删除物品，可延时
hitem.del = function(it, during)
    if (during <= 0) then
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
        charge = 1, --物品可使用次数（可选，默认为1）
        whichUnit = nil, --哪个单位（可选）
        x = nil, --哪个坐标X（可选）
        y = nil, --哪个坐标Y（可选）
        whichLoc = nil, --哪个点（可选，不推荐）
        during = 0, --持续时间（可选，创建给单位要注意powerUp物品的问题）
    }
]]
hitem.create = function(bean)
    if (bean.itemId == nil) then
        print("htime create -it-id")
        return
    end
    local charge = bean.charge or 1
    local during = bean.during or 0
    -- 优先级 坐标 > 单位 > 点
    local it
    if (bean.x == nil and bean.y == nil) then
        it = cj.CreateItem(hSys.getObjId(bean.itemId), bean.x, bean.y)
    elseif (bean.whichUnit == nil) then
        it = cj.CreateItem(hSys.getObjId(bean.itemId), cj.GetLocationX(bean.whichUnit), cj.GetLocationY(bean.whichUnit))
        cj.UnitAddItem(bean.whichUnit, it)
    elseif (bean.whichLoc == nil) then
        it = cj.CreateItem(hSys.getObjId(bean.itemId), cj.GetLocationX(bean.whichLoc), cj.GetLocationY(bean.whichLoc))
    else
        print("htime create -site")
        return
    end
    cj.SetItemCharges(it, charge)
    if (during > 0) then
        htime.setTimeout(during, function(t, td)
            htime.delDialog(td)
            htime.delTimer(t)
            hitem.del(it, 0)
        end)
    end
end

-- 使一个单位的所有物品给另一个单位
hitem.give = function(origin, target)
    if (origin == nil or target == nil) then
        return
    end
    for i = 0, 5, 1 do
        local it = cj.UnitItemInSlot(origin, i)
        if (it ~= nil) then
            hitem.toUnitPrivate(cj.GetItemTypeId(it), cj.GetItemCharges(it), target, false)
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
            hitem.toUnitPrivate(cj.GetItemTypeId(it), cj.GetItemCharges(it), target, false)
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
            htime.toXY(cj.GetItemTypeId(it), cj.GetItemCharges(it), cj.GetUnitX(origin), cj.GetUnitY(origin), -1)
            htime.del(it, 0)
        end
    end
end

return hitem
