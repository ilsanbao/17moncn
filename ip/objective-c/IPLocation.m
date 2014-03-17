//
//  IpLocation.m
//  objcdemos
//
//  Created by 范茹宽 on 14-3-16.
//
//

#import "IpLocation.h"

@implementation IpLocation

-(id)init
{
    self = [super init];
    if (self)
    {
        self.ipBinaryFilePath = @"/Users/fanrukuan/codesource/17monipdb.dat";
        NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:self.ipBinaryFilePath];
        self.data = [file readDataToEndOfFile];
        
        unsigned char bytes[4];
        [self.data getBytes:bytes length:4];
        
        self.offset = (int)bytes[0] << 24;
        self.offset |= (int)bytes[1] << 16;
        self.offset |= (int)bytes[2] << 8;
        self.offset |= (int)bytes[3];
    }
    
    return self;
}

-(NSString*)find:(NSString*)ip
{
    unsigned int ip_prefix = [ip intValue];
    NSArray *ip_array = [ip componentsSeparatedByString:@"."];
    
    unsigned int ip_uint32_value = [self arrayToBigEndianUint32:ip_array];
    
    unsigned char indexBytes[self.offset - 4];
    [self.data getBytes:indexBytes range: NSMakeRange(4, self.offset)];

    unsigned int index[256];
    for (int i = 0; i < 256; i++) {
        unsigned int  n = (int)indexBytes[i*4+3] << 24;
        n |= (int)indexBytes[i*4+2] << 16;
        n |= (int)indexBytes[i*4+1] << 8;
        n |= (int)indexBytes[i*4+0];
        index[i] = n;
    }
    
    unsigned int max_comp_len = self.offset - 1028;
    unsigned int start = index[ip_prefix] * 8 + 1024;
    unsigned int index_length = 0;
    unsigned int index_offset = 0;
    
    for (; start < max_comp_len; start += 8) {
        unsigned int  offset1 = (int)indexBytes[start] << 24;
        offset1 |= (int)indexBytes[start+1] << 16;
        offset1 |= (int)indexBytes[start+2] << 8;
        offset1 |= (int)indexBytes[start+3];
        if (offset1 >= ip_uint32_value) {
            index_length = (int)indexBytes[start+7];
            index_offset |= (int)indexBytes[start+6] << 16;
            index_offset |= (int)indexBytes[start+5] << 8;
            index_offset |= (int)indexBytes[start+4];
            
            break;
        }
    }
    
    NSRange range = NSMakeRange(self.offset + index_offset - 1024, index_length);
    unsigned char buf[index_length];
    [self.data getBytes:buf range:range];
    NSData *areaData = [NSData dataWithBytes:buf length:index_length];
    NSString *area = [[NSString alloc] initWithData:areaData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", area);
    
    return area;
}
-(unsigned int)arrayToBigEndianUint32:(NSArray*)Parray
{
    unsigned int o = [[Parray objectAtIndex:0] intValue] << 24;
    o |= [[Parray objectAtIndex:1] intValue] << 16;
    o |= [[Parray objectAtIndex:2] intValue] << 8;
    o |= [[Parray objectAtIndex:3] intValue];
    
    return o;
}
@end
