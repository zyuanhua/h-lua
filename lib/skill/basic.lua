--回避
hskill.avoid = function(whichUnit)
    cj.UnitAddAbility(whichUnit, hskill.BUFF_AVOID_PLUS)
    cj.SetUnitAbilityLevel(whichUnit, hskill.BUFF_AVOID_PLUS, 2)
    cj.UnitRemoveAbility(whichUnit, hskill.BUFF_AVOID_PLUS)
    htime.setTimeout(
        0.00,
        function(t, td)
            htime.delDialog(td)
            htime.delTimer(t)
            cj.UnitAddAbility(whichUnit, hskill.BUFF_AVOID_MIUNS)
            cj.SetUnitAbilityLevel(whichUnit, hskill.BUFF_AVOID_MIUNS, 2)
            cj.UnitRemoveAbility(whichUnit, hskill.BUFF_AVOID_MIUNS)
        end
    )
end

--无敌
hskill.invulnerable = function(whichUnit, during, effect)
    if (whichUnit == nil) then
        return
    end
    if (during < 0) then
        during = 0.00 -- 如果设置持续时间错误，则0秒无敌，跟回避效果相同
    end
    cj.UnitAddAbility(whichUnit, hskill.BUFF_INVULNERABLE)
    if (during > 0 and effect ~= nil) then
        heffect.bindUnit(effect, whichUnit, "origin", during)
    end
    htime.setTimeout(
        during,
        function(t, td)
            htime.delDialog(td)
            htime.delTimer(t)
            cj.UnitRemoveAbility(whichUnit, hskill.BUFF_INVULNERABLE)
        end
    )
end

--范围群体无敌
hskill.invulnerableRange = function(x, y, radius, filter, during, effect)
    if (x == nil or y == nil or filter == nil) then
        return
    end
    if (during < 0) then
        during = 0.00 -- 如果设置持续时间错误，则0秒无敌，跟回避效果相同
    end
    local g = hgroup.createByXY(x, y, radius, filter)
    cj.ForGroup(
        g,
        function()
            hunit.setInvulnerable(cj.GetEnumUnit(), true)
            if (during > 0 and effect ~= nil) then
                heffect.bindUnit(effect, cj.GetEnumUnit(), "origin", during)
            end
        end
    )
    htime.setTimeout(
        during,
        function(t, td)
            htime.delDialog(td)
            htime.delTimer(t)
            cj.ForGroup(
                g,
                function()
                    hunit.setInvulnerable(cj.GetEnumUnit(), false)
                end
            )
            cj.GroupClear(g)
            cj.DestroyGroup(g)
            g = nil
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

--隐身
hskill.invisible = function(whichUnit, during, transition, effect)
    if (whichUnit == nil or during == nil or during <= 0) then
        return
    end
    if (his.death(whichUnit)) then
        return
    end
    transition = transition or 0
    if (effect ~= nil) then
        heffect.toUnit(effect, whichUnit, 0)
    end
    if (transition > 0) then
        htime.setTimeout(
            transition,
            function(t, td)
                htime.delDialog(td)
                htime.delTimer(t)
                hskill.add(whichUnit, hskill.BUFF_INVISIBLE, during)
            end
        )
    else
        hskill.add(whichUnit, hskill.BUFF_INVISIBLE, during)
    end
end

--现形
hskill.visible = function(whichUnit, during, transition, effect)
    if (whichUnit == nil or during == nil or during <= 0) then
        return
    end
    if (his.death(whichUnit)) then
        return
    end
    transition = transition or 0
    if (effect ~= nil) then
        heffect.toUnit(effect, whichUnit, 0)
    end
    if (transition > 0) then
        htime.setTimeout(
            transition,
            function(t, td)
                htime.delDialog(td)
                htime.delTimer(t)
                hskill.del(whichUnit, hskill.BUFF_INVISIBLE, during)
            end
        )
    else
        hskill.del(whichUnit, hskill.BUFF_INVISIBLE, during)
    end
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

--[[
    自定义技能 - 对单位/对XY/对点
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
