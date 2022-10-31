//
//  AUILiveCheckQueenManager.h
//  AlivcLivePusherDemo
//
//  Created by ISS013602000846 on 2022/8/16.
//  Copyright © 2022 TripleL. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AUILiveCheckQueenManager : NSObject

+ (void)checkWithCurrentView:(UIView *)view completed:(void (^)(BOOL completed))completed;

@end

NS_ASSUME_NONNULL_END
