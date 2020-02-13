hdzapi = {}
hdzapi.hdz_map_lv = 10001

-- 是否红V
hdzapi.isVipRed = function(whichPlayer)
    return japi.DzAPI_Map_IsRedVIP(whichPlayer)
end

-- 是否蓝V
hdzapi.isVipBlue = function(whichPlayer)
    return japi.DzAPI_Map_IsBlueVIP(whichPlayer)
end

-- 获取地图等级
hdzapi.mapLv = function(whichPlayer)
    return japi.DzAPI_Map_GetMapLevel(whichPlayer) or 1
end

-- 是否有商城道具
hdzapi.hasMallItem = function(whichPlayer, key)
    return japi.DzAPI_Map_HasMallItem(whichPlayer, key)
end

-- 设置房间数据
hdzapi.setRoomStat = function(whichPlayer, key, text)
    japi.DzAPI_Map_Stat_SetStat(whichPlayer, tostring(key), tostring(text))
end

-- 服务器存档
hdzapi.server = {}
-- 读取服务器存档是否成功，没有开通或这服务器崩了返回false
hdzapi.server.ready = function(whichPlayer)
    if (whichPlayer == nil) then
        return false
    end
    return japi.GetPlayerServerValueSuccess(whichPlayer)
end

-- save / load
hdzapi.server.save = function(whichPlayer, key, data)
    if (data == nil) then
        return
    end
    if (hdzapi.server.ready(whichPlayer) == true) then
        japi.DzAPI_Map_SaveServerValue(whichPlayer, key, data)
    end
end

hdzapi.server.load = function(whichPlayer, key)
    if (hdzapi.server.ready(whichPlayer) == true) then
        return japi.DzAPI_Map_GetServerValue(whichPlayer, key)
    end
end

-- 清理服务器存档数据
hdzapi.server.clear = function(whichPlayer, key)
    if (hdzapi.server.ready(whichPlayer) == true) then
        japi.DzAPI_Map_SaveServerValue(whichPlayer, key, nil)
    end
end

-- 封装的服务器存档 get / set
hdzapi.server.set = {
    int = function(whichPlayer, key, data)
        hdzapi.server.save(whichPlayer, "I" .. key, data or 0)
    end,
    real = function(whichPlayer, key, data)
        hdzapi.server.save(whichPlayer, "R" .. key, data or 0)
    end,
    bool = function(whichPlayer, key, data)
        local b = "0"
        if (data == true) then
            b = "1"
        end
        hdzapi.server.save(whichPlayer, "B" .. key, data or 0)
    end,
    str = function(whichPlayer, key, data)
        hdzapi.server.save(whichPlayer, "S" .. key, data)
    end,
    unit = function(whichPlayer, key, data)
        hdzapi.server.save(whichPlayer, "S" .. key, hunit.getId(data))
    end,
    item = function(whichPlayer, key, data)
        hdzapi.server.save(whichPlayer, "S" .. key, hitem.getId(data))
    end
}
hdzapi.server.get = {
    int = function(whichPlayer, key)
        local val = hdzapi.server.load(whichPlayer, "I" .. key) or 0
        if (val == "") then
            val = 0
        end
        return math.floor(val)
    end,
    real = function(whichPlayer, key)
        local val = hdzapi.server.load(whichPlayer, "R" .. key) or 0
        if (val == "") then
            val = 0
        end
        return math.round(val)
    end,
    bool = function(whichPlayer, key)
        local b = hdzapi.server.load(whichPlayer, "B" .. key)
        if (b == "1") then
            return true
        end
        return false
    end,
    str = function(whichPlayer, key)
        return hdzapi.server.load(whichPlayer, "S" .. key) or ""
    end,
    unit = function(whichPlayer, key)
        local id = hdzapi.server.load(whichPlayer, "S" .. key) or ""
        if (string.len(id) > 0) then
            return string.char2id(id)
        end
        return ""
    end,
    item = function(whichPlayer, key)
        local id = hdzapi.server.load(whichPlayer, "S" .. key) or ""
        if (string.len(id) > 0) then
            return string.char2id(id)
        end
        return ""
    end
}
