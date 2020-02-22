-- 大部分方法不再支持pairs，会引起异步

-- 获取一个table的正确长度（不建议使用，会引起异步)
table.len = function(table)
    local len = 0
    for _, _ in pairs(table) do
        len = len + 1
    end
    print("[Deprecated]table.len !")
    return len
end

-- 随机在数组内取一个
table.random = function(arr)
    local val
    if (#arr > 0) then
        val = arr[math.random(1, #arr)]
    else
        print_err()
    end
    return val
end

-- 克隆table
table.clone = function(org)
    local function copy(org1, res)
        for _, v in ipairs(org1) do
            if type(v) ~= "table" then
                table.insert(res, v)
            else
                local rl = #res + 1
                res[rl] = {}
                copy(v, res[rl])
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
    for _, v in ipairs(table2) do
        table.insert(tempTable, v)
    end
    return tempTable
end

-- 在数组内
table.includes = function(val, arr)
    local isin = false
    if (val == nil or #arr <= 0) then
        return isin
    end
    for _, v in ipairs(arr) do
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
    local dels = {}
    for k, v in ipairs(arr) do
        if (v == val) then
            q = q + 1
            table.insert(dels, k)
            if (qty ~= -1 and q >= qty) then
                break
            end
        end
    end
    for _, k in ipairs(dels) do
        table.remove(dels, k)
    end
    dels = nil
end
