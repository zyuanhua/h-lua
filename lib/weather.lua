local hweather = {
    --天气ID
    sun = hstring.char2id('LRaa'), --日光
    moon = hstring.char2id('LRma'), --月光
    shield = hstring.char2id('MEds'), --紫光盾
    rain = hstring.char2id('RAlr'), --雨
    rainstorm = hstring.char2id('RAhr'), --大雨
    snow = hstring.char2id('SNls'), --雪
    snowstorm = hstring.char2id('SNhs'), --大雪
    wind = hstring.char2id('WOlw'), --风
    windstorm = hstring.char2id('WNcw'), --大风
    mistwhite = hstring.char2id('FDwh'), --白雾
    mistgreen = hstring.char2id('FDgh'), --绿雾
    mistblue = hstring.char2id('FDbh'), --蓝雾
    mistred = hstring.char2id('FDrh'), --红雾
}

--删除天气
hweather.del = function(w, during)
    if (during <= 0) then
        cj.EnableWeatherEffect(w, false)
        cj.RemoveWeatherEffect(w)
    else
        htime.setTimeout(during, function(t, td)
            htime.delDialog(td)
            htime.delTimer(t)
            cj.EnableWeatherEffect(w, false)
            cj.RemoveWeatherEffect(w)
        end)
    end
end
--[[
    创建天气
    options = {
        x=0,y=0, 坐标
        w=0,h=0, 长宽
        type=hweather.sun 天气类型
        during=10 持续时间小于等于0=无限
    }
]]--
hweather.create = function(bean)
    if (bean.w == nil or bean.h == nil or bean.w <= 0 or bean.h <= 0) then
        print_err("hweather.create -w-h")
        return nil
    end
    if (bean.x == nil or bean.y == nil) then
        print_err("hweather.create -x-y")
        return nil
    end
    if (bean.type == nil) then
        print_err("hweather.create -type")
        return nil
    end
    local r = hrect.createLoc(bean.x, bean.y, bean.w, bean.h)
    local w = cj.AddWeatherEffect(r, bean.type)
    if (bean.during > 0) then
        htime.setTimeout(bean.during, function(t, td)
            htime.delDialog(td)
            htime.delTimer(t)
            cj.RemoveRect(r)
            cj.EnableWeatherEffect(w, false)
            cj.RemoveWeatherEffect(w)
        end)
    end
end

return hweather
