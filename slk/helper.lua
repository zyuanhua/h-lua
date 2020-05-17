slkHelperHashData = {}

slkHelper = {
    shapeshiftIndex = 1
}

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
        if
        (table.includes(
            k,
            {
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
            }
        ))
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
        elseif
        (table.includes(
            k,
            {
                "attack_buff",
                "attack_debuff",
                "skill_buff",
                "skill_debuff",
                "attack_effect",
                "skill_effect"
            }
        ) == false)
        then
            str = str .. (CONST_ATTR[k] or "") .. "："
            str = str .. v .. sep
        end
    end
    return str
end

slkHelper.attrForItemTable = function(attr, sep)
    local str = ""
    sep = sep or "|n"
    for k, v in pairs(attr) do
        if
        (table.includes(
            k,
            {
                "attack_buff",
                "attack_debuff",
                "skill_buff",
                "skill_debuff",
                "attack_effect",
                "skill_effect"
            }
        ))
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
                    elseif
                    (vv["attr"] == "swim" or vv["attr"] == "silent" or vv["attr"] == "unarm" or
                        vv["attr"] == "fetter")
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

-- 组装物品的描述
slkHelper.itemDesc = function(v)
    local desc = ""
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

-- 组装物品的说明
slkHelper.itemUbertip = function(v)
    local desc = ""
    local d = {}
    if (v.ATTR ~= nil) then
        table.sort(v.ATTR)
        table.insert(
            d,
            hColor.green(slkHelper.attrForItem(v.ATTR, "|n")) .. hColor.yellow(slkHelper.attrForItemTable(v.ATTR, "|n"))
        )
    end
    if (v.ACTIVE ~= nil) then
        table.insert(d, hColor.yellow("主动：" .. v.ACTIVE))
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

-- 创建一件物品的冷却技能
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

-- 创建一件物品
slkHelper.item = function(v)
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
    obj.stockStart = v.stockStart or 0
    obj.stockRegen = v.stockRegen or 1
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
    obj.uses = 1
    if (v.HotKey ~= nil) then
        obj.HotKey = v.HotKey
        v.Buttonpos1 = CONST_HOTKEY_KV[v.HotKey].Buttonpos1 or 0
        v.Buttonpos2 = CONST_HOTKEY_KV[v.HotKey].Buttonpos2 or 0
        obj.Tip = "购买" .. v.Name .. "(" .. hColor.gold(v.HotKey) .. ")"
    else
        obj.Buttonpos1 = v.Buttonpos1 or 0
        obj.Buttonpos2 = v.Buttonpos2 or 0
        obj.Tip = "购买" .. v.Name
    end
    local id = obj:get_id()
    table.insert(slkHelperHashData, {
        type = "item",
        data = json.stringify({
            id = id,
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
        })
    })
    return id
end

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
    local obj = slk.ability.AEme:new("slkh_shapeshift_ta_" .. slkHelper.shapeshiftIndex)
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
    local obj = slk.ability.AEme:new("slkh_shapeshift_ba_" .. slkHelper.shapeshiftIndex)
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
