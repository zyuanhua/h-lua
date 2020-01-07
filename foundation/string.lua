--获取一个对象的id
string.char2id = function(idChar)
    if (idChar == nil) then
        print_stack()
    end
    local len = string.len(idChar)
    local id = 0
    for i = 1, len, 1 do
        if (i == 1) then
            id = string.byte(idChar, i)
        else
            id = id * 256 + string.byte(idChar, i)
        end
    end
    return id
end

--获取一个对象的id字符串
string.id2char = function(id)
    if (id == nil) then
        print_stack()
    end
    return string.char(id // 0x1000000) ..
        string.char(id // 0x10000 % 0x100) .. string.char(id // 0x100 % 0x100) .. string.char(id % 0x100)
end

--获取字符串真实长度
string.mb_len = function(inputstr)
    local lenInByte = #inputstr
    local width = 0
    local i = 1
    while (i <= lenInByte) do
        local curByte = string.byte(inputstr, i)
        local byteCount = 1
        if curByte > 0 and curByte <= 127 then
            byteCount = 1 --1字节字符
        elseif curByte >= 192 and curByte < 223 then
            byteCount = 2 --双字节字符
        elseif curByte >= 224 and curByte < 239 then
            byteCount = 3 --汉字
        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4 --4字节字符
        end
        local char = string.sub(inputstr, i, i + byteCount - 1)
        print(char)
        i = i + byteCount -- 重置下一字节的索引
        width = width + 1 -- 字符的个数（长度）
    end
    return width
end
