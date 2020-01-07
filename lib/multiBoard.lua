-- [[多面板/多列榜]]
local hmultiboard = {}

--[[
    根据玩家创建多面板,多面板是可以每个玩家看到的都不一样的
    key 多面板唯一key
    refreshFrequency 刷新频率
    yourData 设置数据的回调,你需要设置数据传回到create中来，拼凑多面板数据，二维数组，行列模式
]]
hmultiBoard.create = function(key, refreshFrequency, yourData)
    --判断玩家各自的多面板属性
    for pi = 1, hplayer.qty_max, 1 do
        local p = hplayer.players[pi]
        if (his.playing(p)) then
            if (hRuntime.multiBoard[pi] == nil) then
                hRuntime.multiBoard[pi] = {
                    visible = true,
                    timer = nil,
                    borads = {}
                }
            end
            if (hRuntime.multiBoard[pi].borads[key] == nil) then
                cj.DestroyMultiboard(hRuntime.leaderBoard[pi].borads[key])
                hRuntime.multiBoard[pi].borads[key] = cj.CreateMultiboard()
                cj.MultiboardSetTitleText(hRuntime.multiBoard[pi].borads[key], "多面板")
            end
        end
        hRuntime.multiBoard[pi].timer =
            htime.setInterval(
            refreshFrequency,
            function(t, td)
                --检查玩家是否隐藏了多面板 -mbv
                if (hRuntime.multiBoard[pi].visible ~= true) then
                    if (cj.GetLocalPlayer() == p) then
                        cj.MultiboardDisplay(hRuntime.leaderBoard[pi].borads[key], false)
                    end
                    --而且隐藏就没必要展示数据了，后续流程中止
                    return
                end
                local data = yourData()
                local row = #data
                local col = 0
                if (row > 0) then
                    col = #data[1]
                end
                print(row)
                print(col)
                if (row <= 0 or col <= 0) then
                    print_err("Multiboard:-row -col")
                    return
                end
                --设置行列数
                cj.MultiboardSetRowCount(hRuntime.leaderBoard[pi].borads[key], row)
                cj.MultiboardSetColumnCount(hRuntime.leaderBoard[pi].borads[key], col)
                
                --显示
                if (cj.GetLocalPlayer() == p) then
                    cj.MultiboardDisplay(hRuntime.leaderBoard[pi].borads[key], true)
                end
            end
        )
    end
    cj.LeaderboardDisplay(hRuntime.leaderBoard[key], true)
end

return hmultiBoard
