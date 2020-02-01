-- [[排行榜]]
hleaderBoard = {}

hleaderBoard.LeaderboardResize = function(lb)
    local size = cj.LeaderboardGetItemCount(lb)
    if cj.LeaderboardGetLabelText(lb) == "" then
        size = size - 1
    end
    cj.LeaderboardSetSizeByItemCount(lb, size)
end

--[[
    根据玩家创建排行榜
    key 排行榜唯一key
    refreshFrequency 刷新频率
    yourData 设置数据的回调,会返回当前的排行榜；
             另外你需要设置数据传回到create中来，拼凑KV数据，playerIndex -> value
]]
hleaderBoard.create = function(key, refreshFrequency, yourData)
    if (hRuntime.leaderBoard[key] == nil) then
        cj.DestroyLeaderboard(hRuntime.leaderBoard[key])
        hRuntime.leaderBoard[key] = cj.CreateLeaderboard()
    end
    cj.LeaderboardSetLabel(hRuntime.leaderBoard[key], "排行榜")
    htime.setInterval(
        refreshFrequency,
        function(t, td)
            local data = yourData(hRuntime.leaderBoard[key])
            for playerIndex, value in pairs(data) do
                if cj.LeaderboardHasPlayerItem(hRuntime.leaderBoard[key], hplayer.players[playerIndex]) then
                    cj.LeaderboardRemovePlayerItem(hRuntime.leaderBoard[key], hplayer.players[playerIndex])
                end
                cj.PlayerSetLeaderboard(hplayer.players[playerIndex], hRuntime.leaderBoard[key])
                cj.LeaderboardAddItem(
                    hRuntime.leaderBoard[key],
                    cj.GetPlayerName(hplayer.players[playerIndex]),
                    value,
                    hplayer.players[playerIndex]
                )
            end
            cj.LeaderboardSortItemsByValue(hRuntime.leaderBoard[key], false) --降序
            hleaderBoard.LeaderboardResize(hRuntime.leaderBoard[key])
        end
    )
    cj.LeaderboardDisplay(hRuntime.leaderBoard[key], true)
    return hRuntime.leaderBoard[key]
end

--设置排行榜的标题
hleaderBoard.setTitle = function(whichBoard, title)
    cj.LeaderboardSetLabel(whichBoard, title)
end
