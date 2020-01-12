-- 加载debug
require "foundation.debug"

-- 加载json
require "foundation.json"

-- 加载md5
require "foundation.md5"

-- 加载runtime
require "foundation.runtime"

-- 加载table
require "foundation.table"

-- 加载string
require "foundation.string"

-- 加载math
require "foundation.math"

-- 加载color
require "foundation.color"

-- 加载h-lua的F9
require "foundation.f9"

hLuaStart = {
    run = function()
        -- 时钟初始化
        -- 全局计时器
        cj.TimerStart(cj.CreateTimer(), 1.00, true, htime.clock)

        -- 玩家系统
        hplayer.init()
        -- 物品系统
        hitem.init()

        -- 单位受伤
        local triggerBeHunt = cj.CreateTrigger()
        cj.TriggerAddAction(
            triggerBeHunt,
            function()
                local fromUnit = cj.GetEventDamageSource()
                local toUnit = cj.GetTriggerUnit()
                local damage = cj.GetEventDamage()
                local oldLife = hunit.getCurLife(toUnit)
                if (damage > 0.125) then
                    hattr.set(toUnit, 0, {life = "+" .. damage})
                    htime.setTimeout(
                        0,
                        function(t, td)
                            htime.delDialog(td)
                            htime.delTimer(t)
                            hattr.set(toUnit, 0, {life = "-" .. damage})
                            hunit.setCurLife(toUnit, oldLife)
                            hattr.huntUnit(
                                {
                                    fromUnit = fromUnit,
                                    toUnit = toUnit,
                                    damage = damage,
                                    damageKind = "attack"
                                }
                            )
                        end
                    )
                end
            end
        )
        -- 单位死亡
        local triggerDeath = cj.CreateTrigger()
        cj.TriggerAddAction(
            triggerDeath,
            function()
                local u = cj.GetTriggerUnit()
                local killer = hevent.getLastDamageUnit(u)
                if (killer ~= nil) then
                    hplayer.addKill(cj.GetOwningPlayer(killer), 1)
                end
                -- @触发死亡事件
                hevent.triggerEvent(
                    u,
                    CONST_EVENT.dead,
                    {
                        triggerUnit = u,
                        killer = killer
                    }
                )
                -- @触发击杀事件
                hevent.triggerEvent(
                    killer,
                    CONST_EVENT.kill,
                    {
                        triggerUnit = killer,
                        killer = killer,
                        targetUnit = u
                    }
                )
            end
        )
        -- 单位进入区域注册
        local triggerRegIn = cj.CreateTrigger()
        bj.TriggerRegisterEnterRectSimple(triggerRegIn, bj.GetPlayableMapRect())
        cj.TriggerAddAction(
            triggerRegIn,
            function()
                local u = cj.GetTriggerUnit()
                if (cj.GetUnitAbilityLevel(u, "Aloc") > 0) then
                    -- 蝗虫不做处理
                    return
                end
                -- 排除单位类型
                local uid = cj.GetUnitTypeId(u)
                if
                    (uid == hslk_global.unit_token or uid == hslk_global.unit_hero_tavern_token or
                        uid == hslk_global.unit_hero_death_token or
                        uid == hslk_global.unit_hero_tavern)
                 then
                    return
                end
                -- 注册
                if (hRuntime.unit[u] == nil) then
                    hRuntime.unit[u] = {}
                end
                if (hRuntime.unit[u].init == nil) then
                    hRuntime.unit[u].init = 1
                    -- 受伤与死亡
                    cj.TriggerRegisterUnitEvent(triggerBeHunt, u, EVENT_UNIT_DAMAGED)
                    cj.TriggerRegisterUnitEvent(triggerDeath, u, EVENT_UNIT_DEATH)
                    -- 属性系统
                    if (hRuntime.attribute[u] == nil) then
                        hattr.registerAll(u)
                    end
                    -- 物品系统
                    if (his.hasSlot(u)) then
                        hitem.registerAll(u)
                    end
                    -- 触发注册事件(全局)
                    hevent.triggerEvent(
                        "global",
                        CONST_EVENT.register,
                        {
                            triggerUnit = u
                        }
                    )
                end
            end
        )

        -- 计时器
        -- 生命魔法恢复
        htime.setInterval(
            0.50,
            function(t, td)
                local period = cj.TimerGetTimeout(t)
                for k, u in pairs(hRuntime.attributeGroup.life_back) do
                    if (his.alive(u)) then
                        if (hattr.get(u, "life_back") ~= 0) then
                            hunit.addCurLife(u, hattr.get(u, "life_back") * period)
                        end
                    end
                end
                for k, u in pairs(hRuntime.attributeGroup.mana_back) do
                    if (his.alive(u)) then
                        if (hattr.get(u, "mana_back") ~= 0) then
                            hunit.addCurMana(u, hattr.get(u, "mana_back") * period)
                        end
                    end
                end
                --- 源力只有在没受伤判定的情况下才会有效
                for k, u in pairs(hRuntime.attributeGroup.life_source) do
                    if (his.alive(u) and hunit.getCurLifePercent(u) < hplayer.getLifeSourceRatio(cj.GetOwningPlayer(u))) then
                        if (hattr.get(u, "be_hunting") == false) then
                            if (hattr.get(u, "life_source_current") > 0) then
                                local fill = hunit.getMaxLife(u) - hunit.getCurLife(u)
                                if (fill > hattr.get(u, "life_source_current")) then
                                    fill = hattr.get(u, "life_source_current")
                                end
                                hattr.set(u, 0, {life_source_current = "-" .. fill})
                                hunit.addCurLife(u, fill)
                                htextTag.style(
                                    htextTag.create2Unit(u, "命源+" .. fill, 6.00, "bce43a", 10, 1.00, 10.00),
                                    "scale",
                                    0,
                                    0.2
                                )
                            end
                        end
                    end
                end
                for k, u in pairs(hRuntime.attributeGroup.mana_source) do
                    if (his.alive(u) and hunit.getCurManaPercent(u) < hplayer.getManaSourceRatio(cj.GetOwningPlayer(u))) then
                        if (hattr.get(u, "be_hunting") == false) then
                            if (hattr.get(u, "mana_source_current") > 0) then
                                local fill = hunit.getMaxLife(u) - hunit.getCurMana(u)
                                if (fill > hattr.get(u, "mana_source_current")) then
                                    fill = hattr.get(u, "mana_source_current")
                                end
                                hattr.set(u, 0, {mana_source_current = "-" .. fill})
                                hunit.addCurMana(u, fill)
                                htextTag.style(
                                    htextTag.create2Unit(u, "魔源+" .. fill, 6.00, "93d3f1", 10, 1.00, 10.00),
                                    "scale",
                                    0,
                                    0.2
                                )
                            end
                        end
                    end
                end
            end
        )
        -- 硬直恢复(3秒内没收到伤害后,每1秒恢复1%)
        htime.setInterval(
            1.00,
            function(t, td)
                for k, u in pairs(hRuntime.attributeGroup.punish_current) do
                    if
                        (his.alive(u) and hattr.get(u, "punish") > 0 and
                            hattr.get(u, "punish_current") < hattr.get(u, "punish"))
                     then
                        if (hattr.get(u, "be_hunting") == false) then
                            hattr.set(u, 0, {punish_current = "+" .. (hattr.get(u, "punish") * 0.01)})
                        end
                    end
                end
            end
        )
        -- 源恢复
        htime.setInterval(
            15.00,
            function(t, td)
                for k, u in pairs(hRuntime.attributeGroup.life_source) do
                    if (his.alive(u)) then
                        hattr.set(u, 0, {life_source_current = "+100"})
                    end
                end
                for k, u in pairs(hRuntime.attributeGroup.mana_source) do
                    if (his.alive(u)) then
                        hattr.set(u, 0, {mana_source_current = "+100"})
                    end
                end
            end
        )
    end
}

return hLuaStart
