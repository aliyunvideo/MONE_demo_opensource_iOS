//
//  AUILiveRecordPushModule.h
//  AlivcLiveDemo
//
//  Created by zzy on 2022/6/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveRecordPushModule : NSObject

- (instancetype)initWithSourceViewController:(UIViewController *)sourceVC;
+ (BOOL)checkCanOpen;
- (void)open;

@end

NS_ASSUME_NONNULL_END
