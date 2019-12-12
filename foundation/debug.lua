print_stack = function(...)
    local out = {'[TRACE]'}
    local n = select('#', ...)
    for i=1, n, 1 do
        local v = select(i,...)
        out[#out+1] = tostring(v)
    end
    out[#out+1] = '\n'
    out[#out+1] = debug.traceback("", 2)
    print(table.concat(out,' '))
    -- print(debug.traceback("Stack trace"))
end
