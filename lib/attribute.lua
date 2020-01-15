-- 属性系统

local hattr = {
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
--- 为单位添加N个同样的攻击之书Private
hattr.setAttackWhitePrivate = function(u, itemId, qty)
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
--- 为单位添加N个同样的攻击之书
hattr.setAttackWhite = function(u, itemId, qty)
    if (u == nil or itemId == nil or qty <= 0) then
        return
    end
    hattr.setAttackWhitePrivate(u, itemId, qty)
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
    hattr.regAllAbility(whichUnit)
    --init
    local unitId = string.id2char(cj.GetUnitTypeId(whichUnit))
    if (hslk_global.unitsKV[unitId] == nil) then
        print_err("未注册 hslk_global.unitsKV:" .. cj.GetUnitName(whichUnit) .. unitId)
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
        attack_hunt_type = {}, --- sp
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
        knocking = 0.0,
        violence = 0.0,
        knocking_odds = 0.0,
        violence_odds = 0.0,
        punish = cj.GetUnitState(whichUnit, UNIT_STATE_MAX_LIFE) / 2,
        punish_current = cj.GetUnitState(whichUnit, UNIT_STATE_MAX_LIFE) / 2,
        meditative = 0.0,
        help = 0.0,
        hemophagia = 0.0,
        hemophagia_skill = 0.0,
        split = 0.0,
        split_range = 0.0,
        luck = 0.0,
        invincible = 0.0,
        weight = 0.0,
        weight_current = 0.0,
        hunt_amplitude = 0.0,
        hunt_rebound = 0.0,
        cure = 0.0,
        knocking_oppose = 0.0,
        violence_oppose = 0.0,
        hemophagia_oppose = 0.0,
        hemophagia_skill_oppose = 0.0,
        split_oppose = 0.0,
        punish_oppose = 0.0,
        hunt_rebound_oppose = 0.0,
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
        hRuntime.attribute[whichUnit].attack_hunt_type = {CONST_DAMAGE_TYPE.magic}
    else
        hRuntime.attribute[whichUnit].attack_hunt_type = {CONST_DAMAGE_TYPE.physical}
    end
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
hattr.setHandle = function(params, whichUnit, attr, opr, val, dur)
    local valType = type(val)
    if (valType == "string") then
        -- string类型只有+-=
        if (opr == "+") then
            -- 添加
            table.insert(params[attr], val)
            if (dur > 0) then
                htime.setTimeout(
                    dur,
                    function(t, td)
                        htime.delDialog(td)
                        htime.delTimer(t)
                        hattr.setHandle(params, whichUnit, attr, "-", val, 0)
                    end
                )
            end
        elseif (opr == "-") then
            -- 减少
            if (table.includes(val, params[attr])) then
                table.delete(val, params[attr], 1)
                if (dur > 0) then
                    htime.setTimeout(
                        dur,
                        function(t, td)
                            htime.delDialog(td)
                            htime.delTimer(t)
                            hattr.setHandle(params, whichUnit, attr, "+", val, 0)
                        end
                    )
                end
            end
        elseif (opr == "=") then
            -- 设定
            local old = table.clone(params[attr])
            params[attr] = val
            if (dur > 0) then
                htime.setTimeout(
                    dur,
                    function(t, td)
                        htime.delDialog(td)
                        htime.delTimer(t)
                        hattr.setHandle(params, whichUnit, attr, "=", old, 0)
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
                        hattr.setHandle(params, whichUnit, attr, "-", val, 0)
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
                            hattr.setHandle(params, whichUnit, attr, "+", val, 0)
                        end
                    )
                end
            end
        end
    elseif (valType == "number") then
        -- number
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
                        hattr.setHandle(params, whichUnit, attr, "-", diff, 0)
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
        print_err("data必须为table")
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
                hattr.setHandle(hRuntime.attribute[whichUnit], whichUnit, attr, opr, val, during)
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
                        hattr.setHandle(hRuntime.attribute[whichUnit], whichUnit, attr, "+", buff, during)
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
                        hattr.setHandle(hRuntime.attribute[whichUnit], whichUnit, attr, "-", buff, during)
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

--- 伤害一个单位
--[[
     * -options.effect 伤害特效
     * -options.damageKind伤害方式:
        attack 攻击
        skill 技能
        item 物品
        special 特殊（如眩晕、打断、分裂、爆炸、闪电链之类的）
     * -options.damageType伤害类型:
        physical 物理伤害则无视护甲<享受物理暴击加成，受护甲影响>
        magic 魔法<享受魔法暴击加成，受魔抗影响>
        real 真实<无视回避>
        absolute 绝对(无视回避、无视无敌)
        fire    火
        soil    土
        water   水
        ice     冰
        wind    风
        light   光
        dark    暗
        wood    木
        thunder 雷
        poison  毒
        ghost   鬼
        metal   金
        dragon  龙
        insect  虫
     * options.breakArmorType 无视的类型：{ 'defend', 'resistance', 'avoid' }
     * 沉默时，爆炸、闪电链、击飞会失效，其他不受影响
]]
hattr.huntUnit = function(options)
    local realDamage = 0
    local realDamagePercent = 0.0
    local realDamageString = ""
    local realDamageStringColor = "d9d9d9"
    local punishEffectRatio = 0
    local isAvoid = false
    local isKnocking = false
    local isViolence = false
    if (options.damage <= 0.125) then
        print_err("伤害太小被忽略")
        return
    end
    if (options.sourceUnit == nil) then
        print_err("伤害源不存在")
        return
    end
    if (options.targetUnit == nil) then
        print_err("目标不存在")
        return
    end
    if (his.alive(options.targetUnit) == false) then
        print_err("目标已死亡")
        return
    end
    -- 判断伤害方式
    if (options.damageKind == CONST_DAMAGE_KIND.attack) then
        if (his.unarm(options.sourceUnit) == true) then
            return
        end
        options.damageType = hattr.get(options.sourceUnit, "attack_hunt_type")
    elseif (options.damageKind == CONST_DAMAGE_KIND.skill) then
        if (his.silent(options.sourceUnit) == true) then
            return
        end
    elseif (options.damageKind == CONST_DAMAGE_KIND.item) then
    elseif (options.damageKind == CONST_DAMAGE_KIND.special) then
    else
        print_err("伤害单位错误：damageKind")
        return
    end
    -- 计算单位是否无敌且伤害类型不混合绝对伤害（无敌属性为百分比计算，被动触发抵挡一次）
    if (his.invincible(options.targetUnit) == true or math.random(1, 100) < hattr.get(options.targetUnit, "invincible")) then
        if (table.includes(CONST_DAMAGE_TYPE.absolute, options.damageType) == false) then
            return
        end
    end
    if (type(options.effect) == "string" and string.len(options.effect) > 0) then
        heffect.toXY(options.effect, cj.GetUnitX(options.targetUnit), cj.GetUnitY(options.targetUnit), 0)
    end
    -- 计算硬直抵抗
    punishEffectRatio = 0.99
    if (hattr.get(options.targetUnit, "punish_oppose") > 0) then
        punishEffectRatio = punishEffectRatio - hattr.get(options.targetUnit, "punish_oppose") * 0.01
        if (punishEffectRatio < 0.100) then
            punishEffectRatio = 0.100
        end
    end

    local targetUnitDefend = hattr.get(options.targetUnit, "defend")
    local targetUnitResistance = hattr.get(options.targetUnit, "resistance")
    local targetUnitAvoid = hattr.get(options.targetUnit, "avoid")
    local sourceUnitKnocking = hattr.get(options.sourceUnit, "knocking")
    local sourceUnitViolence = hattr.get(options.sourceUnit, "violence")
    local sourceUnitKnockingOdds = hattr.get(options.sourceUnit, "knocking_odds")
    local sourceUnitViolenceOdds = hattr.get(options.sourceUnit, "violence_odds")
    local sourceUnitAim = hattr.get(options.sourceUnit, "aim")
    local sourceUnitHuntAmplitude = hattr.get(options.sourceUnit, "hunt_amplitude")

    local targetUnitKnockingOppose = hattr.get(options.targetUnit, "knocking_oppose")
    local targetUnitViolenceOppose = hattr.get(options.targetUnit, "violence_oppose")

    -- *重要* hjass必须设定护甲因子为0，这里为了修正魔兽负护甲依然因子保持0.06的bug
    -- 当护甲x为负时，最大-20,公式2-(1-a)^abs(x)
    if (targetUnitDefend < 0 and targetUnitDefend >= -20) then
        options.damage = options.damage / (2 - cj.Pow(0.94, math.abs(targetUnitDefend)))
    elseif (targetUnitDefend < 0 and targetUnitDefend < -20) then
        options.damage = options.damage / (2 - cj.Pow(0.94, 20))
    end
    -- 计算攻击者的攻击里物理攻击和魔法攻击的占比
    local attackSum = hattr.get(options.sourceUnit, "attack_white") + hattr.get(options.sourceUnit, "attack_green")
    local sourceUnitHuntPercent = {physical = 0, magic = 0}
    if (attackSum > 0) then
        sourceUnitHuntPercent.physical = hattr.get(options.sourceUnit, "attack_white") / attackSum
        sourceUnitHuntPercent.magic = hattr.get(options.sourceUnit, "attack_green") / attackSum
    end
    -- 赋值伤害
    realDamage = options.damage
    -- 计算暴击值，判断伤害类型将暴击归0
    -- 判断无视装甲类型
    if (options.breakArmorType) then
        realDamageString = realDamageString .. "无视"
        if (table.includes("defend", options.breakArmorType)) then
            if (targetUnitDefend > 0) then
                targetUnitDefend = 0
            end
            realDamageString = realDamageString .. "护甲"
            realDamageStringColor = "f97373"
        end
        if (table.includes("resistance", options.breakArmorType)) then
            if (targetUnitResistance > 0) then
                targetUnitResistance = 0
            end
            realDamageString = realDamageString .. "魔抗"
            realDamageStringColor = "6fa8dc"
        end
        if (table.includes("avoid", options.breakArmorType)) then
            targetUnitAvoid = -100
            realDamageString = realDamageString .. "回避"
            realDamageStringColor = "76a5af"
        end
        -- @触发无视防御事件
        hevent.triggerEvent(
            options.sourceUnit,
            CONST_EVENT.breakArmor,
            {
                triggerUnit = options.sourceUnit,
                targetUnit = options.targetUnit,
                breakType = options.breakArmorType
            }
        )
        -- @触发被无视防御事件
        hevent.triggerEvent(
            options.targetUnit,
            CONST_EVENT.beBreakArmor,
            {
                triggerUnit = options.targetUnit,
                sourceUnit = options.sourceUnit,
                breakType = options.breakArmorType
            }
        )
    end
    -- 如果遇到真实伤害，无法回避
    if (table.includes(CONST_DAMAGE_TYPE.real, options.damageType) == true) then
        targetUnitAvoid = -99999
        realDamageString = realDamageString .. CONST_DAMAGE_TYPE_MAP.real.label
        realDamageStringColor = CONST_DAMAGE_TYPE_MAP.real.color
    end
    -- 如果遇到绝对伤害，无法回避，无视无敌
    if (table.includes(CONST_DAMAGE_TYPE.absolute, options.damageType) == true) then
        targetUnitAvoid = -99999
        realDamageString = realDamageString .. CONST_DAMAGE_TYPE_MAP.absolute.label
        realDamageStringColor = CONST_DAMAGE_TYPE_MAP.absolute.color
    end
    -- 计算物理暴击
    if (table.includes(CONST_DAMAGE_TYPE.physical, options.damageType) == true) then
        realDamageStringColor = CONST_DAMAGE_TYPE_MAP.physical.color
        if
            (sourceUnitKnockingOdds - targetUnitKnockingOppose) > 0 and
                math.random(1, 100) <= (sourceUnitKnockingOdds - targetUnitKnockingOppose)
         then
            realDamagePercent = realDamagePercent + sourceUnitHuntPercent.physical * sourceUnitKnocking * 0.01
            targetUnitAvoid = -100 -- 触发暴击，回避减100%
            isKnocking = true
        end
    end
    -- 计算魔法暴击
    if (table.includes(CONST_DAMAGE_TYPE.magic, options.damageType) == true) then
        realDamageStringColor = CONST_DAMAGE_TYPE_MAP.magic.color
        if
            (sourceUnitViolenceOdds - targetUnitViolenceOppose) > 0 and
                math.random(1, 100) <= (sourceUnitViolenceOdds - targetUnitViolenceOppose)
         then
            realDamagePercent = realDamagePercent + sourceUnitHuntPercent.magic * sourceUnitViolence * 0.01
            targetUnitAvoid = -100 -- 触发暴击，回避减100%
            isViolence = true
        end
    end
    -- 计算回避 X 命中
    if
        (options.damageKind == CONST_DAMAGE_KIND.attack and targetUnitAvoid - sourceUnitAim > 0 and
            math.random(1, 100) <= targetUnitAvoid - sourceUnitAim)
     then
        isAvoid = true
        realDamage = 0
        htextTag.style(htextTag.create2Unit(options.targetUnit, "回避", 6.00, "5ef78e", 10, 1.00, 10.00), "scale", 0, 0.2)
        -- @触发回避事件
        hevent.triggerEvent(
            options.targetUnit,
            CONST_EVENT.avoid,
            {
                triggerUnit = options.targetUnit,
                attacker = options.sourceUnit
            }
        )
        -- @触发被回避事件
        hevent.triggerEvent(
            options.sourceUnit,
            CONST_EVENT.beAvoid,
            {
                triggerUnit = options.sourceUnit,
                attacker = options.sourceUnit,
                targetUnit = options.targetUnit
            }
        )
    end
    -- 计算自然属性
    if (realDamage > 0) then
        -- 自然属性
        local sourceUnitNatural = {}
        for k, natural in pairs(CONST_DAMAGE_TYPE_NATURE) do
            sourceUnitNatural[natural] =
                hattr.get(options.sourceUnit, "natural_" .. natural) -
                hattr.get(options.targetUnit, "natural_" .. natural .. "_oppose") +
                10
            if (sourceUnitNatural[natural] < -100) then
                sourceUnitNatural[natural] = -100
            end
            if (table.includes(natural, options.damageType) and sourceUnitNatural[natural] ~= 0) then
                realDamagePercent = realDamagePercent + sourceUnitNatural[natural] * 0.01
                realDamageString = realDamageString .. CONST_DAMAGE_TYPE_MAP[natural].label
                realDamageStringColor = CONST_DAMAGE_TYPE_MAP[natural].color
            end
        end
    end
    -- 计算伤害增幅
    if (realDamage > 0 and sourceUnitHuntAmplitude ~= 0) then
        realDamagePercent = realDamagePercent + sourceUnitHuntAmplitude * 0.01
    end
    -- 计算混合了物理的杂乱伤害，护甲效果减弱
    if (table.includes(CONST_DAMAGE_TYPE.physical, options.damageType) and targetUnitDefend ~= 0) then
        targetUnitDefend = targetUnitDefend * sourceUnitHuntPercent.physical
        -- 计算护甲
        if (targetUnitDefend > 0) then
            realDamagePercent = realDamagePercent - targetUnitDefend / (targetUnitDefend + 200)
        else
            realDamagePercent = realDamagePercent + (-targetUnitDefend / (-targetUnitDefend + 100))
        end
    end
    -- 计算混合了魔法的杂乱伤害，魔抗效果减弱
    if (table.includes(CONST_DAMAGE_TYPE.magic, options.damageType) and targetUnitResistance ~= 0) then
        targetUnitResistance = targetUnitResistance * sourceUnitHuntPercent.magic
        -- 计算魔抗
        if (targetUnitResistance ~= 0) then
            if (targetUnitResistance >= 100) then
                realDamagePercent = realDamagePercent * sourceUnitHuntPercent.physical
            else
                realDamagePercent = realDamagePercent - targetUnitResistance * 0.01
            end
        end
    end

    -- 合计 realDamagePercent
    realDamage = realDamage * (1 + realDamagePercent)

    -- 计算韧性
    local targetUnitToughness = hattr.get(options.targetUnit, "toughness")
    if (targetUnitToughness > 0) then
        if ((realDamage - targetUnitToughness) < realDamage * 0.1) then
            realDamage = realDamage * 0.1
            --@触发极限韧性抵抗事件
            hevent.triggerEvent(
                options.targetUnit,
                CONST_EVENT.limitToughness,
                {
                    triggerUnit = options.targetUnit,
                    sourceUnit = options.sourceUnit
                }
            )
        else
            realDamage = realDamage - targetUnitToughness
        end
    end
    -- 上面都是先行计算 ------------------

    -- 造成伤害
    if (realDamage > 0.25) then
        if (isKnocking) then
            --@触发物理暴击事件
            hevent.triggerEvent(
                options.sourceUnit,
                CONST_EVENT.knocking,
                {
                    triggerUnit = options.sourceUnit,
                    targetUnit = options.targetUnit,
                    damage = realDamage,
                    value = sourceUnitKnocking,
                    percent = sourceUnitKnockingOdds
                }
            )
            --@触发被物理暴击事件
            hevent.triggerEvent(
                options.targetUnit,
                CONST_EVENT.beKnocking,
                {
                    triggerUnit = options.targetUnit,
                    sourceUnit = options.sourceUnit,
                    damage = realDamage,
                    value = sourceUnitKnocking,
                    percent = sourceUnitKnockingOdds
                }
            )
            heffect.targetUnit("war3mapImported\\eff_crit.mdl", options.targetUnit, 0)
        end
        if (isViolence) then
            --@触发魔法暴击事件
            hevent.triggerEvent(
                options.sourceUnit,
                CONST_EVENT.violence,
                {
                    triggerUnit = options.sourceUnit,
                    targetUnit = options.targetUnit,
                    damage = realDamage,
                    value = sourceUnitViolence,
                    percent = sourceUnitViolenceOdds
                }
            )
            --@触发被魔法暴击事件
            hevent.triggerEvent(
                options.targetUnit,
                CONST_EVENT.beViolence,
                {
                    triggerUnit = options.targetUnit,
                    sourceUnit = options.sourceUnit,
                    damage = realDamage,
                    value = sourceUnitViolence,
                    percent = sourceUnitViolenceOdds
                }
            )
            heffect.targetUnit("war3mapImported\\eff_demon_explosion.mdl", options.targetUnit, 0)
        end
        -- 暴击文本加持
        if (isKnocking and isViolence) then
            realDamageString = realDamageString .. "双暴"
            realDamageStringColor = "b054ee"
        elseif (isKnocking) then
            realDamageString = realDamageString .. "物暴"
            realDamageStringColor = "ef3215"
        elseif (isViolence) then
            realDamageString = realDamageString .. "魔爆"
            realDamageStringColor = "15bcef"
        end
        -- 造成伤害
        hskill.damage(
            {
                sourceUnit = options.sourceUnit,
                targetUnit = options.targetUnit,
                damage = realDamage,
                damageString = realDamageString,
                damageStringColor = realDamageStringColor,
                damageKind = options.damageKind,
                damageType = options.damageType,
                effect = options.effect
            }
        )
        -- 分裂
        local split = hattr.get(options.sourceUnit, "split") - hattr.get(options.targetUnit, "split_oppose")
        local split_range = hattr.get(options.sourceUnit, "split_range")
        if (options.damageKind == CONST_DAMAGE_KIND.attack and split > 0) then
            local g =
                hgroup.createByUnit(
                options.targetUnit,
                split_range,
                function()
                    local flag = true
                    if (his.death(cj.GetFilterUnit())) then
                        flag = false
                    end
                    if (his.ally(cj.GetFilterUnit(), options.sourceUnit)) then
                        flag = false
                    end
                    if (his.building(cj.GetFilterUnit())) then
                        flag = false
                    end
                    return flag
                end
            )
            heffect.targetUnit("Abilities\\Spells\\Human\\Feedback\\SpellBreakerAttack.mdl", options.targetUnit, 0)
            cj.ForGroup(
                g,
                function()
                    local u = cj.GetEnumUnit()
                    if (u ~= options.targetUnit) then
                        -- 造成伤害
                        hskill.damage(
                            {
                                sourceUnit = options.sourceUnit,
                                targetUnit = u,
                                damage = realDamage * split * 0.01,
                                damageString = "分裂",
                                damageStringColor = "e25746",
                                damageKind = CONST_DAMAGE_KIND.special,
                                damageType = {CONST_DAMAGE_TYPE.real},
                                effect = "Abilities\\Spells\\Other\\Cleave\\CleaveDamageTarget.mdl"
                            }
                        )
                    end
                end
            )
            cj.GroupClear(g)
            cj.DestroyGroup(g)
            -- @触发分裂事件
            hevent.triggerEvent(
                options.sourceUnit,
                CONST_EVENT.split,
                {
                    triggerUnit = options.sourceUnit,
                    targetUnit = options.targetUnit,
                    damage = realDamage * split * 0.01,
                    range = split_range,
                    percent = split
                }
            )
            -- @触发被分裂事件
            hevent.triggerEvent(
                options.targetUnit,
                CONST_EVENT.beSpilt,
                {
                    triggerUnit = options.targetUnit,
                    sourceUnit = options.sourceUnit,
                    damage = realDamage * split * 0.01,
                    range = split_range,
                    percent = split
                }
            )
        end
        -- 吸血
        local hemophagia =
            hattr.get(options.targetUnit, "hemophagia") - hattr.get(options.targetUnit, "hemophagia_oppose")
        if (options.damageKind == CONST_DAMAGE_KIND.attack and hemophagia > 0) then
            hunit.addLife(options.sourceUnit, realDamage * hemophagia * 0.01)
            heffect.targetUnit(
                "Abilities\\Spells\\Undead\\VampiricAura\\VampiricAuraTarget.mdl",
                options.sourceUnit,
                "origin",
                1.00
            )
            -- @触发吸血事件
            hevent.triggerEvent(
                options.sourceUnit,
                CONST_EVENT.hemophagia,
                {
                    triggerUnit = options.sourceUnit,
                    targetUnit = options.targetUnit,
                    damage = realDamage * hemophagia * 0.01,
                    percent = hemophagia
                }
            )
            -- @触发被吸血事件
            hevent.triggerEvent(
                options.targetUnit,
                CONST_EVENT.beHemophagia,
                {
                    triggerUnit = options.targetUnit,
                    sourceUnit = options.sourceUnit,
                    damage = realDamage * hemophagia * 0.01,
                    percent = hemophagia
                }
            )
        end
        -- 技能吸血
        local hemophagia_skill =
            hattr.get(options.targetUnit, "hemophagia_skill") - hattr.get(options.targetUnit, "hemophagia_skill_oppose")
        if (options.damageKind == CONST_DAMAGE_KIND.skill and hemophagia_skill > 0) then
            hunit.addLife(options.sourceUnit, realDamage * hemophagia_skill * 0.01)
            heffect.targetUnit(
                "Abilities\\Spells\\Items\\HealingSalve\\HealingSalveTarget.mdl",
                options.sourceUnit,
                "origin",
                1.80
            )
            -- @触发技能吸血事件
            hevent.triggerEvent(
                options.sourceUnit,
                CONST_EVENT.skillHemophagia,
                {
                    triggerUnit = options.sourceUnit,
                    targetUnit = options.targetUnit,
                    damage = realDamage * hemophagia_skill * 0.01,
                    percent = hemophagia_skill
                }
            )
            -- @触发被技能吸血事件
            hevent.triggerEvent(
                options.targetUnit,
                CONST_EVENT.beSkillHemophagia,
                {
                    triggerUnit = options.targetUnit,
                    sourceUnit = options.sourceUnit,
                    damage = realDamage * hemophagia_skill * 0.01,
                    percent = hemophagia_skill
                }
            )
        end
        -- 硬直
        local punish_during = 5.00
        if
            (realDamage > 3 and his.alive(options.targetUnit) and his.punish(options.targetUnit) == false and
                hunit.isOpenPunish(options.targetUnit))
         then
            hattr.set(
                options.targetUnit,
                0,
                {
                    punish_current = "-" .. realDamage
                }
            )
            if (hattr.get(options.targetUnit, "punish_current") <= 0) then
                his.set(options.targetUnit, "isPunishing", true)
                htime.setTimeout(
                    punish_during + 1.00,
                    function(t, td)
                        htime.delDialog(td)
                        htime.delTimer(t)
                        his.set(options.targetUnit, "isPunishing", false)
                    end
                )
            end
            local punishEffectAttackSpeed = (100 + hattr.get(options.targetUnit, "attack_speed")) * punishEffectRatio
            local punishEffectMove = hattr.get(options.targetUnit, "move") * punishEffectRatio
            if (punishEffectAttackSpeed < 1) then
                punishEffectAttackSpeed = 1.00
            end
            if (punishEffectMove < 1) then
                punishEffectMove = 1.00
            end
            hattr.set(
                options.targetUnit,
                punish_during,
                {
                    attack_speed = "-" .. punishEffectAttackSpeed,
                    move = "-" .. punishEffectMove
                }
            )
            htextTag.style(
                htextTag.create2Unit(options.targetUnit, "僵硬", 6.00, "c0c0c0", 0, punish_during, 50.00),
                "scale",
                0,
                0
            )
            -- @触发硬直事件
            hevent.triggerEvent(
                options.targetUnit,
                CONST_EVENT.heavy,
                {
                    triggerUnit = options.targetUnit,
                    sourceUnit = options.sourceUnit,
                    percent = punishEffectRatio * 100,
                    during = punish_during
                }
            )
        end
        -- 反射
        local targetUnitHuntRebound =
            hattr.get(options.targetUnit, "hunt_rebound") - hattr.get(options.sourceUnit, "hunt_rebound_oppose")
        if (targetUnitHuntRebound > 0) then
            hunit.subCurLife(options.sourceUnit, realDamage * targetUnitHuntRebound * 0.01)
            htextTag.style(
                htextTag.create2Unit(
                    options.sourceUnit,
                    "反伤" .. (realDamage * targetUnitHuntRebound * 0.01),
                    10.00,
                    "f8aaeb",
                    10,
                    1.00,
                    10.00
                ),
                "shrink",
                -0.05,
                0
            )
            -- @触发反伤事件
            hevent.triggerEvent(
                options.targetUnit,
                CONST_EVENT.rebound,
                {
                    triggerUnit = options.targetUnit,
                    sourceUnit = options.sourceUnit,
                    damage = realDamage * targetUnitHuntRebound * 0.01
                }
            )
        end
        -- 特殊效果,需要非无敌并处于效果启动状态下
        -- buff/debuff
        local buff
        local debuff
        if (options.damageKind == CONST_DAMAGE_KIND.attack) then
            buff = hattr.get(options.sourceUnit, "attack_buff")
            debuff = hattr.get(options.sourceUnit, "attack_debuff")
        elseif (options.damageKind == CONST_DAMAGE_KIND.skill) then
            buff = hattr.get(options.sourceUnit, "skill_buff")
            debuff = hattr.get(options.sourceUnit, "skill_debuff")
        end
        if (buff ~= nil) then
            for _, etc in pairs(buff) do
                local b = etc.table
                if (b.val ~= 0 and b.during > 0 and math.random(1, 1000) <= b.odds * 10) then
                    hattr.set(options.sourceUnit, b.during, {[b.attr] = "+" .. b.val})
                    if (type(b.effect) == "string" and string.len(b.effect) > 0) then
                        heffect.bindUnit(b.effect, options.sourceUnit, "origin", b.during)
                    end
                end
            end
        end
        if (debuff ~= nil) then
            for _, etc in pairs(debuff) do
                local b = etc.table
                if (b.val ~= 0 and b.during > 0 and math.random(1, 1000) <= b.odds * 10) then
                    hattr.set(options.targetUnit, b.during, {[b.attr] = "-" .. b.val})
                    if (type(b.effect) == "string" and string.len(b.effect) > 0) then
                        heffect.bindUnit(b.effect, options.targetUnit, "origin", b.during)
                    end
                end
            end
        end
        -- effect
        local effect
        if (options.damageKind == CONST_DAMAGE_KIND.attack) then
            effect = hattr.get(options.sourceUnit, "attack_effect")
        elseif (options.damageKind == CONST_DAMAGE_KIND.skill) then
            effect = hattr.get(options.sourceUnit, "skill_effect")
        end
        if (effect ~= nil) then
            for _, etc in pairs(effect) do
                local b = etc.table
                b.val = b.val or 0
                b.odds = b.odds or 0
                if (b.odds > 0) then
                    if (b.attr == "broken") then
                        --打断
                        hskill.broken(
                            {
                                whichUnit = options.targetUnit,
                                odds = b.odds,
                                damage = b.val,
                                sourceUnit = options.sourceUnit,
                                effect = b.effect,
                                damageKind = CONST_DAMAGE_KIND.special,
                                damageType = {CONST_DAMAGE_TYPE.real}
                            }
                        )
                    elseif (b.attr == "swim") then
                        --眩晕
                        hskill.swim(
                            {
                                whichUnit = options.targetUnit,
                                odds = b.odds,
                                damage = b.val,
                                during = b.during,
                                sourceUnit = options.sourceUnit,
                                effect = b.effect,
                                damageKind = CONST_DAMAGE_KIND.special,
                                damageType = {CONST_DAMAGE_TYPE.real}
                            }
                        )
                    elseif (b.attr == "silent") then
                        --沉默
                        hskill.silent(
                            {
                                whichUnit = options.targetUnit,
                                odds = b.odds,
                                damage = b.val,
                                during = b.during,
                                sourceUnit = options.sourceUnit,
                                effect = b.effect,
                                damageKind = CONST_DAMAGE_KIND.special,
                                damageType = {CONST_DAMAGE_TYPE.real}
                            }
                        )
                    elseif (b.attr == "unarm") then
                        --缴械
                        hskill.unarm(
                            {
                                whichUnit = options.targetUnit,
                                odds = b.odds,
                                damage = b.val,
                                during = b.during,
                                sourceUnit = options.sourceUnit,
                                effect = b.effect,
                                damageKind = CONST_DAMAGE_KIND.special,
                                damageType = {CONST_DAMAGE_TYPE.real}
                            }
                        )
                    elseif (b.attr == "fetter") then
                        --缚足
                        hskill.fetter(
                            {
                                whichUnit = options.targetUnit,
                                odds = b.odds,
                                damage = b.val,
                                during = b.during,
                                sourceUnit = options.sourceUnit,
                                effect = b.effect,
                                damageKind = CONST_DAMAGE_KIND.special,
                                damageType = {CONST_DAMAGE_TYPE.real}
                            }
                        )
                    elseif (b.attr == "bomb") then
                        --爆破
                        hskill.bomb(
                            {
                                odds = b.odds,
                                damage = b.val,
                                range = b.range,
                                whichUnit = options.targetUnit,
                                sourceUnit = options.sourceUnit,
                                effect = b.effect,
                                effectSingle = b.effectSingle,
                                damageKind = CONST_DAMAGE_KIND.special,
                                damageType = {CONST_DAMAGE_TYPE.real}
                            }
                        )
                    elseif (b.attr == "lightning_chain") then
                        --闪电链
                        hskill.lightningChain(
                            {
                                odds = b.odds,
                                damage = b.val,
                                lightningType = b.lightning_type,
                                qty = b.qty,
                                change = b.change,
                                range = b.range or 500,
                                effect = b.effect,
                                isRepeat = false,
                                whichUnit = options.targetUnit,
                                prevUnit = options.sourceUnit,
                                sourceUnit = options.sourceUnit,
                                damageKind = CONST_DAMAGE_KIND.special,
                                damageType = {CONST_DAMAGE_TYPE.thunder}
                            }
                        )
                    elseif (b.attr == "crack_fly") then
                        --击飞
                        hskill.crackFly(
                            {
                                odds = b.odds,
                                damage = b.val,
                                whichUnit = options.targetUnit,
                                sourceUnit = options.sourceUnit,
                                distance = b.distance,
                                high = b.high,
                                during = b.during,
                                effect = b.effect,
                                damageKind = CONST_DAMAGE_KIND.special,
                                damageType = {CONST_DAMAGE_TYPE.thunder}
                            }
                        )
                    end
                end
            end
        end
    end
end

return hattr
