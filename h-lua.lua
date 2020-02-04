-- 加载YDWE本体库
cj = require "jass.common"
gctl = require "jass.message"
cg = require "jass.globals"
japi = require "jass.japi"

-- 加载blizzard
require "foundation.blizzard_c"
require "foundation.blizzard_b"
bj = require "foundation.blizzard_bj"

-- 加载const
require "const.index"

-- 加载foundation
hLuaStart = require "foundation.index"

--[[
    加载Dzapi库
    需要编辑器支持网易平台的DZAPI
    如果在lua中无法找到Dzapi，你需要检查下面的部分：
    1. YDWE——配置——魔兽插件——[勾上]LUA引擎——[勾上]Dzapi（不行就做第2步）
    2. 打开触发窗口（F4），创建一个不运行的触发（无事件），在条件及动作补充你需要的Dzapi
]]
require "lib.dzapi"

-- 加载h-lua库
require "lib.time" -- 时间/计时器
require "lib.is" -- 条件判断
require "lib.message" -- 消息
require "lib.sound" -- 多媒体
require "lib.mark" -- 遮罩
require "lib.effect" -- 特效
require "lib.lightning" -- 闪电链
require "lib.weather" -- 天气
require "lib.env" -- 环境装饰
require "lib.camera" -- 镜头
require "lib.event" -- 事件
require "lib.textTag" -- 漂浮字
require "lib.rect" -- 区域
require "lib.player" -- 玩家
require "lib.award" -- 奖励
require "lib.unit" -- 单位
require "lib.enemy" -- 敌人
require "lib.group" -- 单位组
require "lib.hero" -- 英雄
require "lib.skill.index" -- 技能
require "lib.attribute" -- 属性
require "lib.item" -- 物品
require "lib.dialog" -- 对话框
require "lib.leaderBoard" -- 排行榜
require "lib.multiBoard" -- 多面板
require "lib.quest" -- 任务
--别称
hmsg = hmessage
httg = htextTag
hattribute = hattr

-- 最后的初始化run
-- last init
hLuaStart.run()
