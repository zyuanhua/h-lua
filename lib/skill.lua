local hskill = {
    SKILL_TOKEN = hslk_global.unit_token,
    SKILL_BREAK = hslk_global.skill_break,
    SKILL_SWIM = hslk_global.skill_swim_unlimit,
    SKILL_AVOID_PLUS = hslk_global.attr.avoid.add,
    SKILL_AVOID_MIUNS = hslk_global.attr.avoid.sub,
    BUFF_SWIM = string.char2id("BPSE")
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
        return defaultVal
    end
    if (hRuntime.skill[handle] == nil or hRuntime.skill[handle][key] == nil) then
        return defaultVal
    end
    return hRuntime.skill[handle][key]
end

-- 添加技能
hskill.add = function(whichUnit, ability_id, during)
    local id = string.char2id(ability_id)
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
    local id = string.char2id(ability_id)
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
    local id = string.char2id(ability_id)
    cj.UnitMakeAbilityPermanent(whichUnit, true, id)
end

-- 是否拥有技能
hskill.has = function(whichUnit, ability_id)
    if (whichUnit == nil or ability_id == nil) then
        return false
    end
    local id = string.char2id(ability_id)
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
    options = {
        sourceUnit = nil, --伤害来源
        targetUnit = nil, --目标单位
        damage = 0, --实际伤害
        damageString = "", --伤害漂浮字颜色
        damageStringColor = "", --伤害漂浮字颜色
        effect = nil, --伤害特效
        damageKind = "attack", --伤害种类请查看 CONST_DAMAGE_KIND
        damageType = { "magic", "thunder" }, --伤害类型请查看 CONST_DAMAGE_TYPE
    }
]]
hskill.damage = function(options)
    local sourceUnit = options.sourceUnit
    local targetUnit = options.targetUnit
    local damage = options.damage or 0
    if (damage <= 0) then
        return
    end
    if (targetUnit == nil) then
        print_err("hskill.damage -sourceUnit -targetUnit")
        print_stack()
        return
    end
    -- 文本显示
    options.damageString = options.damageString or ""
    options.damageStringColor = options.damageStringColor
    htextTag.style(
        htextTag.create2Unit(
            targetUnit,
            options.damageString .. math.floor(options.realDamage),
            6.00,
            options.damageStringColor,
            1,
            1.1,
            11.00
        ),
        "toggle",
        -0.05,
        0
    )
    if (sourceUnit ~= nil) then
        hevent.setLastDamageUnit(targetUnit, sourceUnit)
        hplayer.addDamage(cj.GetOwningPlayer(sourceUnit), options.realDamage)
    end
    hplayer.addBeDamage(cj.GetOwningPlayer(targetUnit), options.realDamage)
    hunit.subCurLife(targetUnit, options.realDamage)
    if (type(options.effect) == "string" and string.len(options.effect) > 0) then
        heffect.toXY(options.effect, cj.GetUnitX(targetUnit), cj.GetUnitY(targetUnit), 0)
    end
    -- @触发伤害事件
    if (sourceUnit ~= nil) then
        hevent.triggerEvent(
            sourceUnit,
            CONST_EVENT.damage,
            {
                triggerUnit = sourceUnit,
                targetUnit = targetUnit,
                sourceUnit = sourceUnit,
                damage = damage,
                damageKind = options.damageKind,
                damageType = options.damageType
            }
        )
    end
    -- @触发被伤害事件
    hevent.triggerEvent(
        targetUnit,
        CONST_EVENT.beDamage,
        {
            triggerUnit = targetUnit,
            sourceUnit = sourceUnit,
            damage = damage,
            damageKind = options.damageKind,
            damageType = options.damageType
        }
    )
    if (options.damageKind == CONST_DAMAGE_KIND.attack) then
        if (sourceUnit ~= nil) then
            -- @触发攻击事件
            hevent.triggerEvent(
                sourceUnit,
                CONST_EVENT.attack,
                {
                    triggerUnit = sourceUnit,
                    attacker = sourceUnit,
                    targetUnit = targetUnit,
                    damage = damage,
                    damageKind = options.damageKind,
                    damageType = options.damageType
                }
            )
        end
        -- @触发被攻击事件
        hevent.triggerEvent(
            targetUnit,
            CONST_EVENT.beAttack,
            {
                triggerUnit = sourceUnit,
                attacker = sourceUnit,
                targetUnit = targetUnit,
                damage = damage,
                damageKind = options.damageKind,
                damageType = options.damageType
            }
        )
    end
end

--[[
    打断 ! 注意这个方法对中立被动无效
    options = {
        whichUnit = unit, --目标单位，必须
        odds = 100, --几率，可选
        damage = 0, --伤害，可选
        sourceUnit = nil, --来源单位，可选
        effect = nil, --特效，可选
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {CONST_DAMAGE_TYPE.real} --伤害的类型,注意是table（可选）
    }
]]
hskill.broken = function(options)
    if (options.whichUnit == nil) then
        return
    end
    if (options.damage ~= nil and options.damage > 0 and options.sourceUnit == nil) then
        return
    end
    local u = options.whichUnit
    local odds = options.odds or 100
    local damage = options.damage or 0
    local sourceUnit = options.sourceUnit or nil
    local damageKind = options.damageKind or CONST_DAMAGE_KIND.skill
    local damageType = options.sourceUnit or {CONST_DAMAGE_TYPE.real}
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
    local cu =
        hunit.create(
        {
            unitId = hskill.SKILL_TOKEN,
            whichPlayer = hplayer.player_passive,
            x = cj.GetUnitX(u),
            y = cj.GetUnitY(u)
        }
    )
    cj.UnitAddAbility(cu, hskill.SKILL_BREAK)
    cj.SetUnitAbilityLevel(cu, hskill.SKILL_BREAK, 1)
    cj.IssueTargetOrder(cu, "thunderbolt", u)
    hunit.del(cu, 0.3)
    if (type(options.effect) == "string" and string.len(options.effect) > 0) then
        heffect.bindUnit(options.effect, u, "origin", during)
    end
    if (damage > 0) then
        hskill.damage(
            {
                sourceUnit = sourceUnit,
                targetUnit = u,
                damage = damage,
                damageString = "打断",
                damageKind = damageKind,
                damageType = damageType
            }
        )
    end
    if (sourceUnit ~= nil) then
        -- @触发打断事件
        hevent.triggerEvent(
            sourceUnit,
            CONST_EVENT.broken,
            {
                triggerUnit = sourceUnit,
                targetUnit = u,
                damage = damage
            }
        )
    end
    -- @触发被打断事件
    hevent.triggerEvent(
        u,
        CONST_EVENT.beBroken,
        {
            triggerUnit = u,
            sourceUnit = sourceUnit,
            damage = damage
        }
    )
end

--[[
    眩晕! 注意这个方法对中立被动无效
    options = {
        whichUnit = unit, --目标单位，必须
        during = 0, --持续时间，必须
        odds = 100, --几率，可选
        damage = 0, --伤害，可选
        sourceUnit = nil, --来源单位，可选
        effect = nil, --特效，可选
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {CONST_DAMAGE_TYPE.real} --伤害的类型,注意是table（可选）
    }
]]
hskill.swim = function(options)
    if (options.whichUnit == nil or options.during == nil or options.during <= 0) then
        return
    end
    if (options.damage ~= nil and options.damage > 0 and options.sourceUnit == nil) then
        return
    end
    local u = options.whichUnit
    local during = options.during
    local odds = options.odds or 100
    local damage = options.damage or 0
    local sourceUnit = options.sourceUnit or nil
    local damageKind = options.damageKind or CONST_DAMAGE_KIND.skill
    local damageType = options.sourceUnit or {CONST_DAMAGE_TYPE.real}
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
    local cu =
        hunit.create(
        {
            unitId = hskill.SKILL_TOKEN,
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
    if (type(options.effect) == "string" and string.len(options.effect) > 0) then
        heffect.bindUnit(options.effect, u, "origin", during)
    end
    if (damage > 0) then
        hskill.damage(
            {
                sourceUnit = sourceUnit,
                targetUnit = u,
                damage = damage,
                damageString = "眩晕",
                damageKind = CONST_DAMAGE_KIND.skill,
                damageType = {CONST_DAMAGE_TYPE.real}
            }
        )
    end
    if (sourceUnit ~= nil) then
        -- @触发眩晕事件
        hevent.triggerEvent(
            sourceUnit,
            CONST_EVENT.swim,
            {
                triggerUnit = sourceUnit,
                targetUnit = u,
                damage = damage,
                during = during
            }
        )
    end
    -- @触发被眩晕事件
    hevent.triggerEvent(
        u,
        CONST_EVENT.beSwim,
        {
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
    沉默
    options = {
        whichUnit = unit, --目标单位，必须
        during = 0, --持续时间，必须
        odds = 100, --几率，可选
        damage = 0, --伤害，可选
        sourceUnit = nil, --来源单位，可选
        effect = nil, --特效，可选
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {CONST_DAMAGE_TYPE.real} --伤害的类型,注意是table（可选）
    }
]]
hskill.silent = function(options)
    if (options.whichUnit == nil or options.during == nil or options.during <= 0) then
        return
    end
    if (options.damage ~= nil and options.damage > 0 and options.sourceUnit == nil) then
        return
    end
    local u = options.whichUnit
    local during = options.during
    local odds = options.odds or 100
    local damage = options.damage or 0
    local sourceUnit = options.sourceUnit or nil
    local damageKind = options.damageKind or CONST_DAMAGE_KIND.skill
    local damageType = options.sourceUnit or {CONST_DAMAGE_TYPE.real}
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
                if (table.includes(u1, hRuntime.skill.silentUnits)) then
                    cj.IssueImmediateOrder(u1, "stop")
                end
            end
        )
    end
    local level = hskill.get(u, "silentLevel", 0) + 1
    if (level <= 1) then
        htextTag.style(htextTag.create2Unit(u, "沉默", 6.00, "ee82ee", 10, 1.00, 10.00), "scale", 0, 0.2)
    else
        htextTag.style(
            htextTag.create2Unit(u, math.floor(level) .. "重沉默", 6.00, "ee82ee", 10, 1.00, 10.00),
            "scale",
            0,
            0.2
        )
    end
    if (type(options.effect) == "string" and string.len(options.effect) > 0) then
        heffect.bindUnit(options.effect, u, "origin", during)
    end
    hskill.set(u, "silentLevel", level)
    if (table.includes(u, hRuntime.skill.silentUnits) == false) then
        table.insert(hRuntime.skill.silentUnits, u)
        local eff = heffect.bindUnit("Abilities\\Spells\\Other\\Silence\\SilenceTarget.mdl", u, "head", -1)
        hskill.set(u, "silentEffect", eff)
    end
    his.set(u, "isSilent", true)
    if (damage > 0) then
        hskill.damage(
            {
                sourceUnit = sourceUnit,
                targetUnit = u,
                damage = damage,
                damageString = "沉默",
                damageKind = CONST_DAMAGE_KIND.skill,
                damageType = {CONST_DAMAGE_TYPE.real}
            }
        )
    end
    if (sourceUnit ~= nil) then
        -- @触发沉默事件
        hevent.triggerEvent(
            sourceUnit,
            CONST_EVENT.silent,
            {
                triggerUnit = sourceUnit,
                targetUnit = u,
                damage = damage,
                during = during
            }
        )
    end
    -- @触发被沉默事件
    hevent.triggerEvent(
        u,
        CONST_EVENT.beSilent,
        {
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
            hskill.set(u, "silentLevel", hskill.get(u, "silentLevel", 0) - 1)
            if (hskill.get(u, "silentLevel") <= 0) then
                heffect.del(hskill.get(u, "silentEffect"))
                if (table.includes(u, hRuntime.skill.silentUnits)) then
                    table.delete(u, hRuntime.skill.silentUnits)
                end
                his.set(u, "isSilent", false)
            end
        end
    )
end

--[[
    缴械
    options = {
        whichUnit = unit, --目标单位，必须
        during = 0, --持续时间，必须
        odds = 100, --几率，可选
        damage = 0, --伤害，可选
        sourceUnit = nil, --来源单位，可选
        effect = nil, --特效，可选
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {CONST_DAMAGE_TYPE.real} --伤害的类型,注意是table（可选）
    }
]]
hskill.unarm = function(options)
    if (options.whichUnit == nil or options.during == nil or options.during <= 0) then
        return
    end
    if (options.damage ~= nil and options.damage > 0 and options.sourceUnit == nil) then
        return
    end
    local u = options.whichUnit
    local during = options.during
    local odds = options.odds or 100
    local damage = options.damage or 0
    local sourceUnit = options.sourceUnit or nil
    local damageKind = options.damageKind or CONST_DAMAGE_KIND.skill
    local damageType = options.sourceUnit or {CONST_DAMAGE_TYPE.real}
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
                if (table.includes(u1, hRuntime.skill.unarmUnits)) then
                    cj.IssueImmediateOrder(u1, "stop")
                end
            end
        )
    end
    local level = hskill.get(u, "unarmLevel", 0) + 1
    if (level <= 1) then
        htextTag.style(htextTag.create2Unit(u, "缴械", 6.00, "ffe4e1", 10, 1.00, 10.00), "scale", 0, 0.2)
    else
        htextTag.style(
            htextTag.create2Unit(u, math.floor(level) .. "重缴械", 6.00, "ffe4e1", 10, 1.00, 10.00),
            "scale",
            0,
            0.2
        )
    end
    if (type(options.effect) == "string" and string.len(options.effect) > 0) then
        heffect.bindUnit(options.effect, u, "origin", during)
    end
    hskill.set(u, "unarmLevel", level)
    if (table.includes(u, hRuntime.skill.unarmUnits) == false) then
        table.insert(hRuntime.skill.unarmUnits, u)
        local eff = heffect.bindUnit("Abilities\\Spells\\Other\\Silence\\SilenceTarget.mdl", u, "weapon", -1)
        hskill.set(u, "unarmEffect", eff)
    end
    his.set(u, "isUnArm", true)
    if (damage > 0) then
        hskill.damage(
            {
                sourceUnit = sourceUnit,
                targetUnit = u,
                damage = damage,
                damageString = "缴械",
                damageKind = CONST_DAMAGE_KIND.skill,
                damageType = {CONST_DAMAGE_TYPE.real}
            }
        )
    end
    if (sourceUnit ~= nil) then
        -- @触发缴械事件
        hevent.triggerEvent(
            sourceUnit,
            CONST_EVENT.unarm,
            {
                triggerUnit = sourceUnit,
                targetUnit = u,
                damage = damage,
                during = during
            }
        )
    end
    -- @触发被缴械事件
    hevent.triggerEvent(
        u,
        CONST_EVENT.beUnarm,
        {
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
            hskill.set(u, "unarmLevel", hskill.get(u, "unarmLevel", 0) - 1)
            if (hskill.get(u, "unarmLevel") <= 0) then
                heffect.del(hskill.get(u, "unarmEffect"))
                if (table.includes(u, hRuntime.skill.unarmUnits)) then
                    table.delete(u, hRuntime.skill.unarmUnits)
                end
                his.set(u, "isUnArm", false)
            end
        end
    )
end

--[[
    缚足
    options = {
        whichUnit = unit, --目标单位，必须
        during = 0, --持续时间，必须
        odds = 100, --几率，可选
        damage = 0, --伤害，可选
        sourceUnit = nil, --来源单位，可选
        effect = nil, --特效，可选
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {CONST_DAMAGE_TYPE.real} --伤害的类型,注意是table（可选）
    }
]]
hskill.fetter = function(options)
    if (options.whichUnit == nil or options.during == nil or options.during <= 0) then
        return
    end
    if (options.damage ~= nil and options.damage > 0 and options.sourceUnit == nil) then
        return
    end
    local u = options.whichUnit
    local during = options.during
    local odds = options.odds or 100
    local damage = options.damage or 0
    local sourceUnit = options.sourceUnit or nil
    local damageKind = options.damageKind or CONST_DAMAGE_KIND.skill
    local damageType = options.sourceUnit or {CONST_DAMAGE_TYPE.real}
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
    htextTag.style(htextTag.create2Unit(u, "缚足", 6.00, "ffa500", 10, 1.00, 10.00), "scale", 0, 0.2)
    if (type(options.effect) == "string" and string.len(options.effect) > 0) then
        heffect.bindUnit(options.effect, u, "origin", during)
    end
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
                sourceUnit = sourceUnit,
                targetUnit = u,
                damage = damage,
                damageString = "缚足",
                damageKind = CONST_DAMAGE_KIND.skill,
                damageType = {CONST_DAMAGE_TYPE.real}
            }
        )
    end
    if (sourceUnit ~= nil) then
        -- @触发缚足事件
        hevent.triggerEvent(
            sourceUnit,
            CONST_EVENT.fetter,
            {
                triggerUnit = sourceUnit,
                targetUnit = u,
                damage = damage,
                during = during
            }
        )
    end
    -- @触发被缚足事件
    hevent.triggerEvent(
        u,
        CONST_EVENT.beFetter,
        {
            triggerUnit = u,
            sourceUnit = sourceUnit,
            damage = damage,
            during = during
        }
    )
end

--[[
    爆破
    options = {
        damage = 0, --伤害（必须有，小于等于0直接无效）
        range = 1, --范围（可选）
        whichUnit = nil, --目标单位（挑选，单位时会自动选择与此单位同盟的单位）
        whichGroup = nil, --目标单位组（挑选，优先级更高）
        sourceUnit = nil, --伤害来源单位（可选）
        odds = 100, --几率（可选）
        effect = nil --目标位置特效（可选）
        effectSingle = nil --个体的特效（可选）
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {CONST_DAMAGE_TYPE.real} --伤害的类型,注意是table（可选）
    }
]]
hskill.bomb = function(options)
    if (options.damage == nil or options.damage <= 0) then
        return
    end
    if (options.sourceUnit == nil) then
        return
    end
    local odds = options.odds or 100
    local range = options.range or 1
    local damageKind = options.damageKind or CONST_DAMAGE_KIND.skill
    local damageType = options.damageType or {CONST_DAMAGE_TYPE.real}
    local whichGroup
    if (options.whichGroup ~= nil) then
        whichGroup = options.whichGroup
    elseif (options.whichUnit ~= nil) then
        whichGroup =
            hgroup.createByUnit(
            options.whichUnit,
            range,
            function()
                local flag = true
                if (his.enemy(options.whichUnit, cj.GetFilterUnit())) then
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
        htextTag.style(htextTag.create2Unit(options.whichUnit, "爆破", 6.00, "FF6347", 10, 1.00, 10.00), "scale", 0, 0.2)
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
            local damage = options.damage
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
                    sourceUnit = options.sourceUnit,
                    targetUnit = cj.GetEnumUnit(),
                    damage = damage,
                    damageKind = damageKind,
                    damageType = damageType
                }
            )
            -- @触发爆破事件
            hevent.triggerEvent(
                options.sourceUnit,
                CONST_EVENT.bomb,
                {
                    triggerUnit = options.sourceUnit,
                    targetUnit = cj.GetEnumUnit(),
                    damage = options.damage,
                    range = range
                }
            )
            -- @触发被爆破事件
            hevent.triggerEvent(
                cj.GetEnumUnit(),
                CONST_EVENT.beBomb,
                {
                    triggerUnit = cj.GetEnumUnit(),
                    sourceUnit = options.sourceUnit,
                    damage = options.damage,
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
    options = {
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
        effect = nil, --目标位置特效（可选）
        damageKind = CONST_DAMAGE_KIND.skill, --伤害的种类（可选）
        damageType = {"thunder"}, --伤害的类型,注意是table（可选）
        index = 1,--隐藏的参数，用于暗地里记录是第几个被电到的单位
        repeatGroup = [group],--隐藏的参数，用于暗地里记录单位是否被电过
    }
]]
hskill.lightningChain = function(options)
    if (options.damage == nil or options.damage <= 0) then
        print_err("lightningChain -damage")
        return
    end
    if (options.whichUnit == nil) then
        print_err("lightningChain -whichUnit")
        return
    end
    if (options.sourceUnit == nil) then
        print_err("lightningChain -sourceUnit")
        return
    end
    if (options.prevUnit == nil) then
        options.prevUnit = options.sourceUnit
    end
    local odds = options.odds or 100
    local damage = options.damage
    --计算抵抗
    local oppose = hattr.get(options.whichUnit, "lightning_chain_oppose")
    odds = odds - oppose --(%)
    if (odds <= 0) then
        return
    else
        if (math.random(1, 1000) > odds * 10) then
            return
        end
        damage = damage * (1 - oppose * 0.01)
    end
    local whichUnit = options.whichUnit
    local prevUnit = options.prevUnit
    local lightningType = options.lightningType or hlightning.type.shan_dian_lian_ci
    local change = options.change or 0
    local range = options.range or 500
    local isRepeat = options.isRepeat or false
    local damageKind = options.damageKind or CONST_DAMAGE_KIND.skill
    local damageType = options.damageType or {"thunder"}
    options.qty = options.qty or 1
    options.qty = options.qty - 1
    if (options.qty < 0) then
        options.qty = 0
    end
    if (options.index == nil) then
        options.index = 1
    else
        options.index = options.index + 1
    end
    hlightning.unit2unit(lightningType, prevUnit, whichUnit, 0.25)
    htextTag.style(htextTag.create2Unit(whichUnit, "电链", 6.00, "87cefa", 10, 1.00, 10.00), "scale", 0, 0.2)
    if (options.effect ~= nil) then
        heffect.bindUnit(options.effect, whichUnit, "origin", 0.5)
    end
    hskill.damage(
        {
            sourceUnit = options.sourceUnit,
            targetUnit = whichUnit,
            damage = damage,
            damageKind = damageKind,
            damageType = damageType
        }
    )
    -- @触发闪电链成功事件
    hevent.triggerEvent(
        options.sourceUnit,
        CONST_EVENT.lightningChain,
        {
            triggerUnit = options.sourceUnit,
            targetUnit = whichUnit,
            damage = damage,
            range = range,
            index = options.index
        }
    )
    -- @触发被闪电链事件
    hevent.triggerEvent(
        whichUnit,
        CONST_EVENT.beLightningChain,
        {
            triggerUnit = whichUnit,
            sourceUnit = options.sourceUnit,
            damage = damage,
            range = range,
            index = options.index
        }
    )
    if (options.qty > 0) then
        if (isRepeat ~= true) then
            if (options.repeatGroup == nil) then
                options.repeatGroup = cj.CreateGroup()
            end
            cj.GroupAddUnit(options.repeatGroup, whichUnit)
        end
        local g =
            hgroup.createByUnit(
            whichUnit,
            range,
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
                if (his.unit(whichUnit, cj.GetFilterUnit())) then
                    flag = false
                end
                if (isRepeat ~= true and hgroup.isIn(options.repeatGroup, cj.GetFilterUnit())) then
                    flag = false
                end
                return flag
            end
        )
        if (hgroup.isEmpty(g)) then
            return
        end
        options.whichUnit = hgroup.getClosest(g, cj.GetUnitX(whichUnit), cj.GetUnitY(whichUnit))
        options.damage = options.damage * (1 + change)
        options.prevUnit = whichUnit
        options.odds = 9999 --闪电链只要开始能延续下去就是100%几率了
        cj.GroupClear(g)
        cj.DestroyGroup(g)
        if (options.damage > 0) then
            htime.setTimeout(
                0.35,
                function(t, td)
                    htime.delDialog(td)
                    htime.delTimer(t)
                    hskill.lightningChain(options)
                end
            )
        end
    else
        if (options.repeatGroup ~= nil) then
            cj.GroupClear(options.repeatGroup)
            cj.DestroyGroup(options.repeatGroup)
        end
    end
end

--[[
    击飞
    options = {
        damage = 0, --伤害（必须有，但是这里可以等于0）
        whichUnit = [unit], --第一个的目标单位（必须有）
        sourceUnit = [unit], --伤害来源单位（必须有）
        odds = 100, --几率（可选,默认100）
        distance = 0, --击退距离，可选，默认0
        high = 100, --击飞高度，可选，默认100
        during = 0.5, --击飞过程持续时间，可选，默认0.5秒
        effect = nil, --特效（可选）
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {CONST_DAMAGE_TYPE.real} --伤害的类型,注意是table（可选）
    }
]]
hskill.crackFly = function(options)
    if (options.damage == nil or options.damage < 0) then
        return
    end
    if (options.whichUnit == nil or options.sourceUnit == nil) then
        return
    end
    local odds = options.odds or 100
    local damage = options.damage
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
    local distance = options.distance or 0
    local high = options.high or 100
    local during = options.during or 0.5
    if (during < 0.5) then
        during = 0.5
    end
    --不二次击飞
    if (his.get(options.targetUnit, "isCrackFly") == true) then
        return
    end
    his.set(options.targetUnit, "isCrackFly", true)
    --镜头放大模式下，距离缩小一半
    if (hcamera.getModel(cj.GetOwningPlayer(options.targetUnit)) == "zoomin") then
        distance = distance * 0.5
        high = high * 0.5
    end
    local tempObj = {
        odds = 99999,
        whichUnit = options.whichUnit,
        during = during
    }
    hskill.unarm(tempObj)
    hskill.silent(tempObj)
    hattr.set(
        options.targetUnit,
        during,
        {
            move = "-9999"
        }
    )
    htextTag.style(htextTag.create2Unit(options.whichUnit, "击飞", 6.00, "808000", 10, 1.00, 10.00), "scale", 0, 0.2)
    if (type(options.effect) == "string" and string.len(options.effect) > 0) then
        heffect.bindUnit(options.effect, options.whichUnit, "origin", during)
    end
    hunit.setCanFly(options.whichUnit)
    cj.SetUnitPathing(options.whichUnit, false)
    local originHigh = cj.GetUnitFlyHeight(options.whichUnit)
    local originFacing = hunit.getFacing(options.whichUnit)
    local originDeg = math.getDegBetweenUnit(options.sourceUnit, options.whichUnit)
    local cost = 0
    -- @触发击飞事件
    hevent.triggerEvent(
        options.sourceUnit,
        CONST_EVENT.crackFly,
        {
            triggerUnit = options.sourceUnit,
            targetUnit = options.whichUnit,
            damage = damage,
            high = high,
            distance = distance
        }
    )
    -- @触发被击飞事件
    hevent.triggerEvent(
        options.whichUnit,
        CONST_EVENT.beCrackFly,
        {
            triggerUnit = options.whichUnit,
            sourceUnit = options.sourceUnit,
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
                        sourceUnit = options.sourceUnit,
                        targetUnit = options.targetUnit,
                        effect = options.effect,
                        damage = options.damage,
                        damageKind = options.damageKind,
                        damageType = options.damageType
                    }
                )
                cj.SetUnitFlyHeight(options.targetUnit, originHigh, 10000)
                cj.SetUnitPathing(options.targetUnit, true)
                his.set(options.targetUnit, "isCrackFly", false)
                -- 默认是地面，创建沙尘
                local tempEff = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
                if (his.water(options.targetUnit) == true) then
                    -- 如果是水面，创建水花
                    tempEff = "Abilities\\Spells\\Other\\CrushingWave\\CrushingWaveDamage.mdl"
                end
                heffect.toUnit(tempEff, options.targetUnit, 0)
                htime.delDialog(td)
                htime.delTimer(t)
                return
            end
            cost = cost + timerSetTime
            if (cost < during * 0.35) then
                dist = distance / (during * 0.5 / timerSetTime)
                z = high / (during * 0.35 / timerSetTime)
                if (dist > 0) then
                    local pxy =
                        math.polarProjection(
                        cj.GetUnitX(options.whichUnit),
                        cj.GetUnitY(options.whichUnit),
                        dist,
                        originDeg
                    )
                    cj.SetUnitFacing(options.whichUnit, originFacing)
                    cj.SetUnitPosition(options.whichUnit, pxy.x, pxy.y)
                end
                if (z > 0) then
                    cj.SetUnitFlyHeight(options.whichUnit, cj.GetUnitFlyHeight(options.whichUnit) + z, z / timerSetTime)
                end
            else
                dist = distance / (during * 0.5 / timerSetTime)
                z = high / (during * 0.65 / timerSetTime)
                if (dist > 0) then
                    local pxy =
                        math.polarProjection(
                        cj.GetUnitX(options.whichUnit),
                        cj.GetUnitY(options.whichUnit),
                        dist,
                        originDeg
                    )
                    cj.SetUnitFacing(options.whichUnit, originFacing)
                    cj.SetUnitPosition(options.whichUnit, pxy.x, pxy.y)
                end
                if (z > 0) then
                    cj.SetUnitFlyHeight(options.whichUnit, cj.GetUnitFlyHeight(options.whichUnit) - z, z / timerSetTime)
                end
            end
        end
    )
end

--[[
    范围眩晕
    options = {
        range = 0, --眩晕范围（必须有）
        during = 0, --眩晕持续时间（必须有）
        odds = 100, --对每个单位的独立几率（可选,默认100）
        effect = "", --特效（可选）
        whichUnit = [unit], --目标单位（可选）
        whichLoc = [location], --目标点（可选）
        x = [point], --目标坐标X（可选）
        y = [point], --目标坐标Y（可选）
        filter = [function], --必须有
        damage = 0, --伤害（可选，但是这里可以等于0）
        sourceUnit = [unit], --伤害来源单位（damage>0时，必须有）
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {CONST_DAMAGE_TYPE.real} --伤害的类型,注意是table（可选）
    }
]]
hskill.rangeSwim = function(options)
    local range = options.range or 0
    local during = options.during or 0
    local damage = options.damage or 0
    if (range <= 0 or during <= 0) then
        print_err("hskill.rangeSwim:-range -during")
        return
    end
    if (damage > 0 and options.sourceUnit == nil) then
        print_err("hskill.rangeSwim:-sourceUnit")
        return
    end
    local odds = options.odds or 100
    local effect = options.effect or "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl"
    local x, y
    if (options.x ~= nil or options.y ~= nil) then
        x = options.x
        y = options.y
    elseif (options.whichUnit ~= nil) then
        x = cj.GetUnitX(options.whichUnit)
        y = cj.GetUnitY(options.whichUnit)
    elseif (options.whichLoc ~= nil) then
        x = cj.GetLocatonX(options.whichLoc)
        y = cj.GetLocatonY(options.whichLoc)
    end
    if (x == nil or y == nil) then
        print_err("hskill.rangeSwim:-x -y")
        return
    end
    local filter = options.filter
    if (type(filter) ~= "function") then
        print_err("filter must be function")
        return
    end
    heffect.toXY(effect, x, y, 0)
    local g = hgroup.createByXY(x, y, range, filter)
    if (g == nil) then
        print_err("rangeSwim has not target")
        return
    end
    if (hgroup.count(g) <= 0) then
        return
    end
    cj.ForGroup(
        g,
        function()
            hskill.swim(
                {
                    odds = odds,
                    whichUnit = cj.GetEnumUnit(),
                    during = during,
                    damage = damage,
                    sourceUnit = options.sourceUnit,
                    damageKind = options.damageKind,
                    damageType = options.damageType
                }
            )
        end
    )
    cj.GroupClear(g)
    cj.DestroyGroup(g)
end

--[[
    范围持续伤害
    options = {
        range = 0, --范围（必须有）
        frequency = 0, --伤害频率（必须有）
        times = 0, --伤害次数（必须有）
        effect = "", --特效（可选）
        effectSingle = "", --单体特效（可选）
        filter = [function], --必须有
        whichUnit = [unit], --目标单位的位置（可选）
        whichLoc = [location], --目标点（可选）
        x = [point], --目标坐标X（可选）
        y = [point], --目标坐标Y（可选）
        damage = 0, --伤害（可选，但是这里可以等于0）
        sourceUnit = [unit], --伤害来源单位（damage>0时，必须有）
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {CONST_DAMAGE_TYPE.real} --伤害的类型,注意是table（可选）
    }
]]
hskill.rangeDamage = function(options)
    local range = options.range or 0
    local times = options.times or 0
    local frequency = options.frequency or 0
    local damage = options.damage or 0
    if (range <= 0 or times <= 0 or frequency <= 0) then
        print_err("hskill.rangeSwim:-range -times -frequency")
        return
    end
    if (damage > 0 and options.sourceUnit == nil) then
        print_err("hskill.rangeSwim:-sourceUnit")
        return
    end
    local odds = options.odds or 100
    local effect = options.effect or "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl"
    local x, y
    if (options.x ~= nil or options.y ~= nil) then
        x = options.x
        y = options.y
    elseif (options.whichUnit ~= nil) then
        x = cj.GetUnitX(options.whichUnit)
        y = cj.GetUnitY(options.whichUnit)
    elseif (options.whichLoc ~= nil) then
        x = cj.GetLocatonX(options.whichLoc)
        y = cj.GetLocatonY(options.whichLoc)
    end
    if (x == nil or y == nil) then
        print_err("hskill.rangeSwim:-x -y")
        return
    end
    local filter = options.filter
    if (type(filter) ~= "function") then
        print_err("filter must be function")
        return
    end
    heffect.toXY(effect, x, y, 0.25 + (times * frequency))
    local ti = 0
    htime.setInterval(
        frequency,
        function(t, td)
            ti = ti + 1
            if (ti >= times) then
                htime.delDialog(td)
                htime.delTimer(t)
                return
            end
            local g = hgroup.createByXY(x, y, range, filter)
            if (g == nil) then
                print_err("rangeDamage has not target")
                return
            end
            if (hgroup.count(g) <= 0) then
                return
            end
            cj.ForGroup(
                g,
                function()
                    hskill.damage(
                        {
                            sourceUnit = options.sourceUnit,
                            targetUnit = cj.GetEnumUnit(),
                            effect = options.effectSingle,
                            damage = damage,
                            damageKind = options.damageKind,
                            damageType = options.damageType
                        }
                    )
                end
            )
            cj.GroupClear(g)
            cj.DestroyGroup(g)
            g = nil
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
    options 伤害options
]]
hskill.leap = function(mover, targetX, targetY, speed, meff, range, isRepeat, options)
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
            local hxy = math.polarProjection(x, y, speed, math.getDegBetweenXY(x, y, targetX, targetY))
            cj.SetUnitPosition(mover, hxy.x, hxy.y)
            if (meff ~= nil) then
                heffect.toXY(meff, x, y, 0.5)
            end
            if (options.damage > 0) then
                local g =
                    hgroup.createByUnit(
                    mover,
                    range,
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
                                sourceUnit = options.sourceUnit,
                                targetUnit = cj.GetEnumUnit(),
                                effect = options.effect,
                                damage = options.damage,
                                damageKind = options.damageKind,
                                damageType = options.damageType
                            }
                        )
                    end
                )
                cj.GroupClear(g)
                cj.DestroyGroup(g)
            end
            local distance = math.getDegBetweenXY(x, y, targetX, targetY)
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
    heffect.targetUnit(eff, u, 1.5)
    UnitAddAbility(u, modelTo)
    UnitRemoveAbility(u, modelTo)
    hattr.reRegister(u)
    htime.setTimeout(
        during,
        function(t, td)
            htime.delDialog(td)
            htime.delTimer(t)
            heffect.targetUnit(eff, u, 1.5)
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
    options = {
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
hskill.diy = function(options)
    if (options.whichPlayer == nil or options.skillId == nil or options.orderString == nil) then
        return
    end
    if (options.x == nil or options.y == nil) then
        return
    end
    local life = options.life
    if (options.life == nil or options.life < 2.00) then
        life = 2.00
    end
    local token = cj.CreateUnit(options.whichPlayer, hskill.SKILL_TOKEN, x, y, bj_UNIT_FACING)
    cj.UnitAddAbility(token, options.skillId)
    if (options.targetUnit ~= nil) then
        cj.IssueTargetOrderById(token, options.orderId, options.targetUnit)
    elseif (options.targetX ~= nil and options.targetY ~= nil) then
        cj.IssuePointOrder(token, options.orderString, options.targetX, options.targetY)
    elseif (options.targetLoc ~= nil) then
        cj.IssuePointOrderLoc(token, options.orderString, options.targetLoc)
    else
        cj.IssueImmediateOrder(token, options.orderString)
    end
    hunit.del(token, life)
end

return hskill
