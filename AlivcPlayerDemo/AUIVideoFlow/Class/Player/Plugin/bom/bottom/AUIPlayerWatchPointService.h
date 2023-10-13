//
//  AUIPlayerWatchPointService.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/29.
//

#import <Foundation/Foundation.h>

@interface AlivcPlayerWatchPointModel : NSObject
@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) int64_t ts;
@end


@interface AUIPlayerWatchPointService : NSObject

- (NSArray<AlivcPlayerWatchPointModel *> *)getWatchPoints;

@end


