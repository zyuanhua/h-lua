local hskill = {
    SKILL_TOKEN = hslk_global.unit_token,
    SKILL_BREAK = hslk_global.skill_break,
    SKILL_SWIM = hslk_global.skill_swim_unlimit,
    SKILL_AVOID_PLUS = hslk_global.attr.avoid.add,
    SKILL_AVOID_MIUNS = hslk_global.attr.avoid.sub,
    BUFF_SWIM = hSys.getObjId("BPSE")
}

hskill.set = function(handle, key, val)
    if (handle == nil or key == nil) then
        return
    end
    if (hRuntime.skill[handle] == nil) then
        hRuntime.skill[handle] = {}
    end
    hRuntime.skill[handle][key] = val
end

hskill.get = function(handle, key, defaultVal)
    if (handle == nil or key == nil) then
        return defaultVal or nil
    end
    if (hRuntime.skill[handle] == nil) then
        return defaultVal or nil
    end
    return hRuntime.skill[handle][key]
end

-- 添加技能
hskill.add = function(whichUnit, ability_id, during)
    local id = hSys.getObjId(ability_id)
    if (during == nil or during <= 0) then
        cj.UnitAddAbility(whichUnit, id)
        cj.UnitMakeAbilityPermanent(whichUnit, true, id)
    else
        cj.UnitAddAbility(whichUnit, id)
        htime.setTimeout(
            during,
            function(t, td)
                cj.UnitRemoveAbility(whichUnit, id)
            end
        )
    end
end

-- 删除技能
hskill.del = function(whichUnit, ability_id, during)
    local id = hSys.getObjId(ability_id)
    if (during == nil or during <= 0) then
        cj.UnitRemoveAbility(whichUnit, id)
    else
        cj.UnitRemoveAbility(whichUnit, id)
        htime.setTimeout(
            during,
            function(t, td)
                cj.UnitAddAbility(whichUnit, id)
            end
        )
    end
end

-- 设置技能的永久使用性
hskill.forever = function(whichUnit, ability_id)
    local id = hSys.getObjId(ability_id)
    cj.UnitMakeAbilityPermanent(whichUnit, true, id)
end

-- 是否拥有技能
hskill.has = function(whichUnit, ability_id)
    if (whichUnit == nil or ability_id == nil) then
        return false
    end
    local id = hSys.getObjId(ability_id)
    if (cj.GetUnitAbilityLevel(whichUnit, id) >= 1) then
        return true
    end
    return false
end

--回避
hskill.avoid = function(whichUnit)
    cj.UnitAddAbility(whichUnit, hskill.SKILL_AVOID_PLUS)
    cj.SetUnitAbilityLevel(whichUnit, hskill.SKILL_AVOID_PLUS, 2)
    cj.UnitRemoveAbility(whichUnit, hskill.SKILL_AVOID_PLUS)
    htime.setTimeout(
        0.00,
        function(t, td)
            htime.delDialog(td)
            htime.delTimer(t)
            cj.UnitAddAbility(whichUnit, hskill.SKILL_AVOID_MIUNS)
            cj.SetUnitAbilityLevel(whichUnit, hskill.SKILL_AVOID_MIUNS, 2)
            cj.UnitRemoveAbility(whichUnit, hskill.SKILL_AVOID_MIUNS)
        end
    )
end

--无敌
hskill.invulnerable = function(whichUnit, during)
    if (whichUnit == nil) then
        return
    end
    if (during < 0) then
        during = 0.00 -- 如果设置持续时间错误，则0秒无敌，跟回避效果相同
    end
    cj.SetUnitInvulnerable(whichUnit, true)
    htime.setTimeout(
        during,
        function(t, td)
            htime.delDialog(td)
            htime.delTimer(t)
            cj.SetUnitInvulnerable(whichUnit, false)
        end
    )
end
--群体无敌
hskill.invulnerableGroup = function(whichGroup, during)
    if (whichGroup == nil) then
        return
    end
    if (during < 0) then
        during = 0.00 -- 如果设置持续时间错误，则0秒无敌，跟回避效果相同
    end
    cj.ForGroup(
        whichGroup,
        function()
            cj.SetUnitInvulnerable(cj.GetEnumUnit(), true)
        end
    )
    htime.setTimeout(
        during,
        function(t, td)
            htime.delDialog(td)
            htime.delTimer(t)
            cj.ForGroup(
                whichGroup,
                function()
                    cj.SetUnitInvulnerable(cj.GetEnumUnit(), false)
                end
            )
        end
    )
end
--暂停效果
hskill.pause = function(whichUnit, during, pauseColor)
    if (whichUnit == nil) then
        return
    end
    if (during < 0) then
        during = 0.01 -- 假如没有设置时间，默认打断效果
    end
    local prevTimer = hskill.get(whichUnit, "pauseTimer")
    local prevTimeRemaining = 0
    if (prevTimer ~= nil) then
        prevTimeRemaining = cj.TimerGetRemaining(prevTimer)
        if (prevTimeRemaining > 0) then
            htime.delTimer(prevTimer)
            hskill.set(whichUnit, "pauseTimer", nil)
        else
            prevTimeRemaining = 0
        end
    end
    if (pauseColor == "black") then
        bj.SetUnitVertexColorBJ(whichUnit, 30, 30, 30, 0)
    elseif (pauseColor == "blue") then
        bj.SetUnitVertexColorBJ(whichUnit, 30, 30, 200, 0)
    elseif (pauseColor == "red") then
        bj.SetUnitVertexColorBJ(whichUnit, 200, 30, 30, 0)
    elseif (pauseColor == "green") then
        bj.SetUnitVertexColorBJ(whichUnit, 30, 200, 30, 0)
    end
    cj.SetUnitTimeScalePercent(whichUnit, 0.00)
    cj.PauseUnit(whichUnit, true)
    hskill.set(
        whichUnit,
        "pauseTimer",
        htime.setTimeout(
            during + prevTimeRemaining,
            function(t, td)
                htime.delDialog(td)
                htime.delTimer(t)
                cj.PauseUnit(whichUnit, false)
                if (string.len(pauseColor) ~= nil) then
                    cj.SetUnitVertexColorBJ(whichUnit, 100, 100, 100, 0)
                end
                cj.SetUnitTimeScalePercent(whichUnit, 100.00)
            end
        )
    )
end

--为单位添加效果只限技能类(一般使用物品技能<攻击之爪>模拟)一段时间
hskill.modelEffect = function(whichUnit, whichAbility, abilityLevel, during)
    if (whichUnit ~= nil and whichAbility ~= nil and during > 0.03) then
        cj.UnitAddAbility(whichUnit, whichAbility)
        cj.UnitMakeAbilityPermanent(whichUnit, true, whichAbility)
        if (abilityLevel > 0) then
            cj.SetUnitAbilityLevel(whichUnit, whichAbility, abilityLevel)
        end
        htime.setTimeout(
            during,
            function(t, td)
                htime.delDialog(td)
                htime.delTimer(t)
                cj.UnitRemoveAbility(whichUnit, whichAbility)
            end
        )
    end
end

--- 造成伤害
--[[
    bean = {
        fromUnit = nil, --伤害来源
        toUnit = nil, --目标单位
        damage = 0, --初始伤害
        realDamage = 0, --实际伤害
        realDamageStringColor = "", --伤害漂浮字颜色
        huntKind = "attack", --伤害种类请查看 CONST_HUNT_KIND
        huntType = { "magic", "thunder" }, --伤害类型请查看 CONST_HUNT_TYPE
        huntEff = "", --伤害特效
    }
]]
hskill.damage = function(bean)
    -- 文本显示
    bean.realDamageString = bean.realDamageString or ""
    bean.realDamageStringColor = bean.realDamageStringColor or nil
    htextTag.style(
        htextTag.create2Unit(
            bean.toUnit,
            bean.realDamageString .. math.floor(bean.realDamage),
            6.00,
            bean.realDamageStringColor,
            1,
            1.1,
            11.00
        ),
        "toggle",
        -0.05,
        0
    )
    hevent.setLastDamageUnit(bean.toUnit, bean.fromUnit)
    hplayer.addDamage(cj.GetOwningPlayer(bean.fromUnit), bean.realDamage)
    hplayer.addBeDamage(cj.GetOwningPlayer(bean.toUnit), bean.realDamage)
    hunit.subCurLife(bean.toUnit, bean.realDamage)
    if (type(bean.huntEff) == "string" and string.len(bean.huntEff) > 0) then
        heffect.toXY(bean.huntEff, cj.GetUnitX(bean.toUnit), cj.GetUnitY(bean.toUnit), 0)
    end
    -- @触发伤害事件
    hevent.triggerEvent(
        {
            triggerKey = heventKeyMap.damage,
            triggerUnit = bean.fromUnit,
            targetUnit = bean.toUnit,
            sourceUnit = bean.fromUnit,
            damage = bean.damage,
            realDamage = bean.realDamage,
            damageKind = bean.huntKind,
            damageType = bean.huntType
        }
    )
    -- @触发被伤害事件
    hevent.triggerEvent(
        {
            triggerKey = heventKeyMap.beDamage,
            triggerUnit = bean.toUnit,
            sourceUnit = bean.fromUnit,
            damage = bean.damage,
            realDamage = bean.realDamage,
            damageKind = bean.huntKind,
            damageType = bean.huntType
        }
    )
    if (bean.huntKind == CONST_HUNT_KIND.attack) then
        -- @触发攻击事件
        hevent.triggerEvent(
            {
                triggerKey = heventKeyMap.attack,
                triggerUnit = bean.fromUnit,
                attacker = bean.fromUnit,
                targetUnit = bean.toUnit,
                damage = bean.damage,
                realDamage = bean.realDamage,
                damageKind = bean.huntKind,
                damageType = bean.huntType
            }
        )
        -- @触发被攻击事件
        hevent.triggerEvent(
            {
                triggerKey = heventKeyMap.beAttack,
                triggerUnit = bean.fromUnit,
                attacker = bean.fromUnit,
                targetUnit = bean.toUnit,
                damage = bean.damage,
                realDamage = bean.realDamage,
                damageKind = bean.huntKind,
                damageType = bean.huntType
            }
        )
    end
end

--[[
    打断 ! 注意这个方法对中立被动无效
    bean = {
        whichUnit = unit, --目标单位，必须
        odds = 100, --几率，可选
        damage = 0, --伤害，可选
        sourceUnit = nil, --来源单位，可选
        huntKind = CONST_HUNT_KIND.skill --伤害的种类（可选）
        huntType = {CONST_HUNT_TYPE.real} --伤害的类型,注意是table（可选）
    }
]]
hskill.broken = function(bean)
    if (bean.whichUnit == nil) then
        return
    end
    if (bean.damage ~= nil and bean.sourceUnit == nil) then
        return
    end
    local u = bean.whichUnit
    local odds = bean.odds or 100
    local damage = bean.damage or 0
    local sourceUnit = bean.sourceUnit or nil
    local huntKind = bean.huntKind or CONST_HUNT_KIND.skill
    local huntType = bean.sourceUnit or { CONST_HUNT_TYPE.real }
    --计算抵抗
    local oppose = hattr.get(u, "broken_oppose")
    odds = odds - oppose --(%)
    if (odds <= 0) then
        return
    else
        if (math.random(1, 1000) > odds * 10) then
            return
        end
        damage = damage * (1 - oppose * 0.01)
    end
    local cu = hunit.create(
        {
            id = hskill.SKILL_TOKEN,
            whichPlayer = hplayer.player_passive,
            x = cj.GetUnitX(u),
            y = cj.GetUnitY(u)
        }
    )
    cj.UnitAddAbility(cu, hskill.SKILL_BREAK)
    cj.SetUnitAbilityLevel(cu, hskill.SKILL_BREAK, 1)
    cj.IssueTargetOrder(cu, "thunderbolt", u)
    hunit.del(cu, 0.3)
    if (damage > 0) then
        hskill.damage(
            {
                fromUnit = sourceUnit,
                toUnit = u,
                damage = damage,
                realDamage = damage,
                realDamageString = "打断",
                huntKind = huntKind,
                huntType = huntType
            }
        )
    end
    if (sourceUnit ~= nil) then
        -- @触发打断事件
        hevent.triggerEvent(
            {
                triggerKey = heventKeyMap.broken,
                triggerUnit = sourceUnit,
                targetUnit = u,
                damage = damage
            }
        )
    end
    -- @触发被打断事件
    hevent.triggerEvent(
        {
            triggerKey = heventKeyMap.beBroken,
            triggerUnit = u,
            sourceUnit = sourceUnit,
            damage = damage
        }
    )
end

--[[
    眩晕! 注意这个方法对中立被动无效
    bean = {
        whichUnit = unit, --目标单位，必须
        during = 0, --持续时间，必须
        odds = 100, --几率，可选
        damage = 0, --伤害，可选
        sourceUnit = nil, --来源单位，可选
        huntKind = CONST_HUNT_KIND.skill --伤害的种类（可选）
        huntType = {CONST_HUNT_TYPE.real} --伤害的类型,注意是table（可选）
    }
]]
hskill.swim = function(bean)
    if (bean.whichUnit == nil or bean.during == nil or bean.during <= 0) then
        return
    end
    if (bean.damage ~= nil and bean.sourceUnit == nil) then
        return
    end
    local u = bean.whichUnit
    local during = bean.during
    local odds = bean.odds or 100
    local damage = bean.damage or 0
    local sourceUnit = bean.sourceUnit or nil
    local huntKind = bean.huntKind or CONST_HUNT_KIND.skill
    local huntType = bean.sourceUnit or { CONST_HUNT_TYPE.real }
    --计算抵抗
    local oppose = hattr.get(u, "swim_oppose")
    odds = odds - oppose --(%)
    if (odds <= 0) then
        return
    else
        if (math.random(1, 1000) > odds * 10) then
            return
        end
        during = during * (1 - oppose * 0.01)
        damage = damage * (1 - oppose * 0.01)
    end
    local swimTimer = hskill.get(u, "swimTimer")
    if (swimTimer ~= nil and cj.TimerGetRemaining(t) > 0) then
        if (during <= cj.TimerGetRemaining(swimTimer)) then
            return
        else
            htime.delTimer(swimTimer)
            hskill.set(u, "swimTimer", nil)
            cj.UnitRemoveAbility(u, hskill.BUFF_SWIM)
            htextTag.style(htextTag.create2Unit(u, "劲眩", 6.00, "64e3f2", 10, 1.00, 10.00), "scale", 0, 0.05)
        end
    end
    local cu = hunit.create(
        {
            id = hskill.SKILL_TOKEN,
            whichPlayer = hplayer.player_passive,
            x = cj.GetUnitX(u),
            y = cj.GetUnitY(u)
        }
    )
    cj.UnitAddAbility(cu, hskill.SKILL_SWIM)
    cj.SetUnitAbilityLevel(cu, hskill.SKILL_SWIM, 1)
    cj.IssueTargetOrder(cu, "thunderbolt", u)
    hunit.del(cu, 0.4)
    his.set(cu, "isSwim", true)
    if (damage > 0) then
        hskill.damage(
            {
                fromUnit = sourceUnit,
                toUnit = u,
                damage = damage,
                realDamage = damage,
                realDamageString = "眩晕",
                huntKind = CONST_HUNT_KIND.skill,
                huntType = { CONST_HUNT_TYPE.real }
            }
        )
    end
    if (sourceUnit ~= nil) then
        -- @触发眩晕事件
        hevent.triggerEvent(
            {
                triggerKey = heventKeyMap.swim,
                triggerUnit = sourceUnit,
                targetUnit = u,
                damage = damage,
                during = during
            }
        )
    end
    -- @触发被眩晕事件
    hevent.triggerEvent(
        {
            triggerKey = heventKeyMap.beSwim,
            triggerUnit = u,
            sourceUnit = sourceUnit,
            damage = damage,
            during = during
        }
    )
    hskill.set(
        u,
        "swimTimer",
        htime.setTimeout(
            during,
            function(t, td)
                htime.delDialog(td)
                htime.delTimer(t)
                cj.UnitRemoveAbility(u, hskill.BUFF_SWIM)
                his.set(cu, "isSwim", false)
            end
        )
    )
end

--[[
    沉默! 注意这个方法对中立被动无效
    bean = {
        whichUnit = unit, --目标单位，必须
        during = 0, --持续时间，必须
        odds = 100, --几率，可选
        damage = 0, --伤害，可选
        sourceUnit = nil, --来源单位，可选
        huntKind = CONST_HUNT_KIND.skill --伤害的种类（可选）
        huntType = {CONST_HUNT_TYPE.real} --伤害的类型,注意是table（可选）
    }
]]
hskill.silent = function(bean)
    if (bean.whichUnit == nil or bean.during == nil or bean.during <= 0) then
        return
    end
    if (bean.damage ~= nil and bean.sourceUnit == nil) then
        return
    end
    local u = bean.whichUnit
    local during = bean.during
    local odds = bean.odds or 100
    local damage = bean.damage or 0
    local sourceUnit = bean.sourceUnit or nil
    local huntKind = bean.huntKind or CONST_HUNT_KIND.skill
    local huntType = bean.sourceUnit or { CONST_HUNT_TYPE.real }
    --计算抵抗
    local oppose = hattr.get(u, "silent_oppose")
    odds = odds - oppose --(%)
    if (odds <= 0) then
        return
    else
        if (math.random(1, 1000) > odds * 10) then
            return
        end
        during = during * (1 - oppose * 0.01)
        damage = damage * (1 - oppose * 0.01)
    end
    if (hRuntime.skill.silentUnits == nil) then
        hRuntime.skill.silentUnits = {}
    end
    if (hRuntime.skill.silentTrigger == nil) then
        hRuntime.skill.silentTrigger = cj.CreateTrigger()
        bj.TriggerRegisterAnyUnitEventBJ(hRuntime.skill.silentTrigger, EVENT_PLAYER_UNIT_SPELL_CHANNEL)
        cj.TriggerAddAction(
            hRuntime.skill.silentTrigger,
            function()
                local u1 = cj.GetTriggerUnit()
                if (hSys.inArray(u1, hRuntime.skill.silentUnits)) then
                    cj.IssueImmediateOrder(u1, "stop")
                end
            end
        )
    end
    local level = hskill.get(u, "silentLevel", 0) + 1
    if (level <= 1) then
        htextTag.style(htextTag.ttg2Unit(u, "沉默", 6.00, "ee82ee", 10, 1.00, 10.00), "scale", 0, 0.2)
    else
        htextTag.style(
            htextTag.ttg2Unit(u, math.floor(level) .. "重沉默", 6.00, "ee82ee", 10, 1.00, 10.00),
            "scale",
            0,
            0.2
        )
    end
    hskill.set(u, "silentLevel", level)
    if (hSys.inArray(u, hRuntime.skill.silentUnits) == false) then
        table.insert(hRuntime.skill.silentUnits, u)
        local eff = heffect.bindUnit("Abilities\\Spells\\Other\\Silence\\SilenceTarget.mdl", u, "head", -1)
        hskill.set(u, "silentEffect", eff)
    end
    his.set(u, "isSilent", true)
    if (damage > 0) then
        hskill.damage(
            {
                fromUnit = sourceUnit,
                toUnit = u,
                damage = damage,
                realDamage = damage,
                realDamageString = "沉默",
                huntKind = CONST_HUNT_KIND.skill,
                huntType = { CONST_HUNT_TYPE.real }
            }
        )
    end
    if (sourceUnit ~= nil) then
        -- @触发沉默事件
        hevent.triggerEvent(
            {
                triggerKey = heventKeyMap.silent,
                triggerUnit = sourceUnit,
                targetUnit = u,
                damage = damage,
                during = during
            }
        )
    end
    -- @触发被沉默事件
    hevent.triggerEvent(
        {
            triggerKey = heventKeyMap.beSilent,
            triggerUnit = u,
            sourceUnit = sourceUnit,
            damage = damage,
            during = during
        }
    )
    htime.setTimeout(
        during,
        function(t, td)
            htime.delDialog(td)
            htime.delTimer(t)
            hskill.set(u, "silentLevel", hskill.get(u, "silentLevel") - 1)
            if (hskill.get(u, "silentLevel") <= 0) then
                heffect.del(hskill.get(u, "silentEffect"))
                if (hSys.inArray(u, hRuntime.skill.silentUnits)) then
                    hSys.rmArray(u, hRuntime.skill.silentUnits)
                end
                his.set(u, "isSilent", false)
            end
        end
    )
end

--[[
    缴械! 注意这个方法对中立被动无效
    bean = {
        whichUnit = unit, --目标单位，必须
        during = 0, --持续时间，必须
        odds = 100, --几率，可选
        damage = 0, --伤害，可选
        sourceUnit = nil, --来源单位，可选
        huntKind = CONST_HUNT_KIND.skill --伤害的种类（可选）
        huntType = {CONST_HUNT_TYPE.real} --伤害的类型,注意是table（可选）
    }
]]
hskill.unarm = function(bean)
    if (bean.whichUnit == nil or bean.during == nil or bean.during <= 0) then
        return
    end
    if (bean.damage ~= nil and bean.sourceUnit == nil) then
        return
    end
    local u = bean.whichUnit
    local during = bean.during
    local odds = bean.odds or 100
    local damage = bean.damage or 0
    local sourceUnit = bean.sourceUnit or nil
    local huntKind = bean.huntKind or CONST_HUNT_KIND.skill
    local huntType = bean.sourceUnit or { CONST_HUNT_TYPE.real }
    --计算抵抗
    local oppose = hattr.get(u, "unarm_oppose")
    odds = odds - oppose --(%)
    if (odds <= 0) then
        return
    else
        if (math.random(1, 1000) > odds * 10) then
            return
        end
        during = during * (1 - oppose * 0.01)
        damage = damage * (1 - oppose * 0.01)
    end
    if (hRuntime.skill.unarmUnits == nil) then
        hRuntime.skill.unarmUnits = {}
    end
    if (hRuntime.skill.unarmTrigger == nil) then
        hRuntime.skill.unarmTrigger = cj.CreateTrigger()
        bj.TriggerRegisterAnyUnitEventBJ(hRuntime.skill.unarmTrigger, EVENT_PLAYER_UNIT_ATTACKED)
        cj.TriggerAddAction(
            hRuntime.skill.unarmTrigger,
            function()
                local u1 = cj.GetTriggerUnit()
                if (hSys.inArray(u1, hRuntime.skill.unarmUnits)) then
                    cj.IssueImmediateOrder(u1, "stop")
                end
            end
        )
    end
    local level = hskill.get(u, "unarmLevel") + 1
    if (level <= 1) then
        htextTag.style(htextTag.ttg2Unit(u, "缴械", 6.00, "ffe4e1", 10, 1.00, 10.00), "scale", 0, 0.2)
    else
        htextTag.style(
            htextTag.ttg2Unit(u, math.floor(level) .. "重缴械", 6.00, "ffe4e1", 10, 1.00, 10.00),
            "scale",
            0,
            0.2
        )
    end
    hskill.set(u, "unarmLevel", level)
    if (hSys.inArray(u, hRuntime.skill.unarmUnits) == false) then
        table.insert(hRuntime.skill.unarmUnits, u)
        local eff = heffect.bindUnit("Abilities\\Spells\\Other\\Silence\\SilenceTarget.mdl", u, "weapon", -1)
        hskill.set(u, "unarmEffect", level)
    end
    his.set(u, "isUnArm", true)
    if (damage > 0) then
        hskill.damage(
            {
                fromUnit = sourceUnit,
                toUnit = u,
                damage = damage,
                realDamage = damage,
                realDamageString = "缴械",
                huntKind = CONST_HUNT_KIND.skill,
                huntType = { CONST_HUNT_TYPE.real }
            }
        )
    end
    if (sourceUnit ~= nil) then
        -- @触发缴械事件
        hevent.triggerEvent(
            {
                triggerKey = heventKeyMap.unarm,
                triggerUnit = sourceUnit,
                targetUnit = u,
                damage = damage,
                during = during
            }
        )
    end
    -- @触发被缴械事件
    hevent.triggerEvent(
        {
            triggerKey = heventKeyMap.beUnarm,
            triggerUnit = u,
            sourceUnit = sourceUnit,
            damage = damage,
            during = during
        }
    )
    htime.setTimeout(
        during,
        function(t, td)
            htime.delDialog(td)
            htime.delTimer(t)
            hskill.set(u, "unarmLevel", hskill.get(u, "unarmLevel") - 1)
            if (hskill.get(u, "unarmLevel") <= 0) then
                heffect.del(hskill.get(u, "unarmEffect"))
                if (hSys.inArray(u, hRuntime.skill.unarmUnits)) then
                    hSys.rmArray(u, hRuntime.skill.unarmUnits)
                end
                his.set(u, "isUnArm", false)
            end
        end
    )
end

--[[
    缚足! 注意这个方法对中立被动无效
    bean = {
        whichUnit = unit, --目标单位，必须
        during = 0, --持续时间，必须
        odds = 100, --几率，可选
        damage = 0, --伤害，可选
        sourceUnit = nil, --来源单位，可选
        huntKind = CONST_HUNT_KIND.skill --伤害的种类（可选）
        huntType = {CONST_HUNT_TYPE.real} --伤害的类型,注意是table（可选）
    }
]]
hskill.fetter = function(bean)
    if (bean.whichUnit == nil or bean.during == nil or bean.during <= 0) then
        return
    end
    if (bean.damage ~= nil and bean.sourceUnit == nil) then
        return
    end
    local u = bean.whichUnit
    local during = bean.during
    local odds = bean.odds or 100
    local damage = bean.damage or 0
    local sourceUnit = bean.sourceUnit or nil
    local huntKind = bean.huntKind or CONST_HUNT_KIND.skill
    local huntType = bean.sourceUnit or { CONST_HUNT_TYPE.real }
    --计算抵抗
    local oppose = hattr.get(u, "fetter_oppose")
    odds = odds - oppose --(%)
    if (odds <= 0) then
        return
    else
        if (math.random(1, 1000) > odds * 10) then
            return
        end
        during = during * (1 - oppose * 0.01)
        damage = damage * (1 - oppose * 0.01)
    end
    htextTag.style(htextTag.ttg2Unit(u, "缚足", 6.00, "ffa500", 10, 1.00, 10.00), "scale", 0, 0.2)
    hattr.set(
        u,
        during,
        {
            move = "-522"
        }
    )
    if (damage > 0) then
        hskill.damage(
            {
                fromUnit = sourceUnit,
                toUnit = u,
                damage = damage,
                realDamage = damage,
                realDamageString = "缚足",
                huntKind = CONST_HUNT_KIND.skill,
                huntType = { CONST_HUNT_TYPE.real }
            }
        )
    end
    if (sourceUnit ~= nil) then
        -- @触发缚足事件
        hevent.triggerEvent(
            {
                triggerKey = heventKeyMap.fetter,
                triggerUnit = sourceUnit,
                targetUnit = u,
                damage = damage,
                during = during
            }
        )
    end
    -- @触发被缚足事件
    hevent.triggerEvent(
        {
            triggerKey = heventKeyMap.beFetter,
            triggerUnit = u,
            sourceUnit = sourceUnit,
            damage = damage,
            during = during
        }
    )
end

--[[
    爆破
    bean = {
        damage = 0, --伤害（必须有，小于等于0直接无效）
        range = 1, --范围（可选）
        whichUnit = nil, --目标单位（挑选，单位时会自动选择与此单位同盟的单位）
        whichGroup = nil, --目标单位组（挑选，优先级更高）
        sourceUnit = nil, --伤害来源单位（可选）
        odds = 100, --几率（可选）
        model = nil --目标位置特效（可选）
        modelSingle = nil --个体的特效（可选）
        huntKind = CONST_HUNT_KIND.skill --伤害的种类（可选）
        huntType = {CONST_HUNT_TYPE.real} --伤害的类型,注意是table（可选）
    }
]]
hskill.bomb = function(bean)
    if (bean.damage == nil or bean.damage <= 0) then
        return
    end
    if (bean.sourceUnit == nil) then
        return
    end
    local odds = bean.odds or 100
    local range = bean.range or 1
    local huntKind = bean.huntKind or CONST_HUNT_KIND.skill
    local huntType = bean.huntType or { CONST_HUNT_TYPE.real }
    local whichGroup
    if (bean.whichGroup ~= nil) then
        whichGroup = bean.whichGroup
    elseif (bean.whichUnit ~= nil) then
        whichGroup = hgroup.createByUnit(
            bean.whichUnit,
            range,
            function()
                local flag = true
                if (his.enemy(bean.whichUnit, cj.GetFilterUnit())) then
                    flag = false
                end
                if (his.death(cj.GetFilterUnit())) then
                    flag = false
                end
                if (his.building(cj.GetFilterUnit())) then
                    flag = false
                end
                return flag
            end
        )
    else
        print_err("lost bomb target")
        return
    end
    cj.ForGroup(
        whichGroup,
        function()
            --计算抵抗
            local oppose = hattr.get(cj.GetEnumUnit(), "bomb_oppose")
            local tempOdds = odds - oppose --(%)
            local damage = bean.damage
            if (tempOdds <= 0) then
                return
            else
                if (math.random(1, 1000) > tempOdds * 10) then
                    return
                end
                damage = damage * (1 - oppose * 0.01)
            end
            hskill.damage(
                {
                    fromUnit = bean.sourceUnit,
                    toUnit = cj.GetEnumUnit(),
                    damage = damage,
                    realDamage = range,
                    huntKind = huntKind,
                    huntType = huntType
                }
            )
            -- @触发爆破事件
            hevent.triggerEvent(
                {
                    triggerKey = heventKeyMap.bomb,
                    triggerUnit = bean.sourceUnit,
                    targetUnit = cj.GetEnumUnit(),
                    damage = bean.damage,
                    range = range
                }
            )
            -- @触发被爆破事件
            hevent.triggerEvent(
                {
                    triggerKey = heventKeyMap.beBomb,
                    triggerUnit = cj.GetEnumUnit(),
                    sourceUnit = bean.sourceUnit,
                    damage = bean.damage,
                    range = range
                }
            )
        end
    )
    cj.GroupClear(whichGroup)
    cj.DestroyGroup(whichGroup)
end

--[[
    闪电链
    bean = {
        damage = 0, --伤害（必须有，小于等于0直接无效）
        whichUnit = [unit], --第一个的目标单位（必须有）
        prevUnit = [unit], --上一个的目标单位（必须有，用于构建两点间闪电特效）
        sourceUnit = nil, --伤害来源单位（必须有）
        lightningType = [hlightning.type], -- 闪电效果类型（可选 详情查看 hlightning.type
        odds = 100, --几率（可选）
        qty = 1, --传递的最大单位数（可选，默认1）
        change = 0, --增减率（可选，默认不增不减为0，范围建议[-1.00，1.00]）
        range = 300, --寻找下一目标的作用范围（可选，默认300）
        isRepeat = false, --是否允许同一个单位重复打击（临近2次不会同一个）
        model = nil, --目标位置特效（可选）
        huntKind = CONST_HUNT_KIND.skill, --伤害的种类（可选）
        huntType = {"thunder"}, --伤害的类型,注意是table（可选）
        index = 1,--隐藏的参数，用于暗地里记录是第几个被电到的单位
        repeatGroup = [group],--隐藏的参数，用于暗地里记录单位是否被电过
    }
]]
hskill.lightningChain = function(bean)
    if (bean.whichUnit == nil or bean.prevUnit == nil or bean.damage == nil or bean.damage <= 0) then
        return
    end
    if (bean.sourceUnit == nil) then
        return
    end
    local odds = bean.odds or 100
    local damage = bean.damage
    --计算抵抗
    local oppose = hattr.get(u, "lightning_chain_oppose")
    odds = odds - oppose --(%)
    if (odds <= 0) then
        return
    else
        if (math.random(1, 1000) > odds * 10) then
            return
        end
        damage = damage * (1 - oppose * 0.01)
    end
    local whichUnit = bean.whichUnit
    local prevUnit = bean.prevUnit
    local lightningType = bean.lightningType or hlightning.type.shan_dian_lian_ci
    local qty = bean.qty or 1
    local change = bean.change or 0
    local range = bean.range or 300
    local isRepeat = bean.isRepeat or false
    local huntKind = bean.huntKind or CONST_HUNT_KIND.skill
    local huntType = bean.huntType or { "thunder" }
    qty = qty - 1
    if (qty < 0) then
        qty = 0
    end
    if (bean.index == nil) then
        bean.index = 1
    else
        bean.index = bean.index + 1
    end
    hlightning.unit2unit(lightningType, prevUnit, whichUnit, 0.25)
    if (bean.model ~= nil) then
        heffect.toUnit(bean.model, whichUnit, "origin", 0.5)
    end
    hskill.damage(
        {
            fromUnit = bean.sourceUnit,
            toUnit = whichUnit,
            damage = damage,
            realDamage = damage,
            huntKind = huntKind,
            huntType = huntType
        }
    )
    -- @触发闪电链成功事件
    hevent.triggerEvent(
        {
            triggerKey = heventKeyMap.lightningChain,
            triggerUnit = bean.sourceUnit,
            targetUnit = whichUnit,
            damage = damage,
            range = range,
            index = bean.index
        }
    )
    -- @触发被闪电链事件
    hevent.triggerEvent(
        {
            triggerKey = heventKeyMap.beLightningChain,
            triggerUnit = whichUnit,
            sourceUnit = bean.sourceUnit,
            damage = damage,
            range = range,
            index = bean.index
        }
    )
    if (qty > 0) then
        if (isRepeat ~= true) then
            if (bean.repeatGroup == nil) then
                bean.repeatGroup = cj.CreateGroup()
            end
            cj.GroupAddUnit(bean.repeatGroup, whichUnit)
        end
        local g = hgroup.createByUnit(
            bean.toUnit,
            range,
            function()
                local flag = true
                if (his.death(cj.GetFilterUnit())) then
                    flag = false
                end
                if (his.ally(cj.GetFilterUnit(), bean.sourceUnit)) then
                    flag = false
                end
                if (his.isBuilding(cj.GetFilterUnit())) then
                    flag = false
                end
                if (his.unit(whichUnit, cj.GetFilterUnit())) then
                    flag = false
                end
                if (isRepeat ~= true and hgroup.isIn(bean.repeatGroup, cj.GetFilterUnit())) then
                    flag = false
                end
                return flag
            end
        )
        if (hgroup.isEmpty(g)) then
            return
        end
        bean.whichUnit = cj.FirstOfGroup(g)
        bean.damage = bean.damage * (1 + change)
        cj.GroupClear(g)
        cj.DestroyGroup(g)
        htime.setTimeout(
            0.35,
            function(t, td)
                htime.delDialog(td)
                htime.delTimer(t)
                hskill.lightningChain(bean)
            end
        )
    else
        if (bean.repeatGroup ~= nil) then
            cj.GroupClear(bean.repeatGroup)
            cj.DestroyGroup(bean.repeatGroup)
        end
    end
end

--[[
    击飞
    bean = {
        damage = 0, --伤害（必须有，但是这里可以等于0）
        whichUnit = [unit], --第一个的目标单位（必须有）
        sourceUnit = [unit], --伤害来源单位（必须有）
        odds = 100, --几率（可选,默认100）
        distance = 0, --击退距离，可选，默认0
        high = 100, --击飞高度，可选，默认100
        during = 0.5, --击飞过程持续时间，可选，默认0.5秒
        huntKind = CONST_HUNT_KIND.skill --伤害的种类（可选）
        huntType = {CONST_HUNT_TYPE.real} --伤害的类型,注意是table（可选）
    }
]]
hskill.crackFly = function(bean)
    if (bean.damage == nil or bean.damage < 0) then
        return
    end
    if (bean.whichUnit == nil or bean.sourceUnit == nil) then
        return
    end
    local odds = bean.odds or 100
    local damage = bean.damage
    --计算抵抗
    local oppose = hattr.get(u, "crack_fly_oppose")
    odds = odds - oppose --(%)
    if (odds <= 0) then
        return
    else
        if (math.random(1, 1000) > odds * 10) then
            return
        end
        if (damage > 0) then
            damage = damage * (1 - oppose * 0.01)
        end
    end
    local distance = bean.distance or 0
    local high = bean.high or 100
    local during = bean.during or 0.5
    if (during < 0.5) then
        during = 0.5
    end
    --不二次击飞
    if (his.get(bean.toUnit, "isCrackFly") == true) then
        return
    end
    his.set(bean.toUnit, "isCrackFly", true)
    --镜头放大模式下，距离缩小一半
    if (hcamera.getModel(cj.GetOwningPlayer(bean.toUnit)) == "zoomin") then
        distance = distance * 0.5
        high = high * 0.5
    end
    local tempObj = {
        odds = 99999,
        whichUnit = bean.whichUnit,
        during = during
    }
    hskill.unarm(tempObj)
    hskill.silent(tempObj)
    hattr.set(
        bean.toUnit,
        during,
        {
            move = "-9999"
        }
    )
    hunit.setCanFly(bean.whichUnit)
    cj.SetUnitPathing(bean.whichUnit, false)
    local originHigh = cj.GetUnitFlyHeight(bean.whichUnit)
    local originFacing = hunit.getFacing(bean.whichUnit)
    local originDeg = hlogic.getDegBetweenUnit(bean.sourceUnit, bean.whichUnit)
    local cost = 0
    -- @触发击飞事件
    hevent.triggerEvent(
        {
            triggerKey = heventKeyMap.crackFly,
            triggerUnit = bean.sourceUnit,
            targetUnit = bean.whichUnit,
            damage = damage,
            high = high,
            distance = distance
        }
    )
    -- @触发被击飞事件
    hevent.triggerEvent(
        {
            triggerKey = heventKeyMap.beCrackFly,
            triggerUnit = bean.whichUnit,
            sourceUnit = bean.sourceUnit,
            damage = damage,
            high = high,
            distance = distance
        }
    )
    htime.setInterval(
        0.05,
        function(t, td)
            local dist = 0
            local z = 0
            local timerSetTime = htime.getSetTime(t)
            if (cost > during) then
                hskill.damage(
                    {
                        fromUnit = bean.fromUnit,
                        toUnit = bean.whichUnit,
                        damage = bean.damage,
                        realDamage = bean.damage,
                        huntEff = bean.huntEff,
                        huntKind = bean.huntKind,
                        huntType = bean.huntType
                    }
                )
                cj.SetUnitFlyHeight(bean.whichUnit, originHigh, 10000)
                cj.SetUnitPathing(bean.whichUnit, true)
                his.set(bean.whichUnit, "isCrackFly", false)
                -- 默认是地面，创建沙尘
                local tempEff = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
                if (his.water(bean.whichUnit) == true) then
                    -- 如果是水面，创建水花
                    tempEff = "Abilities\\Spells\\Other\\CrushingWave\\CrushingWaveDamage.mdl"
                end
                heffect.whichUnit(tempEff, bean.whichUnit, 0)
                htime.delDialog(td)
                htime.delTimer(t)
                return
            end
            cost = cost + timerSetTime
            if (cost < during * 0.35) then
                dist = distance / (during * 0.5 / timerSetTime)
                z = high / (during * 0.35 / timerSetTime)
                if (dist > 0) then
                    local pxy = hlogic.polarProjection(
                        cj.GetUnitX(bean.whichUnit),
                        cj.GetUnitY(bean.whichUnit),
                        dist,
                        originDeg
                    )
                    cj.SetUnitFacing(bean.whichUnit, originFacing)
                    cj.SetUnitPosition(bean.whichUnit, pxy.x, pxy.y)
                end
                if (z > 0) then
                    cj.SetUnitFlyHeight(bean.whichUnit, cj.GetUnitFlyHeight(bean.whichUnit) + z, z / timerSetTime)
                end
            else
                dist = distance / (during * 0.5 / timerSetTime)
                z = high / (during * 0.65 / timerSetTime)
                if (dist > 0) then
                    local pxy = hlogic.polarProjection(
                        cj.GetUnitX(bean.whichUnit),
                        cj.GetUnitY(bean.whichUnit),
                        dist,
                        originDeg
                    )
                    cj.SetUnitFacing(bean.whichUnit, originFacing)
                    cj.SetUnitPosition(bean.whichUnit, pxy.x, pxy.y)
                end
                if (z > 0) then
                    cj.SetUnitFlyHeight(bean.whichUnit, cj.GetUnitFlyHeight(bean.whichUnit) - z, z / timerSetTime)
                end
            end
        end
    )
end

--[[
    剃
    mover, 移动的单位
    x, y, 目标XY坐标
    speed, 速度
    meff, 移动特效
    range, 伤害范围
    isRepeat, 是否允许重复伤害
    bean 伤害bean
]]
hskill.leap = function(mover, targetX, targetY, speed, meff, range, isRepeat, bean)
    local lock_var_period = 0.02
    local repeatGroup
    if (mover == nil or targetX == nil or targetY == nil) then
        return
    end
    if (isRepeat == false) then
        repeatGroup = cj.CreateGroup()
    else
        repeatGroup = nil
    end
    if (speed > 150) then
        speed = 150 -- 最大速度
    elseif (speed <= 1) then
        speed = 1 -- 最小速度
    end
    cj.SetUnitInvulnerable(mover, true)
    cj.SetUnitPathing(mover, false)
    local duringInc = 0
    htime.setInterval(
        lock_var_period,
        function(t, td)
            duringInc = duringInc + cj.TimerGetTimeout(t)
            local x = cj.GetUnitX(mover)
            local y = cj.GetUnitY(mover)
            local hxy = hlogic.polarProjection(x, y, speed, hlogic.getDegBetweenXY(x, y, targetX, targetY))
            cj.SetUnitPosition(mover, hxy.x, hxy.y)
            if (meff ~= nil) then
                heffect.toXY(meff, x, y, 0.5)
            end
            if (bean.damage > 0) then
                local g = hgroup.createByUnit(
                    mover,
                    range,
                    function()
                        local flag = true
                        if (his.death(cj.GetFilterUnit())) then
                            flag = false
                        end
                        if (his.ally(cj.GetFilterUnit(), bean.fromUnit)) then
                            flag = false
                        end
                        if (his.isBuilding(cj.GetFilterUnit())) then
                            flag = false
                        end
                        if (isRepeat ~= true and hgroup.isIn(repeatGroup, cj.GetFilterUnit())) then
                            flag = false
                        end
                        return flag
                    end
                )
                cj.ForGroup(
                    g,
                    function()
                        hskill.damage(
                            {
                                damage = bean.damage,
                                fromUnit = bean.fromUnit,
                                toUnit = cj.GetEnumUnit(),
                                huntEff = bean.huntEff,
                                huntKind = bean.huntKind,
                                huntType = bean.huntType
                            }
                        )
                    end
                )
                cj.GroupClear(g)
                cj.DestroyGroup(g)
            end
            local distance = hlogic.getDegBetweenXY(x, y, targetX, targetY)
            if (distance < speed or distance <= 0 or speed <= 0 or his.death(mover) == true or duringInc > 6) then
                htime.delDialog(td)
                htime.delTimer(t)
                cj.SetUnitInvulnerable(mover, false)
                cj.SetUnitPathing(mover, true)
                cj.SetUnitPosition(mover, targetX, targetY)
                cj.SetUnitVertexColorBJ(mover, 100, 100, 100, 0)
                if (repeatGroup ~= nil) then
                    cj.GroupClear(repeatGroup)
                    cj.DestroyGroup(repeatGroup)
                end
            end
        end
    )
end

--[[
    变身[参考 h-lua变身技能模板]
    * modelFrom 技能模板 参考 h-lua SLK
    * modelTo 技能模板 参考 h-lua SLK
]]
hskill.shapeshift = function(u, during, modelFrom, modelTo, eff, attrData)
    heffect.toUnit(eff, u, 1.5)
    UnitAddAbility(u, modelTo)
    UnitRemoveAbility(u, modelTo)
    hattr.reRegister(u)
    htime.setTimeout(
        during,
        function(t, td)
            htime.delDialog(td)
            htime.delTimer(t)
            heffect.toUnit(eff, u, 1.5)
            UnitAddAbility(u, modelFrom)
            UnitRemoveAbility(u, modelFrom)
            hattr.reRegister(u)
        end
    )
    -- 根据data影响属性
    hattr.set(u, during, attrData)
end

--- 自定义技能 - 对单位/对XY/对点
--[[
    bean = {
        whichPlayer,
        skillId,
        orderString,
        x,y 创建位置
        targetX,targetY 对XY时可选
        targetLoc, 对点时可选
        targetUnit, 对单位时可选
        life, 马甲生命周期
    }
]]
hskill.diy = function(bean)
    if (bean.whichPlayer == nil or bean.skillId == nil or bean.orderString == nil) then
        return
    end
    if (bean.x == nil or bean.y == nil) then
        return
    end
    local life = bean.life
    if (bean.life == nil or bean.life < 2.00) then
        life = 2.00
    end
    local token = cj.CreateUnit(bean.whichPlayer, hskill.SKILL_TOKEN, x, y, bj_UNIT_FACING)
    cj.UnitAddAbility(token, bean.skillId)
    if (bean.targetUnit ~= nil) then
        cj.IssueTargetOrderById(token, bean.orderId, bean.targetUnit)
    elseif (bean.targetX ~= nil and bean.targetY ~= nil) then
        cj.IssuePointOrder(token, bean.orderString, bean.targetX, bean.targetY)
    elseif (bean.targetLoc ~= nil) then
        cj.IssuePointOrderLoc(token, bean.orderString, bean.targetLoc)
    else
        cj.IssueImmediateOrder(token, bean.orderString)
    end
    hunit.del(token, life)
end

return hskill
