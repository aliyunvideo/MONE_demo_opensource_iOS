//
//  AlivcPlayerServer.h
//  ApsaraVideo
//
//  Created by Bingo on 2021/7/5.
//

#import <Foundation/Foundation.h>
#import "AlivcPlayerWebApiService.h"

NS_ASSUME_NONNULL_BEGIN

@interface AlivcPlayerServer : NSObject

+ (NSString *)host;
+ (NSString *)urlWithPath:(NSString *)path;

@end

NS_ASSUME_NONNULL_END
