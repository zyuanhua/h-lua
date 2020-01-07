-- [[排行榜]]
local hleaderBoard = {}

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
    yourFunc 设置数据的回调,可以获取到该排行榜和玩家的index索引,设置标题
]]
hleaderBoard.create = function(key, refreshFrequency, yourFunc)
    if (hRuntime.leaderBoard[key] == nil) then
        cj.DestroyLeaderboard(hRuntime.leaderBoard[key])
        hRuntime.leaderBoard[key] = cj.CreateLeaderboard()
    end
    cj.LeaderboardSetLabel(hRuntime.leaderBoard[key], "排行榜")
    htime.setInterval(
        refreshFrequency,
        function(t, td)
            for i = 1, hplayer.qty_max, 1 do
                if cj.LeaderboardHasPlayerItem(hRuntime.leaderBoard[key], hplayer.players[i]) then
                    cj.LeaderboardRemovePlayerItem(hRuntime.leaderBoard[key], hplayer.players[i])
                end
                if (his.playing(hplayer.players[i])) then
                    cj.PlayerSetLeaderboard(hplayer.players[i], hRuntime.leaderBoard[key])
                    yourFunc(hRuntime.leaderBoard[key], i)
                end
                hleaderBoard.LeaderboardResize(hRuntime.leaderBoard[key])
            end
        end
    )
    cj.LeaderboardDisplay(hRuntime.leaderBoard[key], true)
end

--设置排行榜的标题
hleaderBoard.setTitle = function(whichBoard, title)
    cj.LeaderboardSetLabel(whichBoard, title)
end

hleaderBoard.setPlayerData = function(whichBoard, whichPlayer, data)
    cj.LeaderboardAddItem(whichBoard, cj.GetPlayerName(whichPlayer), data, whichPlayer)
end

return hleaderBoard
