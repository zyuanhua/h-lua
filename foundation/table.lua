-- 获取一个table的正确长度
table.len = function(table)
    local len = 0
    for _, _ in pairs(table) do
        len = len + 1
    end
    return len
end

-- 随机在数组内取一个
table.random = function(arr)
    local keys = {}
    for k, _ in pairs(arr) do
        table.insert(keys, k)
    end
    local val = arr[keys[math.random(1, #keys)]]
    keys = nil
    return val
end

-- 克隆table
table.clone = function(org)
    local function copy(org1, res)
        for k, v in pairs(org1) do
            if type(v) ~= "table" then
                res[k] = v
            else
                res[k] = {}
                copy(v, res[k])
            end
        end
    end
    local res = {}
    copy(org, res)
    return res
end

-- 合并table
table.merge = function(table1, table2)
    local tempTable = {}
    if (table1 ~= nil) then
        tempTable = table.clone(table1)
    end
    if (table2 == nil) then
        return tempTable
    end
    if (table.len(table2) == #table2) then
        for _, v in ipairs(table2) do
            table.insert(tempTable, v)
        end
    else
        for k, v in pairs(table2) do
            tempTable[k] = v
        end
    end
    return tempTable
end

-- 在数组内
table.includes = function(val, arr)
    local isin = false
    if (val == nil or #arr <= 0) then
        return isin
    end
    for k, v in pairs(arr) do
        if (v == val) then
            isin = true
            break
        end
    end
    return isin
end

-- 删除数组一次某个值(qty次,默认删除全部)
table.delete = function(val, arr, qty)
    qty = qty or -1
    local q = 0
    for k, v in pairs(arr) do
        if (v == val) then
            q = q + 1
            table.remove(arr, k)
            if (qty ~= -1 and q >= qty) then
                break
            end
        end
    end
end
