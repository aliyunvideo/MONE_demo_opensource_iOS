//
//  AUILiveLinkMicModule.h
//  AlivcLiveDemo
//
//  Created by ISS013602000846 on 2022/7/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveLinkMicModule : NSObject

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC;
+ (BOOL)checkCanOpen;
- (void)open;

@end

NS_ASSUME_NONNULL_END
