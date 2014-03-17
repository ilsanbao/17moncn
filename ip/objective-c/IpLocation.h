//
//  IpLocation.h
//

#import <Foundation/Foundation.h>

@interface IpLocation : NSObject

@property (strong, nonatomic) NSString *ipBinaryFilePath;
@property (strong, nonatomic) NSData *data;
@property (assign, nonatomic) unsigned int offset;

-(NSString*)find:(NSString*)ip;
@end
