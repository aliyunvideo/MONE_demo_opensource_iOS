//
//  AUIRecorderCountDownView.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIRecorderCountDownView : UIView
+ (AUIRecorderCountDownView *) ShowInView:(UIView *)view complete:(void(^)(BOOL isCanceled))complete;
@end

NS_ASSUME_NONNULL_END
