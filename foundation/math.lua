
-- 极坐标位移
math.polarProjection = function(x, y, dist, angle)
    return {
        x = x + dist * math.cos(angle * bj_DEGTORAD),
        y = y + dist * math.sin(angle * bj_DEGTORAD),
    }
end

-- 四舍五入
math.round = function(decimal)
    return math.floor((decimal * 100) + 0.5) * 0.01
end

-- 数字格式化
math.numberFormat = function(value)
    local txt = ""
    if (value > 10000 * 10000 * 10000 * 10000) then
        txt = string.format('%.2f', value / 10000 * 10000 * 10000 * 10000) .. "亿亿"
    elseif (value > 10000 * 10000 * 10000) then
        txt = string.format('%.2f', value / 10000 * 10000 * 10000) .. "万亿"
    elseif (value > 10000 * 10000) then
        txt = string.format('%.2f', value / 10000 * 10000) .. "亿"
    elseif (value > 10000) then
        txt = string.format('%.2f', value / 10000) .. "万"
    elseif (value > 1000) then
        txt = string.format('%.2f', value / 1000) .. "千"
    else
        txt = string.format('%.2f', value)
    end
    return txt
end

-- 获取两个坐标间角度，如果其中一个单位为空 返回0
math.getDegBetweenXY = function(x1, y1, x2, y2)
    return bj_RADTODEG * cj.Atan2(y2 - y1, x2 - x1)
end
-- 获取两个点间角度，如果其中一个单位为空 返回0
math.getDegBetweenLoc = function(l1, l2)
    if (l1 == nil or l2 == nil) then
        return 0
    end
    return math.getDegBetweenXY(cj.GetLocationX(l1), cj.GetLocationY(l1), cj.GetLocationX(l2), cj.GetLocationY(l2))
end
-- 获取两个单位间角度，如果其中一个单位为空 返回0
math.getDegBetweenUnit = function(u1, u2)
    if (u1 == nil or u2 == nil) then
        return 0
    end
    return math.getDegBetweenXY(cj.GetUnitX(u1), cj.GetUnitY(u1), cj.GetUnitX(u2), cj.GetUnitY(u2))
end

-- 获取两个坐标距离
math.getDistanceBetweenXY = function(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return cj.SquareRoot(dx * dx + dy * dy)
end
-- 获取两个点距离
math.getDistanceBetweenLoc = function(l1, l2)
    return math.getDistanceBetweenXY(cj.GetLocationX(l1), cj.GetLocationY(l1), cj.GetLocationX(l2), cj.GetLocationY(l2))
end
-- 获取两个单位距离
math.getDistanceBetweenUnit = function(u1, u2)
    return math.getDistanceBetweenXY(cj.GetUnitX(u1), cj.GetUnitY(u1), cj.GetUnitX(u2), cj.GetUnitY(u2))
end
