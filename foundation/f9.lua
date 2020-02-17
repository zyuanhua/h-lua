-- h-lua 系统提醒（F9任务）
local txt = ""
txt = txt .. "h-lua完全独立，不依赖任何游戏平台（如YDWE、JAPI、DzApi * 支持使用）"
txt = txt .. "|n包含多样丰富的属性系统，可以轻松做出平时难以甚至不能做出的地图效果"
txt = txt .. "|n内置多达几十种以上的自定义事件，轻松实现神奇的主动和被动效果"
txt = txt .. "|n自带物品合成，免去自行编写的困惑。丰富的自定义技能模板"
txt = txt .. "|n镜头、单位组、过滤器、背景音乐、天气等也应有尽有"
txt = txt .. "|n想要了解更多，官方QQ群：325338043 官网教程：hlua.book.hunzsig.org"
bj.CreateQuestBJ(
    bj_QUESTTYPE_OPT_DISCOVERED,
    "h-lua",
    txt,
    "ReplaceableTextures\\CommandButtons\\BTNTomeOfRetraining.blp"
)
txt = ""
txt = txt .. "-random 随机选择"
txt = txt .. "|n-repick 重新选择"
bj.CreateQuestBJ(
    bj_QUESTTYPE_OPT_DISCOVERED,
    "选择英雄指令",
    txt,
    "ReplaceableTextures\\CommandButtons\\BTNTomeOfRetraining.blp"
)
txt = ""
txt = txt .. "-apc 设定是否自动转换黄金为木头"
txt = txt .. "|n获得黄金超过100万时，自动按照比率转换多余的部分为木头"
txt = txt .. "|n如果超过时没有开启，会寄存下来，待开启再转换(上限1000万)"
bj.CreateQuestBJ(
    bj_QUESTTYPE_OPT_DISCOVERED,
    "设定自动转金为木",
    txt,
    "ReplaceableTextures\\CommandButtons\\BTNTomeOfRetraining.blp"
)
txt = ""
txt = txt .. "-apm 查看你的APM数值"
bj.CreateQuestBJ(
    bj_QUESTTYPE_OPT_DISCOVERED,
    "查看你的APM数值",
    txt,
    "ReplaceableTextures\\CommandButtons\\BTNTomeOfRetraining.blp"
)
txt = ""
txt = txt .. "+[number] 增加视距|n-[number] 减少视距"
txt = txt .. "|n * 视距自动设置上下限，请放心设置"
bj.CreateQuestBJ(
    bj_QUESTTYPE_OPT_DISCOVERED,
    "调整你的视距",
    txt,
    "ReplaceableTextures\\CommandButtons\\BTNTomeOfRetraining.blp"
)
txt = ""
txt = txt .. "-eff 开关特效"
txt = txt .. "|n这个命令只有在单人时有效，可关闭大部分的特效"
bj.CreateQuestBJ(
    bj_QUESTTYPE_OPT_DISCOVERED,
    "开关特效[单人]",
    txt,
    "ReplaceableTextures\\CommandButtons\\BTNTomeOfRetraining.blp"
)
