//
//  AUIRecorderRateSelectView.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AUIRecorderRateSelectView;
@protocol AUIRecorderRateSelectViewDelegate <NSObject>
- (void) onAUIRecorderRateSelectView:(AUIRecorderRateSelectView *)view rate:(CGFloat)rate;
@end

@interface AUIRecorderRateSelectView : UIView
@property (nonatomic, assign) CGFloat rate;
@property (nonatomic, weak) id<AUIRecorderRateSelectViewDelegate> delegate;
- (instancetype) initWithDelegate:(id<AUIRecorderRateSelectViewDelegate>)delegate;
@end

NS_ASSUME_NONNULL_END
