hRuntime = {
    --[[
        注册runtime的数据
        unit,item,ability
    ]]
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
    system = {},
    logic = {},
    time = {},
    is = {},
    message = {},
    sound = {},
    mark = {},
    effect = {},
    lightning = {},
    weather = {},
    env = {},
    camera = {},
    event = {
        register = {},
        trigger = {}
    },
    textTag = {},
    rect = {},
    player = {},
    award = {},
    unit = {},
    enemy = {},
    group = {},
    hero = {},
    heroBuildSelection = {},
    skill = {},
    attribute = {},
    attributeDiff = {},
    attributeDamaging = {},
    attributeGroup = {
        life_back = {},
        mana_back = {},
        punish = {},
        punish_current = {}
    },
    attributeThreeBuff = {
        --- 每一点三围对属性的影响，默认会写一些，可以通过 hattr.setThreeBuff 方法来改变系统构成
        --- 需要注意的是三围只能影响common内的大部分参数，natural及effect是无效的
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
    leaderBoard = {},
    multiBoard = {}
}

hRuntime.clear = function(handle)
    if (handle == nil) then
        return
    end
    for k, v in pairs(hRuntime) do
        if (type(v) == "table") then
            if (v[handle] ~= nil) then
                v[handle] = nil
            end
            if (k == "event") then
                if (v.register[handle] ~= nil) then
                    v.register[handle] = nil
                end
            end
        end
    end
end

for i = 1, bj_MAX_PLAYER_SLOTS, 1 do
    local p = cj.Player(i - 1)
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
