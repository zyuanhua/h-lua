-- [[对话框]]
local hdialog = {}

-- 创建一个新的对话框
hdialog.create = function(whichPlayer, options, call)
    local d = cj.DialogCreate()
    local btnKv = {}
    cj.DialogSetMessage(d, options.title)
    if (#options.buttons == hSys.getTableLen(options.buttons)) then
        for i = 1, #options.buttons, 1 do
            local b = cj.DialogAddButton(d, options.buttons[i], 0)
            btnKv[b] = options.buttons[i]
        end
    else
        for k, v in pairs(options.buttons) do
            local b = cj.DialogAddButton(d, v, 0)
            btnKv[b] = k
        end
    end
    local dtg = cj.CreateTrigger()
    cj.TriggerAddAction(
        dtg,
        function()
            local tri_d = cj.GetClickedDialog()
            local tri_b = cj.GetClickedButton()
            local tri_bi = btnKv[tri_b]
            call(tri_bi)
            cj.DialogClear(tri_d)
            cj.DialogDestroy(tri_b)
            cj.DisableTrigger(cj.GetTriggeringTrigger())
            cj.DestroyTrigger(cj.GetTriggeringTrigger())
        end
    )
    cj.TriggerRegisterDialogEvent(dtg, d)
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

return hdialog
