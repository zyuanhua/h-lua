hevent = {
    POOL = {},
    POOL_RED_LINE = 3000,
}

--- set
---@private
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

--- get
---@private
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

--- 触发池
--- 使用一个handle，以不同的conditionAction累计计数
--- 分配触发到回调注册
---@protected
hevent.pool = function(handle, conditionAction, regEvent)
    if (type(regEvent) ~= 'function') then
        return
    end
    local key = cj.GetHandleId(conditionAction)
    if (hevent.POOL[key] == nil) then
        hevent.POOL[key] = {}
    end
    local poolIndex = #hevent.POOL[key]
    if (poolIndex <= 0 or hevent.POOL[key][poolIndex].count >= hevent.POOL_RED_LINE) then
        local tgr = cj.CreateTrigger()
        table.insert(hevent.POOL[key], {
            stock = 0,
            count = 0,
            trigger = tgr
        })
        cj.TriggerAddCondition(tgr, conditionAction)
        poolIndex = #hevent.POOL[key]
    end
    if (hRuntime.event.pool[handle] == nil) then
        hRuntime.event.pool[handle] = {}
    end
    table.insert(hRuntime.event.pool[handle], {
        key = key,
        poolIndex = poolIndex,
    })
    hevent.POOL[key][poolIndex].count = hevent.POOL[key][poolIndex].count + 1
    hevent.POOL[key][poolIndex].stock = hevent.POOL[key][poolIndex].stock + 1
    regEvent(hevent.POOL[key][poolIndex].trigger)
end

--- set最后一位伤害的单位
---@protected
hevent.setLastDamageUnit = function(whichUnit, lastUnit)
    if (whichUnit == nil and lastUnit == nil) then
        return
    end
    hevent.set(whichUnit, "lastDamageUnit", lastUnit)
end

--- 最后一位伤害的单位
---@protected
hevent.getLastDamageUnit = function(whichUnit)
    return hevent.get(whichUnit, "lastDamageUnit")
end

--- 注册事件，会返回一个event_id（私有通用）
---@protected
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

--- 触发事件（私有通用）
---@protected
hevent.triggerEvent = function(handle, key, triggerData)
    triggerData = triggerData or {}
    if (hRuntime.event.register[handle] == nil or hRuntime.event.register[handle][key] == nil) then
        return
    end
    if (#hRuntime.event.register[handle][key] <= 0) then
        return
    end
    -- 处理数据
    if (triggerData.triggerSkill ~= nil and type(triggerData.triggerSkill) == "number") then
        triggerData.triggerSkill = string.id2char(triggerData.triggerSkill)
    end
    if (triggerData.targetLoc ~= nil) then
        triggerData.targetX = cj.GetLocationX(triggerData.targetLoc)
        triggerData.targetY = cj.GetLocationY(triggerData.targetLoc)
        triggerData.targetZ = cj.GetLocationZ(triggerData.targetLoc)
        cj.RemoveLocation(triggerData.targetLoc)
        triggerData.targetLoc = nil
    end
    for _, callFunc in ipairs(hRuntime.event.register[handle][key]) do
        callFunc(triggerData)
    end
end

--- 删除事件（需要event_id）
---@param handle userdata
---@param key string
---@param eventId any
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

--- 注意到攻击目标
---@alias EvtData {triggerUnit:"触发单位",targetUnit:"目标单位"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onAttackDetect = function(whichUnit, callFunc)
    hevent.pool(whichUnit, hevent_default_actions.unit.attackDetect, function(tgr)
        cj.TriggerRegisterUnitEvent(tgr, whichUnit, EVENT_UNIT_ACQUIRED_TARGET)
    end)
    return hevent.registerEvent(whichUnit, CONST_EVENT.attackDetect, callFunc)
end

--- 获取攻击目标
---@alias EvtData {triggerUnit:"触发单位",targetUnit:"目标单位"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onAttackGetTarget = function(whichUnit, callFunc)
    hevent.pool(whichUnit, hevent_default_actions.unit.attackGetTarget, function(tgr)
        cj.TriggerRegisterUnitEvent(tgr, whichUnit, EVENT_UNIT_TARGET_IN_RANGE)
    end)
    return hevent.registerEvent(whichUnit, CONST_EVENT.attackGetTarget, callFunc)
end

--- 准备被攻击
---@alias EvtData {triggerUnit:"被攻击单位",targetUnit:"攻击单位",attacker:"攻击单位"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onBeAttackReady = function(whichUnit, callFunc)
    hevent.pool(whichUnit, hevent_default_actions.unit.beAttackReady, function(tgr)
        cj.TriggerRegisterUnitEvent(tgr, whichUnit, EVENT_UNIT_ATTACKED)
    end)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beAttackReady, callFunc)
end

--- 造成攻击
---@alias EvtData {triggerUnit:"攻击单位",targetUnit:"被攻击单位",attacker:"攻击单位",damage:"伤害",damageKind:"伤害方式",damageType:"伤害类型"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onAttack = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.attack, callFunc)
end

--- 承受攻击
---@alias EvtData {triggerUnit:"被攻击单位",attacker:"攻击来源",damage:"伤害",damageKind:"伤害方式",damageType:"伤害类型"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onBeAttack = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beAttack, callFunc)
end

--- 学习技能
---@alias EvtData {triggerUnit:"学习单位",triggerSkill:"学习技能ID字符串"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onSkillStudy = function(whichUnit, callFunc)
    hevent.pool(whichUnit, hevent_default_actions.unit.skillStudy, function(tgr)
        cj.TriggerRegisterUnitEvent(tgr, whichUnit, EVENT_UNIT_HERO_SKILL)
    end)
    return hevent.registerEvent(whichUnit, CONST_EVENT.skillStudy, callFunc)
end

--- 准备施放技能
---@alias EvtData {triggerUnit:"施放单位",triggerSkill:"施放技能ID字符串",targetUnit:"获取目标单位",targetX:"获取施放目标点X",targetY:"获取施放目标点Y",targetZ:"获取施放目标点Z"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onSkillReady = function(whichUnit, callFunc)
    hevent.pool(whichUnit, hevent_default_actions.unit.skillReady, function(tgr)
        cj.TriggerRegisterUnitEvent(tgr, whichUnit, EVENT_UNIT_SPELL_CHANNEL)
    end)
    return hevent.registerEvent(whichUnit, CONST_EVENT.skillReady, callFunc)
end

--- 开始施放技能
---@alias EvtData {triggerUnit:"施放单位",triggerSkill:"施放技能ID字符串",targetUnit:"获取目标单位",targetX:"获取施放目标点X",targetY:"获取施放目标点Y",targetZ:"获取施放目标点Z"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onSkillCast = function(whichUnit, callFunc)
    hevent.pool(whichUnit, hevent_default_actions.unit.skillCast, function(tgr)
        cj.TriggerRegisterUnitEvent(tgr, whichUnit, EVENT_UNIT_SPELL_CAST)
    end)
    return hevent.registerEvent(whichUnit, CONST_EVENT.skillCast, callFunc)
end

--- 停止施放技能
---@alias EvtData {triggerUnit:"施放单位",triggerSkill:"施放技能ID字符串"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onSkillStop = function(whichUnit, callFunc)
    hevent.pool(whichUnit, hevent_default_actions.unit.skillStop, function(tgr)
        cj.TriggerRegisterUnitEvent(tgr, whichUnit, EVENT_UNIT_SPELL_ENDCAST)
    end)
    return hevent.registerEvent(whichUnit, CONST_EVENT.skillStop, callFunc)
end

--- 发动技能效果
---@alias EvtData {triggerUnit:"施放单位",triggerSkill:"施放技能ID字符串",targetUnit:"获取目标单位",targetX:"获取施放目标点X",targetY:"获取施放目标点Y",targetZ:"获取施放目标点Z"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onSkillEffect = function(whichUnit, callFunc)
    hevent.pool(whichUnit, hevent_default_actions.unit.skillEffect, function(tgr)
        cj.TriggerRegisterUnitEvent(tgr, whichUnit, EVENT_UNIT_SPELL_EFFECT)
    end)
    return hevent.registerEvent(whichUnit, CONST_EVENT.skillEffect, callFunc)
end

--- 施放技能结束
---@alias EvtData {triggerUnit:"施放单位",triggerSkill:"施放技能ID字符串"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onSkillFinish = function(whichUnit, callFunc)
    hevent.pool(whichUnit, hevent_default_actions.unit.skillFinish, function(tgr)
        cj.TriggerRegisterUnitEvent(tgr, whichUnit, EVENT_UNIT_SPELL_FINISH)
    end)
    return hevent.registerEvent(whichUnit, CONST_EVENT.skillFinish, callFunc)
end

--- 单位使用物品
---@alias EvtData {triggerUnit:"触发单位",triggerItem:"触发物品"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onItemUsed = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.itemUsed, callFunc)
end

--- 出售物品(商店卖给玩家)
---@alias EvtData {triggerUnit:"触发单位",triggerItem:"触发物品"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onItemSell = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.itemSell, callFunc)
end

--- 丢弃(传递)物品
---@alias EvtData {triggerUnit:"丢弃单位",targetUnit:"获得单位（如果有）",triggerItem:"触发物品"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onItemDrop = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.itemDrop, callFunc)
end

--- 获得物品
---@alias EvtData {triggerUnit:"触发单位",triggerItem:"触发物品"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onItemGet = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.itemGet, callFunc)
end

--- 抵押物品（玩家把物品扔给商店）
---@alias EvtData {triggerUnit:"触发单位",triggerItem:"触发物品"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onItemPawn = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.itemPawn, callFunc)
end

--- 物品被破坏
---@alias EvtData {triggerUnit:"触发单位",triggerItem:"触发物品"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onItemDestroy = function(whichItem, callFunc)
    hevent.pool(whichItem, hevent_default_actions.item.destroy, function(tgr)
        cj.TriggerRegisterDeathEvent(tgr, whichItem)
    end)
    return hevent.registerEvent(whichItem, CONST_EVENT.itemDestroy, callFunc)
end

--- 合成物品
---@alias EvtData {triggerUnit:"触发单位",triggerItem:"合成物品"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onItemMixed = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.itemMixed, callFunc)
end

--- 拆分物品
---@alias EvtData {triggerUnit:"触发单位",triggerItemId:"被拆分物品ID字符串",type:"拆分的类型:simple(多次数)|mixed(合成物)"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onItemSeparate = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.itemSeparate, callFunc)
end

--- 物品超重
---@alias EvtData {triggerUnit:"触发单位",triggerItem:"得到的物品",value:"超出的重量(kg)"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onItemOverWeight = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.itemOverWeight, callFunc)
end

--- 单位满格
---@alias EvtData {triggerUnit:"触发单位",triggerItem:"触发的物品"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onItemOverSlot = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.itemOverSlot, callFunc)
end

--- 造成伤害
---@alias EvtData {triggerUnit:"伤害来源",targetUnit:"被伤害单位",sourceUnit:"伤害来源",damage:"伤害",damageKind:"伤害方式",damageType:"伤害类型"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onDamage = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.damage, callFunc)
end

--- 承受伤害
---@alias EvtData {triggerUnit:"被伤害单位",sourceUnit:"伤害来源",damage:"伤害",damageKind:"伤害方式",damageType:"伤害类型"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onBeDamage = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beDamage, callFunc)
end

--- 回避攻击成功
---@alias EvtData {triggerUnit:"触发单位",attacker:"攻击单位"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onAvoid = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.avoid, callFunc)
end

--- 攻击被回避
---@alias EvtData {triggerUnit:"攻击单位",attacker:"攻击单位",targetUnit:"回避的单位"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onBeAvoid = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beAvoid, callFunc)
end

--- 破防（护甲/魔抗）成功
---@alias EvtData {breakType:"无视类型",triggerUnit:"触发无视单位",targetUnit:"目标单位",value:"破防的数值"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onBreakArmor = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.breakArmor, callFunc)
end

--- 被破防（护甲/魔抗）成功
---@alias EvtData {breakType:"无视类型",triggerUnit:"被破甲单位",sourceUnit:"来源单位",value:"破防的数值"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onBeBreakArmor = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beBreakArmor, callFunc)
end

--- 眩晕成功
---@alias EvtData {triggerUnit:"触发单位",targetUnit:"被眩晕单位",odds:"几率百分比",during:"持续时间（秒）",damage:"伤害"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onSwim = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.swim, callFunc)
end

--- 被眩晕
---@alias EvtData {triggerUnit:"触发单位",sourceUnit:"来源单位",odds:"几率百分比",during:"持续时间（秒）",damage:"伤害"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onBeSwim = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beSwim, callFunc)
end

--- 打断成功
---@alias EvtData {triggerUnit:"触发单位",targetUnit:"被打断单位",odds:"几率百分比",damage:"伤害"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onBroken = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.broken, callFunc)
end

--- 被打断
---@alias EvtData {triggerUnit:"触发单位",sourceUnit:"来源单位",odds:"几率百分比",damage:"伤害"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onBeBroken = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beBroken, callFunc)
end

--- 沉默成功
---@alias EvtData {triggerUnit:"触发单位",targetUnit:"被沉默单位",odds:"几率百分比",during:"持续时间（秒）",damage:"伤害"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onSilent = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.silent, callFunc)
end

--- 被沉默
---@alias EvtData {triggerUnit:"触发单位",sourceUnit:"来源单位",odds:"几率百分比",during:"持续时间（秒）",damage:"伤害"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onBeSilent = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beSilent, callFunc)
end

--- 缴械成功
---@alias EvtData {triggerUnit:"触发单位",targetUnit:"被缴械单位",odds:"几率百分比",during:"持续时间（秒）",damage:"伤害"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onUnarm = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.unarm, callFunc)
end

--- 被缴械
---@alias EvtData {triggerUnit:"触发单位",sourceUnit:"来源单位",odds:"几率百分比",during:"持续时间（秒）",damage:"伤害"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onBeUnarm = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beUnarm, callFunc)
end

--- 缚足成功
---@alias EvtData {triggerUnit:"触发单位",targetUnit:"被缚足单位",odds:"几率百分比",during:"持续时间（秒）",damage:"伤害"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onFetter = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.fetter, callFunc)
end

--- 被缚足
---@alias EvtData {triggerUnit:"触发单位",sourceUnit:"来源单位",odds:"几率百分比",during:"持续时间（秒）",damage:"伤害"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onBeFetter = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beFetter, callFunc)
end

--- 爆破成功
---@alias EvtData {triggerUnit:"触发单位",targetUnit:"被爆破单位",odds:"几率百分比",range:"爆破范围",damage:"伤害"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onBomb = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.bomb, callFunc)
end

--- 被爆破
---@alias EvtData {triggerUnit:"触发单位",sourceUnit:"来源单位",odds:"几率百分比",range:"爆破范围",damage:"伤害"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onBeBomb = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beBomb, callFunc)
end

--- 闪电链成功
---@alias EvtData {triggerUnit:"触发单位",targetUnit:"被闪电链单位",odds:"几率百分比",range:"闪电链范围",damage:"伤害",index:"是第几个被电到的"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onLightningChain = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.lightningChain, callFunc)
end

--- 被闪电链
---@alias EvtData {triggerUnit:"触发单位",targetUnit:"来源单位",odds:"几率百分比",range:"闪电链范围",damage:"伤害",index:"是第几个被电到的"}
---@alias Func fun(evtData: EvtData):void
---@param whichUnit userdata
---@param callFunc Func | "function(evtData) end"
---@return any
hevent.onBeLightningChain = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beLightningChain, callFunc)
end

--- 击飞成功
--- triggerUnit 获取触发单位
--- targetUnit 获取被击飞单位
--- odds 获取几率百分比
--- damage 获取击飞伤害
--- high 获取击飞高度
--- distance 获取击飞距离
hevent.onCrackFly = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.crackFly, callFunc)
end

--- 被击飞
--- triggerUnit 获取被击飞单位
--- sourceUnit 获取来源单位
--- odds 获取几率百分比
--- damage 获取击飞伤害
--- high 获取击飞高度
--- distance 获取击飞距离
hevent.onBeCrackFly = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beCrackFly, callFunc)
end

--- 反伤时
--- triggerUnit 获取触发单位
--- sourceUnit 获取来源单位
--- damage 获取反伤伤害
hevent.onRebound = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.rebound, callFunc)
end

--- 被反伤时
--- triggerUnit 获取触发单位
--- sourceUnit 获取来源单位
--- damage 获取反伤伤害
hevent.onBeRebound = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beRebound, callFunc)
end

--- 造成无法回避的伤害时
--- triggerUnit 获取触发单位
--- targetUnit 获取目标单位
--- damage 获取伤害值
hevent.onNoAvoid = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.noAvoid, callFunc)
end

--- 被造成无法回避的伤害时
--- triggerUnit 获取触发单位
--- sourceUnit 获取来源单位
--- damage 获取伤害值
hevent.onBeNoAvoid = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beNoAvoid, callFunc)
end

--- 物理暴击时
--- triggerUnit 获取触发单位
--- targetUnit 获取目标单位
--- damage 获取暴击伤害值
--- odds 获取暴击几率百分比
--- percent 获取暴击增幅百分比
hevent.onKnocking = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.knocking, callFunc)
end

--- 承受物理暴击时
--- triggerUnit 获取触发单位
--- sourceUnit 获取来源单位
--- damage 获取暴击伤害值
--- odds 获取暴击几率百分比
--- percent 获取暴击增幅百分比
hevent.onBeKnocking = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beKnocking, callFunc)
end

--- 魔法暴击时
--- triggerUnit 获取触发单位
--- targetUnit 获取目标单位
--- damage 获取暴击伤害值
--- odds 获取暴击几率百分比
--- percent 获取暴击增幅百分比
hevent.onViolence = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.violence, callFunc)
end

--- 承受魔法暴击时
--- triggerUnit 获取触发单位
--- sourceUnit 获取来源单位
--- damage 获取暴击伤害值
--- odds 获取暴击几率百分比
--- percent 获取暴击增幅百分比
hevent.onBeViolence = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beViolence, callFunc)
end

--- 分裂时
--- triggerUnit 获取触发单位
--- targetUnit 获取目标单位
--- damage 获取分裂伤害值
--- range 获取分裂范围(px)
--- percent 获取分裂百分比
hevent.onSpilt = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.spilt, callFunc)
end

--- 承受分裂时
--- triggerUnit 获取触发单位
--- sourceUnit 获取来源单位
--- damage 获取分裂伤害值
--- range 获取分裂范围(px)
--- percent 获取分裂百分比
hevent.onBeSpilt = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beSpilt, callFunc)
end

--- 极限减伤抵抗（减伤不足以抵扣）
--- triggerUnit 获取触发单位
--- sourceUnit 获取来源单位
hevent.onLimitToughness = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.limitToughness, callFunc)
end

--- 吸血时
--- triggerUnit 获取触发单位
--- targetUnit 获取目标单位
--- damage 获取吸血值
--- percent 获取吸血百分比
hevent.onHemophagia = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.hemophagia, callFunc)
end

--- 被吸血时
--- triggerUnit 获取触发单位
--- sourceUnit 获取来源单位
--- damage 获取吸血值
--- percent 获取吸血百分比
hevent.onBeHemophagia = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beHemophagia, callFunc)
end

--- 技能吸血时
--- triggerUnit 获取触发单位
--- targetUnit 获取目标单位
--- damage 获取吸血值
--- percent 获取吸血百分比
hevent.onSkillHemophagia = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.skillHemophagia, callFunc)
end

--- 被技能吸血时
--- triggerUnit 获取触发单位
--- sourceUnit 获取来源单位
--- damage 获取吸血值
--- percent 获取吸血百分比
hevent.onBeSkillHemophagia = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.beSkillHemophagia, callFunc)
end

--- 硬直时
--- triggerUnit 获取触发单位
--- sourceUnit 获取来源单位
--- percent 获取硬直程度百分比
--- during 获取持续时间
hevent.onPunish = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, ONST_EVENT.punish, callFunc)
end

--- 死亡时
--- triggerUnit 获取触发单位
--- killer 获取凶手单位
hevent.onDead = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.dead, callFunc)
end

--- 击杀时
--- triggerUnit 获取触发单位
--- killer 获取凶手单位
--- targetUnit 获取死亡单位
hevent.onKill = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.kill, callFunc)
end

--- triggerUnit 获取触发单位
--- 复活时(必须使用 hunit.reborn 方法才能嵌入到事件系统)
hevent.onReborn = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.reborn, callFunc)
end

--- 提升升等级时
--- triggerUnit 获取触发单位
--- value 获取提升了多少级
hevent.onLevelUp = function(whichUnit, callFunc)
    return hevent.registerEvent(whichUnit, CONST_EVENT.levelUp, callFunc)
end

--- 建筑升级开始时
--- triggerUnit 获取触发单位
hevent.onUpgradeStart = function(whichUnit, callFunc)
    hevent.pool(whichUnit, hevent_default_actions.unit.upgradeStart, function(tgr)
        cj.TriggerRegisterUnitEvent(tgr, whichUnit, EVENT_UNIT_UPGRADE_START)
    end)
    return hevent.registerEvent(whichUnit, CONST_EVENT.upgradeStart, callFunc)
end

--- 建筑升级取消时
--- triggerUnit 获取触发单位
hevent.onUpgradeCancel = function(whichUnit, callFunc)
    hevent.pool(whichUnit, hevent_default_actions.unit.upgradeCancel, function(tgr)
        cj.TriggerRegisterUnitEvent(tgr, whichUnit, EVENT_UNIT_UPGRADE_CANCEL)
    end)
    return hevent.registerEvent(whichUnit, CONST_EVENT.upgradeCancel, callFunc)
end

--- 建筑升级完成时
--- triggerUnit 获取触发单位
hevent.onUpgradeFinish = function(whichUnit, callFunc)
    hevent.pool(whichUnit, hevent_default_actions.unit.upgradeFinish, function(tgr)
        cj.TriggerRegisterUnitEvent(tgr, whichUnit, EVENT_UNIT_UPGRADE_FINISH)
    end)
    return hevent.registerEvent(whichUnit, CONST_EVENT.upgradeFinish, callFunc)
end

--- 进入某单位（whichUnit）范围内
--- centerUnit 被进入范围的中心单位
--- triggerUnit 进入范围的单位
--- enterUnit 进入范围的单位
--- range 设定范围
hevent.onEnterUnitRange = function(whichUnit, range, callFunc)
    local key = CONST_EVENT.enterUnitRange
    if (hRuntime.event.trigger[whichUnit] == nil) then
        hRuntime.event.trigger[whichUnit] = {}
    end
    if (hRuntime.event.trigger[whichUnit][key] == nil) then
        hRuntime.event.trigger[whichUnit][key] = cj.CreateTrigger()
        cj.TriggerRegisterUnitInRange(
            hRuntime.event.trigger[whichUnit][key],
            whichUnit, range, nil
        )
        cj.TriggerAddAction(
            hRuntime.event.trigger[whichUnit][key],
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

--- 进入某区域
--- triggerRect 获取被进入的矩形区域
--- triggerUnit 获取进入矩形区域的单位
hevent.onEnterRect = function(whichRect, callFunc)
    local key = CONST_EVENT.enterRect
    if (hRuntime.event.trigger[whichRect] == nil) then
        hRuntime.event.trigger[whichRect] = {}
    end
    if (hRuntime.event.trigger[whichRect][key] == nil) then
        hRuntime.event.trigger[whichRect][key] = cj.CreateTrigger()
        local rectRegion = cj.CreateRegion()
        cj.RegionAddRect(rectRegion, whichRect)
        cj.TriggerRegisterEnterRegion(hRuntime.event.trigger[whichRect][key], rectRegion, nil)
        cj.TriggerAddAction(
            hRuntime.event.trigger[whichRect][key],
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

--- 离开某区域
--- triggerRect 获取被离开的矩形区域
--- triggerUnit 获取离开矩形区域的单位
hevent.onLeaveRect = function(whichRect, callFunc)
    local key = CONST_EVENT.leaveRect
    if (hRuntime.event.trigger[whichRect] == nil) then
        hRuntime.event.trigger[whichRect] = {}
    end
    if (hRuntime.event.trigger[whichRect][key] == nil) then
        hRuntime.event.trigger[whichRect][key] = cj.CreateTrigger()
        local rectRegion = cj.CreateRegion()
        cj.RegionAddRect(rectRegion, whichRect)
        cj.TriggerRegisterLeaveRegion(hRuntime.event.trigger[whichRect][key], rectRegion, nil)
        cj.TriggerAddAction(
            hRuntime.event.trigger[whichRect][key],
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

--- 当聊天时
--- params matchAll 是否全匹配，false为like
--- triggerPlayer 获取聊天的玩家
--- chatString 获取聊天的内容
--- matchedString 获取匹配命中的内容
hevent.onChat = function(whichPlayer, chatStr, matchAll, callFunc)
    local key = CONST_EVENT.chat .. chatStr .. '|F'
    if (matchAll) then
        key = CONST_EVENT.chat .. chatStr .. '|T'
    end
    if (hRuntime.event.trigger[whichPlayer] == nil) then
        hRuntime.event.trigger[whichPlayer] = {}
    end
    if (hRuntime.event.trigger[whichPlayer][key] == nil) then
        hRuntime.event.trigger[whichPlayer][key] = cj.CreateTrigger()
        cj.TriggerRegisterPlayerChatEvent(hRuntime.event.trigger[whichPlayer][key], whichPlayer, chatStr, matchAll)
        cj.TriggerAddAction(
            hRuntime.event.trigger[whichPlayer][key],
            function()
                hevent.triggerEvent(
                    cj.GetTriggerPlayer(),
                    key,
                    {
                        triggerPlayer = cj.GetTriggerPlayer(),
                        chatString = cj.GetEventPlayerChatString(),
                        matchedString = cj.GetEventPlayerChatStringMatched()
                    }
                )
            end
        )
    end
    return hevent.registerEvent(whichPlayer, key, callFunc)
end

--- 按ESC
--- triggerPlayer 获取触发玩家
hevent.onEsc = function(whichPlayer, callFunc)
    hevent.pool(whichPlayer, hevent_default_actions.player.esc, function(tgr)
        cj.TriggerRegisterPlayerEventEndCinematic(tgr, whichPlayer)
    end)
    return hevent.registerEvent(whichPlayer, CONST_EVENT.esc, callFunc)
end

--- 玩家选择单位(点击了qty次)
--- triggerPlayer 获取触发玩家
--- triggerUnit 获取触发单位
hevent.onSelection = function(whichPlayer, qty, callFunc)
    local key = CONST_EVENT.selection .. "#" .. qty
    if (hRuntime.event.trigger[whichPlayer] == nil) then
        hRuntime.event.trigger[whichPlayer] = {}
    end
    if (hRuntime.event.trigger[whichPlayer][key] == nil) then
        hRuntime.event.trigger[whichPlayer][key] = {
            click = 0,
            trigger = cj.CreateTrigger(),
        }
        cj.TriggerRegisterPlayerUnitEvent(
            hRuntime.event.trigger[whichPlayer][key].trigger,
            whichPlayer, EVENT_PLAYER_UNIT_SELECTED, nil
        )
        cj.TriggerAddAction(
            hRuntime.event.trigger[whichPlayer][key].trigger,
            function()
                local triggerPlayer = cj.GetTriggerPlayer()
                local triggerUnit = cj.GetTriggerUnit()
                hRuntime.event.trigger[triggerPlayer][key].click = hRuntime.event.trigger[triggerPlayer][key].click + 1
                htime.setTimeout(
                    0.3,
                    function(t)
                        htime.delTimer(t)
                        hRuntime.event.trigger[triggerPlayer][key].click = hRuntime.event.trigger[triggerPlayer][key].click - 1
                    end
                )
                if (hRuntime.event.trigger[triggerPlayer][key].click >= qty) then
                    hevent.triggerEvent(
                        triggerPlayer,
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

--- 玩家取消选择单位
--- triggerPlayer 获取触发玩家
--- triggerUnit 获取触发单位
hevent.onDeSelection = function(whichPlayer, callFunc)
    hevent.pool(whichPlayer, hevent_default_actions.player.deSelection, function(tgr)
        cj.TriggerRegisterPlayerUnitEvent(tgr, whichPlayer, EVENT_PLAYER_UNIT_DESELECTED, nil)
    end)
    return hevent.registerEvent(whichPlayer, CONST_EVENT.deSelection, callFunc)
end

--- 任意建筑建造开始时
--- triggerUnit 获取触发单位
hevent.onConstructStart = function(whichPlayer, callFunc)
    hevent.pool(whichPlayer, hevent_default_actions.player.constructStart, function(tgr)
        cj.TriggerRegisterPlayerUnitEvent(tgr, whichPlayer, EVENT_PLAYER_UNIT_CONSTRUCT_START, nil)
    end)
    return hevent.registerEvent(whichPlayer, CONST_EVENT.constructStart, callFunc)
end

--- 任意建筑建造取消时
--- triggerUnit 获取触发单位
hevent.onConstructCancel = function(whichPlayer, callFunc)
    hevent.pool(whichPlayer, hevent_default_actions.player.constructCancel, function(tgr)
        cj.TriggerRegisterPlayerUnitEvent(tgr, whichPlayer, EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL, nil)
    end)
    return hevent.registerEvent(whichPlayer, CONST_EVENT.constructCancel, callFunc)
end

--- 任意建筑建造完成时
--- triggerUnit 获取触发单位
hevent.onConstructFinish = function(whichPlayer, callFunc)
    hevent.pool(whichPlayer, hevent_default_actions.player.constructFinish, function(tgr)
        cj.TriggerRegisterPlayerUnitEvent(tgr, whichPlayer, EVENT_PLAYER_UNIT_CONSTRUCT_FINISH, nil)
    end)
    return hevent.registerEvent(whichPlayer, CONST_EVENT.constructFinish, callFunc)
end

--- 玩家离开游戏事件(注意这是全局事件)
--- triggerPlayer 获取触发玩家
hevent.onPlayerLeave = function(callFunc)
    return hevent.registerEvent("global", CONST_EVENT.playerLeave, callFunc)
end

--- 任意单位经过hero方法被玩家所挑选为英雄时(注意这是全局事件)
--- triggerPlayer 获取触发玩家
--- triggerUnit 获取触发单位
hevent.onPickHero = function(callFunc)
    return hevent.onEventByHandle("global", CONST_EVENT.pickHero, callFunc)
end
