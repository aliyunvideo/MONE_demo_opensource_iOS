//
//  AlivcPlayerVideoHistoryProtocol.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/14.
//

#import <Foundation/Foundation.h>

@protocol AlivcPlayerVideoHistoryProtocol <NSObject>

- (void)saveToLocal:(NSString *)videoId;

- (int64_t)localWatchTime:(NSString *)videoId;
@end


