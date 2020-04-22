---@class hleaderBoard 排行榜
hleaderBoard = {}

---@private
hleaderBoard.LeaderboardResize = function(lb)
    local size = cj.LeaderboardGetItemCount(lb)
    if cj.LeaderboardGetLabelText(lb) == "" then
        size = size - 1
    end
    cj.LeaderboardSetSizeByItemCount(lb, size)
end

--- 根据玩家创建排行榜
---@alias hleaderBoard fun(whichLeaderBoard: userdata):void
---@param key string 排行榜唯一key
---@param refreshFrequency number 刷新频率
---@param yourData hleaderBoard | "function(whichLeaderBoard) return {{playerIndex = 1,value = nil}} end"
hleaderBoard.create = function(key, refreshFrequency, yourData)
    --[[
        yourData 设置数据的回调,会返回当前的排行榜；
        另外你需要设置数据传回到create中来，拼凑KV数据，{
            playerIndex = ?,
            value = ?
        }
    ]]
    if (hRuntime.leaderBoard[key] == nil) then
        cj.DestroyLeaderboard(hRuntime.leaderBoard[key])
        hRuntime.leaderBoard[key] = cj.CreateLeaderboard()
    end
    cj.LeaderboardSetLabel(hRuntime.leaderBoard[key], "排行榜")
    htime.setInterval(
        refreshFrequency,
        function(t)
            local data = yourData(hRuntime.leaderBoard[key])
            for _, d in ipairs(data) do
                local playerIndex = d.playerIndex
                local value = d.value
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

--- 设置排行榜的标题
---@param whichBoard userdata
---@param title string
hleaderBoard.setTitle = function(whichBoard, title)
    cj.LeaderboardSetLabel(whichBoard, title)
end

--- 获取排行第N的玩家
---@param whichBoard userdata
---@param n number
---@return userdata 玩家
hleaderBoard.pos = function(whichBoard, n)
    if (n < 1 or n > hplayer.qty_max) then
        return
    end
    local pos
    n = n - 1
    for i = 1, hplayer.qty_max, 1 do
        if (cj.LeaderboardGetPlayerIndex(whichBoard, hplayer.players[i]) == n) then
            pos = hplayer.players[i]
            break
        end
    end
    return pos
end

--- 获取排行第一的玩家
---@param whichBoard userdata
---@return userdata 玩家
hleaderBoard.top = function(whichBoard)
    return hleaderBoard.pos(whichBoard, 1)
end

--- 获取排行最后的玩家
---@param whichBoard userdata
---@return userdata 玩家
hleaderBoard.bottom = function(whichBoard)
    return hleaderBoard.pos(whichBoard, hplayer.qty_max)
end
