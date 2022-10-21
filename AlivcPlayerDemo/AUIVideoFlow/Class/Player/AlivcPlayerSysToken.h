//
//  AlivcPlayerSysToken.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/13.
//

#import <Foundation/Foundation.h>


@interface AlivcPlayerSysToken : NSObject

@property (nullable, copy) NSString *accessKeyId;
@property (nullable, copy) NSString *accessKeySecret;
@property (nullable, copy) NSString *securityToken;
@property (nullable, copy) NSString *expirationDuration;//毫秒



- (void)refreshToken;

@end

