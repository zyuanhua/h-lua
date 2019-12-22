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
        end,
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
    event = {},
    eventTgr = {},
    eventGlobalTgr = {},
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
    attributeGroup = {
        life_back = {},
        mana_back = {},
        life_source = {},
        mana_source = {},
        punish = {},
        punish_current = {},
    },
    item = {},
    leaderBoard = {},
}

for i = 1, bj_MAX_PLAYER_SLOTS, 1 do
    local p = cj.Player(i - 1)
    -- is
    hRuntime.is[p] = {}
    hRuntime.is[p].isComputer = true
    hRuntime.is[p].isAutoConvertGoldToLumber = true
    -- sound
    hRuntime.sound[p] = {}
    hRuntime.sound[p].currentBgm = nil
    hRuntime.sound[p].bgmDelay = 3.00
    -- event
    hRuntime.event[p] = {}
    hRuntime.eventGlobalTgr[p] = {}
    -- player
    hRuntime.player[p] = {}
    -- camera
    hRuntime.camera[p] = {}
    hRuntime.camera[p].model = "normal" -- 镜头模型
    hRuntime.camera[p].isShocking = false
end