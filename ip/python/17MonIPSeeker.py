import os
import functools
from mmap import mmap
from struct import unpack
from ipaddress import IPv4Address
from collections import namedtuple


class SeventeenMonIPSeeker():
    """本类使用Public Domain许可
    ip_seeker = SeventeenMonIPSeeker('IPBase.17Mon.DAT')
    ip_seeker[3232235777] -> Location
    ip_seeker['192.168.1.1'] -> Location
    ip_seeker[b'\\xC0\\xA8\\x01\\x01'] -> Location
    ip_seeker[ipaddress.IPv4Address('192.168.1.1')] -> Location
    
    location = ip_seeker['192.168.1.1']
    country, province, city, unit = ip_seeker['192.168.1.1']
    print(repr(location)) -> Location(country='局域网', province='局域网', city='', unit='')
    print(repr(str(location))) -> '局域网 局域网'
    print(repr(country), repr(province), repr(city), repr(unit)) -> '局域网' '局域网' '' ''
    """

    class Location(namedtuple('Location', ['country', 'province', 'city', 'unit'])):
        """字段说明：country(国家) province(省) city(市) unit(学校/单位)"""

        def __str__(self):
            return ('%s %s %s %s' % self).strip()

    def __init__(self, path: str):
        self.__data_offset = 4
        self.__path = path
        if not os.path.exists(path):
            raise FileNotFoundError
        with open(self.__path, 'rb') as fp:
            self.__fp = mmap(fp.fileno(), 0, access=1)
        self.__fp.seek(0)
        self.__index_offset, = unpack('>L', self.__fp.read(4))
        self.__max_comp_length = self.__data_offset + (self.__index_offset - 0x404)

    def __locate(self, ip: IPv4Address):
        ip = int(ip).to_bytes(4, 'big')
        self.__fp.seek(self.__data_offset + (ip[0] * 4))
        
        offset, = unpack('<L', self.__fp.read(4))
        offset = self.__data_offset + (offset * 8) + 0x400
        while offset < self.__max_comp_length:
            self.__fp.seek(offset)
            if self.__fp.read(4) >= ip:
                index_offset, = unpack('<L', self.__fp.read(3) + b'\0')
                index_length = ord(self.__fp.read(1))
                return index_offset, index_length
            offset += 8

    def __lookup(self, ip: IPv4Address):
        offset, length = self.__locate(ip)
        if offset == 0:
            return

        self.__fp.seek(self.__index_offset + offset - 0x400)
        return self.Location(*self.__fp.read(length).decode('UTF-8').split('\t'))

    @functools.lru_cache()
    def __getitem__(self, ip):
        if isinstance(ip, int) or isinstance(ip, str) or isinstance(ip, bytes):
            return self.__lookup(IPv4Address(ip))
        elif isinstance(ip, IPv4Address):
            return self.__lookup(ip)
        else:
            raise TypeError('wrong key type.')

    def reload(self):
        with open(self.__path, 'rb') as fp:
            self.__fp.close()
            self.__fp = mmap(fp.fileno(), 0, access=1)
        self.__fp.seek(0)
        self.__index_offset, = unpack('>L', self.__fp.read(4))
        self.__max_comp_length = self.__data_offset + (self.__index_offset - 0x404)

    def __del__(self):
        self.__fp.close()
