---遮罩
hmark = {}

hmark.create = function(path, during, whichPlayer)
    if (whichPlayer == nil) then
        bj.CinematicFilterGenericBJ(
            0.50,
            BLEND_MODE_ADDITIVE,
            path,
            100,
            100,
            100,
            100.00,
            100.00,
            100.00,
            100.00,
            0.00
        )
        htime.setTimeout(
            during,
            function(t, td)
                htime.delDialog(td)
                htime.delTimer(t)
                bj.CinematicFilterGenericBJ(
                    0.50,
                    BLEND_MODE_ADDITIVE,
                    path,
                    100,
                    100,
                    100,
                    0.00,
                    100.00,
                    100.00,
                    100.00,
                    100.00
                )
            end
        )
    elseif (whichPlayer ~= nil) then
        if (whichPlayer == cj.GetLocalPlayer()) then
            bj.CinematicFilterGenericBJ(
                0.50,
                BLEND_MODE_ADDITIVE,
                path,
                100,
                100,
                100,
                100.00,
                100.00,
                100.00,
                100.00,
                0.00
            )
        end
        htime.setTimeout(
            during,
            function(t, td)
                htime.delDialog(td)
                htime.delTimer(t)
                if (whichPlayer == cj.GetLocalPlayer()) then
                    bj.CinematicFilterGenericBJ(
                        0.50,
                        BLEND_MODE_ADDITIVE,
                        path,
                        100,
                        100,
                        100,
                        0.00,
                        100.00,
                        100.00,
                        100.00,
                        100.00
                    )
                end
            end
        )
    end
end
