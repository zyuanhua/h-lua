hRuntime = {
    -- 注册runtime的数据
    register = {
        unit = function(json)
            hslk_global.unitsKV[json.UNIT_ID] = json
        end,
        item = function(json)
            hslk_global.itemsKV[json.ITEM_ID] = json
            if (type(json.SHADOW_ID) == "string") then
                hslk_global.itemsShadowKV[json.ITEM_ID] = json.SHADOW_ID
                hslk_global.itemsFaceKV[json.SHADOW_ID] = json.ITEM_ID
            end
        end,
        ability = function(json)
            hslk_global.abilitiesKV[json.ABILITY_ID] = json
        end
    },
    is = {},
    sound = {},
    env = {},
    camera = {},
    event = {
        -- 核心注册
        register = {},
        -- 池
        pool = {},
        -- 额外的触发管理
        trigger = {},
    },
    textTag = {},
    rect = {},
    player = {},
    unit = {},
    hero = {},
    heroBuildSelection = {},
    skill = {},
    attribute = {},
    attributeDiff = {},
    attributeDamaging = {},
    attributeGroup = {
        life_back = {},
        mana_back = {},
        punish = {}
    },
    attributeThreeBuff = {
        -- 每一点三围对属性的影响，默认会写一些，可以通过 hattr.setThreeBuff 方法来改变系统构成
        -- 需要注意的是三围只能影响common内的大部分参数，natural及effect是无效的
        str = {
            life = 10, -- 每点力量提升10生命（默认例子）
            life_back = 0.1 -- 每点力量提升0.1生命恢复（默认例子）
        },
        agi = {
            attack_white = 1, -- 每点敏捷提升1白字攻击（默认例子）
            defend = 0.01 -- 每点敏捷提升0.01护甲（默认例子）
        },
        int = {
            attack_green = 1, -- 每点智力提升1绿字攻击（默认例子）
            mana = 6, -- 每点智力提升6魔法（默认例子）
            mana_back = 0.05 -- 每点力量提升0.05生命恢复（默认例子）
        }
    },
    item = {},
    itemPickPool = {},
    leaderBoard = {},
    multiBoard = {},
    dialog = {}
}
hRuntime.clear = function(handle)
    if (handle == nil) then
        return
    end
    if (hRuntime.is[handle] ~= nil) then
        hRuntime.is[handle] = nil
    end
    if (hRuntime.sound[handle] ~= nil) then
        hRuntime.sound[handle] = nil
    end
    if (hRuntime.env[handle] ~= nil) then
        hRuntime.env[handle] = nil
    end
    if (hRuntime.camera[handle] ~= nil) then
        hRuntime.camera[handle] = nil
    end
    if (hRuntime.event[handle] ~= nil) then
        hRuntime.event[handle] = nil
    end
    if (hRuntime.event.register[handle] ~= nil) then
        hRuntime.event.register[handle] = nil
    end
    if (hRuntime.event.trigger[handle] ~= nil) then
        local keys = {
            CONST_EVENT.enterUnitRange,
        }
        for _, s in ipairs(keys) do
            if (hRuntime.event.trigger[handle][s] ~= nil) then
                cj.DisableTrigger(hRuntime.event.trigger[handle][s])
                cj.DestroyTrigger(hRuntime.event.trigger[handle][s])
            end
        end
        hRuntime.event.trigger[handle] = nil
    end
    if (hRuntime.event.pool[handle] ~= nil) then
        for _, p in ipairs(hRuntime.event.pool[handle]) do
            local key = p.key
            local poolIndex = p.poolIndex
            hevent.POOL[key][poolIndex].stock = hevent.POOL[key][poolIndex].stock - 1
            -- 起码利用红线一半允许归零
            if (hevent.POOL[key][poolIndex].stock == 0
                and hevent.POOL[key][poolIndex].count > 0.5 * hevent.POOL_RED_LINE) then
                cj.DisableTrigger(hevent.POOL[key][poolIndex].trigger)
                cj.DestroyTrigger(hevent.POOL[key][poolIndex].trigger)
                hevent.POOL[key][poolIndex] = -1
            end
            local e = 0
            for _, v in ipairs(hevent.POOL[key]) do
                if (v == -1) then
                    e = e + 1
                end
            end
            if (e == #hevent.POOL[key]) then
                hevent.POOL[key] = {}
            end
        end
        hRuntime.event.pool[handle] = nil
    end
    if (hRuntime.textTag[handle] ~= nil) then
        hRuntime.textTag[handle] = nil
    end
    if (hRuntime.rect[handle] ~= nil) then
        hRuntime.rect[handle] = nil
    end
    if (hRuntime.player[handle] ~= nil) then
        hRuntime.player[handle] = nil
    end
    if (hRuntime.unit[handle] ~= nil) then
        hRuntime.unit[handle] = nil
    end
    if (hRuntime.hero[handle] ~= nil) then
        hRuntime.hero[handle] = nil
    end
    if (hRuntime.heroBuildSelection[handle] ~= nil) then
        hRuntime.heroBuildSelection[handle] = nil
    end
    if (hRuntime.skill[handle] ~= nil) then
        hRuntime.skill[handle] = nil
    end
    if (hRuntime.attribute[handle] ~= nil) then
        hRuntime.attribute[handle] = nil
    end
    if (hRuntime.attributeDiff[handle] ~= nil) then
        hRuntime.attributeDiff[handle] = nil
    end
    if (hRuntime.attributeDamaging[handle] ~= nil) then
        hRuntime.attributeDamaging[handle] = nil
    end
    if (hRuntime.item[handle] ~= nil) then
        hRuntime.item[handle] = nil
    end
    if (hRuntime.leaderBoard[handle] ~= nil) then
        hRuntime.leaderBoard[handle] = nil
    end
    if (hRuntime.multiBoard[handle] ~= nil) then
        hRuntime.multiBoard[handle] = nil
    end
end

for i = 1, bj_MAX_PLAYER_SLOTS, 1 do
    -- is
    hRuntime.is[i] = {}
    hRuntime.is[i].isComputer = true
    hRuntime.is[i].isAutoConvertGoldToLumber = true
    -- sound
    hRuntime.sound[i] = {}
    hRuntime.sound[i].currentBgm = nil
    hRuntime.sound[i].bgmDelay = 3.00
    -- player
    hRuntime.player[i] = {}
    -- camera
    hRuntime.camera[i] = {}
    hRuntime.camera[i].model = "normal" -- 镜头模型
    hRuntime.camera[i].isShocking = false
end
