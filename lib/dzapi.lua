hdzapi = {
    enable = false,
    commandHashCache = {},
    commandHash = function(command)
        if (hdzapi.commandHashCache[command] == nil) then
            hdzapi.commandHashCache[command] = cj.StringHash(command)
        end
        return hdzapi.commandHashCache[command]
    end,
    exec = function(command, ...)
        if (hdzapi.enable ~= true) then
            print_err("Please copy ./plugin/dzapi.jass")
            return
        end
        local whichPlayer = select("1", ...)
        local key = select("2", ...)
        local data = select("3", ...)
        if (whichPlayer == nil) then
            return
        end
        if (his.playing(whichPlayer) == false) then
            return false
        end
        cj.SavePlayerHandle(cg.hash_hlua_dzapi, hdzapi.commandHash(command), cg.HLDK_PLAYER, whichPlayer)
        if (key ~= nil) then
            cj.SaveStr(cg.hash_hlua_dzapi, hdzapi.commandHash(command), cg.HLDK_KEY, key)
        end
        if (data ~= nil) then
            cj.SaveStr(cg.hash_hlua_dzapi, hdzapi.commandHash(command), cg.HLDK_DATA, data)
        end
        cj.ExecuteFunc(command)
        local res = cj.LoadStr(cg.hash_hlua_dzapi, hdzapi.commandHash(command), cg.HLDK_RESULT)
        if (type(res) == "string") then
            return res
        end
    end
}

-- 初始化
hdzapi.init = function()
    hdzapi.enable = true
end

-- 是否红V
hdzapi.isVipRed = function(whichPlayer)
    return hdzapi.exec("Hlua_DzAPI_Map_IsRedVIP", whichPlayer) == "1"
end

-- 是否蓝V
hdzapi.isVipBlue = function(whichPlayer)
    return hdzapi.exec("Hlua_DzAPI_Map_IsBlueVIP", whichPlayer) == "1"
end

-- 获取地图等级
hdzapi.mapLv = function(whichPlayer)
    local lv = hdzapi.exec("Hlua_DzAPI_Map_GetMapLevel", whichPlayer)
    if (lv == nil or lv == "") then
        lv = 1
    else
        lv = math.floor(lv)
    end
    if (lv < 1) then
        lv = 1
    end
    return lv
end

-- 是否有商城道具
hdzapi.hasMallItem = function(whichPlayer, key)
    return hdzapi.exec("Hlua_DzAPI_Map_HasMallItem", whichPlayer, key) == "1"
end

-- 服务器存档
hdzapi.server = {}
-- 读取服务器存档是否成功，没有开通或这服务器崩了返回false
hdzapi.server.ready = function(whichPlayer)
    return hdzapi.exec("Hlua_DzAPI_GetPlayerServerValueSuccess", whichPlayer) == "1"
end

-- 设置房间数据
hdzapi.setRoomStat = function(whichPlayer, key, text)
    if (hdzapi.server.ready(whichPlayer) == true) then
        hdzapi.exec("Hlua_DzAPI_Map_Stat_SetStat", whichPlayer, tostring(key), tostring(text))
    end
end

-- save / load
hdzapi.server.save = function(whichPlayer, key, data)
    if (data == nil) then
        return
    end
    if (hdzapi.server.ready(whichPlayer) == true) then
        hdzapi.exec("Hlua_DzAPI_Map_SaveServerValue", whichPlayer, key, tostring(data))
    end
end

hdzapi.server.load = function(whichPlayer, key)
    if (hdzapi.server.ready(whichPlayer) == true) then
        return hdzapi.exec("Hlua_DzAPI_Map_GetServerValue", whichPlayer, key)
    end
end

-- 清理服务器存档数据
hdzapi.server.clear = function(whichPlayer, key)
    if (hdzapi.server.ready(whichPlayer) == true) then
        hdzapi.exec("Hlua_DzAPI_Map_SaveServerValue", whichPlayer, key, "")
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
        hdzapi.server.save(whichPlayer, "B" .. key, b)
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
        return nil
    end,
    item = function(whichPlayer, key)
        local id = hdzapi.server.load(whichPlayer, "S" .. key) or ""
        if (string.len(id) > 0) then
            return string.char2id(id)
        end
        return nil
    end
}
