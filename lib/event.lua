local hevent = {}

--set
hevent.set = function(handle, key, value)
    if (handle == nil) then
        print_stack()
        return
    end
    if (hRuntime.event[handle] == nil) then
        hRuntime.event[handle] = {}
    end
    hRuntime.event[handle][key] = value
end

--
hevent.get = function(handle, key)
    if (handle == nil) then
        print_stack()
        return
    end
    if (hRuntime.event[handle] == nil) then
        hRuntime.event[handle] = {}
    end
    return hRuntime.event[handle][key]
end

--set最后一位伤害的单位
hevent.setLastDamageUnit = function(whichUnit, lastUnit)
    if (whichUnit == nil and lastUnit == nil) then
        return
    end
    hevent.set(whichUnit, "lastDamageUnit", lastUnit)
end

--最后一位伤害的单位
hevent.getLastDamageUnit = function(whichUnit)
    hevent.get(whichUnit, "lastDamageUnit")
end

-- 注册事件，会返回一个event_id（私有通用）
hevent.registerEvent = function(handle, key, callFunc)
    if (hRuntime.event.register[handle] == nil) then
        hRuntime.event.register[handle] = {}
    end
    if (hRuntime.event.register[handle][key] == nil) then
        hRuntime.event.register[handle][key] = {}
    end
    table.insert(hRuntime.event.register[handle][key], callFunc)
    return #hRuntime.event.register[handle][key]
end

-- 触发事件（私有通用）
hevent.triggerEvent = function(handle, key, triggerData)
    triggerData = triggerData or {}
    if (hRuntime.event.register[handle] == nil or hRuntime.event.register[handle][key] == nil) then
        print_stack()
        return
    end
    if (#hRuntime.event.register[handle][key] <= 0) then
        return
    end
    --处理数据
    if (table.len(triggerData) > 0) then
        for k, v in pairs(triggerData) do
            if (k == "triggerSkill") then
                triggerData[k] = string.id2char(v)
            elseif (k == "targetLoc") then
                triggerData.targetX = cj.GetLocationX(v)
                triggerData.targetY = cj.GetLocationY(v)
                triggerData.targetZ = cj.GetLocationZ(v)
                cj.RemoveLocation(v)
            end
        end
    end
    for _, callFunc in pairs(hRuntime.event.register[handle][key]) do
        callFunc(triggerData)
    end
end

-- 删除事件（需要event_id）
hevent.deleteEvent = function(handle, key, eventId)
    if (handle == nil or key == nil or eventId == nil) then
        print_stack()
        return
    end
    if (hRuntime.event.register[handle] == nil or hRuntime.event.register[handle][key] == nil) then
        return
    end
    table.remove(hRuntime.event.register[handle], eventId)
end

-- 注意到攻击目标
--triggerUnit 获取触发单位
--targetUnit 获取被注意/目标单位
hevent.onAttackDetect = function(whichUnit, callFunc)
    local key = CONST_EVENT.attackDetect
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = cj.CreateTrigger()
        cj.TriggerAddAction(
            hRuntime.event.trigger[key],
            function()
                hevent.triggerEvent(
                    whichUnit,
                    key,
                    {
                        triggerUnit = cj.GetTriggerUnit(),
                        targetUnit = cj.GetEventTargetUnit()
                    }
                )
            end
        )
    end
    cj.TriggerRegisterUnitEvent(hRuntime.event.trigger[key], whichUnit, EVENT_UNIT_ACQUIRED_TARGET)
    return hevent.registerEvent(whichUnit, key, callFunc)
end

-- 获取攻击目标
--triggerUnit 获取触发单位
--targetUnit 获取被获取/目标单位
hevent.onAttackGetTarget = function(whichUnit, callFunc)
    local key = CONST_EVENT.attackGetTarget
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = cj.CreateTrigger()
        cj.TriggerAddAction(
            hRuntime.event.trigger[key],
            function()
                hevent.triggerEvent(
                    whichUnit,
                    key,
                    {
                        triggerUnit = cj.GetTriggerUnit(),
                        targetUnit = cj.GetEventTargetUnit()
                    }
                )
            end
        )
    end
    cj.TriggerRegisterUnitEvent(hRuntime.event.trigger[key], whichUnit, EVENT_UNIT_TARGET_IN_RANGE)
    return hevent.registerEvent(whichUnit, key, callFunc)
end

-- 准备攻击
--triggerUnit 获取攻击单位
--targetUnit 获取被攻击单位
--attacker 获取攻击单位
hevent.onAttackReadyAction = function(whichUnit, callFunc)
    local key = CONST_EVENT.attackReady
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = cj.CreateTrigger()
        bj.TriggerRegisterAnyUnitEventBJ(hRuntime.event.trigger[key], EVENT_PLAYER_UNIT_ATTACKED)
        cj.TriggerAddAction(
            hRuntime.event.trigger[key],
            function()
                hevent.triggerEvent(
                    whichUnit,
                    key,
                    {
                        triggerUnit = cj.GetAttacker(),
                        targetUnit = cj.GetTriggerUnit(),
                        attacker = cj.GetAttacker()
                    }
                )
            end
        )
    end
    return hevent.registerEvent(whichUnit, key, callFunc)
end

--准备被攻击
--triggerUnit 获取被攻击单位
--targetUnit 获取攻击单位
--attacker 获取攻击单位
hevent.onBeAttackReady = function(whichUnit, callFunc)
    local key = CONST_EVENT.beAttackReady
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = cj.CreateTrigger()
        bj.TriggerRegisterAnyUnitEventBJ(hRuntime.event.trigger[key], EVENT_PLAYER_UNIT_ATTACKED)
        cj.TriggerAddAction(
            hRuntime.event.trigger[key],
            function()
                hevent.triggerEvent(
                    whichUnit,
                    key,
                    {
                        triggerUnit = cj.GetTriggerUnit(),
                        targetUnit = cj.GetAttacker(),
                        attacker = cj.GetAttacker()
                    }
                )
            end
        )
    end
    return hevent.registerEvent(whichUnit, key, callFunc)
end

--造成攻击
--triggerUnit 获取攻击来源
--targetUnit 获取被攻击单位
--attacker 获取攻击来源
--damage 获取初始伤害
--realDamage 获取实际伤害
--damageKind 获取伤害方式
--damageType 获取伤害类型
hevent.onAttack = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.attack, callFunc)
end

--承受攻击
--triggerUnit 获取被攻击单位
--attacker 获取攻击来源
--damage 获取初始伤害
--realDamage 获取实际伤害
--damageKind 获取伤害方式
--damageType 获取伤害类型
hevent.onBeAttack = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beAttack, callFunc)
end

-- 学习技能
--triggerUnit 获取学习单位
--triggerSkill 获取学习技能ID
hevent.onSkillStudy = function(whichUnit, callFunc)
    local key = CONST_EVENT.skillStudy
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = cj.CreateTrigger()
        bj.TriggerRegisterAnyUnitEventBJ(hRuntime.event.trigger[key], EVENT_PLAYER_HERO_SKILL)
        cj.TriggerAddAction(
            hRuntime.event.trigger[key],
            function()
                hevent.triggerEvent(
                    whichUnit,
                    key,
                    {
                        triggerUnit = cj.GetTriggerUnit(),
                        triggerSkill = cj.GetLearnedSkill()
                    }
                )
            end
        )
    end
    return hevent.registerEvent(whichUnit, key, callFunc)
end

-- 准备施放技能
--triggerUnit 获取施放单位
--triggerSkill 获取施放技能ID
--targetUnit 获取目标单位(只对对目标施放有效)
--targetX 获取施放目标点X
--targetY 获取施放目标点Y
--targetZ 获取施放目标点Z
hevent.onSkillReady = function(whichUnit, callFunc)
    local key = CONST_EVENT.skillReady
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = cj.CreateTrigger()
        bj.TriggerRegisterAnyUnitEventBJ(hRuntime.event.trigger[key], EVENT_PLAYER_UNIT_SPELL_CHANNEL)
        cj.TriggerAddAction(
            hRuntime.event.trigger[key],
            function()
                hevent.triggerEvent(
                    whichUnit,
                    key,
                    {
                        triggerUnit = cj.GetTriggerUnit(),
                        triggerSkill = cj.GetSpellAbilityId(),
                        targetUnit = cj.GetSpellTargetUnit(),
                        targetLoc = cj.GetSpellTargetLoc()
                    }
                )
            end
        )
    end
    return hevent.registerEvent(whichUnit, key, callFunc)
end

-- 开始施放技能
--triggerUnit 获取施放单位
--triggerSkill 获取施放技能ID
--targetUnit 获取目标单位(只对对目标施放有效)
--targetX 获取施放目标点X
--targetY 获取施放目标点Y
--targetZ 获取施放目标点Z
hevent.onSkillStart = function(whichUnit, callFunc)
    local key = CONST_EVENT.skillStart
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = cj.CreateTrigger()
        bj.TriggerRegisterAnyUnitEventBJ(hRuntime.event.trigger[key], EVENT_PLAYER_UNIT_SPELL_CAST)
        cj.TriggerAddAction(
            hRuntime.event.trigger[key],
            function()
                hevent.triggerEvent(
                    whichUnit,
                    key,
                    {
                        triggerUnit = cj.GetTriggerUnit(),
                        triggerSkill = string.id2char(cj.GetSpellAbilityId()),
                        targetUnit = cj.GetSpellTargetUnit(),
                        targetLoc = cj.GetSpellTargetLoc()
                    }
                )
            end
        )
    end
    return hevent.registerEvent(whichUnit, key, callFunc)
end

-- 停止施放技能
--triggerUnit 获取施放单位
--triggerSkill 获取施放技能ID
hevent.onSkillStop = function(whichUnit, callFunc)
    local key = CONST_EVENT.skillStop
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = cj.CreateTrigger()
        bj.TriggerRegisterAnyUnitEventBJ(hRuntime.event.trigger[key], EVENT_PLAYER_UNIT_SPELL_ENDCAST)
        cj.TriggerAddAction(
            hRuntime.event.trigger[key],
            function()
                hevent.triggerEvent(
                    whichUnit,
                    key,
                    {
                        triggerUnit = cj.GetTriggerUnit(),
                        triggerSkill = cj.GetSpellAbilityId()
                    }
                )
            end
        )
    end
    return hevent.registerEvent(whichUnit, key, callFunc)
end

-- 发动技能效果
--triggerUnit 获取施放单位
--triggerSkill 获取施放技能ID
--targetUnit 获取目标单位(只对对目标施放有效)
--targetX 获取施放目标点X
--targetY 获取施放目标点Y
--targetZ 获取施放目标点Z
hevent.onSkillHappen = function(whichUnit, callFunc)
    local key = CONST_EVENT.skillHappen
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = cj.CreateTrigger()
        bj.TriggerRegisterAnyUnitEventBJ(hRuntime.event.trigger[key], EVENT_PLAYER_UNIT_SPELL_EFFECT)
        cj.TriggerAddAction(
            hRuntime.event.trigger[key],
            function()
                hevent.triggerEvent(
                    whichUnit,
                    key,
                    {
                        triggerUnit = cj.GetTriggerUnit(),
                        triggerSkill = cj.GetSpellAbilityId(),
                        targetUnit = cj.GetSpellTargetUnit(),
                        targetLoc = cj.GetSpellTargetLoc()
                    }
                )
            end
        )
    end
    return hevent.registerEvent(whichUnit, key, callFunc)
end

--施放技能结束
--triggerUnit 获取施放单位
--triggerSkill 获取施放技能ID
hevent.onSkillOver = function(whichUnit, callFunc)
    local key = CONST_EVENT.skillOver
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = cj.CreateTrigger()
        bj.TriggerRegisterAnyUnitEventBJ(hRuntime.event.trigger[key], EVENT_PLAYER_UNIT_SPELL_FINISH)
        cj.TriggerAddAction(
            hRuntime.event.trigger[key],
            function()
                hevent.triggerEvent(
                    whichUnit,
                    key,
                    {
                        triggerUnit = cj.GetTriggerUnit(),
                        triggerSkill = cj.GetSpellAbilityId()
                    }
                )
            end
        )
    end
    return hevent.registerEvent(whichUnit, key, callFunc)
end

--单位使用物品
--triggerUnit 获取触发单位
--triggerItem 获取触发物品
hevent.onItemUsed = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.itemUsed, callFunc)
end

--出售物品(商店卖给玩家)
--triggerUnit 获取触发单位
--triggerItem 获取触发物品
hevent.onItemSell = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.itemSell, callFunc)
end

--丢弃物品
--triggerUnit 获取触发/出售单位
--targetUnit 获取购买单位
--triggerItem 获取触发/出售物品
hevent.onItemDrop = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.itemDrop, callFunc)
end

--获得物品
--triggerUnit 获取触发单位
--triggerItem 获取触发物品
hevent.onItemGet = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.itemGet, callFunc)
end

--抵押物品（玩家把物品扔给商店）
--triggerUnit 获取触发单位
--triggerItem 获取触发物品
hevent.onItemPawn = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.itemPawn, callFunc)
end

--物品被破坏
--triggerUnit 获取触发单位
--triggerItem 获取触发物品
hevent.onItemDestroy = function(whichItem, callFunc)
    local key = CONST_EVENT.itemDestroy
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = cj.CreateTrigger()
        cj.TriggerAddAction(
            hRuntime.event.trigger[key],
            function()
                hevent.triggerEvent(
                    whichItem,
                    key,
                    {
                        triggerItem = cj.GetManipulatedItem(),
                        triggerUnit = cj.GetKillingUnit()
                    }
                )
            end
        )
    end
    cj.TriggerRegisterDeathEvent(hRuntime.event.trigger[key], whichItem)
    return hevent.registerEvent(whichItem, key, callFunc)
end

--合成物品
--triggerUnit 获取触发单位
--triggerItem 获取合成的物品
hevent.onItemMix = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.itemMix, callFunc)
end

--拆分物品
--triggerUnit 获取触发单位
--id 获取拆分的物品ID
--[[
    type 获取拆分的类型
        simple 单件拆分(同一种物品拆成很多件)
        mixed 合成品拆分(一种物品拆成零件的种类)
]]
hevent.onItemSeparate = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.itemSeparate, callFunc)
end

--物品超重
--triggerUnit 获取触发单位
--triggerItem 获取得到的物品
--value 获取超出的重量
hevent.onItemOverWeight = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.itemOverWeight, callFunc)
end

--单位满格
--triggerUnit 获取触发单位
--triggerItem 获取触发的物品
hevent.onItemOverSlot = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.itemOverSlot, callFunc)
end

--造成伤害
--triggerUnit 获取伤害来源
--targetUnit 获取被伤害单位
--sourceUnit 获取伤害来源
--damage 获取初始伤害
--realDamage 获取实际伤害
--damageKind 获取伤害方式
--damageType 获取伤害类型
hevent.onDamage = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.damage, callFunc)
end

--承受伤害
--triggerUnit 获取被伤害单位
--sourceUnit 获取伤害来源
--damage 获取初始伤害
--realDamage 获取实际伤害
--damageKind 获取伤害方式
--damageType 获取伤害类型
hevent.onBeDamage = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beDamage, callFunc)
end

--回避攻击成功
--triggerUnit 获取触发单位
--attacker 获取攻击单位
hevent.onAvoid = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.avoid, callFunc)
end

--攻击被回避
--triggerUnit 获取攻击单位
--attacker 获取攻击单位
--targetUnit 获取回避的单位
hevent.onBeAvoid = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beAvoid, callFunc)
end

--破防（护甲/魔抗）成功
--breakType 获取无视类型
--triggerUnit 获取触发无视单位
--targetUnit 获取目标单位
--value 获取破护甲的数值
hevent.onBreakArmor = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.breakArmor, callFunc)
end

--被破防（护甲/魔抗）成功
--breakType 获取无视类型
--triggerUnit 获取被破甲单位
--sourceUnit 获取来源单位
--value 获取破护甲的数值
hevent.onBeBreakArmor = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beBreakArmor, callFunc)
end

--眩晕成功
--triggerUnit 获取触发单位
--targetUnit 获取被眩晕单位
--percent 获取眩晕几率百分比
--during 获取眩晕时间（秒）
--damage 获取眩晕伤害
hevent.onSwim = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.swim, callFunc)
end

--被眩晕
--triggerUnit 获取被眩晕单位
--sourceUnit 获取来源单位
--percent 获取眩晕几率百分比
--during 获取眩晕时间（秒）
--damage 获取眩晕伤害
hevent.onBeSwim = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beSwim, callFunc)
end

--打断成功
--triggerUnit 获取触发单位
--targetUnit 获取被打断单位
--damage 获取打断伤害
hevent.onBroken = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.broken, callFunc)
end

--被打断
--triggerUnit 获取被打断单位
--sourceUnit 获取来源单位
--damage 获取打断伤害
hevent.onBeBroken = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beBroken, callFunc)
end

--沉默成功
--triggerUnit 获取触发单位
--targetUnit 获取被沉默单位
--during 获取沉默时间（秒）
--damage 获取沉默伤害
hevent.onSilent = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.silent, callFunc)
end

--被沉默
--triggerUnit 获取被沉默单位
--sourceUnit 获取来源单位
--during 获取沉默时间（秒）
--damage 获取沉默伤害
hevent.onBeSilent = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beSilent, callFunc)
end

--缴械成功
--triggerUnit 获取触发单位
--targetUnit 获取被缴械单位
--during 获取缴械时间（秒）
--damage 获取缴械伤害
hevent.onUnarm = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.unarm, callFunc)
end

--被缴械
--triggerUnit 获取被缴械单位
--sourceUnit 获取来源单位
--during 获取缴械时间（秒）
--damage 获取缴械伤害
hevent.onBeUnarm = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beUnarm, callFunc)
end

--缚足成功
--triggerUnit 获取触发单位
--targetUnit 获取被缚足单位
--during 获取缚足时间（秒）
--damage 获取缚足伤害
hevent.onFetter = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.fetter, callFunc)
end

--被缚足
--triggerUnit 获取被缚足单位
--sourceUnit 获取来源单位
--during 获取缚足时间（秒）
--damage 获取缚足伤害
hevent.onBeFetter = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beFetter, callFunc)
end

--爆破成功
--triggerUnit 获取触发单位
--targetUnit 获取被爆破单位
--damage 获取爆破伤害
--range 获取爆破范围
hevent.onBomb = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.bomb, callFunc)
end

--被爆破
--triggerUnit 获取被爆破单位
--sourceUnit 获取来源单位
--damage 获取爆破伤害
--range 获取爆破范围
hevent.onBeBomb = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beBomb, callFunc)
end

--闪电链成功
--triggerUnit 获取触发单位
--targetUnit 获取被闪电链单位
--damage 获取闪电链伤害
--range 获取闪电链范围
--index 获取单位是第几个被电到的
hevent.onLightningChain = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.lightningChain, callFunc)
end

--被闪电链
--triggerUnit 获取被闪电链单位
--sourceUnit 获取来源单位
--damage 获取闪电链伤害
--range 获取闪电链范围
--index 获取单位是第几个被电到的
hevent.onBeLightningChain = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beLightningChain, callFunc)
end

--击飞成功
--triggerUnit 获取触发单位
--targetUnit 获取被击飞单位
--damage 获取击飞伤害
--high 获取击飞高度
--distance 获取击飞距离
hevent.onCrackFly = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.crackFly, callFunc)
end

--被击飞
--triggerUnit 获取被击飞单位
--sourceUnit 获取来源单位
--damage 获取击飞伤害
--high 获取击飞高度
--distance 获取击飞距离
hevent.onBeCrackFly = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beCrackFly, callFunc)
end

--反伤时
--triggerUnit 获取触发单位
--sourceUnit 获取来源单位
--damage 获取反伤伤害
hevent.onRebound = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.rebound, callFunc)
end

--造成无法回避的伤害时
--triggerUnit 获取触发单位
--targetUnit 获取目标单位
--damage 获取伤害值
hevent.onNoAvoid = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.noAvoid, callFunc)
end

--被造成无法回避的伤害时
--triggerUnit 获取触发单位
--sourceUnit 获取来源单位
--damage 获取伤害值
hevent.onBeNoAvoid = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beNoAvoid, callFunc)
end

--物理暴击时
--triggerUnit 获取触发单位
--targetUnit 获取目标单位
--damage 获取暴击伤害值
--value 获取暴击几率百分比
--percent 获取暴击增幅百分比
hevent.onKnocking = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.knocking, callFunc)
end

--承受物理暴击时
--triggerUnit 获取触发单位
--sourceUnit 获取来源单位
--damage 获取暴击伤害值
--value 获取暴击几率百分比
--percent 获取暴击增幅百分比
hevent.onBeKnocking = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beKnocking, callFunc)
end

--魔法暴击时
--triggerUnit 获取触发单位
--targetUnit 获取目标单位
--damage 获取暴击伤害值
--value 获取暴击几率百分比
--percent 获取暴击增幅百分比
hevent.onViolence = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.violence, callFunc)
end

--承受魔法暴击时
--triggerUnit 获取触发单位
--sourceUnit 获取来源单位
--damage 获取暴击伤害值
--value 获取暴击几率百分比
--percent 获取暴击增幅百分比
hevent.onBeViolence = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beViolence, callFunc)
end

--分裂时
--triggerUnit 获取触发单位
--targetUnit 获取目标单位
--damage 获取分裂伤害值
--range 获取分裂范围(px)
--percent 获取分裂百分比
hevent.onSpilt = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.spilt, callFunc)
end

--承受分裂时
--triggerUnit 获取触发单位
--sourceUnit 获取来源单位
--damage 获取分裂伤害值
--range 获取分裂范围(px)
--percent 获取分裂百分比
hevent.onBeSpilt = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beSpilt, callFunc)
end

--极限减伤抵抗（减伤不足以抵扣）
--triggerUnit 获取触发单位
--sourceUnit 获取来源单位
hevent.onLimitToughness = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.limitToughness, callFunc)
end

--吸血时
--triggerUnit 获取触发单位
--targetUnit 获取目标单位
--damage 获取吸血值
--percent 获取吸血百分比
hevent.onHemophagia = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.hemophagia, callFunc)
end

--被吸血时
--triggerUnit 获取触发单位
--sourceUnit 获取来源单位
--damage 获取吸血值
--percent 获取吸血百分比
hevent.onBeHemophagia = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beHemophagia, callFunc)
end

--技能吸血时
--triggerUnit 获取触发单位
--targetUnit 获取目标单位
--damage 获取吸血值
--percent 获取吸血百分比
hevent.onSkillHemophagia = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.skillHemophagia, callFunc)
end

--被技能吸血时
--triggerUnit 获取触发单位
--sourceUnit 获取来源单位
--damage 获取吸血值
--percent 获取吸血百分比
hevent.onBeSkillHemophagia = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beSkillHemophagia, callFunc)
end

--硬直时
--triggerUnit 获取触发单位
--sourceUnit 获取来源单位
--percent 获取硬直程度百分比
--during 获取持续时间
hevent.onPunish = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, ONST_EVENT.punish, callFunc)
end

--死亡时
--triggerUnit 获取触发单位
--Killer 获取凶手单位
hevent.onDead = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.dead, callFunc)
end

--击杀时
--triggerUnit 获取触发单位
--Killer 获取凶手单位
--targetUnit 获取死亡单位
hevent.onKill = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.kill, callFunc)
end

--triggerUnit 获取触发单位
--- 复活时(必须使用 hunit.reborn 方法才能嵌入到事件系统)
hevent.onReborn = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.reborn, callFunc)
end

--提升升等级时
--triggerUnit 获取触发单位
--value 获取提升了多少级
hevent.onLevelUp = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.levelUp, callFunc)
end

--被召唤时
--triggerUnit 获取被召唤单位
hevent.onSummon = function(whichUnit, callFunc)
    local key = CONST_EVENT.summon
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = cj.CreateTrigger()
        bj.TriggerRegisterAnyUnitEventBJ(hRuntime.event.trigger[key], EVENT_PLAYER_UNIT_SUMMON)
        cj.TriggerAddAction(
            hRuntime.event.trigger[key],
            function()
                hevent.triggerEvent(
                    whichUnit,
                    key,
                    {
                        triggerUnit = cj.GetTriggerUnit()
                    }
                )
            end
        )
    end
    return hevent.registerEvent(whichUnit, key, callFunc)
end

--进入某单位（whichUnit）范围内
--centerUnit 被进入范围的中心单位
--triggerUnit 进入范围的单位
--enterUnit 进入范围的单位
--range 设定范围
hevent.onEnterUnitRange = function(whichUnit, range, callFunc)
    local key = CONST_EVENT.enterUnitRange .. "#range"
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = {}
    end
    if (hRuntime.event.trigger[key][whichUnit] == nil) then
        hRuntime.event.trigger[key][whichUnit] = cj.CreateTrigger()
        cj.TriggerRegisterUnitInRangeSimple(hRuntime.event.trigger[key][whichUnit], range, whichUnit)
        cj.TriggerAddAction(
            hRuntime.event.trigger[key][whichUnit],
            function()
                hevent.triggerEvent(
                    whichUnit,
                    key,
                    {
                        centerUnit = whichUnit,
                        triggerUnit = cj.GetTriggerUnit(),
                        enterUnit = cj.GetTriggerUnit(),
                        range = range
                    }
                )
            end
        )
    end
    return hevent.registerEvent(whichUnit, key, callFunc)
end

--进入某区域
--triggerRect 获取被进入的矩形区域
--triggerUnit 获取进入矩形区域的单位
hevent.onEnterRect = function(whichRect, callFunc)
    local key = CONST_EVENT.enterRect
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = {}
    end
    if (hRuntime.event.trigger[key][whichRect] == nil) then
        hRuntime.event.trigger[key][whichRect] = cj.CreateTrigger()
        local rectRegion = cj.CreateRegion()
        cj.RegionAddRect(rectRegion, r)
        cj.TriggerRegisterEnterRegion(hRuntime.event.trigger[key][whichRect], rectRegion, nil)
        cj.TriggerAddAction(
            tg,
            function()
                hevent.triggerEvent(
                    whichRect,
                    key,
                    {
                        triggerRect = whichRect,
                        triggerUnit = cj.GetTriggerUnit()
                    }
                )
            end
        )
    end
    return hevent.registerEvent(whichRect, key, callFunc)
end

--离开某区域
--triggerRect 获取被离开的矩形区域
--triggerUnit 获取离开矩形区域的单位
hevent.onLeaveRect = function(whichRect, callFunc)
    local key = CONST_EVENT.leaveRect
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = {}
    end
    if (hRuntime.event.trigger[key][whichRect] == nil) then
        hRuntime.event.trigger[key][whichRect] = cj.CreateTrigger()
        local rectRegion = cj.CreateRegion()
        cj.RegionAddRect(rectRegion, r)
        cj.TriggerRegisterLeaveRegion(hRuntime.event.trigger[key][whichRect], rectRegion, nil)
        cj.TriggerAddAction(
            tg,
            function()
                hevent.triggerEvent(
                    whichRect,
                    key,
                    {
                        triggerRect = whichRect,
                        triggerUnit = cj.GetTriggerUnit()
                    }
                )
            end
        )
    end
    return hevent.registerEvent(whichRect, key, callFunc)
end

--当聊天时
--params matchAll 是否全匹配，false为like
--triggerPlayer 获取聊天的玩家
--chatString 获取聊天的内容
--matchedString 获取匹配命中的内容
hevent.onChat = function(whichPlayer, chatStr, matchAll, callFunc)
    if (whichPlayer == nil or chatStr == nil) then
        return
    end
    local key = CONST_EVENT.chat
    local tg = cj.CreateTrigger()
    cj.TriggerRegisterPlayerChatEvent(tg, whichPlayer, chatStr, matchAll)
    cj.TriggerAddAction(
        tg,
        function()
            callFunc(
                {
                    triggerPlayer = cj.GetTriggerPlayer(),
                    chatString = cj.GetEventPlayerChatString(),
                    matchedString = cj.GetEventPlayerChatStringMatched()
                }
            )
        end
    )
end

--按ESC
--triggerPlayer 获取触发玩家
hevent.onEsc = function(whichPlayer, callFunc)
    local key = CONST_EVENT.esc
    if (whichPlayer == nil) then
        return
    end
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = {}
    end
    if (hRuntime.event.trigger[key][whichPlayer] == nil) then
        hRuntime.event.trigger[key][whichPlayer] = cj.CreateTrigger()
        cj.TriggerRegisterPlayerEventEndCinematic(hRuntime.event.trigger[key][whichPlayer], whichPlayer)
        cj.TriggerAddAction(
            hRuntime.event.trigger[key][whichPlayer],
            function()
                hevent.triggerEvent(
                    whichPlayer,
                    key,
                    {
                        triggerPlayer = cj.GetTriggerPlayer()
                    }
                )
            end
        )
    end
    return hevent.registerEvent(whichPlayer, key, callFunc)
end

--玩家选择单位(点击了qty次)
--triggerPlayer 获取触发玩家
--triggerUnit 获取触发单位
hevent.onSelection = function(whichPlayer, qty, callFunc)
    if (whichPlayer == nil or qty == nil or qty <= 0) then
        return
    end
    local key = CONST_EVENT.selection .. "#" .. qty
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = {}
    end
    if (hRuntime.event.trigger[key][whichPlayer] == nil) then
        hRuntime.event.trigger[key].click = 0
        hRuntime.event.trigger[key][whichPlayer] = cj.CreateTrigger()
        bj.TriggerRegisterPlayerSelectionEventBJ(hRuntime.event.trigger[key][whichPlayer], whichPlayer, true)
        cj.TriggerAddAction(
            hRuntime.event.trigger[key][whichPlayer],
            function()
                local triggerPlayer = cj.GetTriggerPlayer()
                local triggerUnit = cj.GetTriggerUnit()
                hRuntime.event.trigger[key].click = hRuntime.event.trigger[key].click + 1
                htime.setTimeout(
                    0.3,
                    function(t, td)
                        htime.delDialog(td)
                        htime.delTimer(t)
                        hRuntime.event.trigger[key].click = hRuntime.event.trigger[key].click - 1
                    end
                )
                if (hRuntime.event.trigger[key].click >= qty) then
                    hevent.triggerEvent(
                        whichPlayer,
                        key,
                        {
                            triggerPlayer = triggerPlayer,
                            triggerUnit = triggerUnit,
                            qty = qty
                        }
                    )
                end
            end
        )
    end
    return hevent.registerEvent(whichPlayer, key, callFunc)
end

--玩家取消选择单位
--triggerPlayer 获取触发玩家
--triggerUnit 获取触发单位
hevent.onUnSelection = function(whichPlayer, callFunc)
    if (whichPlayer == nil) then
        return
    end
    local key = CONST_EVENT.unSelection
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = {}
    end
    if (hRuntime.event.trigger[key][whichPlayer] == nil) then
        hRuntime.event.trigger[key][whichPlayer] = cj.CreateTrigger()
        bj.TriggerRegisterPlayerSelectionEventBJ(hRuntime.event.trigger[key][whichPlayer], whichPlayer, false)
        cj.TriggerAddAction(
            hRuntime.event.trigger[key][whichPlayer],
            function()
                hevent.triggerEvent(
                    whichPlayer,
                    key,
                    {
                        triggerPlayer = cj.GetTriggerPlayer(),
                        triggerUnit = cj.GetTriggerUnit()
                    }
                )
            end
        )
    end
    return hevent.registerEvent(whichPlayer, key, callFunc)
end

--建筑升级开始时
--triggerUnit 获取触发单位
hevent.onUpgradeStart = function(whichUnit, callFunc)
    local key = CONST_EVENT.upgradeStart
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = cj.CreateTrigger()
        cj.TriggerAddAction(
            hRuntime.event.trigger[key],
            function()
                hevent.triggerEvent(
                    whichUnit,
                    key,
                    {
                        triggerUnit = cj.GetTriggerUnit()
                    }
                )
            end
        )
    end
    cj.TriggerRegisterUnitEvent(hRuntime.event.trigger[key], whichUnit, EVENT_UNIT_UPGRADE_START)
    return hevent.registerEvent(whichUnit, key, callFunc)
end

--建筑升级取消时
--triggerUnit 获取触发单位
hevent.onUpgradeCancel = function(whichUnit, callFunc)
    local key = CONST_EVENT.upgradeCancel
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = cj.CreateTrigger()
        cj.TriggerAddAction(
            hRuntime.event.trigger[key],
            function()
                hevent.triggerEvent(
                    whichUnit,
                    key,
                    {
                        triggerUnit = cj.GetTriggerUnit()
                    }
                )
            end
        )
    end
    cj.TriggerRegisterUnitEvent(hRuntime.event.trigger[key], whichUnit, EVENT_UNIT_UPGRADE_CANCEL)
    return hevent.registerEvent(whichUnit, key, callFunc)
end

--建筑升级完成时
--triggerUnit 获取触发单位
hevent.onUpgradeFinish = function(whichUnit, callFunc)
    local key = CONST_EVENT.upgradeFinish
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = cj.CreateTrigger()
        cj.TriggerAddAction(
            hRuntime.event.trigger[key],
            function()
                hevent.triggerEvent(
                    whichUnit,
                    key,
                    {
                        triggerUnit = cj.GetTriggerUnit()
                    }
                )
            end
        )
    end
    cj.TriggerRegisterUnitEvent(hRuntime.event.trigger[key], whichUnit, EVENT_UNIT_UPGRADE_FINISH)
    return hevent.registerEvent(whichUnit, key, callFunc)
end

--任意建筑建造开始时
--triggerUnit 获取触发单位
hevent.onConstructStart = function(whichPlayer, callFunc)
    if (whichPlayer == nil) then
        return
    end
    local key = CONST_EVENT.constructStart
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = cj.CreateTrigger()
        cj.TriggerAddAction(
            hRuntime.event.trigger[key],
            function()
                hevent.triggerEvent(
                    whichPlayer,
                    key,
                    {
                        triggerKey = key,
                        triggerUnit = cj.GetTriggerUnit()
                    }
                )
            end
        )
    end
    cj.TriggerRegisterPlayerUnitEvent(hRuntime.event.trigger[key], whichPlayer, EVENT_PLAYER_UNIT_CONSTRUCT_START, nil)
    return hevent.registerEvent(whichPlayer, key, whichPlayer, callFunc)
end

--任意建筑建造取消时
--triggerUnit 获取触发单位
hevent.onConstructCancel = function(whichPlayer, callFunc)
    if (whichPlayer == nil) then
        return
    end
    local key = CONST_EVENT.constructCancel
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = cj.CreateTrigger()
        cj.TriggerAddAction(
            hRuntime.event.trigger[key],
            function()
                hevent.triggerEvent(
                    whichPlayer,
                    key,
                    {
                        triggerUnit = cj.GetCancelledStructure()
                    }
                )
            end
        )
    end
    cj.TriggerRegisterPlayerUnitEvent(hRuntime.event.trigger[key], whichPlayer, EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL, nil)
    return hevent.registerEvent(whichPlayer, key, callFunc)
end

--任意建筑建造完成时
--triggerUnit 获取触发单位
hevent.onConstructFinish = function(whichPlayer, callFunc)
    if (whichPlayer == nil) then
        return
    end
    local key = CONST_EVENT.constructFinish
    if (hRuntime.event.trigger[key] == nil) then
        hRuntime.event.trigger[key] = cj.CreateTrigger()
        cj.TriggerAddAction(
            hRuntime.event.trigger[key],
            function()
                hevent.triggerEvent(
                    whichPlayer,
                    key,
                    {
                        triggerUnit = cj.GetConstructedStructure()
                    }
                )
            end
        )
    end
    cj.TriggerRegisterPlayerUnitEvent(hRuntime.event.trigger[key], whichPlayer, EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL, nil)
    return hevent.registerEvent(whichPlayer, key, callFunc)
end

--任意单位注册进h-lua系统时(注意这是全局事件)
--triggerUnit 获取触发单位
hevent.onRegister = function(callFunc)
    return hevent.registerEvent("global", CONST_EVENT.register, callFunc)
end

--任意单位经过hero方法被玩家所挑选为英雄时(注意这是全局事件)
--triggerPlayer 获取触发玩家
--triggerUnit 获取触发单位
hevent.onPickHero = function(callFunc)
    return hevent.onEventByHandle("global", CONST_EVENT.pickHero, callFunc)
end

return hevent
