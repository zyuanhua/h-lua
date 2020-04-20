bj = {}

bj.VolumeGroupSetVolumeForPlayerBJ = function(whichPlayer, vgroup, scale)
    if cj.GetLocalPlayer() == whichPlayer then
        cj.VolumeGroupSetVolume(vgroup, scale)
    end
end
bj.TriggerRegisterAnyUnitEventBJ = function(trig, whichEvent)
    for i = 1, bj_MAX_PLAYER_SLOTS, 1 do
        cj.TriggerRegisterPlayerUnitEvent(trig, cj.Player(i - 1), whichEvent, nil)
    end
end
bj.AllowVictoryDefeatBJ = function(gameResult)
    if (gameResult == PLAYER_GAME_RESULT_VICTORY) then
        return not cj.IsNoVictoryCheat()
    end
    if (gameResult == PLAYER_GAME_RESULT_DEFEAT) then
        return not cj.IsNoDefeatCheat()
    end
    if (gameResult == PLAYER_GAME_RESULT_NEUTRAL) then
        return (not cj.IsNoVictoryCheat()) and (not cj.IsNoDefeatCheat())
    end
    return true
end
bj.CustomDefeatDialogBJ = function(whichPlayer, message)
    local t = cj.CreateTrigger()
    local d = cj.DialogCreate()
    cj.DialogSetMessage(d, message)
    cj.TriggerRegisterDialogButtonEvent(
        t,
        cj.DialogAddButton(
            d,
            cj.GetLocalizedString("GAMEOVER_QUIT_MISSION"),
            cj.GetLocalizedHotkey("GAMEOVER_QUIT_MISSION")
        )
    )
    cj.TriggerAddAction(
        t,
        function()
            cj.PauseGame(false)
            cj.RestartGame(true)
        end
    )
    if (cj.GetLocalPlayer() == whichPlayer) then
        cj.EnableUserControl(true)
        if cg.bj_isSinglePlayer then
            cj.PauseGame(true)
        end
        cj.EnableUserUI(false)
    end
    cj.DialogDisplay(whichPlayer, d, true)
    bj.VolumeGroupSetVolumeForPlayerBJ(whichPlayer, SOUND_VOLUMEGROUP_UI, 1.0)
    if whichPlayer == cj.GetLocalPlayer() then
        cj.StartSound(cg.bj_defeatDialogSound)
    end
end
bj.CustomDefeatQuitBJ = function()
    if cg.bj_isSinglePlayer then
        cj.PauseGame(false)
    end

    -- Bump the difficulty back up to the default.
    cj.SetGameDifficulty(cj.GetDefaultDifficulty())
    cj.EndGame(true)
end
bj.CustomVictoryDialogBJ = function(whichPlayer)
    local t
    local d = cj.DialogCreate()

    cj.DialogSetMessage(d, cj.GetLocalizedString("GAMEOVER_VICTORY_MSG"))
    t = cj.CreateTrigger()
    cj.TriggerRegisterDialogButtonEvent(
        t,
        cj.DialogAddButton(d, cj.GetLocalizedString("GAMEOVER_CONTINUE"), cj.GetLocalizedHotkey("GAMEOVER_CONTINUE"))
    )
    cj.TriggerAddAction(
        t,
        function()
            if cg.bj_isSinglePlayer then
                cj.PauseGame(false)
                -- Bump the difficulty back up to the default.
                cj.SetGameDifficulty(cj.GetDefaultDifficulty())
            end

            if cg.bj_changeLevelMapName == nil then
                cj.EndGame(cg.bj_changeLevelShowScores)
            else
                cj.ChangeLevel(cg.bj_changeLevelMapName, cg.bj_changeLevelShowScores)
            end
        end
    )
    t = cj.CreateTrigger()
    cj.TriggerRegisterDialogButtonEvent(
        t,
        cj.DialogAddButton(
            d,
            cj.GetLocalizedString("GAMEOVER_QUIT_MISSION"),
            cj.GetLocalizedHotkey("GAMEOVER_QUIT_MISSION")
        )
    )
    cj.TriggerAddAction(t, bj.CustomDefeatQuitBJ)

    if cj.GetLocalPlayer() == whichPlayer then
        cj.EnableUserControl(true)
        if cg.bj_isSinglePlayer then
            cj.PauseGame(true)
        end
        cj.EnableUserUI(false)
    end

    cj.DialogDisplay(whichPlayer, d, true)
    bj.VolumeGroupSetVolumeForPlayerBJ(whichPlayer, SOUND_VOLUMEGROUP_UI, 1.0)
    if whichPlayer == cj.GetLocalPlayer() then
        cj.StartSound(cg.bj_victoryDialogSound)
    end
end
bj.CustomDefeatBJ = function(whichPlayer, message)
    if bj.AllowVictoryDefeatBJ(PLAYER_GAME_RESULT_DEFEAT) then
        cj.RemovePlayer(whichPlayer, PLAYER_GAME_RESULT_DEFEAT)
        if not cg.bj_isSinglePlayer then
            cj.DisplayTimedTextFromPlayer(whichPlayer, 0, 0, 60, cj.GetLocalizedString("PLAYER_DEFEATED"))
        end
        -- UI only needs to be displayed to users.
        if (cj.GetPlayerController(whichPlayer) == MAP_CONTROL_USER) then
            bj.CustomDefeatDialogBJ(whichPlayer, message)
        end
    end
end
bj.CustomVictorySkipBJ = function(whichPlayer)
    if cj.GetLocalPlayer() == whichPlayer then
        if cg.bj_isSinglePlayer then
            -- Bump the difficulty back up to the default.
            cj.SetGameDifficulty(cj.GetDefaultDifficulty())
        end

        if cg.bj_changeLevelMapName == nil then
            cj.EndGame(cg.bj_changeLevelShowScores)
        else
            cj.ChangeLevel(cg.bj_changeLevelMapName, cg.bj_changeLevelShowScores)
        end
    end
end
bj.CustomVictoryBJ = function(whichPlayer, showDialog, showScores)
    if bj.AllowVictoryDefeatBJ(PLAYER_GAME_RESULT_VICTORY) then
        cj.RemovePlayer(whichPlayer, PLAYER_GAME_RESULT_VICTORY)

        if not cg.bj_isSinglePlayer then
            cj.DisplayTimedTextFromPlayer(whichPlayer, 0, 0, 60, cj.GetLocalizedString("PLAYER_VICTORIOUS"))
        end

        -- UI only needs to be displayed to users.
        if (cj.GetPlayerController(whichPlayer) == MAP_CONTROL_USER) then
            cg.bj_changeLevelShowScores = showScores
            if showDialog then
                bj.CustomVictoryDialogBJ(whichPlayer)
            else
                bj.CustomVictorySkipBJ(whichPlayer)
            end
        end
    end
end
bj.AbortCinematicFadeBJ = function()
    if cg.bj_cineFadeContinueTimer ~= nil then
        cj.DestroyTimer(cg.bj_cineFadeContinueTimer)
    end

    if cg.bj_cineFadeFinishTimer ~= nil then
        cj.DestroyTimer(cg.bj_cineFadeFinishTimer)
    end
end
bj.PercentToInt = function(percentage, max)
    local result = cj.R2I(percentage * cj.I2R(max) * 0.01)
    if result < 0 then
        result = 0
    elseif result > max then
        result = max
    end
    return result
end
bj.PercentTo255 = function(percentage)
    return bj.PercentToInt(percentage, 255)
end
bj.CinematicFilterGenericBJ = function(duration, bmode, tex, red0, green0, blue0, trans0, red1, green1, blue1, trans1)
    bj.AbortCinematicFadeBJ()
    cj.SetCineFilterTexture(tex)
    cj.SetCineFilterBlendMode(bmode)
    cj.SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
    cj.SetCineFilterStartUV(0, 0, 1, 1)
    cj.SetCineFilterEndUV(0, 0, 1, 1)
    cj.SetCineFilterStartColor(
        bj.PercentTo255(red0),
        bj.PercentTo255(green0),
        bj.PercentTo255(blue0),
        bj.PercentTo255(100 - trans0)
    )
    cj.SetCineFilterEndColor(
        bj.PercentTo255(red1),
        bj.PercentTo255(green1),
        bj.PercentTo255(blue1),
        bj.PercentTo255(100 - trans1)
    )
    cj.SetCineFilterDuration(duration)
    cj.DisplayCineFilter(true)
end