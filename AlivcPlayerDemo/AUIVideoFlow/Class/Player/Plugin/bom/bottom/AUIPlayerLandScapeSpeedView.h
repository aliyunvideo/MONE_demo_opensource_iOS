//
//  AUIPlayerLandScapeSpeedView.h
//  ApsaraVideo
//
//  Created by mengyehao on 2021/7/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIPlayerLandScapeSpeedView : UIView
@property (nonatomic, copy) void(^onRateChanged)(float rate);

- (void)updateSeletedRate:(float)rate;
@end

NS_ASSUME_NONNULL_END
