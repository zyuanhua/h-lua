-- 属性系统
hattr = {
    max_move_speed = 522,
    max_life = 999999999,
    max_mana = 999999999,
    min_life = 1,
    min_mana = 1,
    max_attack_range = 9999,
    min_attack_range = 0,
    default_attack_speed_space = 1.50,
    DEFAULT_SKILL_ITEM_SLOT = string.char2id("AInv") -- 默认物品栏技能（英雄6格那个）默认认定这个技能为物品栏
}

--- 为单位添加N个同样的生命魔法技能 1级设0 2级设负 负减法（百度谷歌[卡血牌bug]，了解原理）
hattr.setLM = function(u, abilityId, qty)
    if (qty <= 0) then
        return
    end
    local i = 1
    while (i <= qty) do
        cj.UnitAddAbility(u, abilityId)
        cj.SetUnitAbilityLevel(u, abilityId, 2)
        cj.UnitRemoveAbility(u, abilityId)
        i = i + 1
    end
end

--- 为单位添加N个同样的攻击之书
hattr.setAttackWhite = function(u, itemId, qty)
    if (u == nil or itemId == nil or qty <= 0) then
        return
    end
    if (his.alive(u) == true) then
        local i = 1
        local it
        local hasSlot = (cj.GetUnitAbilityLevel(u, hattr.DEFAULT_SKILL_ITEM_SLOT) >= 1)
        if (hasSlot == false) then
            cj.UnitAddAbility(u, hattr.DEFAULT_SKILL_ITEM_SLOT)
        end
        while (i <= qty) do
            it = cj.CreateItem(itemId, 0, 0)
            cj.UnitAddItem(u, it)
            cj.SetWidgetLife(it, 10.00)
            cj.RemoveItem(it)
            i = i + 1
        end
        if (hasSlot == false) then
            cj.UnitRemoveAbility(u, hattr.DEFAULT_SKILL_ITEM_SLOT)
        end
    else
        local per = 3.00
        local limit = 60.0 / per -- 一般不会超过1分钟复活
        htime.setInterval(
            per,
            function(t, td)
                limit = limit - 1
                if (limit < 0) then
                    htime.delDialog(td)
                    htime.delTimer(t)
                elseif (his.alive(u) == true) then
                    htime.delDialog(td)
                    htime.delTimer(t)
                    local i = 1
                    local it
                    local hasSlot = (cj.GetUnitAbilityLevel(u, hattr.DEFAULT_SKILL_ITEM_SLOT) >= 1)
                    if (hasSlot == false) then
                        cj.UnitAddAbility(u, hattr.DEFAULT_SKILL_ITEM_SLOT)
                    end
                    while (i <= qty) do
                        it = cj.CreateItem(itemId, 0, 0)
                        cj.UnitAddItem(u, it)
                        cj.SetWidgetLife(it, 10.00)
                        cj.RemoveItem(it)
                        i = i + 1
                    end
                    if (hasSlot == false) then
                        cj.UnitRemoveAbility(u, hattr.DEFAULT_SKILL_ITEM_SLOT)
                    end
                end
            end
        )
    end
end
--- 设置三围的影响
hattr.setThreeBuff = function(buff)
    if (type(buff) == "table") then
        hRuntime.attributeThreeBuff = buff
    end
end
--- 为单位注册属性系统所需要的基础技能
--- hslk_global.attr
hattr.regAllAbility = function(whichUnit)
    --生命魔法
    for _, ability in pairs(hslk_global.attr.life.add) do
        cj.UnitAddAbility(whichUnit, ability)
        cj.UnitRemoveAbility(whichUnit, ability)
    end
    for _, ability in pairs(hslk_global.attr.life.sub) do
        cj.UnitAddAbility(whichUnit, ability)
        cj.UnitRemoveAbility(whichUnit, ability)
    end
    for _, ability in pairs(hslk_global.attr.mana.add) do
        cj.UnitAddAbility(whichUnit, ability)
        cj.UnitRemoveAbility(whichUnit, ability)
    end
    for _, ability in pairs(hslk_global.attr.mana.sub) do
        cj.UnitAddAbility(whichUnit, ability)
        cj.UnitRemoveAbility(whichUnit, ability)
    end
    --物品栏
    if (cj.GetUnitAbilityLevel(whichUnit, hattr.DEFAULT_SKILL_ITEM_SLOT) < 1) then
        cj.UnitAddAbility(whichUnit, hattr.DEFAULT_SKILL_ITEM_SLOT)
        cj.UnitRemoveAbility(whichUnit, hattr.DEFAULT_SKILL_ITEM_SLOT)
    end
    --绿字攻击
    for _, ability in pairs(hslk_global.attr.attack_green.add) do
        cj.UnitAddAbility(whichUnit, ability)
        cj.UnitMakeAbilityPermanent(whichUnit, true, ability)
        cj.SetUnitAbilityLevel(whichUnit, ability, 1)
    end
    for _, ability in pairs(hslk_global.attr.attack_green.sub) do
        cj.UnitAddAbility(whichUnit, ability)
        cj.UnitMakeAbilityPermanent(whichUnit, true, ability)
        cj.SetUnitAbilityLevel(whichUnit, ability, 1)
    end
    --绿色属性
    for _, ability in pairs(hslk_global.attr.str_green.add) do
        cj.UnitAddAbility(whichUnit, ability)
        cj.UnitMakeAbilityPermanent(whichUnit, true, ability)
        cj.SetUnitAbilityLevel(whichUnit, ability, 1)
    end
    for _, ability in pairs(hslk_global.attr.str_green.sub) do
        cj.UnitAddAbility(whichUnit, ability)
        cj.UnitMakeAbilityPermanent(whichUnit, true, ability)
        cj.SetUnitAbilityLevel(whichUnit, ability, 1)
    end
    for _, ability in pairs(hslk_global.attr.agi_green.add) do
        cj.UnitAddAbility(whichUnit, ability)
        cj.UnitMakeAbilityPermanent(whichUnit, true, ability)
        cj.SetUnitAbilityLevel(whichUnit, ability, 1)
    end
    for _, ability in pairs(hslk_global.attr.agi_green.sub) do
        cj.UnitAddAbility(whichUnit, ability)
        cj.UnitMakeAbilityPermanent(whichUnit, true, ability)
        cj.SetUnitAbilityLevel(whichUnit, ability, 1)
    end
    for _, ability in pairs(hslk_global.attr.int_green.add) do
        cj.UnitAddAbility(whichUnit, ability)
        cj.UnitMakeAbilityPermanent(whichUnit, true, ability)
        cj.SetUnitAbilityLevel(whichUnit, ability, 1)
    end
    for _, ability in pairs(hslk_global.attr.int_green.sub) do
        cj.UnitAddAbility(whichUnit, ability)
        cj.UnitMakeAbilityPermanent(whichUnit, true, ability)
        cj.SetUnitAbilityLevel(whichUnit, ability, 1)
    end
    --攻击速度
    for _, ability in pairs(hslk_global.attr.attack_speed.add) do
        cj.UnitAddAbility(whichUnit, ability)
        cj.UnitMakeAbilityPermanent(whichUnit, true, ability)
        cj.SetUnitAbilityLevel(whichUnit, ability, 1)
    end
    for _, ability in pairs(hslk_global.attr.attack_speed.sub) do
        cj.UnitAddAbility(whichUnit, ability)
        cj.UnitMakeAbilityPermanent(whichUnit, true, ability)
        cj.SetUnitAbilityLevel(whichUnit, ability, 1)
    end
    --防御
    for _, ability in pairs(hslk_global.attr.defend.add) do
        cj.UnitAddAbility(whichUnit, ability)
        cj.UnitMakeAbilityPermanent(whichUnit, true, ability)
        cj.SetUnitAbilityLevel(whichUnit, ability, 1)
    end
    for _, ability in pairs(hslk_global.attr.defend.sub) do
        cj.UnitAddAbility(whichUnit, ability)
        cj.UnitMakeAbilityPermanent(whichUnit, true, ability)
        cj.SetUnitAbilityLevel(whichUnit, ability, 1)
    end
    --白字攻击
    for _, ability in pairs(hslk_global.attr.attack_white.add) do
        cj.UnitMakeAbilityPermanent(whichUnit, true, ability)
    end
    for _, ability in pairs(hslk_global.attr.attack_white.sub) do
        cj.UnitMakeAbilityPermanent(whichUnit, true, ability)
    end
    --视野
    for _, ability in pairs(hslk_global.attr.sight.add) do
        cj.UnitMakeAbilityPermanent(whichUnit, true, ability)
    end
    for _, ability in pairs(hslk_global.attr.sight.sub) do
        cj.UnitMakeAbilityPermanent(whichUnit, true, ability)
    end
end
--- 为单位注册属性系统所需要的基础技能
--- hslk_global.attr
hattr.registerAll = function(whichUnit)
    if (whichUnit == nil) then
        return
    end
    hattr.regAllAbility(whichUnit)
    --init
    local unitId = string.id2char(cj.GetUnitTypeId(whichUnit))
    if (unitId == nil) then
        print_err("unresgister unitId is nil")
        return
    end
    if (hslk_global.unitsKV[unitId] == nil) then
        print_err("unresgister hslk_global.unitsKV:" .. cj.GetUnitName(whichUnit) .. unitId)
        return
    end
    hRuntime.attribute[whichUnit] = {
        primary = hslk_global.unitsKV[unitId].Primary or "NIL",
        be_hunting = false,
        --
        life = cj.GetUnitState(whichUnit, UNIT_STATE_MAX_LIFE),
        mana = cj.GetUnitState(whichUnit, UNIT_STATE_MAX_MANA),
        move = hslk_global.unitsKV[unitId].spd or cj.GetUnitDefaultMoveSpeed(whichUnit),
        defend = hslk_global.unitsKV[unitId].def or 0.0,
        attack_damage_type = {}, --- sp
        attack_speed = 0.0,
        attack_speed_space = hslk_global.unitsKV[unitId].cool1 or hattr.default_attack_speed_space,
        attack_white = 0.0,
        attack_green = 0.0,
        attack_range = hslk_global.unitsKV[unitId].rangeN1 or 100.0,
        sight = hslk_global.unitsKV[unitId].sight or 800,
        str_green = 0.0,
        agi_green = 0.0,
        int_green = 0.0,
        str_white = cj.GetHeroStr(whichUnit, false),
        agi_white = cj.GetHeroAgi(whichUnit, false),
        int_white = cj.GetHeroInt(whichUnit, false),
        life_back = 0.0,
        life_source = 0.0,
        life_source_current = 0.0,
        mana_back = 0.0,
        mana_source = 0.0,
        mana_source_current = 0.0,
        resistance = 0.0,
        toughness = 0.0,
        avoid = 0.0,
        aim = 0.0,
        punish = cj.GetUnitState(whichUnit, UNIT_STATE_MAX_LIFE) / 2,
        punish_current = cj.GetUnitState(whichUnit, UNIT_STATE_MAX_LIFE) / 2,
        meditative = 0.0,
        help = 0.0,
        hemophagia = 0.0,
        hemophagia_skill = 0.0,
        luck = 0.0,
        invincible = 0.0,
        weight = 0.0,
        weight_current = 0.0,
        damage_extent = 0.0,
        damage_rebound = 0.0,
        cure = 0.0,
        knocking_oppose = 0.0,
        violence_oppose = 0.0,
        hemophagia_oppose = 0.0,
        hemophagia_skill_oppose = 0.0,
        split_oppose = 0.0,
        punish_oppose = 0.0,
        damage_rebound_oppose = 0.0,
        swim_oppose = 0.0,
        heavy_oppose = 0.0,
        broken_oppose = 0.0,
        unluck_oppose = 0.0,
        silent_oppose = 0.0,
        unarm_oppose = 0.0,
        fetter_oppose = 0.0,
        bomb_oppose = 0.0,
        lightning_chain_oppose = 0.0,
        crack_fly_oppose = 0.0,
        natural_fire = 0.0,
        natural_soil = 0.0,
        natural_water = 0.0,
        natural_ice = 0.0,
        natural_wind = 0.0,
        natural_light = 0.0,
        natural_dark = 0.0,
        natural_wood = 0.0,
        natural_thunder = 0.0,
        natural_poison = 0.0,
        natural_ghost = 0.0,
        natural_metal = 0.0,
        natural_dragon = 0.0,
        natural_insect = 0.0,
        natural_god = 0.0,
        natural_fire_oppose = 0.0,
        natural_soil_oppose = 0.0,
        natural_water_oppose = 0.0,
        natural_ice_oppose = 0.0,
        natural_wind_oppose = 0.0,
        natural_light_oppose = 0.0,
        natural_dark_oppose = 0.0,
        natural_wood_oppose = 0.0,
        natural_thunder_oppose = 0.0,
        natural_poison_oppose = 0.0,
        natural_ghost_oppose = 0.0,
        natural_metal_oppose = 0.0,
        natural_dragon_oppose = 0.0,
        natural_insect_oppose = 0.0,
        natural_god_oppose = 0.0,
        --
        attack_buff = {}, -- array
        attack_debuff = {}, -- array
        skill_buff = {}, -- array
        skill_debuff = {}, -- array
        -- 特殊特效
        attack_effect = {},
        skill_effect = {}
        --[[
            buff/debuff例子
            attack_buff = {
                攻击伤害时buff=20%几率增加自身 1.5% 的攻击速度 3 秒
                add = { --这个add表示添加这一种效果，而不是数值的增减
                    { attr="attack_speed", odds = 20.0, val = 1.5, during = 3.0, effect = nil },
                },
                sub = { --这个sub表示删除这一种效果，如果效果不存在，而无动作
                    { attr="attack_speed", odds = 20.0, val = 1.5, during = 3.0, effect = nil },
                }
            }
            skill_debuff = {
                技能伤害时buff=13%几率减少目标 3.5% 的攻击速度 4.4 秒，特效是 war3mapImported\\ExplosionBIG.mdl
                add = {
                    { attr="move",odds = 13.0, val = 3.5, during = 4.4, effect = 'war3mapImported\\ExplosionBIG.mdl' },
                },
                sub = { --这个sub表示删除这一种效果，如果效果不存在，而无动作
                    { attr="move",odds = 13.0, val = 3.5, during = 4.4, effect = 'war3mapImported\\ExplosionBIG.mdl' },
                }
            }
            attack_effect / skill_effect同理,effect只能设定下列的值，会在属性系统自动调用：
                {attr="knocking",odds = 0.0, percent = 0.0, effect = nil},
                {attr="violence",odds = 0.0, percent = 0.0, effect = nil},
                {attr="split",odds = 0.0, percent=0.0, range = 0.0, effect = nil},
                {attr="swim",odds = 0.0, val = 0.0, during = 0.0, effect = nil},
                {attr="broken",odds = 0.0, val = 0.0, during = 0.0, effect = nil},
                {attr="silent",odds = 0.0, val = 0.0, during = 0.0, effect = nil},
                {attr="unarm",odds = 0.0, val = 0.0, during = 0.0, effect = nil},
                {attr="fetter",odds = 0.0, val = 0.0, during = 0.0, effect = nil},
                {attr="bomb",odds = 0.0, val = 0.0, during = 0.0, effect = nil},
                {attr="lightning_chain",odds = 0.0, val = 0.0, during = 0.0, effect = nil, qty = 0, reduce = 0.0},
                {attr="crack_fly",odds = 0.0, val = 0.0, during = 0.0, effect = nil, distance = 0, high = 0.0}
            * 至于是否同一种效果，是根据你设定的值自动计算出来的
        ]]
    }
    -- 智力英雄的攻击默认为魔法，力量敏捷为物理
    if (hRuntime.attribute[whichUnit].primary == "INT") then
        hRuntime.attribute[whichUnit].attack_damage_type = {CONST_DAMAGE_TYPE.magic}
    else
        hRuntime.attribute[whichUnit].attack_damage_type = {CONST_DAMAGE_TYPE.physical}
    end
end

--积累性diff
hattr.getAccumuDiff = function(whichUnit, attr)
    if (hRuntime.attributeDiff[whichUnit] == nil) then
        hRuntime.attributeDiff[whichUnit] = {}
    end
    return hRuntime.attributeDiff[whichUnit][attr] or 0
end

hattr.setAccumuDiff = function(whichUnit, attr, value)
    if (hRuntime.attributeDiff[whichUnit] == nil) then
        hRuntime.attributeDiff[whichUnit] = {}
    end
    hRuntime.attributeDiff[whichUnit][attr] = math.round(value)
end

hattr.addAccumuDiff = function(whichUnit, attr, value)
    hattr.setAccumuDiff(whichUnit, attr, hattr.getAccumuDiff(whichUnit, attr) + value)
end

hattr.subAccumuDiff = function(whichUnit, attr, value)
    hattr.setAccumuDiff(whichUnit, attr, hattr.getAccumuDiff(whichUnit, attr) - value)
end

---设定属性
--[[
    白字攻击 绿字攻击
    攻速 视野 射程
    力敏智 力敏智(绿)
    护甲 魔抗
    生命 魔法 +恢复
    硬直
    物暴 术暴 分裂 回避 移动力 力量 敏捷 智力 救助力 吸血 负重 各率
    type(data) == table
    data = { 支持 加/减/乘/除/等
        life = '+100',
        mana = '-100',
        life_back = '*100',
        mana_back = '/100',
        move = '=100',
    }
    during = 0.0 大于0生效；小于等于0时无限持续时间
]]
hattr.setHandle = function(whichUnit, attr, opr, val, dur)
    local valType = type(val)
    local params = hRuntime.attribute[whichUnit]
    if (params == nil) then
        return
    end
    if (valType == "string") then
        -- string类型只有+-=
        if (opr == "+") then
            -- 添加
            local valArr = string.explode(",", val)
            params[attr] = table.merge(params[attr], valArr)
            if (dur > 0) then
                htime.setTimeout(
                    dur,
                    function(t, td)
                        htime.delDialog(td)
                        htime.delTimer(t)
                        hattr.setHandle(whichUnit, attr, "-", val, 0)
                    end
                )
            end
        elseif (opr == "-") then
            -- 减少
            local valArr = string.explode(",", val)
            for _, v in ipairs(valArr) do
                if (table.includes(v, params[attr])) then
                    table.delete(v, params[attr], 1)
                end
            end
            if (dur > 0) then
                htime.setTimeout(
                    dur,
                    function(t, td)
                        htime.delDialog(td)
                        htime.delTimer(t)
                        hattr.setHandle(whichUnit, attr, "+", val, 0)
                    end
                )
            end
        elseif (opr == "=") then
            -- 设定
            local old = table.clone(params[attr])
            params[attr] = string.explode(",", val)
            if (dur > 0) then
                htime.setTimeout(
                    dur,
                    function(t, td)
                        htime.delDialog(td)
                        htime.delTimer(t)
                        hattr.setHandle(whichUnit, attr, "=", string.implode(",", old), 0)
                    end
                )
            end
        end
    elseif (valType == "table") then
        -- table类型只有+-没有别的
        if (opr == "+") then
            -- 添加
            local hkey = string.md5(val)
            table.insert(params[attr], {hash = hkey, table = val})
            if (dur > 0) then
                htime.setTimeout(
                    dur,
                    function(t, td)
                        htime.delDialog(td)
                        htime.delTimer(t)
                        hattr.setHandle(whichUnit, attr, "-", val, 0)
                    end
                )
            end
        elseif (opr == "-") then
            -- 减少
            local hkey = string.md5(val)
            local hasKey = false
            for k, v in pairs(params[attr]) do
                if (v.hash == hkey) then
                    table.remove(params[attr], k)
                    hasKey = true
                    break
                end
            end
            if (hasKey == true) then
                if (dur > 0) then
                    htime.setTimeout(
                        dur,
                        function(t, td)
                            htime.delDialog(td)
                            htime.delTimer(t)
                            hattr.setHandle(whichUnit, attr, "+", val, 0)
                        end
                    )
                end
            end
        end
    elseif (valType == "number") then
        -- number
        local intAttr = {
            "life",
            "mana",
            "move",
            "attack_white",
            "attack_green",
            "attack_range",
            "sight",
            "defend",
            "str_white",
            "agi_white",
            "int_white",
            "str_green",
            "agi_green",
            "int_green",
            "punish"
        }
        local isInt = false
        if (table.includes(attr, intAttr)) then
            isInt = true
        end
        --
        local diff = 0
        if (opr == "+") then
            diff = val
        elseif (opr == "-") then
            diff = -val
        elseif (opr == "*") then
            diff = params[attr] * val - params[attr]
        elseif (opr == "/" and val ~= 0) then
            diff = params[attr] / val - params[attr]
        elseif (opr == "=") then
            diff = val - params[attr]
        end
        local isAccumuDiff = false
        local accumuDiff = hattr.getAccumuDiff(whichUnit, attr)
        if (diff * accumuDiff > 0) then
            isAccumuDiff = true
            diff = diff + accumuDiff
        end
        --部分属性取整处理，否则失真
        if (isInt and diff ~= 0) then
            local di, df = math.modf(math.abs(diff))
            if (isAccumuDiff) then
                if (diff >= 0) then
                    hattr.setAccumuDiff(whichUnit, attr, df)
                else
                    hattr.setAccumuDiff(whichUnit, attr, -df)
                end
            else
                if (diff >= 0) then
                    hattr.addAccumuDiff(whichUnit, attr, df)
                else
                    hattr.subAccumuDiff(whichUnit, attr, df)
                end
            end
            if (diff >= 0) then
                diff = di
            else
                diff = -di
            end
        end
        if (diff ~= 0) then
            local currentVal = params[attr]
            local futureVal = params[attr] + diff
            params[attr] = futureVal
            if (dur > 0) then
                htime.setTimeout(
                    dur,
                    function(t, td)
                        htime.delDialog(td)
                        htime.delTimer(t)
                        hattr.setHandle(whichUnit, attr, "-", diff, 0)
                    end
                )
            end
            -- ability
            local tempVal = 0
            local level = 0
            if (attr == "life" or attr == "mana") then
                --- 生命 | 魔法
                if (futureVal >= hattr["max_" .. attr]) then
                    if (currentVal >= hattr["max_" .. attr]) then
                        diff = 0
                    else
                        diff = hattr["max_" .. attr] - currentVal
                    end
                elseif (futureVal <= hattr["min_" .. attr]) then
                    if (currentVal <= hattr["min_" .. attr]) then
                        diff = 0
                    else
                        diff = hattr["min_" .. attr] - currentVal
                    end
                end
                tempVal = math.floor(math.abs(diff))
                local max = 100000000
                if (tempVal ~= 0) then
                    while (max >= 1) do
                        level = math.floor(tempVal / max)
                        tempVal = math.floor(tempVal - level * max)
                        if (diff > 0) then
                            hattr.setLM(whichUnit, hslk_global.attr[attr].add[max], level)
                        else
                            hattr.setLM(whichUnit, hslk_global.attr[attr].sub[max], level)
                        end
                        max = math.floor(max / 10)
                    end
                end
            elseif (attr == "move") then
                --- 移动
                if (futureVal < 0) then
                    cj.SetUnitMoveSpeed(whichUnit, 0)
                else
                    if (hcamera.getModel(cj.GetOwningPlayer(whichUnit)) == "zoomin") then
                        cj.SetUnitMoveSpeed(whichUnit, math.floor(futureVal * 0.5))
                    else
                        cj.SetUnitMoveSpeed(whichUnit, math.floor(futureVal))
                    end
                end
            elseif (attr == "attack_white") then
                --- 白字攻击
                local max = 100000000
                if (futureVal > max or futureVal < -max) then
                    diff = 0
                end
                tempVal = math.floor(math.abs(diff))
                if (tempVal ~= 0) then
                    while (max >= 1) do
                        level = math.floor(tempVal / max)
                        tempVal = math.floor(tempVal - level * max)
                        if (diff > 0) then
                            hattr.setAttackWhite(whichUnit, hslk_global.attr.item_attack_white.add[max], level)
                        else
                            hattr.setAttackWhite(whichUnit, hslk_global.attr.item_attack_white.sub[max], level)
                        end
                        max = math.floor(max / 10)
                    end
                end
            elseif (attr == "attack_range") then
                --- 攻击范围(仅仅是自动警示范围)
                if (futureVal < hattr.min_attack_range) then
                    futureVal = hattr.min_attack_range
                elseif (futureVal > hattr.max_attack_range) then
                    futureVal = hattr.max_attack_range
                end
                if (hcamera.getModel(cj.GetOwningPlayer(whichUnit)) == "zoomin") then
                    futureVal = futureVal * 0.5
                end
                cj.SetUnitAcquireRange(whichUnit, futureVal * 1.1)
            elseif (attr == "sight") then
                --- 视野
                if (futureVal < -hattr.max_sight) then
                    futureVal = -hattr.max_sight
                elseif (futureVal > hattr.max_sight) then
                    futureVal = hattr.max_sight
                end
                for _, ability in pairs(hslk_global.attr.sight.add) do
                    cj.UnitRemoveAbility(whichUnit, ability)
                end
                for _, ability in pairs(hslk_global.attr.sight.sub) do
                    cj.UnitRemoveAbility(whichUnit, ability)
                end
                tempVal = math.floor(math.abs(futureVal))
                local sightTotal = table.clone(hslk_global.attr.sightTotal)
                if (tempVal ~= 0) then
                    while (true) do
                        local isFound = false
                        for _, v in pairs(sightTotal) do
                            if (tempVal >= v) then
                                tempVal = math.floor(tempVal - v)
                                table.delete(v, sightTotal)
                                if (futureVal > 0) then
                                    cj.UnitAddAbility(whichUnit, hslk_global.attr.sight.add[v])
                                else
                                    cj.UnitAddAbility(whichUnit, hslk_global.attr.sight.sub[v])
                                end
                                isFound = true
                                break
                            end
                        end
                        if (isFound == false) then
                            break
                        end
                    end
                end
            elseif (table.includes(attr, {"attack_green", "attack_speed", "defend"})) then
                --- 绿字攻击 攻击速度 护甲
                if (futureVal < -99999999) then
                    futureVal = -99999999
                elseif (futureVal > 99999999) then
                    futureVal = 99999999
                end
                for _, ability in pairs(hslk_global.attr[attr].add) do
                    cj.SetUnitAbilityLevel(whichUnit, ability, 1)
                end
                for _, ability in pairs(hslk_global.attr[attr].sub) do
                    cj.SetUnitAbilityLevel(whichUnit, ability, 1)
                end
                tempVal = math.floor(math.abs(futureVal))
                local max = 100000000
                if (tempVal ~= 0) then
                    while (max >= 1) do
                        level = math.floor(tempVal / max)
                        tempVal = math.floor(tempVal - level * max)
                        if (futureVal > 0) then
                            cj.SetUnitAbilityLevel(whichUnit, hslk_global.attr[attr].add[max], level + 1)
                        else
                            cj.SetUnitAbilityLevel(whichUnit, hslk_global.attr[attr].sub[max], level + 1)
                        end
                        max = math.floor(max / 10)
                    end
                end
            elseif (his.hero(whichUnit) and table.includes(attr, {"str_green", "agi_green", "int_green"})) then
                --- 绿字力量 绿字敏捷 绿字智力
                if (futureVal < -99999999) then
                    futureVal = -99999999
                elseif (futureVal > 99999999) then
                    futureVal = 99999999
                end
                for _, ability in pairs(hslk_global.attr[attr].add) do
                    cj.SetUnitAbilityLevel(whichUnit, ability, 1)
                end
                for _, ability in pairs(hslk_global.attr[attr].sub) do
                    cj.SetUnitAbilityLevel(whichUnit, ability, 1)
                end
                tempVal = math.floor(math.abs(futureVal))
                local max = 100000000
                if (tempVal ~= 0) then
                    while (max >= 1) do
                        level = math.floor(tempVal / max)
                        tempVal = math.floor(tempVal - level * max)
                        if (futureVal > 0) then
                            cj.SetUnitAbilityLevel(whichUnit, hslk_global.attr[attr].add[max], level + 1)
                        else
                            cj.SetUnitAbilityLevel(whichUnit, hslk_global.attr[attr].sub[max], level + 1)
                        end
                        max = math.floor(max / 10)
                    end
                end
                local setting = {}
                for k, v in pairs(hRuntime.attributeThreeBuff[string.gsub(attr, "_green", "")]) do
                    local tempV = diff * v
                    if (tempV < 0) then
                        setting[k] = "-" .. math.abs(tempV)
                    elseif (tempV > 0) then
                        setting[k] = "+" .. tempV
                    end
                end
                hattr.set(whichUnit, 0, setting)
            elseif (his.hero(whichUnit) and table.includes(attr, {"str_white", "agi_white", "int_white"})) then
                --- 白字力量 敏捷 智力
                if (attr == "str_white") then
                    cj.SetHeroStr(whichUnit, math.floor(futureVal), true)
                elseif (attr == "agi_white") then
                    cj.SetHeroAgi(whichUnit, math.floor(futureVal), true)
                elseif (attr == "int_white") then
                    cj.SetHeroInt(whichUnit, math.floor(futureVal), true)
                end
                local setting = {}
                for k, v in pairs(hRuntime.attributeThreeBuff[string.gsub(attr, "_white", "")]) do
                    local tempV = diff * v
                    if (tempV < 0) then
                        setting[k] = "-" .. math.abs(tempV)
                    elseif (tempV > 0) then
                        setting[k] = "+" .. tempV
                    end
                end
                hattr.set(whichUnit, 0, setting)
            elseif (attr == "life_back" or attr == "mana_back") then
                --- 生命恢复 魔法恢复
                if (math.abs(futureVal) > 0.02 and table.includes(whichUnit, hRuntime.attributeGroup[attr]) == false) then
                    table.insert(hRuntime.attributeGroup[attr], whichUnit)
                elseif (math.abs(futureVal) < 0.02) then
                    table.delete(whichUnit, hRuntime.attributeGroup[attr])
                end
            elseif (attr == "life_source_current" or attr == "mana_source_current") then
                --- 生命源 魔法源(current)
                local attrSource = string.gsub(attr, "_current", "", 1)
                if (futureVal > hRuntime.attribute[whichUnit][attrSource]) then
                    futureVal = hRuntime.attribute[whichUnit][attrSource]
                    hRuntime.attribute[whichUnit][attr] = futureVal
                end
                if (math.abs(futureVal) > 1 and table.includes(whichUnit, hRuntime.attributeGroup[attrSource]) == false) then
                    table.insert(hRuntime.attributeGroup[attrSource], whichUnit)
                elseif (math.abs(futureVal) < 1) then
                    table.delete(whichUnit, hRuntime.attributeGroup[attrSource])
                end
            elseif (attr == "punish" and hunit.isOpenPunish(whichUnit)) then
                --- 硬直
                if (currentVal > 0) then
                    local tempPercent = futureVal / currentVal
                    hRuntime.attribute[whichUnit].punish_current =
                        tempPercent * hRuntime.attribute[whichUnit].punish_current
                else
                    hRuntime.attribute[whichUnit].punish_current = futureVal
                end
            elseif (attr == "punish_current" and hunit.isOpenPunish(whichUnit)) then
                --- 硬直(current)
                if (futureVal > hRuntime.attribute[whichUnit].punish) then
                    hRuntime.attribute[whichUnit].punish_current = hRuntime.attribute[whichUnit].punish
                end
            end
        end
    end
end
hattr.set = function(whichUnit, during, data)
    if (whichUnit == nil) then
        print_stack("whichUnit is nil")
        return
    end
    if (hRuntime.attribute[whichUnit] == nil) then
        hattr.registerAll(whichUnit)
    end
    -- 处理data
    if (type(data) ~= "table") then
        print_err("data must be table")
        return
    end
    for attr, v in pairs(data) do
        if (hRuntime.attribute[whichUnit][attr] ~= nil) then
            if (type(v) == "string") then
                local opr = string.sub(v, 1, 1)
                v = string.sub(v, 2, string.len(v))
                local val = tonumber(v)
                if (val == nil) then
                    val = v
                end
                hattr.setHandle(whichUnit, attr, opr, val, during)
            elseif (type(v) == "table") then
                -- table型，如特效，buff等
                if (v.add ~= nil and type(v.add) == "table") then
                    for _, buff in pairs(v.add) do
                        if (buff == nil) then
                            print_err("table effect loss[buff]!")
                            print_stack()
                            break
                        end
                        if (type(buff) ~= "table") then
                            print_err("add type(buff) must be a table!")
                            print_stack()
                            break
                        end
                        hattr.setHandle(whichUnit, attr, "+", buff, during)
                    end
                elseif (v.sub ~= nil and type(v.sub) == "table") then
                    for _, buff in pairs(v.sub) do
                        if (buff == nil) then
                            print_err("table effect loss[buff]!")
                            print_stack()
                            break
                        end
                        if (type(buff) ~= "table") then
                            print_err("sub type(buff) must be a table!")
                            print_stack()
                            break
                        end
                        hattr.setHandle(whichUnit, attr, "-", buff, during)
                    end
                end
            end
        end
    end
end

--- 通用get
hattr.get = function(whichUnit, attr)
    if (whichUnit == nil) then
        return nil
    end
    if (hRuntime.attribute[whichUnit] == nil) then
        hattr.registerAll(whichUnit)
    end
    if (attr == nil) then
        return hRuntime.attribute[whichUnit]
    end
    return hRuntime.attribute[whichUnit][attr]
end

---重置注册
hattr.reRegister = function(whichUnit)
    local life = hRuntime.attribute[whichUnit].life
    local mana = hRuntime.attribute[whichUnit].mana
    local move = hRuntime.attribute[whichUnit].move
    local strGreen = hRuntime.attribute[whichUnit].str_green
    local agiGreen = hRuntime.attribute[whichUnit].agi_green
    local intGreen = hRuntime.attribute[whichUnit].int_green
    local strWhite = hRuntime.attribute[whichUnit].str_white
    local agiWhite = hRuntime.attribute[whichUnit].agi_white
    local intWhite = hRuntime.attribute[whichUnit].int_white
    local attackWhite = hRuntime.attribute[whichUnit].attack_white
    local attackGreen = hRuntime.attribute[whichUnit].attack_green
    local attackSpeed = hRuntime.attribute[whichUnit].attack_speed
    local defend = hRuntime.attribute[whichUnit].defend
    -- 注册技能
    hattr.registerAll(whichUnit)
    -- 弥补属性
    cj.SetHeroStr(whichUnit, cj.R2I(strWhite), true)
    cj.SetHeroAgi(whichUnit, cj.R2I(agiWhite), true)
    cj.SetHeroInt(whichUnit, cj.R2I(intWhite), true)
    if (move < 0) then
        cj.SetUnitMoveSpeed(whichUnit, 0)
    else
        if (hcamera.model == "zoomin") then
            cj.SetUnitMoveSpeed(whichUnit, cj.R2I(move * 0.5))
        else
            cj.SetUnitMoveSpeed(whichUnit, cj.R2I(move))
        end
    end
    hRuntime.attribute[whichUnit].life = cj.GetUnitState(whichUnit, UNIT_STATE_MAX_LIFE)
    hRuntime.attribute[whichUnit].mana = cj.GetUnitState(whichUnit, UNIT_STATE_MAX_MANA)
    hRuntime.attribute[whichUnit].defend = hslk_global.unitsKV[unitId].def or 0.0
    hRuntime.attribute[whichUnit].attack_speed = 0
    hRuntime.attribute[whichUnit].attack_white = 0
    hRuntime.attribute[whichUnit].attack_green = 0
    hRuntime.attribute[whichUnit].str_green = 0
    hRuntime.attribute[whichUnit].agi_green = 0
    hRuntime.attribute[whichUnit].int_green = 0
    hattr.set(
        whichUnit,
        0,
        {
            life = "+" .. (life - cj.GetUnitState(whichUnit, UNIT_STATE_MAX_LIFE)),
            mana = "+" .. (mana - cj.GetUnitState(whichUnit, UNIT_STATE_MAX_LIFE)),
            str_green = "+" .. strGreen,
            agi_green = "+" .. agiGreen,
            int_green = "+" .. intGreen,
            attack_white = "+" .. attackWhite,
            attack_green = "+" .. attackGreen,
            attack_speed = "+" .. attackSpeed,
            defend = "+" .. defend
        }
    )
end
