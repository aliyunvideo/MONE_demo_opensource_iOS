//
//  AUIPlayerWatchPointContainer.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/29.
//

#import <UIKit/UIKit.h>
#import "AUIPlayerNoActionView.h"

@class AlivcPlayerWatchPointModel;

NS_ASSUME_NONNULL_BEGIN

@interface AUIPlayerWatchPointContainer : AUIPlayerNoActionView

@property (nonatomic, weak) UIView *superContainer;

- (void)updateData;

@end

NS_ASSUME_NONNULL_END
