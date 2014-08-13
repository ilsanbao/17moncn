local ffi = require "ffi"

ffi.cdef[[
    struct in_addr {
        uint32_t s_addr;
    };

    int inet_aton(const char *cp, struct in_addr *inp);
    uint32_t ntohl(uint32_t netlong);

    char *inet_ntoa(struct in_addr in);
    uint32_t htonl(uint32_t hostlong);
]]

local C = ffi.C

function ip2long(ip)
    local inp = ffi.new("struct in_addr[1]")
    if C.inet_aton(ip, inp) ~= 0 then
        return tonumber(C.ntohl(inp[0].s_addr))
    end
    return nil
end

function long2ip(long)
    if type(long) ~= "number" then
        return nil
    end
    local addr = ffi.new("struct in_addr")
    addr.s_addr = C.htonl(long)
    return ffi.string(C.inet_ntoa(addr))
end

