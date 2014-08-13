#include "IpLocation.h"

#include <io.h>
#include <iostream>
#include <Windows.h>

#define B2IL(b) (((b)[0] & 0xFF) | (((b)[1] << 8) & 0xFF00) | (((b)[2] << 16) & 0xFF0000) | (((b)[3] << 24) & 0xFF000000))
#define B2IU(b) (((b)[3] & 0xFF) | (((b)[2] << 8) & 0xFF00) | (((b)[1] << 16) & 0xFF0000) | (((b)[0] << 24) & 0xFF000000))

IpLocation::IpLocation()
{
	FILE *file;
	_tfopen_s(&file, _T("17monipdb.dat"), _T("rb"));
	long size = _filelength(_fileno(file));
	dataBuffer = (byte*)malloc(size * sizeof(byte));
	fread_s(dataBuffer, size, sizeof(byte), size, file);
	fclose(file);

	uint indexLength = B2IU(dataBuffer);
	indexBuffer = (byte*)malloc(indexLength * sizeof(byte));
	memcpy_s(indexBuffer, indexLength, dataBuffer + 4, indexLength);

	offset = indexLength;

	index = (uint*)malloc(256 * sizeof(uint));
	memcpy_s(index, 256 * sizeof(uint), indexBuffer, 256 * sizeof(uint));
}


IpLocation::~IpLocation()
{
	free(index);
	free(indexBuffer);
	free(dataBuffer);
}

void IpLocation::find(TCHAR* ip, TCHAR* out){
	uint ips[4];
	_stscanf_s(ip, _T("%d.%d.%d.%d"), &ips[0], &ips[1], &ips[2], &ips[3]);
	uint ip_prefix_value = ips[0];
	uint ip2long_value = B2IU(ips);
	uint start = index[ip_prefix_value];
	uint max_comp_len = offset - 1028;
	uint index_offset = 0;
	uint index_length = 0;
	for (start = start * 8 + 1024; start < max_comp_len; start += 8)
	{
		if (B2IU(indexBuffer + start) >= ip2long_value)
		{
			index_offset = B2IL(indexBuffer + start + 4) & 0x00FFFFFF;
			index_length = indexBuffer[start + 7];
			break;
		}
	}
	char* temp = (char*)malloc(index_length + 1);
	memcpy_s(temp, index_length, dataBuffer + offset + index_offset - 1024, index_length);
	temp[index_length] = '\0';

#ifdef _UNICODE
	MultiByteToWideChar(CP_UTF8, 0, temp, -1, out, index_length + 1);
#else
	wchar_t* tempw = (wchar_t*)malloc((index_length + 1) * sizeof(wchar_t));
	MultiByteToWideChar(CP_UTF8, 0, temp, -1, tempw, index_length + 1);
	WideCharToMultiByte(CP_ACP, 0, tempw, -1, out, index_length + 1, NULL, NULL);
	free(tempw);
#endif
	free(temp);
}