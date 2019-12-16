-- [[奖励]]
local haward = {
    shareRange = 1000.00
}
-- 设置共享范围
haward.setShareRange = function(range)
    haward.shareRange = hlogic.round(range)
end
-- 奖励单位（经验黄金木头）
haward.forUnit = function(whichUnit, exp, gold, lumber)
    local floatStr = ""
    local realExp = exp
    local realGold = gold
    local realLumber = lumber
    local index = 0
    local ttgColorLen = 0
    local ttg
    local p
    if (whichUnit == nil) then
        return
    end
    p = cj.GetOwningPlayer(whichUnit)
    index = hplayer.index(p)
    -- 增益
    realGold = cj.R2I(gold * hplayer.getGoldRatio(p) / 100.00)
    realLumber = cj.R2I(lumber * hplayer.getLumberRatio(p) / 100.00)
    realExp = cj.R2I(exp * hplayer.getExpRatio(p) / 100.00)
    if (realExp >= 1 and his.hero(whichUnit)) then
        cj.AddHeroXP(whichUnit, realExp, true)
        floatStr = floatStr .. "|cffc4c4ff" .. realExp .. "Exp" .. "|r"
        ttgColorLen = ttgColorLen + 12
    end
    if (realGold >= 1) then
        hplayer.addGold(p, realGold)
        floatStr = floatStr .. " |cffffcc00" .. realGold .. "G" .. "|r"
        ttgColorLen = ttgColorLen + 13
        hsound.sound2Unit(cg.gg_snd_ReceiveGold, 100, whichUnit)
    end
    if (realLumber >= 1) then
        hplayer.addLumber(p, realLumber)
        floatStr = floatStr .. " |cff80ff80" .. realLumber .. "L" .. "|r"
        ttgColorLen = ttgColorLen + 13
        hsound.sound2Unit(cg.gg_snd_BundleOfLumber, 100, whichUnit)
    end
    ttg = htextTag.create2Unit(whichUnit, floatStr, 7, "", 0, 1.70, 60.00)
    cj.SetTextTagPos(ttg, cj.GetUnitX(whichUnit) - (string.len(floatStr) - ttgColorLen) * 7 * 0.5, cj.GetUnitY(whichUnit), 50)
    htextTag.style(ttg, "toggle", 0, 0.23)
end
-- 奖励单位经验
haward.forUnitExp = function(whichUnit, exp)
    return haward.forUnit(whichUnit, exp, 0, 0)
end
-- 奖励单位黄金
haward.forUnitGold = function(whichUnit, gold)
    return haward.forUnit(whichUnit, 0, gold, 0)
end
-- 奖励单位木头
haward.forUnitLumber = function(whichUnit, lumber)
    return haward.forUnit(whichUnit, 0, 0, lumber)
end

-- 平分奖励英雄组（经验黄金木头）
haward.forGroup = function(whichUnit, exp, gold, lumber)
    local cutExp = 0
    local cutGold = 0
    local cutLumber = 0
    local g = hgroup.createByUnit(whichUnit, haward.shareRange, function()
        local flag = true
        if (his.hero(cj.GetFilterUnit()) == false) then
            flag = false
        end
        if (his.ally(whichUnit, cj.GetFilterUnit()) == false) then
            flag = false
        end
        if (his.alive(cj.GetFilterUnit()) == false) then
            flag = false
        end
        if (his.building(cj.GetFilterUnit()) == true) then
            flag = false
        end
        return flag
    end)
    local gCount = hgroup.count(g)
    if (gCount <= 0) then
        return
    end
    cutExp = cj.R2I(exp / gCount)
    cutGold = cj.R2I(gold / gCount)
    cutLumber = cj.R2I(lumber / gCount)
    if (exp > 0 and cutExp < 1) then
        cutExp = 1
    end
    cj.ForGroup(g, function()
        local u = cj.GetEnumUnit()
        haward.forUnit(u, cutExp, cutGold, cutLumber)
    end)
    cj.GroupClear(g)
    cj.DestroyGroup(g)
end
-- 平分奖励英雄组（经验）
haward.forGroupExp = function(whichUnit, exp)
    haward.forGroup(whichUnit, exp, 0, 0)
end
-- 平分奖励英雄组（黄金）
haward.forGroupGold = function(whichUnit, gold)
    haward.forGroup(whichUnit, 0, gold, 0)
end
-- 平分奖励英雄组（木头）
haward.forGroupLumber = function(whichUnit, lumber)
    haward.forGroup(whichUnit, 0, 0, lumber)
end

-- 平分奖励玩家组（黄金木头）
haward.forPlayer = function(gold, lumber)
    if (hplayer.qty_current <= 0) then
        return
    end
    local cutGold = math.floor(gold / hplayer.qty_current)
    local cutLumber = math.floor(lumber / hplayer.qty_current)
    for i = 1, hplayer.qty_max, 1 do
        if (hplayer.getStatus(hplayer.players[i]) == hplayer.player_status.gaming) then
            if (cutGold > 0) then
                hplayer.addGold(hplayer.players[i], cutGold)
            end
            if (cutLumber > 0) then
                hplayer.addLumber(hplayer.players[i], cutLumber)
            end
        end
    end
end
-- 平分奖励玩家组（黄金）
haward.forPlayerGold = function(gold)
    haward.forPlayer(gold, 0)
end
-- 平分奖励玩家组（木头）
haward.forPlayerLumber = function(lumber)
    haward.forPlayer(0, lumber)
end

return haward