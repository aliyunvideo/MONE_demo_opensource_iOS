//
//  AUIRecorderCameraForceView.h
//  AlivcUgsvDemo
//
//  Created by coder.pi on 2022/6/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUIRecorderCameraForceView : UIView
@property (nonatomic, readonly) BOOL isShowing;
@property (nonatomic, readonly) CGFloat currentExposure; // -1, 1
- (CGFloat) addExposure:(CGFloat)exposure;
- (void) showOnPosition:(CGPoint)position;
@end

NS_ASSUME_NONNULL_END
