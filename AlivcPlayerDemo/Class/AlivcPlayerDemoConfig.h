//
//  AlivcPlayerDemoConfig.h
//  AlivcPlayerDemo
//
//  Created by ISS013602000846 on 2022/6/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlivcPlayerDemoConfig : NSObject

- (void)didFinishLaunching;

// 特殊横竖屏适配。如果没有则按默认视图方向，如果有则按照特殊适配，在特殊视图退出时复原适配
- (UIInterfaceOrientationMask)supportedInterfaceOrientation;

@end

NS_ASSUME_NONNULL_END
