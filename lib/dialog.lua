-- 对话框
hdialog = {
    trigger = nil
}

-- 自动根据key识别热键
hdialog.hotkey = function(key)
    if (key == nil) then
        return 0
    elseif (type(key) == "number") then
        return key
    elseif (type(key) == "string") then
        return string.byte(key, 1)
    else
        return 0
    end
end

-- 创建一个新的对话框
hdialog.create = function(whichPlayer, options, call)
    local d = cj.DialogCreate()
    if (#options.buttons <= 0) then
        print_err("Dialog buttons is empty")
        return
    end
    cj.DialogSetMessage(d, options.title)
    for i = 1, #options.buttons, 1 do
        if (type(options.buttons[i]) == "table") then
            local b = cj.DialogAddButton(d, options.buttons[i].label, hdialog.hotkey(options.buttons[i].value))
            hRuntime.dialog[b] = options.buttons[i].value
        else
            local b = cj.DialogAddButton(d, options.buttons[i], hdialog.hotkey(options.buttons[i]))
            hRuntime.dialog[b] = options.buttons[i]
        end
    end
    if (hdialog.trigger == nil) then
        hdialog.trigger = cj.CreateTrigger()
        cj.TriggerAddAction(
            hdialog.trigger,
            function()
                local tri_d = cj.GetClickedDialog()
                local tri_b = cj.GetClickedButton()
                hRuntime.dialog[tri_d](hRuntime.dialog[tri_b])
                hRuntime.dialog[tri_d] = nil
                hRuntime.dialog[tri_b] = nil
                cj.DialogClear(tri_d)
                cj.DialogDestroy(tri_b)
            end
        )
    end
    hRuntime.dialog[d] = call
    cj.TriggerRegisterDialogEvent(hdialog.trigger, d)
    if (whichPlayer == nil) then
        for i = 1, bj_MAX_PLAYERS, 1 do
            if
                (cj.GetPlayerController(hplayer.players[i]) == MAP_CONTROL_USER and
                    cj.GetPlayerSlotState(hplayer.players[i]) == PLAYER_SLOT_STATE_PLAYING)
             then
                whichPlayer = hplayer.players[i]
                break
            end
        end
    end
    cj.DialogDisplay(whichPlayer, d, true)
end
