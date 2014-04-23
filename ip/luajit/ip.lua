#!/usr/bin/env luajit

-- 暂时还不可用 --

local bit = require("bit")

require('php')

function byteToUint32(a,b,c,d)
        local _int = 0
	if a then
		_int = _int +  bit.lshift(a, 24)
	end
	_int = _int + bit.lshift(b, 16)
	_int = _int + bit.lshift(c, 8)
	_int = _int + d
	return _int
end

function Split(szFullString, szSeparator)
	local nFindStartIndex = 1
	local nSplitIndex = 1
	local nSplitArray = {}
	while true do
	   local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
	   if not nFindLastIndex then
	    nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
	    break
	   end
	   nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
	   nFindStartIndex = nFindLastIndex + string.len(szSeparator)
	   nSplitIndex = nSplitIndex + 1
	end
	return nSplitArray
end

local ipBinaryFilePath = "/home/software/17monipdb.dat"

function IpLocation(ipstr)
	local ip_uint32 = ip2long(ipstr)

	local file = io.open(ipBinaryFilePath)
	if file == nil then
		return nil
	end

	local str = file:read(4)

	local offset_len = byteToUint32(string.byte(str, 1), string.byte(str, 2),string.byte(str, 3),string.byte(str, 4))

	local indexBuffer = file:read(offset_len - 4)

	local tmp_offset = 118 * 4 -- 这里是写死的

	local start_len = byteToUint32(string.byte(indexBuffer, tmp_offset + 4), string.byte(indexBuffer, tmp_offset + 3), string.byte(indexBuffer, tmp_offset + 2), string.byte(indexBuffer, tmp_offset + 1))

	local max_comp_len = offset_len - 1028

	start = start_len * 8 + 1024 + 1

	local index_offset = 0
	local index_length = 0
	while start < max_comp_len do
		local find_uint32 = byteToUint32(string.byte(indexBuffer, start), string.byte(indexBuffer, start+1),string.byte(indexBuffer, start+2),string.byte(indexBuffer, start+3))

		if ip_uint32 <= find_uint32  then
			index_offset = byteToUint32(0, string.byte(indexBuffer, start+6),string.byte(indexBuffer, start+5),string.byte(indexBuffer, start+4))
			index_length = string.byte(indexBuffer, start+7)
			break
		end
		start = start + 8
	end

	if index_offset == 0 or index_length == 0 then
		return nil
	end

	local offset = offset_len + index_offset - 1024

	file:seek("set", offset)

	return file:read(index_length)
end

print(IpLocation("118.26.235.100"))
