print_stack = function(...)
    local out = { '[TRACE]' }
    local n = select('#', ...)
    for i = 1, n, 1 do
        local v = select(i, ...)
        out[#out + 1] = tostring(v)
    end
    out[#out + 1] = '\n'
    out[#out + 1] = debug.traceback("", 2)
    print(table.concat(out, ' '))
    -- print(debug.traceback("Stack trace"))
end

--打印utf8->ansi编码
print_mb = function(str)
    console.write(str)
end

--打印对象table
print_r = function(t)
    local print_r_cache = {}
    local function sub_print_r(tt, indent)
        if (print_r_cache[tostring(tt)]) then
            print(indent .. "*" .. tostring(tt))
        else
            print_r_cache[tostring(tt)] = true
            if (type(tt) == "table") then
                for pos, val in pairs(tt) do
                    if (type(val) == "table") then
                        print(indent .. "[" .. pos .. "] => " .. tostring(tt) .. " {")
                        sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
                        print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
                    elseif (type(val) == "string") then
                        print(indent .. "[" .. pos .. '] => "' .. val .. '"')
                    else
                        print(indent .. "[" .. pos .. "] => " .. tostring(val))
                    end
                end
            else
                print(indent .. tostring(tt))
            end
        end
    end
    if (type(t) == "table") then
        print(tostring(t) .. " {")
        sub_print_r(t, "  ")
        print("}")
    else
        sub_print_r(t, "  ")
    end
    print()
end
