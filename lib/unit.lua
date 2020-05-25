hunit = {}

--- [SLK] 获取英雄在slkHelper设定的部分数据
--- 数值键值是根据地图编辑器作为标准的，所以大小写也是与之一致
---@param whichUnit userdata
---@return table
hunit.getSlk = function(whichUnit)
    local default = {
        -- 参考数据
        UNIT_ID = nil,
        UNIT_TYPE = "normal",
        CUSTOM_DATA = {},
        Art = nil,
        file = nil,
        goldcost = 0,
        lumbercost = 0,
        cool1 = 1.50,
        def = 0,
        rangeN1 = 100,
        sight = 1800,
        nsight = 800,
    }
    if (whichUnit ~= nil) then
        default.Name = cj.GetUnitName(whichUnit)
    else
        default.Name = ""
    end
    if (whichUnit == nil or his.deleted(whichUnit)) then
        return default
    end
    if (his.hero(whichUnit)) then
        default.UNIT_TYPE = "hero"
        default.Primary = nil
        default.STR = cj.GetHeroStr(whichUnit, false)
        default.AGI = cj.GetHeroStr(whichUnit, false)
        default.INT = cj.GetHeroStr(whichUnit, false)
        default.STRplus = nil
        default.AGIplus = nil
        default.INTplus = nil
    end
    return hslk_global.id2Value.unit[hunit.getId(whichUnit)] or default
end

--- 获取单位的头像
---@param uOrUid any
---@return string
hunit.getAvatar = function(whichUnit)
    local slk = hunit.getSlk(whichUnit)
    return slk.Art or "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp"
end

--- 获取单位的最大生命值
---@param u userdata
---@return number
hunit.getMaxLife = function(u)
    return cj.GetUnitState(u, UNIT_STATE_MAX_LIFE)
end
--- 获取单位的当前生命
---@param u userdata
---@return number
hunit.getCurLife = function(u)
    return cj.GetUnitState(u, UNIT_STATE_LIFE)
end
--- 设置单位的当前生命
---@param u userdata
---@param val number
hunit.setCurLife = function(u, val)
    cj.SetUnitState(u, UNIT_STATE_LIFE, val)
end
--- 增加单位的当前生命
---@param u userdata
---@param val number
hunit.addCurLife = function(u, val)
    cj.SetUnitState(u, UNIT_STATE_LIFE, hunit.getCurLife(u) + val)
end
--- 减少单位的当前生命
---@param u userdata
---@param val number
hunit.subCurLife = function(u, val)
    cj.SetUnitState(u, UNIT_STATE_LIFE, hunit.getCurLife(u) - val)
end
--- 获取单位的最大魔法
---@param u userdata
---@return number
hunit.getMaxMana = function(u)
    return cj.GetUnitState(u, UNIT_STATE_MAX_MANA)
end
--- 获取单位的当前魔法
---@param u userdata
---@return number
hunit.getCurMana = function(u)
    return cj.GetUnitState(u, UNIT_STATE_MANA)
end
--- 设置单位的当前魔法
---@param u userdata
---@param val number
hunit.setCurMana = function(u, val)
    cj.SetUnitState(u, UNIT_STATE_MANA, val)
end
--- 增加单位的当前魔法
---@param u userdata
---@param val number
hunit.addCurMana = function(u, val)
    cj.SetUnitState(u, UNIT_STATE_MANA, hunit.getCurMana(u) + val)
end
--- 减少单位的当前魔法
---@param u userdata
---@param val number
hunit.subCurMana = function(u, val)
    cj.SetUnitState(u, UNIT_STATE_MANA, hunit.getCurMana(u) - val)
end

--- 获取单位百分比生命
---@param u userdata
---@return number %
hunit.getCurLifePercent = function(u)
    return math.round(100 * (hunit.getCurLife(u) / hunit.getMaxLife(u)))
end
--- 设置单位百分比生命
---@param u userdata
---@param val number
hunit.setCurLifePercent = function(u, val)
    local max = hunit.getMaxLife(u)
    local life = math.floor(max * val * 0.01)
    if (max > 0 and life < 1) then
        life = 1
    end
    hunit.setCurLife(u, life)
end
--- 获取单位百分比魔法
---@param u userdata
---@return number %
hunit.getCurManaPercent = function(u)
    return math.round(100 * (hunit.getCurMana(u) / hunit.getMaxMana(u)))
end
--- 设置单位百分比魔法
---@param u userdata
---@param val number %
hunit.setCurManaPercent = function(u, val)
    local max = hunit.getMaxMana(u)
    local mana = math.floor(max * val * 0.01)
    if (max > 0 and mana < 1) then
        mana = 1
    end
    hunit.setCurLife(u, mana)
end

--- 增加单位的经验值
---@param u userdata
---@param val number
hunit.addExp = function(u, val, showEffect)
    if (u == nil or val == nil or val <= 0) then
        return
    end
    if (type(showEffect) ~= "boolean") then
        showEffect = false
    end
    val = cj.R2I(val * hplayer.getExpRatio(hunit.getOwner(u)) / 100)
    cj.AddHeroXP(u, val, showEffect)
    htextTag.style(htextTag.create2Unit(u, "+" .. val .. " Exp", 7, "c4c4ff", 1, 1.70, 60.00), "toggle", 0, 0.20)
end

--- 设置单位的生命周期
---@param u userdata
---@param life number
hunit.setPeriod = function(u, life)
    cj.UnitApplyTimedLife(u, string.char2id("BTLF"), life)
end

--- 设置单位面向角度
---@param u userdata
---@param facing number
hunit.setFacing = function(u, facing)
    cj.SetUnitFacing(u, facing)
end

--- 获取单位面向角度
---@param u userdata
---@return number
hunit.getFacing = function(u)
    return cj.GetUnitFacing(u)
end

--- 显示单位
---@param u userdata
hunit.show = function(u)
    cj.ShowUnit(u, true)
end

--- 隐藏单位
---@param u userdata
---@return number
hunit.hide = function(u)
    cj.ShowUnit(u, false)
end

--- 获取单位X坐标
---@param u userdata
---@return number
hunit.x = function(u)
    return cj.GetUnitX(u)
end

--- 获取单位Y坐标
---@param u userdata
---@return number
hunit.y = function(u)
    return cj.GetUnitY(u)
end

--- 单位是否启用硬直（系统默认不启用）
---@param u userdata
---@return boolean
hunit.isOpenPunish = function(u)
    if (u == nil or hRuntime.unit[u] == nil) then
        return false
    end
    if (type(hRuntime.unit[u].isOpenPunish) ~= 'boolean') then
        return false
    end
    return hRuntime.unit[u].isOpenPunish
end

--- 设置单位无敌
---@param u userdata
---@param flag boolean
hunit.setInvulnerable = function(u, flag)
    if (flag == nil) then
        flag = true
    end
    if (flag == true and cj.GetUnitAbilityLevel(u, hskill.BUFF_INVULNERABLE) < 1) then
        cj.UnitAddAbility(u, hskill.BUFF_INVULNERABLE)
    else
        cj.UnitRemoveAbility(u, hskill.BUFF_INVULNERABLE)
    end
end

--- 设置单位的动画速度[比例尺1.00]
---@param u userdata
---@param speed number 0.00-1.00
---@param during number
hunit.setAnimateSpeed = function(u, speed, during)
    if (hRuntime.unit[u] == nil) then
        hRuntime.unit[u] = {}
    end
    cj.SetUnitTimeScale(u, speed)
    during = during or 0
    if (during > 0) then
        local prevSpeed = hRuntime.unit[u].animateSpeed or 1.00
        hRuntime.unit[u].animateSpeed = speed
        htime.setTimeout(
            during,
            function(t)
                htime.delTimer(t)
                cj.SetUnitTimeScale(u, prevSpeed)
            end
        )
    end
end

--- 设置单位的三原色，rgb取值0-255
---@param whichUnit userdata
---@param red number 0-255
---@param green number 0-255
---@param blue number 0-255
---@param opacity number 0.0-1.0
hunit.setRGB = function(whichUnit, red, green, blue, opacity)
    cj.SetUnitVertexColor(
        whichUnit,
        red,
        green,
        blue,
        255 * opacity
    )
end

--- 获取单位当前归属玩家
---@param whichUnit userdata
---@return userdata ownerPlayer
hunit.getOwner = function(whichUnit)
    if (whichUnit == nil) then
        return
    end
    return cj.GetOwningPlayer(whichUnit)
end

--- 瞬间传送单位到X,Y坐标
---@param whichUnit userdata
---@param x number
---@param y number
---@param facing number|nil
hunit.portal = function(whichUnit, x, y, facing)
    if (whichUnit == nil or x == nil or y == nil) then
        return
    end
    cj.SetUnitPosition(whichUnit, x, y)
    if (facing ~= nil) then
        cj.SetUnitFacing(facing)
    end
end

--- 命令单位做动画动作，如 "attack"
--- 当动作为整型序号时，自动播放对应的序号行为(每种模型的序号并不一致)
---@param whichUnit userdata
---@param animate number | string
hunit.animate = function(whichUnit, animate)
    if (whichUnit == nil or animate == nil) then
        return
    end
    if (type(animate) == "string") then
        cj.SetUnitAnimation(whichUnit, animate)
    elseif (type(animate) == "number") then
        animate = math.floor(animate)
        cj.SetUnitAnimationByIndex(whichUnit, animate)
    end
end

--- 创建单位/单位组
---@param bean table
---@return userdata|table 最后创建单位|单位组
hunit.create = function(bean)
    --[[
        bean = {
            register = true, --是否注册进系统
            whichPlayer = nil, --归属玩家
            unitId = nil, --类型id,如'H001'
            x = nil, --创建坐标X，可选
            y = nil, --创建坐标Y，可选
            loc = nil, --创建点，可选
            height = 高度，0，可选
            timeScale = 动作时间比例，1~，可选
            modelScale = 模型缩放比例，1~，可选
            opacity = 透明，0.0～1.0，可选,0不可见
            qty = 1, --数量，可选，可选
            life = nil, --生命周期，到期死亡，可选
            during = nil, --持续时间，到期删除，可选
            facing = nil, --面向角度，可选
            facingX = nil, --面向X，可选
            facingY = nil, --面向Y，可选
            facingLoc = nil, --面向点，可选
            facingUnit = nil, --面向单位，可选
            attackX = nil, --攻击X，可选
            attackY = nil, --攻击Y，可选
            attackLoc = nil, --攻击点，可选
            attackUnit = nil, --攻击单位，可选
            isOpenSlot = false, --是否开启物品栏(自动注册)可选
            isOpenPunish = false, --是否开启硬直系统，可选
            isShadow = false, --是否影子，可选
            isUnSelectable = false, --是否不可鼠标选中，可选
            isPause = false, -- 是否暂停
            isInvulnerable = false, --是否无敌，可选
            isShareSight = false, --是否与所有玩家共享视野，可选
        }
    ]]
    if (bean.qty == nil) then
        bean.qty = 1
    end
    if (bean.whichPlayer == nil) then
        print_err("create unit fail -pl")
        return
    end
    if (bean.unitId == nil) then
        print_err("create unit fail -id")
        return
    end
    if (bean.qty <= 0) then
        print_err("create unit fail -qty")
        return
    end
    if (bean.x == nil and bean.y == nil and bean.loc == nil) then
        print_err("create unit fail -place")
        return
    end
    if (bean.unitId == nil) then
        print_err("create unit id")
        return
    end
    if (type(bean.unitId) == "string") then
        bean.unitId = string.char2id(bean.unitId)
    end
    local u
    local facing
    local x
    local y
    local g
    if (bean.x ~= nil and bean.y ~= nil) then
        x = bean.x
        y = bean.y
    elseif (bean.loc ~= nil) then
        x = cj.GetLocationX(bean.loc)
        y = cj.GetLocationY(bean.loc)
    end
    if (bean.facing ~= nil) then
        facing = bean.facing
    elseif (bean.facingX ~= nil and bean.facingY ~= nil) then
        facing = math.getDegBetweenXY(x, y, bean.facingX, bean.facingY)
    elseif (bean.facingLoc ~= nil) then
        facing = math.getDegBetweenXY(x, y, cj.GetLocationX(bean.facingLoc), cj.GetLocationY(bean.facingLoc))
    elseif (bean.facingUnit ~= nil) then
        facing = math.getDegBetweenXY(x, y, hunit.x(bean.facingUnit), hunit.y(bean.facingUnit))
    else
        facing = bj_UNIT_FACING
    end
    if (bean.qty > 1) then
        g = {}
    end
    for _ = 1, bean.qty, 1 do
        if (bean.x ~= nil and bean.y ~= nil) then
            u = cj.CreateUnit(bean.whichPlayer, bean.unitId, bean.x, bean.y, facing)
        elseif (bean.loc ~= nil) then
            u = cj.CreateUnitAtLoc(bean.whichPlayer, bean.unitId, bean.loc, facing)
        end
        -- 高度
        if (bean.height ~= nil and bean.height ~= 0) then
            bean.height = math.round(bean.height)
            hunit.setCanFly(u)
            cj.SetUnitFlyHeight(u, bean.height, 10000)
        end
        -- 动作时间比例 %
        if (bean.timeScale ~= nil and bean.timeScale > 0) then
            bean.timeScale = math.round(bean.timeScale * 0.01)
            cj.SetUnitTimeScale(u, bean.timeScale)
        end
        -- 模型缩放比例 %
        if (bean.modelScale ~= nil and bean.modelScale > 0) then
            bean.modelScale = math.round(bean.modelScale)
            cj.SetUnitScale(u, bean.modelScale, bean.modelScale, bean.modelScale)
        end
        -- 透明比例
        if (bean.opacity ~= nil and bean.opacity <= 1 and bean.opacity >= 0) then
            bean.opacity = math.round(bean.opacity)
            cj.SetUnitVertexColor(u, 255, 255, 255, 255 * bean.opacity)
        end
        if (bean.attackX ~= nil and bean.attackY ~= nil) then
            cj.IssuePointOrder(u, "attack", bean.attackX, bean.attackY)
        elseif (bean.attackLoc ~= nil) then
            cj.IssuePointOrderLoc(u, "attack", bean.attackLoc)
        elseif (bean.attackUnit ~= nil) then
            cj.IssueTargetOrder(u, "attack", bean.attackUnit)
        end
        if (bean.qty > 1) then
            hgroup.addUnit(g, u)
        end
        --是否可选
        if (bean.isUnSelectable ~= nil and bean.isUnSelectable == true) then
            cj.UnitAddAbility(u, string.char2id("Aloc"))
        end
        --是否暂停
        if (bean.isPause ~= nil and bean.isPause == true) then
            cj.PauseUnit(u, true)
        end
        --是否无敌
        if (bean.isInvulnerable ~= nil and bean.isInvulnerable == true) then
            hunit.setInvulnerable(u, true)
        end
        --开启硬直，执行硬直计算
        if (bean.isOpenPunish ~= nil and bean.isOpenPunish == true) then
            table.insert(hRuntime.attributeGroup.punish, u)
        end
        --影子，无敌蝗虫暂停,且不注册系统
        if (bean.isShadow ~= nil and bean.isShadow == true) then
            cj.UnitAddAbility(u, "Aloc")
            cj.PauseUnit(u, true)
            hunit.setInvulnerable(u, true)
            bean.register = false
        end
        --是否与所有玩家共享视野
        if (bean.isShareSight ~= nil and bean.isShareSight == true) then
            for pi = 0, bj_MAX_PLAYERS - 1, 1 do
                cj.SetPlayerAlliance(bean.whichPlayer, cj.Player(pi), ALLIANCE_SHARED_VISION, true)
            end
        end
        -- 记入group选择器（不在框架系统内的单位，也不会被group选择到）
        table.insert(hRuntime.group, u)
        -- 记入realtime
        hRuntime.unit[u] = {
            id = bean.unitId,
            life = bean.life,
            during = bean.during,
            isOpenPunish = bean.isOpenPunish,
            isShadow = bean.isShadow,
            animateSpeed = bean.timeScale,
        }
        -- 注册系统(默认注册)
        if (type(bean.register) ~= "boolean") then
            bean.register = true
        end
        if (bean.register == true) then
            -- 单位受伤
            hevent.pool(u, hevent_default_actions.unit.damaged, function(tgr)
                cj.TriggerRegisterUnitEvent(tgr, u, EVENT_UNIT_DAMAGED)
            end)
            -- 单位死亡
            hevent.pool(u, hevent_default_actions.unit.death, function(tgr)
                cj.TriggerRegisterUnitEvent(tgr, u, EVENT_UNIT_DEATH)
            end)
            -- 物品系统
            if (his.hasSlot(u)) then
                hitem.register(u)
            elseif (bean.isOpenSlot == true) then
                hskill.add(u, hitem.DEFAULT_SKILL_ITEM_SLOT, 0)
                hitem.register(u)
            end
        end
        -- 如果是英雄，注册事件和计算初次属性
        if (his.hero(u) == true) then
            hhero.formatHero(u)
        end
        -- 生命周期 dead
        if (bean.life ~= nil and bean.life > 0) then
            hunit.setPeriod(u, bean.life)
            hunit.del(u, bean.life + 1)
        end
        -- 持续时间 delete
        if (bean.during ~= nil and bean.during >= 0) then
            hunit.del(u, bean.during)
        end
    end
    if (g ~= nil) then
        return g
    else
        return u
    end
end

--- 获取单位ID字符串
---@param u userdata
---@return string
hunit.getId = function(u)
    return string.id2char(cj.GetUnitTypeId(u))
end

--- 获取单位的名称
---@param u userdata
---@return string
hunit.getName = function(u)
    return cj.GetUnitName(u)
end
--- 获取单位的自定义值
---@param u userdata
---@return number
hunit.getUserData = function(u)
    return cj.GetUnitUserData(u)
end
--- 设置单位的自定义值
---@param u userdata
---@param val number
---@param during number
hunit.setUserData = function(u, val, during)
    local oldData = hunit.getUserData(u)
    val = math.ceil(val)
    cj.SetUnitUserData(u, val)
    during = during or 0
    if (during > 0) then
        htime.setTimeout(
            during,
            function(t)
                htime.delTimer(t)
                cj.SetUnitUserData(u, oldData)
            end
        )
    end
end

--- 设置单位颜色,color可设置玩家索引[1-16],应用其对应的颜色
---@param u userdata
---@param color any 阵营颜色
hunit.setColor = function(u, color)
    if (type(color) == "string") then
        color = string.upper(color)
        if (CONST_PLAYER_COLOR[color] ~= nil) then
            cj.SetUnitColor(u, CONST_PLAYER_COLOR[color])
        end
    else
        cj.SetUnitColor(u, cj.ConvertPlayerColor(color - 1))
    end
end

--- 删除单位，延时<delay>秒
---@param targetUnit userdata
---@param delay number
hunit.del = function(targetUnit, delay)
    if (delay == nil or delay <= 0) then
        hitem.clearUnitCache(targetUnit)
        hRuntime.clear(targetUnit)
        cj.RemoveUnit(targetUnit)
    else
        htime.setTimeout(
            delay,
            function(t)
                htime.delTimer(t)
                hitem.clearUnitCache(targetUnit)
                hRuntime.clear(targetUnit)
                cj.RemoveUnit(targetUnit)
            end
        )
    end
end
--- 杀死单位，延时<delay>秒
---@param targetUnit userdata
---@param delay number
hunit.kill = function(targetUnit, delay)
    if (delay == nil or delay <= 0) then
        cj.KillUnit(targetUnit)
    else
        htime.setTimeout(
            delay,
            function(t)
                htime.delTimer(t)
                cj.KillUnit(targetUnit)
            end
        )
    end
end
--- 爆毁单位，延时<delay>秒
---@param targetUnit userdata
---@param delay number
hunit.exploded = function(targetUnit, delay)
    if (delay == nil or delay <= 0) then
        cj.SetUnitExploded(targetUnit, true)
        cj.KillUnit(targetUnit)
    else
        htime.setTimeout(
            delay,
            function(t)
                htime.delTimer(t)
                cj.SetUnitExploded(targetUnit, true)
                cj.KillUnit(targetUnit)
            end
        )
    end
end

--- 设置单位可飞，用于设置单位飞行高度之前
---@param u userdata
hunit.setCanFly = function(u)
    cj.UnitAddAbility(u, string.char2id("Arav"))
    cj.UnitRemoveAbility(u, string.char2id("Arav"))
end

--- 设置单位高度，用于设置单位可飞行之后
---@param u userdata
---@param height number
---@param speed number
hunit.setFlyHeight = function(u, height, speed)
    cj.SetUnitFlyHeight(u, height, speed)
end