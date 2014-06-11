#!/usr/bin/env lua

function byteToUint32(a,b,c,d)
        local _int = 0
	if a then
		_int = _int +  bit32.lshift(a, 24)
	end
	_int = _int + bit32.lshift(b, 16)
	_int = _int + bit32.lshift(c, 8)
	_int = _int + d
	if _int >= 0 then
        return _int
    else
        return _int + math.pow(2, 32)
    end
end

local ipBinaryFilePath = "/home/codebase/17mon/17monipdb.dat"

local indexBuffer = ''
local offset_len = 0
local areaList = {}

function loadAreaList()
    local file = io.open(ipBinaryFilePath)
    local str = file:read(4)
    
    offset_len = byteToUint32(string.byte(str, 1), string.byte(str, 2)
    ,string.byte(str, 3),string.byte(str, 4))
    indexBuffer = file:read(offset_len - 4)
    
    file:seek("set", 4)
    local indexPrefixBuf = file:read(1024);
    local indexBuf = file:read(offset_len - 4 - 1024);
    local index_offset = -1;
    local index_length = -1;
    local index = 1;
    while index < string.len(indexBuf) do
            index_offset =  byteToUint32(0, string.byte(indexBuf, index+6),string.byte(indexBuf, index+5),string.byte(indexBuf, index+4))
            index_length = string.byte(indexBuf, index+7)
            index = index +8
            file:seek("set", offset_len - 1024 + index_offset)
            areaList[index_offset] = file:read(index_length)
    end
end

loadAreaList()

function IpOffset(ipstr)
    local ip1,ip2,ip3,ip4 = string.match(ipstr, "(%d+).(%d+).(%d+).(%d+)")
    local ip_uint32 = byteToUint32(ip1, ip2, ip3, ip4)

	local tmp_offset = ip1 * 4 
	local start_len = byteToUint32(string.byte(indexBuffer, tmp_offset + 4), string.byte(indexBuffer, tmp_offset + 3), string.byte(indexBuffer, tm
p_offset + 2), string.byte(indexBuffer, tmp_offset + 1))

	local max_comp_len = offset_len - 1028
	start = start_len * 8 + 1024 + 1
        local find_uint32 = 0
	local index_offset = -1
	local index_length = -1
	while start < max_comp_len do
        find_uint32 = byteToUint32(string.byte(indexBuffer, start), string.byte(indexBuffer, start+1),string.byte(indexBuffer, start+2),string.byte(in
dexBuffer, start+3))
        if ip_uint32 <= find_uint32  then
			index_offset = byteToUint32(0, string.byte(indexBuffer, start+6),string.byte(indexBuffer, start+5),string.byte(indexBuffer, st
art+4))
			index_length = string.byte(indexBuffer, start+7)
			break
		end
		start = start + 8
	end

	if index_offset == -1 or index_length == -1 then
		return nil
	end

	return index_offset
end


function IpLocation(ipstr)
	return areaList[IpOffset(ipstr)]
end
