--- slk hash data
slkHelperHashData = {}

slkHelper = {
    count = 0,
    shapeshiftIndex = 1
}

--[[
    构建变身slk
    options = {
        fromUnitId = "name", --from单位ID
        toName = "name", --to单位名称
        toArt = "art", --to单位图标
        toFire = "fire", --to单位模型路径
    }
    return {
        fromUnitId,
        toUnitId,
        toAbilityId,
        backAbilityId,
    }
]]
slkHelper.shapeshift = function(options)
    local re = {
        fromUnitId = options.fromUnitId
    }
    -- #变身演示
    local obj = slk.unit.Edmm:new("slkh_shapeshift_tu_" .. slkHelper.shapeshiftIndex)
    obj.EditorSuffix = "SLK#变身"
    obj.Name = options.toName
    obj.special = 0
    obj.abilList = ""
    obj.heroAbiList = ""
    obj.Requirescount = 0
    obj.Requires1 = ""
    obj.Requires2 = ""
    obj.file = options.toFire
    obj.Art = options.toArt
    obj.race = "other"
    re.toUnitId = obj:get_id()
    obj = slk.ability.AEme:new("slkh_shapeshift_ta_" .. slkHelper.shapeshiftIndex)
    obj.EditorSuffix = "#h-lua"
    obj.Name = "SLK#变身#T[" .. options.toName .. "]"
    obj.UnitD1 = re.fromUnitId
    obj.DataE1 = 0
    obj.DataA1 = re.toUnitId
    obj.Tip = ""
    obj.Ubertip = ""
    obj.Art = ""
    obj.hero = 0
    obj.race = "other"
    obj.Cool1 = 0.00
    obj.Dur1 = 0.500
    obj.HeroDur1 = 0.001
    obj.Cost1 = 0
    re.toAbilityId = obj:get_id()
    obj = slk.ability.AEme:new("slkh_shapeshift_ba_" .. slkHelper.shapeshiftIndex)
    obj.EditorSuffix = "#h-lua"
    obj.Name = "SLK#变身#B[" .. options.toName .. "]"
    obj.UnitD1 = re.toUnitId
    obj.DataE1 = 0
    obj.DataA1 = re.fromUnitId
    obj.Tip = ""
    obj.Ubertip = ""
    obj.Art = ""
    obj.hero = 0
    obj.race = "other"
    obj.Cool1 = 0.00
    obj.Dur1 = 0.500
    obj.HeroDur1 = 0.001
    obj.Cost1 = 0
    re.backAbilityId = obj:get_id()
    return re
end

--- 属性系统说明构成
---@private
slkHelper.attrForItem = function(attr, sep)
    local str = ""
    sep = sep or "|n"
    for k, v in pairs(attr) do
        -- 附加单位
        if (k == "attack_speed_space") then
            v = v .. "击每秒"
        end
        if (table.includes(k, { "life_back", "mana_back" })) then
            v = v .. "每秒"
        end
        if (table.includes(k, {
            "attack_speed",
            "resistance",
            "avoid",
            "aim",
            "hemophagia",
            "hemophagia_skill",
            "split",
            "luck",
            "invincible",
            "damage_extent",
            "damage_rebound",
            "cure",
            "gold_ratio",
            "lumber_ratio",
            "exp_ratio",
            "sell_ratio"
        }))
        then
            v = v .. "%"
        end
        local s = string.find(k, "oppose")
        local n = string.find(k, "natural")
        if (s ~= nil or n ~= nil) then
            v = v .. "%"
        end
        --
        if (k == "attack_damage_type") then
            str = str .. (CONST_ATTR[k] or "") .. "："
            local temp = ""
            local opt = string.sub(v, 1, 1) or "+"
            if (type(v) == "string") then
                v = string.sub(v, 2)
                v = string.explode(",", v)
            end
            local av = {}
            for kk, vv in ipairs(v) do
                table.insert(av, CONST_ATTR[vv] or "")
            end
            str = str .. opt .. string.implode(",", av)
            av = nil
            str = str .. temp .. sep
        elseif (table.includes(k, {
            "attack_buff",
            "attack_debuff",
            "skill_buff",
            "skill_debuff",
            "attack_effect",
            "skill_effect"
        }) == false)
        then
            str = str .. (CONST_ATTR[k] or "") .. "："
            str = str .. v .. sep
        end
    end
    return str
end

--- 物品属性系统说明构成
---@private
slkHelper.attrForItemTable = function(attr, sep)
    local str = ""
    sep = sep or "|n"
    for k, v in pairs(attr) do
        if (table.includes(k, {
            "attack_buff",
            "attack_debuff",
            "skill_buff",
            "skill_debuff",
            "attack_effect",
            "skill_effect"
        }))
        then
            str = str .. (CONST_ATTR[k] or "") .. "："
            local temp = ""
            for kk, vv in pairs(v) do
                temp = temp .. (CONST_ATTR[kk] or "")
                local odds = vv["odds"] or 0
                local during = vv["during"] or 0
                local val = vv["val"] or 0
                local percent = vv["percent"] or 0
                local qty = vv["qty"] or 0
                local reduce = vv["reduce"] or 0
                local range = vv["range"] or 0
                local distance = vv["distance"] or 0
                local high = vv["high"] or 0
                local temp2 = "|n　-"
                if (k == "attack_buff" or k == "skill_buff") then
                    temp2 = temp2 .. "有"
                    temp2 = temp2 .. odds .. "%几率"
                    temp2 = temp2 .. "在" .. during .. "秒内"
                    if (val >= 0) then
                        temp2 = temp2 .. "增加自身" .. val
                    else
                        temp2 = temp2 .. "减少自身" .. val
                    end
                    temp2 = temp2 .. CONST_ATTR[vv["attr"]]
                elseif (k == "attack_debuff" or k == "skill_debuff") then
                    temp2 = temp2 .. "有" .. odds .. "%几率"
                    temp2 = temp2 .. "在" .. during .. "秒内"
                    if (vv["val"] >= 0) then
                        temp2 = temp2 .. "减少敌人" .. vv["val"]
                    else
                        temp2 = temp2 .. "增加敌人" .. vv["val"]
                    end
                    temp2 = temp2 .. CONST_ATTR[vv["attr"]]
                elseif (k == "attack_effect" or k == "skill_effect") then
                    if (odds < 100) then
                        temp2 = temp2 .. "有" .. odds .. "%几率"
                    end
                    if (vv["attr"] == "knocking" or vv["attr"] == "violence") then
                        temp2 = temp2 .. "击出额外" .. percent .. "%伤害的" .. CONST_ATTR[vv["attr"]]
                    elseif (vv["attr"] == "split" or vv["attr"] == "bomb") then
                        temp2 = temp2 .. "击出" .. range .. "范围"
                        temp2 = temp2 .. percent .. "%的" .. CONST_ATTR[vv["attr"]] .. "伤害"
                    elseif (vv["attr"] == "swim" or vv["attr"] == "silent" or vv["attr"] == "unarm" or vv["attr"] == "fetter")
                    then
                        temp2 = temp2 .. CONST_ATTR[vv["attr"]] .. "目标" .. during .. "秒"
                        if (val > 0) then
                            temp2 = temp2 .. ",并造成" .. val .. "点伤害"
                        end
                    elseif (vv["attr"] == "broken") then
                        temp2 = temp2 .. CONST_ATTR[vv["attr"]] .. "目标"
                        if (val > 0) then
                            temp2 = temp2 .. ",并造成" .. val .. "点伤害"
                        end
                    elseif (vv["attr"] == "lightning_chain") then
                        temp2 = temp2 .. "对最多" .. qty .. "个目标"
                        temp2 = temp2 .. "发动" .. val .. "伤害的" .. CONST_ATTR[vv["attr"]]
                        if (reduce > 0) then
                            temp2 = temp2 .. ",每次击中伤害渐强" .. reduce .. "%"
                        elseif (reduce < 0) then
                            temp2 = temp2 .. ",每次击中伤害衰减" .. reduce .. "%"
                        end
                    elseif (vv["attr"] == "crack_fly") then
                        temp2 = temp2 .. CONST_ATTR[vv["attr"]] .. "目标高达" .. high .. "高度"
                        if (val > 0) then
                            temp2 = temp2 .. ",并击退" .. distance .. "范围"
                        end
                        if (val > 0) then
                            temp2 = temp2 .. ",同时造成" .. val .. "伤害"
                        end
                    end
                end
                temp = temp .. temp2
            end
            str = str .. temp .. sep
        end
    end
    return str
end

--- 组装物品的描述
---@private
slkHelper.itemDesc = function(v)
    local d = {}
    if (v.ACTIVE ~= nil) then
        table.insert(d, "主动：" .. v.ACTIVE)
    end
    if (v.PASSIVE ~= nil) then
        table.insert(d, v.PASSIVE)
    end
    if (v.ATTR ~= nil) then
        table.sort(v.ATTR)
        table.insert(d, slkHelper.attrForItem(v.ATTR, ";") .. slkHelper.attrForItemTable(v.ATTR, ";"))
    end
    local overlie = v.OVERLIE or 1
    local weight = v.WEIGHT or 0
    weight = tostring(math.round(weight))
    table.insert(d, "叠加：" .. overlie .. "|n重量：" .. weight .. "Kg")
    if (v.Desc ~= nil and v.Desc ~= "") then
        table.insert(d, v.Desc)
    end
    return string.implode("|n", d)
end

--- 组装物品的说明
---@private
slkHelper.itemUbertip = function(v)
    local d = {}
    if (v.ATTR ~= nil) then
        table.sort(v.ATTR)
        table.insert(d, hColor.green(slkHelper.attrForItem(v.ATTR, "|n"))
            .. hColor.yellow(slkHelper.attrForItemTable(v.ATTR, "|n")))
    end
    if (v.ACTIVE ~= nil) then
        table.insert(d, hColor.yellow("主动：" .. v.ACTIVE .. "，冷却" .. v.cooldown .. "秒)"))
    end
    if (v.PASSIVE ~= nil) then
        table.insert(d, hColor.seaLight(v.PASSIVE))
    end
    local overlie = v.OVERLIE or 1
    local weight = v.WEIGHT or 0
    weight = tostring(math.round(weight))
    table.insert(d, hColor.purpleLight("叠加：" .. overlie .. "|n重量：" .. weight .. "Kg"))
    if (v.Desc ~= nil and v.Desc ~= "") then
        table.insert(d, hColor.grey(v.Desc))
    end
    return string.implode("|n", d)
end

--- 创建一件物品的冷却技能
---@public
slkHelper.itemCooldownID = function(v)
    if (v.cooldown == nil) then
        return "AIat"
    end
    if (v.cooldown < 0) then
        v.cooldown = 0
    end
    local oobTips = "ITEMS_DEFCD_ID_" .. v.Name
    local oob = slk.ability.AIgo:new("items_default_cooldown_" .. v.Name)
    oob.Effectsound = ""
    oob.Name = oobTips
    oob.Tip = oobTips
    oob.Ubertip = oobTips
    oob.Art = ""
    oob.TargetArt = ""
    oob.Targetattach = ""
    oob.DataA1 = 0
    oob.Art = ""
    oob.CasterArt = v.CasterArt or ""
    oob.Cool = v.cooldown
    return oob:get_id()
end

--- 创建一件物品
--- 设置的CUSTOM_DATA数据会自动传到数据中
---@public
slkHelper.item = function(v)
    slkHelper.count = slkHelper.count + 1
    local cd = slkHelper.itemCooldownID(v)
    local abilList = ""
    local usable = 0
    if (cd ~= "AIat") then
        abilList = cd
        usable = 1
        if (v.perishable == nil) then
            v.perishable = 1
        end
        v.class = "Charged"
    else
        if (v.perishable == nil) then
            v.perishable = 0
        end
        v.class = "Permanent"
    end
    local lv = 1
    v.goldcost = v.goldcost or 0
    v.lumbercost = v.lumbercost or 0
    lv = math.floor((v.goldcost + v.lumbercost) / 500)
    if (lv < 1) then
        lv = 1
    end
    v.Name = v.Name or "未命名" .. slkHelper.count
    v.Art = v.Art or "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp"
    v.file = v.file or "Objects\\InventoryItems\\TreasureChest\\treasurechest.mdl"
    v.powerup = v.powerup or 0
    v.perishable = v.perishable or 0
    v.sellable = v.sellable or 1
    v.pawnable = v.pawnable or 1
    v.dropable = v.dropable or 1
    local OVERLIE = v.OVERLIE or 1
    local WEIGHT = v.WEIGHT or 0
    local obj = slk.item.rat9:new("items_" .. v.Name)
    obj.Name = v.Name
    obj.Description = slkHelper.itemDesc(v)
    obj.Ubertip = slkHelper.itemUbertip(v)
    obj.goldcost = v.goldcost or 1000000
    obj.lumbercost = v.lumbercost or 1000000
    obj.class = v.class
    obj.Level = lv
    obj.oldLevel = lv
    obj.Art = v.Art
    obj.file = v.file
    obj.prio = v.prio or 0
    obj.cooldownID = cd
    obj.abilList = abilList
    obj.ignoreCD = v.ignoreCD or 0
    obj.drop = v.drop or 0
    obj.perishable = v.perishable
    obj.usable = usable
    obj.powerup = v.powerup
    obj.sellable = v.sellable
    obj.pawnable = v.pawnable
    obj.droppable = v.dropable
    obj.pickRandom = v.pickRandom or 1
    obj.stockStart = v.stockStart or 0 -- 库存开始
    obj.stockRegen = v.stockRegen or 0 -- 进货周期
    obj.stockMax = v.stockMax or 1 -- 最大库存
    obj.uses = 1
    if (v.HotKey ~= nil) then
        obj.HotKey = v.HotKey
        v.Buttonpos1 = CONST_HOTKEY_KV[v.HotKey].Buttonpos1 or 0
        v.Buttonpos2 = CONST_HOTKEY_KV[v.HotKey].Buttonpos2 or 0
        obj.Tip = "获得" .. v.Name .. "(" .. hColor.gold(v.HotKey) .. ")"
    else
        obj.Buttonpos1 = v.Buttonpos1 or 0
        obj.Buttonpos2 = v.Buttonpos2 or 0
        obj.Tip = "获得" .. v.Name
    end
    local id = obj:get_id()
    table.insert(slkHelperHashData, {
        type = "item",
        data = {
            ITEM_ID = id,
            Name = v.Name,
            class = v.class,
            Art = v.Art,
            file = v.file,
            goldcost = v.goldcost,
            lumbercost = v.lumbercost,
            usable = usable,
            powerup = v.powerup,
            perishable = v.perishable,
            sellable = v.sellable,
            OVERLIE = OVERLIE,
            WEIGHT = WEIGHT,
            ATTR = v.ATTR,
            CUSTOM_DATA = v.CUSTOM_DATA or {},
        }
    })
    return id
end

--- 创建一件英雄
--- 设置的CUSTOM_DATA数据会自动传到数据中
---@public
slkHelper.hero = function(v)
    slkHelper.count = slkHelper.count + 1
    v.Name = v.Name or "未命名" .. slkHelper.count
    local Primary = v.Primary or "STR"
    local Ubertip = ""
    Ubertip = Ubertip .. hColor.red("攻击类型：" .. CONST_WEAPON_TYPE[v.weapTp1].label .. "(" .. v.cool1 .. "秒/击)")
    Ubertip = Ubertip .. "|n" .. hColor.redLight("基础攻击：" .. v.dmgplus1)
    Ubertip = Ubertip .. "|n" .. hColor.seaLight("攻击范围：" .. v.rangeN1)
    if (Primary == "STR") then
        Ubertip = Ubertip .. "|n" .. hColor.yellow("力量：" .. v.STR .. "(+" .. v.STRplus .. ")")
    else
        Ubertip = Ubertip .. "|n" .. hColor.yellowLight("力量：" .. v.STR .. "(+" .. v.STRplus .. ")")
    end
    if (Primary == "AGI") then
        Ubertip = Ubertip .. "|n" .. hColor.yellow("敏捷：" .. v.AGI .. "(+" .. v.AGIplus .. ")")
    else
        Ubertip = Ubertip .. "|n" .. hColor.yellowLight("敏捷：" .. v.AGI .. "(+" .. v.AGIplus .. ")")
    end
    if (Primary == "INT") then
        Ubertip = Ubertip .. "|n" .. hColor.yellow("智力：" .. v.INT .. "(+" .. v.INTplus .. ")")
    else
        Ubertip = Ubertip .. "|n" .. hColor.yellowLight("智力：" .. v.INT .. "(+" .. v.INTplus .. ")")
    end
    Ubertip = Ubertip .. "|n" .. hColor.greenLight("移动：" .. v.spd .. " " .. CONST_MOVE_TYPE[v.movetp].label)
    Ubertip = Ubertip .. "|n|n" .. v.Ubertip -- 自定义说明会在最后
    local acquire = v.acquire or v.rangeN1 -- 警戒范围
    if (acquire < 1000) then
        acquire = 1000
    end
    local targs1 = v.targs1 or "vulnerable,ground,ward,structure,organic,mechanical,tree,debris,air" --攻击目标
    local Propernames = v.Propernames or v.Name
    local PropernamesArr = string.explode(',', Propernames)
    local abl = {}
    if (type(v.abilList) == "string") then
        abl = string.explode(',', abl)
    elseif (type(v.abilList) == "table") then
        for _, t in pairs(v.abilList) do
            table.insert(abl, t)
        end
    end
    table.insert(abl, "AInv")
    v.weapTp1 = v.weapTp1 or "normal"
    v.goldcost = v.goldcost or 0
    v.lumbercost = v.lumbercost or 0
    --
    local obj = slk.unit.Hpal:new("slk_hero_" .. v.Name)
    if (v.HotKey ~= nil) then
        obj.HotKey = v.HotKey
        v.Buttonpos1 = CONST_HOTKEY_KV[v.HotKey].Buttonpos1 or 0
        v.Buttonpos2 = CONST_HOTKEY_KV[v.HotKey].Buttonpos2 or 0
        obj.Tip = "选择：" .. v.Name .. "(" .. hColor.gold(v.HotKey) .. ")"
    else
        obj.Buttonpos1 = v.Buttonpos1 or 0
        obj.Buttonpos2 = v.Buttonpos2 or 0
        obj.Tip = "选择：" .. v.Name
    end
    obj.Primary = Primary
    obj.Ubertip = Ubertip
    obj.tilesets = 1
    obj.hostilePal = 0
    obj.Requires = "" --需求,全部无限制，用代码限制
    obj.Requirescount = 1
    obj.Requires1 = ""
    obj.Requires2 = ""
    obj.upgrade = ""
    obj.unitShadow = "ShadowFlyer"
    obj.death = 0.10
    obj.turnRate = 1.00
    obj.acquire = acquire
    obj.weapsOn = 1
    obj.race = v.race or "human"
    obj.deathType = 0
    obj.fused = 0
    obj.sides1 = v.sides1 or 3 --骰子面
    obj.dice1 = v.dice1 or 2 --骰子数量
    obj.regenMana = v.regenMana or 0.00
    obj.regenHP = v.regenHP or 0.00
    obj.stockStart = v.stockStart or 0 -- 库存开始
    obj.stockRegen = v.stockRegen or 0 -- 进货周期
    obj.stockMax = v.stockMax or 1 -- 最大库存
    obj.collision = 32 --接触体积
    obj.def = v.def or 0.00 -- 护甲
    obj.sight = v.sight or 1000 -- 白天视野
    obj.nsight = v.nsight or 1000 -- 夜晚视野
    obj.targs1 = targs1
    obj.EditorSuffix = v.EditorSuffix or ""
    obj.Propernames = Propernames
    obj.abilList = string.implode(",", abl)
    obj.heroAbilList = ""
    obj.nameCount = v.nameCount or #PropernamesArr

    if (v.weapTp1 == "normal") then
        obj.weapType1 = v.weapType1 or "" --攻击声音
        obj.Missileart = ""
        obj.Missilespeed = 0
        obj.Missilearc = 0
    else
        obj.weapType1 = "" --攻击声音
        obj.Missileart = v.Missileart -- 箭矢模型
        obj.Missilespeed = v.Missilespeed or 1100 -- 箭矢速度
        obj.Missilearc = v.Missilearc or 0.05
    end
    if (v.weapTp1 == "msplash" or v.weapTp1 == "artillery") then
        --溅射/炮火
        obj.Farea1 = v.Farea1 or 1
        obj.Qfact1 = v.Qfact1 or 0.05
        obj.Qarea1 = v.Qarea1 or 500
        obj.Hfact1 = v.Hfact1 or 0.15
        obj.Harea1 = v.Harea1 or 350
        obj.splashTargs1 = targs1 .. ",enemies"
    elseif (v.weapTp1 == "mbounce") then
        --弹射
        obj.Farea1 = v.Farea1 or 450
        obj.targCount1 = v.targCount1 or 4
        obj.damageLoss1 = v.damageLoss1 or 0.3
        obj.splashTargs1 = targs1 .. ",enemies"
    elseif (v.weapTp1 == "mline") then
        --穿透
        obj.spillRadius = v.spillRadius or 200
        obj.spillDist1 = v.spillDist1 or 450
        obj.damageLoss1 = v.damageLoss1 or 0.3
        obj.splashTargs1 = targs1 .. ",enemies"
    elseif (v.weapTp1 == "aline") then
        --炮火穿透
        obj.Farea1 = v.Farea1 or 1
        obj.Qfact1 = v.Qfact1 or 0.05
        obj.Qarea1 = v.Qarea1 or 500
        obj.Hfact1 = v.Hfact1 or 0.15
        obj.Harea1 = v.Harea1 or 350
        obj.spillRadius = v.spillRadius or 200
        obj.spillDist1 = v.spillDist1 or 450
        obj.damageLoss1 = v.damageLoss1 or 0.3
        obj.splashTargs1 = targs1 .. ",enemies"
    end
    obj.Name = v.Name
    obj.Awakentip = "唤醒：" .. v.Name
    obj.Revivetip = "复活：" .. v.Name
    obj.unitSound = v.unitSound or "" -- 声音
    obj.modelScale = v.modelScale or 1.00 --模型缩放
    obj.file = v.file --模型
    obj.fileVerFlags = v.fileVerFlags or 0
    obj.Art = v.Art --头像
    obj.scale = v.scale or 1.00 --选择圈
    obj.movetp = v.movetp or "foot" --移动类型
    obj.moveHeight = v.moveHeight or 0 --移动高度
    obj.moveFloor = math.floor((v.moveHeight or 0) * 0.25) --最低高度
    obj.spd = v.spd or 275
    obj.backSw1 = v.backSw1 or 0.500
    obj.dmgpt1 = v.dmgpt1 or 0.500
    obj.rangeN1 = v.rangeN1 or 100
    obj.cool1 = v.cool1 or 2.00
    obj.armor = v.armor or "Flesh" -- 被击声音
    obj.targType = v.targType or "ground" --作为目标类型
    obj.weapTp1 = v.weapTp1 --攻击类型
    obj.dmgplus1 = v.dmgplus1 or 10 -- 基础攻击
    obj.showUI1 = v.showUI1 or 1 -- 显示攻击按钮
    obj.STR = v.STR
    obj.AGI = v.AGI
    obj.INT = v.INT
    obj.STRplus = v.STRplus
    obj.AGIplus = v.AGIplus
    obj.INTplus = v.INTplus
    obj.goldcost = v.goldcost
    obj.lumbercost = v.lumbercost
    local id = obj:get_id()
    table.insert(slkHelperHashData, {
        type = "unit",
        data = {
            UNIT_ID = id,
            UNIT_TYPE = "hero",
            Primary = Primary,
            Name = v.Name,
            Art = v.Art,
            file = v.file,
            goldcost = v.goldcost,
            lumbercost = v.lumbercost,
            CUSTOM_DATA = v.CUSTOM_DATA or {},
        }
    })
    return id
end
