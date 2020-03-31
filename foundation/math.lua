-- 随机整数
math.random = function(n, m)
    local func = cj.GetRandomReal
    if (n == nil or m == nil) then
        -- 0.00 ~ 1.00
        return math.floor((func(0.000, 1.000) * 100) + 0.5) * 0.01
    end
    if (n == m) then
        return n
    end
    local fn = string.find(tostring(n), "[.]", 0)
    local fm = string.find(tostring(m), "[.]", 0)
    if (type(fn) ~= "number" and type(fm) ~= "number") then
        func = cj.GetRandomInt
        n = math.floor(n)
        m = math.floor(m)
    end
    if (m < n) then
        return func(m, n)
    end
    return func(n, m)
end

-- 极坐标位移
math.polarProjection = function(x, y, dist, angle)
    return {
        x = x + dist * math.cos(angle * bj_DEGTORAD),
        y = y + dist * math.sin(angle * bj_DEGTORAD)
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
        txt = string.format("%.2f", value / 10000 * 10000 * 10000 * 10000) .. "亿亿"
    elseif (value > 10000 * 10000 * 10000) then
        txt = string.format("%.2f", value / 10000 * 10000 * 10000) .. "万亿"
    elseif (value > 10000 * 10000) then
        txt = string.format("%.2f", value / 10000 * 10000) .. "亿"
    elseif (value > 10000) then
        txt = string.format("%.2f", value / 10000) .. "万"
    elseif (value > 1000) then
        txt = string.format("%.2f", value / 1000) .. "千"
    else
        txt = string.format("%.2f", value)
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

--[[
    获取矩形区域内某角度距离边缘最大距离
    w = 区域长
    h = 区域宽
    deg = 角度
]]
math.getMaxDistanceInRect = function(w, h, deg)
    w = w or 0
    h = h or 0
    if (w <= 0 or h <= 0) then
        return
    end
    local distance = 0
    local lockDegA = (180 * cj.Atan(h / w)) / bj_PI
    local lockDegB = 90 - lockDegA
    if (deg == 0 or deg == 180 or deg == -180) then
        -- 横
        distance = w
    elseif (deg == 90 or deg == -90) then
        -- 竖
        distance = h
    elseif (deg > 0 and deg <= lockDegA) then
        -- 第1三角区间
        distance = w / 2 / math.cos(deg * bj_DEGTORAD)
    elseif (deg > lockDegA and deg < 90) then
        -- 第2三角区间
        distance = h / 2 / math.cos(90 - deg * bj_DEGTORAD)
    elseif (deg > 90 and deg <= 90 + lockDegB) then
        -- 第3三角区间
        distance = h / 2 / math.cos((deg - 90) * bj_DEGTORAD)
    elseif (deg > 90 + lockDegB and deg < 180) then
        -- 第4三角区间
        distance = w / 2 / math.cos((180 - deg) * bj_DEGTORAD)
    elseif (deg < 0 and deg >= -lockDegA) then
        -- 第5三角区间
        distance = w / 2 / math.cos(deg * bj_DEGTORAD)
    elseif (deg < lockDegA and deg > -90) then
        -- 第6三角区间
        distance = h / 2 / math.cos((90 + deg) * bj_DEGTORAD)
    elseif (deg < -90 and deg >= -90 - lockDegB) then
        -- 第7三角区间
        distance = h / 2 / math.cos((-deg - 90) * bj_DEGTORAD)
    elseif (deg < -90 - lockDegB and deg > -180) then
        -- 第8三角区间
        distance = w / 2 / math.cos((180 + deg) * bj_DEGTORAD)
    end
    return distance
end
