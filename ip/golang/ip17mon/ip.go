package ip17mon

import (
	"fmt"
	"os"
	"encoding/binary"
	"bytes"
	"strings"
	"strconv"
)

var ipBinaryFilePath string = "/Users/fanrukuan/codesource/17monipdb.dat"

var data []byte;
var offset uint32;
var index []byte;

func init() {
	data = loadDataBytes(ipBinaryFilePath)
	offset = bytesBigEndianToUint32(data[:4]);
	index = data[4:offset];
}

func Find(ip string) []byte {

	ip_max_prefix, ipUint32 := parseIpString(ip)

	var tmp_offset uint32 = ip_max_prefix * 4
	var max_comp_len uint32 = offset - 1028
	var start uint32 = bytesLittleEndianToUint32(index[tmp_offset:tmp_offset+4])
	var index_offset uint32 = 0;
	var index_length byte = 0;
	for start = start * 8 + 1024; start < max_comp_len; start += 8 {
		if bytesBigEndianToUint32(index[start:start+4]) >= ipUint32 {
			index_offset = uint32(index[start+6]) << 16 + uint32(index[start+5]) << 8 + uint32(index[start+4]);
			index_length = index[start+7]
			break
		}
	}
	if index_length == 0 {
		return nil
	}

	return data[offset + index_offset - 1024:offset + index_offset - 1024 + uint32(index_length)]
}

func parseIpString(ip string) (prefix uint32, num uint32) {
	var ipArray []string  = strings.Split(ip, ".")
	ip_part0, _ := strconv.ParseUint(ipArray[0], 10, 32)
	var ip_max_prefix uint32 = uint32(ip_part0);
	ip_part1, _ := strconv.ParseUint(ipArray[1], 10, 32)
	ip_part2, _ := strconv.ParseUint(ipArray[2], 10, 32)
	ip_part3, _ := strconv.ParseUint(ipArray[3], 10, 32)
	var ipUint32 uint32 = (ip_max_prefix << 24 + uint32(ip_part1) << 16 + uint32(ip_part2) << 8 + uint32(ip_part3));

	return ip_max_prefix, ipUint32
}

func loadDataBytes(filePath string) []byte {
	file, err := os.Open(filePath)
	if err != nil {
		fmt.Println(err)
	}
	defer file.Close()
	var fileInfo os.FileInfo
	fileInfo, err = file.Stat()

	var data []byte = make([]byte, fileInfo.Size())
	file.Read(data)

	return data
}

func bytesBigEndianToUint32(b []byte) uint32 {
	var num uint32
	err := binary.Read(bytes.NewReader(b), binary.BigEndian, &num)
	if err != nil {
		fmt.Println("binary.Read Failed." + err.Error())
	}
	return num
}

func bytesLittleEndianToUint32(b []byte) uint32 {
	var num uint32
	err := binary.Read(bytes.NewReader(b), binary.LittleEndian, &num)
	if err != nil {
		//
	}
	return num
}
