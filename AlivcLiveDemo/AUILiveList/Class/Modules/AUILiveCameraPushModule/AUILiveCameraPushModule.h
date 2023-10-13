//
//  AUILiveCameraPushModule.h
//  AlivcLiveDemo
//
//  Created by zzy on 2022/6/1.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveCameraPushModule : NSObject

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC;
- (void)open;

@end

NS_ASSUME_NONNULL_END
