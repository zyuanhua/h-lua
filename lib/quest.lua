--任务探索
hquest = {}

--删除任务
hquest.del = function(q, during)
    if (during == nil or during <= 0) then
        cj.DestroyQuest(q)
    else
        htime.setTimeout(
            during,
            function(t)
                htime.delTimer(t)
                cj.DestroyQuest(q)
            end
        )
    end
end

--[[
    创建一个任务
    options = {
        side = "left", --位置，默认left
        title = "", --标题
        content = "", --内容，你可以设置一个string或一个table，table会自动便利附加|n（换行）
        icon = "ReplaceableTextures\\CommandButtons\\BTNTomeOfRetraining.blp", --图标
        during = nil, --持续时间，默认为nil，不计时
    }
]]
hquest.create = function(options)
    local side = options.side or "left"
    local title = options.title
    local content = options.content
    local isFinish = options.isFinish
    if (title == nil) then
        return
    end
    if (type(options.content) == "table") then
        content = string.implode("|n", options.content)
    end
    if (content == nil) then
        return
    end
    local questtype = bj_QUESTTYPE_REQ_DISCOVERED
    if (side == "right") then
        questtype = bj_QUESTTYPE_OPT_DISCOVERED
    end
    local icon = options.icon or "ReplaceableTextures\\CommandButtons\\BTNTomeOfRetraining.blp"
    local q = bj.CreateQuestBJ(questtype, title, content, icon)
    if (isFinish == true) then
        cj.QuestSetCompleted(q, true)
    end
    if (options.during ~= nil and options.during > 0) then
        hquest.del(q, options.during)
    end
    return q
end

--令F9按钮闪烁
hquest.flash = function()
    cj.FlashQuestDialogButton()
end

--设置任务为完成
hquest.setCompleted = function(q)
    cj.QuestSetCompleted(q, true)
end

--设置任务为失败
hquest.setFailed = function(q)
    cj.QuestSetFailed(q, true)
end

--设置任务为被发现
hquest.setDiscovered = function(q)
    cj.QuestSetDiscovered(q, true)
end
