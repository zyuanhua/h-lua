-- 遮罩
hmark = {}

hmark.cinematicFilterGeneric = function(duration, bmode, tex, red0, green0, blue0, trans0, red1, green1, blue1, trans1)
    if cg.bj_cineFadeContinueTimer ~= nil then
        cj.DestroyTimer(cg.bj_cineFadeContinueTimer)
    end
    if cg.bj_cineFadeFinishTimer ~= nil then
        cj.DestroyTimer(cg.bj_cineFadeFinishTimer)
    end
    cj.SetCineFilterTexture(tex)
    cj.SetCineFilterBlendMode(bmode)
    cj.SetCineFilterTexMapFlags(TEXMAP_FLAG_NONE)
    cj.SetCineFilterStartUV(0, 0, 1, 1)
    cj.SetCineFilterEndUV(0, 0, 1, 1)
    cj.SetCineFilterStartColor(
        red0,
        green0,
        blue0,
        255 - trans0
    )
    cj.SetCineFilterEndColor(
        red1,
        green1,
        blue1,
        255 - trans1
    )
    cj.SetCineFilterDuration(duration)
    cj.DisplayCineFilter(true)
end

hmark.create = function(path, during, whichPlayer)
    if (whichPlayer == nil) then
        hmark.cinematicFilterGeneric(
            0.50,
            BLEND_MODE_ADDITIVE,
            path,
            255, 255, 255, 255,
            255, 255, 255, 0
        )
        htime.setTimeout(
            during,
            function(t)
                htime.delTimer(t)
                hmark.cinematicFilterGeneric(
                    0.50,
                    BLEND_MODE_ADDITIVE,
                    path,
                    255, 255, 255, 0,
                    255, 255, 255, 255
                )
            end
        )
    elseif (whichPlayer ~= nil) then
        if (whichPlayer == cj.GetLocalPlayer()) then
            hmark.cinematicFilterGeneric(
                0.50,
                BLEND_MODE_ADDITIVE,
                path,
                255, 255, 255, 255,
                255, 255, 255, 0
            )
        end
        htime.setTimeout(
            during,
            function(t)
                htime.delTimer(t)
                if (whichPlayer == cj.GetLocalPlayer()) then
                    hmark.cinematicFilterGeneric(
                        0.50,
                        BLEND_MODE_ADDITIVE,
                        path,
                        255, 255, 255, 0,
                        255, 255, 255, 255
                    )
                end
            end
        )
    end
end
