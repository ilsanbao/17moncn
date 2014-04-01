package ip17mon

import (
	"fmt"
	"os"
	"encoding/binary"
	"bytes"
	"strings"
	"strconv"
)

var ipBinaryFilePath string = "C:\\Users\\T400\\Desktop\\gocode\\ip17mon/17monipdb.dat"

var data []byte
var offset uint32
var index []byte
var index2 [256]uint32
var max_comp_len uint32

func init() {
	data = loadDataBytes(ipBinaryFilePath)
	offset = bytesBigEndianToUint32(data[:4])
	index = data[4:offset]
	for i:=0 ; i < 256; i++ {
		index2[i] = bytesLittleEndianToUint32(index[i*4:i*4+4])
	}
	max_comp_len = offset - 1028
}

func Find(ip string) string {
	ip_max_prefix, ipUint32 := parseIpString(ip)
	
	var index_offset uint32 = 0
	var index_length byte = 0
	var start uint32 = index2[ip_max_prefix] * 8 + 1024
	/*
	if ip_max_prefix < 255 {
		er_fen := start + uint32((index2[ip_max_prefix+1] * 8 + 1024 - start) / 2)
		if (bytesBigEndianToUint32(index[er_fen:er_fen+4]) < ipUint32) {
			start = er_fen			
		}
	}
*/
	for ; start < max_comp_len; start += 8 {
		if bytesBigEndianToUint32(index[start:start+4]) >= ipUint32 {
			index_offset = uint32(index[start+6]) << 16 + uint32(index[start+5]) << 8 + uint32(index[start+4]);
			index_length = index[start+7]
			break
		}
	}

	if index_length == 0 {
		return "N/A"
	}

	return string(data[offset + index_offset - 1024:offset + index_offset - 1024 + uint32(index_length)])
}

func parseIpString(ip string) (prefix uint32, num uint32) {
	var ipArray []string  = strings.Split(ip, ".")
	ip_part0, _ := strconv.ParseUint(ipArray[0], 10, 32)
	ip_part1, _ := strconv.ParseUint(ipArray[1], 10, 32)
	ip_part2, _ := strconv.ParseUint(ipArray[2], 10, 32)
	ip_part3, _ := strconv.ParseUint(ipArray[3], 10, 32)
    
	return uint32(ip_part0), (uint32(ip_part0) << 24 + uint32(ip_part1) << 16 + uint32(ip_part2) << 8 + uint32(ip_part3))
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