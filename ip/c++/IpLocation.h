#pragma once

#include <tchar.h>
typedef unsigned char byte;
typedef unsigned int uint;
class IpLocation
{
public:
	IpLocation();
	~IpLocation();
	void find(TCHAR* ip, TCHAR* out);

private:
	byte* dataBuffer;
	byte* indexBuffer;
	uint* index;
	uint offset;
};

