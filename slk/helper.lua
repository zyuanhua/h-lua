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
        if (table.includes(k, {"life_back", "mana_back"})) then
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
        str = str .. (CONST_ATTR[k] or "") .. "："
        if (k == "attack_damage_type") then
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
            ))
         then
            local temp = ""
            for kk, vv in pairs(v) do
                temp = temp .. (CONST_ATTR[kk] or "")
                local temp2 = ""
                for kkk, vvv in pairs(vv) do
                    if (kkk ~= "effect") then
                        if (kkk == "during") then
                            vvv = vvv .. "秒"
                        end
                        if (table.includes(kkk, {"odds", "reduce", "percent"})) then
                            vvv = vvv .. "%"
                        end
                        if (kkk == "attr") then
                            vvv = "类别[" .. CONST_ATTR[vvv] .. "]"
                        else
                            vvv = (CONST_ATTR[kkk] or "") .. "[" .. vvv .. "]"
                        end
                        if (temp2 == "") then
                            temp2 = temp2 .. vvv
                        else
                            temp2 = temp2 .. "," .. vvv
                        end
                    end
                end
                temp = temp .. temp2
            end
            str = str .. temp
        else
            str = str .. v
        end
        str = str .. sep
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
    if (v.ATTR ~= nil and table.len(v.ATTR) >= 1) then
        table.insert(d, slkHelper.attrForItem(v.ATTR, ";"))
    end
    if (v.Description ~= nil and v.Description ~= "") then
        table.insert(d, v.Description)
    end
    return string.implode("|n", d)
end

-- 组装物品的说明
slkHelper.itemUbertip = function(v)
    local desc = ""
    local d = {}
    if (v.ATTR ~= nil and table.len(v.ATTR) >= 1) then
        table.insert(d, hColor.yellow(slkHelper.attrForItem(v.ATTR, "|n")))
    end
    if (v.ACTIVE ~= nil) then
        table.insert(d, hColor.red("主动：" .. v.ACTIVE))
    end
    if (v.PASSIVE ~= nil) then
        table.insert(d, hColor.seaLight(v.PASSIVE))
    end
    if (v.Description ~= nil) then
        table.insert(d, hColor.grey(v.Description))
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
