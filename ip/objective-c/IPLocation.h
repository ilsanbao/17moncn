//
//  IpLocation.h
//  objcdemos
//
//  Created by 范茹宽 on 14-3-16.
//
//

#import <Foundation/Foundation.h>

@interface IpLocation : NSObject

@property (strong, nonatomic) NSString *ipBinaryFilePath;
@property (strong, nonatomic) NSData *data;
@property (assign, nonatomic) unsigned int offset;

-(NSString*)find:(NSString*)ip;
@end