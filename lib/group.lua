hgroup = {}

--- 循环group
---@alias GroupLoop fun(enumUnit: userdata):void
---@param whichGroup userdata
---@param actions GroupLoop | "function(enumUnit) end"
---@param autoDel boolean
hgroup.loop = function(whichGroup, actions, autoDel)
    if (whichGroup == nil or type(actions) ~= "function") then
        return
    end
    if (type(autoDel) ~= "boolean") then
        autoDel = false
    end
    local tempUnits = {}
    while (true) do
        local u = cj.FirstOfGroup(whichGroup)
        if (u == nil) then
            break
        end
        table.insert(tempUnits, u)
        actions(u)
        cj.GroupRemoveUnit(whichGroup, u)
    end
    if (autoDel == true) then
        cj.DestroyGroup(whichGroup)
    else
        for _, u in ipairs(tempUnits) do
            cj.GroupAddUnit(whichGroup, u)
        end
    end
    tempUnits = nil
end

--- 统计单位组当前单位数
---@param whichGroup userdata
---@return number
hgroup.count = function(whichGroup)
    if (whichGroup == nil) then
        return 0
    end
    local count = 0
    hgroup.loop(
        whichGroup,
        function()
            count = count + 1
        end
    )
    return count
end

--- 判断单位是否在单位组内
---@param whichGroup userdata
---@param whichUnit userdata
---@return boolean
hgroup.isIn = function(whichGroup, whichUnit)
    if (whichGroup == nil) then
        return false
    end
    return cj.IsUnitInGroup(whichUnit, whichGroup)
end

--- 判断单位组是否为空
---@param whichGroup userdata
---@return boolean
hgroup.isEmpty = function(whichGroup)
    if (whichGroup == nil) then
        return true
    end
    local isUnitGroupEmptyResult = true
    hgroup.loop(
        whichGroup,
        function()
            isUnitGroupEmptyResult = false
        end
    )
    return isUnitGroupEmptyResult
end

--- 单位组添加单位
---@param whichGroup userdata
---@param whichUnit userdata
hgroup.addUnit = function(whichGroup, whichUnit)
    if (hgroup.isIn(whichGroup, whichUnit) == false) then
        cj.GroupAddUnit(whichGroup, whichUnit)
    end
end
--- 单位组删除单位
---@param whichGroup userdata
---@param whichUnit userdata
hgroup.removeUnit = function(whichGroup, whichUnit)
    if (hgroup.isIn(whichGroup, whichUnit) == true) then
        cj.GroupRemoveUnit(whichGroup, whichUnit)
    end
end

--- 创建单位组,以(x,y)点为中心radius距离\
---@alias GroupFilter fun(filterUnit: userdata):void
---@param x number
---@param y number
---@param radius number
---@param filterFunc GroupFilter | "function(filterUnit) end"
---@return userdata
hgroup.createByXY = function(x, y, radius, filterFunc)
    -- 镜头放大模式下，范围缩小一半
    if (hcamera.model == "zoomin") then
        radius = radius * 0.5
    end
    local g = cj.CreateGroup()
    cj.GroupEnumUnitsInRange(g, x, y, radius, nil)
    if (filterFunc ~= nil) then
        local fg = cj.CreateGroup()
        hgroup.loop(
            g,
            function(filterUnit)
                if (filterFunc(filterUnit) == true) then
                    cj.GroupAddUnit(fg, filterUnit)
                end
            end,
            true
        )
        g = nil
        return fg
    else
        return g
    end
end

--- 创建单位组,以loc点为中心radius距离
---@param loc userdata
---@param radius number
---@param filterFunc GroupFilter | "function(filterUnit) end"
---@return userdata
hgroup.createByLoc = function(loc, radius, filterFunc)
    return hgroup.createByXY(cj.GetLocationX(loc), cj.GetLocationY(loc), radius, filterFunc)
end

--- 创建单位组,以某个单位为中心radius距离
---@param u userdata
---@param radius number
---@param filterFunc GroupFilter | "function(filterUnit) end"
---@return userdata
hgroup.createByUnit = function(u, radius, filterFunc)
    return hgroup.createByXY(cj.GetUnitX(u), cj.GetUnitY(u), radius, filterFunc)
end

--- 创建单位组,以区域为范围选择
---@param r userdata
---@param filterFunc GroupFilter | "function(filterUnit) end"
---@return userdata
hgroup.createByRect = function(r, filterFunc)
    local g = cj.CreateGroup()
    cj.GroupEnumUnitsInRect(g, r, nil)
    if (filterFunc ~= nil) then
        local fg = cj.CreateGroup()
        hgroup.loop(
            g,
            function(filterUnit)
                if (filterFunc(filterUnit) == true) then
                    cj.GroupAddUnit(fg, filterUnit)
                end
            end,
            true
        )
        g = nil
        return fg
    else
        return g
    end
end

--- 瞬间移动单位组
---@param whichGroup userdata
---@param x number
---@param y number
---@param eff string
---@param isFollow boolean
hgroup.move = function(whichGroup, x, y, eff, isFollow)
    if (whichGroup == nil or loc == nil) then
        return
    end
    hgroup.loop(
        whichGroup,
        function(eu)
            cj.SetUnitPosition(eu, x, y)
            if (isFollow == true) then
                cj.PanCameraToTimedForPlayer(cj.GetOwningPlayer(eu), x, y, 0.00)
            end
            if (eff ~= nil) then
                heffect.toXY(eff, x, y, 0)
            end
        end
    )
end

--- 指挥单位组所有单位做动作
---@param whichGroup userdata
---@param animateStr string
hgroup.animate = function(whichGroup, animateStr)
    if (whichGroup == nil or animateStr == nil) then
        return
    end
    hgroup.loop(
        whichGroup,
        function(eu)
            if (his.death(eu) == false) then
                cj.SetUnitAnimation(eu, animateStr)
            end
        end
    )
end

--- 获取单位组内离选定的(x,y)最近的单位
---@param whichGroup userdata
---@param x number
---@param y number
---@return userdata 单位
hgroup.getClosest = function(whichGroup, x, y)
    if (whichGroup == nil or x == nil or y == nil) then
        return
    end
    if (hgroup.count(whichGroup) == 0) then
        return
    end
    local closeDist = 99999
    local closeUnit
    hgroup.loop(
        whichGroup,
        function(u)
            local tx = cj.GetUnitX(u)
            local ty = cj.GetUnitY(u)
            local dist = math.getDistanceBetweenXY(x, y, tx, ty)
            if (dist < closeDist) then
                closeUnit = u
            end
        end
    )
    return closeUnit
end

--- 清空单位组
---@param whichGroup userdata
---@param isDestroy boolean 是否同时删除单位组
---@param isDestroyUnit boolean 是否同时删除单位组里面的单位
---
hgroup.clear = function(whichGroup, isDestroy, isDestroyUnit)
    if (whichGroup == nil) then
        return
    end
    hgroup.loop(
        whichGroup,
        function(eu)
            cj.GroupRemoveUnit(whichGroup, eu)
            if (isDestroyUnit == true) then
                hunit.del(eu)
            end
        end
    )
    if (isDestroy == true) then
        cj.DestroyGroup(whichGroup)
    end
end
