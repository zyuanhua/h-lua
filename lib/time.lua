htime = {
    -- 获取开始游戏后经过的总秒数
    count = 0,
    -- 时
    hour = 0,
    -- 分
    min = 0,
    -- 秒
    sec = 0,
    -- 池
    pool = {}
}
-- 时钟
htime.clock = function()
    htime.count = htime.count + 1
    htime.sec = htime.sec + 1
    if (htime.sec >= 60) then
        htime.sec = 0
        htime.min = htime.min + 1
        if (htime.min >= 60) then
            htime.hour = htime.hour + 1
            htime.min = 0
        end
    end
end
-- 获取时分秒
htime.his = function()
    local str = ""
    if (htime.hour < 10) then
        str = str .. "0" .. htime.hour
    else
        str = str .. htime.hour
    end
    str = str .. ":"
    if (htime.min < 10) then
        str = str .. "0" .. htime.min
    else
        str = str .. htime.min
    end
    str = str .. ":"
    if (htime.sec < 10) then
        str = str .. "0" .. htime.sec
    else
        str = str .. htime.sec
    end
    return str
end
-- 从池中获取一个计时器
htime.timerInPool = function()
    local t
    local td
    for timer, v in pairs(htime.pool) do
        if (v.free == true) then
            v.free = false
            t = timer
            td = v.dialog
            break
        end
    end
    if (t == nil) then
        t = cj.CreateTimer()
        td = cj.CreateTimerDialog(t)
        htime.pool[t] = {
            free = false,
            dialog = td
        }
    end
    return {t, td}
end
-- 获取计时器设置时间
htime.getSetTime = function(t)
    if (t == nil) then
        return 0
    else
        return cj.TimerGetTimeout(t)
    end
end
-- 获取计时器剩余时间
htime.getRemainTime = function(t)
    if (t == nil) then
        return 0
    else
        return cj.TimerGetRemaining(t)
    end
end

-- 获取计时器已过去时间
htime.getElapsedTime = function(t)
    if (t == nil) then
        return 0
    else
        return cj.TimerGetElapsed(t)
    end
end
-- 删除计时器
htime.delTimer = function(t)
    if (t == nil) then
        return
    end
    cj.PauseTimer(t)
    cj.TimerDialogDisplay(htime.pool[t].dialog, false)
    htime.pool[t].free = true
    t = nil
end
-- 设置一次性计时器
htime.setTimeout = function(time, yourFunc, title)
    local pool = htime.timerInPool()
    local t = pool[1]
    local td = pool[2]
    if (title ~= nil) then
        cj.TimerDialogSetTitle(td, title)
        cj.TimerDialogDisplay(td, true)
    end
    cj.TimerStart(
        t,
        time,
        false,
        function()
            yourFunc(t)
        end
    )
    return t
end
-- 设置周期性计时器
htime.setInterval = function(time, yourFunc, title)
    local pool = htime.timerInPool()
    local t = pool[1]
    local td = pool[2]
    if (title ~= nil) then
        cj.TimerDialogSetTitle(td, title)
        cj.TimerDialogDisplay(td, true)
    end
    cj.TimerStart(
        t,
        time,
        true,
        function()
            yourFunc(t)
        end
    )
    return t
end
