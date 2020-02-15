-- 加载YDWE库
cj = require "jass.common"
cg = require "jass.globals"

-- 加载blizzard
require "foundation.blizzard_c"
require "foundation.blizzard_b"
require "foundation.blizzard_bj"

-- 加载const
require "const.attribute"
require "const.damageKind"
require "const.damageType"
require "const.hero"
require "const.hotKey"
require "const.item"
require "const.unit"
require "const.playerColor"
require "const.event"

-- 加载foundation
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

-- 加载Dzapi库
-- 需要编辑器支持网易平台的DZAPI
-- 如果在lua中无法找到Dzapi，你需要检查下面的部分：
-- 1. YDWE——配置——魔兽插件——[勾上]LUA引擎——[勾上]Dzapi（不行就做第2步）
-- 2. 打开触发窗口（F4），创建一个不运行的触发（无事件），在条件及动作补充你需要的Dzapi
require "lib.dzapi"

-- 加载h-lua库
require "lib.time"
require "lib.is"
require "lib.message"
require "lib.sound"
require "lib.mark"
require "lib.effect"
require "lib.lightning"
require "lib.weather"
require "lib.env"
require "lib.camera"
require "lib.event"
require "lib.textTag"
require "lib.rect"
require "lib.player"
require "lib.award"
require "lib.unit"
require "lib.enemy"
require "lib.group"
require "lib.hero"
require "lib.skill.index"
require "lib.skill.basic"
require "lib.skill.damage"
require "lib.skill.complex"
require "lib.attribute"
require "lib.item"
require "lib.dialog"
require "lib.leaderBoard"
require "lib.multiBoard"
require "lib.quest"
-- 别称
hmsg = hmessage
httg = htextTag
hattribute = hattr

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

-- DzApi
if (cg.HLUA_DZAPI_FLAG == true) then
    hdzapi.init()
end
