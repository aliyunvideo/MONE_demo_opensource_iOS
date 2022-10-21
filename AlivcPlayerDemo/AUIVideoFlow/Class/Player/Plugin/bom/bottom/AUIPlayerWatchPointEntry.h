//
//  AUIPlayerWatchPointEntry.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/29.
//

#import <UIKit/UIKit.h>
#import "AUIPlayerWatchPointService.h"

NS_ASSUME_NONNULL_BEGIN

@interface AUIPlayerWatchPointEntry : UIView
@property (nonatomic) AlivcPlayerWatchPointModel *model;
@property (nonatomic, copy) dispatch_block_t onViewBlock;
@end

NS_ASSUME_NONNULL_END
