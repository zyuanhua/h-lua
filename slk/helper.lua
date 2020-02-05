slkHelper = {
    shapeshiftIndex = 1
}

slkHelper.attrForItemDesc = function(attr)
    local str = ""
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
                    "resistance",
                    "avoid",
                    "aim",
                    "knocking",
                    "violence",
                    "knocking_odds",
                    "violence_odds",
                    "hemophagia",
                    "hemophagia_skill",
                    "split",
                    "luck",
                    "invincible",
                    "damage_extent",
                    "damage_rebound",
                    "cure"
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
        str = str .. CONST_ATTR[k] .. "："
        if (type(v) == "table") then
            local temp = ""
            if (table.includes(k, {"attack_damage_type"})) then
                for _, vv in ipairs(v) do
                    if (temp == "") then
                        temp = temp .. CONST_ATTR[vv]
                    else
                        temp = "," .. CONST_ATTR[vv]
                    end
                end
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
                for kk, vv in pairs(v) do
                    temp = temp .. CONST_ATTR[kk]
                    local temp2 = ""
                    for kkk, vvv in pairs(vv) do
                        if (kkk == "during") then
                            vvv = vvv .. "秒"
                        end
                        if (table.includes(kkk, {"odds", "reduce"})) then
                            vvv = vvv .. "%"
                        end
                        if (temp2 == "") then
                            temp2 = temp2 .. CONST_ATTR[kkk] .. "[" .. vvv .. "]"
                        else
                            temp2 = temp2 .. "," .. CONST_ATTR[kkk] .. "[" .. vvv .. "]"
                        end
                    end
                    temp = temp .. temp2
                end
            end
            str = str .. temp
        else
            str = str .. v
        end
        str = str .. "|n"
    end
    return str
end

slkHelper.attrForItemUbertip = function(attr)
    local str = ""
    for k, v in pairs(attr) do
        str = str .. CONST_ATTR[k] .. ":"
        if (type(v) == "table") then
            local temp = ""
            if (k == "attack_damage_type") then
                for _, vv in ipairs(v) do
                    if (temp == "") then
                        temp = temp .. CONST_ATTR[vv]
                    else
                        temp = "," .. CONST_ATTR[vv]
                    end
                end
            end
        else
            str = str .. v
        end
        str = str .. ","
    end
    return str
end

-- 组装物品的描述
slkHelper.itemDesc = function(v)
    local desc = ""
    if (v.ASDescription ~= nil) then
        desc = desc .. hColor.yellow("主动：" .. v.ASDescription) .. "|n"
    end
    if (v.PSDescription ~= nil) then
        desc = desc .. hColor.seaLight(v.PSDescription)
        if (v.Attr == nil and v.Description ~= nil and v.Suffix ~= nil and v.Description ~= "" and v.Suffix ~= "") then
            desc = desc .. "|n|n"
        else
            desc = desc .. "|n"
        end
    end
    if (v.Attr ~= nil and table.len(v.Attr) >= 1) then
        desc = desc .. hColor.yellowLight(slkHelper.attrForItemDesc(v.Attr))
        if ((v.Description ~= nil and v.Description ~= "") or (v.Suffix ~= nil and v.Suffix ~= "")) then
            desc = desc .. "|n"
        end
    end
    if (v.Description ~= nil and v.Description ~= "") then
        desc = desc .. hColor.white(v.Description)
        if (v.Suffix ~= nil and v.Suffix ~= "") then
            desc = desc .. "|n"
        end
    end
    if (v.Suffix ~= nil and v.Suffix ~= "") then
        desc = desc .. hColor.grey(v.Suffix)
    end
    return desc
end

-- 组装物品的说明
slkHelper.itemUbertip = function(v)
    local desc = ""
    if (v.Attr ~= nil and table.len(v.Attr) >= 1) then
        desc = desc .. slkHelper.attrForItemUbertip(v.Attr)
    end
    if (v.ASDescription ~= nil) then
        desc = desc .. "主动使用时可" .. v.ASDescription .. ";"
    end
    if (v.PSDescription ~= nil) then
        desc = desc .. v.PSDescription .. ";"
    end
    if (v.Description ~= nil) then
        desc = desc .. v.Description
    end
    if (v.Suffix ~= nil) then
        desc = desc .. ";" .. v.Suffix
    end
    return desc
end

-- 创建一件物品的冷却技能
slkHelper.itemCooldownID = function(v)
    if (v.cooldownID == nil) then
        return "AIat"
    end
    if (v.cooldownID < 0) then
        v.cooldownID = 0
    end
    local oobTips = "ITEMS_DEFCD_ID_" .. k
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
    oob.Cool = v.cooldownID
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
