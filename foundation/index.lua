-- 加载debug
require "foundation.debug"

-- 加载json
require "foundation.json"

-- 加载md5
require "foundation.md5"

-- 加载runtime
require "foundation.runtime"

-- 加载table
require "foundation.table"

-- 加载string
require "foundation.string"

-- 加载math
require "foundation.math"

-- 加载color
require "foundation.color"

-- 加载h-lua的F9
require "foundation.f9"

-- 加载runtime
require "foundation.slk"

hLuaStart = {
    run = function()
        -- 时钟初始化
        -- 全局计时器
        cj.TimerStart(cj.CreateTimer(), 1.00, true, htime.clock)

        -- 预读preread
        local u = cj.CreateUnit(hplayer.player_passive, hslk_global.unit_token, 0, 0, 0)
        hattr.regAllAbility(u)
        hunit.del(u)

        -- 玩家
        hplayer.init()
        -- 物品
        hitem.init()
        -- 单位
        hunit.init()

        --DzApi
        if (cg.HLUA_DZAPI_FLAG == true) then
            hdzapi.init()
        end
    end
}

return hLuaStart
